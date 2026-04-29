import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;
import 'package:flutter_test/flutter_test.dart';

import 'package:in_lida_web/custom_code/actions/parse_csv_to_json_rebanho2.dart';
import 'package:in_lida_web/flutter_flow/uploaded_file.dart';

void main() {
  test('parseCsvToJsonRebanho2 ignora linhas em branco', () async {
    final csv = [
      'numero,nome\n',
      '\n',
      '123,Boi A\n',
      '\n',
      ',\n',
      '456,Vaca B\n',
      '\n',
    ].join();

    final file = FFUploadedFile(
      name: 'rebanho.csv',
      bytes: Uint8List.fromList(csv.codeUnits),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, hasLength(2));

    final row1 = out[0] as Map;
    final row2 = out[1] as Map;

    expect(row1['numeroAnimal'], '123');
    expect(row1['nome'], 'Boi A');
    expect(row2['numeroAnimal'], '456');
    expect(row2['nome'], 'Vaca B');
  });

  test('parseCsvToJsonRebanho2 mapeia Data_desmama em CSV', () async {
    final csv = [
      'Numero;Data_desmama;Peso_desmama\n',
      '123;15/01/2024;180,5\n',
    ].join();

    final file = FFUploadedFile(
      name: 'rebanho.csv',
      bytes: Uint8List.fromList(csv.codeUnits),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, hasLength(1));

    final row = out.first as Map;
    expect(row['numeroAnimal'], '123');
    expect(row['dataDesmama'], '15/01/2024');
    expect(row['pesoDesmama'], 180.5);
  });

  test('parseCsvToJsonRebanho2 lê Data_desmama de XLSX', () async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = xl.TextCellValue('Numero');
    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = xl.TextCellValue('Data_desmama');
    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
        .value = xl.TextCellValue('Peso_desmama');
    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = xl.TextCellValue('123');
    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = xl.DateCellValue.fromDateTime(DateTime(2024, 1, 15));
    sheet
        .cell(xl.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
        .value = xl.DoubleCellValue(180.5);

    final bytes = excel.encode();
    expect(bytes, isNotNull);

    final file = FFUploadedFile(
      name: 'rebanho.xlsx',
      originalFilename: 'rebanho.xlsx',
      bytes: Uint8List.fromList(bytes!),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, hasLength(1));

    final row = out.first as Map;
    expect(row['numeroAnimal'], '123');
    expect(row['dataDesmama'], '15/01/2024');
    expect(row['pesoDesmama'], 180.5);
  });
}
