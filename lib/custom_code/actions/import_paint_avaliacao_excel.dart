// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import '/pg_rebanho/pesagem_rebanho_sync.dart'
    show sincronizarUltimaPesagemRebanho;
import 'package:excel/excel.dart';

/// Importa planilha PAINT de avaliação (matrizes/desmama/sobreano).
///
/// Desmama/sobreano: o Peso_kg da planilha também vira pesagem no inLida
/// (`historico_pesagens`, tipo 'Desmama'/'Atual') e a ficha do animal é
/// sincronizada — terceira via de cadastro de peso, além do import do Painel e
/// do lançamento manual no Rebanho.
///
/// Retorna { inseridos, atualizados, pesagens_inseridas, pesagens_atualizadas,
/// erros: [{linha, motivo}] }.
Future<Map<String, dynamic>> importPaintAvaliacaoExcel(
  String? idPropriedade,
  String? tipo,
  FFUploadedFile? arquivo,
) async {
  final result = <String, dynamic>{
    'inseridos': 0,
    'atualizados': 0,
    'pesagens_inseridas': 0,
    'pesagens_atualizadas': 0,
    'erros': <Map<String, dynamic>>[],
  };
  if (idPropriedade == null || idPropriedade.isEmpty) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Propriedade não informada.'},
    ];
    return result;
  }
  if (arquivo?.bytes == null) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Arquivo vazio.'},
    ];
    return result;
  }

  final cfg = await loadPaintConfig(idPropriedade);
  if (cfg == null) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Configure PAINT antes de importar.'},
    ];
    return result;
  }

  final t = (tipo ?? '').toLowerCase().trim();
  final table = t == 'matrizes'
      ? 'paint_avaliacao_rah'
      : t == 'desmama'
          ? 'paint_avaliacao_desmama'
          : t == 'sobreano'
              ? 'paint_avaliacao_sobreano'
              : null;
  if (table == null) {
    result['erros'] = [
      {
        'linha': 0,
        'motivo': 'Tipo inválido: use matrizes, desmama ou sobreano.'
      },
    ];
    return result;
  }

  final excel = Excel.decodeBytes(arquivo!.bytes!.toList());
  if (excel.tables.isEmpty) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Planilha sem abas.'},
    ];
    return result;
  }
  final sheet = excel.tables[excel.tables.keys.first]!;
  if (sheet.rows.isEmpty) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Planilha vazia.'},
    ];
    return result;
  }

  final cabecalho = sheet.rows.first
      .map((c) => normalizePaintHeader(c?.value?.toString() ?? ''))
      .toList();

  int idx(String name) => cabecalho.indexOf(normalizePaintHeader(name));

  final iA12 = idx('a12');
  final iDataAv = idx('data_avaliacao');
  if (iA12 < 0 || iDataAv < 0) {
    result['erros'] = [
      {'linha': 1, 'motivo': 'Colunas A12 e Data_Avaliacao são obrigatórias.'},
    ];
    return result;
  }
  final technicalIndexes = _technicalIndexesFor(t, idx);
  if (technicalIndexes.every((i) => i < 0)) {
    result['erros'] = [
      {'linha': 1, 'motivo': 'Nenhuma coluna de nota técnica encontrada.'},
    ];
    return result;
  }

  final rebanho = await fetchRebanhoPaint(idPropriedade);
  final byNumero = <String, List<Map<String, dynamic>>>{};
  final byA12 = <String, Map<String, dynamic>>{};
  final duplicatedA12 = <String>{};
  for (final r in rebanho) {
    final n = (r['numeroAnimal'] ?? '').toString().trim();
    if (n.isNotEmpty) {
      byNumero.putIfAbsent(n, () => <Map<String, dynamic>>[]).add(r);
    }
    final a12Rebanho = _a12Key(a12FromRebanho(r, cfg));
    if (a12Rebanho.isEmpty) continue;
    if (byA12.containsKey(a12Rebanho)) {
      duplicatedA12.add(a12Rebanho);
      byA12.remove(a12Rebanho);
    } else if (!duplicatedA12.contains(a12Rebanho)) {
      byA12[a12Rebanho] = r;
    }
  }

  // Carrega TODAS as avaliações existentes da propriedade, paginando: o
  // PostgREST limita o SELECT a 1000 linhas por padrão. Sem paginar, animais
  // já avaliados além da 1000ª linha escapariam da detecção e cairiam no
  // INSERT puro (que não tem on_conflict), reintroduzindo o erro 23505.
  final existKeys = <String, String>{};
  const pagina = 1000;
  var offset = 0;
  while (true) {
    final lote = await SupaFlow.client
        .from(table)
        .select('id,animal_a12,data')
        .eq('id_propriedade', idPropriedade)
        .range(offset, offset + pagina - 1);
    for (final e in lote) {
      existKeys['${_a12Key(e['animal_a12']?.toString())}|${e['data']}'] =
          e['id'].toString();
    }
    if (lote.length < pagina) break;
    offset += pagina;
  }

  final erros = <Map<String, dynamic>>[];
  var inseridos = 0;
  var atualizados = 0;
  final inserts = <Map<String, dynamic>>[];
  final updates = <Map<String, dynamic>>[];
  final importKeys = <String>{};
  // Pesos das linhas aceitas, para registrar em historico_pesagens após a
  // gravação das avaliações (desmama → tipo 'Desmama'; sobreano → 'Atual').
  final pesagensPlanilha = <_PesagemPlanilha>[];
  final fichasPorRebanho = <String, Map<String, dynamic>>{};

  for (var r = 1; r < sheet.rows.length; r++) {
    final row = sheet.rows[r];
    final linha = r + 1;
    final a12 = _cel(row, iA12)?.trim() ?? '';
    if (a12.isEmpty) continue;
    final a12Key = _a12Key(a12);
    if (a12Key.isEmpty) continue;
    if (!_hasAnyCellValue(row, technicalIndexes)) continue;
    final dataAv = parseDateIso(_celValue(row, iDataAv));
    if (dataAv == null) {
      erros.add({'linha': linha, 'motivo': 'Data_Avaliacao inválida.'});
      continue;
    }
    if (duplicatedA12.contains(a12Key)) {
      erros.add({
        'linha': linha,
        'motivo':
            'A12 $a12Key é ambíguo: mais de um animal da propriedade gera o mesmo código.',
      });
      continue;
    }
    final reb = byA12[a12Key];
    if (reb == null) {
      erros.add({
        'linha': linha,
        'motivo':
            'A12 $a12Key não pertence ao rebanho da propriedade ou não pôde ser calculado com a configuração PAINT atual.',
      });
      continue;
    }
    if (!isElegivelAvaliacaoPaint(t, reb)) {
      erros.add({
        'linha': linha,
        'motivo':
            'Animal não elegível para $t: status "${reb['status'] ?? ''}", categoria "${reb['categoria'] ?? ''}".',
      });
      continue;
    }

    // Identificador único PAINT: A12 + número + data de nascimento. Quando a
    // planilha trouxer a coluna preenchida, confere com o rebanho para evitar
    // associar a avaliação ao animal errado.
    final iNasc = idx('data_nascimento');
    if (iNasc >= 0) {
      final nascCel = parseDateIso(_celValue(row, iNasc));
      if (nascCel != null) {
        final nascReb = parseDateIso(reb['dataNascimento']);
        if (nascReb != null && nascCel != nascReb) {
          erros.add({
            'linha': linha,
            'motivo':
                'Data_Nascimento $nascCel não confere com o animal do A12 $a12Key (rebanho: $nascReb).',
          });
          continue;
        }
      }
    }

    final iNum = idx('numero_animal');
    if (iNum >= 0) {
      final num = _cel(row, iNum);
      if (num != null && num.isNotEmpty) {
        final animaisMesmoNumero =
            byNumero[num] ?? const <Map<String, dynamic>>[];
        final numeroConfere =
            (reb['numeroAnimal'] ?? '').toString().trim() == num;
        if (!numeroConfere) {
          erros.add({
            'linha': linha,
            'motivo':
                'Numero_Animal $num não confere com o animal identificado pelo A12 $a12Key.',
          });
          continue;
        }
        if (animaisMesmoNumero.length > 1) {
          final algumConfere = animaisMesmoNumero
              .any((animal) => _a12Key(a12FromRebanho(animal, cfg)) == a12Key);
          if (!algumConfere) {
            erros.add({
              'linha': linha,
              'motivo':
                  'Numero_Animal $num é duplicado na propriedade e não pôde ser associado ao A12 $a12Key.',
            });
            continue;
          }
        }
      }
    }

    Map<String, dynamic> payload = {
      'id_propriedade': idPropriedade,
      'animal_a12': _a12DbValue(a12),
      'data': dataAv,
      'updated_at': DateTime.now().toIso8601String(),
    };
    num? pesoPesagem;

    if (t == 'matrizes') {
      final racial = parseNota(_celNum(row, idx('raca')), min: 1, max: 5);
      final frame = parseNota(_celNum(row, idx('frame')), min: 1, max: 3);
      final aprumo = parseNota(_celNum(row, idx('aprumo')), min: 1, max: 5);
      final pigment =
          parseNota(_celNum(row, idx('pigmentacao')), min: 1, max: 3);
      if (racial == null &&
          frame == null &&
          aprumo == null &&
          pigment == null) {
        erros.add(
            {'linha': linha, 'motivo': 'Informe ao menos uma nota técnica.'});
        continue;
      }
      if (racial != null) payload['racial'] = racial;
      if (frame != null) payload['frame'] = frame;
      if (aprumo != null) payload['aprumos'] = aprumo;
      if (pigment != null) payload['pigmentacao'] = pigment;
    } else if (t == 'desmama') {
      final c = parseNota(_celNum(row, idx('conformacao_c')));
      final p = parseNota(_celNum(row, idx('precocidade_p')));
      final m = parseNota(_celNum(row, idx('musculatura_m')));
      final u = parseNota(_celNum(row, idx('umbigo_u')));
      if (c == null || p == null || m == null || u == null) {
        erros.add({'linha': linha, 'motivo': 'Notas C/P/M/U devem ser 1–5.'});
        continue;
      }
      payload['nota_c'] = c;
      payload['nota_p'] = p;
      payload['nota_m'] = m;
      payload['nota_u'] = u;
      final obs = normalizarAnotacao(_cel(row, idx('anotacao')));
      if (obs != null) payload['obs'] = obs;
      final pesoRaw = _celValue(row, idx('peso_kg'));
      final peso = _celNum(row, idx('peso_kg'));
      if (peso != null && peso > 0) {
        payload['peso'] = peso;
        pesoPesagem = peso;
      } else if (!_isBlankValue(pesoRaw)) {
        erros.add({
          'linha': linha,
          'motivo': 'Aviso: Peso_kg inválido ("$pesoRaw") — avaliação '
              'importada, mas a pesagem não foi registrada no rebanho.',
        });
      }
    } else {
      final c = parseNota(_celNum(row, idx('conformacao_c')));
      final p = parseNota(_celNum(row, idx('precocidade_p')));
      final m = parseNota(_celNum(row, idx('musculatura_m')));
      final u = parseNota(_celNum(row, idx('umbigo_u')));
      final temp = parseNota(_celNum(row, idx('temperamento_t')));
      if (c == null || p == null || m == null || u == null) {
        erros.add({'linha': linha, 'motivo': 'Notas C/P/M/U devem ser 1–5.'});
        continue;
      }
      if (temp != null && temp == 3) {
        erros.add({'linha': linha, 'motivo': 'Temperamento não pode ser 3.'});
        continue;
      }
      payload['nota_c'] = c;
      payload['nota_p'] = p;
      payload['nota_m'] = m;
      payload['nota_u'] = u;
      if (temp != null) payload['nota_t'] = temp;
      final pe = parseNota(_celNum(row, idx('perimetro_escrotal_pe')));
      if (pe != null) payload['nota_ce'] = pe;
      final obs = normalizarAnotacao(_cel(row, idx('anotacao')));
      if (obs != null) payload['obs'] = obs;
      final pesoRaw = _celValue(row, idx('peso_kg'));
      final peso = _celNum(row, idx('peso_kg'));
      if (peso != null && peso > 0) {
        payload['peso'] = peso;
        pesoPesagem = peso;
      } else if (!_isBlankValue(pesoRaw)) {
        erros.add({
          'linha': linha,
          'motivo': 'Aviso: Peso_kg inválido ("$pesoRaw") — avaliação '
              'importada, mas a pesagem não foi registrada no rebanho.',
        });
      }
    }

    final key = '$a12Key|$dataAv';
    if (importKeys.contains(key)) {
      erros.add({
        'linha': linha,
        'motivo':
            'Avaliação duplicada na planilha para A12 $a12Key e data $dataAv.',
      });
      continue;
    }
    importKeys.add(key);
    // Inserts e updates são separados em dois lotes. O postgrest-dart 2.4.2
    // descarta o parâmetro `on_conflict` em upsert de LISTA (bug: ao montar o
    // `columns=` ele sobrescreve a URL e perde o on_conflict), então não dá
    // para resolver o conflito pela unique (id_propriedade,animal_a12,data).
    //  - Novos: insert sem `id` (o DEFAULT gen_random_uuid gera o id).
    //  - Existentes: upsert com `id` em todas as linhas → conflito pela PRIMARY
    //    KEY (usada pelo merge-duplicates por padrão, sem precisar de on_conflict).
    if (existKeys.containsKey(key)) {
      payload['id'] = existKeys[key];
      updates.add(payload);
      atualizados++;
    } else {
      inserts.add(payload);
      inseridos++;
    }

    if (pesoPesagem != null) {
      final idReb = (reb['idRebanho'] ?? '').toString().trim();
      if (idReb.isNotEmpty) {
        pesagensPlanilha.add(_PesagemPlanilha(idReb, dataAv, pesoPesagem));
        fichasPorRebanho[idReb] = reb;
      }
    }
  }

  const tam = 200;
  for (var i = 0; i < inserts.length; i += tam) {
    final fim = (i + tam < inserts.length) ? i + tam : inserts.length;
    await SupaFlow.client.from(table).insert(inserts.sublist(i, fim));
  }
  for (var i = 0; i < updates.length; i += tam) {
    final fim = (i + tam < updates.length) ? i + tam : updates.length;
    await SupaFlow.client.from(table).upsert(updates.sublist(i, fim));
  }

  // Só depois de as avaliações gravarem com sucesso, alimenta o peso no
  // rebanho do inLida (elimina a dupla digitação Painel + PAINT).
  if (t == 'desmama' || t == 'sobreano') {
    final resumo = await _registrarPesagensImportadas(
      idPropriedade: idPropriedade,
      tipoPesagem: t == 'desmama' ? 'Desmama' : 'Atual',
      itens: pesagensPlanilha,
      fichas: fichasPorRebanho,
      atualizarFichaDesmama: t == 'desmama',
    );
    result['pesagens_inseridas'] = resumo['inseridas'];
    result['pesagens_atualizadas'] = resumo['atualizadas'];
  }

  result['inseridos'] = inseridos;
  result['atualizados'] = atualizados;
  result['erros'] = erros;
  return result;
}

/// Peso de uma linha aceita da planilha, destinado a `historico_pesagens`.
class _PesagemPlanilha {
  final String idRebanho;
  final String dataIso;
  final num peso;
  _PesagemPlanilha(this.idRebanho, this.dataIso, this.peso);
}

/// Registra os pesos da planilha em `historico_pesagens` e sincroniza a ficha
/// dos animais afetados. Idempotente: reimportar a mesma planilha não duplica.
///  - Desmama é evento único do animal: atualiza a pesagem 'Desmama' existente
///    mesmo se a data foi corrigida na planilha (nunca cria uma segunda).
///  - 'Atual' (sobreano) é um registro por data: mesma data atualiza o peso,
///    data nova insere.
Future<Map<String, int>> _registrarPesagensImportadas({
  required String idPropriedade,
  required String tipoPesagem,
  required List<_PesagemPlanilha> itens,
  required Map<String, Map<String, dynamic>> fichas,
  required bool atualizarFichaDesmama,
}) async {
  if (itens.isEmpty) return const {'inseridas': 0, 'atualizadas': 0};

  final existentes = await fetchPesagensPaintPorRebanho(
    itens.map((i) => i.idRebanho),
    tipo: tipoPesagem,
  );
  final porRebanho = <String, List<Map<String, dynamic>>>{};
  for (final p in existentes) {
    (porRebanho[(p['idRebanho'] ?? '').toString()] ??= []).add(p);
  }

  final inserts = <Map<String, dynamic>>[];
  final updates = <Map<String, dynamic>>[];
  // Animais cuja "Última pesagem"/"Peso atual" da ficha precisa ser recalculada.
  final sincronizarFicha = <String>{};
  final fichaDesmama = <String, Map<String, dynamic>>{};

  for (final item in itens) {
    final ativos = porRebanho[item.idRebanho] ?? const [];
    Map<String, dynamic>? alvo;
    for (final p in ativos) {
      if (tipoPesagem != 'Desmama' &&
          parseDateIso(p['dataPesagem']) != item.dataIso) {
        continue;
      }
      if (alvo == null || (p['id'] as num) > (alvo['id'] as num)) alvo = p;
    }

    final registro = <String, dynamic>{
      'idRebanho': item.idRebanho,
      'id_propriedade': idPropriedade,
      'dataPesagem': item.dataIso,
      'tipo': tipoPesagem,
      'peso': item.peso,
      'deletado': 'NAO',
    };

    if (alvo != null) {
      final mesmaData = parseDateIso(alvo['dataPesagem']) == item.dataIso;
      if (!mesmaData || !_pesoIgual(alvo['peso'], item.peso)) {
        updates.add({'id': alvo['id'], 'registro': registro});
        sincronizarFicha.add(item.idRebanho);
      }
    } else {
      inserts.add(registro);
      // Insert só mexe na ficha se puder virar a última pesagem do animal.
      final ultimaIso = parseDateIso(fichas[item.idRebanho]?['dataUltimaPesagem']);
      if (ultimaIso == null || item.dataIso.compareTo(ultimaIso) >= 0) {
        sincronizarFicha.add(item.idRebanho);
      }
    }

    if (atualizarFichaDesmama) {
      final ficha = fichas[item.idRebanho];
      if (parseDateIso(ficha?['dataDesmama']) != item.dataIso ||
          !_pesoIgual(ficha?['pesoDesmama'], item.peso)) {
        fichaDesmama[item.idRebanho] = {
          'dataDesmama': item.dataIso,
          'pesoDesmama': item.peso,
        };
      }
    }
  }

  const tam = 200;
  for (var i = 0; i < inserts.length; i += tam) {
    final fim = (i + tam < inserts.length) ? i + tam : inserts.length;
    await SupaFlow.client
        .from('historico_pesagens')
        .insert(inserts.sublist(i, fim));
  }
  await _emLotesConcorrentes(updates, (u) async {
    await SupaFlow.client
        .from('historico_pesagens')
        .update(u['registro'] as Map<String, dynamic>)
        .eq('id', u['id']);
  });

  // Espelha o que o import do Painel grava na ficha para a desmama.
  await _emLotesConcorrentes(fichaDesmama.entries.toList(), (e) async {
    await SupaFlow.client.from('rebanho').update(e.value).eq('idRebanho', e.key);
  });

  // Recalcula Última pesagem/Peso atual pela regra oficial (pesagem ativa mais
  // recente) — não regride se o animal já tem pesagem mais nova que a planilha.
  await _emLotesConcorrentes(sincronizarFicha.toList(), (idReb) async {
    await sincronizarUltimaPesagemRebanho(
      idRebanho: idReb,
      sincronizarPesoAtual: true,
    );
  });

  return {'inseridas': inserts.length, 'atualizadas': updates.length};
}

bool _pesoIgual(dynamic a, num b) {
  final na = a is num
      ? a
      : num.tryParse((a ?? '').toString().replaceAll(',', '.'));
  if (na == null) return false;
  return (na - b).abs() < 0.001;
}

/// Executa [acao] sobre [itens] em lotes paralelos limitados — atualizações
/// linha a linha no PostgREST sem estourar conexões nem serializar tudo.
Future<void> _emLotesConcorrentes<T>(
  List<T> itens,
  Future<void> Function(T) acao, {
  int concorrencia = 8,
}) async {
  for (var i = 0; i < itens.length; i += concorrencia) {
    final fim =
        (i + concorrencia < itens.length) ? i + concorrencia : itens.length;
    await Future.wait(itens.sublist(i, fim).map(acao));
  }
}

List<int> _technicalIndexesFor(String tipo, int Function(String) idx) {
  if (tipo == 'matrizes') {
    return [
      idx('raca'),
      idx('frame'),
      idx('aprumo'),
      idx('pigmentacao'),
    ];
  }
  if (tipo == 'desmama') {
    return [
      idx('conformacao_c'),
      idx('precocidade_p'),
      idx('musculatura_m'),
      idx('umbigo_u'),
      idx('anotacao'),
    ];
  }
  return [
    idx('conformacao_c'),
    idx('precocidade_p'),
    idx('musculatura_m'),
    idx('umbigo_u'),
    idx('temperamento_t'),
    idx('perimetro_escrotal_pe'),
    idx('anotacao'),
  ];
}

bool _hasAnyCellValue(List<dynamic> row, List<int> indexes) {
  for (final index in indexes) {
    if (!_isBlankValue(_celValue(row, index))) return true;
  }
  return false;
}

bool _isBlankValue(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  return false;
}

String? _cel(List<dynamic> row, int index) {
  final v = _celValue(row, index);
  if (v == null) return null;
  return v.toString().trim();
}

dynamic _celValue(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) return null;
  final cell = row[index];
  if (cell == null) return null;
  final v = cell.value;
  if (v == null) return null;
  if (v is DateCellValue) return v.asDateTimeLocal();
  if (v is DoubleCellValue) return v.value;
  if (v is IntCellValue) return v.value;
  if (v is TextCellValue) return v.value.text ?? '';
  return v;
}

/// Lê uma célula como número. Célula vazia (ou texto não-numérico) vira `null`
/// — importante para NÃO enviar string vazia "" a colunas numéricas do banco
/// (erro 22P02). Aceita vírgula decimal ("300,00").
num? _celNum(List<dynamic> row, int index) {
  final v = _celValue(row, index);
  if (v == null) return null;
  if (v is num) return v;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return num.tryParse(s.replaceAll(',', '.'));
}

String _a12DbValue(String raw) {
  final clean = raw.trim();
  if (clean.length > 12) return clean.substring(0, 12);
  return clean.padRight(12, ' ');
}

String _a12Key(String? raw) {
  if (raw == null) return '';
  return _a12DbValue(raw).trim();
}
