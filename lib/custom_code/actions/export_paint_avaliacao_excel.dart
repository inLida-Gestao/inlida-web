// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import 'package:download/download.dart';
import 'package:excel/excel.dart';

/// Exporta template Excel PAINT de avaliações ou lista de touros.
/// [tipo]: matrizes | desmama | sobreano | lista_touros
/// [modo]: vazio | preenchido (ignorado para lista_touros)
Future<bool> exportPaintAvaliacaoExcel(
  String idPropriedade,
  String tipo,
  String modo,
) async {
  if (idPropriedade.isEmpty) return false;
  final t = tipo.toLowerCase().trim();
  final m = modo.toLowerCase().trim();
  final preenchido = m == 'preenchido';

  if (t == 'lista_touros') {
    return _exportListaTouros(idPropriedade, preenchido);
  }

  final cfg = await loadPaintConfig(idPropriedade);
  if (cfg == null) return false;

  List<String> headers;
  String nomeArquivo;
  bool Function(Map<String, dynamic>) filtro;

  switch (t) {
    case 'matrizes':
      headers = matrizesHeaders;
      nomeArquivo =
          preenchido ? 'PAINT_Av_Matrizes_preenchido' : 'PAINT_Av_Matrizes';
      filtro = filtroMatrizes;
      break;
    case 'desmama':
      headers = desmamaHeaders;
      nomeArquivo =
          preenchido ? 'PAINT_Av_Desmama_preenchido' : 'PAINT_Av_Desmama';
      filtro = filtroDesmama;
      break;
    case 'sobreano':
      headers = sobreanoHeaders;
      nomeArquivo =
          preenchido ? 'PAINT_Av_Sobreano_preenchido' : 'PAINT_Av_Sobreano';
      filtro = filtroSobreano;
      break;
    default:
      return false;
  }

  final rebanho = await fetchRebanhoPaint(idPropriedade);
  final animais = rebanho.where(filtro).toList();
  if (animais.isEmpty) return false;

  Map<String, Map<String, dynamic>> existentes = {};
  if (preenchido) {
    final table = t == 'matrizes'
        ? 'paint_avaliacao_rah'
        : t == 'desmama'
            ? 'paint_avaliacao_desmama'
            : 'paint_avaliacao_sobreano';
    final rows = await SupaFlow.client
        .from(table)
        .select()
        .eq('id_propriedade', idPropriedade);
    for (final e in rows) {
      final k = '${(e['animal_a12'] ?? '').toString().trim()}|${e['data']}';
      existentes[k] = Map<String, dynamic>.from(e);
    }
  }

  final excel = Excel.createExcel();
  final sheet = excel.tables[excel.tables.keys.first]!;
  for (var c = 0; c < headers.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
        TextCellValue(headers[c]);
  }

  var rowIdx = 1;
  for (final r in animais) {
    final a12 = a12FromRebanho(r, cfg);
    if (a12.isEmpty) continue;
    final numAnimal = (r['numeroAnimal'] ?? '').toString();
    final nasc = parseDateIso(r['dataNascimento']) ?? '';
    final sexo = sexoMF(r['sexo']);
    Map<String, dynamic>? exist;
    if (preenchido) {
      for (final e in existentes.entries) {
        if (e.key.startsWith('${a12.trim()}|')) {
          exist = e.value;
          break;
        }
      }
    }

    List<dynamic> vals;
    if (t == 'matrizes') {
      vals = [
        numAnimal,
        nasc,
        sexo,
        a12.trim(),
        exist?['data'] ?? '',
        exist?['racial'] ?? '',
        exist?['frame'] ?? '',
        exist?['aprumos'] ?? '',
        exist?['pigmentacao'] ?? '',
      ];
    } else if (t == 'desmama') {
      vals = [
        numAnimal,
        nasc,
        sexo,
        a12.trim(),
        exist?['data'] ?? parseDateIso(r['dataDesmama']) ?? '',
        exist?['nota_c'] ?? '',
        exist?['nota_p'] ?? '',
        exist?['nota_m'] ?? '',
        exist?['nota_u'] ?? '',
        exist?['obs'] ?? '',
        exist?['peso'] ?? r['pesoDesmama'] ?? '',
      ];
    } else {
      vals = [
        numAnimal,
        nasc,
        sexo,
        a12.trim(),
        exist?['data'] ?? parseDateIso(r['dataUltimaPesagem']) ?? '',
        exist?['nota_c'] ?? '',
        exist?['nota_p'] ?? '',
        exist?['nota_m'] ?? '',
        exist?['nota_u'] ?? '',
        exist?['nota_t'] ?? '',
        exist?['nota_ce'] ?? '',
        exist?['obs'] ?? '',
        exist?['peso'] ?? r['pesoAtual'] ?? '',
      ];
    }

    for (var c = 0; c < vals.length; c++) {
      final v = vals[c];
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx),
      );
      if (v is num) {
        cell.value = DoubleCellValue(v.toDouble());
      } else if (headers[c].contains('Data') && v.toString().isNotEmpty) {
        final d = DateTime.tryParse(v.toString());
        if (d != null) {
          cell.value = DateCellValue.fromDateTime(d);
        } else {
          cell.value = TextCellValue(v.toString());
        }
      } else {
        cell.value = TextCellValue(v?.toString() ?? '');
      }
    }
    rowIdx++;
  }

  final bytes = excel.encode();
  if (bytes == null || bytes.isEmpty) return false;
  await download(Stream.fromIterable(bytes), '$nomeArquivo.xlsx');
  return true;
}

Future<bool> _exportListaTouros(String idPropriedade, bool preenchido) async {
  final excel = Excel.createExcel();
  final sheet = excel.tables[excel.tables.keys.first]!;
  for (var c = 0; c < listaTourosHeaders.length; c++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0)).value =
        TextCellValue(listaTourosHeaders[c]);
  }

  if (preenchido) {
    var row = 1;
    final rows = await SupaFlow.client
        .from('paint_biblioteca_touros')
        .select()
        .order('nome', ascending: true)
        .limit(5000);
    for (final t in rows) {
      final vals = [
        t['a12'],
        t['nome'],
        t['rgd'] ?? t['rgn'],
        t['raca'],
        t['tipo_registro'],
        t['pai_a12'],
        t['mae_a12'],
        t['rgd'],
        t['rgn'],
      ];
      for (var c = 0; c < vals.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
            .value = TextCellValue(vals[c]?.toString() ?? '');
      }
      row++;
    }
  }

  final bytes = excel.encode();
  if (bytes == null) return false;
  final nome =
      preenchido ? 'LISTA_TOUROS_PAINT_preenchido' : 'LISTA_TOUROS_PAINT';
  await download(Stream.fromIterable(bytes), '$nome.xlsx');
  return true;
}
