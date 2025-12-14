// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:csv/csv.dart';

Future<List<dynamic>> parseCsvToJsonLotes(FFUploadedFile? csvFile) async {
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

    // 6. Colunas fixas conforme tabela
    const columns = [
      'id',
      'created_at',
      'id_propriedade',
      'id_animais',
      'nome',
      'anotacoes',
      'ativo',
      'data_entrada_piquete',
      'data_saida_piquete',
      'motivo',
      'data_motivo',
      'id_lote',
      'deletado',
      'updated_at',
      'valorVenda',
    ];

    const dateColumns = [
      'created_at',
      'data_entrada_piquete',
      'data_saida_piquete',
      'data_motivo',
      'updated_at',
    ];

    const numericColumns = [
      'valorVenda',
    ];

    // 7. Mapear linhas para JSON
    return rows.skip(1).map((row) {
      final map = <String, dynamic>{};

      for (var i = 0; i < columns.length; i++) {
        var raw = (i < row.length && row[i] != null) ? row[i].toString() : '';

        // Melhor tratamento de texto preservando acentos
        String value = _cleanText(raw);

        final column = columns[i];

        // Verificar se valor está vazio ou é null ANTES de qualquer processamento
        if (value.isEmpty ||
            value.toLowerCase() == 'null' ||
            value.toLowerCase() == 'undefined' ||
            value == '0' && !numericColumns.contains(column)) {
          map[column] = null;
          continue;
        }

        if (dateColumns.contains(column)) {
          // Para colunas de data, apenas mantém como string (sem parsing)
          map[column] = value;
        } else if (numericColumns.contains(column)) {
          final numericValue = value.replaceAll(',', '.');
          // Para colunas numéricas, só converte se não estiver vazio
          if (numericValue.trim().isEmpty) {
            map[column] = null;
          } else {
            final parsed = double.tryParse(numericValue);
            map[column] = parsed; // Se não conseguir converter, fica null
          }
        } else {
          map[column] = value;
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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
