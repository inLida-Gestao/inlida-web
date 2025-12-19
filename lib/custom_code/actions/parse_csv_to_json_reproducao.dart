// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:csv/csv.dart';

Future<List<dynamic>> parseCsvToJsonReproducao(FFUploadedFile? csvFile) async {
  if (csvFile == null || csvFile.bytes == null) return [];

  try {
    List<int> bytes = csvFile.bytes!;

    // 1. Detectar e remover BOM (Byte Order Mark)
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      bytes = bytes.sublist(3);
      print('BOM UTF-8 removido');
    }

    // 2. Melhor detecção de encoding
    String csvString = _decodeWithBestEncoding(bytes);

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

    final List<List<dynamic>> rows = converter.convert(csvString);

    if (rows.isEmpty) return [];

    // 6. Colunas do banco (para fallback por posição quando CSV já vem exportado)
    const dbColumnsInOrder = [
      'id',
      'created_at',
      'id_propriedade',
      'tipo_reproducao',
      'id_rebanho_matriz',
      'score_corporal',
      'id_rebanho_reprodutor',
      'data_inseminacao',
      'data_partida_semen',
      'partida_semen',
      'previsao_parto',
      'id_lote',
      'data_inicial',
      'data_final',
      'status_reproducao',
      'inseminador',
      'anotacoes',
      'id_reproducao',
      'deletado',
      'updated_at',
      'categoria',
      'numMatriz',
      'nomeMatriz',
      'nascimentoMatriz',
      'numReprodutor',
      'nomeReprodutor',
      'nascimentoReprodutor',
      'loteNome',
      'data_status',
      'racaMatriz',
      'racaReprodutor',
      'chipReprodutor',
      'chipMatriz',
      'ressinc',
      'parida',
      'data_parto',
    ];

    const dbColumnSet = {
      'id',
      'created_at',
      'id_propriedade',
      'tipo_reproducao',
      'id_rebanho_matriz',
      'score_corporal',
      'id_rebanho_reprodutor',
      'data_inseminacao',
      'data_partida_semen',
      'partida_semen',
      'previsao_parto',
      'id_lote',
      'data_inicial',
      'data_final',
      'status_reproducao',
      'inseminador',
      'anotacoes',
      'id_reproducao',
      'deletado',
      'updated_at',
      'categoria',
      'numMatriz',
      'nomeMatriz',
      'nascimentoMatriz',
      'numReprodutor',
      'nomeReprodutor',
      'nascimentoReprodutor',
      'loteNome',
      'data_status',
      'racaMatriz',
      'racaReprodutor',
      'chipReprodutor',
      'chipMatriz',
      'ressinc',
      'parida',
      'data_parto',
    };

    const dateColumns = [
      'created_at',
      'data_inseminacao',
      'data_partida_semen',
      'previsao_parto',
      'data_inicial',
      'data_final',
      'updated_at',
      'nascimentoMatriz',
      'nascimentoReprodutor',
      'data_status',
      'data_parto',
    ];

    const numericDoubleColumns = [
      'score_corporal',
    ];
    const numericIntColumns = [
      'partida_semen',
    ];

    // 7. Detectar layout do CSV
    // - Se a primeira linha contém headers, mapear por nome.
    // - Caso contrário, usar fallback por posição.
    final headerRow = rows.first;
    final headerStrings = headerRow
        .map((e) => e == null ? '' : e.toString())
        .map(_cleanText)
        .toList();
    final normalizedHeaders = headerStrings.map(_normalizeHeader).toList();

    final bool looksLikeUserTemplate = normalizedHeaders.contains('lote') ||
        normalizedHeaders.contains('lote_nome') ||
        normalizedHeaders.contains('numero_matriz') ||
        normalizedHeaders.contains('numero_reprodutor') ||
        normalizedHeaders.contains('data_inicial_monta') ||
        normalizedHeaders.contains('data_final_monta');

    final bool looksLikeDbExport = headerStrings.any(dbColumnSet.contains);

    final bool useHeaderMapping = (looksLikeUserTemplate || looksLikeDbExport) &&
        normalizedHeaders.any((h) => h.isNotEmpty);

    if (useHeaderMapping) {
      final mapping = _buildHeaderToDbMapping(headerStrings, dbColumnSet);

      return rows.skip(1).map((row) {
        final map = <String, dynamic>{};

        mapping.forEach((dbColumn, index) {
          final raw = (index < row.length && row[index] != null)
              ? row[index].toString()
              : '';
          final value = _cleanText(raw);
          final cleaned =
              _cleanCellToNull(value, dbColumn, numericDoubleColumns, numericIntColumns);

          if (cleaned == null) {
            map[dbColumn] = null;
            return;
          }

          if (dateColumns.contains(dbColumn)) {
            map[dbColumn] = cleaned;
          } else if (numericDoubleColumns.contains(dbColumn)) {
            map[dbColumn] = _parseDoublePtBr(cleaned);
          } else if (numericIntColumns.contains(dbColumn)) {
            map[dbColumn] = _parseIntPtBr(cleaned);
          } else {
            map[dbColumn] = cleaned;
          }
        });

        // Campos que o usuário normalmente não tem: deixam null para o batch_insert gerar/limpar.
        map.putIfAbsent('id_reproducao', () => null);
        map.putIfAbsent('id_propriedade', () => null);

        return map;
      }).toList();
    }

    // Fallback: CSV sem header (ou inesperado), por posição com a ordem do banco.
    return rows.skip(1).map((row) {
      final map = <String, dynamic>{};

      for (var i = 0; i < dbColumnsInOrder.length; i++) {
        final dbColumn = dbColumnsInOrder[i];
        final raw = (i < row.length && row[i] != null) ? row[i].toString() : '';
        final value = _cleanText(raw);
        final cleaned =
            _cleanCellToNull(value, dbColumn, numericDoubleColumns, numericIntColumns);

        if (cleaned == null) {
          map[dbColumn] = null;
          continue;
        }

        if (dateColumns.contains(dbColumn)) {
          map[dbColumn] = cleaned;
        } else if (numericDoubleColumns.contains(dbColumn)) {
          map[dbColumn] = _parseDoublePtBr(cleaned);
        } else if (numericIntColumns.contains(dbColumn)) {
          map[dbColumn] = _parseIntPtBr(cleaned);
        } else {
          map[dbColumn] = cleaned;
        }
      }

      return map;
    }).toList();
  } catch (e, stack) {
    print('Erro no processamento CSV: $e');
    print(stack);
    return [];
  }
}

// Função auxiliar para decodificação customizada (fallback)
String _decodeWithBestEncoding(List<int> bytes) {
  // 1) Tentar UTF-8 estrito (principal caminho).
  // Importante: NÃO usar allowMalformed aqui, senão perde caracteres (vira "�")
  // e depois não dá pra recuperar.
  try {
    return utf8.decode(bytes);
  } catch (_) {}

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
      .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
          ''); // Remove caracteres de controle
}

String? _cleanCellToNull(
  String value,
  String column,
  List<String> numericDoubleColumns,
  List<String> numericIntColumns,
) {
  final lower = value.toLowerCase();
  if (value.isEmpty || lower == 'null' || lower == 'undefined') return null;
  if (value == '0' &&
      !numericDoubleColumns.contains(column) &&
      !numericIntColumns.contains(column)) {
    return null;
  }
  return value;
}

double? _parseDoublePtBr(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  // Ex.: "1.234,56" -> "1234.56" | "1234,56" -> "1234.56"
  if (trimmed.contains(',')) {
    final normalized = trimmed.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
  return double.tryParse(trimmed);
}

int? _parseIntPtBr(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  // Aceita "1.234" ou "1234" ou "1234,0" etc.
  final asDouble = _parseDoublePtBr(trimmed);
  if (asDouble == null) return int.tryParse(trimmed);
  return asDouble.round();
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
    'id': 'id',
    'created_at': 'created_at',
    'updated_at': 'updated_at',
    'id_propriedade': 'id_propriedade',
    'id_lote': 'id_lote',
    'id_rebanho_matriz': 'id_rebanho_matriz',
    'id_rebanho_reprodutor': 'id_rebanho_reprodutor',
    'id_reproducao': 'id_reproducao',
    'deletado': 'deletado',

    'tipo_reproducao': 'tipo_reproducao',
    'score_corporal': 'score_corporal',
    'data_inseminacao': 'data_inseminacao',
    'data_partida_semen': 'data_partida_semen',
    'partida_semen': 'partida_semen',
    'previsao_parto': 'previsao_parto',
    'status_reproducao': 'status_reproducao',
    'inseminador': 'inseminador',
    'anotacoes': 'anotacoes',
    'anotacoes_': 'anotacoes',
    'anotacoes_do_parto': 'anotacoes',
    'categoria': 'categoria',
    'categoria_matriz': 'categoria',

    'numero_matriz': 'numMatriz',
    'num_matriz': 'numMatriz',
    'nome_matriz': 'nomeMatriz',
    'data_nascimento_matriz': 'nascimentoMatriz',
    'nascimento_matriz': 'nascimentoMatriz',
    'raca_matriz': 'racaMatriz',
    'chip_matriz': 'chipMatriz',

    'numero_reprodutor': 'numReprodutor',
    'num_reprodutor': 'numReprodutor',
    'nome_reprodutor': 'nomeReprodutor',
    'data_nascimento_reprodutor': 'nascimentoReprodutor',
    'nascimento_reprodutor': 'nascimentoReprodutor',
    'raca_reprodutor': 'racaReprodutor',
    'chip_reprodutor': 'chipReprodutor',

    'lote': 'loteNome',
    'lote_nome': 'loteNome',

    // OBS do usuário: monta == data_inicial/data_final
    'data_inicial_monta': 'data_inicial',
    'data_final_monta': 'data_final',
    'data_inicial': 'data_inicial',
    'data_final': 'data_final',

    'data_status': 'data_status',
    'ressinc': 'ressinc',
    'parida': 'parida',
    'data_parto': 'data_parto',
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
