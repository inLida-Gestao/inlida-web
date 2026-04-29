// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class _PesagemRebanhoLookup {
  final Map<String, _AnimalInfo> byFiveFields;
  final Map<String, _AnimalInfo> byNumeroNomeDataRaca;
  final Map<String, _AnimalInfo> byNumeroData;
  final Map<String, _AnimalInfo> byNumero;
  final Map<String, _AnimalInfo> byChip;

  const _PesagemRebanhoLookup({
    required this.byFiveFields,
    required this.byNumeroNomeDataRaca,
    required this.byNumeroData,
    required this.byNumero,
    required this.byChip,
  });
}

class _AnimalInfo {
  final String idRebanho;
  final String? numeroAnimal;
  final String? nome;
  final String? dataNascimento;
  final String? raca;
  final String? sexo;

  const _AnimalInfo({
    required this.idRebanho,
    this.numeroAnimal,
    this.nome,
    this.dataNascimento,
    this.raca,
    this.sexo,
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

String _normalize(String value) {
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
    case 'á': case 'à': case 'â': case 'ã': case 'ä': case 'å':
    case 'Á': case 'À': case 'Â': case 'Ã': case 'Ä': case 'Å':
      return 'a';
    case 'é': case 'è': case 'ê': case 'ë':
    case 'É': case 'È': case 'Ê': case 'Ë':
      return 'e';
    case 'í': case 'ì': case 'î': case 'ï':
    case 'Í': case 'Ì': case 'Î': case 'Ï':
      return 'i';
    case 'ó': case 'ò': case 'ô': case 'õ': case 'ö':
    case 'Ó': case 'Ò': case 'Ô': case 'Õ': case 'Ö':
      return 'o';
    case 'ú': case 'ù': case 'û': case 'ü':
    case 'Ú': case 'Ù': case 'Û': case 'Ü':
      return 'u';
    case 'ç': case 'Ç':
      return 'c';
    case 'ñ': case 'Ñ':
      return 'n';
    default:
      return ch;
  }
}

String _fixEncoding(String text) {
  try {
    final looksLikeMojibake = text.contains('Ã') || text.contains('Â ');
    if (!looksLikeMojibake) return text;

    late final List<int> bytes;
    try {
      bytes = latin1.encode(text);
    } catch (_) {
      return text;
    }

    final decoded = utf8.decode(bytes);
    final beforeScore = _mojibakeScore(text);
    final afterScore = _mojibakeScore(decoded);

    if (afterScore < beforeScore && !decoded.contains('�')) {
      return decoded;
    }
    return text;
  } catch (_) {
    return text;
  }
}

int _mojibakeScore(String s) {
  var score = 0;
  const patterns = ['Ã', 'Â ', 'Ã¡', 'Ã¢', 'Ã£', 'Ã©', 'Ãª', 'Ã­', 'Ã³', 'Ã´', 'Ãµ', 'Ãº', 'Ã§'];
  for (final p in patterns) {
    if (s.contains(p)) score += 3;
  }
  if (s.contains('�')) score += 10;
  return score;
}

String? _normalizeDateKey(dynamic value) {
  final raw = _asNonEmptyString(value);
  if (raw == null) return null;

  final fixed = _fixEncoding(raw);
  final converted = _convertDateFormat(fixed);
  if (converted != null) return converted;

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

String? _convertDateFormat(String dateStr) {
  if (dateStr.isEmpty) return null;
  try {
    dateStr = dateStr.trim();

    final isoMatch =
        RegExp(r'^(\d{4}-\d{2}-\d{2})(?:\s+.*)?$').firstMatch(dateStr);
    if (isoMatch != null) {
      final isoDate = isoMatch.group(1)!;
      if (DateTime.tryParse(isoDate) == null) return null;
      return isoDate;
    }

    final brMatch = RegExp(r'^(\d{2})[/\-](\d{2})[/\-](\d{4})(?:\s+.*)?$')
        .firstMatch(dateStr);
    if (brMatch != null) {
      final day = brMatch.group(1)!;
      final month = brMatch.group(2)!;
      final year = brMatch.group(3)!;
      final converted = '$year-$month-$day';
      if (DateTime.tryParse(converted) == null) return null;
      return converted;
    }

    return null;
  } catch (_) {
    return null;
  }
}

double? _parseDoubleSafe(dynamic value) {
  if (_isMissingValue(value)) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  final normalized =
      s.contains(',') ? s.replaceAll('.', '').replaceAll(',', '.') : s;
  return double.tryParse(normalized);
}

String _normalizeTipoPesagem(dynamic value) {
  final tipo = _fixEncoding((value ?? 'Atual').toString().trim());
  return tipo.isEmpty ? 'Atual' : tipo;
}

String _composePesagemDedupKey({
  required String idRebanho,
  required String tipo,
  required String? dataPesagem,
  required double? peso,
}) =>
    '$idRebanho|$tipo|${dataPesagem ?? ''}|${peso?.toStringAsFixed(6) ?? ''}';

String _nextIsoDate(String isoDate) {
  final parsed = DateTime.parse(isoDate);
  return parsed.add(const Duration(days: 1)).toIso8601String().split('T').first;
}

Future<bool> _pesagemAtivaJaExiste({
  required String idRebanho,
  required String tipo,
  required String? dataPesagem,
  required double? peso,
}) async {
  if (idRebanho.trim().isEmpty || dataPesagem == null || peso == null) {
    return false;
  }

  final rows = await Supabase.instance.client
      .from('historico_pesagens')
      .select('id,deletado')
      .eq('idRebanho', idRebanho)
      .eq('tipo', tipo)
      .eq('peso', peso)
      .gte('dataPesagem', dataPesagem)
      .lt('dataPesagem', _nextIsoDate(dataPesagem))
      .limit(20);

  return (rows as List).any((row) {
    final map = Map<String, dynamic>.from(row as Map);
    return map['deletado']?.toString().trim().toUpperCase() != 'SIM';
  });
}

String _composeFiveFieldKey({
  required String numero,
  required String nome,
  required String dataNascimento,
  required String raca,
  required String sexo,
}) {
  return '${_normalize(_fixEncoding(numero))}|${_normalize(_fixEncoding(nome))}|$dataNascimento|${_normalize(_fixEncoding(raca))}|${_normalize(_fixEncoding(sexo))}';
}

String _composeFourFieldKey({
  required String numero,
  required String nome,
  required String dataNascimento,
  required String raca,
}) {
  return '${_normalize(_fixEncoding(numero))}|${_normalize(_fixEncoding(nome))}|$dataNascimento|${_normalize(_fixEncoding(raca))}';
}

String _composeNumeroDataKey({
  required String numero,
  required String dataNascimento,
}) {
  return '${numero.trim()}|$dataNascimento';
}

Future<_PesagemRebanhoLookup> _fetchPesagemRebanhoLookup(
    String idPropriedade) async {
  const pageSize = 1000;
  var from = 0;

  final byFiveFields = <String, _AnimalInfo>{};
  final byNumeroNomeDataRaca = <String, _AnimalInfo>{};
  final byNumeroData = <String, _AnimalInfo>{};
  final byNumero = <String, _AnimalInfo>{};
  final byChip = <String, _AnimalInfo>{};

  while (true) {
    final res = await Supabase.instance.client
        .from('rebanho')
        .select(
            'idRebanho,numeroAnimal,chip,nome,dataNascimento,raca,sexo,deletado')
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
      final nome = _asNonEmptyString(row['nome']);
      final raca = _asNonEmptyString(row['raca']);
      final sexo = _asNonEmptyString(row['sexo']);
      final chip = _asNonEmptyString(row['chip']);
      final dataNasc = _normalizeDateKey(row['dataNascimento']);

      final info = _AnimalInfo(
        idRebanho: id,
        numeroAnimal: numero,
        nome: nome,
        dataNascimento: dataNasc,
        raca: raca,
        sexo: sexo,
      );

      if (numero != null &&
          nome != null &&
          dataNasc != null &&
          raca != null &&
          sexo != null) {
        final key5 = _composeFiveFieldKey(
          numero: numero,
          nome: nome,
          dataNascimento: dataNasc,
          raca: raca,
          sexo: sexo,
        );
        byFiveFields.putIfAbsent(key5, () => info);
      }

      if (numero != null && nome != null && dataNasc != null && raca != null) {
        final key4 = _composeFourFieldKey(
          numero: numero,
          nome: nome,
          dataNascimento: dataNasc,
          raca: raca,
        );
        byNumeroNomeDataRaca.putIfAbsent(key4, () => info);
      }

      if (numero != null && dataNasc != null) {
        final keyND =
            _composeNumeroDataKey(numero: numero, dataNascimento: dataNasc);
        byNumeroData.putIfAbsent(keyND, () => info);
      }

      if (numero != null) {
        byNumero.putIfAbsent(numero.trim(), () => info);
      }

      if (chip != null) {
        byChip.putIfAbsent(chip.trim(), () => info);
      }
    }

    if (rows.length < pageSize) break;
    from += pageSize;
  }

  return _PesagemRebanhoLookup(
    byFiveFields: byFiveFields,
    byNumeroNomeDataRaca: byNumeroNomeDataRaca,
    byNumeroData: byNumeroData,
    byNumero: byNumero,
    byChip: byChip,
  );
}

_AnimalInfo? _resolveAnimal({
  required _PesagemRebanhoLookup lookup,
  String? numero,
  String? nome,
  String? raca,
  String? sexo,
  String? chip,
  dynamic dataNascimento,
}) {
  final dataNasc = _normalizeDateKey(dataNascimento);

  if (numero != null &&
      nome != null &&
      dataNasc != null &&
      raca != null &&
      sexo != null) {
    final key5 = _composeFiveFieldKey(
      numero: numero,
      nome: nome,
      dataNascimento: dataNasc,
      raca: raca,
      sexo: sexo,
    );
    final resolved = lookup.byFiveFields[key5];
    if (resolved != null) return resolved;
  }

  if (numero != null && nome != null && dataNasc != null && raca != null) {
    final key4 = _composeFourFieldKey(
      numero: numero,
      nome: nome,
      dataNascimento: dataNasc,
      raca: raca,
    );
    final resolved = lookup.byNumeroNomeDataRaca[key4];
    if (resolved != null) return resolved;
  }

  if (numero != null && dataNasc != null) {
    final keyND =
        _composeNumeroDataKey(numero: numero, dataNascimento: dataNasc);
    final resolved = lookup.byNumeroData[keyND];
    if (resolved != null) return resolved;
  }

  if (numero != null) {
    final resolved = lookup.byNumero[numero.trim()];
    if (resolved != null) return resolved;
  }

  if (chip != null) {
    final resolved = lookup.byChip[chip.trim()];
    if (resolved != null) return resolved;
  }

  return null;
}

/// Resolve animais do CSV sem inserir. Retorna lista de maps com campo
/// `_status` ("found" / "not_found") e `_idRebanho` quando encontrado.
Future<List<Map<String, dynamic>>> previewPesagemImport(
  List<dynamic> records,
  String idPropriedade,
) async {
  if (records.isEmpty) return [];

  final lookup = await _fetchPesagemRebanhoLookup(idPropriedade);
  final result = <Map<String, dynamic>>[];

  for (var i = 0; i < records.length; i++) {
    final record = records[i] is Map
        ? Map<String, dynamic>.from(records[i] as Map)
        : <String, dynamic>{};

    final numero = _asNonEmptyString(record['numeroAnimal']);
    final chip = _asNonEmptyString(record['chip']);
    final nome = _asNonEmptyString(record['nome']);
    final raca = _asNonEmptyString(record['raca']);
    final sexo = _asNonEmptyString(record['sexo']);
    final dataNasc = record['dataNascimento'];

    final animal = _resolveAnimal(
      lookup: lookup,
      numero: numero,
      nome: nome,
      raca: raca,
      sexo: sexo,
      chip: chip,
      dataNascimento: dataNasc,
    );

    final row = Map<String, dynamic>.from(record);
    row['_linha'] = i + 2;

    if (animal != null) {
      row['_status'] = 'found';
      row['_idRebanho'] = animal.idRebanho;
      row['_animalNumero'] = animal.numeroAnimal ?? '';
      row['_animalNome'] = animal.nome ?? '';
    } else {
      row['_status'] = 'not_found';
      row['_idRebanho'] = null;
      row['_animalNumero'] = '';
      row['_animalNome'] = '';
    }

    result.add(row);
  }

  return result;
}

/// Insere registros de pesagem na tabela `historico_pesagens` e atualiza `rebanho`.
/// Recebe a lista de preview (já com `_status` e `_idRebanho`).
Future<Map<String, dynamic>> batchInsertSupabasePesagem(
  List<Map<String, dynamic>> previewRows,
  String idPropriedade,
) async {
  final foundRows =
      previewRows.where((r) => r['_status'] == 'found').toList();
  final notFoundRows =
      previewRows.where((r) => r['_status'] != 'found').toList();

  if (foundRows.isEmpty) {
    return {
      'success': false,
      'total': previewRows.length,
      'inserted': 0,
      'failed': previewRows.length,
      'failedRows': notFoundRows
          .map((r) => {
                'linha': r['_linha'],
                'numeroAnimal': r['numeroAnimal']?.toString() ?? '',
                'nome': r['nome']?.toString() ?? '',
                'motivo': 'Animal não encontrado no sistema.',
                'erro': 'Animal não encontrado.',
              })
          .toList(),
    };
  }

  int totalInserted = 0;
  int totalFailed = 0;
  final List<Map<String, dynamic>> failedRows = [];

  for (final r in notFoundRows) {
    totalFailed++;
    failedRows.add({
      'linha': r['_linha'],
      'numeroAnimal': r['numeroAnimal']?.toString() ?? '',
      'nome': r['nome']?.toString() ?? '',
      'motivo': 'Animal não encontrado no sistema.',
      'erro': 'Animal não encontrado.',
    });
  }

  const int chunkSize = 500;

  try {
    for (int i = 0; i < foundRows.length; i += chunkSize) {
      final end = (i + chunkSize < foundRows.length)
          ? i + chunkSize
          : foundRows.length;
      final chunk = foundRows.sublist(i, end);

      final List<Map<String, dynamic>> pesagemRecords = [];
      final List<Map<String, dynamic>> rowsParaInserir = [];
      final List<Map<String, dynamic>> rowsParaAtualizar = [];
      final dedupKeysNoChunk = <String>{};

      for (final row in chunk) {
        final idRebanho = row['_idRebanho'] as String;
        final dataPesagem = _convertDateFormat(
            (row['dataPesagem'] ?? '').toString());
        final tipo = _normalizeTipoPesagem(row['tipo']);
        final peso = _parseDoubleSafe(row['peso']);
        final dedupKey = _composePesagemDedupKey(
          idRebanho: idRebanho,
          tipo: tipo,
          dataPesagem: dataPesagem,
          peso: peso,
        );

        if (!dedupKeysNoChunk.add(dedupKey)) {
          continue;
        }

        if (await _pesagemAtivaJaExiste(
          idRebanho: idRebanho,
          tipo: tipo,
          dataPesagem: dataPesagem,
          peso: peso,
        )) {
          rowsParaAtualizar.add(row);
          continue;
        }

        pesagemRecords.add({
          'idRebanho': idRebanho,
          'dataPesagem': dataPesagem,
          'tipo': tipo,
          'peso': peso,
          'deletado': null,
          'id_propriedade': idPropriedade,
        });
        rowsParaInserir.add(row);
      }

      try {
        if (pesagemRecords.isNotEmpty) {
          await Supabase.instance.client
              .from('historico_pesagens')
              .insert(pesagemRecords);

          rowsParaAtualizar.addAll(rowsParaInserir);
          totalInserted += pesagemRecords.length;
        }
      } catch (insertError) {
        for (int ci = 0; ci < rowsParaInserir.length; ci++) {
          final row = rowsParaInserir[ci];
          try {
            final idRebanho = row['_idRebanho'] as String;
            final dataPesagem = _convertDateFormat(
                (row['dataPesagem'] ?? '').toString());
            final tipo = _normalizeTipoPesagem(row['tipo']);
            final peso = _parseDoubleSafe(row['peso']);

            if (await _pesagemAtivaJaExiste(
              idRebanho: idRebanho,
              tipo: tipo,
              dataPesagem: dataPesagem,
              peso: peso,
            )) {
              rowsParaAtualizar.add(row);
              continue;
            }

            await Supabase.instance.client.from('historico_pesagens').insert({
              'idRebanho': idRebanho,
              'dataPesagem': dataPesagem,
              'tipo': tipo,
              'peso': peso,
              'deletado': null,
              'id_propriedade': idPropriedade,
            });

            rowsParaAtualizar.add(row);
            totalInserted++;
          } catch (recordError) {
            totalFailed++;
            failedRows.add({
              'linha': row['_linha'],
              'numeroAnimal': row['numeroAnimal']?.toString() ?? '',
              'nome': row['nome']?.toString() ?? '',
              'motivo': _buildFriendlyError(recordError),
              'erro': recordError.toString(),
            });
          }
        }
      }

      for (final row in rowsParaAtualizar) {
        final idRebanho = row['_idRebanho'] as String;
        final tipo = _normalizeTipoPesagem(row['tipo']);
        final peso = _parseDoubleSafe(row['peso']);
        final dataPesagem =
            _convertDateFormat((row['dataPesagem'] ?? '').toString());

        await _updateRebanhoAfterPesagem(
          idRebanho: idRebanho,
          tipo: tipo,
          peso: peso,
          dataPesagem: dataPesagem,
        );
      }
    }
  } catch (e, stack) {
    print('Erro geral no batch insert pesagem: $e');
    print(stack);
    return {
      'success': false,
      'total': previewRows.length,
      'inserted': totalInserted,
      'failed': previewRows.length - totalInserted,
      'failedRows': failedRows,
    };
  }

  final success = totalFailed == 0;
  return {
    'success': success,
    'total': previewRows.length,
    'inserted': totalInserted,
    'failed': totalFailed,
    'failedRows': failedRows,
  };
}

Future<void> _updateRebanhoAfterPesagem({
  required String idRebanho,
  required String tipo,
  double? peso,
  String? dataPesagem,
}) async {
  if (peso == null) return;

  try {
    final tipoNorm = tipo.trim().toLowerCase();
    final data = <String, dynamic>{};

    if (tipoNorm == 'nascimento') {
      data['pesoNascimento'] = peso;
    } else if (tipoNorm == 'desmama') {
      data['pesoDesmama'] = peso;
    } else {
      data['pesoAtual'] = peso;
      if (dataPesagem != null) {
        data['dataUltimaPesagem'] = dataPesagem;
      }
    }

    if (data.isNotEmpty) {
      await Supabase.instance.client
          .from('rebanho')
          .update(data)
          .eq('idRebanho', idRebanho);
    }
  } catch (e) {
    print('Erro ao atualizar rebanho após pesagem: $e');
  }
}

String _buildFriendlyError(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();

  if (lower.contains('date') || lower.contains('timestamp')) {
    return 'Data inválida ou em formato não reconhecido.';
  }
  if (lower.contains('invalid input syntax for type numeric') ||
      lower.contains('invalid input syntax for type double')) {
    return 'Valor numérico inválido no campo peso.';
  }
  if (lower.contains('duplicate key') || lower.contains('unique constraint')) {
    return 'Registro duplicado.';
  }
  if (lower.contains('null value in column') ||
      lower.contains('not-null constraint')) {
    final match = RegExp(r'column\s+"([^"]+)"').firstMatch(lower);
    final col = match?.group(1) ?? 'desconhecido';
    return 'Campo obrigatório ausente: $col.';
  }

  return raw;
}
