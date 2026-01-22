import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

// ignore: unused_element
const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start Functions Supabase Rebanho Group Code

class FunctionsSupabaseRebanhoGroup {
  static String getBaseUrl() =>
      'https://eqrtgsqnxxnfjjzlxpuj.supabase.co/rest/v1/rpc';
  static Map<String, String> headers = {
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
  };
  static QTDRebanhoPropriedadesCall qTDRebanhoPropriedadesCall =
      QTDRebanhoPropriedadesCall();
  static QTDRebanhoForaPropriedadeCall qTDRebanhoForaPropriedadeCall =
      QTDRebanhoForaPropriedadeCall();
  static QTDRebanhoPropriedadeCall qTDRebanhoPropriedadeCall =
      QTDRebanhoPropriedadeCall();
  static RebanhoPropriedadeCall rebanhoPropriedadeCall =
      RebanhoPropriedadeCall();
  static CountRebanhoFiltrosCall countRebanhoFiltrosCall =
      CountRebanhoFiltrosCall();
  static BuscarRebanhoFiltrosCall buscarRebanhoFiltrosCall =
      BuscarRebanhoFiltrosCall();
  static BuscarRebanhoExportCall buscarRebanhoExportCall =
      BuscarRebanhoExportCall();
  static BuscarReproducaoFiltrosCall buscarReproducaoFiltrosCall =
      BuscarReproducaoFiltrosCall();
  static CountReproducaoFiltrosCall countReproducaoFiltrosCall =
      CountReproducaoFiltrosCall();
  static BuscarLotesFiltrosCall buscarLotesFiltrosCall =
      BuscarLotesFiltrosCall();
  static CountLotesFiltrosCall countLotesFiltrosCall = CountLotesFiltrosCall();
  static BuscarSanidadeFiltrosCall buscarSanidadeFiltrosCall =
      BuscarSanidadeFiltrosCall();
  static CountSanidadeVacinacaoCall countSanidadeVacinacaoCall =
      CountSanidadeVacinacaoCall();
  static CountSanidadeAntiparasitarioCall countSanidadeAntiparasitarioCall =
      CountSanidadeAntiparasitarioCall();
  static CountSanidadeTratamentoCall countSanidadeTratamentoCall =
      CountSanidadeTratamentoCall();
  static CountSanidadeProtocoloReprodutivoCall
      countSanidadeProtocoloReprodutivoCall =
      CountSanidadeProtocoloReprodutivoCall();
  static CountSanidadeFiltrosCall countSanidadeFiltrosCall =
      CountSanidadeFiltrosCall();
  static ListaRebanhosPropriedadeCall listaRebanhosPropriedadeCall =
      ListaRebanhosPropriedadeCall();
  static GraficoQtdRebanhoPeriodoCall graficoQtdRebanhoPeriodoCall =
      GraficoQtdRebanhoPeriodoCall();
  static AnosComRebanhoCall anosComRebanhoCall = AnosComRebanhoCall();
  static QtdAnimaisMortalidadeCall qtdAnimaisMortalidadeCall =
      QtdAnimaisMortalidadeCall();
  static QtdAnimaisDesmamaCall qtdAnimaisDesmamaCall = QtdAnimaisDesmamaCall();
  static CountInseminacaoCall countInseminacaoCall = CountInseminacaoCall();
  static CountMontaNaturalCall countMontaNaturalCall = CountMontaNaturalCall();
  static BuscarPropriedadesDoUsuarioCall buscarPropriedadesDoUsuarioCall =
      BuscarPropriedadesDoUsuarioCall();
  static ValidarAcessoUserCall validarAcessoUserCall = ValidarAcessoUserCall();
  static CountRebanhosComLoteCall countRebanhosComLoteCall =
      CountRebanhosComLoteCall();
}

class QTDRebanhoPropriedadesCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'QTD Rebanho Propriedades',
      apiUrl: '$baseUrl/contar_rebanho_ativo',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class QTDRebanhoForaPropriedadeCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'QTD Rebanho Fora Propriedade',
      apiUrl: '$baseUrl/contar_rebanho_fora',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class QTDRebanhoPropriedadeCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'QTD Rebanho Propriedade ',
      apiUrl: '$baseUrl/contar_rebanho_prop',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class RebanhoPropriedadeCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    int? pLimite = 20,
    int? pOffset = 0,
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_limite": $pLimite,
  "p_offset": $pOffset
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Rebanho Propriedade',
      apiUrl: '$baseUrl/obter_rebanho_ativo_por_propriedade',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountRebanhoFiltrosCall {
  Future<ApiCallResponse> call({
    String? pCategoria = '',
    String? pDataNascimento = '',
    String? pIdPropriedade = '',
    String? pLoteID = '',
    String? pOrigem = '',
    String? pRaca = '',
    String? pSexo = '',
    String? pStatus = '',
    String? pPesquisa = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_categoria": "${escapeStringForJson(pCategoria)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_lote_id": "${escapeStringForJson(pLoteID)}",
  "p_origem": "${escapeStringForJson(pOrigem)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_status": "${escapeStringForJson(pStatus)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Rebanho Filtros',
      apiUrl: '$baseUrl/contar_rebanho_propriedade_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BuscarRebanhoFiltrosCall {
  Future<ApiCallResponse> call({
    String? pCategoria = '',
    String? pDataNascimento = '',
    String? pIdPropriedade = '',
    String? pLoteNome = '',
    String? pOrigem = '',
    String? pRaca = '',
    String? pSexo = '',
    String? pStatus = '',
    int? pLimite,
    int? pOffset,
    String? pPesquisa = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_categoria": "${escapeStringForJson(pCategoria)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_limite": $pLimite,
  "p_lote_nome": "${escapeStringForJson(pLoteNome)}",
  "p_offset": $pOffset,
  "p_origem": "${escapeStringForJson(pOrigem)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_status": "${escapeStringForJson(pStatus)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buscar Rebanho Filtros',
      apiUrl: '$baseUrl/rebanho_propriedade_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BuscarRebanhoExportCall {
  Future<ApiCallResponse> call({
    String? pCategoria = '',
    String? pDataNascimento = '',
    String? pIdPropriedade = '',
    String? pLoteNome = '',
    String? pOrigem = '',
    String? pRaca = '',
    String? pSexo = '',
    String? pStatus = '',
    int? pLimite,
    int? pOffset,
    String? pPesquisa = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_categoria": "${escapeStringForJson(pCategoria)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_limite": $pLimite,
  "p_lote_nome": "${escapeStringForJson(pLoteNome)}",
  "p_offset": $pOffset,
  "p_origem": "${escapeStringForJson(pOrigem)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_status": "${escapeStringForJson(pStatus)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buscar Rebanho Export',
      apiUrl: '$baseUrl/rebanho_propriedade_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BuscarReproducaoFiltrosCall {
  Future<ApiCallResponse> call({
    String? pDataPrevisaoParto = '',
    String? pDataReproducao = '',
    String? pLoteNome = '',
    String? pIdPropriedade = '',
    String? pInseminador = '',
    int? pLimite = 20,
    String? pMatriz = '',
    int? pOffset = 0,
    String? pPesquisa = '',
    String? pReprodutor = '',
    String? pTipoReproducao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_data_reproducao": "${escapeStringForJson(pDataReproducao)}",
  "p_data_previsao_parto": "${escapeStringForJson(pDataPrevisaoParto)}",
  "p_tipo_reproducao": "${escapeStringForJson(pTipoReproducao)}",
  "p_lote_nome": "${escapeStringForJson(pLoteNome)}",
  "p_inseminador": "${escapeStringForJson(pInseminador)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_matriz": "${escapeStringForJson(pMatriz)}",
  "p_reprodutor": "${escapeStringForJson(pReprodutor)}",
  "p_limite": $pLimite,
  "p_offset": $pOffset
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buscar Reproducao Filtros',
      apiUrl: '$baseUrl/reproducao_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountReproducaoFiltrosCall {
  Future<ApiCallResponse> call({
    String? pDataPrevisaoParto = '',
    String? pDataReproducao = '',
    String? pLoteNome = '',
    String? pIdPropriedade = '',
    String? pInseminador = '',
    String? pMatriz = '',
    String? pPesquisa = '',
    String? pReprodutor = '',
    String? pTipoReproducao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_data_reproducao": "${escapeStringForJson(pDataReproducao)}",
  "p_data_previsao_parto": "${escapeStringForJson(pDataPrevisaoParto)}",
  "p_tipo_reproducao": "${escapeStringForJson(pTipoReproducao)}",
  "p_lote_nome": "${escapeStringForJson(pLoteNome)}",
  "p_inseminador": "${escapeStringForJson(pInseminador)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_matriz": "${escapeStringForJson(pMatriz)}",
  "p_reprodutor": "${escapeStringForJson(pReprodutor)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Reproducao Filtros ',
      apiUrl: '$baseUrl/contar_reproducao_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BuscarLotesFiltrosCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pStatus = '',
    int? pLimite = 20,
    int? pOffset = 0,
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_status": "${escapeStringForJson(pStatus)}",
  "p_limite": $pLimite,
  "p_offset": $pOffset
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buscar Lotes Filtros',
      apiUrl: '$baseUrl/lotes_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountLotesFiltrosCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pStatus = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_status": "${escapeStringForJson(pStatus)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Lotes Filtros ',
      apiUrl: '$baseUrl/count_lotes_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BuscarSanidadeFiltrosCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pDataSanidade = '',
    String? pLoteId = '',
    String? pRebanhoId = '',
    String? pSexo = '',
    String? pDataNascimento = '',
    String? pRaca = '',
    String? pTratamento = '',
    String? pProtocolo = '',
    String? pAntiparasitarios = '',
    String? pVacinacao = '',
    int? pLimite = 20,
    int? pOffset = 0,
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_data_sanidade": "${escapeStringForJson(pDataSanidade)}",
"p_lote_id": "${escapeStringForJson(pLoteId)}",
"p_rebanho_id": "${escapeStringForJson(pRebanhoId)}",
"p_sexo": "${escapeStringForJson(pSexo)}",
"p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
"p_raca": "${escapeStringForJson(pRaca)}",
"p_categoria": "${escapeStringForJson(pRaca)}",
"p_tratamento": "${escapeStringForJson(pTratamento)}",
"p_protocolo": "${escapeStringForJson(pProtocolo)}",
"p_antiparasitarios": "${escapeStringForJson(pAntiparasitarios)}",
"p_vacinacao": "${escapeStringForJson(pVacinacao)}",
  "p_limite": $pLimite,
  "p_offset": $pOffset
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buscar Sanidade Filtros',
      apiUrl: '$baseUrl/sanidade_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountSanidadeVacinacaoCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pDataSanidade = '',
    String? pLoteId = '',
    String? pRebanhoId = '',
    String? pSexo = '',
    String? pDataNascimento = '',
    String? pRaca = '',
    String? pTratamento = '',
    String? pProtocolo = '',
    String? pAntiparasitarios = '',
    String? pVacinacao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_data_sanidade": "${escapeStringForJson(pDataSanidade)}",
  "p_lote_id": "${escapeStringForJson(pLoteId)}",
  "p_rebanho_id": "${escapeStringForJson(pRebanhoId)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_categoria": "${escapeStringForJson(pRaca)}",
  "p_tratamento": "${escapeStringForJson(pTratamento)}",
  "p_protocolo": "${escapeStringForJson(pProtocolo)}",
  "p_antiparasitarios": "${escapeStringForJson(pAntiparasitarios)}",
  "p_vacinacao": "${escapeStringForJson(pVacinacao)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Sanidade Vacinacao',
      apiUrl: '$baseUrl/count_sanidade_vacinacao',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountSanidadeAntiparasitarioCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pDataSanidade = '',
    String? pLoteId = '',
    String? pRebanhoId = '',
    String? pSexo = '',
    String? pDataNascimento = '',
    String? pRaca = '',
    String? pTratamento = '',
    String? pProtocolo = '',
    String? pAntiparasitarios = '',
    String? pVacinacao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_data_sanidade": "${escapeStringForJson(pDataSanidade)}",
  "p_lote_id": "${escapeStringForJson(pLoteId)}",
  "p_rebanho_id": "${escapeStringForJson(pRebanhoId)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_categoria": "${escapeStringForJson(pRaca)}",
  "p_tratamento": "${escapeStringForJson(pTratamento)}",
  "p_protocolo": "${escapeStringForJson(pProtocolo)}",
  "p_antiparasitarios": "${escapeStringForJson(pAntiparasitarios)}",
  "p_vacinacao": "${escapeStringForJson(pVacinacao)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Sanidade Antiparasitario',
      apiUrl: '$baseUrl/count_sanidade_antiparasitario',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountSanidadeTratamentoCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pDataSanidade = '',
    String? pLoteId = '',
    String? pRebanhoId = '',
    String? pSexo = '',
    String? pDataNascimento = '',
    String? pRaca = '',
    String? pTratamento = '',
    String? pProtocolo = '',
    String? pAntiparasitarios = '',
    String? pVacinacao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_data_sanidade": "${escapeStringForJson(pDataSanidade)}",
  "p_lote_id": "${escapeStringForJson(pLoteId)}",
  "p_rebanho_id": "${escapeStringForJson(pRebanhoId)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_categoria": "${escapeStringForJson(pRaca)}",
  "p_tratamento": "${escapeStringForJson(pTratamento)}",
  "p_protocolo": "${escapeStringForJson(pProtocolo)}",
  "p_antiparasitarios": "${escapeStringForJson(pAntiparasitarios)}",
  "p_vacinacao": "${escapeStringForJson(pVacinacao)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Sanidade Tratamento',
      apiUrl: '$baseUrl/count_sanidade_tratamento',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountSanidadeProtocoloReprodutivoCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pDataSanidade = '',
    String? pLoteId = '',
    String? pRebanhoId = '',
    String? pSexo = '',
    String? pDataNascimento = '',
    String? pRaca = '',
    String? pTratamento = '',
    String? pProtocolo = '',
    String? pAntiparasitarios = '',
    String? pVacinacao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_data_sanidade": "${escapeStringForJson(pDataSanidade)}",
  "p_lote_id": "${escapeStringForJson(pLoteId)}",
  "p_rebanho_id": "${escapeStringForJson(pRebanhoId)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_categoria": "${escapeStringForJson(pRaca)}",
  "p_tratamento": "${escapeStringForJson(pTratamento)}",
  "p_protocolo": "${escapeStringForJson(pProtocolo)}",
  "p_antiparasitarios": "${escapeStringForJson(pAntiparasitarios)}",
  "p_vacinacao": "${escapeStringForJson(pVacinacao)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Sanidade Protocolo Reprodutivo',
      apiUrl: '$baseUrl/count_sanidade_protocolo_reprodutivo',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountSanidadeFiltrosCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
    String? pPesquisa = '',
    String? pDataSanidade = '',
    String? pLoteId = '',
    String? pRebanhoId = '',
    String? pSexo = '',
    String? pDataNascimento = '',
    String? pRaca = '',
    String? pTratamento = '',
    String? pProtocolo = '',
    String? pAntiparasitarios = '',
    String? pVacinacao = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}",
  "p_pesquisa": "${escapeStringForJson(pPesquisa)}",
  "p_data_sanidade": "${escapeStringForJson(pDataSanidade)}",
  "p_lote_id": "${escapeStringForJson(pLoteId)}",
  "p_rebanho_id": "${escapeStringForJson(pRebanhoId)}",
  "p_sexo": "${escapeStringForJson(pSexo)}",
  "p_data_nascimento": "${escapeStringForJson(pDataNascimento)}",
  "p_raca": "${escapeStringForJson(pRaca)}",
  "p_categoria": "${escapeStringForJson(pRaca)}",
  "p_tratamento": "${escapeStringForJson(pTratamento)}",
  "p_protocolo": "${escapeStringForJson(pProtocolo)}",
  "p_antiparasitarios": "${escapeStringForJson(pAntiparasitarios)}",
  "p_vacinacao": "${escapeStringForJson(pVacinacao)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Sanidade Filtros',
      apiUrl: '$baseUrl/count_sanidade_filtros',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ListaRebanhosPropriedadeCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "property_id": "${escapeStringForJson(propertyId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Lista Rebanhos Propriedade',
      apiUrl: '$baseUrl/get_rebanho_stats_by_categoria',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GraficoQtdRebanhoPeriodoCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    int? startYear,
    int? startMonth,
    int? endYear,
    int? endMonth,
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "property_id": "${escapeStringForJson(propertyId)}",
  "start_year": $startYear,
  "start_month": $startMonth,
  "end_year": $endYear,
  "end_month": $endMonth
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Grafico qtd Rebanho Periodo',
      apiUrl: '$baseUrl/get_rebanho_stats_by_gender_monthly',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<int>? anos(dynamic response) => (getJsonField(
        response,
        r'''$[:].ano''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? meses(dynamic response) => (getJsonField(
        response,
        r'''$[:].mes''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<String>? mesesNome(dynamic response) => (getJsonField(
        response,
        r'''$[:].mes_nome''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? qtdMacho(dynamic response) => (getJsonField(
        response,
        r'''$[:].quantidade_macho''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? qtdFemea(dynamic response) => (getJsonField(
        response,
        r'''$[:].quantidade_femea''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? qtdTotal(dynamic response) => (getJsonField(
        response,
        r'''$[:].quantidade_total''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<String>? mesAno(dynamic response) => (getJsonField(
        response,
        r'''$[:].mes_ano_texto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class AnosComRebanhoCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "property_id": "${escapeStringForJson(propertyId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Anos com rebanho',
      apiUrl: '$baseUrl/get_rebanho_available_years',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<int>? ano(dynamic response) => (getJsonField(
        response,
        r'''$[:].ano''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class QtdAnimaisMortalidadeCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    int? startYear,
    int? startMonth,
    int? endYear,
    int? endMonth,
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "property_id": "${escapeStringForJson(propertyId)}",
  "start_year": $startYear,
  "start_month": $startMonth,
  "end_year": $endYear,
  "end_month": $endMonth
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Qtd animais mortalidade',
      apiUrl: '$baseUrl/calculate_mortality_rate',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  double? taxaMortalidade(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$[:].taxa_mortalidade''',
      ));
}

class QtdAnimaisDesmamaCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
    int? startYear,
    int? startMonth,
    int? endYear,
    int? endMonth,
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "property_id": "${escapeStringForJson(propertyId)}",
  "start_year": $startYear,
  "start_month": $startMonth,
  "end_year": $endYear,
  "end_month": $endMonth
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Qtd animais desmama',
      apiUrl: '$baseUrl/calculate_weaning_percentage',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? totalAnimais(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].total_animais''',
      ));
  int? totalDesmamados(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$[:].total_desmamados''',
      ));
  double? pctDesmamados(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$[:].percentual_desmamados''',
      ));
}

class CountInseminacaoCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Inseminacao',
      apiUrl: '$baseUrl/contar_reproducao_inseminacao',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CountMontaNaturalCall {
  Future<ApiCallResponse> call({
    String? pIdPropriedade = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(pIdPropriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count Monta Natural',
      apiUrl: '$baseUrl/contar_reproducao_monta',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class BuscarPropriedadesDoUsuarioCall {
  Future<ApiCallResponse> call({
    String? pUserId = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_user_id": "${escapeStringForJson(pUserId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Buscar propriedades do usuario',
      apiUrl: '$baseUrl/propriedades_by_user',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ValidarAcessoUserCall {
  Future<ApiCallResponse> call({
    String? pUserId = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_user_id": "${escapeStringForJson(pUserId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Validar acesso user',
      apiUrl: '$baseUrl/user_acesso',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? acesso(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].acesso''',
      ));
}

class CountRebanhosComLoteCall {
  Future<ApiCallResponse> call({
    String? propriedade = '',
  }) async {
    final baseUrl = FunctionsSupabaseRebanhoGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "p_id_propriedade": "${escapeStringForJson(propriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Count rebanhos com lote',
      apiUrl: '$baseUrl/count_rebanhos_com_lote',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End Functions Supabase Rebanho Group Code

/// Start Supabase Edge Group Code

class SupabaseEdgeGroup {
  static String getBaseUrl() =>
      'https://eqrtgsqnxxnfjjzlxpuj.functions.supabase.co/';
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  static NascimentosPeriodoCall nascimentosPeriodoCall =
      NascimentosPeriodoCall();
  static MortalidadePeriodoCall mortalidadePeriodoCall =
      MortalidadePeriodoCall();
  static DesmamaPeriodoCall desmamaPeriodoCall = DesmamaPeriodoCall();
  static IdadeDesmamaCall idadeDesmamaCall = IdadeDesmamaCall();
  static PesoDesmamaCall pesoDesmamaCall = PesoDesmamaCall();
  static VendidosPorCategoriasPeriodoCall vendidosPorCategoriasPeriodoCall =
      VendidosPorCategoriasPeriodoCall();
  static PrecoMedioCategoriaCall precoMedioCategoriaCall =
      PrecoMedioCategoriaCall();
  static TaxaPrenhezGetCall taxaPrenhezGetCall = TaxaPrenhezGetCall();
  static TaxaNatalidadeGetCall taxaNatalidadeGetCall = TaxaNatalidadeGetCall();
  static ProjecaoDesmamasCall projecaoDesmamasCall = ProjecaoDesmamasCall();
}

class NascimentosPeriodoCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? idPropriedade = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "inicio": "${escapeStringForJson(inicio)}",
  "fim": "${escapeStringForJson(fim)}",
  "agrupar": "mes",
  "idPropriedade": "${escapeStringForJson(idPropriedade)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Nascimentos Periodo',
      apiUrl: '${baseUrl}nascimentos_periodo',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) {
    dynamic decoded = response;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }

    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map && decoded['items'] is List) {
      return decoded['items'] as List;
    }

    return getJsonField(
      response,
      r'''$.items''',
      true,
    ) as List?;
  }

  List<String>? itemsbucketini(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].bucket_ini''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? itemsbucketfim(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].bucket_fim''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? itemslabel(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].label''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? itemstotal(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].total''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? itemsmachos(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].machos''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? itemsfemeas(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].femeas''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class MortalidadePeriodoCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? idPropriedade = '',
    String? causa = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "inicio": "${escapeStringForJson(inicio)}",
  "fim": "${escapeStringForJson(fim)}",
  "agrupar": "mes",
  "idPropriedade": "${escapeStringForJson(idPropriedade)}",
  "causa": "${escapeStringForJson(causa)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Mortalidade periodo',
      apiUrl: '${baseUrl}mortalidade_periodo',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) {
    dynamic decoded = response;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }

    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map && decoded['items'] is List) {
      return decoded['items'] as List;
    }

    return getJsonField(
      response,
      r'''$.items''',
      true,
    ) as List?;
  }
}

class DesmamaPeriodoCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? idPropriedade = '',
    String? agrupar = '',
    String? sexo = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Desmama Periodo',
      apiUrl: '${baseUrl}desmama_periodo',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'inicio': inicio,
        'fim': fim,
        'idPropriedade': idPropriedade,
        'agrupar': agrupar,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) {
    dynamic decoded = response;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }

    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map && decoded['items'] is List) {
      return decoded['items'] as List;
    }

    return getJsonField(
      response,
      r'''$.items''',
      true,
    ) as List?;
  }
}

class IdadeDesmamaCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? sexo = '',
    String? idPropriedade = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Idade Desmama',
      apiUrl: '${baseUrl}idade_desmama_kpi',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'inicio': inicio,
        'fim': fim,
        'sexo': sexo,
        'idPropriedade': idPropriedade,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
      );
}

class PesoDesmamaCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? sexo = '',
    String? idPropriedade = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'peso Desmama',
      apiUrl: '${baseUrl}peso_desmama_kpi',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'inicio': inicio,
        'fim': fim,
        'sexo': sexo,
        'idPropriedade': idPropriedade,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
      );
}

class VendidosPorCategoriasPeriodoCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? idPropriedade = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Vendidos por Categorias Periodo',
      apiUrl: '${baseUrl}vendidos_categoria_periodo',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'inicio': inicio,
        'fim': fim,
        'agrupar': "mes",
        'idPropriedade': idPropriedade,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
        true,
      ) as List?;
}

class PrecoMedioCategoriaCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? idPropriedade = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Preco Medio Categoria',
      apiUrl: '${baseUrl}preco_medio_categoria_periodo',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'inicio': inicio,
        'fim': fim,
        'agrupar': "mes",
        'idPropriedade': idPropriedade,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
      );
}

class TaxaPrenhezGetCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicio = '',
    String? dataFim = '',
    String? pLoteId = '',
    String? pInseminador = '',
    String? pIdRebanhoReprodutor = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    final params = <String, dynamic>{
      'id_propriedade': idPropriedade,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      // Filtros opcionais (se vazios, não são enviados)
      'p_lote_id': pLoteId,
      'p_inseminador': pInseminador,
      'p_id_rebanho_reprodutor': pIdRebanhoReprodutor,
    };
    params.removeWhere((key, value) =>
        value == null || (value is String && value.trim().isEmpty));

    return ApiManager.instance.makeApiCall(
      callName: 'taxa prenhez get',
      apiUrl: '${baseUrl}taxa-prenhez',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<String>? titulo(dynamic response) => (getJsonField(
        response,
        r'''$[:].titulo''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? porcentagem(dynamic response) => (getJsonField(
        response,
        r'''$[:].porcentagem''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class TaxaNatalidadeGetCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicio = '',
    String? dataFim = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'taxa natalidade get',
      apiUrl: '${baseUrl}taxa-natalidade',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'id_propriedade': idPropriedade,
        'data_inicio': dataInicio,
        'data_fim': dataFim,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<String>? titulo(dynamic response) => (getJsonField(
        response,
        r'''$[:].titulo''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? porcentagem(dynamic response) => (getJsonField(
        response,
        r'''$[:].porcentagem''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class ProjecaoDesmamasCall {
  Future<ApiCallResponse> call({
    String? inicio = '',
    String? fim = '',
    String? idPropriedade = '',
    String? agrupar = '',
    String? sexo = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Projecao Desmamas',
      apiUrl: '${baseUrl}projecao_desmamas',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'inicio': inicio,
        'fim': fim,
        'idPropriedade': idPropriedade,
        'agrupar': agrupar,
        'sexo': sexo,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) {
    dynamic decoded = response;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } catch (_) {}
    }

    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map && decoded['items'] is List) {
      return decoded['items'] as List;
    }

    return getJsonField(
      response,
      r'''$.items''',
      true,
    ) as List?;
  }
}

/// End Supabase Edge Group Code

/// Start Supa Edge Group Code

class SupaEdgeGroup {
  static String getBaseUrl() =>
      'https://eqrtgsqnxxnfjjzlxpuj.supabase.co/functions/v1/';
  static Map<String, String> headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
    'Content-Type': 'application/json',
    'apikey':
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
  };
  static ReproducaoPartosCategoriaCall reproducaoPartosCategoriaCall =
      ReproducaoPartosCategoriaCall();
  static ReproducaoProjecaoPartosCall reproducaoProjecaoPartosCall =
      ReproducaoProjecaoPartosCall();
  static ReproducaoAnosCall reproducaoAnosCall = ReproducaoAnosCall();
  static ReproducaoIdadeMediaPrimeraCriaCall
      reproducaoIdadeMediaPrimeraCriaCall =
      ReproducaoIdadeMediaPrimeraCriaCall();
  static IntervaloEntrePartosMesesCall intervaloEntrePartosMesesCall =
      IntervaloEntrePartosMesesCall();
  static ReproducaoDiagnosticosCategoriaCall
      reproducaoDiagnosticosCategoriaCall =
      ReproducaoDiagnosticosCategoriaCall();
  static ReproducaoDiagnosticosPeriodoCall reproducaoDiagnosticosPeriodoCall =
      ReproducaoDiagnosticosPeriodoCall();
}

class ReproducaoPartosCategoriaCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicial = '',
    String? dataFinal = '',
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reproducao Partos Categoria',
      apiUrl: '${baseUrl}reproducao-partos-categoria',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'idPropriedade': idPropriedade,
        'inicio': dataInicial,
        'fim': dataFinal,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
        true,
      ) as List?;
  bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  String? itemsmes(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.items[:].mes''',
      ));
  int? itemsNovilha(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].Novilha''',
      ));
  String? itemslabel(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.items[:].label''',
      ));
  int? itemsPrimpara(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].Primípara''',
      ));
  int? itemsMultpara(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].Multípara''',
      ));
}

class ReproducaoProjecaoPartosCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicial = '',
    String? dataFinal = '',
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reproducao Projecao Partos',
      apiUrl: '${baseUrl}reproducao-projecao-partos',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'idPropriedade': idPropriedade,
        'inicio': dataInicial,
        'fim': dataFinal,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
        true,
      ) as List?;
  List<int>? multpara(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].Multípara''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? primpara(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].Primípara''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? novilha(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].Novilha''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<String>? label(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].label''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? mes(dynamic response) => (getJsonField(
        response,
        r'''$.items[:].mes''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ReproducaoAnosCall {
  Future<ApiCallResponse> call({
    String? propertyId = '',
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reproducao Anos',
      apiUrl: '${baseUrl}get-reproducao-years',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'property_id': propertyId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<int>? ano(dynamic response) => (getJsonField(
        response,
        r'''$[:].ano''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class ReproducaoIdadeMediaPrimeraCriaCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicio = '',
    String? dataFim = '',
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reproducao idade media primera cria',
      apiUrl: '${baseUrl}media-primeira-cria',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'id_propriedade': idPropriedade,
        'data_inicio': dataInicio,
        'data_fim': dataFim,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  List? items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
        true,
      ) as List?;
  double? itemsvalor(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.items[:].valor''',
      ));
  int? itemsn(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].n''',
      ));
}

class IntervaloEntrePartosMesesCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicio = '',
    String? dataFim = '',
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Intervalo entre partos meses',
      apiUrl: '${baseUrl}media-intervalo-partos',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'id_propriedade': idPropriedade,
        'data_inicio': dataInicio,
        'data_fim': dataFim,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End Supa Edge Group Code

class BuscaCidadesCall {
  static Future<ApiCallResponse> call({
    String? uf = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Busca cidades',
      apiUrl:
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$uf/municipios',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? cidades(dynamic response) => (getJsonField(
        response,
        r'''$[:].nome''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ExclusaoDeContaCall {
  static Future<ApiCallResponse> call({
    String? userId = '',
    String? jwt = '',
  }) async {
    final ffApiRequestBody = '''
{
  "p_user_id": "${escapeStringForJson(userId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Exclusao de conta',
      apiUrl:
          'https://eqrtgsqnxxnfjjzlxpuj.supabase.co/rest/v1/rpc/excluir_usuario_completo',
      callType: ApiCallType.POST,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization': 'Bearer $jwt',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AtualizarSenhaCall {
  static Future<ApiCallResponse> call({
    String? userToken = '',
    String? email = '',
    String? password = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Atualizar senha',
      apiUrl: 'https://eqrtgsqnxxnfjjzlxpuj.supabase.co/auth/v1/user',
      callType: ApiCallType.PUT,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Authorization': 'Bearer $userToken',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ImportRebanhosCall {
  static Future<ApiCallResponse> call({
    dynamic jsonRebanhoJson,
  }) async {
    final jsonRebanho = _serializeJson(jsonRebanhoJson, true);

    return ApiManager.instance.makeApiCall(
      callName: 'Import Rebanhos',
      apiUrl:
          'https://eqrtgsqnxxnfjjzlxpuj.supabase.co/functions/v1/import-rebanho',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'rebanhoData': jsonRebanho,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ImportAnimaisCall {
  static Future<ApiCallResponse> call({
    dynamic jsonRebanhoJson,
  }) async {
    final jsonRebanho = _serializeJson(jsonRebanhoJson, true);
    final ffApiRequestBody = '''
{
  "animais": [
    $jsonRebanho
  ],
  "operacao": "insert"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Import Animais',
      apiUrl:
          'https://eqrtgsqnxxnfjjzlxpuj.supabase.co/functions/v1/rebanho-import',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GerasrPdfCall {
  static Future<ApiCallResponse> call({
    String? nome = '',
    String? telefone = '',
  }) async {
    final ffApiRequestBody = '''
{
  "nome": "${escapeStringForJson(nome)}",
  "telefone": "${escapeStringForJson(telefone)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'gerasr pdf',
      apiUrl: 'pdf.com',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

// ignore: unused_element
String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

class ReproducaoDiagnosticosCategoriaCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    String? dataInicial = '',
    String? dataFinal = '',
    String? categoria = '',
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reproducao Diagnosticos Categoria',
      apiUrl: '${baseUrl}reproducao-diagnosticos-categoria',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'idPropriedade': idPropriedade,
        'inicio': dataInicial,
        'fim': dataFinal,
        if (categoria != null && categoria != '' && categoria != 'Todos') 'categoria': categoria,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
        true,
      ) as List?;
  bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  String? itemsperiodo(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.items[:].periodo''',
      ));
  String? itemslabel(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.items[:].label''',
      ));
  int? itemsNovilha(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].Novilha''',
      ));
  int? itemsPrimpara(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].Primípara''',
      ));
  int? itemsMultpara(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].Multípara''',
      ));
}

class ReproducaoDiagnosticosPeriodoCall {
  Future<ApiCallResponse> call({
    String? idPropriedade = '',
    int? mes = 1,
    int? ano = 2023,
  }) async {
    final baseUrl = SupaEdgeGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Reproducao Diagnosticos Periodo',
      apiUrl: '${baseUrl}reproducao-diagnosticos-periodo',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxcnRnc3FueHhuZmpqemx4cHVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjkwNjgsImV4cCI6MjA2MjgwNTA2OH0.OIpsBOdszJWSjFeeZeNTu4WQySocdJIygMWpYRYc-tM',
      },
      params: {
        'idPropriedade': idPropriedade,
        'mes': mes?.toString(),
        'ano': ano?.toString(),
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List? items(dynamic response) => getJsonField(
        response,
        r'''$.items''',
        true,
      ) as List?;
  bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.items''',
      ));
  String? itemssituacao(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.items[:].situacao''',
      ));
  int? itemstotal(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.items[:].total''',
      ));
  double? itemsporcentagem(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.items[:].porcentagem''',
      ));
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
