import 'dart:typed_data';

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
}
