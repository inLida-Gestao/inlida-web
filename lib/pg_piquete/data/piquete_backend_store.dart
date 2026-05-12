import 'package:flutter/foundation.dart';

import 'piquete_models.dart';
import 'piquete_repository.dart';
import '../prototype/piquete_prototype_store.dart';

class PiqueteBackendStore extends ChangeNotifier {
  PiqueteBackendStore._();

  static final PiqueteBackendStore instance = PiqueteBackendStore._();

  final PiqueteRepository _repository = const PiqueteRepository();

  final List<RetiroPrototype> _retiros = [];
  final List<PiquetePrototype> _piquetes = [];
  final List<AnimalPrototype> _animais = [];
  final List<LotePrototype> _lotes = [];
  final Map<String, List<PiqueteHistoricoEvent>> _historicoPorPiquete = {};

  bool loading = false;
  String? errorMessage;
  String? selectedRetiroId;
  int totalPiquetes = 0;
  int totalAnimais = 0;
  int totalLotes = 0;

  List<RetiroPrototype> get retiros => List.unmodifiable(_retiros);
  List<PiquetePrototype> get piquetes => List.unmodifiable(_piquetes);
  List<AnimalPrototype> get animais => List.unmodifiable(_animais);
  List<LotePrototype> get lotes => List.unmodifiable(_lotes);
  List<PiqueteHistoricoEvent> historicoDoPiquete(String? piqueteId) {
    if (piqueteId == null) return const [];
    return List.unmodifiable(_historicoPorPiquete[piqueteId] ?? const []);
  }

  RetiroPrototype? get selectedRetiro =>
      retiroById(selectedRetiroId) ?? _retiros.firstOrNull;

  Future<void> load() async {
    await _run(() async {
      final summaries = await _repository.listarRetirosComResumo();
      _retiros
        ..clear()
        ..addAll(summaries.map((summary) => summary.retiro));

      totalPiquetes = summaries.fold<int>(
        0,
        (total, summary) => total + summary.piquetesCount,
      );
      totalAnimais = summaries.fold<int>(
        0,
        (total, summary) => total + summary.animaisCount,
      );
      totalLotes = summaries.fold<int>(
        0,
        (total, summary) => total + summary.lotesCount,
      );

      if (_retiros.isEmpty) {
        selectedRetiroId = null;
        _piquetes.clear();
        return;
      }

      if (selectedRetiroId == null || retiroById(selectedRetiroId) == null) {
        selectedRetiroId = _retiros.first.id;
      }

      await _loadPiquetesDoRetiro(selectedRetiroId!);
    });
  }

  Future<void> selectRetiro(String retiroId) async {
    selectedRetiroId = retiroId;
    await _run(() => _loadPiquetesDoRetiro(retiroId));
  }

  Future<void> loadOptions({String piqueteId = ''}) async {
    await _run(() => _loadOptionsRaw(piqueteId: piqueteId));
  }

  Future<PiquetePrototype?> loadPiqueteDetail(String piqueteId) async {
    PiquetePrototype? loaded;
    await _run(() async {
      final detail = await _repository.buscarPiqueteDetalhe(piqueteId);
      final historico = await _repository.buscarPiqueteHistorico(
        detail.piquete.id,
      );
      selectedRetiroId = detail.piquete.retiroId;
      await _loadPiquetesDoRetiro(detail.piquete.retiroId);
      loaded = detail.piquete;
      _upsertPiquete(detail.piquete);
      _historicoPorPiquete[detail.piquete.id] = historico;
      await _loadOptionsRaw(piqueteId: detail.piquete.id);
    });
    return loaded;
  }

  Future<void> _loadOptionsRaw({String piqueteId = ''}) async {
    final animaisFuture =
        _repository.buscarAnimaisDisponiveis(piqueteId: piqueteId);
    final lotesFuture =
        _repository.buscarLotesDisponiveis(piqueteId: piqueteId);
    final animais = await animaisFuture;
    final lotes = await lotesFuture;
    _animais
      ..clear()
      ..addAll(animais.map((option) => option.animal));
    _lotes
      ..clear()
      ..addAll(lotes.map((option) => option.lote));
  }

  List<PiquetePrototype> piquetesDoRetiro(String? retiroId) {
    final id = retiroId ?? selectedRetiro?.id;
    if (id == null) return [];
    return _piquetes.where((p) => p.retiroId == id).toList();
  }

  RetiroPrototype? retiroById(String? id) {
    if (id == null) return null;
    return _retiros.where((r) => r.id == id).firstOrNull;
  }

  PiquetePrototype? piqueteById(String? id) {
    if (id == null) return null;
    return _piquetes.where((p) => p.id == id).firstOrNull;
  }

  List<AnimalPrototype> animaisByIds(Iterable<String> ids) {
    final idSet = ids.toSet();
    return _animais.where((a) => idSet.contains(a.id)).toList();
  }

  List<LotePrototype> lotesByIds(Iterable<String> ids) {
    final idSet = ids.toSet();
    return _lotes.where((l) => idSet.contains(l.id)).toList();
  }

  List<AnimalPrototype> animaisDisponiveis({String? exceptPiqueteId}) =>
      List.unmodifiable(_animais);

  List<LotePrototype> lotesDisponiveis({String? exceptPiqueteId}) =>
      List.unmodifiable(_lotes);

  int get totalAnimaisEmPiquetes => totalAnimais;

  int get totalLotesEmPiquetes => totalLotes;

  Future<RetiroPrototype> addRetiro({
    required String nome,
    required double areaHa,
    required String anotacoes,
    required List<MapPoint> pontos,
  }) async {
    late RetiroPrototype retiro;
    await _run(() async {
      final summary = await _repository.salvarRetiro(
        nome: nome,
        areaHa: areaHa,
        anotacoes: anotacoes,
        pontos: pontos,
      );
      retiro = summary.retiro;
      _upsertRetiro(retiro);
      selectedRetiroId = retiro.id;
      await _loadPiquetesDoRetiro(retiro.id);
      await load();
    });
    return retiro;
  }

  Future<PiquetePrototype> addPiquete({
    required String retiroId,
    required String nome,
    required double areaHa,
    required List<String> forrageiras,
    required String anotacoes,
    required List<MapPoint> pontos,
    required List<String> animaisIds,
    required List<String> lotesIds,
  }) async {
    late PiquetePrototype piquete;
    await _run(() async {
      final detail = await _repository.salvarPiquete(
        retiroId: retiroId,
        nome: nome,
        areaHa: areaHa,
        forrageiras: forrageiras,
        anotacoes: anotacoes,
        pontos: pontos,
        animaisIds: animaisIds,
        lotesIds: lotesIds,
      );
      piquete = detail.piquete;
      _upsertPiquete(piquete);
      selectedRetiroId = retiroId;
      await load();
    });
    return piquete;
  }

  Future<PiquetePrototype> updatePiquete(PiquetePrototype piquete) async {
    late PiquetePrototype updated;
    await _run(() async {
      final detail = await _repository.salvarPiquete(
        piqueteId: piquete.id,
        retiroId: piquete.retiroId,
        nome: piquete.nome,
        areaHa: piquete.areaHa,
        forrageiras: piquete.forrageiras,
        anotacoes: piquete.anotacoes,
        pontos: piquete.pontos,
        animaisIds: piquete.animaisIds,
        lotesIds: piquete.lotesIds,
      );
      updated = detail.piquete;
      _upsertPiquete(updated);
      selectedRetiroId = updated.retiroId;
      await load();
    });
    return updated;
  }

  Future<void> deletePiquete(String piqueteId) async {
    await _run(() async {
      await _repository.excluirPiquete(piqueteId);
      _piquetes.removeWhere((piquete) => piquete.id == piqueteId);
      await load();
    });
  }

  List<MapPoint> exampleRetiroPoints() {
    return const [
      MapPoint.fromLatLng(-15.7828, -47.9038),
      MapPoint.fromLatLng(-15.7816, -47.8844),
      MapPoint.fromLatLng(-15.7952, -47.8812),
      MapPoint.fromLatLng(-15.7991, -47.8976),
    ];
  }

  List<MapPoint> examplePiquetePoints() {
    return const [
      MapPoint.fromLatLng(-15.7861, -47.8974),
      MapPoint.fromLatLng(-15.7847, -47.8906),
      MapPoint.fromLatLng(-15.7909, -47.8889),
      MapPoint.fromLatLng(-15.7921, -47.8952),
    ];
  }

  Future<void> _loadPiquetesDoRetiro(String retiroId) async {
    final detalhes = await _repository.listarPiquetesPorRetiro(
      retiroId: retiroId,
    );
    _piquetes.removeWhere((piquete) => piquete.retiroId == retiroId);
    _piquetes.addAll(detalhes.map((detail) => detail.piquete));
  }

  Future<void> _run(Future<void> Function() action) async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on PiqueteRepositoryException catch (error) {
      errorMessage = error.message;
      rethrow;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _upsertRetiro(RetiroPrototype retiro) {
    final index = _retiros.indexWhere((item) => item.id == retiro.id);
    if (index == -1) {
      _retiros.add(retiro);
    } else {
      _retiros[index] = retiro;
    }
  }

  void _upsertPiquete(PiquetePrototype piquete) {
    final index = _piquetes.indexWhere((item) => item.id == piquete.id);
    if (index == -1) {
      _piquetes.add(piquete);
    } else {
      _piquetes[index] = piquete;
    }
  }
}
