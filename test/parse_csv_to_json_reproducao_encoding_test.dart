import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:in_lida_web/flutter_flow/uploaded_file.dart';
import 'package:in_lida_web/custom_code/actions/parse_csv_to_json_reproducao.dart';

void main() {
  test('parseCsvToJsonReproducao preserva acentos (bytes legado)', () async {
    // CSV mínimo com header do banco + 1 coluna de texto.
    // Inclui bytes específicos já encontrados em exports antigos:
    // - 0x90 => ê ("Fêmea")
    // - 0x8D => ç ("Mestiço")
    final bytes = <int>[
      // anotacoes\n
      0x61,
      0x6E,
      0x6F,
      0x74,
      0x61,
      0x63,
      0x6F,
      0x65,
      0x73,
      0x0A,
      // linha vazia (deve ser ignorada)\n
      0x0A,
      // F\x90mea\n
      0x46,
      0x90,
      0x6D,
      0x65,
      0x61,
      0x0A,
      // linha vazia (deve ser ignorada)\n
      0x0A,
      // Mesti\x8Do\n
      0x4D,
      0x65,
      0x73,
      0x74,
      0x69,
      0x8D,
      0x6F,
      0x0A,
    ];

    final file = FFUploadedFile(
      name: 'reproducao.csv',
      bytes: Uint8List.fromList(bytes),
    );

    final out = await parseCsvToJsonReproducao(file);
    expect(out, hasLength(2));

    final row1 = out[0] as Map;
    final row2 = out[1] as Map;

    expect(row1['anotacoes'], 'Fêmea');
    expect(row2['anotacoes'], 'Mestiço');
  });

  test('batch insert não corrompe palavras com Â legítimo', () async {
    // Este teste é indireto: garante que o parser preserve "Ângulo" (UTF-8 normal)
    // e que não gere replacement char.
    final csv = 'anotacoes\nÂngulo\n';

    final file = FFUploadedFile(
      name: 'reproducao_utf8.csv',
      bytes: Uint8List.fromList(csv.codeUnits),
    );

    final out = await parseCsvToJsonReproducao(file);
    expect(out, hasLength(1));

    final row = out[0] as Map;
    final anotacoes = row['anotacoes']?.toString() ?? '';

    expect(anotacoes, 'Ângulo');
    expect(anotacoes.contains('�'), isFalse);
  });
}
