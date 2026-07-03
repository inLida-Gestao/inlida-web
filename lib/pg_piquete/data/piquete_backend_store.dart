import 'package:flutter/foundation.dart';

import 'piquete_models.dart';
import 'piquete_repository.dart';
import '../prototype/piquete_prototype_store.dart';

class PiqueteBackendStore extends ChangeNotifier {
  PiqueteBackendStore._();

  static final PiqueteBackendStore instance = PiqueteBackendStore._();
  static const optionsPageSize = 50;

  final PiqueteRepository _repository = const PiqueteRepository();

  final List<RetiroPrototype> _retiros = [];
  final List<PiquetePrototype> _piquetes = [];
  final List<AnimalPrototype> _animais = [];
  final List<LotePrototype> _lotes = [];
  final Map<String, List<PiqueteHistoricoEvent>> _historicoPorPiquete = {};
  LimitePropriedadePrototype? _limitePropriedade;

  static const semRetiroId = '';

  String? _loadedPropertyId;
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
  LimitePropriedadePrototype? get limitePropriedade => _limitePropriedade;
  bool get temLimitePropriedade => _limitePropriedade != null;
  double get areaUsadaNoLimiteHa => _limitePropriedade?.areaUsadaHa ?? 0;
  double get areaDisponivelNoLimiteHa =>
      _limitePropriedade?.areaDisponivelHa ?? 0;
  List<PiqueteHistoricoEvent> historicoDoPiquete(String? piqueteId) {
    if (piqueteId == null) return const [];
    return List.unmodifiable(_historicoPorPiquete[piqueteId] ?? const []);
  }

  RetiroPrototype? get selectedRetiro {
    final id = selectedRetiroId;
    if (id == null || id.isEmpty) return null;
    return retiroById(id);
  }

  bool get mostrandoPiquetesSemRetiro =>
      selectedRetiroId == semRetiroId || _retiros.isEmpty;

  List<PiquetePrototype> get piquetesSemRetiro =>
      _piquetes.where((p) => p.retiroId.isEmpty).toList();

  Future<void> load() async {
    await _run(() async {
      _syncPropertyContext();
      final limiteFuture = _repository.buscarLimitePropriedade();
      final summariesFuture = _repository.listarRetirosComResumo();
      final piquetesSemRetiroFuture = _repository.listarPiquetesSemRetiro();
      final limite = await limiteFuture;
      final summaries = await summariesFuture;
      final piquetesSemRetiro = await piquetesSemRetiroFuture;
      _limitePropriedade = limite?.limite;
      _retiros
        ..clear()
        ..addAll(summaries.map((summary) => summary.retiro));
      _piquetes
        ..clear()
        ..addAll(piquetesSemRetiro.map((detail) => detail.piquete));

      totalPiquetes = summaries.fold<int>(
        piquetesSemRetiro.length,
        (total, summary) => total + summary.piquetesCount,
      );
      totalAnimais = summaries.fold<int>(
        _totalAnimaisDosPiquetes(
          piquetesSemRetiro.map((detail) => detail.piquete),
        ),
        (total, summary) => total + summary.animaisCount,
      );
      totalLotes = summaries.fold<int>(
        piquetesSemRetiro.fold<int>(
          0,
          (total, detail) => total + detail.piquete.totalLotes,
        ),
        (total, summary) => total + summary.lotesCount,
      );

      if (_retiros.isEmpty) {
        selectedRetiroId = semRetiroId;
        return;
      }

      selectedRetiroId ??= _retiros.first.id;

      if (selectedRetiroId!.isNotEmpty &&
          retiroById(selectedRetiroId) == null) {
        selectedRetiroId = _retiros.first.id;
      }

      if (selectedRetiroId!.isEmpty) {
        await _loadPiquetesSemRetiro();
      } else {
        await _loadPiquetesDoRetiro(selectedRetiroId!);
      }
    });
  }

  Future<void> selectRetiro(String retiroId) async {
    if (retiroId.isEmpty) {
      await _run(() async {
        _syncPropertyContext();
        selectedRetiroId = retiroId;
        await _loadPiquetesSemRetiro();
      });
      return;
    }
    await _run(() async {
      _syncPropertyContext();
      selectedRetiroId = retiroId;
      await _loadPiquetesDoRetiro(retiroId);
    });
  }

  Future<void> selectPiquetesSemRetiro() async {
    await _run(() async {
      _syncPropertyContext();
      selectedRetiroId = semRetiroId;
      await _loadPiquetesSemRetiro();
    });
  }

  Future<void> loadAllPiqueteAreas() async {
    await _run(() async {
      _syncPropertyContext();
      await _loadPiquetesSemRetiro();
      await Future.wait(
        _retiros.map((retiro) => _loadPiquetesDoRetiro(retiro.id)),
      );
    });
  }

  Future<void> loadOptions({String piqueteId = ''}) async {
    await _run(() async {
      _syncPropertyContext();
      await _loadOptionsRaw(piqueteId: piqueteId, limit: optionsPageSize);
    });
  }

  Future<PiquetePrototype?> loadPiqueteDetail(String piqueteId) async {
    PiquetePrototype? loaded;
    await _run(() async {
      _syncPropertyContext();
      final detail = await _repository.buscarPiqueteDetalhe(piqueteId);
      final historico = await _repository.buscarPiqueteHistorico(
        detail.piquete.id,
      );
      selectedRetiroId = detail.piquete.retiroId;
      if (detail.piquete.retiroId.isEmpty) {
        await _loadPiquetesSemRetiro();
      } else {
        await _loadPiquetesDoRetiro(detail.piquete.retiroId);
      }
      loaded = detail.piquete;
      _upsertPiquete(detail.piquete);
      _historicoPorPiquete[detail.piquete.id] = historico;
      await ensureSelectedOptions(
        animaisIds: {
          ...detail.piquete.animaisIds,
          ..._animalIdsFromHistorico(historico),
        },
        lotesIds: detail.piquete.lotesIds,
      );
    });
    return loaded;
  }

  Set<String> _animalIdsFromHistorico(List<PiqueteHistoricoEvent> historico) {
    return historico
        .where((event) => event.tipo.contains('animal'))
        .map(_animalIdFromHistoricoEvent)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  String _animalIdFromHistoricoEvent(PiqueteHistoricoEvent event) {
    for (final key in ['id_rebanho', 'idRebanho', 'animal_id', 'id']) {
      final value = event.metadata[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return event.entidadeId.trim();
  }

  Future<void> _loadOptionsRaw({
    String piqueteId = '',
    int limit = optionsPageSize,
  }) async {
    final animaisFuture = _repository.buscarAnimaisDisponiveis(
      piqueteId: piqueteId,
      limite: limit,
      offset: 0,
    );
    final lotesFuture = _repository.buscarLotesDisponiveis(
      piqueteId: piqueteId,
      limite: limit,
      offset: 0,
    );
    final animais = await animaisFuture;
    final lotes = await lotesFuture;
    _upsertAnimais(animais.map((option) => option.animal));
    _upsertLotes(lotes.map((option) => option.lote));
  }

  Future<PiqueteOptionsPage<AnimalPrototype>> buscarAnimaisDisponiveisPage({
    String piqueteId = '',
    String pesquisa = '',
    int offset = 0,
    int limit = optionsPageSize,
    String status = '',
    String sexo = '',
    String categoria = '',
    String raca = '',
    String origem = '',
    String lote = '',
    String dataNascimentoDe = '',
    String dataNascimentoAte = '',
  }) async {
    try {
      _syncPropertyContext();
      final options = await _repository.buscarAnimaisDisponiveis(
        piqueteId: piqueteId,
        pesquisa: pesquisa,
        limite: limit + 1,
        offset: offset,
        status: status,
        sexo: sexo,
        categoria: categoria,
        raca: raca,
        origem: origem,
        lote: lote,
        dataNascimentoDe: dataNascimentoDe,
        dataNascimentoAte: dataNascimentoAte,
      );
      final animais = options.map((option) => option.animal).toList();
      final hasNext = animais.length > limit;
      final pageItems = hasNext ? animais.take(limit).toList() : animais;
      _upsertAnimais(pageItems);
      errorMessage = null;
      notifyListeners();
      return PiqueteOptionsPage(
        items: pageItems,
        offset: offset,
        limit: limit,
        hasNext: hasNext,
      );
    } on PiqueteRepositoryException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<PiqueteOptionsPage<LotePrototype>> buscarLotesDisponiveisPage({
    String piqueteId = '',
    String pesquisa = '',
    int offset = 0,
    int limit = optionsPageSize,
    String status = '',
    String dataCriacaoDe = '',
    String dataCriacaoAte = '',
  }) async {
    try {
      _syncPropertyContext();
      final options = await _repository.buscarLotesDisponiveis(
        piqueteId: piqueteId,
        pesquisa: pesquisa,
        limite: limit + 1,
        offset: offset,
        status: status,
        dataCriacaoDe: dataCriacaoDe,
        dataCriacaoAte: dataCriacaoAte,
      );
      final lotes = options.map((option) => option.lote).toList();
      final hasNext = lotes.length > limit;
      final pageItems = hasNext ? lotes.take(limit).toList() : lotes;
      _upsertLotes(pageItems);
      errorMessage = null;
      notifyListeners();
      return PiqueteOptionsPage(
        items: pageItems,
        offset: offset,
        limit: limit,
        hasNext: hasNext,
      );
    } on PiqueteRepositoryException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> ensureSelectedOptions({
    Iterable<String> animaisIds = const [],
    Iterable<String> lotesIds = const [],
  }) async {
    _syncPropertyContext();
    final missingAnimais = animaisIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && animaisByIds([id]).isEmpty)
        .toSet();
    final missingLotes = lotesIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && lotesByIds([id]).isEmpty)
        .toSet();

    if (missingAnimais.isEmpty && missingLotes.isEmpty) return;

    try {
      final animaisFuture = missingAnimais.isEmpty
          ? Future<List<AnimalPiqueteOption>>.value(const [])
          : _repository.buscarAnimaisPorIds(missingAnimais);
      final lotesFuture = missingLotes.isEmpty
          ? Future<List<LotePiqueteOption>>.value(const [])
          : _repository.buscarLotesPorIds(missingLotes);
      final animais = await animaisFuture;
      final lotes = await lotesFuture;
      _upsertAnimais(animais.map((option) => option.animal));
      _upsertLotes(lotes.map((option) => option.lote));
      errorMessage = null;
      notifyListeners();
    } on PiqueteRepositoryException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      rethrow;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<PiquetePrototype> piquetesDoRetiro(String? retiroId) {
    final id = retiroId ?? selectedRetiroId;
    if (id == null) return [];
    if (id.isEmpty) return piquetesSemRetiro;
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
      _syncPropertyContext();
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

  Future<LimitePropriedadePrototype> saveLimitePropriedade({
    LimitePropriedadePrototype? limite,
    required String nome,
    required double areaHa,
    required String anotacoes,
    required List<MapPoint> pontos,
  }) async {
    late LimitePropriedadePrototype saved;
    await _run(() async {
      _syncPropertyContext();
      final summary = await _repository.salvarLimitePropriedade(
        limiteId: limite?.id ?? '',
        nome: nome,
        areaHa: areaHa,
        anotacoes: anotacoes,
        pontos: pontos,
      );
      saved = summary.limite;
      _limitePropriedade = saved;
      await load();
    });
    return saved;
  }

  Future<void> deleteLimitePropriedade(String limiteId) async {
    await _run(() async {
      _syncPropertyContext();
      await _repository.excluirLimitePropriedade(limiteId);
      _limitePropriedade = null;
      await load();
    });
  }

  Future<RetiroPrototype> updateRetiro({
    required RetiroPrototype retiro,
    required String nome,
    required double areaHa,
    required String anotacoes,
    required List<MapPoint> pontos,
  }) async {
    late RetiroPrototype updated;
    await _run(() async {
      _syncPropertyContext();
      final summary = await _repository.salvarRetiro(
        retiroId: retiro.id,
        nome: nome,
        areaHa: areaHa,
        anotacoes: anotacoes,
        pontos: pontos,
      );
      updated = summary.retiro;
      _upsertRetiro(updated);
      selectedRetiroId = updated.id;
      await _loadPiquetesDoRetiro(updated.id);
      await load();
    });
    return updated;
  }

  Future<void> deleteRetiro(String retiroId) async {
    await _run(() async {
      _syncPropertyContext();
      await _repository.excluirRetiro(retiroId);
      _retiros.removeWhere((retiro) => retiro.id == retiroId);
      if (selectedRetiroId == retiroId) {
        selectedRetiroId = semRetiroId;
      }
      await load();
    });
  }

  Future<PiquetePrototype> addPiquete({
    String retiroId = '',
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
      _syncPropertyContext();
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
      selectedRetiroId = piquete.retiroId;
      await load();
    });
    return piquete;
  }

  Future<PiquetePrototype> updatePiquete(PiquetePrototype piquete) async {
    late PiquetePrototype updated;
    await _run(() async {
      _syncPropertyContext();
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
      _syncPropertyContext();
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
    if (retiroId.isEmpty) {
      await _loadPiquetesSemRetiro();
      return;
    }
    final detalhes = await _repository.listarPiquetesPorRetiro(
      retiroId: retiroId,
    );
    _piquetes.removeWhere((piquete) => piquete.retiroId == retiroId);
    _piquetes.addAll(detalhes.map((detail) => detail.piquete));
  }

  Future<void> _loadPiquetesSemRetiro() async {
    final detalhes = await _repository.listarPiquetesSemRetiro();
    _piquetes.removeWhere((piquete) => piquete.retiroId.isEmpty);
    _piquetes.addAll(detalhes.map((detail) => detail.piquete));
  }

  void _syncPropertyContext() {
    final currentPropertyId = _repository.idPropriedade;
    if (_loadedPropertyId == currentPropertyId) return;

    _loadedPropertyId = currentPropertyId;
    _limitePropriedade = null;
    _retiros.clear();
    _piquetes.clear();
    _animais.clear();
    _lotes.clear();
    _historicoPorPiquete.clear();
    selectedRetiroId = null;
    totalPiquetes = 0;
    totalAnimais = 0;
    totalLotes = 0;
  }

  int _totalAnimaisDosPiquetes(Iterable<PiquetePrototype> piquetes) {
    return piquetes.fold<int>(
      0,
      (total, piquete) =>
          total + piquete.totalAnimaisIndividuais + piquete.animaisLotesCount,
    );
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

  void _upsertAnimais(Iterable<AnimalPrototype> animais) {
    for (final animal in animais) {
      final index = _animais.indexWhere((item) => item.id == animal.id);
      if (index == -1) {
        _animais.add(animal);
      } else {
        _animais[index] = animal;
      }
    }
  }

  void _upsertLotes(Iterable<LotePrototype> lotes) {
    for (final lote in lotes) {
      final index = _lotes.indexWhere((item) => item.id == lote.id);
      if (index == -1) {
        _lotes.add(lote);
      } else {
        _lotes[index] = lote;
      }
    }
  }
}

class PiqueteOptionsPage<T> {
  const PiqueteOptionsPage({
    required this.items,
    required this.offset,
    required this.limit,
    required this.hasNext,
  });

  final List<T> items;
  final int offset;
  final int limit;
  final bool hasNext;

  bool get hasPrevious => offset > 0;
  int get firstItemNumber => items.isEmpty ? 0 : offset + 1;
  int get lastItemNumber => offset + items.length;
}
