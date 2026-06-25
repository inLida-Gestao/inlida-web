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
    String pesquisa = '',
    int limite = 50,
    int offset = 0,
    String status = '',
    String sexo = '',
    String categoria = '',
    String raca = '',
    String origem = '',
    String lote = '',
    String dataNascimentoDe = '',
    String dataNascimentoAte = '',
  }) async {
    final response = await _rpc(
      'buscar_animais_disponiveis_piquete',
      {
        'p_id_propriedade': idPropriedade,
        'p_piquete_id': piqueteId,
      },
    );
    return _filterAnimalOptions(
      _asList(response),
      pesquisa: pesquisa,
      limite: limite,
      offset: offset,
      status: status,
      sexo: sexo,
      categoria: categoria,
      raca: raca,
      origem: origem,
      lote: lote,
      dataNascimentoDe: dataNascimentoDe,
      dataNascimentoAte: dataNascimentoAte,
    ).map((item) => AnimalPiqueteOption.fromJson(item)).toList();
  }

  Future<List<LotePiqueteOption>> buscarLotesDisponiveis({
    String piqueteId = '',
    String pesquisa = '',
    int limite = 50,
    int offset = 0,
    String status = '',
    String dataCriacaoDe = '',
    String dataCriacaoAte = '',
  }) async {
    final response = await _rpc(
      'buscar_lotes_disponiveis_piquete',
      {
        'p_id_propriedade': idPropriedade,
        'p_piquete_id': piqueteId,
      },
    );
    return _filterLoteOptions(
      _asList(response),
      pesquisa: pesquisa,
      limite: limite,
      offset: offset,
      status: status,
      dataCriacaoDe: dataCriacaoDe,
      dataCriacaoAte: dataCriacaoAte,
    ).map((item) => LotePiqueteOption.fromJson(item)).toList();
  }

  Future<List<AnimalPiqueteOption>> buscarAnimaisPorIds(
    Iterable<String> animaisIds,
  ) async {
    final ids = animaisIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (ids.isEmpty) return const [];

    final response = await _rpc(
      'buscar_animais_piquete_por_ids',
      {
        'p_id_propriedade': idPropriedade,
        'p_animais_ids': ids,
      },
    );
    return _asList(response)
        .map((item) => AnimalPiqueteOption.fromJson(item))
        .toList();
  }

  Future<List<LotePiqueteOption>> buscarLotesPorIds(
    Iterable<String> lotesIds,
  ) async {
    final ids = lotesIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (ids.isEmpty) return const [];

    final response = await _rpc(
      'buscar_lotes_piquete_por_ids',
      {
        'p_id_propriedade': idPropriedade,
        'p_lotes_ids': ids,
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

  List<Map<String, dynamic>> _filterAnimalOptions(
    List<Map<String, dynamic>> items, {
    required String pesquisa,
    required int limite,
    required int offset,
    required String status,
    required String sexo,
    required String categoria,
    required String raca,
    required String origem,
    required String lote,
    required String dataNascimentoDe,
    required String dataNascimentoAte,
  }) {
    final query = pesquisa.trim().toLowerCase();
    final normalizedStatus = status.trim().toLowerCase();
    final normalizedSexo = sexo.trim().toLowerCase();
    final normalizedCategoria = categoria.trim().toLowerCase();
    final normalizedRaca = raca.trim().toLowerCase();
    final normalizedOrigem = origem.trim().toLowerCase();
    final normalizedLote = lote.trim().toLowerCase();
    final fromDate = _parseDateFilter(dataNascimentoDe);
    final toDate = _parseDateFilter(dataNascimentoAte);
    final normalizedLimit = limite.clamp(1, 200);
    final normalizedOffset = offset < 0 ? 0 : offset;

    final filtered = items.where((item) {
      final numero = _normalizedOptionValue(item['numero']);
      final nome = _normalizedOptionValue(item['nome']);
      final itemStatus = _normalizedOptionValue(item['status']);
      final itemSexo = _normalizedOptionValue(item['sexo']);
      final itemCategoria = _normalizedOptionValue(item['categoria']);
      final itemRaca = _normalizedOptionValue(item['raca']);
      final itemOrigem = _normalizedOptionValue(item['origem']);
      final loteNome = _normalizedOptionValue(item['lote_nome']);
      final loteId = _normalizedOptionValue(item['lote_id']);
      final nascimento = _parseDateFilter(item['data_nascimento']?.toString());

      if (query.isNotEmpty &&
          !numero.contains(query) &&
          !nome.contains(query) &&
          !itemCategoria.contains(query) &&
          !loteNome.contains(query)) {
        return false;
      }
      if (normalizedStatus.isNotEmpty && itemStatus != normalizedStatus) {
        return false;
      }
      if (normalizedSexo.isNotEmpty && itemSexo != normalizedSexo) {
        return false;
      }
      if (normalizedCategoria.isNotEmpty &&
          itemCategoria != normalizedCategoria) {
        return false;
      }
      if (normalizedRaca.isNotEmpty && itemRaca != normalizedRaca) {
        return false;
      }
      if (normalizedOrigem.isNotEmpty && itemOrigem != normalizedOrigem) {
        return false;
      }
      if (normalizedLote.isNotEmpty &&
          loteId != normalizedLote &&
          !loteNome.contains(normalizedLote)) {
        return false;
      }
      if (fromDate != null &&
          (nascimento == null || nascimento.isBefore(fromDate))) {
        return false;
      }
      if (toDate != null &&
          (nascimento == null || nascimento.isAfter(toDate))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final numeroCompare = _normalizedOptionValue(a['numero'])
            .compareTo(_normalizedOptionValue(b['numero']));
        if (numeroCompare != 0) return numeroCompare;
        final nomeCompare = _normalizedOptionValue(a['nome'])
            .compareTo(_normalizedOptionValue(b['nome']));
        if (nomeCompare != 0) return nomeCompare;
        return _normalizedOptionValue(a['id'])
            .compareTo(_normalizedOptionValue(b['id']));
      });

    return filtered.skip(normalizedOffset).take(normalizedLimit).toList();
  }

  String _normalizedOptionValue(dynamic value) =>
      (value?.toString() ?? '').trim().toLowerCase();

  DateTime? _parseDateFilter(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw.length > 10 ? raw.substring(0, 10) : raw);
  }

  List<Map<String, dynamic>> _filterLoteOptions(
    List<Map<String, dynamic>> items, {
    required String pesquisa,
    required int limite,
    required int offset,
    required String status,
    required String dataCriacaoDe,
    required String dataCriacaoAte,
  }) {
    final query = pesquisa.trim().toLowerCase();
    final normalizedStatus = status.trim().toLowerCase();
    final fromDate = _parseDateFilter(dataCriacaoDe);
    final toDate = _parseDateFilter(dataCriacaoAte);
    final normalizedLimit = limite.clamp(1, 200);
    final normalizedOffset = offset < 0 ? 0 : offset;

    final filtered = items.where((item) {
      final id = _normalizedOptionValue(item['id']);
      final nome = _normalizedOptionValue(item['nome']);
      final itemStatus = _normalizedOptionValue(item['status']);
      final createdAt = _parseDateFilter(item['created_at']?.toString());

      if (query.isNotEmpty && !id.contains(query) && !nome.contains(query)) {
        return false;
      }
      if (normalizedStatus.isNotEmpty && itemStatus != normalizedStatus) {
        return false;
      }
      if (fromDate != null &&
          (createdAt == null || createdAt.isBefore(fromDate))) {
        return false;
      }
      if (toDate != null && (createdAt == null || createdAt.isAfter(toDate))) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final nomeCompare = _normalizedOptionValue(a['nome'])
            .compareTo(_normalizedOptionValue(b['nome']));
        if (nomeCompare != 0) return nomeCompare;
        return _normalizedOptionValue(a['id'])
            .compareTo(_normalizedOptionValue(b['id']));
      });

    return filtered.skip(normalizedOffset).take(normalizedLimit).toList();
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
