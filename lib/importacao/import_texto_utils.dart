// Helpers de texto, data e numero usados pela importacao de planilhas.
//
// Por que este arquivo existe: estes helpers nasceram privados e duplicados em
// 5 arquivos de lib/custom_code/actions/ (parse_csv_to_json_*.dart e
// batch_insert_supabase_*.dart), com copias que ja divergiam entre si. Isso
// tornava impossivel validar uma planilha antes de gravar sem reimplementar a
// mesma logica uma sexta vez.
//
// As implementacoes aqui foram extraidas VERBATIM das copias canonicas -- as
// mais completas de cada helper -- para garantir paridade de comportamento:
//   - de batch_insert_supabase_rebanho.dart: fixEncoding, stripDiacritics,
//     convertDateFormat, isValidPeso, isValidDate, normalizeDateKey e
//     as chaves de identidade;
//   - de parse_csv_to_json_rebanho2.dart: normalizeHeader, parseNumberPtBr,
//     cleanText, cleanCellToNull e as checagens de texto corrompido.
// A unica alteracao foi remover os print() de diagnostico, que nao influenciam
// o valor de retorno -- quem reporta problema agora e o diagnostico de
// importacao, nao o console. test/import_helpers_paridade_test.dart protege
// essa equivalencia com valores golden.
//
// Este arquivo e Dart puro de proposito (sem flutter_flow_util, sem Supabase),
// para rodar em `flutter test` sem subir nada -- mesmo padrao de
// lib/pg_rebanho/pesagem_rebanho_sync.dart.

import 'dart:convert';

bool isMissingValueImport(dynamic value) {
  if (value == null) return true;
  final s = value.toString();
  return s.trim().isEmpty || s == 'null' || s == 'undefined';
}

String? asNonEmptyStringImport(dynamic value) {
  if (isMissingValueImport(value)) return null;
  return value.toString();
}

String normalizeNumeroKeyImport(String value) {
  return value.trim();
}

String? normalizeDateKeyImport(dynamic value) {
  final raw = asNonEmptyStringImport(value);
  if (raw == null) return null;

  final fixed = fixEncodingImport(raw);
  final converted = convertDateFormatImport(fixed);
  if (converted != null) return converted;

  // Último fallback: tenta cortar ISO com horário.
  if (fixed.contains('T')) {
    final part = fixed.split('T').first;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(part)) return part;
  }
  if (fixed.contains(' ')) {
    final part = fixed.split(' ').first;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(part)) return part;
  }
  return null;
}

String normalizeIdentityTextImport(String value) {
  return normalizeLoteNomeImport(fixEncodingImport(value));
}

String normalizeLoteNomeImport(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAllMapped(
        RegExp(r'[\u00C0-\u017F]'),
        (m) => stripDiacriticsImport(m[0]!),
      )
      .replaceAll(RegExp(r'\s+'), ' ');
}

String stripDiacriticsImport(String ch) {
  switch (ch) {
    case 'á':
    case 'à':
    case 'â':
    case 'ã':
    case 'ä':
    case 'å':
    case 'Á':
    case 'À':
    case 'Â':
    case 'Ã':
    case 'Ä':
    case 'Å':
      return 'a';
    case 'é':
    case 'è':
    case 'ê':
    case 'ë':
    case 'É':
    case 'È':
    case 'Ê':
    case 'Ë':
      return 'e';
    case 'í':
    case 'ì':
    case 'î':
    case 'ï':
    case 'Í':
    case 'Ì':
    case 'Î':
    case 'Ï':
      return 'i';
    case 'ó':
    case 'ò':
    case 'ô':
    case 'õ':
    case 'ö':
    case 'Ó':
    case 'Ò':
    case 'Ô':
    case 'Õ':
    case 'Ö':
      return 'o';
    case 'ú':
    case 'ù':
    case 'û':
    case 'ü':
    case 'Ú':
    case 'Ù':
    case 'Û':
    case 'Ü':
      return 'u';
    case 'ç':
    case 'Ç':
      return 'c';
    case 'ñ':
    case 'Ñ':
      return 'n';
    default:
      return ch;
  }
}

bool isValidPesoImport(dynamic peso) {
  if (peso == null) return false;
  if (peso == "null" || peso == "undefined" || peso == "") return false;
  if (peso is String && peso.trim().isEmpty) return false;

  try {
    final pesoNum = parsePesoImport(peso);
    return pesoNum != null && pesoNum > 0;
  } catch (e) {
    return false;
  }
}

bool isValidDateImport(String? dateValue) {
  if (dateValue == null) return false;
  final trimmed =
      dateValue.trim().replaceAll('null', '').replaceAll('undefined', '');
  if (trimmed.isEmpty) return false;
  return DateTime.tryParse(trimmed) != null;
}

// Função auxiliar para converter peso para número
num? parsePesoImport(dynamic peso) {
  if (peso == null) return null;

  try {
    if (peso is num) return peso;
    if (peso is String) {
      // Remover espaços e trocar vírgula por ponto
      final cleaned = peso.trim().replaceAll(',', '.');
      return num.parse(cleaned);
    }
    return null;
  } catch (e) {
    return null;
  }
}

// Função auxiliar para corrigir problemas de encoding (acentuação)
String fixEncodingImport(String text) {
  try {
    text = stripControlCharsImport(text);

    // Heurística: corrige strings UTF-8 interpretadas como Latin-1.
    // Ex.: "FÃªmea" -> "Fêmea".
    if (!looksMojibakeImport(text)) {
      return text;
    }

    final originalScore = mojibakeScoreImport(text);
    String? candidate;

    try {
      final bytes = latin1.encode(text);
      candidate = utf8.decode(bytes);
    } catch (_) {
      try {
        final bytes = latin1.encode(text);
        candidate = utf8.decode(bytes, allowMalformed: true);
      } catch (_) {}
    }

    if (candidate != null && mojibakeScoreImport(candidate) < originalScore) {
      return stripControlCharsImport(candidate);
    }
    return text;
  } catch (e) {
    return text;
  }
}

String stripControlCharsImport(String value) {
  return value.replaceAll(
    RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F\uFFFD]'),
    '',
  );
}

bool looksMojibakeImport(String value) {
  return value.contains('Ã') || value.contains('Â') || value.contains('�');
}

int mojibakeScoreImport(String value) {
  var score = 0;
  for (final ch in value.split('')) {
    if (ch == 'Ã' || ch == 'Â' || ch == '�') score += 2;
  }
  return score;
}

// Função auxiliar para converter data de DD/MM/YYYY para YYYY-MM-DD
String? convertDateFormatImport(String dateStr) {
  if (dateStr.isEmpty) return null;

  try {
    // Remover espaços em branco
    dateStr = dateStr.trim();

    // Verificar se já está no formato YYYY-MM-DD (com ou sem hora)
    final isoMatch =
        RegExp(r'^(\d{4}-\d{2}-\d{2})(?:\s+.*)?$').firstMatch(dateStr);
    if (isoMatch != null) {
      final isoDate = isoMatch.group(1)!;
      final parsedIso = DateTime.tryParse(isoDate);
      if (parsedIso == null) {
        return null;
      }
      return isoDate;
    }

    // Verificar formato DD/MM/YYYY (com ou sem hora no final)
    final brMatch = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})(?:\s+.*)?$')
        .firstMatch(dateStr);
    if (brMatch != null) {
      final day = brMatch.group(1)!;
      final month = brMatch.group(2)!;
      final year = brMatch.group(3)!;
      final converted = '$year-$month-$day';
      final parsedBr = DateTime.tryParse(converted);
      if (parsedBr == null) {
        return null;
      }
      return converted;
    }

    // Se não conseguir converter, retorna null
    return null;
  } catch (e) {
    return null;
  }
}

String? cleanStringOrNullImport(dynamic value) {
  if (value == null) return null;
  final cleaned = cleanTextImport(value.toString());
  if (cleaned.isEmpty ||
      cleaned.toLowerCase() == 'null' ||
      cleaned.toLowerCase() == 'undefined') {
    return null;
  }
  return cleaned;
}

bool isPlausibleImportIdentifier(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > 80) return false;

  var hasLetterOrDigit = false;
  for (final rune in trimmed.runes) {
    if (isWhitespaceRuneImport(rune)) continue;
    if (!isAllowedImportTextRune(rune)) return false;
    if (isImportIdentifierLetterOrDigit(rune)) {
      hasLetterOrDigit = true;
    }
  }

  return hasLetterOrDigit;
}

bool looksLikeCorruptedImportText(String value) {
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
    if (isWhitespaceRuneImport(rune)) continue;
    nonSpace++;
    if (isAllowedImportTextRune(rune)) continue;
    unusualSymbols++;
  }

  return nonSpace > 0 &&
      unusualSymbols >= 3 &&
      unusualSymbols / nonSpace > 0.25;
}

bool isWhitespaceRuneImport(int rune) =>
    rune == 0x20 || rune == 0x09 || rune == 0x0A || rune == 0x0D;

bool isAllowedImportTextRune(int rune) {
  final isAsciiLetter =
      (rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A);
  final isDigit = rune >= 0x30 && rune <= 0x39;
  final isLatinLetter = (rune >= 0x00C0 && rune <= 0x017F);
  final isCommonPunctuation = '.,;:/_-#()*+@\'"&ªº°'.runes.contains(rune);
  return isAsciiLetter || isDigit || isLatinLetter || isCommonPunctuation;
}

bool isImportIdentifierLetterOrDigit(int rune) {
  final isAsciiLetter =
      (rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A);
  final isDigit = rune >= 0x30 && rune <= 0x39;
  final isLatinLetter = (rune >= 0x00C0 && rune <= 0x017F);
  return isAsciiLetter || isDigit || isLatinLetter;
}

String cleanTextImport(String text) {
  if (text.isEmpty) return text;

  // Remove espaços extras mas preserva acentos
  return text
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ') // Múltiplos espaços viram um só
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F\uFFFD]'),
          ''); // Remove caracteres de controle e substituições inválidas
}

String? cleanCellToNullImport(
  String value,
  String column,
  List<String> numericColumns,
) {
  final lower = value.toLowerCase();
  if (value.isEmpty || lower == 'null' || lower == 'undefined') return null;
  if (value == '0' && !numericColumns.contains(column)) return null;
  return value;
}

double? parseNumberPtBrImport(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  // Ex.: "1.234,56" -> "1234.56" | "1234,56" -> "1234.56"
  if (trimmed.contains(',')) {
    final normalized = trimmed.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
  return double.tryParse(trimmed);
}

String normalizeHeaderImport(String header) {
  var h = cleanTextImport(header).toLowerCase();
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
