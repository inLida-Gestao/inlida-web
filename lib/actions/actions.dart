import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

Future countReproducoes(BuildContext context) async {
  List<ReproducaoRow>? countRepro;
  ApiCallResponse? countReproducoes;

  countRepro = await ReproducaoTable().queryRows(
    queryFn: (q) => q.eqOrNull(
      'id_propriedade',
      FFAppState().propriedadeSelecionada.idPropriedade,
    ),
  );
  FFAppState().qtdReproducoes = valueOrDefault<int>(
    countRepro.length,
    0,
  );
  FFAppState().qtdInseminacoes = valueOrDefault<int>(
    countRepro
        .where((e) => e.tipoReproducao == 'Inseminação')
        .toList()
        .length,
    0,
  );
  FFAppState().qtdMontaNatural = valueOrDefault<int>(
    countRepro
        .where((e) => e.tipoReproducao == 'Monta Natural')
        .toList()
        .length,
    0,
  );
  countReproducoes =
      await FunctionsSupabaseRebanhoGroup.countReproducaoFiltrosCall.call(
    pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
  );

  if (countReproducoes.succeeded) {
    FFAppState().qtdReproducoes = (countReproducoes.jsonBody ?? '');
  }
}

Future countLotes(BuildContext context) async {
  List<LotesRow>? qtdLotesInativos;
  List<LotesRow>? qtdLotesAtivos;

  await Future.wait([
    Future(() async {
      qtdLotesInativos = await LotesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'id_propriedade',
              FFAppState().propriedadeSelecionada.idPropriedade,
            )
            .eqOrNull(
              'ativo',
              'Inativo',
            )
            .eqOrNull(
              'deletado',
              'NAO',
            ),
      );
      FFAppState().lotesInativos = valueOrDefault<int>(
        qtdLotesInativos?.length,
        0,
      );
    }),
    Future(() async {
      qtdLotesAtivos = await LotesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
              'id_propriedade',
              FFAppState().propriedadeSelecionada.idPropriedade,
            )
            .eqOrNull(
              'ativo',
              'Ativo',
            )
            .eqOrNull(
              'deletado',
              'NAO',
            ),
      );
      FFAppState().lotesAtivos = valueOrDefault<int>(
        qtdLotesAtivos?.length,
        0,
      );
    }),
  ]);

  final ativos = qtdLotesAtivos ?? [];
  final idsLotesAtivos = <String>{};
  final nomesLotesAtivos = <String>{};
  for (final l in ativos) {
    final idLote = l.idLote?.trim();
    if (idLote != null && idLote.isNotEmpty && idLote != 'null') {
      idsLotesAtivos.add(idLote);
    }
    final nome = l.nome?.trim();
    if (nome != null && nome.isNotEmpty && nome != 'null') {
      nomesLotesAtivos.add(nome);
    }
  }

  final rebanhos = await RebanhoTable().queryRows(
    queryFn: (q) => q
        .eqOrNull(
          'idPropriedade',
          FFAppState().propriedadeSelecionada.idPropriedade,
        )
        .eqOrNull('deletado', 'NAO'),
  );

  var qtdAnimaisEmLotesAtivos = 0;
  for (final r in rebanhos) {
    final lid = r.loteID?.trim() ?? '';
    final lnome = r.loteNome?.trim() ?? '';
    final temLoteId = lid.isNotEmpty && lid != 'null';
    final temLoteNome = lnome.isNotEmpty && lnome != 'null';
    if (!temLoteId && !temLoteNome) {
      continue;
    }
    final emLoteAtivo = temLoteId
        ? idsLotesAtivos.contains(lid)
        : nomesLotesAtivos.contains(lnome);
    if (emLoteAtivo) {
      qtdAnimaisEmLotesAtivos++;
    }
  }

  FFAppState().qtdAnimaisEmLotesAtivos = qtdAnimaisEmLotesAtivos;
  FFAppState().update(() {});
}

Future countPiquetes(BuildContext context) async {
  final result =
      await FunctionsSupabaseRebanhoGroup.contarPiquetesFiltrosCall.call(
    pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
  );
  FFAppState().qtdPiquetes = valueOrDefault<int>(
    result.jsonBody is num ? (result.jsonBody as num).toInt() : 0,
    0,
  );
}

Future countSanidades(BuildContext context) async {
  ApiCallResponse? apiResult19o;

  apiResult19o =
      await FunctionsSupabaseRebanhoGroup.countSanidadeVacinacaoCall.call(
    pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
  );

  if (apiResult19o.succeeded) {
    FFAppState().qtdVacinacao = valueOrDefault<int>(
      (apiResult19o.jsonBody ?? ''),
      0,
    );
  }
}
