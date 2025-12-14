// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:csv/csv.dart';

import 'dart:convert';

Future importBooks(FFUploadedFile fileParam) async {
  // Add your function code here!
  final bytes = fileParam.bytes!;
  final csvString = utf8.decode(bytes);
  final rows = const CsvToListConverter().convert(csvString, eol: '\n');
  FFAppState().update(() {
    FFAppState().totalrow = rows.length - 1;
  });
  final List<Map<String, dynamic>> rowsToInsert = [];

  for (int i = 1; i < rows.length; i++) {
    final numeroAnimal = rows[i][0]?.toString().trim();
    final chip = rows[i][1]?.toString().trim();

    if (numeroAnimal != null && chip != null) {
      rowsToInsert.add({
        'numeroAnimal': numeroAnimal,
        'chip': chip,
        'created_at': DateTime.now().toIso8601String(),
      });
      FFAppState().update(() {
        FFAppState().currentrow = i;
      });
    }
  }

  const int batchSize =
      200; // Ubah sesuai kapasitas Supabase dan kestabilan koneksi

  for (var i = 0; i < rowsToInsert.length; i += batchSize) {
    final batch = rowsToInsert.sublist(
      i,
      i + batchSize > rowsToInsert.length ? rowsToInsert.length : i + batchSize,
    );

    await Supabase.instance.client.from('rebanho').insert(batch);
  }
}
