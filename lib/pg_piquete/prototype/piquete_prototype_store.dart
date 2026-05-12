import 'package:flutter/foundation.dart';

class MapPoint {
  const MapPoint(this.latitude, this.longitude);

  const MapPoint.fromLatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class RetiroPrototype {
  const RetiroPrototype({
    required this.id,
    required this.nome,
    required this.areaHa,
    required this.anotacoes,
    required this.pontos,
    this.piquetesCount = 0,
    this.animaisCount = 0,
    this.lotesCount = 0,
    this.forrageiras = const [],
  });

  final String id;
  final String nome;
  final double areaHa;
  final String anotacoes;
  final List<MapPoint> pontos;
  final int piquetesCount;
  final int animaisCount;
  final int lotesCount;
  final List<String> forrageiras;

  RetiroPrototype copyWith({
    String? nome,
    double? areaHa,
    String? anotacoes,
    List<MapPoint>? pontos,
    int? piquetesCount,
    int? animaisCount,
    int? lotesCount,
    List<String>? forrageiras,
  }) =>
      RetiroPrototype(
        id: id,
        nome: nome ?? this.nome,
        areaHa: areaHa ?? this.areaHa,
        anotacoes: anotacoes ?? this.anotacoes,
        pontos: pontos ?? this.pontos,
        piquetesCount: piquetesCount ?? this.piquetesCount,
        animaisCount: animaisCount ?? this.animaisCount,
        lotesCount: lotesCount ?? this.lotesCount,
        forrageiras: forrageiras ?? this.forrageiras,
      );
}

class PiquetePrototype {
  const PiquetePrototype({
    required this.id,
    required this.retiroId,
    required this.nome,
    required this.areaHa,
    required this.forrageiras,
    required this.anotacoes,
    required this.pontos,
    required this.animaisIds,
    required this.lotesIds,
    this.animaisCount = 0,
    this.lotesCount = 0,
    this.animaisLotesCount = 0,
  });

  final String id;
  final String retiroId;
  final String nome;
  final double areaHa;
  final List<String> forrageiras;
  final String anotacoes;
  final List<MapPoint> pontos;
  final List<String> animaisIds;
  final List<String> lotesIds;
  final int animaisCount;
  final int lotesCount;
  final int animaisLotesCount;

  bool get contemAnimais => animaisIds.isNotEmpty || animaisCount > 0;
  bool get contemLotes => lotesIds.isNotEmpty || lotesCount > 0;
  int get totalAnimaisIndividuais =>
      animaisCount > 0 ? animaisCount : animaisIds.length;
  int get totalLotes => lotesCount > 0 ? lotesCount : lotesIds.length;
  bool get misto => contemAnimais && contemLotes;
  String get forrageira => forrageiras.join(', ');
  String get conteudoLabel {
    if (misto) return 'Misto';
    if (contemAnimais) return 'Animais individuais';
    if (contemLotes) return 'Lotes inteiros';
    return 'Vazio';
  }

  PiquetePrototype copyWith({
    String? retiroId,
    String? nome,
    double? areaHa,
    List<String>? forrageiras,
    String? anotacoes,
    List<MapPoint>? pontos,
    List<String>? animaisIds,
    List<String>? lotesIds,
    int? animaisCount,
    int? lotesCount,
    int? animaisLotesCount,
  }) =>
      PiquetePrototype(
        id: id,
        retiroId: retiroId ?? this.retiroId,
        nome: nome ?? this.nome,
        areaHa: areaHa ?? this.areaHa,
        forrageiras: forrageiras ?? this.forrageiras,
        anotacoes: anotacoes ?? this.anotacoes,
        pontos: pontos ?? this.pontos,
        animaisIds: animaisIds ?? this.animaisIds,
        lotesIds: lotesIds ?? this.lotesIds,
        animaisCount: animaisCount ?? this.animaisCount,
        lotesCount: lotesCount ?? this.lotesCount,
        animaisLotesCount: animaisLotesCount ?? this.animaisLotesCount,
      );
}

class AnimalPrototype {
  const AnimalPrototype({
    required this.id,
    required this.numero,
    required this.nome,
    required this.sexo,
    required this.categoria,
    required this.raca,
    required this.dataNascimento,
    required this.loteNome,
  });

  final String id;
  final String numero;
  final String nome;
  final String sexo;
  final String categoria;
  final String raca;
  final String dataNascimento;
  final String loteNome;
}

class LotePrototype {
  const LotePrototype({
    required this.id,
    required this.nome,
    required this.qtdAnimais,
    required this.status,
  });

  final String id;
  final String nome;
  final int qtdAnimais;
  final String status;
}

class PiquetePrototypeStore extends ChangeNotifier {
  PiquetePrototypeStore._();

  static final PiquetePrototypeStore instance = PiquetePrototypeStore._()
    .._seed();

  final List<RetiroPrototype> _retiros = [];
  final List<PiquetePrototype> _piquetes = [];
  final List<AnimalPrototype> _animais = [];
  final List<LotePrototype> _lotes = [];

  String? selectedRetiroId;
  int _counter = 100;

  List<RetiroPrototype> get retiros => List.unmodifiable(_retiros);
  List<PiquetePrototype> get piquetes => List.unmodifiable(_piquetes);
  List<AnimalPrototype> get animais => List.unmodifiable(_animais);
  List<LotePrototype> get lotes => List.unmodifiable(_lotes);

  RetiroPrototype? get selectedRetiro =>
      retiroById(selectedRetiroId) ?? _retiros.firstOrNull;

  List<PiquetePrototype> piquetesDoRetiro(String? retiroId) {
    final id = retiroId ?? selectedRetiro?.id;
    if (id == null) return [];
    return _piquetes.where((p) => p.retiroId == id).toList();
  }

  int get totalAnimaisEmPiquetes =>
      _piquetes.expand((p) => p.animaisIds).toSet().length;

  int get totalLotesEmPiquetes =>
      _piquetes.expand((p) => p.lotesIds).toSet().length;

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

  List<AnimalPrototype> animaisDisponiveis({String? exceptPiqueteId}) {
    final ocupados = _piquetes
        .where((p) => p.id != exceptPiqueteId)
        .expand((p) => p.animaisIds)
        .toSet();
    return _animais.where((a) => !ocupados.contains(a.id)).toList();
  }

  List<LotePrototype> lotesDisponiveis({String? exceptPiqueteId}) {
    final ocupados = _piquetes
        .where((p) => p.id != exceptPiqueteId)
        .expand((p) => p.lotesIds)
        .toSet();
    return _lotes.where((l) => !ocupados.contains(l.id)).toList();
  }

  RetiroPrototype addRetiro({
    required String nome,
    required double areaHa,
    required String anotacoes,
    required List<MapPoint> pontos,
  }) {
    final retiro = RetiroPrototype(
      id: _nextId('ret'),
      nome: nome,
      areaHa: areaHa,
      anotacoes: anotacoes,
      pontos: pontos,
    );
    _retiros.add(retiro);
    selectedRetiroId = retiro.id;
    notifyListeners();
    return retiro;
  }

  void updateRetiro(RetiroPrototype retiro) {
    final index = _retiros.indexWhere((r) => r.id == retiro.id);
    if (index == -1) return;
    _retiros[index] = retiro;
    notifyListeners();
  }

  PiquetePrototype addPiquete({
    required String retiroId,
    required String nome,
    required double areaHa,
    required List<String> forrageiras,
    required String anotacoes,
    required List<MapPoint> pontos,
    required List<String> animaisIds,
    required List<String> lotesIds,
  }) {
    final piquete = PiquetePrototype(
      id: _nextId('piq'),
      retiroId: retiroId,
      nome: nome,
      areaHa: areaHa,
      forrageiras: forrageiras,
      anotacoes: anotacoes,
      pontos: pontos,
      animaisIds: animaisIds,
      lotesIds: lotesIds,
    );
    _piquetes.add(piquete);
    selectedRetiroId = retiroId;
    notifyListeners();
    return piquete;
  }

  void updatePiquete(PiquetePrototype piquete) {
    final index = _piquetes.indexWhere((p) => p.id == piquete.id);
    if (index == -1) return;
    _piquetes[index] = piquete;
    selectedRetiroId = piquete.retiroId;
    notifyListeners();
  }

  void deletePiquete(String id) {
    _piquetes.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  List<MapPoint> exampleRetiroPoints() => const [
        MapPoint(-15.7805, -47.9005),
        MapPoint(-15.7798, -47.8860),
        MapPoint(-15.7890, -47.8835),
        MapPoint(-15.7950, -47.8910),
        MapPoint(-15.7905, -47.9020),
      ];

  List<MapPoint> examplePiquetePoints() => const [
        MapPoint(-15.7830, -47.8960),
        MapPoint(-15.7820, -47.8910),
        MapPoint(-15.7860, -47.8900),
        MapPoint(-15.7870, -47.8960),
      ];

  String _nextId(String prefix) => '$prefix-${_counter++}';

  void _seed() {
    _retiros.addAll([
      RetiroPrototype(
        id: 'ret-1',
        nome: 'Retiro Sede',
        areaHa: 128,
        anotacoes: 'Area principal da propriedade, proxima ao curral.',
        pontos: exampleRetiroPoints(),
      ),
      const RetiroPrototype(
        id: 'ret-2',
        nome: 'Retiro Cachoeira',
        areaHa: 96,
        anotacoes: 'Area com acesso ao curso d agua e sombra natural.',
        pontos: [
          MapPoint(-15.8000, -47.9080),
          MapPoint(-15.7970, -47.8940),
          MapPoint(-15.8060, -47.8890),
          MapPoint(-15.8130, -47.8980),
          MapPoint(-15.8100, -47.9120),
        ],
      ),
    ]);

    selectedRetiroId = 'ret-1';

    _lotes.addAll(const [
      LotePrototype(
          id: 'lote-1',
          nome: 'Vacas leiteiras',
          qtdAnimais: 37,
          status: 'Ativo'),
      LotePrototype(
          id: 'lote-2', nome: 'Novilhas 2024', qtdAnimais: 24, status: 'Ativo'),
      LotePrototype(
          id: 'lote-3',
          nome: 'Bezerros apartados',
          qtdAnimais: 18,
          status: 'Ativo'),
      LotePrototype(
          id: 'lote-4',
          nome: 'Matrizes prenhas',
          qtdAnimais: 42,
          status: 'Ativo'),
      LotePrototype(
          id: 'lote-5', nome: 'Desmama', qtdAnimais: 31, status: 'Inativo'),
    ]);

    _animais.addAll(const [
      AnimalPrototype(
        id: 'ani-1',
        numero: '1986',
        nome: 'Florzinha',
        sexo: 'Femea',
        categoria: 'Vaca multipara',
        raca: 'Holandesa',
        dataNascimento: '24/10/2008',
        loteNome: 'Lote XYZ',
      ),
      AnimalPrototype(
        id: 'ani-2',
        numero: '1987',
        nome: 'Flocos de neve',
        sexo: 'Macho',
        categoria: 'Bezerro',
        raca: 'Holandesa',
        dataNascimento: '24/10/2023',
        loteNome: 'Animal sem lote',
      ),
      AnimalPrototype(
        id: 'ani-3',
        numero: '2011',
        nome: 'Pintada',
        sexo: 'Femea',
        categoria: 'Novilha',
        raca: 'Girolando',
        dataNascimento: '08/03/2022',
        loteNome: 'Novilhas 2024',
      ),
      AnimalPrototype(
        id: 'ani-4',
        numero: '2045',
        nome: 'Estrela',
        sexo: 'Femea',
        categoria: 'Vaca',
        raca: 'Jersey',
        dataNascimento: '12/07/2019',
        loteNome: 'Vacas leiteiras',
      ),
      AnimalPrototype(
        id: 'ani-5',
        numero: '2078',
        nome: 'Trovão',
        sexo: 'Macho',
        categoria: 'Touro',
        raca: 'Nelore',
        dataNascimento: '11/11/2020',
        loteNome: 'Matrizes prenhas',
      ),
    ]);

    _piquetes.addAll([
      PiquetePrototype(
        id: 'piq-1',
        retiroId: 'ret-1',
        nome: 'Tradição Campeira',
        areaHa: 23,
        forrageiras: const ['Brachiaria ruziensis', 'Tifton 85'],
        anotacoes: 'Piquete em descanso programado para pastejo rotacionado.',
        pontos: examplePiquetePoints(),
        animaisIds: const ['ani-1', 'ani-2'],
        lotesIds: const ['lote-1'],
      ),
      const PiquetePrototype(
        id: 'piq-2',
        retiroId: 'ret-1',
        nome: 'Capim Novo',
        areaHa: 18,
        forrageiras: ['Massai (Panicum maximum)', 'Mombaça'],
        anotacoes: 'Area nova para recria.',
        pontos: [
          MapPoint(-15.7830, -47.8900),
          MapPoint(-15.7815, -47.8860),
          MapPoint(-15.7855, -47.8845),
          MapPoint(-15.7870, -47.8890),
        ],
        animaisIds: ['ani-3'],
        lotesIds: ['lote-2', 'lote-3'],
      ),
    ]);
  }
}
