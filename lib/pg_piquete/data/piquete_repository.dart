import 'dart:convert';

import '/app_state.dart';
import '/backend/supabase/supabase.dart';
import 'piquete_geojson_mapper.dart';
import 'piquete_models.dart';
import '../prototype/piquete_prototype_store.dart';

class PiqueteRepository {
  const PiqueteRepository();

  String get idPropriedade {
    final id = FFAppState().propriedadeSelecionada.idPropriedade.trim();
    if (id.isEmpty) {
      throw const PiqueteRepositoryException(
        'Selecione uma propriedade antes de acessar os piquetes.',
      );
    }
    return id;
  }

  Future<List<RetiroBackendSummary>> listarRetirosComResumo() async {
    final response = await _rpc(
      'listar_retiros_com_resumo',
      {'p_id_propriedade': idPropriedade},
    );
    return _asList(response)
        .map((item) => RetiroBackendSummary.fromJson(item))
        .toList();
  }

  Future<LimitePropriedadeBackendSummary?> buscarLimitePropriedade() async {
    dynamic response;
    try {
      response = await _rpc(
        'buscar_limite_propriedade',
        {'p_id_propriedade': idPropriedade},
      );
    } on PiqueteRepositoryException catch (error) {
      if (!_isMissingRpcError(error.message, 'buscar_limite_propriedade')) {
        rethrow;
      }
      return null;
    }
    final map = _asMap(response);
    if (map.isEmpty) return null;
    return LimitePropriedadeBackendSummary.fromJson(map);
  }

  Future<List<PiqueteBackendDetail>> listarPiquetesPorRetiro({
    required String retiroId,
    String pesquisa = '',
  }) async {
    final response = await _rpc(
      'listar_piquetes_por_retiro',
      {
        'p_retiro_id': retiroId,
        'p_pesquisa': pesquisa,
        'p_forrageiras': <String>[],
        'p_limite': 100,
        'p_offset': 0,
      },
    );
    return _asList(response)
        .map((item) => PiqueteBackendDetail.fromJson(item))
        .toList();
  }

  Future<List<PiqueteBackendDetail>> listarPiquetesSemRetiro({
    String pesquisa = '',
  }) async {
    dynamic response;
    try {
      response = await _rpc(
        'listar_piquetes_sem_retiro',
        {
          'p_id_propriedade': idPropriedade,
          'p_pesquisa': pesquisa,
          'p_forrageiras': <String>[],
          'p_limite': 100,
          'p_offset': 0,
        },
      );
    } on PiqueteRepositoryException catch (error) {
      if (!_isMissingRpcError(error.message, 'listar_piquetes_sem_retiro')) {
        rethrow;
      }
      return const [];
    }
    return _asList(response)
        .map((item) => PiqueteBackendDetail.fromJson(item))
        .toList();
  }

  Future<PiqueteBackendDetail> buscarPiqueteDetalhe(String piqueteId) async {
    final response = await _rpc(
      'buscar_piquete_detalhe',
      {
        'p_piquete_id': piqueteId,
        'p_id_propriedade': idPropriedade,
      },
    );
    return PiqueteBackendDetail.fromJson(_asMap(response));
  }

  Future<List<PiqueteHistoricoEvent>> buscarPiqueteHistorico(
    String piqueteId,
  ) async {
    try {
      final response = await SupaFlow.client
          .from('piquete_movimentacoes')
          .select()
          .eq('id_propriedade', idPropriedade)
          .eq('piquete_id', piqueteId)
          .order('created_at', ascending: false)
          .limit(100);

      return _asList(response)
          .map((item) => PiqueteHistoricoEvent.fromJson(item))
          .toList();
    } catch (error) {
      throw PiqueteRepositoryException(_friendlyError(error));
    }
  }

  Future<List<AnimalPiqueteOption>> buscarAnimaisDisponiveis({
    String piqueteId = '',
  }) async {
    final response = await _rpc(
      'buscar_animais_disponiveis_piquete',
      {
        'p_id_propriedade': idPropriedade,
        'p_piquete_id': piqueteId,
      },
    );
    return _asList(response)
        .map((item) => AnimalPiqueteOption.fromJson(item))
        .toList();
  }

  Future<List<LotePiqueteOption>> buscarLotesDisponiveis({
    String piqueteId = '',
  }) async {
    final response = await _rpc(
      'buscar_lotes_disponiveis_piquete',
      {
        'p_id_propriedade': idPropriedade,
        'p_piquete_id': piqueteId,
      },
    );
    return _asList(response)
        .map((item) => LotePiqueteOption.fromJson(item))
        .toList();
  }

  Future<RetiroBackendSummary> salvarRetiro({
    String retiroId = '',
    required String nome,
    required double areaHa,
    required String anotacoes,
    required List<MapPoint> pontos,
  }) async {
    final response = await _rpc(
      'salvar_retiro',
      {
        'p_retiro_id': retiroId,
        'p_id_propriedade': idPropriedade,
        'p_nome': nome,
        'p_area_informada_ha': areaHa,
        'p_anotacoes': anotacoes,
        'p_geojson': PiqueteGeoJsonMapper.polygonFromPoints(pontos),
      },
    );
    return RetiroBackendSummary.fromJson(_asMap(response));
  }

  Future<LimitePropriedadeBackendSummary> salvarLimitePropriedade({
    String limiteId = '',
    required String nome,
    required double areaHa,
    required String anotacoes,
    required List<MapPoint> pontos,
  }) async {
    final response = await _rpc(
      'salvar_limite_propriedade',
      {
        'p_limite_id': limiteId,
        'p_id_propriedade': idPropriedade,
        'p_nome': nome,
        'p_area_informada_ha': areaHa,
        'p_anotacoes': anotacoes,
        'p_geojson': PiqueteGeoJsonMapper.polygonFromPoints(pontos),
      },
    );
    return LimitePropriedadeBackendSummary.fromJson(_asMap(response));
  }

  Future<void> excluirLimitePropriedade(String limiteId) async {
    await _rpc(
      'excluir_limite_propriedade',
      {
        'p_limite_id': limiteId,
        'p_id_propriedade': idPropriedade,
      },
    );
  }

  Future<PiqueteBackendDetail> salvarPiquete({
    String piqueteId = '',
    String retiroId = '',
    required String nome,
    required double areaHa,
    required List<String> forrageiras,
    required String anotacoes,
    required List<MapPoint> pontos,
    required List<String> animaisIds,
    required List<String> lotesIds,
  }) async {
    final response = await _rpc(
      'salvar_piquete',
      {
        'p_piquete_id': piqueteId,
        'p_retiro_id': retiroId,
        'p_id_propriedade': idPropriedade,
        'p_nome': nome,
        'p_area_informada_ha': areaHa,
        'p_forrageiras': forrageiras,
        'p_anotacoes': anotacoes,
        'p_geojson': PiqueteGeoJsonMapper.polygonFromPoints(pontos),
        'p_animais_ids': animaisIds,
        'p_lotes_ids': lotesIds,
      },
    );
    return PiqueteBackendDetail.fromJson(_asMap(response));
  }

  Future<void> excluirPiquete(String piqueteId) async {
    await _rpc(
      'excluir_piquete',
      {
        'p_piquete_id': piqueteId,
        'p_id_propriedade': idPropriedade,
      },
    );
  }

  Future<void> excluirRetiro(String retiroId) async {
    await _rpc(
      'excluir_retiro',
      {
        'p_retiro_id': retiroId,
        'p_id_propriedade': idPropriedade,
      },
    );
  }

  Future<dynamic> _rpc(String name, Map<String, dynamic> params) async {
    try {
      return _decode(await SupaFlow.client.rpc(name, params: params));
    } catch (error) {
      throw PiqueteRepositoryException(_friendlyError(error));
    }
  }

  dynamic _decode(dynamic value) {
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (_) {
        return value;
      }
    }
    return value;
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    final decoded = _decode(value);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    final decoded = _decode(value);
    if (decoded is Map) return decoded.cast<String, dynamic>();
    return const {};
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    final match = RegExp(r'message: ([^,}]+)').firstMatch(message);
    if (match != null) return match.group(1)?.trim() ?? message;
    return message.replaceFirst('Exception: ', '');
  }

  bool _isMissingRpcError(String message, String functionName) {
    final normalized = message.toLowerCase();
    return normalized.contains(functionName.toLowerCase()) &&
        (normalized.contains('could not find') ||
            normalized.contains('not found') ||
            normalized.contains('pgrst202'));
  }
}

class PiqueteRepositoryException implements Exception {
  const PiqueteRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
