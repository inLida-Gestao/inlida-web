// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:csv/csv.dart';
import 'dart:convert';


String _decodeWithBestEncoding(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } catch (_) {}
  try {
    return latin1.decode(bytes);
  } catch (_) {}
  return utf8.decode(bytes, allowMalformed: true);
}

Future<List<dynamic>> parseCsvToJsonMachines(FFUploadedFile? csvFile) async {
  if (csvFile == null || csvFile.bytes == null) return [];

  try {
    // 1. Remove BOM (Byte Order Mark) se presente
    List<int> bytes = csvFile.bytes!;
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      bytes = bytes.sublist(3);
    }

    // 2. Decodificação com tratamento de erros
    final csvData = _decodeWithBestEncoding(bytes)
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    // 3. Configurar conversor CSV
    const converter = CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
      allowInvalid: true,
    );

    // 4. Converter dados
    final List<List<dynamic>> rows = converter.convert(csvData);

    // 5. Colunas conforme o CSV
    const columns = [
      'id',
      'created_at',
      'idPropriedade',
      'numeroAnimal',
      'chip',
      'codRegistro',
      'nome',
      'sexo',
      'categoria',
      'dataNascimento',
      'pesoNascimento',
      'porte',
      'raca',
      'loteID',
      'dataEntradaLote',
      'rebanhoIdMatriz',
      'rebanhoIdReprodutor',
      'dataDesmama',
      'pesoDesmama',
      'pesoAtual',
      'status',
      'origem',
      'anotacoes',
      'idRebanho',
      'deletado',
      'updated_at',
      'loteNome',
      'tipo',
      'dataAcao',
      'valorCompra',
      'dataUltimaPesagem',
      'nomeConcat',
    ];

    // 6. Processar linhas (ignorando cabeçalho)
    return rows.skip(1).map((row) {
      final map = <String, dynamic>{};
      for (var i = 0; i < columns.length; i++) {
        var raw = (i < row.length) ? row[i].toString() : '';

        // Limpeza básica
        String value = raw
            .trim()
            .replaceAll(RegExp(r'\r'), '')
            .replaceAll(RegExp(r'\n'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ');

        final column = columns[i];
        map[column] = value;

        // Conversão específica
        //if (column == 'machine_connected' ||
        //column == 'data_restricted_by_client') {
        //final lower = value.toLowerCase();
        //map[column] = (lower == 'true')
        //? true
        //: (lower == 'false')
        //      ? false
        //        : null;
        //} else if (column == 'installation_date') {
        //map[column] = DateTime.tryParse(value)?.toIso8601String();
        // } else {
        //map[column] = value;
        //}
      }
      return map;
    }).toList();
  } catch (e, stack) {
    print('Erro no processamento CSV: $e');
    print('Stack trace: $stack');
    return [];
  }
}
