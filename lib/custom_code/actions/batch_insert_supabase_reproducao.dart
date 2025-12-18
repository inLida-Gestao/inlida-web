// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class _RebanhoLookup {
  final Map<String, String> byNumero;
  final Map<String, String> byNumeroData;
  final Map<String, String> byComposite;
  final Map<String, String> byChip;

  const _RebanhoLookup({
    required this.byNumero,
    required this.byNumeroData,
    required this.byComposite,
    required this.byChip,
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

String _normalizeNumeroKey(String value) => value.trim();

String _normalizeChipKey(String value) => value.trim();

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

String _composeNumeroDataKey({
  required String numero,
  required String dataNascimento,
}) {
  return '${_normalizeNumeroKey(numero)}|$dataNascimento';
}

String _composeParentKey({
  required String numero,
  required String nome,
  required String dataNascimento,
  required String raca,
}) {
  return '${_normalizeNumeroKey(numero)}|${_normalizeLoteNome(nome)}|$dataNascimento|${_normalizeLoteNome(raca)}';
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

Future<_RebanhoLookup> _fetchRebanhoLookupFromDb(String idPropriedade) async {
  const pageSize = 1000;
  var from = 0;

  final byNumero = <String, String>{};
  final byNumeroData = <String, String>{};
  final byComposite = <String, String>{};
  final byChip = <String, String>{};

  while (true) {
    final res = await Supabase.instance.client
        .from('rebanho')
      .select('idRebanho,numeroAnimal,nome,dataNascimento,raca,chip,deletado')
        .eq('idPropriedade', idPropriedade)
        .range(from, from + pageSize - 1);

    final rows = (res as List).cast<dynamic>();
    if (rows.isEmpty) break;

    for (final rowAny in rows) {
      final row = Map<String, dynamic>.from(rowAny as Map);
      final deletado = row['deletado']?.toString();
      if (deletado != null && deletado.trim().toUpperCase() == 'SIM') continue;

      final id = _asNonEmptyString(row['idRebanho']);
      if (id == null) continue;

      final numero = _asNonEmptyString(row['numeroAnimal']);
      if (numero != null) {
        byNumero.putIfAbsent(_normalizeNumeroKey(numero), () => id);

        final dataNasc = _normalizeDateKey(row['dataNascimento']);
        if (dataNasc != null) {
          final key =
              _composeNumeroDataKey(numero: numero, dataNascimento: dataNasc);
          byNumeroData.putIfAbsent(key, () => id);
        }

        final nome = _asNonEmptyString(row['nome']);
        final raca = _asNonEmptyString(row['raca']);
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

      final chip = _asNonEmptyString(row['chip']);
      if (chip != null) {
        byChip.putIfAbsent(_normalizeChipKey(chip), () => id);
      }
    }

    if (rows.length < pageSize) break;
    from += pageSize;
  }

  return _RebanhoLookup(
    byNumero: byNumero,
    byNumeroData: byNumeroData,
    byComposite: byComposite,
    byChip: byChip,
  );
}

String? _resolveRebanhoId({
  required _RebanhoLookup lookup,
  String? numero,
  String? nome,
  String? raca,
  String? chip,
  dynamic dataNascimento,
}) {
  if (numero != null) {
    final dataNasc = _normalizeDateKey(dataNascimento);

    // Preferência: chave composta (numero + nome + data + raca)
    if (nome != null && raca != null && dataNasc != null) {
      final key = _composeParentKey(
        numero: _fixEncoding(numero),
        nome: _fixEncoding(nome),
        dataNascimento: dataNasc,
        raca: _fixEncoding(raca),
      );
      final resolved = lookup.byComposite[key];
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }

    if (dataNasc != null) {
      final key = _composeNumeroDataKey(
        numero: _normalizeNumeroKey(_fixEncoding(numero)),
        dataNascimento: dataNasc,
      );
      final resolved = lookup.byNumeroData[key];
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }

    final resolved = lookup.byNumero[_normalizeNumeroKey(_fixEncoding(numero))];
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }

  // Último fallback: chip
  if (chip != null) {
    final resolved = lookup.byChip[_normalizeChipKey(_fixEncoding(chip))];
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }

  return null;
}

int? _parseIntSafe(dynamic value) {
  if (_isMissingValue(value)) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s) ?? double.tryParse(s.replaceAll(',', '.'))?.round();
}

double? _parseDoubleSafe(dynamic value) {
  if (_isMissingValue(value)) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  final normalized = s.contains(',') ? s.replaceAll('.', '').replaceAll(',', '.') : s;
  return double.tryParse(normalized);
}

Map<String, dynamic> _prepareReproducaoRecord(
  Map<String, dynamic> record,
  String idPropriedade,
  Map<String, String> loteNomeToIdLote,
  _RebanhoLookup rebanhoLookup,
  List<String> dateFields,
) {
  final data = Map<String, dynamic>.from(record);

  // Remove campos gerados automaticamente pelo Supabase
  data.remove('id');
  data.remove('created_at');
  data.remove('updated_at');
  data.remove('deletado');

  // Gerar id_reproducao único SOMENTE se não existir ou estiver vazio
  if (_isMissingValue(data['id_reproducao'])) {
    data['id_reproducao'] = _generateIdReproducao();
  }

  // Garantir que id_propriedade está presente
  data['id_propriedade'] = idPropriedade;

  // Limpar valores "null" string e vazios para null real
  final Map<String, dynamic> cleanData = {};
  data.forEach((key, value) {
    if (_isMissingValue(value)) {
      cleanData[key] = null;
    } else if (value is String && value.trim().isEmpty) {
      cleanData[key] = null;
    } else {
      // Corrigir encoding de acentuação
      cleanData[key] = value is String ? _fixEncoding(value) : value;
    }
  });

  // Campo ressinc/parida: defaults
  cleanData['ressinc'] ??= 'NAO';
  cleanData['parida'] ??= 'NAO';

  // Normalizar numéricos principais (caso venham como string)
  if (cleanData.containsKey('score_corporal')) {
    cleanData['score_corporal'] = _parseDoubleSafe(cleanData['score_corporal']);
  }
  if (cleanData.containsKey('partida_semen')) {
    cleanData['partida_semen'] = _parseIntSafe(cleanData['partida_semen']);
  }

  // Converter campos de data de DD/MM/YYYY para YYYY-MM-DD
  for (final dateField in dateFields) {
    if (cleanData[dateField] != null) {
      cleanData[dateField] = _convertDateFormat(cleanData[dateField].toString());
    }
  }

  // Calcular previsao_parto automaticamente se data_inseminacao estiver preenchida e previsao_parto estiver vazio
  if (cleanData['previsao_parto'] == null &&
      cleanData['data_inseminacao'] != null &&
      cleanData['data_inseminacao'].toString().isNotEmpty) {
    cleanData['previsao_parto'] = _addDaysToDate(cleanData['data_inseminacao'].toString(), 295);
  }

  // Resolver id_lote pelo loteNome (se faltar)
  if (_isMissingValue(cleanData['id_lote'])) {
    final loteNome = _asNonEmptyString(cleanData['loteNome']);
    if (loteNome != null) {
      final resolved = loteNomeToIdLote[_normalizeLoteNome(loteNome)];
      if (resolved != null && resolved.isNotEmpty) {
        cleanData['id_lote'] = resolved;
      }
    }
  }

  // Resolver id_rebanho_matriz (se faltar)
  if (_isMissingValue(cleanData['id_rebanho_matriz'])) {
    final resolved = _resolveRebanhoId(
      lookup: rebanhoLookup,
      numero: _asNonEmptyString(cleanData['numMatriz']),
      nome: _asNonEmptyString(cleanData['nomeMatriz']),
      raca: _asNonEmptyString(cleanData['racaMatriz']),
      chip: _asNonEmptyString(cleanData['chipMatriz']),
      dataNascimento: cleanData['nascimentoMatriz'],
    );
    if (resolved != null) cleanData['id_rebanho_matriz'] = resolved;
  }

  // Resolver id_rebanho_reprodutor (se faltar)
  if (_isMissingValue(cleanData['id_rebanho_reprodutor'])) {
    final resolved = _resolveRebanhoId(
      lookup: rebanhoLookup,
      numero: _asNonEmptyString(cleanData['numReprodutor']),
      nome: _asNonEmptyString(cleanData['nomeReprodutor']),
      raca: _asNonEmptyString(cleanData['racaReprodutor']),
      chip: _asNonEmptyString(cleanData['chipReprodutor']),
      dataNascimento: cleanData['nascimentoReprodutor'],
    );
    if (resolved != null) cleanData['id_rebanho_reprodutor'] = resolved;
  }

  return cleanData;
}

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

    // Cache para resolver ids
    final loteNomeToIdLote = await _fetchLoteNomeToIdLoteMap(idPropriedade);
    final rebanhoLookup = await _fetchRebanhoLookupFromDb(idPropriedade);

    // Processar em chunks para melhor performance
    for (int i = 0; i < records.length; i += chunkSize) {
      final end =
          (i + chunkSize < records.length) ? i + chunkSize : records.length;
      final chunk = records.sublist(i, end);

      try {
        // Preparar dados para inserção
        final List<Map<String, dynamic>> cleanRecords = [];

        for (final record in chunk) {
          final prepared = _prepareReproducaoRecord(
            Map<String, dynamic>.from(record as Map),
            idPropriedade,
            loteNomeToIdLote,
            rebanhoLookup,
            dateFields,
          );
          cleanRecords.add(prepared);
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
            final cleanData = _prepareReproducaoRecord(
              Map<String, dynamic>.from(record as Map),
              idPropriedade,
              loteNomeToIdLote,
              rebanhoLookup,
              dateFields,
            );
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
    // Heurística: tenta corrigir strings UTF-8 que foram interpretadas como Latin-1.
    // Ex.: "SÃ£o" -> "São".
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
