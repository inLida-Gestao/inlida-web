import 'package:excel/excel.dart' as xl;
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/custom_code/actions/export_pesagem_excel.dart';

void main() {
  group('formatDataPesagemForExport', () {
    test('preserva o dia civil de strings ISO sem converter o fuso', () {
      expect(formatDataPesagemForExport('2024-01-15'), '15/01/2024');
      expect(
        formatDataPesagemForExport('2024-01-15T12:30:00Z'),
        '15/01/2024',
      );
      expect(
        formatDataPesagemForExport('2024-01-15T23:30:00-03:00'),
        '15/01/2024',
      );
      expect(
        formatDataPesagemForExport('2024-01-15 23:30:00+00'),
        '15/01/2024',
      );
    });

    test('formata DateTime pelos seus componentes civis', () {
      expect(
        formatDataPesagemForExport(DateTime.utc(2023, 12, 31, 23, 59)),
        '31/12/2023',
      );
    });

    test('mantem vazio ou valor desconhecido sem inventar uma data', () {
      expect(formatDataPesagemForExport(null), '');
      expect(formatDataPesagemForExport('   '), '');
      expect(
        formatDataPesagemForExport('data desconhecida'),
        'data desconhecida',
      );
      expect(
        formatDataPesagemForExport('2024-02-30T10:00:00Z'),
        '2024-02-30T10:00:00Z',
      );
    });
  });

  test('mantem Data_pesagem como texto depois de codificar o XLSX', () {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];
    final cellIndex =
        xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0);

    sheet.cell(cellIndex).value =
        dataPesagemCellValueForExport('2024-01-15T23:30:00-03:00');

    final bytes = excel.encode();
    expect(bytes, isNotNull);

    final decoded = xl.Excel.decodeBytes(bytes!);
    final decodedValue = decoded['Sheet1'].cell(cellIndex).value;

    expect(decodedValue, isA<xl.TextCellValue>());
    expect(decodedValue.toString(), '15/01/2024');
  });
}
