// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import 'package:download/download.dart';
import 'package:excel/excel.dart';

/// Relatório auxiliar estilo 460: resumo de contagens PAINT + animais elegíveis.
Future<bool> exportPaintResultadosExcel(String idPropriedade) async {
  if (idPropriedade.isEmpty) return false;
  final cfg = await loadPaintConfig(idPropriedade);
  if (cfg == null) return false;

  final tabelas = [
    'paint_avaliacao_desmama',
    'paint_avaliacao_sobreano',
    'paint_avaliacao_rah',
    'paint_estoque',
    'paint_baixa',
    'paint_composicao_racial',
  ];

  final excel = Excel.createExcel();
  final resumo = excel.tables[excel.tables.keys.first]!;
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      .value = TextCellValue('Tabela');
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
      .value = TextCellValue('Registros');

  var row = 1;
  for (final t in tabelas) {
    var q = SupaFlow.client.from(t).select('*');
    if (t != 'paint_biblioteca_touros') {
      q = q.eq('id_propriedade', idPropriedade);
    }
    final resp = await q.count(CountOption.exact);
    resumo
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(t);
    resumo
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = IntCellValue(resp.count);
    row++;
  }

  final rebanho = await fetchRebanhoPaint(idPropriedade);
  final ventres =
      rebanho.where((r) => filtroMatrizes(r, status: 'Na propriedade')).length;
  final desm =
      rebanho.where((r) => filtroDesmama(r, status: 'Na propriedade')).length;
  final sob =
      rebanho.where((r) => filtroSobreano(r, status: 'Na propriedade')).length;

  row += 1;
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      .value = TextCellValue('Rebanho elegível matrizes');
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      .value = IntCellValue(ventres);
  row++;
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      .value = TextCellValue('Rebanho elegível desmama');
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      .value = IntCellValue(desm);
  row++;
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
      .value = TextCellValue('Rebanho elegível sobreano');
  resumo
      .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
      .value = IntCellValue(sob);

  final bytes = excel.encode();
  if (bytes == null) return false;
  await download(
    Stream.fromIterable(bytes),
    'PAINT_460_RESULTADOS_${cfg.codigoTransmissao}.xlsx',
  );
  return true;
}
