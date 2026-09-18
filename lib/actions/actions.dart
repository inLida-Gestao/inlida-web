import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

Future countReproducoes(
  BuildContext context, {
  String? propriedadeId,
}) async {
  List<ReproducaoRow>? countRepro;
  ApiCallResponse? countReproducoes;
  final targetPropertyId =
      (propriedadeId ?? FFAppState().propriedadeSelecionada.idPropriedade)
          .trim();

  countRepro = await ReproducaoTable().queryRows(
    queryFn: (q) => q.eqOrNull(
      'id_propriedade',
      targetPropertyId,
    ),
  );
  countReproducoes =
      await FunctionsSupabaseRebanhoGroup.countReproducaoFiltrosCall.call(
    pIdPropriedade: targetPropertyId,
  );

  if (FFAppState().propriedadeSelecionada.idPropriedade != targetPropertyId) {
    return;
  }

  FFAppState().qtdReproducoes = countReproducoes.succeeded
      ? valueOrDefault<int>(countReproducoes.jsonBody, countRepro.length)
      : countRepro.length;
  FFAppState().qtdInseminacoes =
      countRepro.where((e) => e.tipoReproducao == 'Inseminação').length;
  FFAppState().qtdMontaNatural =
      countRepro.where((e) => e.tipoReproducao == 'Monta Natural').length;
}

Future countLotes(
  BuildContext context, {
  String? propriedadeId,
}) async {
  final targetPropertyId =
      (propriedadeId ?? FFAppState().propriedadeSelecionada.idPropriedade)
          .trim();

  if (targetPropertyId.isEmpty) {
    FFAppState().lotesInativos = 0;
    FFAppState().lotesAtivos = 0;
    FFAppState().qtdAnimaisEmLotesAtivos = 0;
    FFAppState().update(() {});
    return;
  }

  // Busca todos os lotes da propriedade
  final todosLotes = await LotesTable().queryRows(
    queryFn: (q) =>
        q.eq('id_propriedade', targetPropertyId).eqOrNull('deletado', 'NAO'),
  );

  // Aplica mesma lógica de hasExitInfo do pg_lotes_widget para determinar ativo/inativo
  bool isLoteAtivo(LotesRow l) {
    final statusRaw = (l.ativo ?? '').trim().toLowerCase();
    if (statusRaw != 'ativo') return false;
    final hasExitInfo = l.dataSaidaPiquete != null ||
        (l.motivo ?? '').trim().isNotEmpty ||
        l.dataMotivo != null;
    return !hasExitInfo;
  }

  var lotesAtivosCount = 0;
  var lotesInativosCount = 0;

  for (final l in todosLotes) {
    if (isLoteAtivo(l)) {
      lotesAtivosCount++;
    } else {
      lotesInativosCount++;
    }
  }

  // Conta animais que têm loteID preenchido via função SQL (sem limite de rows)
  final countResult =
      await FunctionsSupabaseRebanhoGroup.countRebanhosComLoteCall.call(
    propriedade: targetPropertyId,
  );

  var qtdAnimaisEmLotes = 0;
  if (countResult.succeeded) {
    final body = countResult.jsonBody;
    if (body is int) {
      qtdAnimaisEmLotes = body;
    } else if (body is num) {
      qtdAnimaisEmLotes = body.toInt();
    } else {
      qtdAnimaisEmLotes = int.tryParse('$body') ?? 0;
    }
  }

  if (FFAppState().propriedadeSelecionada.idPropriedade != targetPropertyId) {
    return;
  }

  FFAppState().lotesAtivos = lotesAtivosCount;
  FFAppState().lotesInativos = lotesInativosCount;
  FFAppState().qtdAnimaisEmLotesAtivos = qtdAnimaisEmLotes;
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
