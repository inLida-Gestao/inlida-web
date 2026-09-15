// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>> batchInsertSupabaseLotes(
  List<dynamic> records,
  String idPropriedade,
) async {
  if (records.isEmpty) {
    return {
      'success': true,
      'total': 0,
      'inserted': 0,
      'failed': 0,
      'failedRows': <Map<String, dynamic>>[],
    };
  }

  try {
    // Configurações de performance
    const int chunkSize = 500; // Tamanho do lote (ajuste conforme necessário)

    // Campos de data que precisam de conversão DD/MM/YYYY -> YYYY-MM-DD
    // (created_at e updated_at são gerados pelo Supabase automaticamente)
    const dateFields = [
      'data_entrada_piquete',
      'data_saida_piquete',
      'data_motivo',
    ];

    int totalInserted = 0;
    int totalFailed = 0;
    final List<Map<String, dynamic>> failedRows = [];

    // Processar em chunks para melhor performance
    for (int i = 0; i < records.length; i += chunkSize) {
      final end =
          (i + chunkSize < records.length) ? i + chunkSize : records.length;
      final chunk = records.sublist(i, end);

      try {
        // Preparar dados para inserção
        final List<Map<String, dynamic>> cleanRecords = [];

        for (final record in chunk) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(record);

          // Remove campos gerados automaticamente pelo Supabase
          data.remove('id');
          data.remove('created_at');
          data.remove('updated_at');
          data.remove('deletado');

          // Gerar id_reproducao único SOMENTE se não existir ou estiver vazio
          if (data['id_lote'] == null ||
              data['id_lote'].toString().trim().isEmpty ||
              data['id_lote'] == 'null') {
            data['id_lote'] = _generateIdReproducao();
          }

          // Garantir que id_propriedade está presente
          data['id_propriedade'] = idPropriedade;

          // Limpar valores "null" string e vazios para null real
          final Map<String, dynamic> cleanData = {};
          data.forEach((key, value) {
            if (value == null ||
                value == "null" ||
                value == "undefined" ||
                value == "") {
              cleanData[key] = null;
            } else if (value is String && value.trim().isEmpty) {
              cleanData[key] = null;
            } else {
              // Corrigir encoding de acentuação
              if (value is String) {
                cleanData[key] = _fixEncoding(value);
              } else {
                cleanData[key] = value;
              }
            }
          });

          // Converter campos de data de DD/MM/YYYY para YYYY-MM-DD
          for (final dateField in dateFields) {
            if (cleanData[dateField] != null) {
              cleanData[dateField] =
                  _convertDateFormat(cleanData[dateField].toString());
            }
          }

          cleanRecords.add(cleanData);
        }

        // Inserir em lote no Supabase
        // Usando upsert com id_reproducao como chave única
        await Supabase.instance.client.from('lotes').upsert(
              cleanRecords,
              onConflict: 'id_lote',
              ignoreDuplicates: false,
            );

        totalInserted += cleanRecords.length;

        print(
            'Chunk ${(i / chunkSize).floor() + 1}: ${chunk.length} registros inseridos');
      } catch (chunkError) {
        print('Erro no chunk ${(i / chunkSize).floor() + 1}: $chunkError');

        // Tentar inserir registro por registro em caso de erro no chunk
        for (int chunkIndex = 0; chunkIndex < chunk.length; chunkIndex++) {
          final record = chunk[chunkIndex];
          try {
            final Map<String, dynamic> data = Map<String, dynamic>.from(record);

            // Remove campos gerados automaticamente pelo Supabase
            data.remove('id');
            data.remove('created_at');
            data.remove('updated_at');
            data.remove('deletado');

            // Gerar id_reproducao único SOMENTE se não existir ou estiver vazio
            if (data['id_lote'] == null ||
                data['id_lote'].toString().trim().isEmpty ||
                data['id_lote'] == 'null') {
              data['id_lote'] = _generateIdReproducao();
            }

            data['id_propriedade'] = idPropriedade;

            final Map<String, dynamic> cleanData = {};
            data.forEach((key, value) {
              if (value == null ||
                  value == "null" ||
                  value == "undefined" ||
                  value == "") {
                cleanData[key] = null;
              } else if (value is String && value.trim().isEmpty) {
                cleanData[key] = null;
              } else {
                // Corrigir encoding de acentuação
                if (value is String) {
                  cleanData[key] = _fixEncoding(value);
                } else {
                  cleanData[key] = value;
                }
              }
            });

            // Converter campos de data de DD/MM/YYYY para YYYY-MM-DD
            for (final dateField in dateFields) {
              if (cleanData[dateField] != null) {
                cleanData[dateField] =
                    _convertDateFormat(cleanData[dateField].toString());
              }
            }

            await Supabase.instance.client
                .from('lotes')
                .upsert(cleanData, onConflict: 'id_lote');

            totalInserted += 1;
          } catch (recordError) {
            print('Erro ao inserir registro individual: $recordError');
            totalFailed += 1;

            final originalData = record is Map
                ? Map<String, dynamic>.from(record)
                : <String, dynamic>{};
            failedRows.add({
              'linha': i + chunkIndex + 2,
              'id_lote': (originalData['id_lote']?.toString() ?? '').trim(),
              'nome': (originalData['nome']?.toString() ?? '').trim(),
              'motivo': _buildFriendlyImportError(recordError),
              'erro': recordError.toString(),
            });
            continue;
          }
        }
      }
    }

    if (totalFailed > 0) {
      print(
        'Importação de lotes concluída com falhas: inseridos=$totalInserted, falhas=$totalFailed, total=${records.length}',
      );
      return {
        'success': false,
        'total': records.length,
        'inserted': totalInserted,
        'failed': totalFailed,
        'failedRows': failedRows,
      };
    }

    print(
      'Importação de lotes concluída: inseridos=$totalInserted, total=${records.length}',
    );
    return {
      'success': true,
      'total': records.length,
      'inserted': totalInserted,
      'failed': 0,
      'failedRows': <Map<String, dynamic>>[],
    };
  } catch (e, stack) {
    print('Erro geral no batch insert: $e');
    print(stack);
    return {
      'success': false,
      'total': records.length,
      'inserted': 0,
      'failed': records.length,
      'failedRows': <Map<String, dynamic>>[
        {
          'linha': null,
          'id_lote': '',
          'nome': '',
          'motivo': _buildFriendlyImportError(e),
          'erro': e.toString(),
        }
      ],
    };
  }
}

String _buildFriendlyImportError(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();
  final column = _extractErrorColumn(lower);
  final keyColumn = _extractKeyColumn(lower);

  if (lower.contains('date') ||
      lower.contains('timestamp') ||
      lower.contains('invalid input syntax for type date')) {
    if (column != null) {
      return 'Data inválida ou em formato não reconhecido no campo ${_labelLoteColumn(column)}.';
    }
    return 'Data inválida ou em formato não reconhecido.';
  }

  if (lower.contains('invalid input syntax for type numeric') ||
      lower.contains('invalid input syntax for type double') ||
      lower.contains('invalid input syntax for type integer')) {
    if (column != null) {
      return 'Valor numérico inválido no campo ${_labelLoteColumn(column)}.';
    }
    return 'Valor numérico inválido.';
  }

  if (lower.contains('duplicate key') || lower.contains('unique constraint')) {
    if (keyColumn != null) {
      return 'Registro duplicado para chave única no campo ${_labelLoteColumn(keyColumn)}.';
    }
    return 'Registro duplicado para chave única.';
  }

  if (lower.contains('null value in column') ||
      lower.contains('not-null constraint')) {
    if (column != null) {
      return 'Campo obrigatório ausente: ${_labelLoteColumn(column)}.';
    }
    return 'Campo obrigatório ausente.';
  }

  if (lower.contains('violates foreign key constraint') ||
      lower.contains('foreign key')) {
    if (keyColumn != null) {
      return 'Referência inválida no campo ${_labelLoteColumn(keyColumn)} (registro relacionado não encontrado).';
    }
    return 'Referência inválida em campo relacionado.';
  }

  return raw;
}

String? _extractErrorColumn(String lowerRaw) {
  final match = RegExp(r'column\s+"([^"]+)"').firstMatch(lowerRaw);
  return match?.group(1);
}

String? _extractKeyColumn(String lowerRaw) {
  final match = RegExp(r'key\s*\(([^\)]+)\)').firstMatch(lowerRaw);
  return match?.group(1)?.trim();
}

String _labelLoteColumn(String column) {
  switch (column) {
    case 'nome':
      return 'Nome do lote';
    case 'id_lote':
      return 'ID do lote';
    case 'id_propriedade':
      return 'Propriedade';
    case 'data_entrada_piquete':
      return 'Data de entrada no piquete';
    case 'data_saida_piquete':
      return 'Data de saída do piquete';
    case 'data_motivo':
      return 'Data do motivo';
    default:
      return column;
  }
}

// Função auxiliar para corrigir problemas de encoding (acentuação)
String _fixEncoding(String text) {
  try {
    // Heurística: corrige strings UTF-8 interpretadas como Latin-1.
    // Ex.: "FÃªmea" -> "Fêmea".
    if (!(text.contains('Ã') || text.contains('Â') || text.contains('�'))) {
      return text;
    }

    final bytes = latin1.encode(text);
    return utf8.decode(bytes, allowMalformed: true);
  } catch (e) {
    print('Erro ao corrigir encoding: $e');
    return text;
  }
}

// Função auxiliar para gerar id_reproducao único
String _generateIdReproducao() {
  const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final Random random = Random();

  return List.generate(20, (index) => chars[random.nextInt(chars.length)])
      .join();
}

// Função auxiliar para converter data de DD/MM/YYYY para YYYY-MM-DD
String? _convertDateFormat(String dateStr) {
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
        print('Data ISO inválida: $dateStr');
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
        print('Data BR inválida: $dateStr');
        return null;
      }
      return converted;
    }

    // Se não conseguir converter, retorna null
    print('Formato de data não reconhecido: $dateStr');
    return null;
  } catch (e) {
    print('Erro ao converter data: $dateStr - $e');
    return null;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
