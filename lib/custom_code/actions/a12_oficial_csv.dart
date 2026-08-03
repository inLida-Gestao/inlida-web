// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import 'paint_excel_helpers.dart';
// Begin custom action code

import 'dart:convert' show utf8, latin1;
import 'package:download/download.dart';

const _a12CsvHeader =
    'idRebanho;Numero_Animal;Nome;Data_Nascimento;A12_Calculado;A12_PAINT;Origem;Divergente';

/// Baixa um CSV com o A12 de cada animal para a cliente conferir/corrigir:
/// `A12_Calculado` é o que o inLida calcularia; `A12_PAINT` é o que será
/// enviado (o oficial, quando cadastrado). A cliente edita SÓ a coluna
/// `A12_PAINT` e reimporta com [importarA12OficialCsv] — o `idRebanho` é a
/// chave, então reimportar ATUALIZA e nunca duplica.
///
/// Separador `;` e UTF-8 com BOM: abre direto no Excel pt-BR.
Future<bool> exportarA12OficialCsv(String? idPropriedade) async {
  final idProp = (idPropriedade ?? '').trim();
  if (idProp.isEmpty) return false;

  final cfg = await loadPaintConfig(idProp);
  if (cfg == null) return false;

  final rebanho = await fetchRebanhoPaint(idProp, incluirRemovidos: true);
  if (rebanho.isEmpty) return false;

  // Overrides já cadastrados (idRebanho -> linha).
  final overrides = <String, Map<String, dynamic>>{};
  const pagina = 1000;
  var offset = 0;
  while (true) {
    final lote = await SupaFlow.client
        .from('paint_animal_a12')
        .select('id_rebanho,a12,origem,divergente')
        .eq('id_propriedade', idProp)
        .range(offset, offset + pagina - 1);
    for (final r in lote) {
      overrides[(r['id_rebanho'] ?? '').toString().trim()] =
          Map<String, dynamic>.from(r as Map);
    }
    if (lote.length < pagina) break;
    offset += pagina;
  }

  String csvCell(dynamic v) {
    final s = (v ?? '').toString().replaceAll('\r', ' ').replaceAll('\n', ' ');
    // ';' é o separador; troca por ',' para não quebrar a coluna.
    return s.replaceAll(';', ',').trim();
  }

  final linhas = <String>[_a12CsvHeader];
  for (final r in rebanho) {
    final idReb = (r['idRebanho'] ?? '').toString().trim();
    if (idReb.isEmpty) continue;
    final calc = a12FromRebanho(Map<String, dynamic>.from(r), cfg);
    final ov = overrides[idReb];
    final oficial = (ov?['a12'] ?? '').toString().trimRight();
    linhas.add([
      csvCell(idReb),
      csvCell(r['numeroAnimal']),
      csvCell(r['nome']),
      csvCell(parseDateIso(r['dataNascimento'])),
      csvCell(calc),
      // Quando não há oficial, pré-preenche com o calculado: a cliente só mexe
      // nas linhas que precisam mudar.
      csvCell(oficial.isEmpty ? calc : oficial),
      csvCell(ov?['origem'] ?? ''),
      (ov?['divergente'] == true) ? 'SIM' : 'NAO',
    ].join(';'));
  }

  final conteudo = '${linhas.join('\r\n')}\r\n';
  // UTF-8 com BOM: o Excel (pt-BR) reconhece o BOM e abre com os acentos certos,
  // e ao contrário do latin1 aceita qualquer caractere que venha do cadastro
  // (nomes com caracteres fora do Latin-1 faziam o latin1.encode lançar).
  final bytes = <int>[0xEF, 0xBB, 0xBF, ...utf8.encode(conteudo)];
  await download(
    Stream.fromIterable(bytes),
    'PAINT_A12_OFICIAL_${cfg.codigoTransmissao}.csv',
  );
  return true;
}

/// Reimporta o CSV editado, gravando a coluna `A12_PAINT` como A12 oficial.
///
/// NÃO DUPLICA: a chave é (id_propriedade, idRebanho) — reimportar a mesma
/// planilha atualiza as linhas existentes. Linhas cujo `A12_PAINT` é igual ao
/// `A12_Calculado` e que ainda não tinham override são ignoradas (não faz
/// sentido gravar override idêntico ao cálculo).
///
/// Retorna { total_linhas, gravados, inseridos, atualizados, ignorados,
/// erros: [{linha, motivo}] }.
Future<Map<String, dynamic>> importarA12OficialCsv(
  String? idPropriedade,
  FFUploadedFile? arquivo,
) async {
  final result = <String, dynamic>{
    'total_linhas': 0,
    'gravados': 0,
    'inseridos': 0,
    'atualizados': 0,
    'ignorados': 0,
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

  // Aceita UTF-8 (com ou sem BOM) e latin1 — o Excel pt-BR salva em latin1.
  String texto;
  try {
    texto = utf8.decode(bytes);
  } catch (_) {
    texto = latin1.decode(bytes, allowInvalid: true);
  }
  if (texto.isNotEmpty && texto.codeUnitAt(0) == 0xFEFF) {
    texto = texto.substring(1);
  }

  final linhas = texto
      .split(RegExp(r'\r\n|\n|\r'))
      .where((l) => l.trim().isNotEmpty)
      .toList();
  result['total_linhas'] = linhas.isEmpty ? 0 : linhas.length - 1;
  if (linhas.length < 2) {
    result['erros'] = [
      {'linha': 0, 'motivo': 'CSV sem linhas de dados.'}
    ];
    return result;
  }

  // Cabeçalho: aceita ';' ou ',' como separador e nomes em qualquer ordem.
  final sep = linhas.first.contains(';') ? ';' : ',';
  final cab = linhas.first
      .split(sep)
      .map((c) => normalizePaintHeader(c.replaceAll('"', '')))
      .toList();
  int col(String nome) => cab.indexOf(normalizePaintHeader(nome));
  final iId = col('idRebanho');
  final iA12 = col('A12_PAINT');
  final iCalc = col('A12_Calculado');
  if (iId < 0 || iA12 < 0) {
    result['erros'] = [
      {
        'linha': 1,
        'motivo':
            'CSV precisa das colunas idRebanho e A12_PAINT (baixe o modelo pelo botão "Baixar CSV do A12").'
      }
    ];
    return result;
  }

  // Estado atual, para distinguir inserção de atualização e detectar no-op.
  final existentes = <String, Map<String, dynamic>>{};
  const pagina = 1000;
  var offset = 0;
  while (true) {
    final lote = await SupaFlow.client
        .from('paint_animal_a12')
        .select('id_rebanho,a12,origem')
        .eq('id_propriedade', idProp)
        .range(offset, offset + pagina - 1);
    for (final r in lote) {
      existentes[(r['id_rebanho'] ?? '').toString().trim()] =
          Map<String, dynamic>.from(r as Map);
    }
    if (lote.length < pagina) break;
    offset += pagina;
  }

  final erros = <Map<String, dynamic>>[];
  final upserts = <Map<String, dynamic>>[];
  final vistos = <String>{};
  var ignorados = 0;
  var inseridos = 0;
  var atualizados = 0;

  String campo(List<String> partes, int i) {
    if (i < 0 || i >= partes.length) return '';
    var v = partes[i].trim();
    if (v.length >= 2 && v.startsWith('"') && v.endsWith('"')) {
      v = v.substring(1, v.length - 1);
    }
    return v;
  }

  for (var i = 1; i < linhas.length; i++) {
    final numLinha = i + 1;
    final partes = linhas[i].split(sep);
    final idReb = campo(partes, iId);
    // trimRight só: a CAIXA e os espaços internos do A12 são significativos.
    final a12 = campo(partes, iA12).trimRight();
    if (idReb.isEmpty) {
      erros.add({'linha': numLinha, 'motivo': 'idRebanho vazio.'});
      continue;
    }
    if (a12.isEmpty) {
      ignorados += 1;
      continue;
    }
    if (a12.trim().length > 12) {
      erros.add({
        'linha': numLinha,
        'motivo': 'A12_PAINT "$a12" tem mais de 12 caracteres.'
      });
      continue;
    }
    if (!vistos.add(idReb)) {
      erros.add({
        'linha': numLinha,
        'motivo': 'idRebanho $idReb repetido no CSV — 1ª linha mantida.'
      });
      continue;
    }

    final anterior = existentes[idReb];
    final calc = campo(partes, iCalc).trimRight();
    // Sem override antes e A12 igual ao calculado: nada a gravar.
    if (anterior == null && calc.isNotEmpty && calc == a12) {
      ignorados += 1;
      continue;
    }
    // Já existe e não mudou nada: também é no-op.
    if (anterior != null &&
        (anterior['a12'] ?? '').toString().trimRight() == a12) {
      ignorados += 1;
      continue;
    }

    upserts.add({
      'id_propriedade': idProp,
      'id_rebanho': idReb,
      'a12': a12,
      'origem': 'manual',
      'divergente': calc.isEmpty ? true : calc != a12,
      'updated_at': DateTime.now().toIso8601String(),
    });
    if (anterior == null) {
      inseridos += 1;
    } else {
      atualizados += 1;
    }
  }

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

  result['gravados'] = upserts.length;
  result['inseridos'] = inseridos;
  result['atualizados'] = atualizados;
  result['ignorados'] = ignorados;
  result['erros'] = erros;
  return result;
}
