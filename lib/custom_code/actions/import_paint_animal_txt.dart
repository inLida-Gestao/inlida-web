// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import 'dart:convert' show latin1;

/// Importa o ANIMAL.TXT que a fazenda JÁ envia manualmente ao PAINT e grava,
/// por animal, o A12 exato que o PAINT possui (tabela `paint_animal_a12`).
///
/// Por que existe: fazendas antigas no PAINT têm A12 digitado ao longo de anos,
/// com inconsistências que não podem mais ser corrigidas lá (ex.: programa 'F'
/// no lugar de 'P', ou 'p' minúsculo). Como o A12 é a CHAVE do animal no PAINT,
/// a exportação precisa reproduzir exatamente o que já está lá.
///
/// Layout de largura fixa (posições 1-based, conforme LAYOUTS.ANIMAL do export):
///   programa 7 | série 8-11 | animal 12-16 | data nasc 17-26 (dd/mm/aaaa)
///   A12 27-38 | sexo 56 | nome 61-90 | rgd 153-167
///
/// Retorna { total_linhas, casados, inseridos, atualizados, divergentes,
/// manual_preservados, nao_encontrados: [...], ambiguos: [...], erros: [...] }.
Future<Map<String, dynamic>> importPaintAnimalTxt(
  String? idPropriedade,
  FFUploadedFile? arquivo,
  bool? substituirEdicoesManuais,
) async {
  final result = <String, dynamic>{
    'total_linhas': 0,
    'casados': 0,
    'inseridos': 0,
    'atualizados': 0,
    'divergentes': 0,
    'manual_preservados': 0,
    'nao_encontrados': <Map<String, dynamic>>[],
    'ambiguos': <Map<String, dynamic>>[],
    'erros': <Map<String, dynamic>>[],
  };
  final idProp = (idPropriedade ?? '').trim();
  if (idProp.isEmpty) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Propriedade não informada.'}
    ];
    return result;
  }
  final bytes = arquivo?.bytes;
  if (bytes == null || bytes.isEmpty) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Arquivo vazio.'}
    ];
    return result;
  }

  final cfg = await loadPaintConfig(idProp);
  if (cfg == null) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Configure o PAINT antes de importar.'}
    ];
    return result;
  }

  // O PAINT grava os TXT em Windows-1252; latin1 cobre o mesmo conjunto de
  // acentos e nunca lança em byte inválido.
  final texto = latin1.decode(bytes, allowInvalid: true);
  final linhas = texto
      .split(RegExp(r'\r\n|\n|\r'))
      .where((l) => l.trim().isNotEmpty)
      .toList();
  result['total_linhas'] = linhas.length;
  if (linhas.isEmpty) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'Nenhuma linha encontrada no arquivo.'}
    ];
    return result;
  }

  // Índices do rebanho (inclui vendidos/mortos/removidos: têm histórico no PAINT).
  final rebanho = await fetchRebanhoPaint(idProp, incluirRemovidos: true);
  final porCodRegistro = <String, List<Map<String, dynamic>>>{};
  final porDigAno = <String, List<Map<String, dynamic>>>{};
  for (final r in rebanho) {
    final cod = paintSoDigitos((r['codRegistro'] ?? '').toString());
    final codFull =
        (r['codRegistro'] ?? '').toString().trim().toUpperCase();
    if (codFull.isNotEmpty) {
      (porCodRegistro[codFull] ??= <Map<String, dynamic>>[]).add(r);
    } else if (cod.isNotEmpty) {
      // guarda também só-dígitos, para registros com sigla divergente
      (porCodRegistro[cod] ??= <Map<String, dynamic>>[]).add(r);
    }
    final chave =
        paintChaveDigAno((r['numeroAnimal'] ?? '').toString(), r['dataNascimento']);
    if (chave.isNotEmpty) {
      (porDigAno[chave] ??= <Map<String, dynamic>>[]).add(r);
    }
  }

  // Overrides já existentes: para preservar edições manuais e saber
  // inseridos vs atualizados.
  final existentes = <String, Map<String, dynamic>>{};
  const pagina = 1000;
  var offset = 0;
  while (true) {
    final lote = await SupaFlow.client
        .from('paint_animal_a12')
        .select('id,id_rebanho,a12,origem')
        .eq('id_propriedade', idProp)
        .range(offset, offset + pagina - 1);
    for (final e in lote) {
      existentes[(e['id_rebanho'] ?? '').toString().trim()] =
          Map<String, dynamic>.from(e as Map);
    }
    if (lote.length < pagina) break;
    offset += pagina;
  }

  final substituirManual = substituirEdicoesManuais ?? false;
  final upserts = <Map<String, dynamic>>[];
  final naoEncontrados = <Map<String, dynamic>>[];
  final ambiguos = <Map<String, dynamic>>[];
  final erros = <Map<String, dynamic>>[];
  final vistos = <String>{};
  var divergentes = 0;
  var manualPreservados = 0;
  var atualizados = 0;
  var inseridos = 0;

  for (var i = 0; i < linhas.length; i++) {
    final linha = linhas[i];
    final numLinha = i + 1;
    if (linha.length < 38) {
      erros.add({
        'linha': numLinha,
        'motivo': 'Linha curta (${linha.length} chars) — ignorada.'
      });
      continue;
    }
    final programa = _campo(linha, 7, 7);
    final serie = _campo(linha, 8, 11);
    final numeroPaint = _campo(linha, 12, 16);
    final dataNascPaint = _campo(linha, 17, 26);
    final a12 = _campoRaw(linha, 27, 38).trimRight(); // preserva caixa/espaços
    final sexoPaint = _campo(linha, 56, 56);
    final nomePaint = _campo(linha, 61, 90);
    final rgdPaint = _campo(linha, 153, 167);

    if (a12.trim().isEmpty) {
      erros.add({'linha': numLinha, 'motivo': 'A12 vazio na linha.'});
      continue;
    }

    // 1) match forte por código de registro
    List<Map<String, dynamic>> candidatos = const [];
    if (rgdPaint.isNotEmpty) {
      candidatos = porCodRegistro[rgdPaint.toUpperCase()] ??
          porCodRegistro[paintSoDigitos(rgdPaint)] ??
          const [];
    }
    // 2) dígitos do número + ano de nascimento
    if (candidatos.isEmpty) {
      final chave = paintChaveDigAno(numeroPaint, dataNascPaint);
      final porChave = chave.isEmpty ? null : porDigAno[chave];
      // 3) fallback: chave derivada do próprio A12
      candidatos = porChave ??
          porDigAno[paintChaveDigAnoDeA12(a12)] ??
          const [];
    }

    if (candidatos.isEmpty) {
      if (naoEncontrados.length < 50) {
        naoEncontrados.add({
          'linha': numLinha,
          'a12': a12,
          'numero': numeroPaint,
          'nome': nomePaint,
        });
      }
      continue;
    }

    // Desempate: data de nascimento completa -> sexo -> nome
    var filtrados = candidatos;
    if (filtrados.length > 1) {
      final nascIso = parseDateIso(dataNascPaint);
      if (nascIso != null) {
        final f = filtrados
            .where((c) => parseDateIso(c['dataNascimento']) == nascIso)
            .toList();
        if (f.isNotEmpty) filtrados = f;
      }
    }
    if (filtrados.length > 1 && sexoPaint.isNotEmpty) {
      final f = filtrados
          .where((c) =>
              (c['sexo'] ?? '').toString().trim().toUpperCase().startsWith(
                    sexoPaint.toUpperCase(),
                  ))
          .toList();
      if (f.isNotEmpty) filtrados = f;
    }
    if (filtrados.length > 1 && nomePaint.isNotEmpty) {
      final alvo = normalizePaintText(nomePaint);
      final f = filtrados
          .where((c) => normalizePaintText(c['nome']) == alvo)
          .toList();
      if (f.isNotEmpty) filtrados = f;
    }
    if (filtrados.length != 1) {
      if (ambiguos.length < 50) {
        ambiguos.add({
          'linha': numLinha,
          'a12': a12,
          'numero': numeroPaint,
          'candidatos': filtrados.length,
        });
      }
      continue;
    }

    final reb = filtrados.first;
    final idRebanho = (reb['idRebanho'] ?? '').toString().trim();
    if (idRebanho.isEmpty) {
      erros.add({
        'linha': numLinha,
        'motivo': 'Animal casado sem idRebanho no inLida.'
      });
      continue;
    }
    if (!vistos.add(idRebanho)) {
      erros.add({
        'linha': numLinha,
        'motivo':
            'Duas linhas do arquivo apontam para o mesmo animal ($idRebanho) — 1ª mantida.'
      });
      continue;
    }

    final anterior = existentes[idRebanho];
    if (anterior != null &&
        (anterior['origem'] ?? '').toString() == 'manual' &&
        !substituirManual) {
      manualPreservados += 1;
      continue;
    }

    // Aviso quando o A12 não confere com os campos posicionais da própria linha
    // (o campo 27-38 é o que o PAINT usa como chave, então ele prevalece).
    final partes = paintPartesDoA12(a12);
    final serieDoA12 = (partes?['serie'] ?? '').trim();
    if ((programa.isNotEmpty && !a12.startsWith(programa)) ||
        (serie.isNotEmpty && serieDoA12.isNotEmpty && serieDoA12 != serie)) {
      erros.add({
        'linha': numLinha,
        'motivo':
            'Aviso: programa/série da linha ("$programa$serie") difere do A12 "$a12" — gravado o A12.'
      });
    }

    final calculado = a12FromRebanho(Map<String, dynamic>.from(reb), cfg);
    final divergente = calculado.trimRight() != a12;
    if (divergente) divergentes += 1;

    upserts.add({
      'id_propriedade': idProp,
      'id_rebanho': idRebanho,
      'a12': a12,
      'origem': 'animal_txt',
      'numero_animal_paint': numeroPaint.isEmpty ? null : numeroPaint,
      'data_nascimento_paint': parseDateIso(dataNascPaint),
      'nome_paint': nomePaint.isEmpty ? null : nomePaint,
      'divergente': divergente,
      'updated_at': DateTime.now().toIso8601String(),
    });
    if (anterior == null) {
      inseridos += 1;
    } else {
      atualizados += 1;
    }
  }

  // Grava em lotes; upsert idempotente pela unique (id_propriedade, id_rebanho).
  const tam = 500;
  for (var i = 0; i < upserts.length; i += tam) {
    final fim = (i + tam < upserts.length) ? i + tam : upserts.length;
    try {
      await SupaFlow.client.from('paint_animal_a12').upsert(
            upserts.sublist(i, fim),
            onConflict: 'id_propriedade,id_rebanho',
          );
    } catch (e) {
      erros.add({
        'linha': 0,
        'motivo': 'Falha ao gravar lote ${i ~/ tam + 1}: $e',
      });
    }
  }

  result['casados'] = upserts.length;
  result['inseridos'] = inseridos;
  result['atualizados'] = atualizados;
  result['divergentes'] = divergentes;
  result['manual_preservados'] = manualPreservados;
  result['nao_encontrados'] = naoEncontrados;
  result['ambiguos'] = ambiguos;
  result['erros'] = erros;
  return result;
}

/// Campo de largura fixa (1-based, inclusivo), com clamp e trim — arquivos reais
/// costumam ter a última linha truncada.
String _campo(String linha, int ini, int fim) => _campoRaw(linha, ini, fim).trim();

String _campoRaw(String linha, int ini, int fim) {
  final i = ini - 1;
  if (i >= linha.length) return '';
  final f = fim > linha.length ? linha.length : fim;
  if (f <= i) return '';
  return linha.substring(i, f);
}
