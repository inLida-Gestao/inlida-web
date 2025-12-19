// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:math';


String _decodeWithBestEncoding(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } catch (_) {}
  try {
    return latin1.decode(bytes);
  } catch (_) {}
  return utf8.decode(bytes, allowMalformed: true);
}

Future<bool> importCSVToSupabase(
  FFUploadedFile csvFile,
  String idPropriedade,
) async {
  try {
    // Initialize Supabase client
    final supabase = SupaFlow.client;

    // Validate required parameters
    if (idPropriedade.isEmpty) {
      return false;
    }

    // Validate file
    if (csvFile.bytes == null || csvFile.bytes!.isEmpty) {
      return false;
    }

    // Decode CSV content
    String csvContent;
    try {
      csvContent = _decodeWithBestEncoding(csvFile.bytes!);
    } catch (e) {
      return false;
    }

    // Parse CSV
    List<List<dynamic>> csvData;
    try {
      const converter = CsvToListConverter(
        shouldParseNumbers: false,
        allowInvalid: true,
      );
      csvData = converter.convert(csvContent);
    } catch (e) {
      return false;
    }

    // Validate CSV structure
    if (csvData.isEmpty) {
      return false;
    }

    // Get headers from first row
    final headers =
        csvData[0].map((header) => header.toString().trim()).toList();

    // Process data rows
    List<Map<String, dynamic>> processedData = [];

    for (int i = 1; i < csvData.length; i++) {
      try {
        final row = csvData[i];

        // Skip empty rows
        if (row.isEmpty ||
            row.every((cell) => cell.toString().trim().isEmpty)) {
          continue;
        }

        // Create record map
        Map<String, dynamic> record = {};

        // Add fixed parameters
        record['idPropriedade'] = idPropriedade;

        // Generate unique idRebanho (20 characters, lowercase letters and numbers)
        record['idRebanho'] = generateRandomId();

        // Process each column
        for (int j = 0; j < headers.length && j < row.length; j++) {
          final headerName = headers[j];
          final cellValue = row[j]?.toString().trim() ?? '';

          // Skip system fields that should not be imported
          if (['id', 'created_at', 'idPropriedade', 'idRebanho']
              .contains(headerName)) {
            continue;
          }

          // Add value to record
          if (cellValue.isNotEmpty) {
            record[headerName] = cellValue;
          } else {
            record[headerName] = null;
          }
        }

        processedData.add(record);
      } catch (e) {
        continue;
      }
    }

    // Check if we have any data to insert
    if (processedData.isEmpty) {
      return false;
    }

    // Bulk insert to Supabase
    try {
      const batchSize = 100;

      for (int i = 0; i < processedData.length; i += batchSize) {
        final batch = processedData.sublist(
            i,
            (i + batchSize < processedData.length)
                ? i + batchSize
                : processedData.length);

        await supabase.from('rebanho').insert(batch).select();
      }

      return true;
    } catch (e) {
      return false;
    }
  } catch (e) {
    return false;
  }
}

String generateRandomId() {
  final random = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  const length = 20;

  return List.generate(length, (index) {
    return chars[random.nextInt(chars.length)];
  }).join();
}
