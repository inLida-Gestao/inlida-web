// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> batchInsertSupabaseRebanho(
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
      'dataNascimento',
      'dataEntradaLote',
      'dataDesmama',
      'dataAcao',
      'dataUltimaPesagem',
      'dataVenda',
      'movimentacao_entrada',
      'dataNascMatriz',
      'dataNascReprodutor',
      'movimentacao_saida',
      'data_morte',
    ];

    // Processar em chunks para melhor performance
    for (int i = 0; i < records.length; i += chunkSize) {
      final end =
          (i + chunkSize < records.length) ? i + chunkSize : records.length;
      final chunk = records.sublist(i, end);

      try {
        // Preparar dados para inserção
        final List<Map<String, dynamic>> cleanRecords = [];
        final List<Map<String, dynamic>> pesagensToInsert = [];

        for (final record in chunk) {
          final Map<String, dynamic> data = Map<String, dynamic>.from(record);

          // Remove campos gerados automaticamente pelo Supabase
          data.remove('id');
          data.remove('created_at');
          data.remove('updated_at');
          data.remove('deletado');
          data.remove('tipo');

          // Gerar id_reproducao único SOMENTE se não existir ou estiver vazio
          if (data['idRebanho'] == null ||
              data['idRebanho'].toString().trim().isEmpty ||
              data['idRebanho'] == 'null') {
            data['idRebanho'] = _generateIdReproducao();
          }

          // Armazenar o idRebanho para uso posterior
          final String idRebanho = data['idRebanho'];

          // Garantir que id_propriedade está presente
          data['idPropriedade'] = idPropriedade;

          // Capturar valores de peso ANTES de limpar
          final pesoAtual = data['pesoAtual'];
          final pesoNascimento = data['pesoNascimento'];
          final pesoDesmama = data['pesoDesmama'];
          final dataNascimento = data['dataNascimento'];
          final dataDesmama = data['dataDesmama'];
          final dataUltimaPesagem = data['dataUltimaPesagem'];

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

          // Preparar registros de pesagem
          _preparePesagemRecords(
            pesagensToInsert,
            idRebanho,
            idPropriedade,
            pesoAtual,
            pesoNascimento,
            pesoDesmama,
            cleanData['dataNascimento'],
            cleanData['dataDesmama'],
            cleanData['dataUltimaPesagem'],
          );
        }

        // Inserir em lote no Supabase
        // Usando upsert com id_reproducao como chave única
        await Supabase.instance.client.from('rebanho').upsert(
              cleanRecords,
              onConflict: 'idRebanho',
              ignoreDuplicates: false,
            );

        print(
            'Chunk ${(i / chunkSize).floor() + 1}: ${chunk.length} registros inseridos');

        // Inserir pesagens se houver
        if (pesagensToInsert.isNotEmpty) {
          await _insertPesagens(pesagensToInsert);
          print('${pesagensToInsert.length} pesagens inseridas para o chunk');
        }
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
            data.remove('tipo');

            // Gerar id_reproducao único SOMENTE se não existir ou estiver vazio
            if (data['idRebanho'] == null ||
                data['idRebanho'].toString().trim().isEmpty ||
                data['idRebanho'] == 'null') {
              data['idRebanho'] = _generateIdReproducao();
            }

            final String idRebanho = data['idRebanho'];
            data['idPropriedade'] = idPropriedade;

            // Capturar valores de peso
            final pesoAtual = data['pesoAtual'];
            final pesoNascimento = data['pesoNascimento'];
            final pesoDesmama = data['pesoDesmama'];
            final dataNascimento = data['dataNascimento'];
            final dataDesmama = data['dataDesmama'];
            final dataUltimaPesagem = data['dataUltimaPesagem'];

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
                .from('rebanho')
                .upsert(cleanData, onConflict: 'idRebanho');

            // Inserir pesagens individualmente
            final List<Map<String, dynamic>> individualPesagens = [];
            _preparePesagemRecords(
              individualPesagens,
              idRebanho,
              idPropriedade,
              pesoAtual,
              pesoNascimento,
              pesoDesmama,
              cleanData['dataNascimento'],
              cleanData['dataDesmama'],
              cleanData['dataUltimaPesagem'],
            );

            if (individualPesagens.isNotEmpty) {
              await _insertPesagens(individualPesagens);
            }
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

// Função auxiliar para preparar registros de pesagem
void _preparePesagemRecords(
  List<Map<String, dynamic>> pesagensToInsert,
  String idRebanho,
  String idPropriedade,
  dynamic pesoAtual,
  dynamic pesoNascimento,
  dynamic pesoDesmama,
  String? dataNascimento,
  String? dataDesmama,
  String? dataUltimaPesagem,
) {
  final hoje = DateTime.now().toIso8601String().split('T')[0];

  // Peso de Nascimento
  if (_isValidPeso(pesoNascimento)) {
    pesagensToInsert.add({
      'idRebanho': idRebanho,
      'id_propriedade': idPropriedade,
      'tipo': 'Nascimento',
      'peso': _parsePeso(pesoNascimento),
      'dataPesagem': dataNascimento ?? hoje,
      'deletado': null,
    });
  }

  // Peso de Desmama
  if (_isValidPeso(pesoDesmama)) {
    pesagensToInsert.add({
      'idRebanho': idRebanho,
      'id_propriedade': idPropriedade,
      'tipo': 'Desmama',
      'peso': _parsePeso(pesoDesmama),
      'dataPesagem': dataDesmama ?? hoje,
      'deletado': null,
    });
  }

  // Peso Atual
  if (_isValidPeso(pesoAtual)) {
    pesagensToInsert.add({
      'idRebanho': idRebanho,
      'id_propriedade': idPropriedade,
      'tipo': 'Atual',
      'peso': _parsePeso(pesoAtual),
      'dataPesagem': dataUltimaPesagem ?? hoje,
      'deletado': null,
    });
  }
}

// Função auxiliar para inserir pesagens
Future<void> _insertPesagens(List<Map<String, dynamic>> pesagens) async {
  try {
    await Supabase.instance.client.from('historico_pesagens').insert(pesagens);
  } catch (e) {
    print('Erro ao inserir pesagens: $e');
    // Tentar inserir uma por uma em caso de erro
    for (final pesagem in pesagens) {
      try {
        await Supabase.instance.client
            .from('historico_pesagens')
            .insert(pesagem);
      } catch (individualError) {
        print('Erro ao inserir pesagem individual: $individualError');
      }
    }
  }
}

// Função auxiliar para validar se o peso é válido
bool _isValidPeso(dynamic peso) {
  if (peso == null) return false;
  if (peso == "null" || peso == "undefined" || peso == "") return false;
  if (peso is String && peso.trim().isEmpty) return false;

  try {
    final pesoNum = _parsePeso(peso);
    return pesoNum != null && pesoNum > 0;
  } catch (e) {
    return false;
  }
}

// Função auxiliar para converter peso para número
num? _parsePeso(dynamic peso) {
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
    print('Erro ao converter peso: $peso - $e');
    return null;
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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
