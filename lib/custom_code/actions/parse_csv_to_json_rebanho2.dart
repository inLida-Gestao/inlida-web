// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xl;

Future<List<dynamic>> parseCsvToJsonRebanho2(FFUploadedFile? csvFile) async {
  if (csvFile == null || csvFile.bytes == null || csvFile.bytes!.isEmpty) {
    return [];
  }

  try {
    final List<int> bytes = csvFile.bytes!;
    final fileName = (csvFile.originalFilename.isNotEmpty
            ? csvFile.originalFilename
            : (csvFile.name ?? ''))
        .toLowerCase();

    if (_isLegacyXlsBinary(bytes, fileName)) {
      print(
        'Arquivo .xls binário não suportado na importação. Exporte como .xlsx ou CSV.',
      );
      return [];
    }

    final isXlsx = _isXlsxFile(bytes, fileName);
    if (!isXlsx && _looksLikeBinaryContent(bytes)) {
      print(
        'Arquivo parece binário e não será importado como CSV para evitar caracteres corrompidos.',
      );
      return [];
    }

    final List<List<dynamic>> rows =
        isXlsx ? _parseXlsx(bytes) : _parseCsv(bytes);

    if (rows.isEmpty) return [];

    // 6. Colunas do banco (para fallback por posição quando CSV já vem exportado)
    const dbColumnsInOrder = [
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
      'movimentacao_entrada',
      'numeroMatriz',
      'nomeMatriz',
      'dataNascMatriz',
      'racaMatriz',
      'numeroReprodutor',
      'nomeReprodutor',
      'dataNascReprodutor',
      'racaReprodutor',
      'movimentacao_saida',
      'data_morte',
      'motivo_morte',
      'categoria_matriz',
    ];

    const dbColumnSet = {
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
      'movimentacao_entrada',
      'numeroMatriz',
      'nomeMatriz',
      'dataNascMatriz',
      'racaMatriz',
      'numeroReprodutor',
      'nomeReprodutor',
      'dataNascReprodutor',
      'racaReprodutor',
      'movimentacao_saida',
      'data_morte',
      'motivo_morte',
      'categoria_matriz',
    };

    const dateColumns = [
      'created_at',
      'dataNascimento',
      'dataEntradaLote',
      'dataDesmama',
      'updated_at',
      'dataAcao',
      'dataUltimaPesagem',
      'dataVenda',
      'movimentacao_entrada',
      'dataNascMatriz',
      'dataNascReprodutor',
      'movimentacao_saida',
      'data_morte',
    ];

    const numericColumns = [
      'pesoNascimento',
      'pesoDesmama',
      'pesoAtual',
      'valorCompra',
      'valorVenda',
    ];

    // 7. Detectar layout do CSV
    // - Se a primeira linha contém headers, mapear por nome.
    // - Caso contrário (ou se parecer export do banco sem header do usuário), usar fallback por posição.
    final headerRow = rows.first;
    final headerStrings = headerRow
        .map((e) => e == null ? '' : e.toString())
        .map(_cleanText)
        .toList();
    final normalizedHeaders = headerStrings.map(_normalizeHeader).toList();

    final bool looksLikeUserTemplate = normalizedHeaders.contains('numero') ||
        normalizedHeaders.contains('numero_animal') ||
        normalizedHeaders.contains('data_compra') ||
        normalizedHeaders.contains('valor_compra');

    final bool looksLikeDbExport = headerStrings.any(dbColumnSet.contains);

    final bool useHeaderMapping =
        (looksLikeUserTemplate || looksLikeDbExport) &&
            normalizedHeaders.any((h) => h.isNotEmpty);

    if (useHeaderMapping) {
      final mapping = _buildHeaderToDbMapping(headerStrings, dbColumnSet);

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

        // Campos que o usuário normalmente não tem: deixam null para o batch_insert gerar/limpar.
        map.putIfAbsent('idRebanho', () => null);
        map.putIfAbsent('idPropriedade', () => null);

        if (_isAllValuesMissing(map.values)) continue;
        final validationError = _validateParsedRecord(map);
        if (validationError != null) {
          print('Linha ignorada na importação de rebanho: $validationError');
          continue;
        }
        out.add(map);
      }

      return out;
    }

    // Fallback: CSV sem header (ou inesperado), por posição com a ordem do banco.
    final out = <dynamic>[];
    for (final row in rows.skip(1)) {
      if (_isCsvRowEmpty(row)) continue;

      final map = <String, dynamic>{};

      for (var i = 0; i < dbColumnsInOrder.length; i++) {
        final dbColumn = dbColumnsInOrder[i];
        final raw = (i < row.length && row[i] != null) ? row[i].toString() : '';
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
      final validationError = _validateParsedRecord(map);
      if (validationError != null) {
        print('Linha ignorada na importação de rebanho: $validationError');
        continue;
      }
      out.add(map);
    }

    return out;
  } catch (e, stack) {
    print('Erro no processamento CSV: $e');
    print(stack);
    return [];
  }
}

bool _isXlsxFile(List<int> bytes, String fileName) {
  if (fileName.endsWith('.xlsx')) return true;
  if (fileName.endsWith('.xls') && _hasZipSignature(bytes)) return true;
  // XLSX é um ZIP; a assinatura evita decodificar bytes binários como CSV.
  return _hasZipSignature(bytes);
}

bool _hasZipSignature(List<int> bytes) {
  return bytes.length >= 4 &&
      bytes[0] == 0x50 &&
      bytes[1] == 0x4B &&
      bytes[2] == 0x03 &&
      bytes[3] == 0x04;
}

bool _isLegacyXlsBinary(List<int> bytes, String fileName) {
  final hasOleSignature = bytes.length >= 8 &&
      bytes[0] == 0xD0 &&
      bytes[1] == 0xCF &&
      bytes[2] == 0x11 &&
      bytes[3] == 0xE0 &&
      bytes[4] == 0xA1 &&
      bytes[5] == 0xB1 &&
      bytes[6] == 0x1A &&
      bytes[7] == 0xE1;

  if (hasOleSignature) return true;

  return fileName.endsWith('.xls') && !_hasZipSignature(bytes);
}

bool _hasUtf16Bom(List<int> bytes) {
  return bytes.length >= 2 &&
      ((bytes[0] == 0xFF && bytes[1] == 0xFE) ||
          (bytes[0] == 0xFE && bytes[1] == 0xFF));
}

bool _looksLikeBinaryContent(List<int> bytes) {
  if (bytes.isEmpty || _hasUtf16Bom(bytes) || _hasZipSignature(bytes)) {
    return false;
  }

  final sampleLength = bytes.length < 4096 ? bytes.length : 4096;
  var binaryControlBytes = 0;
  var nullBytes = 0;

  for (var i = 0; i < sampleLength; i++) {
    final byte = bytes[i];
    if (byte == 0) {
      nullBytes++;
      continue;
    }

    final isAllowedTextControl = byte == 0x09 || byte == 0x0A || byte == 0x0D;
    if (byte < 0x20 && !isAllowedTextControl) {
      binaryControlBytes++;
    }
  }

  final binaryRatio = (binaryControlBytes + nullBytes) / sampleLength;
  return nullBytes > 0 || binaryRatio > 0.04;
}

List<List<dynamic>> _parseXlsx(List<int> bytes) {
  final excel = xl.Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return [];

  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName];
  if (sheet == null || sheet.rows.isEmpty) return [];

  final rows = <List<dynamic>>[];
  for (final row in sheet.rows) {
    final cells = <dynamic>[];
    for (final cell in row) {
      final value = cell?.value;
      if (value == null) {
        cells.add('');
      } else if (value is xl.DateCellValue) {
        final dt = value.asDateTimeLocal();
        cells.add(
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}',
        );
      } else if (value is xl.DoubleCellValue) {
        cells.add(value.value.toString());
      } else if (value is xl.IntCellValue) {
        cells.add(value.value.toString());
      } else if (value is xl.TextCellValue) {
        cells.add(value.value.text ?? '');
      } else {
        cells.add(value.toString());
      }
    }
    rows.add(cells);
  }
  return rows;
}

List<List<dynamic>> _parseCsv(List<int> bytes) {
  List<int> cleanBytes = bytes;
  String? csvString = _decodeUtf16Bom(cleanBytes);

  // 1. Detectar e remover BOM (Byte Order Mark)
  if (csvString == null &&
      cleanBytes.length >= 3 &&
      cleanBytes[0] == 0xEF &&
      cleanBytes[1] == 0xBB &&
      cleanBytes[2] == 0xBF) {
    cleanBytes = cleanBytes.sublist(3);
    print('BOM UTF-8 removido');
  }

  // 2. Melhor detecção de encoding
  csvString ??= _decodeWithBestEncoding(cleanBytes);

  // 3. Normalizar quebras de linha
  csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // 4. Detectar delimitador (usa a primeira linha como base)
  String firstLine = csvString.split('\n').first;
  String delimiter = _detectDelimiter(firstLine);
  print('Delimitador detectado: "$delimiter"');

  // 5. Ler CSV respeitando o delimitador detectado
  final converter = CsvToListConverter(
    fieldDelimiter: delimiter,
    eol: '\n',
    shouldParseNumbers: false,
    allowInvalid: true,
  );

  return converter.convert(csvString);
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

String? _validateParsedRecord(Map<String, dynamic> map) {
  const strictIdentifierColumns = [
    'numeroAnimal',
    'chip',
    'codRegistro',
    'numeroMatriz',
    'numeroReprodutor',
  ];

  for (final column in strictIdentifierColumns) {
    final value = _cleanStringOrNull(map[column]);
    if (value == null) continue;
    if (!_isPlausibleImportIdentifier(value)) {
      return 'campo $column contém caracteres incompatíveis com identificador de animal.';
    }
  }

  for (final entry in map.entries) {
    final value = entry.value;
    if (value is String && _looksLikeCorruptedImportText(value)) {
      return 'campo ${entry.key} parece estar com bytes de arquivo/encoding corrompidos.';
    }
  }

  const identityColumns = ['numeroAnimal', 'chip', 'codRegistro', 'nome'];
  final hasIdentity = identityColumns.any((column) {
    final value = _cleanStringOrNull(map[column]);
    return value != null && !_looksLikeCorruptedImportText(value);
  });

  if (!hasIdentity) {
    return 'registro sem identificação válida do animal.';
  }

  return null;
}

String? _cleanStringOrNull(dynamic value) {
  if (value == null) return null;
  final cleaned = _cleanText(value.toString());
  if (cleaned.isEmpty ||
      cleaned.toLowerCase() == 'null' ||
      cleaned.toLowerCase() == 'undefined') {
    return null;
  }
  return cleaned;
}

bool _isPlausibleImportIdentifier(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > 80) return false;
  if (!RegExp(r'[A-Za-z0-9]').hasMatch(trimmed)) return false;
  return RegExp(r'^[A-Za-z0-9 _./#:\-()]+$').hasMatch(trimmed);
}

bool _looksLikeCorruptedImportText(String value) {
  final text = value.trim();
  if (text.isEmpty) return false;
  if (text.contains('\uFFFD')) return true;

  final artifactMatches = RegExp(
    r'[¢£¤¥¦¨©ª«¬®¯±²³µ¶·¸¹»¼½¾¿ÆÐ×ØÞßæ÷øþ]',
  ).allMatches(text).length;
  if (artifactMatches >= 2) return true;

  var nonSpace = 0;
  var unusualSymbols = 0;
  for (final rune in text.runes) {
    if (_isWhitespaceRune(rune)) continue;
    nonSpace++;
    if (_isAllowedImportTextRune(rune)) continue;
    unusualSymbols++;
  }

  return nonSpace > 0 &&
      unusualSymbols >= 3 &&
      unusualSymbols / nonSpace > 0.25;
}

bool _isWhitespaceRune(int rune) =>
    rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0x0D;

bool _isAllowedImportTextRune(int rune) {
  final isAsciiLetter =
      (rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A);
  final isDigit = rune >= 0x30 && rune <= 0x39;
  final isLatinLetter = (rune >= 0x00C0 && rune <= 0x017F);
  final isCommonPunctuation = '.,;:/_-#()+\'"'.runes.contains(rune);
  return isAsciiLetter || isDigit || isLatinLetter || isCommonPunctuation;
}

// Função auxiliar para decodificação customizada (fallback)
String _decodeWithBestEncoding(List<int> bytes) {
  // 1) Tentar UTF-8 estrito (principal caminho).
  // Importante: NÃO usar allowMalformed aqui, senão perde caracteres (vira "�")
  // e depois não dá pra recuperar.
  String? utf8Text;
  try {
    utf8Text = utf8.decode(bytes);
  } catch (_) {}

  if (utf8Text != null) {
    if (!_looksMojibake(utf8Text)) {
      return utf8Text;
    }

    // Se UTF-8 parece mojibake, tenta Latin-1 e escolhe o melhor.
    try {
      final latin1Text = latin1.decode(bytes);
      if (_mojibakeScore(latin1Text) < _mojibakeScore(utf8Text)) {
        return latin1Text;
      }
    } catch (_) {}

    return utf8Text;
  }

  // 2) Tentar Latin-1 (muito comum em CSVs antigos / Excel).
  try {
    return latin1.decode(bytes);
  } catch (_) {}

  // 3) Fallback customizado (mantido para casos específicos)
  print('Usando decodificação customizada como fallback');

  // Criar string resultado para casos de encoding customizado
  String result = '';

  // Processar byte por byte com mapeamento específico para arquivos antigos
  for (int i = 0; i < bytes.length; i++) {
    final byte = bytes[i];

    // Mapeamento apenas dos bytes problemáticos identificados em arquivos não-UTF8
    switch (byte) {
      case 0x90:
        result += 'ê'; // Fêmea
        break;
      case 0x8D:
        result += 'ç'; // Mestiço
        break;
      case 0xCC:
        result += 'Ã'; // SÃO
        break;
      default:
        result += String.fromCharCode(byte);
        break;
    }
  }

  return result;
}

String? _decodeUtf16Bom(List<int> bytes) {
  if (!_hasUtf16Bom(bytes)) return null;

  final littleEndian = bytes[0] == 0xFF && bytes[1] == 0xFE;
  final buffer = StringBuffer();

  for (var i = 2; i + 1 < bytes.length; i += 2) {
    final codeUnit = littleEndian
        ? bytes[i] | (bytes[i + 1] << 8)
        : (bytes[i] << 8) | bytes[i + 1];
    buffer.writeCharCode(codeUnit);
  }

  return buffer.toString();
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

// Função auxiliar para detectar delimitador
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

// Função auxiliar para limpar texto preservando acentos
String _cleanText(String text) {
  if (text.isEmpty) return text;

  // Remove espaços extras mas preserva acentos
  return text
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ') // Múltiplos espaços viram um só
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F\uFFFD]'),
          ''); // Remove caracteres de controle e substituições inválidas
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

  // Ex.: "1.234,56" -> "1234.56" | "1234,56" -> "1234.56"
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

  // Padroniza separadores
  h = h.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  h = h.replaceAll(RegExp(r'_+'), '_');
  h = h.replaceAll(RegExp(r'^_|_$'), '');
  return h;
}

Map<String, int> _buildHeaderToDbMapping(
  List<String> headerStrings,
  Set<String> dbColumnSet,
) {
  // Mapeamento do modelo do usuário (Excel) -> coluna do banco
  const templateMap = <String, String>{
    'numero': 'numeroAnimal',
    'numero_animal': 'numeroAnimal',
    'chip': 'chip',
    'codigo_registro': 'codRegistro',
    'codigo_registro_': 'codRegistro',
    'codigo': 'codRegistro',
    'nome': 'nome',
    'sexo': 'sexo',
    'data_nascimento': 'dataNascimento',
    'peso_nascimento': 'pesoNascimento',
    'porte': 'porte',
    'categoria': 'categoria',
    'raca': 'raca',
    'lote': 'loteNome',
    'data_desmama': 'dataDesmama',
    'peso_desmama': 'pesoDesmama',
    'data_ultima_pesagem': 'dataUltimaPesagem',
    'peso_atual': 'pesoAtual',
    'status': 'status',
    'data_venda': 'dataVenda',
    'valor_venda': 'valorVenda',
    'data_morte': 'data_morte',
    'motivo_morte': 'motivo_morte',
    'movimentacao_saida': 'movimentacao_saida',
    'origem': 'origem',
    'data_compra': 'dataAcao',
    'valor_compra': 'valorCompra',
    'movimentacao_entrada': 'movimentacao_entrada',
    'anotacoes': 'anotacoes',
    'numero_matriz': 'numeroMatriz',
    'nome_matriz': 'nomeMatriz',
    'data_nascimento_matriz': 'dataNascMatriz',
    'categoria_matriz': 'categoria_matriz',
    'raca_matriz': 'racaMatriz',
    'numero_reprodutor': 'numeroReprodutor',
    'nome_reprodutor': 'nomeReprodutor',
    'data_nascimento_reprodutor': 'dataNascReprodutor',
    'raca_reprodutor': 'racaReprodutor',
  };

  final out = <String, int>{};

  for (var i = 0; i < headerStrings.length; i++) {
    final rawHeader = headerStrings[i];
    if (rawHeader.trim().isEmpty) continue;

    // Se já vier com nomes do banco, usa direto.
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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
