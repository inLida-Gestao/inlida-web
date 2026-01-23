// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class _RebanhoParentLookup {
  final Map<String, String> byNumero;
  final Map<String, String> byNumeroData;
  final Map<String, String> byComposite;

  const _RebanhoParentLookup({
    required this.byNumero,
    required this.byNumeroData,
    required this.byComposite,
  });
}

bool _isMissingValue(dynamic value) {
  if (value == null) return true;
  final s = value.toString();
  return s.trim().isEmpty || s == 'null' || s == 'undefined';
}

String? _asNonEmptyString(dynamic value) {
  if (_isMissingValue(value)) return null;
  return value.toString();
}

String _normalizeNumeroKey(String value) {
  return value.trim();
}

String? _normalizeDateKey(dynamic value) {
  final raw = _asNonEmptyString(value);
  if (raw == null) return null;

  final fixed = _fixEncoding(raw);
  final converted = _convertDateFormat(fixed);
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

String _composeParentKey({
  required String numero,
  required String nome,
  required String dataNascimento,
  required String raca,
}) {
  return '${_normalizeNumeroKey(numero)}|${_normalizeLoteNome(nome)}|$dataNascimento|${_normalizeLoteNome(raca)}';
}

String _composeNumeroDataKey({
  required String numero,
  required String dataNascimento,
}) {
  return '${_normalizeNumeroKey(numero)}|$dataNascimento';
}

void _ensureIdRebanhoForRecords(List<dynamic> records) {
  for (var i = 0; i < records.length; i++) {
    final record = records[i];
    if (record is! Map) continue;
    final map = Map<String, dynamic>.from(record);

    if (_isMissingValue(map['idRebanho'])) {
      map['idRebanho'] = _generateIdReproducao();
    }

    records[i] = map;
  }
}

_RebanhoParentLookup _buildLookupFromImportedRecords(List<dynamic> records) {
  final byNumero = <String, String>{};
  final byNumeroData = <String, String>{};
  final byComposite = <String, String>{};

  for (final record in records) {
    if (record is! Map) continue;
    final map = Map<String, dynamic>.from(record);

    final id = _asNonEmptyString(map['idRebanho']);
    if (id == null) continue;

    final numero = _asNonEmptyString(map['numeroAnimal']);
    if (numero == null) continue;

    final numeroKey = _normalizeNumeroKey(_fixEncoding(numero));
    byNumero.putIfAbsent(numeroKey, () => id);

    final nome = _asNonEmptyString(map['nome']);
    final raca = _asNonEmptyString(map['raca']);
    final dataNasc = _normalizeDateKey(map['dataNascimento']);

    if (dataNasc != null) {
      final key = _composeNumeroDataKey(
        numero: _fixEncoding(numero),
        dataNascimento: dataNasc,
      );
      byNumeroData.putIfAbsent(key, () => id);
    }

    if (nome != null && raca != null && dataNasc != null) {
      final key = _composeParentKey(
        numero: _fixEncoding(numero),
        nome: _fixEncoding(nome),
        dataNascimento: dataNasc,
        raca: _fixEncoding(raca),
      );
      byComposite.putIfAbsent(key, () => id);
    }
  }

  return _RebanhoParentLookup(
    byNumero: byNumero,
    byNumeroData: byNumeroData,
    byComposite: byComposite,
  );
}

Future<_RebanhoParentLookup> _fetchLookupFromDb(String idPropriedade) async {
  const pageSize = 1000;
  var from = 0;

  final byNumero = <String, String>{};
  final byNumeroData = <String, String>{};
  final byComposite = <String, String>{};

  while (true) {
    final res = await Supabase.instance.client
        .from('rebanho')
        .select('idRebanho,numeroAnimal,nome,dataNascimento,raca,deletado')
        .eq('idPropriedade', idPropriedade)
        .range(from, from + pageSize - 1);

    final rows = (res as List).cast<dynamic>();
    if (rows.isEmpty) break;

    for (final rowAny in rows) {
      final row = Map<String, dynamic>.from(rowAny as Map);
      final deletado = row['deletado']?.toString();
      if (deletado != null && deletado.trim().toUpperCase() == 'SIM') continue;

      final id = _asNonEmptyString(row['idRebanho']);
      final numero = _asNonEmptyString(row['numeroAnimal']);
      if (id == null || numero == null) continue;

      final numeroKey = _normalizeNumeroKey(numero);
      byNumero.putIfAbsent(numeroKey, () => id);

      final nome = _asNonEmptyString(row['nome']);
      final raca = _asNonEmptyString(row['raca']);
      final dataNasc = _normalizeDateKey(row['dataNascimento']);

      if (dataNasc != null) {
        final key = _composeNumeroDataKey(
          numero: numero,
          dataNascimento: dataNasc,
        );
        byNumeroData.putIfAbsent(key, () => id);
      }

      if (nome != null && raca != null && dataNasc != null) {
        final key = _composeParentKey(
          numero: numero,
          nome: nome,
          dataNascimento: dataNasc,
          raca: raca,
        );
        byComposite.putIfAbsent(key, () => id);
      }
    }

    if (rows.length < pageSize) break;
    from += pageSize;
  }

  return _RebanhoParentLookup(
    byNumero: byNumero,
    byNumeroData: byNumeroData,
    byComposite: byComposite,
  );
}

Future<_RebanhoParentLookup> _buildParentLookup(
  List<dynamic> records,
  String idPropriedade,
) async {
  final db = await _fetchLookupFromDb(idPropriedade);
  final imported = _buildLookupFromImportedRecords(records);

  final mergedByNumero = Map<String, String>.from(db.byNumero);
  imported.byNumero.forEach((k, v) {
    mergedByNumero.putIfAbsent(k, () => v);
  });

  final mergedByNumeroData = Map<String, String>.from(db.byNumeroData);
  imported.byNumeroData.forEach((k, v) {
    mergedByNumeroData.putIfAbsent(k, () => v);
  });

  final mergedByComposite = Map<String, String>.from(db.byComposite);
  imported.byComposite.forEach((k, v) {
    mergedByComposite.putIfAbsent(k, () => v);
  });

  return _RebanhoParentLookup(
    byNumero: mergedByNumero,
    byNumeroData: mergedByNumeroData,
    byComposite: mergedByComposite,
  );
}

void _fillParentIdsFromKeys(
  Map<String, dynamic> data,
  _RebanhoParentLookup lookup,
) {
  // Matriz
  if (_isMissingValue(data['rebanhoIdMatriz'])) {
    final num = _asNonEmptyString(data['numeroMatriz']);
    final nome = _asNonEmptyString(data['nomeMatriz']);
    final raca = _asNonEmptyString(data['racaMatriz']);
    final dataNasc = _normalizeDateKey(data['dataNascMatriz']);

    if (num != null) {
      final onlyNumero = nome == null && raca == null && dataNasc == null;
      String? resolved;
      if (!onlyNumero && nome != null && raca != null && dataNasc != null) {
        final key = _composeParentKey(
          numero: _fixEncoding(num),
          nome: _fixEncoding(nome),
          dataNascimento: dataNasc,
          raca: _fixEncoding(raca),
        );
        resolved = lookup.byComposite[key];
      }

      if (resolved == null && dataNasc != null) {
        final key = _composeNumeroDataKey(
          numero: _fixEncoding(num),
          dataNascimento: dataNasc,
        );
        resolved = lookup.byNumeroData[key];
      }

      resolved ??= lookup.byNumero[_normalizeNumeroKey(_fixEncoding(num))];
      if (resolved != null && resolved.isNotEmpty) {
        data['rebanhoIdMatriz'] = resolved;
      }
    }
  }

  // Reprodutor
  if (_isMissingValue(data['rebanhoIdReprodutor'])) {
    final num = _asNonEmptyString(data['numeroReprodutor']);
    final nome = _asNonEmptyString(data['nomeReprodutor']);
    final raca = _asNonEmptyString(data['racaReprodutor']);
    final dataNasc = _normalizeDateKey(data['dataNascReprodutor']);

    if (num != null) {
      final onlyNumero = nome == null && raca == null && dataNasc == null;
      String? resolved;
      if (!onlyNumero && nome != null && raca != null && dataNasc != null) {
        final key = _composeParentKey(
          numero: _fixEncoding(num),
          nome: _fixEncoding(nome),
          dataNascimento: dataNasc,
          raca: _fixEncoding(raca),
        );
        resolved = lookup.byComposite[key];
      }

      if (resolved == null && dataNasc != null) {
        final key = _composeNumeroDataKey(
          numero: _fixEncoding(num),
          dataNascimento: dataNasc,
        );
        resolved = lookup.byNumeroData[key];
      }

      resolved ??= lookup.byNumero[_normalizeNumeroKey(_fixEncoding(num))];
      if (resolved != null && resolved.isNotEmpty) {
        data['rebanhoIdReprodutor'] = resolved;
      }
    }
  }
}

Future<Map<String, String>> _fetchLoteNomeToIdLoteMap(
  String idPropriedade,
) async {
  try {
    final res = await Supabase.instance.client
        .from('lotes')
        .select('id_lote,nome,deletado')
        .eq('id_propriedade', idPropriedade);

    final map = <String, String>{};
    for (final row in (res as List)) {
      final nome = row['nome']?.toString();
      final idLote = row['id_lote']?.toString();
      final deletado = row['deletado']?.toString();

      if (deletado != null && deletado.trim().toUpperCase() == 'SIM') continue;
      if (nome == null || nome.trim().isEmpty) continue;
      if (idLote == null || idLote.trim().isEmpty) continue;
      map[_normalizeLoteNome(nome)] = idLote;
    }
    return map;
  } catch (e) {
    print('Falha ao carregar lotes para vincular por nome: $e');
    return <String, String>{};
  }
}

String _normalizeLoteNome(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAllMapped(
        RegExp(r'[\u00C0-\u017F]'),
        (m) => _stripDiacritics(m[0]!),
      )
      .replaceAll(RegExp(r'\s+'), ' ');
}

String _stripDiacritics(String ch) {
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

Future<bool> batchInsertSupabaseRebanho(
  List<dynamic> records,
  String idPropriedade,
) async {
  if (records.isEmpty) return true;

  try {
    // Configurações de performance
    const int chunkSize = 500; // Tamanho do lote (ajuste conforme necessário)

    // Garante que todos os registros tenham idRebanho antes do processamento,
    // para permitir referenciar matriz/reprodutor dentro do mesmo CSV.
    _ensureIdRebanhoForRecords(records);

    // Cache de lotes para resolver loteNome -> loteID (id_lote)
    // O usuário geralmente só tem o nome do lote no CSV.
    final Map<String, String> loteNomeToIdLote =
        await _fetchLoteNomeToIdLoteMap(idPropriedade);

    // Cache de animais para resolver matriz/reprodutor -> idRebanho
    final _RebanhoParentLookup parentLookup =
        await _buildParentLookup(records, idPropriedade);

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

          // Resolver loteID pelo nome do lote (quando loteID não vier na planilha)
          final dynamic loteIdRaw = data['loteID'];
          final dynamic loteNomeRaw = data['loteNome'];

          final bool missingLoteId = loteIdRaw == null ||
              loteIdRaw.toString().trim().isEmpty ||
              loteIdRaw == 'null';
          final bool hasLoteNome = loteNomeRaw != null &&
              loteNomeRaw.toString().trim().isNotEmpty &&
              loteNomeRaw != 'null';

          if (missingLoteId && hasLoteNome) {
            final normalizedLoteNome = _normalizeLoteNome(
              _fixEncoding(loteNomeRaw.toString()),
            );
            final resolvedIdLote = loteNomeToIdLote[normalizedLoteNome];
            if (resolvedIdLote != null && resolvedIdLote.isNotEmpty) {
              data['loteID'] = resolvedIdLote;
            }
          }

          // Resolver rebanhoIdMatriz/rebanhoIdReprodutor a partir dos campos-chave
          _fillParentIdsFromKeys(data, parentLookup);

          // Capturar valores de peso ANTES de limpar
          final pesoAtual = data['pesoAtual'];
          final pesoNascimento = data['pesoNascimento'];
          final pesoDesmama = data['pesoDesmama'];

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

            // Resolver loteID pelo nome do lote (quando loteID não vier na planilha)
            final dynamic loteIdRaw = data['loteID'];
            final dynamic loteNomeRaw = data['loteNome'];

            final bool missingLoteId = loteIdRaw == null ||
                loteIdRaw.toString().trim().isEmpty ||
                loteIdRaw == 'null';
            final bool hasLoteNome = loteNomeRaw != null &&
                loteNomeRaw.toString().trim().isNotEmpty &&
                loteNomeRaw != 'null';

            if (missingLoteId && hasLoteNome) {
              final normalizedLoteNome = _normalizeLoteNome(
                _fixEncoding(loteNomeRaw.toString()),
              );
              final resolvedIdLote = loteNomeToIdLote[normalizedLoteNome];
              if (resolvedIdLote != null && resolvedIdLote.isNotEmpty) {
                data['loteID'] = resolvedIdLote;
              }
            }

            // Resolver rebanhoIdMatriz/rebanhoIdReprodutor a partir dos campos-chave
            _fillParentIdsFromKeys(data, parentLookup);

            // Capturar valores de peso
            final pesoAtual = data['pesoAtual'];
            final pesoNascimento = data['pesoNascimento'];
            final pesoDesmama = data['pesoDesmama'];

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
    // Heurística: corrige strings UTF-8 interpretadas como Latin-1.
    // Ex.: "FÃªmea" -> "Fêmea".
    if (!_looksMojibake(text)) {
      return text;
    }

    final originalScore = _mojibakeScore(text);
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

    if (candidate != null && _mojibakeScore(candidate) < originalScore) {
      return candidate;
    }
    return text;
  } catch (e) {
    print('Erro ao corrigir encoding: $e');
    return text;
  }
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
