// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
import 'paint_helpers.dart';
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Popula tabelas paint_* derivando dados de tabelas legadas
/// (reproducao, lotes, rebanho, historico_pesagens) para a propriedade
/// selecionada. Idempotente — rodar 2x não duplica.
///
/// Filtros opcionais (reunião 01/06 — evitar volumes grandes, ex.: Cachoeira
/// ~1.400 registros): intervalo de data de nascimento do animal e intervalo de
/// data do evento/avaliação. Os filtros afetam apenas as avaliações derivadas
/// por animal (composição, desmama, sobreano, RAH, diagnóstico); os cadastros
/// de apoio (inseminadores, grupos, localidades, safras, regimes, biblioteca)
/// são sempre importados integralmente. Avaliadores são cadastrados manualmente
/// (decisão do cliente) e não são derivados automaticamente.
///
/// Retorna contagens por categoria (quantos itens novos foram inseridos).
/// Chave 'erro' (>0) sinaliza falha geral, com 'mensagem' contendo o erro.
Future<Map<String, dynamic>> autoPreencherPaint(
  String? idPropriedade, {
  DateTime? dataNascimentoDe,
  DateTime? dataNascimentoAte,
  DateTime? dataAvaliacaoDe,
  DateTime? dataAvaliacaoAte,
}) async {
  final result = <String, dynamic>{
    'inseminadores': 0,
    'grupos': 0,
    'localidades': 0,
    'safras': 0,
    'composicao': 0,
    'desmamas': 0,
    'sobreanos': 0,
    'rahs': 0,
    'diagnosticos': 0,
    'regimes': 0,
    'biblioteca': 0,
    'erro': 0,
    'mensagem': '',
    'falhas': <String>[],
  };
  Future<void> exec(String label, Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      (result['falhas'] as List).add(_mensagemFalhaEtapa(label, e));
    }
  }

  if (idPropriedade == null || idPropriedade.trim().isEmpty) {
    result['erro'] = 1;
    result['mensagem'] = 'Selecione uma propriedade.';
    return result;
  }
  final client = SupaFlow.client;

  try {
    // Config obrigatória para calcular A12.
    final configRows = await client
        .from('paint_fazenda_config')
        .select(
          'codigo_transmissao,serie_fazenda,serie_raca_po,codigo_fazenda,'
          'programa,estrategia_a12,campo_origem_animal',
        )
        .eq('id_propriedade', idPropriedade)
        .limit(1);
    if (configRows.isEmpty) {
      result['erro'] = 1;
      result['mensagem'] =
          'Configure código de transmissão e série fazenda antes.';
      return result;
    }
    final cfgRow = configRows.first;
    final serieFazenda = (cfgRow['serie_fazenda'] ?? '').toString().trim();
    if (serieFazenda.isEmpty) {
      result['erro'] = 1;
      result['mensagem'] = 'Série fazenda vazia em paint_fazenda_config.';
      return result;
    }
    final paintCfg = PaintConfigExcel(
      codigoTransmissao: (cfgRow['codigo_transmissao'] ?? '').toString(),
      serieFazenda: serieFazenda,
      serieRacaPo: (cfgRow['serie_raca_po'] ?? '').toString().trim().isEmpty
          ? null
          : (cfgRow['serie_raca_po']).toString().trim(),
      codigoFazenda: (cfgRow['codigo_fazenda'] ?? '0001').toString(),
      programa: (cfgRow['programa'] ?? 'P').toString(),
      estrategia: parseEstrategiaA12(cfgRow['estrategia_a12']?.toString()),
      campoOrigemAnimal:
          (cfgRow['campo_origem_animal'] ?? 'numeroAnimal').toString(),
    );

    // Pré-fetch dos cadastros pequenos (lookup tables, < 1000 linhas).
    final r1 = await Future.wait<dynamic>([
      client
          .from('paint_inseminador')
          .select('codigo, nome')
          .eq('id_propriedade', idPropriedade),
      client
          .from('paint_localidade')
          .select('codigo, descricao')
          .eq('id_propriedade', idPropriedade),
      client
          .from('paint_safra')
          .select('codigo')
          .eq('id_propriedade', idPropriedade),
      client
          .from('paint_regime_alimentar')
          .select('codigo, descricao')
          .eq('id_propriedade', idPropriedade),
    ]);
    final existIns = (r1[0] as List).cast<Map<String, dynamic>>();
    final existLocs = (r1[1] as List).cast<Map<String, dynamic>>();
    final existSafras = (r1[2] as List).cast<Map<String, dynamic>>();
    final existRegs = (r1[3] as List).cast<Map<String, dynamic>>();

    // Pré-fetch paginado das tabelas grandes (>1000 linhas possíveis).
    final existComp = await _selectAllPaged(
      client,
      'paint_composicao_racial',
      'animal_a12,raca_codigo',
      {'id_propriedade': idPropriedade},
    );
    final existDes = await _selectAllPaged(
      client,
      'paint_avaliacao_desmama',
      'animal_a12,data',
      {'id_propriedade': idPropriedade},
    );
    final existSob = await _selectAllPaged(
      client,
      'paint_avaliacao_sobreano',
      'animal_a12,data',
      {'id_propriedade': idPropriedade},
    );
    final existRah = await _selectAllPaged(
      client,
      'paint_avaliacao_rah',
      'animal_a12,data',
      {'id_propriedade': idPropriedade},
    );
    final existDiag = await _selectAllPaged(
      client,
      'paint_diagnostico',
      'animal_a12,data,safra_codigo',
      {'id_propriedade': idPropriedade},
    );
    final existBib = await _selectAllPaged(
      client,
      'paint_biblioteca_touros',
      'a12',
      const {},
    );

    // Fontes legadas (todas paginadas).
    final reproRows = await _selectAllPaged(
      client,
      'reproducao',
      'id_propriedade,inseminador,id_rebanho_matriz,status_reproducao,data_status,data_inseminacao',
      {'id_propriedade': idPropriedade, 'deletado': 'NAO'},
      orderColumn: 'id',
    );
    final loteRows = await _selectAllPaged(
      client,
      'lotes',
      'id_propriedade,nome',
      {'id_propriedade': idPropriedade, 'deletado': 'NAO'},
    );
    final rebanhoRows = await _selectAllPaged(
      client,
      'rebanho',
      'idRebanho,idPropriedade,numeroAnimal,dataNascimento,raca,sexo,'
          'categoria,status,dataDesmama,pesoDesmama,dataUltimaPesagem,pesoAtual',
      {'idPropriedade': idPropriedade, 'deletado': 'NAO'},
      orderColumn: 'id',
    );
    final pesagemRows = await _selectAllPaged(
      client,
      'historico_pesagens',
      'id_propriedade,idRebanho,dataPesagem,peso,tipo',
      {'id_propriedade': idPropriedade, 'deletado': 'NAO'},
      orderColumn: 'id',
    );

    // Index rebanho por idRebanho para joins manuais.
    final rebanhoById = <String, Map<String, dynamic>>{};
    for (final r in rebanhoRows) {
      final id = r['idRebanho']?.toString() ?? '';
      if (id.isNotEmpty) rebanhoById[id] = r;
    }

    String a12Of(Map<String, dynamic> r) => a12FromRebanho(r, paintCfg);

    // Filtros opcionais por data — aplicados só às avaliações por animal.
    bool nascDentro(Map<String, dynamic> r) => dentroIntervaloData(
          parseDateIso(r['dataNascimento']),
          dataNascimentoDe,
          dataNascimentoAte,
        );
    bool avDentro(String? iso) =>
        dentroIntervaloData(iso, dataAvaliacaoDe, dataAvaliacaoAte);

    // ---------------- 1. INSEMINADORES ----------------
    await exec('inseminadores', () async {
      final insExistNomes = existIns
          .map((e) => (e['nome'] ?? '').toString().trim().toUpperCase())
          .toSet();
      final insCodigosUsados = _codigosUsados(existIns.map((e) => e['codigo']));
      final insertIns = <Map<String, dynamic>>[];
      final insSet = <String>{};
      for (final r in reproRows) {
        final nome = (r['inseminador'] ?? '').toString().trim();
        if (nome.isEmpty) continue;
        final norm = nome.toUpperCase();
        if (insExistNomes.contains(norm)) continue;
        if (insSet.contains(norm)) continue;
        insSet.add(norm);
        insertIns.add({
          'id_propriedade': idPropriedade,
          'codigo': _proximoCodigoLivre(insCodigosUsados),
          'nome': nome.length > 20 ? nome.substring(0, 20) : nome,
          'situacao': 'ATIVO',
        });
      }
      if (insertIns.isNotEmpty) {
        result['inseminadores'] = await _upsertCodedRowsSafely(
          client,
          'paint_inseminador',
          insertIns,
          'id_propriedade,codigo',
          insCodigosUsados,
        );
      }
    });

    // ---------------- 2. GRUPOS MANEJO ----------------
    await exec('grupos_manejo', () async {
      // Recarrega imediatamente antes de inserir para evitar conflito quando
      // outro fluxo criou grupo desde o pré-fetch inicial.
      final gruposAtuais = await _selectAllPaged(
        client,
        'paint_grupo_manejo',
        'codigo,descricao',
        {'id_propriedade': idPropriedade},
      );
      final grpExistDesc = gruposAtuais
          .map((e) => (e['descricao'] ?? '').toString().trim().toUpperCase())
          .toSet();
      final grpCodigosUsados =
          _codigosUsados(gruposAtuais.map((e) => e['codigo']));
      final insertGrp = <Map<String, dynamic>>[];
      final grpSet = <String>{};
      for (final r in loteRows) {
        final nome = (r['nome'] ?? '').toString().trim();
        if (nome.isEmpty) continue;
        final norm = nome.toUpperCase();
        if (grpExistDesc.contains(norm)) continue;
        if (grpSet.contains(norm)) continue;
        grpSet.add(norm);
        insertGrp.add({
          'id_propriedade': idPropriedade,
          'codigo': _proximoCodigoLivre(grpCodigosUsados),
          'descricao': nome.length > 20 ? nome.substring(0, 20) : nome,
        });
      }
      if (insertGrp.isNotEmpty) {
        result['grupos'] = await _upsertCodedRowsSafely(
          client,
          'paint_grupo_manejo',
          insertGrp,
          'id_propriedade,codigo',
          grpCodigosUsados,
        );
      }
    });

    // ---------------- 3. LOCALIDADES ----------------
    await exec('localidades', () async {
      if (existLocs.isEmpty) {
        final insertLoc = <Map<String, dynamic>>[];
        for (var i = 1; i <= 5; i++) {
          insertLoc.add({
            'id_propriedade': idPropriedade,
            'codigo': i.toString().padLeft(4, '0'),
            'descricao': 'PASTO ${i.toString().padLeft(2, '0')}',
          });
        }
        await _upsertIgnore(
            client, 'paint_localidade', insertLoc, 'id_propriedade,codigo');
        result['localidades'] = insertLoc.length;
      }
    });

    // ---------------- 4. SAFRA atual ----------------
    final hoje = DateTime.now();
    final letra = _letraTrimestre(hoje.month);
    final ano2 = (hoje.year % 100).toString().padLeft(2, '0');
    final codSafra = '$ano2$letra';
    await exec('safra', () async {
      final safrasExist =
          existSafras.map((e) => (e['codigo'] ?? '').toString()).toSet();
      if (!safrasExist.contains(codSafra)) {
        final lim = _limitesTrimestre(hoje.year, hoje.month);
        await client.from('paint_safra').upsert({
          'id_propriedade': idPropriedade,
          'codigo': codSafra,
          'descricao': 'Safra $codSafra',
          'data_inicio': lim[0],
          'data_final': lim[1],
          'concluida': false,
        }, onConflict: 'id_propriedade,codigo');
        result['safras'] = 1;
      }
    });

    // ---------------- 5. COMPOSIÇÃO RACIAL ----------------
    await exec('composicao_racial', () async {
      // Normaliza chaves trim (banco armazena character(N) com padding).
      final compExist = existComp
          .map((e) =>
              '${(e['animal_a12'] ?? '').toString().trim()}|${(e['raca_codigo'] ?? '').toString().trim()}')
          .toSet();
      final insertComp = <Map<String, dynamic>>[];
      for (final r in rebanhoRows) {
        if (!nascDentro(r)) continue;
        final a = a12Of(r);
        if (a.isEmpty) continue;
        final racaCod = mapRacaCodigo(r['raca']);
        final key = '${a.trim()}|$racaCod';
        if (compExist.contains(key)) continue;
        compExist.add(key);
        insertComp.add({
          'id_propriedade': idPropriedade,
          'animal_a12': a,
          'raca_codigo': racaCod,
          'indice': 1.00,
        });
      }
      if (insertComp.isNotEmpty) {
        await _upsertIgnore(client, 'paint_composicao_racial', insertComp,
            'id_propriedade,animal_a12,raca_codigo');
        result['composicao'] = insertComp.length;
      }
    });

    // ---------------- 6. AVALIAÇÃO DESMAMA ----------------
    await exec('desmamas', () async {
      final desExist =
          existDes.map((e) => '${e['animal_a12']}|${e['data']}').toSet();
      final insertDes = <Map<String, dynamic>>[];
      for (final r in rebanhoRows) {
        if (!filtroDesmama(r)) continue;
        if (!nascDentro(r)) continue;
        final peso = r['pesoDesmama'];
        final data = r['dataDesmama'];
        if (peso == null || data == null) continue;
        final a = a12Of(r);
        if (a.isEmpty) continue;
        final dataStr = parseDateIso(data);
        if (dataStr == null) continue;
        if (!avDentro(dataStr)) continue;
        final key = '$a|$dataStr';
        if (desExist.contains(key)) continue;
        desExist.add(key);
        insertDes.add({
          'id_propriedade': idPropriedade,
          'animal_a12': a,
          'data': dataStr,
          'peso': peso,
        });
      }
      if (insertDes.isNotEmpty) {
        await _upsertIgnore(client, 'paint_avaliacao_desmama', insertDes,
            'id_propriedade,animal_a12,data');
        result['desmamas'] = insertDes.length;
      }
    });

    // ---------------- 7. AVALIAÇÃO SOBREANO ----------------
    await exec('sobreanos', () async {
      final sobExist =
          existSob.map((e) => '${e['animal_a12']}|${e['data']}').toSet();
      final insertSob = <Map<String, dynamic>>[];
      for (final p in pesagemRows) {
        final tipo = (p['tipo'] ?? '').toString().toLowerCase();
        final pesoP = p['peso'];
        final dataP = p['dataPesagem'];
        if (pesoP == null || dataP == null) continue;
        final idReb = p['idRebanho']?.toString() ?? '';
        final reb = rebanhoById[idReb];
        if (reb == null) continue;
        if (!filtroSobreano(reb)) continue;
        if (!nascDentro(reb)) continue;
        DateTime? dPes;
        if (dataP is String && dataP.isNotEmpty) {
          dPes = DateTime.tryParse(dataP);
        } else if (dataP is DateTime) {
          dPes = dataP;
        }
        if (dPes == null) continue;
        bool ehSobreano = tipo.contains('sobre');
        if (!ehSobreano) {
          final nasc = reb['dataNascimento'];
          DateTime? dN;
          if (nasc is String && nasc.isNotEmpty) {
            dN = DateTime.tryParse(nasc);
          } else if (nasc is DateTime) {
            dN = nasc;
          }
          if (dN != null) {
            final idade = dPes.difference(dN).inDays;
            ehSobreano = idade >= 365 && idade <= 550;
          }
        }
        if (!ehSobreano) continue;
        final a = a12Of(reb);
        if (a.isEmpty) continue;
        final dataStr = dPes.toIso8601String().substring(0, 10);
        if (!avDentro(dataStr)) continue;
        final key = '$a|$dataStr';
        if (sobExist.contains(key)) continue;
        sobExist.add(key);
        insertSob.add({
          'id_propriedade': idPropriedade,
          'animal_a12': a,
          'data': dataStr,
          'peso': pesoP,
        });
      }
      for (final reb in rebanhoRows) {
        if (!filtroSobreano(reb)) continue;
        if (!nascDentro(reb)) continue;
        final peso = reb['pesoAtual'];
        final data = reb['dataUltimaPesagem'];
        if (peso == null || data == null) continue;
        final a = a12Of(reb);
        if (a.isEmpty) continue;
        final dataStr = parseDateIso(data);
        if (dataStr == null) continue;
        if (!avDentro(dataStr)) continue;
        final key = '$a|$dataStr';
        if (sobExist.contains(key)) continue;
        sobExist.add(key);
        insertSob.add({
          'id_propriedade': idPropriedade,
          'animal_a12': a,
          'data': dataStr,
          'peso': peso,
        });
      }
      if (insertSob.isNotEmpty) {
        await _upsertIgnore(client, 'paint_avaliacao_sobreano', insertSob,
            'id_propriedade,animal_a12,data');
        result['sobreanos'] = insertSob.length;
      }
    });

    // ---------------- 8. AVALIAÇÃO RAH ----------------
    await exec('rahs', () async {
      final rahExist =
          existRah.map((e) => '${e['animal_a12']}|${e['data']}').toSet();
      final insertRah = <Map<String, dynamic>>[];
      for (final r in rebanhoRows) {
        if (!filtroMatrizes(r)) continue;
        if (!nascDentro(r)) continue;
        final peso = r['pesoAtual'];
        final data = r['dataUltimaPesagem'];
        if (peso == null || data == null) continue;
        final a = a12Of(r);
        if (a.isEmpty) continue;
        final dataStr = parseDateIso(data);
        if (dataStr == null) continue;
        if (!avDentro(dataStr)) continue;
        final key = '$a|$dataStr';
        if (rahExist.contains(key)) continue;
        rahExist.add(key);
        insertRah.add({
          'id_propriedade': idPropriedade,
          'animal_a12': a,
          'data': dataStr,
          'peso': peso,
        });
      }
      if (insertRah.isNotEmpty) {
        await _upsertIgnore(client, 'paint_avaliacao_rah', insertRah,
            'id_propriedade,animal_a12,data');
        result['rahs'] = insertRah.length;
      }
    });

    // ---------------- 9. DIAGNÓSTICO ----------------
    await exec('diagnosticos', () async {
      final diagExist = existDiag
          .map((e) => '${e['animal_a12']}|${e['data']}|${e['safra_codigo']}')
          .toSet();
      final insertDiag = <Map<String, dynamic>>[];
      for (final rep in reproRows) {
        final status =
            (rep['status_reproducao'] ?? '').toString().toLowerCase();
        String? resultadoPV;
        if (status.contains('prenh') || status == 'p') {
          resultadoPV = 'P';
        } else if (status.contains('vazi') || status == 'v') {
          resultadoPV = 'V';
        }
        if (resultadoPV == null) continue;
        final dataDiag = rep['data_status'] ?? rep['data_inseminacao'];
        if (dataDiag == null) continue;
        final idMatriz = rep['id_rebanho_matriz']?.toString() ?? '';
        final reb = rebanhoById[idMatriz];
        if (reb == null) continue;
        if (!nascDentro(reb)) continue;
        if (!avDentro(parseDateIso(dataDiag))) continue;
        final a = a12Of(reb);
        if (a.isEmpty) continue;
        final dataStr = dataDiag is String ? dataDiag : dataDiag.toString();
        final key = '$a|$dataStr|$codSafra';
        if (diagExist.contains(key)) continue;
        diagExist.add(key);
        insertDiag.add({
          'id_propriedade': idPropriedade,
          'safra_codigo': codSafra,
          'animal_a12': a,
          'data': dataStr,
          'resultado': resultadoPV,
        });
      }
      if (insertDiag.isNotEmpty) {
        await _upsertIgnore(client, 'paint_diagnostico', insertDiag,
            'id_propriedade,safra_codigo,animal_a12,data');
        result['diagnosticos'] = insertDiag.length;
      }
    });

    // ---------------- 10. AVALIADORES (cadastro manual) ----------------
    // Por decisão do cliente, os avaliadores são cadastrados manualmente na tela
    // PAINT > Cadastros automáticos > Avaliadores. Não há fonte na INLIDA para
    // derivá-los automaticamente, então esta importação não cria avaliadores.

    // ---------------- 11. REGIMES ALIMENTARES (placeholders) ----------------
    await exec('regimes', () async {
      if (existRegs.isEmpty) {
        final placeholders = <Map<String, String>>[
          {'codigo': '0001', 'descricao': 'PASTAGEM'},
          {'codigo': '0002', 'descricao': 'SEMI-INTENSIVO'},
          {'codigo': '0003', 'descricao': 'CONFINAMENTO'},
        ];
        final insertRegs = placeholders
            .map((p) => {
                  'id_propriedade': idPropriedade,
                  'codigo': p['codigo'],
                  'descricao': p['descricao'],
                })
            .toList();
        await _upsertIgnore(client, 'paint_regime_alimentar', insertRegs,
            'id_propriedade,codigo');
        result['regimes'] = insertRegs.length;
      }
    });

    // ---------------- 12. BIBLIOTECA DE TOUROS (reprodutores do rebanho) ----------------
    await exec('biblioteca', () async {
      final bibExist =
          existBib.map((e) => (e['a12'] ?? '').toString().trim()).toSet();
      final insertBib = <Map<String, dynamic>>[];
      final bibSet = <String>{};
      for (final r in rebanhoRows) {
        final categoria = (r['categoria'] ?? '').toString().toLowerCase();
        final ehTouro =
            categoria.contains('reprod') || categoria.contains('touro');
        if (!ehTouro) continue;
        final a = a12Of(r);
        if (a.isEmpty) continue;
        if (bibExist.contains(a)) continue;
        if (bibSet.contains(a)) continue;
        bibSet.add(a);
        final nome = (r['nome'] ?? r['numeroAnimal'] ?? '').toString().trim();
        final raca = (r['raca'] ?? '').toString().trim();
        final racaCurta = raca.isEmpty
            ? null
            : (raca.length > 2
                ? raca.substring(0, 2).toUpperCase()
                : raca.toUpperCase());
        insertBib.add({
          'a12': a,
          'nome': nome.isEmpty ? null : nome,
          'raca': racaCurta,
        });
      }
      if (insertBib.isNotEmpty) {
        await _upsertBatched(
            client, 'paint_biblioteca_touros', insertBib, 'a12');
        result['biblioteca'] = insertBib.length;
      }
    });

    return result;
  } catch (e) {
    result['erro'] = 1;
    result['mensagem'] = e.toString();
    return result;
  }
}

Set<String> _codigosUsados(Iterable<dynamic> codigos) {
  return codigos
      .map((c) => (c ?? '').toString().trim())
      .where((c) => c.isNotEmpty)
      .toSet();
}

String _proximoCodigoLivre(Set<String> usados) {
  for (var n = 1; n <= 9999; n++) {
    final codigo = n.toString().padLeft(4, '0');
    if (!usados.contains(codigo)) {
      usados.add(codigo);
      return codigo;
    }
  }
  throw Exception('Não há códigos PAINT livres entre 0001 e 9999.');
}

String _letraTrimestre(int mes) {
  if (mes >= 1 && mes <= 3) return 'V'; // Verão
  if (mes >= 4 && mes <= 6) return 'O'; // Outono
  if (mes >= 7 && mes <= 9) return 'I'; // Inverno
  return 'P'; // Primavera (out-dez)
}

List<String> _limitesTrimestre(int ano, int mes) {
  int inicioMes;
  int fimMes;
  if (mes <= 3) {
    inicioMes = 1;
    fimMes = 3;
  } else if (mes <= 6) {
    inicioMes = 4;
    fimMes = 6;
  } else if (mes <= 9) {
    inicioMes = 7;
    fimMes = 9;
  } else {
    inicioMes = 10;
    fimMes = 12;
  }
  final inicio = DateTime(ano, inicioMes, 1);
  final fim = DateTime(ano, fimMes + 1, 0); // último dia do mês fim
  String fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  return [fmt(inicio), fmt(fim)];
}

Future<List<Map<String, dynamic>>> _selectAllPaged(
  dynamic client,
  String table,
  String columns,
  Map<String, String> filtros, {
  String? orderColumn,
}) async {
  const pageSize = 1000;
  final all = <Map<String, dynamic>>[];
  int offset = 0;
  while (true) {
    var q = client.from(table).select(columns);
    filtros.forEach((k, v) {
      q = q.eq(k, v);
    });
    // Ordenação estável garante paginação consistente em tabelas grandes
    // (sem ORDER BY o PostgREST pode omitir/duplicar linhas entre páginas).
    if (orderColumn != null) {
      q = q.order(orderColumn);
    }
    final rows = await q.range(offset, offset + pageSize - 1);
    final list = (rows as List).cast<Map<String, dynamic>>();
    all.addAll(list);
    if (list.length < pageSize) break;
    offset += pageSize;
  }
  return all;
}

Future<void> _upsertBatched(
  dynamic client,
  String table,
  List<Map<String, dynamic>> rows,
  String onConflict,
) async {
  const batch = 500;
  for (var i = 0; i < rows.length; i += batch) {
    final slice =
        rows.sublist(i, i + batch > rows.length ? rows.length : i + batch);
    await client.from(table).upsert(slice, onConflict: onConflict);
  }
}

Future<int> _upsertCodedRowsSafely(
  dynamic client,
  String table,
  List<Map<String, dynamic>> rows,
  String onConflict,
  Set<String> codigosUsados,
) async {
  var gravados = 0;
  for (final original in rows) {
    final row = Map<String, dynamic>.from(original);
    var tentativas = 0;
    while (tentativas < 5) {
      try {
        await _upsertIgnore(client, table, [row], onConflict);
        gravados++;
        break;
      } catch (e) {
        if (!_isDuplicateKeyError(e)) rethrow;
        row['codigo'] = _proximoCodigoLivre(codigosUsados);
        tentativas++;
      }
    }
    if (tentativas >= 5) {
      throw Exception(
        'Não foi possível encontrar código livre para ${_nomeTabelaPaint(table)}.',
      );
    }
  }
  return gravados;
}

// Upsert que ignora duplicatas (não sobrescreve dados manuais existentes).
Future<void> _upsertIgnore(
  dynamic client,
  String table,
  List<Map<String, dynamic>> rows,
  String onConflict,
) async {
  const batch = 500;
  for (var i = 0; i < rows.length; i += batch) {
    final slice =
        rows.sublist(i, i + batch > rows.length ? rows.length : i + batch);
    await client.from(table).upsert(
          slice,
          onConflict: onConflict,
          ignoreDuplicates: true,
        );
  }
}

bool _isDuplicateKeyError(Object e) {
  final s = e.toString().toLowerCase();
  return s.contains('23505') || s.contains('duplicate key');
}

String _mensagemFalhaEtapa(String label, Object e) {
  final etapa = _labelEtapa(label);
  if (_isDuplicateKeyError(e)) {
    return '$etapa: já existia um registro com o mesmo código PAINT. '
        'A etapa foi preservada para evitar duplicidade; tente importar novamente.';
  }
  return '$etapa: não foi possível concluir esta etapa. ${_resumoErroTecnico(e)}';
}

String _labelEtapa(String label) {
  const labels = {
    'inseminadores': 'Inseminadores',
    'grupos_manejo': 'Grupos de manejo',
    'localidades': 'Localidades',
    'safra': 'Safra',
    'composicao_racial': 'Composição racial',
    'desmamas': 'Avaliações de desmama',
    'sobreanos': 'Avaliações de sobreano',
    'rahs': 'Avaliações de matrizes',
    'diagnosticos': 'Diagnósticos',
    'avaliadores': 'Avaliadores',
    'regimes': 'Regimes alimentares',
    'biblioteca': 'Biblioteca de touros',
  };
  return labels[label] ?? label;
}

String _nomeTabelaPaint(String table) {
  const nomes = {
    'paint_inseminador': 'inseminadores',
    'paint_grupo_manejo': 'grupos de manejo',
    'paint_avaliador': 'avaliadores',
  };
  return nomes[table] ?? table;
}

String _resumoErroTecnico(Object e) {
  final raw = e.toString();
  if (raw.contains('PostgrestException')) {
    final match = RegExp(r'message:\s*([^,}]+)').firstMatch(raw);
    if (match != null) return match.group(1)!.trim();
  }
  return raw;
}
