import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;
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
  final propriedadeId = FFAppState().propriedadeSelecionada.idPropriedade;

  if (propriedadeId.isEmpty) {
    FFAppState().lotesInativos = 0;
    FFAppState().lotesAtivos = 0;
    FFAppState().qtdAnimaisEmLotesAtivos = 0;
    FFAppState().update(() {});
    return;
  }

  // Busca todos os lotes da propriedade
  final todosLotes = await LotesTable().queryRows(
    queryFn: (q) => q
        .eq('id_propriedade', propriedadeId)
        .eqOrNull('deletado', 'NAO'),
  );

  // Aplica mesma lógica de hasExitInfo do pg_lotes_widget para determinar ativo/inativo
  bool _isLoteAtivo(LotesRow l) {
    final statusRaw = (l.ativo ?? '').trim().toLowerCase();
    if (statusRaw != 'ativo') return false;
    final hasExitInfo =
        l.dataSaidaPiquete != null ||
        (l.motivo ?? '').trim().isNotEmpty ||
        l.dataMotivo != null;
    return !hasExitInfo;
  }

  var lotesAtivosCount = 0;
  var lotesInativosCount = 0;

  for (final l in todosLotes) {
    if (_isLoteAtivo(l)) {
      lotesAtivosCount++;
    } else {
      lotesInativosCount++;
    }
  }

  FFAppState().lotesAtivos = lotesAtivosCount;
  FFAppState().lotesInativos = lotesInativosCount;

  // Conta animais que têm loteID preenchido (estão em algum lote)
  final rebanhos = await RebanhoTable().queryRows(
    queryFn: (q) => q
        .eqOrNull('idPropriedade', propriedadeId)
        .eqOrNull('deletado', 'NAO'),
  );

  var qtdAnimaisEmLotes = 0;
  for (final r in rebanhos) {
    final lid = r.loteID?.trim() ?? '';
    if (lid.isNotEmpty && lid != 'null') {
      qtdAnimaisEmLotes++;
    }
  }

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
