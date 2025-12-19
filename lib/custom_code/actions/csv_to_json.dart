// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// gere uma action que faz o upload de um arquivo csv e converte para uma lista do tipo json
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

Future<List<dynamic>> csvToJson(FFUploadedFile? csvFile) async {
  if (csvFile == null || csvFile.bytes == null || csvFile.bytes!.isEmpty) {
    return [];
  }

  try {
    // Convert bytes to string
    String csvContent = _decodeWithBestEncoding(csvFile.bytes!);

    // Split into lines and remove empty lines
    List<String> lines =
        csvContent.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      return [];
    }

    // Get headers from first line
    List<String> headers = lines[0]
        .split(',')
        .map((header) => header.trim().replaceAll('"', ''))
        .toList();

    List<dynamic> jsonList = [];

    // Process each data row
    for (int i = 1; i < lines.length; i++) {
      List<String> values = lines[i]
          .split(',')
          .map((value) => value.trim().replaceAll('"', ''))
          .toList();

      // Ensure we don't have more values than headers
      if (values.length > headers.length) {
        values = values.sublist(0, headers.length);
      }

      // Create JSON object for this row
      Map<String, dynamic> rowJson = {};
      for (int j = 0; j < headers.length; j++) {
        String value = j < values.length ? values[j] : '';

        // Try to parse as number if possible
        if (value.isNotEmpty) {
          if (RegExp(r'^\d+$').hasMatch(value)) {
            rowJson[headers[j]] = int.tryParse(value) ?? value;
          } else if (RegExp(r'^\d+\.\d+$').hasMatch(value)) {
            rowJson[headers[j]] = double.tryParse(value) ?? value;
          } else {
            rowJson[headers[j]] = value;
          }
        } else {
          rowJson[headers[j]] = '';
        }
      }

      jsonList.add(rowJson);
    }

    return jsonList;
  } catch (e) {
    print('Error parsing CSV: $e');
    return [];
  }
}
