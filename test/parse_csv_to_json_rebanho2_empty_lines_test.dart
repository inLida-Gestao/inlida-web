import 'dart:convert';
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

  test('parseCsvToJsonRebanho2 mapeia Data de desmama em CSV', () async {
    final csv = [
      'Numero;Data de desmama;Peso de desmama\n',
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

  test('parseCsvToJsonRebanho2 preserva numeroAnimal com parenteses', () async {
    final csv = [
      'numeroAnimal;numeroMatriz;numeroReprodutor;sexo;categoria;raca\n',
      '(R 261);R #282;;Fêmea;Vaca Multipara;Nelore\n',
      '(R 282 (BRINCO 11);T 265 - 4;;Fêmea;Vaca Multipara;Nelore\n',
      '(R #290 (BRINCO 06);T 03 - 7;;Fêmea;Vaca Multipara;Nelore\n',
      '- #282;T 276 - 8;;Fêmea;Vaca Multipara;Nelore\n',
      '#COMPRADA MOACIR;;;Fêmea;Vaca Multipara;Nelore\n',
      '- (T 254 - 10);;;Fêmea;Vaca Multipara;Nelore\n',
      '- #01;;;Fêmea;Novilha;Nelore\n',
      '#01;;(GARROTE 13@);Macho;Bezerro;Nelore\n',
      'LAMPIÃO;;;Macho;Touro;Nelore\n',
    ].join();

    final file = FFUploadedFile(
      name: 'rebanho.csv',
      bytes: Uint8List.fromList(latin1.encode(csv)),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, hasLength(9));

    final row1 = out[0] as Map;
    final row2 = out[1] as Map;
    final row3 = out[2] as Map;
    final row4 = out[3] as Map;
    final row5 = out[4] as Map;
    final row6 = out[5] as Map;
    final row7 = out[6] as Map;
    final row8 = out[7] as Map;
    final row9 = out[8] as Map;

    expect(row1['numeroAnimal'], '(R 261)');
    expect(row1['numeroMatriz'], 'R #282');
    expect(row1['sexo'], 'Fêmea');
    expect(row2['numeroAnimal'], '(R 282 (BRINCO 11)');
    expect(row2['numeroMatriz'], 'T 265 - 4');
    expect(row2['sexo'], 'Fêmea');
    expect(row3['numeroAnimal'], '(R #290 (BRINCO 06)');
    expect(row3['numeroMatriz'], 'T 03 - 7');
    expect(row4['numeroAnimal'], '- #282');
    expect(row4['numeroMatriz'], 'T 276 - 8');
    expect(row5['numeroAnimal'], '#COMPRADA MOACIR');
    expect(row6['numeroAnimal'], '- (T 254 - 10)');
    expect(row7['numeroAnimal'], '- #01');
    expect(row7['sexo'], 'Fêmea');
    expect(row8['numeroAnimal'], '#01');
    expect(row8['numeroReprodutor'], '(GARROTE 13@)');
    expect(row8['sexo'], 'Macho');
    expect(row9['numeroAnimal'], 'LAMPIÃO');
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
        .value = const xl.DoubleCellValue(180.5);

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

  test('parseCsvToJsonRebanho2 rejeita arquivo binário renomeado como CSV',
      () async {
    final bytes = <int>[
      0xD0,
      0xCF,
      0x11,
      0xE0,
      0xA1,
      0xB1,
      0x1A,
      0xE1,
      ...List<int>.filled(64, 0),
    ];

    final file = FFUploadedFile(
      name: 'rebanho.csv',
      originalFilename: 'rebanho.csv',
      bytes: Uint8List.fromList(bytes),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, isEmpty);
  });

  test('parseCsvToJsonRebanho2 ignora linha com identificador corrompido',
      () async {
    final csv = [
      'Numero;Nome\n',
      'Ñ9½?Ñbqûæåe;\n',
      '123;Vaca Boa\n',
    ].join();

    final file = FFUploadedFile(
      name: 'rebanho.csv',
      bytes: Uint8List.fromList(latin1.encode(csv)),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, hasLength(1));

    final row = out.first as Map;
    expect(row['numeroAnimal'], '123');
    expect(row['nome'], 'Vaca Boa');
  });

  test('parseCsvToJsonRebanho2 preserva acentos em CSV Latin-1', () async {
    final csv = [
      'Numero;Sexo;Raca\n',
      '123;Fêmea;Mestiço\n',
    ].join();

    final file = FFUploadedFile(
      name: 'rebanho.csv',
      bytes: Uint8List.fromList(latin1.encode(csv)),
    );

    final out = await parseCsvToJsonRebanho2(file);
    expect(out, hasLength(1));

    final row = out.first as Map;
    expect(row['numeroAnimal'], '123');
    expect(row['sexo'], 'Fêmea');
    expect(row['raca'], 'Mestiço');
  });
}
