// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import 'package:excel/excel.dart';

/// Importa planilha PAINT de avaliação (matrizes/desmama/sobreano).
/// Retorna { inseridos, atualizados, erros: [{linha, motivo}] }.
Future<Map<String, dynamic>> importPaintAvaliacaoExcel(
  String? idPropriedade,
  String? tipo,
  FFUploadedFile? arquivo,
) async {
  final result = <String, dynamic>{
    'inseridos': 0,
    'atualizados': 0,
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

  final existRows = await SupaFlow.client
      .from(table)
      .select('id,animal_a12,data')
      .eq('id_propriedade', idPropriedade);
  final existKeys = <String, String>{};
  for (final e in existRows) {
    existKeys['${_a12Key(e['animal_a12']?.toString())}|${e['data']}'] =
        e['id'].toString();
  }

  final erros = <Map<String, dynamic>>[];
  var inseridos = 0;
  var atualizados = 0;
  final upserts = <Map<String, dynamic>>[];
  final importKeys = <String>{};

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
      final peso = _celNum(row, idx('peso_kg'));
      if (peso != null) payload['peso'] = peso;
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
      final peso = _celNum(row, idx('peso_kg'));
      if (peso != null) payload['peso'] = peso;
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
    if (existKeys.containsKey(key)) {
      payload['id'] = existKeys[key];
      atualizados++;
    } else {
      inseridos++;
    }
    upserts.add(payload);
  }

  if (upserts.isNotEmpty) {
    const tam = 200;
    for (var i = 0; i < upserts.length; i += tam) {
      final fim = (i + tam < upserts.length) ? i + tam : upserts.length;
      await SupaFlow.client.from(table).upsert(
            upserts.sublist(i, fim),
            onConflict: 'id_propriedade,animal_a12,data',
          );
    }
  }

  result['inseridos'] = inseridos;
  result['atualizados'] = atualizados;
  result['erros'] = erros;
  return result;
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

dynamic _celNum(List<dynamic> row, int index) {
  return _celValue(row, index);
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
