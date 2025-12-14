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
