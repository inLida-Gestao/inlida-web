// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> batchInsertSupabaseReproducao(
  List<dynamic> records,
  String idPropriedade,
) async {
  if (records.isEmpty) return true;

  try {
    // Configurações de performance
    const int chunkSize = 500; // Tamanho do lote (ajuste conforme necessário)

    // Campos de data que precisam de conversão DD/MM/YYYY -> YYYY-MM-DD
    // (created_at e updated_at são gerados pelo Supabase automaticamente)
    const dateFields = [
      'data_inseminacao',
      'data_partida_semen',
      'previsao_parto',
      'data_inicial',
      'data_final',
      'nascimentoMatriz',
      'nascimentoReprodutor',
      'data_status',
      'data_parto',
    ];

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
          if (data['id_reproducao'] == null ||
              data['id_reproducao'].toString().trim().isEmpty ||
              data['id_reproducao'] == 'null') {
            data['id_reproducao'] = _generateIdReproducao();
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

          // Campo ressinc: se estiver vazio/null, define como "NAO"
          if (cleanData['ressinc'] == null) {
            cleanData['ressinc'] = 'NAO';
          }

          if (cleanData['parida'] == null) {
            cleanData['parida'] = 'NAO';
          }

          // Converter campos de data de DD/MM/YYYY para YYYY-MM-DD
          for (final dateField in dateFields) {
            if (cleanData[dateField] != null) {
              cleanData[dateField] =
                  _convertDateFormat(cleanData[dateField].toString());
            }
          }

          // Calcular previsao_parto automaticamente se data_inseminacao estiver preenchida
          if (cleanData['data_inseminacao'] != null &&
              cleanData['data_inseminacao'].toString().isNotEmpty) {
            cleanData['previsao_parto'] =
                _addDaysToDate(cleanData['data_inseminacao'].toString(), 295);
          }

          cleanRecords.add(cleanData);
        }

        // Inserir em lote no Supabase
        // Usando upsert com id_reproducao como chave única
        await Supabase.instance.client.from('reproducao').upsert(
              cleanRecords,
              onConflict: 'id_reproducao',
              ignoreDuplicates: false,
            );

        print(
            'Chunk ${(i / chunkSize).floor() + 1}: ${chunk.length} registros inseridos');
      } catch (chunkError) {
        print('Erro no chunk ${(i / chunkSize).floor() + 1}: $chunkError');

        // Tentar inserir registro por registro em caso de erro no chunk
        for (final record in chunk) {
          try {
            final Map<String, dynamic> data = Map<String, dynamic>.from(record);

            // Remove campos gerados automaticamente pelo Supabase
            data.remove('id');
            data.remove('created_at');
            data.remove('updated_at');
            data.remove('deletado');
            data.remove('categoria');

            // Gerar id_reproducao único SOMENTE se não existir ou estiver vazio
            if (data['id_reproducao'] == null ||
                data['id_reproducao'].toString().trim().isEmpty ||
                data['id_reproducao'] == 'null') {
              data['id_reproducao'] = _generateIdReproducao();
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

            // Campo ressinc: se estiver vazio/null, define como "NAO"
            if (cleanData['ressinc'] == null) {
              cleanData['ressinc'] = 'NAO';
            }

            if (cleanData['parida'] == null) {
              cleanData['parida'] = 'NAO';
            }

            // Converter campos de data de DD/MM/YYYY para YYYY-MM-DD
            for (final dateField in dateFields) {
              if (cleanData[dateField] != null) {
                cleanData[dateField] =
                    _convertDateFormat(cleanData[dateField].toString());
              }
            }

            // Calcular previsao_parto automaticamente se data_inseminacao estiver preenchida
            if (cleanData['data_inseminacao'] != null &&
                cleanData['data_inseminacao'].toString().isNotEmpty) {
              cleanData['previsao_parto'] =
                  _addDaysToDate(cleanData['data_inseminacao'].toString(), 295);
            }

            await Supabase.instance.client
                .from('reproducao')
                .upsert(cleanData, onConflict: 'id_reproducao');
          } catch (recordError) {
            print('Erro ao inserir registro individual: $recordError');
            return false;
          }
        }
      }
    }

    return true;
  } catch (e, stack) {
    print('Erro geral no batch insert: $e');
    print(stack);
    return false;
  }
}

// Função auxiliar para corrigir problemas de encoding (acentuação)
String _fixEncoding(String text) {
  try {
    // Mapa de correções comuns de encoding UTF-8 mal interpretado
    final Map<String, String> corrections = {
      'Ã§': 'ç',
      'Ã£': 'ã',
      'Ã¡': 'á',
      'Ã©': 'é',
      'Ã­': 'í',
      'Ã³': 'ó',
      'Ãº': 'ú',
      'Ã¢': 'â',
      'Ãª': 'ê',
      'Ã´': 'ô',
      'Ã': 'à',
      'Ãµ': 'õ',
      'Ã¼': 'ü',
      'Ã': 'Á',
      'Ã‰': 'É',
      'Ã': 'Í',
      'Ã"': 'Ó',
      'Ãš': 'Ú',
      'Ã‚': 'Â',
      'ÃŠ': 'Ê',
      'Ã"': 'Ô',
      'Ã€': 'À',
      'Ã•': 'Õ',
      'Ãœ': 'Ü',
      'Ã‡': 'Ç',
    };

    String fixed = text;
    corrections.forEach((wrong, correct) {
      fixed = fixed.replaceAll(wrong, correct);
    });

    return fixed;
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

    // Verificar se já está no formato YYYY-MM-DD
    if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(dateStr)) {
      return dateStr.split(' ')[0]; // Remove hora se existir
    }

    // Verificar se está no formato DD/MM/YYYY
    if (RegExp(r'^\d{2}[/\-]\d{2}[/\-]\d{4}').hasMatch(dateStr)) {
      final parts = dateStr.split(RegExp(r'[/\-]'));
      if (parts.length >= 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    }

    // Se não conseguir converter, retorna null
    print('Formato de data não reconhecido: $dateStr');
    return null;
  } catch (e) {
    print('Erro ao converter data: $dateStr - $e');
    return null;
  }
}

// Função auxiliar para adicionar dias a uma data (formato YYYY-MM-DD)
String? _addDaysToDate(String dateStr, int days) {
  try {
    // Parse da data no formato YYYY-MM-DD
    final parts = dateStr.split('-');
    if (parts.length != 3) return null;

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    // Criar DateTime e adicionar dias
    final date = DateTime(year, month, day);
    final newDate = date.add(Duration(days: days));

    // Retornar no formato YYYY-MM-DD
    return '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';
  } catch (e) {
    print('Erro ao adicionar dias à data: $dateStr - $e');
    return null;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
