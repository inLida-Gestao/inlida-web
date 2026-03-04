// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xl;

Future<List<dynamic>> parseCsvToJsonPesagem(FFUploadedFile? csvFile) async {
  if (csvFile == null || csvFile.bytes == null || csvFile.bytes!.isEmpty) {
    return [];
  }

  try {
    List<int> bytes = csvFile.bytes!;
    final fileName = csvFile.originalFilename.toLowerCase();

    List<List<dynamic>> rows;

    if (_isXlsxFile(bytes, fileName)) {
      rows = _parseXlsx(bytes);
    } else {
      rows = _parseCsv(bytes);
    }

    if (rows.isEmpty) return [];

    return _processRows(rows);
  } catch (e, stack) {
    print('Erro no processamento pesagem: $e');
    print(stack);
    return [];
  }
}

bool _isXlsxFile(List<int> bytes, String fileName) {
  if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) return true;
  // ZIP magic number (XLSX is a ZIP file)
  if (bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04) {
    return true;
  }
  return false;
}

List<List<dynamic>> _parseXlsx(List<int> bytes) {
  final excel = xl.Excel.decodeBytes(bytes);
  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName];
  if (sheet == null || sheet.rows.isEmpty) return [];

  final rows = <List<dynamic>>[];
  for (final row in sheet.rows) {
    final cells = <dynamic>[];
    for (final cell in row) {
      if (cell == null || cell.value == null) {
        cells.add('');
      } else {
        final val = cell.value;
        if (val is xl.DateCellValue) {
          final dt = val.asDateTimeLocal();
          cells.add(
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}');
        } else if (val is xl.DoubleCellValue) {
          cells.add(val.value.toString());
        } else if (val is xl.IntCellValue) {
          cells.add(val.value.toString());
        } else {
          cells.add(val.toString());
        }
      }
    }
    rows.add(cells);
  }
  return rows;
}

List<List<dynamic>> _parseCsv(List<int> bytes) {
  List<int> cleanBytes = bytes;

  if (cleanBytes.length >= 3 &&
      cleanBytes[0] == 0xEF &&
      cleanBytes[1] == 0xBB &&
      cleanBytes[2] == 0xBF) {
    cleanBytes = cleanBytes.sublist(3);
  }

  String csvString = _decodeWithBestEncoding(cleanBytes);
  csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  String firstLine = csvString.split('\n').first;
  String delimiter = _detectDelimiter(firstLine);

  final converter = CsvToListConverter(
    fieldDelimiter: delimiter,
    eol: '\n',
    shouldParseNumbers: false,
    allowInvalid: true,
  );

  return converter.convert(csvString);
}

List<dynamic> _processRows(List<List<dynamic>> rows) {
  const dbColumnsInOrder = [
    'numeroAnimal',
    'chip',
    'nome',
    'sexo',
    'dataNascimento',
    'raca',
    'dataPesagem',
    'peso',
    'tipo',
  ];

  const dateColumns = ['dataNascimento', 'dataPesagem'];
  const numericColumns = ['peso'];

  final headerRow = rows.first;
  final headerStrings = headerRow
      .map((e) => e == null ? '' : e.toString())
      .map(_cleanText)
      .toList();
  final normalizedHeaders = headerStrings.map(_normalizeHeader).toList();

  final bool looksLikeHeader = normalizedHeaders.any((h) =>
      h == 'numero' ||
      h == 'numero_animal' ||
      h == 'nome' ||
      h == 'chip' ||
      h == 'data_nascimento' ||
      h == 'raca' ||
      h == 'sexo' ||
      h == 'data_pesagem' ||
      h == 'tipo' ||
      h == 'peso');

  final bool looksLikeDbExport = headerStrings.any((h) =>
      const {'numeroAnimal', 'chip', 'dataPesagem', 'dataNascimento', 'peso'}
          .contains(h));

  final bool useHeaderMapping = (looksLikeHeader || looksLikeDbExport) &&
      normalizedHeaders.any((h) => h.isNotEmpty);

  if (useHeaderMapping) {
    final mapping = _buildPesagemHeaderMapping(headerStrings);

    final out = <dynamic>[];
    for (final row in rows.skip(1)) {
      if (_isCsvRowEmpty(row)) continue;

      final map = <String, dynamic>{};

      mapping.forEach((dbColumn, index) {
        final raw = (index < row.length && row[index] != null)
            ? row[index].toString()
            : '';
        final value = _cleanText(raw);
        final cleaned = _cleanCellToNull(value, dbColumn, numericColumns);
        if (cleaned == null) {
          map[dbColumn] = null;
          return;
        }

        if (dateColumns.contains(dbColumn)) {
          map[dbColumn] = cleaned;
        } else if (numericColumns.contains(dbColumn)) {
          map[dbColumn] = _parseNumberPtBr(cleaned);
        } else {
          map[dbColumn] = cleaned;
        }
      });

        if (_isAllValuesMissing(map.values)) continue;
        if (!_hasMinimumPesagemData(map)) continue;
        out.add(map);
      }

      return out;
    }

    final out = <dynamic>[];
    for (final row in rows.skip(1)) {
      if (_isCsvRowEmpty(row)) continue;

      final map = <String, dynamic>{};

      for (var i = 0; i < dbColumnsInOrder.length && i < row.length; i++) {
        final dbColumn = dbColumnsInOrder[i];
        final raw = row[i]?.toString() ?? '';
        final value = _cleanText(raw);
        final cleaned = _cleanCellToNull(value, dbColumn, numericColumns);

        if (cleaned == null) {
          map[dbColumn] = null;
          continue;
        }

        if (dateColumns.contains(dbColumn)) {
          map[dbColumn] = cleaned;
        } else if (numericColumns.contains(dbColumn)) {
          map[dbColumn] = _parseNumberPtBr(cleaned);
        } else {
          map[dbColumn] = cleaned;
        }
      }

      if (_isAllValuesMissing(map.values)) continue;
      if (!_hasMinimumPesagemData(map)) continue;
      out.add(map);
    }

  return out;
}

Map<String, int> _buildPesagemHeaderMapping(List<String> headerStrings) {
  const templateMap = <String, String>{
    'numero': 'numeroAnimal',
    'numero_animal': 'numeroAnimal',
    'num': 'numeroAnimal',
    'chip': 'chip',
    'brinco': 'chip',
    'nome': 'nome',
    'nome_animal': 'nome',
    'data_nascimento': 'dataNascimento',
    'data_nasc': 'dataNascimento',
    'nascimento': 'dataNascimento',
    'raca': 'raca',
    'sexo': 'sexo',
    'data_pesagem': 'dataPesagem',
    'data_da_pesagem': 'dataPesagem',
    'dt_pesagem': 'dataPesagem',
    'tipo': 'tipo',
    'tipo_pesagem': 'tipo',
    'peso': 'peso',
    'peso_kg': 'peso',
  };

  const dbColumnSet = {
    'numeroAnimal',
    'chip',
    'nome',
    'dataNascimento',
    'raca',
    'sexo',
    'dataPesagem',
    'tipo',
    'peso',
  };

  final out = <String, int>{};

  for (var i = 0; i < headerStrings.length; i++) {
    final rawHeader = headerStrings[i];
    if (rawHeader.trim().isEmpty) continue;

    if (dbColumnSet.contains(rawHeader)) {
      out.putIfAbsent(rawHeader, () => i);
      continue;
    }

    final normalized = _normalizeHeader(rawHeader);
    final mappedDb = templateMap[normalized];
    if (mappedDb != null) {
      out.putIfAbsent(mappedDb, () => i);
      continue;
    }
  }

  return out;
}

bool _hasMinimumPesagemData(Map<String, dynamic> map) {
  final hasIdentification = _hasValue(map['numeroAnimal']) ||
      _hasValue(map['chip']) ||
      _hasValue(map['nome']);
  final hasPesagem = _hasValue(map['peso']) || _hasValue(map['dataPesagem']);
  return hasIdentification && hasPesagem;
}

bool _hasValue(dynamic value) {
  if (value == null) return false;
  final s = value.toString().trim().toLowerCase();
  return s.isNotEmpty && s != 'null' && s != 'undefined';
}

bool _isCsvRowEmpty(List<dynamic> row) {
  if (row.isEmpty) return true;
  for (final cell in row) {
    if (cell == null) continue;
    final cleaned = _cleanText(cell.toString());
    if (cleaned.isNotEmpty && cleaned.toLowerCase() != 'null') {
      return false;
    }
  }
  return true;
}

bool _isAllValuesMissing(Iterable<dynamic> values) {
  for (final v in values) {
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty &&
        s.toLowerCase() != 'null' &&
        s.toLowerCase() != 'undefined') {
      return false;
    }
  }
  return true;
}

String _decodeWithBestEncoding(List<int> bytes) {
  String? utf8Text;
  try {
    utf8Text = utf8.decode(bytes);
  } catch (_) {}

  if (utf8Text != null) {
    if (!_looksMojibake(utf8Text)) {
      return utf8Text;
    }
    try {
      final latin1Text = latin1.decode(bytes);
      if (_mojibakeScore(latin1Text) < _mojibakeScore(utf8Text)) {
        return latin1Text;
      }
    } catch (_) {}
    return utf8Text;
  }

  try {
    return latin1.decode(bytes);
  } catch (_) {}

  String result = '';
  for (int i = 0; i < bytes.length; i++) {
    final byte = bytes[i];
    switch (byte) {
      case 0x90:
        result += 'ê';
        break;
      case 0x8D:
        result += 'ç';
        break;
      case 0xCC:
        result += 'Ã';
        break;
      default:
        result += String.fromCharCode(byte);
        break;
    }
  }
  return result;
}

bool _looksMojibake(String value) {
  return value.contains('Ã') || value.contains('Â') || value.contains('�');
}

int _mojibakeScore(String value) {
  var score = 0;
  for (final ch in value.split('')) {
    if (ch == 'Ã' || ch == 'Â' || ch == '�') score += 2;
  }
  return score;
}

String _detectDelimiter(String firstLine) {
  final delimiters = [';', ',', '\t', '|'];
  String bestDelimiter = ',';
  int maxFields = 0;

  for (final delimiter in delimiters) {
    final fields = firstLine.split(delimiter).length;
    if (fields > maxFields) {
      maxFields = fields;
      bestDelimiter = delimiter;
    }
  }

  return bestDelimiter;
}

String _cleanText(String text) {
  if (text.isEmpty) return text;
  return text
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(
          RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F\uFFFD]'), '');
}

String? _cleanCellToNull(
  String value,
  String column,
  List<String> numericColumns,
) {
  final lower = value.toLowerCase();
  if (value.isEmpty || lower == 'null' || lower == 'undefined') return null;
  if (value == '0' && !numericColumns.contains(column)) return null;
  return value;
}

double? _parseNumberPtBr(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.contains(',')) {
    final normalized = trimmed.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
  return double.tryParse(trimmed);
}

String _normalizeHeader(String header) {
  var h = _cleanText(header).toLowerCase();
  h = h
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('ä', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('è', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('í', 'i')
      .replaceAll('î', 'i')
      .replaceAll('ì', 'i')
      .replaceAll('ï', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('ò', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ö', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('û', 'u')
      .replaceAll('ù', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ç', 'c');

  h = h.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  h = h.replaceAll(RegExp(r'_+'), '_');
  h = h.replaceAll(RegExp(r'^_|_$'), '');
  return h;
}
