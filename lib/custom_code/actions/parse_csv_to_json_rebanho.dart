// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:csv/csv.dart';
import 'dart:convert';

Future<List<dynamic>> parseCsvToJsonRebanho(FFUploadedFile? csvFile) async {
  if (csvFile == null || csvFile.bytes == null) return [];

  try {
    // 1. Remove BOM (Byte Order Mark) if present
    List<int> bytes = csvFile.bytes!;
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      bytes = bytes.sublist(3);
    }

    // 2. Decode with error handling and normalize newlines
    final csvData = utf8
        .decode(bytes, allowMalformed: true)
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    // 3. Configure CSV converter
    const converter = CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
      allowInvalid: true,
    );

    // 4. Convert CSV to rows
    final List<List<dynamic>> rows = converter.convert(csvData);

    // 5. Columns matching the supabase rebanho table
    // Note: id, created_at, updated_at are auto-generated and should not be included in CSV
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
      'dataVenda',
      'valorVenda',
      'dataMovimentacao',
      'numeroMatriz',
      'nomeMatriz',
      'dataNascMatriz',
      'racaMatriz',
      'numeroReprodutor',
      'nomeReprodutor',
      'dataNascReprodutor',
      'racaReprodutor',
    ];

    // 6. Date columns for special handling
    const dateColumns = [
      'created_at',
      'dataNascimento',
      'dataEntradaLote',
      'dataDesmama',
      'updated_at',
      'dataAcao',
      'dataUltimaPesagem',
      'dataVenda',
      'dataMovimentacao',
      'dataNascMatriz',
      'dataNascReprodutor',
    ];

    // 7. Numeric columns for special handling (only columns that are numeric in the database)
    const numericColumns = [
      'pesoNascimento',
      'pesoDesmama',
      'pesoAtual',
      'valorCompra',
      'valorVenda',
    ];

    // 8. Process rows (ignoring header)
    return rows.skip(1).map((row) {
      final map = <String, dynamic>{};

      for (var i = 0; i < columns.length; i++) {
        var raw = (i < row.length) ? row[i].toString() : '';

        // Basic cleanup
        String value = raw
            .trim()
            .replaceAll(RegExp(r'\r'), '')
            .replaceAll(RegExp(r'\n'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ');

        final column = columns[i];

        // Handle empty values
        if (value.isEmpty || value == 'null' || value == 'NULL') {
          map[column] = null;
          continue;
        }

        // Parse dates to ISO format
        if (dateColumns.contains(column)) {
          final parsedDate = DateTime.tryParse(value);
          map[column] = parsedDate
              ?.toIso8601String()
              .split('T')[0]; // Keep only date part (YYYY-MM-DD)
        }
        // Parse numeric values (only for columns that are actually numeric in DB)
        else if (numericColumns.contains(column)) {
          // Replace comma with dot for decimal numbers
          final numericValue = value.replaceAll(',', '.');
          final parsedNumber = double.tryParse(numericValue);
          map[column] = parsedNumber;
        }
        // Handle text fields (including numeroAnimal, chip, codRegistro, rebanhoIdMatriz, rebanhoIdReprodutor, idRebanho)
        else {
          map[column] = value;
        }
      }

      return map;
    }).toList();
  } catch (e, stack) {
    print('Erro no processamento CSV: $e');
    print('Stack trace: $stack');
    return [];
  }
}
