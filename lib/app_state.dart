import 'package:flutter/material.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  static const List<String> _kVacinacaoOptions = <String>[
    'Aftosa',
    'Antitetânica',
    'Botulismo',
    'Brucelose',
    'Clostridiose',
    'Diarréia (BVD)',
    'Doença Respiratória (DBR)',
    'Leptospirose',
    'Parainfluenza e herpes',
    'Raiva',
    'Rinotraqueíte (IBR)',
  ];

  static const List<String> _kTratamentoOptions = <String>[
    'Anestésico, Sedativo & Similares',
    'Analgésico',
    'Anti-inflamatório',
    'Anti-séptico',
    'Antibiótico',
    'Castração Química',
    'Complexo Vitamínico & Mineral',
    'Homeopático',
    'Hormônio',
  ];

  static const List<String> _kAntiparasitarioOptions = <String>[
    'Abamectina',
    'Abendazol',
    'Babesiose (Tristeza Bovina) & Tripanossoma',
    'Brinco mosquicida',
    'Carrapaticida & Mosquicida (PourON)',
    'Carrapaticida & Mosquicida (Pulverização)',
    'Deltrametrina, Imidocarp, Nitroxinil & Triclofon',
    'Doramectina',
    'Eprinomectina',
    'Ivermectina',
    'Levamisol',
    'Moxidectina',
  ];

  static const List<String> _kProtocoloReprodutivoOptions = <String>[
    'D0-D7-D9',
    'D0-D8-D10',
    'D0-D9-D11',
    'D0-D7-D9-D11',
  ];

  static const List<String> _kRacaOptions = <String>[
    'Aberdeen',
    'Angus Black',
    'Angus Red',
    'Bonsmara',
    'Boran',
    'Braford',
    'Brahman',
    'Brangus',
    'Caracu',
    'Charolês',
    'Devon Red',
    'Gir',
    'Girolando',
    'Guzerá',
    'Hereford',
    'Holandês',
    'Jersey',
    'Limousin',
    'Marchigiana',
    'Mestiço',
    'Nelore',
    'Nelore PO',
    'Pardo Suíço (CORTE)',
    'Pardo Suíço (Leite)',
    'Santa Gertrudis',
    'Senepol',
    'Simental',
    'Sindi',
    'Sindinel',
    'Tabapuã',
    'Ultrablack',
    'Wagyu',
  ];

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _navegacao = prefs.getString('ff_navegacao') ?? _navegacao;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_propriedadeSelecionada')) {
        try {
          final serializedData =
              prefs.getString('ff_propriedadeSelecionada') ?? '{}';
          _propriedadeSelecionada = PropriedadesDTStruct.fromSerializableMap(
              jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _propriedadeEdit =
          prefs.getString('ff_propriedadeEdit') ?? _propriedadeEdit;
    });
    _safeInit(() {
      _raca = prefs.getStringList('ff_raca') ?? _raca;
      if (!_listEquals(_raca, _kRacaOptions)) {
        _raca = _kRacaOptions.toList();
        prefs.setStringList('ff_raca', _raca);
      }
    });
    _safeInit(() {
      _statusRebanho =
          prefs.getStringList('ff_statusRebanho') ?? _statusRebanho;
    });
    _safeInit(() {
      _origemRebanho =
          prefs.getStringList('ff_origemRebanho') ?? _origemRebanho;
    });
    _safeInit(() {
      _vacinacao = prefs.getStringList('ff_vacinacao') ?? _vacinacao;
      // Normalize persisted values to the canonical list used by the UI.
      if (!_listEquals(_vacinacao, _kVacinacaoOptions)) {
        _vacinacao = _kVacinacaoOptions.toList();
        prefs.setStringList('ff_vacinacao', _vacinacao);
      }
    });
    _safeInit(() {
      _tratamento = prefs.getStringList('ff_tratamento') ?? _tratamento;
      // Normalize persisted values to the canonical list used by the UI.
      if (!_listEquals(_tratamento, _kTratamentoOptions)) {
        _tratamento = _kTratamentoOptions.toList();
        prefs.setStringList('ff_tratamento', _tratamento);
      }
    });
    _safeInit(() {
      _antiparasitario =
          prefs.getStringList('ff_antiparasitario') ?? _antiparasitario;
      // Normalize persisted values to the canonical list used by the UI.
      if (!_listEquals(_antiparasitario, _kAntiparasitarioOptions)) {
        _antiparasitario = _kAntiparasitarioOptions.toList();
        prefs.setStringList('ff_antiparasitario', _antiparasitario);
      }
    });
    _safeInit(() {
      _protocoloReprodutivo = prefs.getStringList('ff_protocoloReprodutivo') ??
          _protocoloReprodutivo;
      // Normalize persisted values to the canonical list used by the UI.
      if (!_listEquals(_protocoloReprodutivo, _kProtocoloReprodutivoOptions)) {
        _protocoloReprodutivo = _kProtocoloReprodutivoOptions.toList();
        prefs.setStringList('ff_protocoloReprodutivo', _protocoloReprodutivo);
      }
    });
    _safeInit(() {
      _anos = prefs
              .getStringList('ff_anos')
              ?.map((x) {
                try {
                  return AnosStruct.fromSerializableMap(jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _anos;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  // --- Refresh callback system ---
  final Map<String, List<VoidCallback>> _refreshCallbacks = {};

  /// Register a callback to be called when a specific refresh flag is set.
  /// Returns a dispose function that removes the callback.
  VoidCallback onRefresh(String key, VoidCallback callback) {
    _refreshCallbacks.putIfAbsent(key, () => []);
    _refreshCallbacks[key]!.add(callback);
    return () => _refreshCallbacks[key]?.remove(callback);
  }

  void _notifyRefresh(String key) {
    final callbacks = _refreshCallbacks[key];
    if (callbacks != null) {
      for (final cb in List.of(callbacks)) {
        cb();
      }
    }
  }

  /// Chamado quando o usuário troca a propriedade no dropdown.
  ///
  /// Fluxo de invalidação:
  /// 1. Persiste a nova propriedade.
  /// 2. Reseta **todos** os campos `filtro*` para valores default — se um novo
  ///    filtro for adicionado ao app, ele **deve** ser resetado aqui também.
  /// 3. Seta todas as flags `refresh*` e notifica via `_notifyRefresh`, o que
  ///    faz cada página ouvinte invalidar seu `Completer<ApiCallResponse>` e
  ///    disparar um novo fetch com os filtros limpos.
  /// 4. Chama `notifyListeners()` uma única vez para reconstruir a árvore.
  ///
  /// Padrão Completer nas páginas de lista:
  /// - Cada página usa `_model.apiRequestCompleterN` (1 para count, 2 para dados).
  /// - Quando `refresh*` é `true`, o callback registrado via `onRefresh` seta
  ///   `apiRequestCompleterN = null` e chama `safeSetState`, forçando o
  ///   `FutureBuilder` a criar um novo `Completer` e refazer a chamada à RPC.
  /// - Isso garante que trocar propriedade, aplicar filtro ou pesquisar sempre
  ///   resulta em dados frescos sem cache stale.
  void onPropriedadeChanged(PropriedadesDTStruct novaProp) {
    // 1. Atualizar propriedade selecionada com persistência
    _propriedadeSelecionada = novaProp;
    prefs.setString('ff_propriedadeSelecionada', novaProp.serialize());

    // 2. Resetar todos os filtros para valores padrão
    _filtroCategoria = '';
    _filtroSexo = '';
    _filtroStatusRebanho = '';
    _filtroRaca = '';
    _filtroOrigem = '';
    _filtroLoteNome = '';
    _filtroLoteId = '';
    _filtroDataNacimentoDe = null;
    _filtroDataNacimentoAte = null;
    _filtroStatusLote = '';
    _filtroDataCriacaoLoteDe = null;
    _filtroDataCriacaoLoteAte = null;
    _filtroCidadeProp = '';
    _filtroUFProp = '';
    _filtroCategoriaRepro = '';
    _filtroInseminador = '';
    _filtroIDMatriz = '';
    _filtroIDReprodutor = '';
    _filtroDataReproducaoDe = null;
    _filtroDataReproducaoAte = null;
    _filtroDataPartoDe = null;
    _filtroDataPartoAte = null;
    _filtroDataDiagnosticoDe = null;
    _filtroDataDiagnosticoAte = null;
    _filtroPiqueteForrageira = '';
    _filtroAreaMin = 0;
    _filtroAreaMax = 9999;
    _filtroDataSanidadeDe = null;
    _filtroDataSanidadeAte = null;
    _filtroLoteSanidade = '';
    _filtroAnimalSanidade = '';
    _filtroSexoSanidade = '';
    _filtroRacaSanidade = '';
    _filtroCategoriaSanidade = '';
    _filtroTratamentoSanidade = '';
    _filtroProtocolo = '';
    _filtroAntiparasitario = '';
    _filtroVacinacao = '';
    _filtroNascimentoSanidadeDe = null;
    _filtroNascimentoSanidadeAte = null;
    _filtroDataDiagnostico = null;

    // Seleção de matriz/reprodutor (ex.: aba Progênie em edição de animal) não
    // deve vazar para a lista de reprodução após troca de propriedade.
    _matrizSelecionada = AnimalSelecionadoStruct();
    _reprodutorSelecionado = AnimalSelecionadoStruct();

    // 3. Setar TODAS as flags de refresh (usando campos privados
    // para evitar o notifyListeners extra do setter de refreshReproducao)
    _refreshRebanho = true;
    _notifyRefresh('refreshRebanho');
    _refreshReproducao = true;
    _notifyRefresh('refreshReproducao');
    _refreshLotes = true;
    _notifyRefresh('refreshLotes');
    _refreshPiquete = true;
    _notifyRefresh('refreshPiquete');
    _refreshSanidade = true;
    _notifyRefresh('refreshSanidade');
    _refreshPainel = true;
    _notifyRefresh('refreshPainel');

    // 4. Notificar todos os listeners uma única vez
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _navegacao = '';
  String get navegacao => _navegacao;
  set navegacao(String value) {
    _navegacao = value;
    prefs.setString('ff_navegacao', value);
  }

  PropriedadesDTStruct _propriedadeSelecionada = PropriedadesDTStruct();
  PropriedadesDTStruct get propriedadeSelecionada => _propriedadeSelecionada;
  set propriedadeSelecionada(PropriedadesDTStruct value) {
    _propriedadeSelecionada = value;
    prefs.setString('ff_propriedadeSelecionada', value.serialize());
  }

  void updatePropriedadeSelecionadaStruct(
      Function(PropriedadesDTStruct) updateFn) {
    updateFn(_propriedadeSelecionada);
    prefs.setString(
        'ff_propriedadeSelecionada', _propriedadeSelecionada.serialize());
  }

  String _filtroCidadeProp = '';
  String get filtroCidadeProp => _filtroCidadeProp;
  set filtroCidadeProp(String value) {
    _filtroCidadeProp = value;
  }

  String _filtroUFProp = '';
  String get filtroUFProp => _filtroUFProp;
  set filtroUFProp(String value) {
    _filtroUFProp = value;
  }

  List<String> _filtroAtividades = [];
  List<String> get filtroAtividades => _filtroAtividades;
  set filtroAtividades(List<String> value) {
    _filtroAtividades = value;
  }

  void addToFiltroAtividades(String value) {
    filtroAtividades.add(value);
  }

  void removeFromFiltroAtividades(String value) {
    filtroAtividades.remove(value);
  }

  void removeAtIndexFromFiltroAtividades(int index) {
    filtroAtividades.removeAt(index);
  }

  void updateFiltroAtividadesAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    filtroAtividades[index] = updateFn(_filtroAtividades[index]);
  }

  void insertAtIndexInFiltroAtividades(int index, String value) {
    filtroAtividades.insert(index, value);
  }

  double _filtroQtdAnimais = 0.0;
  double get filtroQtdAnimais => _filtroQtdAnimais;
  set filtroQtdAnimais(double value) {
    _filtroQtdAnimais = value;
  }

  bool _refreshPropriedades = false;
  bool get refreshPropriedades => _refreshPropriedades;
  set refreshPropriedades(bool value) {
    _refreshPropriedades = value;
    if (value) _notifyRefresh('refreshPropriedades');
  }

  List<UsersDTStruct> _usersPropriedade = [];
  List<UsersDTStruct> get usersPropriedade => _usersPropriedade;
  set usersPropriedade(List<UsersDTStruct> value) {
    _usersPropriedade = value;
  }

  void addToUsersPropriedade(UsersDTStruct value) {
    usersPropriedade.add(value);
  }

  void removeFromUsersPropriedade(UsersDTStruct value) {
    usersPropriedade.remove(value);
  }

  void removeAtIndexFromUsersPropriedade(int index) {
    usersPropriedade.removeAt(index);
  }

  void updateUsersPropriedadeAtIndex(
    int index,
    UsersDTStruct Function(UsersDTStruct) updateFn,
  ) {
    usersPropriedade[index] = updateFn(_usersPropriedade[index]);
  }

  void insertAtIndexInUsersPropriedade(int index, UsersDTStruct value) {
    usersPropriedade.insert(index, value);
  }

  String _pagePropriedades = 'home';
  String get pagePropriedades => _pagePropriedades;
  set pagePropriedades(String value) {
    _pagePropriedades = value;
  }

  bool _refreshEditProp = false;
  bool get refreshEditProp => _refreshEditProp;
  set refreshEditProp(bool value) {
    _refreshEditProp = value;
    if (value) _notifyRefresh('refreshEditProp');
  }

  String _propriedadeEdit = '';
  String get propriedadeEdit => _propriedadeEdit;
  set propriedadeEdit(String value) {
    _propriedadeEdit = value;
    prefs.setString('ff_propriedadeEdit', value);
  }

  int _totalrow = 0;
  int get totalrow => _totalrow;
  set totalrow(int value) {
    _totalrow = value;
  }

  int _currentrow = 0;
  int get currentrow => _currentrow;
  set currentrow(int value) {
    _currentrow = value;
  }

  List<dynamic> _jsonLista = [];
  List<dynamic> get jsonLista => _jsonLista;
  set jsonLista(List<dynamic> value) {
    _jsonLista = value;
  }

  void addToJsonLista(dynamic value) {
    jsonLista.add(value);
  }

  void removeFromJsonLista(dynamic value) {
    jsonLista.remove(value);
  }

  void removeAtIndexFromJsonLista(int index) {
    jsonLista.removeAt(index);
  }

  void updateJsonListaAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    jsonLista[index] = updateFn(_jsonLista[index]);
  }

  void insertAtIndexInJsonLista(int index, dynamic value) {
    jsonLista.insert(index, value);
  }

  int _qtdAnimaisRebanho = 0;
  int get qtdAnimaisRebanho => _qtdAnimaisRebanho;
  set qtdAnimaisRebanho(int value) {
    _qtdAnimaisRebanho = value;
  }

  int _qtdAnimaisNaPropriedade = 0;
  int get qtdAnimaisNaPropriedade => _qtdAnimaisNaPropriedade;
  set qtdAnimaisNaPropriedade(int value) {
    _qtdAnimaisNaPropriedade = value;
  }

  bool _refreshRebanho = false;
  bool get refreshRebanho => _refreshRebanho;
  set refreshRebanho(bool value) {
    _refreshRebanho = value;
    if (value) _notifyRefresh('refreshRebanho');
  }

  List<String> _raca = List<String>.from(_kRacaOptions);
  List<String> get raca => _raca;
  set raca(List<String> value) {
    _raca = value;
    prefs.setStringList('ff_raca', value);
  }

  void addToRaca(String value) {
    raca.add(value);
    prefs.setStringList('ff_raca', _raca);
  }

  void removeFromRaca(String value) {
    raca.remove(value);
    prefs.setStringList('ff_raca', _raca);
  }

  void removeAtIndexFromRaca(int index) {
    raca.removeAt(index);
    prefs.setStringList('ff_raca', _raca);
  }

  void updateRacaAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    raca[index] = updateFn(_raca[index]);
    prefs.setStringList('ff_raca', _raca);
  }

  void insertAtIndexInRaca(int index, String value) {
    raca.insert(index, value);
    prefs.setStringList('ff_raca', _raca);
  }

  List<LotesDTStruct> _rebanhoLotesSelecionar = [];
  List<LotesDTStruct> get rebanhoLotesSelecionar => _rebanhoLotesSelecionar;
  set rebanhoLotesSelecionar(List<LotesDTStruct> value) {
    _rebanhoLotesSelecionar = value;
  }

  void addToRebanhoLotesSelecionar(LotesDTStruct value) {
    rebanhoLotesSelecionar.add(value);
  }

  void removeFromRebanhoLotesSelecionar(LotesDTStruct value) {
    rebanhoLotesSelecionar.remove(value);
  }

  void removeAtIndexFromRebanhoLotesSelecionar(int index) {
    rebanhoLotesSelecionar.removeAt(index);
  }

  void updateRebanhoLotesSelecionarAtIndex(
    int index,
    LotesDTStruct Function(LotesDTStruct) updateFn,
  ) {
    rebanhoLotesSelecionar[index] = updateFn(_rebanhoLotesSelecionar[index]);
  }

  void insertAtIndexInRebanhoLotesSelecionar(int index, LotesDTStruct value) {
    rebanhoLotesSelecionar.insert(index, value);
  }

  List<String> _statusRebanho = [
    'Sêmen',
    'Vendido',
    'Na propriedade',
    'Fora da propriedade',
    'Morto',
    'Movimentação'
  ];
  List<String> get statusRebanho => _statusRebanho;
  set statusRebanho(List<String> value) {
    _statusRebanho = value;
    prefs.setStringList('ff_statusRebanho', value);
  }

  void addToStatusRebanho(String value) {
    statusRebanho.add(value);
    prefs.setStringList('ff_statusRebanho', _statusRebanho);
  }

  void removeFromStatusRebanho(String value) {
    statusRebanho.remove(value);
    prefs.setStringList('ff_statusRebanho', _statusRebanho);
  }

  void removeAtIndexFromStatusRebanho(int index) {
    statusRebanho.removeAt(index);
    prefs.setStringList('ff_statusRebanho', _statusRebanho);
  }

  void updateStatusRebanhoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    statusRebanho[index] = updateFn(_statusRebanho[index]);
    prefs.setStringList('ff_statusRebanho', _statusRebanho);
  }

  void insertAtIndexInStatusRebanho(int index, String value) {
    statusRebanho.insert(index, value);
    prefs.setStringList('ff_statusRebanho', _statusRebanho);
  }

  List<String> _origemRebanho = ['Compra', 'Movimentação', 'Nascimento'];
  List<String> get origemRebanho => _origemRebanho;
  set origemRebanho(List<String> value) {
    _origemRebanho = value;
    prefs.setStringList('ff_origemRebanho', value);
  }

  void addToOrigemRebanho(String value) {
    origemRebanho.add(value);
    prefs.setStringList('ff_origemRebanho', _origemRebanho);
  }

  void removeFromOrigemRebanho(String value) {
    origemRebanho.remove(value);
    prefs.setStringList('ff_origemRebanho', _origemRebanho);
  }

  void removeAtIndexFromOrigemRebanho(int index) {
    origemRebanho.removeAt(index);
    prefs.setStringList('ff_origemRebanho', _origemRebanho);
  }

  void updateOrigemRebanhoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    origemRebanho[index] = updateFn(_origemRebanho[index]);
    prefs.setStringList('ff_origemRebanho', _origemRebanho);
  }

  void insertAtIndexInOrigemRebanho(int index, String value) {
    origemRebanho.insert(index, value);
    prefs.setStringList('ff_origemRebanho', _origemRebanho);
  }

  String _valueFormat = '';
  String get valueFormat => _valueFormat;
  set valueFormat(String value) {
    _valueFormat = value;
  }

  double _valueDouble = 0.0;
  double get valueDouble => _valueDouble;
  set valueDouble(double value) {
    _valueDouble = value;
  }

  String _filtroSexo = '';
  String get filtroSexo => _filtroSexo;
  set filtroSexo(String value) {
    _filtroSexo = value;
  }

  String _filtroStatusRebanho = '';
  String get filtroStatusRebanho => _filtroStatusRebanho;
  set filtroStatusRebanho(String value) {
    _filtroStatusRebanho = value;
  }

  String _filtroCategoria = '';
  String get filtroCategoria => _filtroCategoria;
  set filtroCategoria(String value) {
    _filtroCategoria = value;
  }

  DateTime? _filtroDataNacimentoDe;
  DateTime? get filtroDataNacimentoDe => _filtroDataNacimentoDe;
  set filtroDataNacimentoDe(DateTime? value) {
    _filtroDataNacimentoDe = value;
  }

  DateTime? _filtroDataNacimentoAte;
  DateTime? get filtroDataNacimentoAte => _filtroDataNacimentoAte;
  set filtroDataNacimentoAte(DateTime? value) {
    _filtroDataNacimentoAte = value;
  }

  String _filtroLoteId = '';
  String get filtroLoteId => _filtroLoteId;
  set filtroLoteId(String value) {
    _filtroLoteId = value;
  }

  String _filtroRaca = '';
  String get filtroRaca => _filtroRaca;
  set filtroRaca(String value) {
    _filtroRaca = value;
  }

  String _filtroOrigem = '';
  String get filtroOrigem => _filtroOrigem;
  set filtroOrigem(String value) {
    _filtroOrigem = value;
  }

  List<AnimaisStruct> _crias = [];
  List<AnimaisStruct> get crias => _crias;
  set crias(List<AnimaisStruct> value) {
    _crias = value;
  }

  void addToCrias(AnimaisStruct value) {
    crias.add(value);
  }

  void removeFromCrias(AnimaisStruct value) {
    crias.remove(value);
  }

  void removeAtIndexFromCrias(int index) {
    crias.removeAt(index);
  }

  void updateCriasAtIndex(
    int index,
    AnimaisStruct Function(AnimaisStruct) updateFn,
  ) {
    crias[index] = updateFn(_crias[index]);
  }

  void insertAtIndexInCrias(int index, AnimaisStruct value) {
    crias.insert(index, value);
  }

  List<HistoricoPesagensStruct> _histPesagens = [];
  List<HistoricoPesagensStruct> get histPesagens => _histPesagens;
  set histPesagens(List<HistoricoPesagensStruct> value) {
    _histPesagens = value;
  }

  void addToHistPesagens(HistoricoPesagensStruct value) {
    histPesagens.add(value);
  }

  void removeFromHistPesagens(HistoricoPesagensStruct value) {
    histPesagens.remove(value);
  }

  void removeAtIndexFromHistPesagens(int index) {
    histPesagens.removeAt(index);
  }

  void updateHistPesagensAtIndex(
    int index,
    HistoricoPesagensStruct Function(HistoricoPesagensStruct) updateFn,
  ) {
    histPesagens[index] = updateFn(_histPesagens[index]);
  }

  void insertAtIndexInHistPesagens(int index, HistoricoPesagensStruct value) {
    histPesagens.insert(index, value);
  }

  String _pageRebanho = 'rebanho';
  String get pageRebanho => _pageRebanho;
  set pageRebanho(String value) {
    _pageRebanho = value;
  }

  bool _refreshPesagem = false;
  bool get refreshPesagem => _refreshPesagem;
  set refreshPesagem(bool value) {
    _refreshPesagem = value;
    if (value) _notifyRefresh('refreshPesagem');
  }

  int _qtdReproducoes = 0;
  int get qtdReproducoes => _qtdReproducoes;
  set qtdReproducoes(int value) {
    _qtdReproducoes = value;
  }

  int _qtdInseminacoes = 0;
  int get qtdInseminacoes => _qtdInseminacoes;
  set qtdInseminacoes(int value) {
    _qtdInseminacoes = value;
  }

  int _qtdMontaNatural = 0;
  int get qtdMontaNatural => _qtdMontaNatural;
  set qtdMontaNatural(int value) {
    _qtdMontaNatural = value;
  }

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
  }

  DateTime? _filtroDataReproducaoDe;
  DateTime? get filtroDataReproducaoDe => _filtroDataReproducaoDe;
  set filtroDataReproducaoDe(DateTime? value) {
    _filtroDataReproducaoDe = value;
  }

  DateTime? _filtroDataReproducaoAte;
  DateTime? get filtroDataReproducaoAte => _filtroDataReproducaoAte;
  set filtroDataReproducaoAte(DateTime? value) {
    _filtroDataReproducaoAte = value;
  }

  DateTime? _filtroDataPartoDe;
  DateTime? get filtroDataPartoDe => _filtroDataPartoDe;
  set filtroDataPartoDe(DateTime? value) {
    _filtroDataPartoDe = value;
  }

  DateTime? _filtroDataPartoAte;
  DateTime? get filtroDataPartoAte => _filtroDataPartoAte;
  set filtroDataPartoAte(DateTime? value) {
    _filtroDataPartoAte = value;
  }

  DateTime? _filtroDataDiagnosticoDe;
  DateTime? get filtroDataDiagnosticoDe => _filtroDataDiagnosticoDe;
  set filtroDataDiagnosticoDe(DateTime? value) {
    _filtroDataDiagnosticoDe = value;
  }

  DateTime? _filtroDataDiagnosticoAte;
  DateTime? get filtroDataDiagnosticoAte => _filtroDataDiagnosticoAte;
  set filtroDataDiagnosticoAte(DateTime? value) {
    _filtroDataDiagnosticoAte = value;
  }

  DateTime? _filtroDataDiagnostico;
  DateTime? get filtroDataDiagnostico => _filtroDataDiagnostico;
  set filtroDataDiagnostico(DateTime? value) {
    _filtroDataDiagnostico = value;
  }

  String _filtroCategoriaRepro = '';
  String get filtroCategoriaRepro => _filtroCategoriaRepro;
  set filtroCategoriaRepro(String value) {
    _filtroCategoriaRepro = value;
  }

  String _filtroLoteNome = '';
  String get filtroLoteNome => _filtroLoteNome;
  set filtroLoteNome(String value) {
    _filtroLoteNome = value;
  }

  String _filtroInseminador = '';
  String get filtroInseminador => _filtroInseminador;
  set filtroInseminador(String value) {
    _filtroInseminador = value;
  }

  String _filtroIDMatriz = '';
  String get filtroIDMatriz => _filtroIDMatriz;
  set filtroIDMatriz(String value) {
    _filtroIDMatriz = value;
  }

  String _filtroIDReprodutor = '';
  String get filtroIDReprodutor => _filtroIDReprodutor;
  set filtroIDReprodutor(String value) {
    _filtroIDReprodutor = value;
  }

  bool _refreshReproducao = false;
  bool get refreshReproducao => _refreshReproducao;
  set refreshReproducao(bool value) {
    _refreshReproducao = value;
    if (value) _notifyRefresh('refreshReproducao');
    notifyListeners();
  }

  String _filtroStatusLote = '';
  String get filtroStatusLote => _filtroStatusLote;
  set filtroStatusLote(String value) {
    _filtroStatusLote = value;
  }

  DateTime? _filtroDataCriacaoLoteDe;
  DateTime? get filtroDataCriacaoLoteDe => _filtroDataCriacaoLoteDe;
  set filtroDataCriacaoLoteDe(DateTime? value) {
    _filtroDataCriacaoLoteDe = value;
  }

  DateTime? _filtroDataCriacaoLoteAte;
  DateTime? get filtroDataCriacaoLoteAte => _filtroDataCriacaoLoteAte;
  set filtroDataCriacaoLoteAte(DateTime? value) {
    _filtroDataCriacaoLoteAte = value;
  }

  bool _refreshLotes = false;
  bool get refreshLotes => _refreshLotes;
  set refreshLotes(bool value) {
    _refreshLotes = value;
    if (value) _notifyRefresh('refreshLotes');
  }

  bool _refreshPiquete = false;
  bool get refreshPiquete => _refreshPiquete;
  set refreshPiquete(bool value) {
    _refreshPiquete = value;
    if (value) _notifyRefresh('refreshPiquete');
  }

  String _filtroPiqueteForrageira = '';
  String get filtroPiqueteForrageira => _filtroPiqueteForrageira;
  set filtroPiqueteForrageira(String value) {
    _filtroPiqueteForrageira = value;
  }

  double _filtroAreaMin = 0;
  double get filtroAreaMin => _filtroAreaMin;
  set filtroAreaMin(double value) {
    _filtroAreaMin = value;
  }

  double _filtroAreaMax = 9999;
  double get filtroAreaMax => _filtroAreaMax;
  set filtroAreaMax(double value) {
    _filtroAreaMax = value;
  }

  int _qtdPiquetes = 0;
  int get qtdPiquetes => _qtdPiquetes;
  set qtdPiquetes(int value) {
    _qtdPiquetes = value;
  }

  DateTime? _filtroDataSanidadeDe;
  DateTime? get filtroDataSanidadeDe => _filtroDataSanidadeDe;
  set filtroDataSanidadeDe(DateTime? value) {
    _filtroDataSanidadeDe = value;
  }

  DateTime? _filtroDataSanidadeAte;
  DateTime? get filtroDataSanidadeAte => _filtroDataSanidadeAte;
  set filtroDataSanidadeAte(DateTime? value) {
    _filtroDataSanidadeAte = value;
  }

  String _filtroLoteSanidade = '';
  String get filtroLoteSanidade => _filtroLoteSanidade;
  set filtroLoteSanidade(String value) {
    _filtroLoteSanidade = value;
  }

  String _filtroAnimalSanidade = '';
  String get filtroAnimalSanidade => _filtroAnimalSanidade;
  set filtroAnimalSanidade(String value) {
    _filtroAnimalSanidade = value;
  }

  String _filtroSexoSanidade = '';
  String get filtroSexoSanidade => _filtroSexoSanidade;
  set filtroSexoSanidade(String value) {
    _filtroSexoSanidade = value;
  }

  String _filtroRacaSanidade = '';
  String get filtroRacaSanidade => _filtroRacaSanidade;
  set filtroRacaSanidade(String value) {
    _filtroRacaSanidade = value;
  }

  String _filtroCategoriaSanidade = '';
  String get filtroCategoriaSanidade => _filtroCategoriaSanidade;
  set filtroCategoriaSanidade(String value) {
    _filtroCategoriaSanidade = value;
  }

  String _filtroTratamentoSanidade = '';
  String get filtroTratamentoSanidade => _filtroTratamentoSanidade;
  set filtroTratamentoSanidade(String value) {
    _filtroTratamentoSanidade = value;
  }

  String _filtroProtocolo = '';
  String get filtroProtocolo => _filtroProtocolo;
  set filtroProtocolo(String value) {
    _filtroProtocolo = value;
  }

  String _filtroAntiparasitario = '';
  String get filtroAntiparasitario => _filtroAntiparasitario;
  set filtroAntiparasitario(String value) {
    _filtroAntiparasitario = value;
  }

  String _filtroVacinacao = '';
  String get filtroVacinacao => _filtroVacinacao;
  set filtroVacinacao(String value) {
    _filtroVacinacao = value;
  }

  DateTime? _filtroNascimentoSanidadeDe;
  DateTime? get filtroNascimentoSanidadeDe => _filtroNascimentoSanidadeDe;
  set filtroNascimentoSanidadeDe(DateTime? value) {
    _filtroNascimentoSanidadeDe = value;
  }

  DateTime? _filtroNascimentoSanidadeAte;
  DateTime? get filtroNascimentoSanidadeAte => _filtroNascimentoSanidadeAte;
  set filtroNascimentoSanidadeAte(DateTime? value) {
    _filtroNascimentoSanidadeAte = value;
  }

  List<String> _vacinacao = _kVacinacaoOptions.toList();
  List<String> get vacinacao => _vacinacao;
  set vacinacao(List<String> value) {
    _vacinacao = value;
    prefs.setStringList('ff_vacinacao', value);
  }

  void addToVacinacao(String value) {
    vacinacao.add(value);
    prefs.setStringList('ff_vacinacao', _vacinacao);
  }

  void removeFromVacinacao(String value) {
    vacinacao.remove(value);
    prefs.setStringList('ff_vacinacao', _vacinacao);
  }

  void removeAtIndexFromVacinacao(int index) {
    vacinacao.removeAt(index);
    prefs.setStringList('ff_vacinacao', _vacinacao);
  }

  void updateVacinacaoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    vacinacao[index] = updateFn(_vacinacao[index]);
    prefs.setStringList('ff_vacinacao', _vacinacao);
  }

  void insertAtIndexInVacinacao(int index, String value) {
    vacinacao.insert(index, value);
    prefs.setStringList('ff_vacinacao', _vacinacao);
  }

  List<String> _tratamento = _kTratamentoOptions.toList();
  List<String> get tratamento => _tratamento;
  set tratamento(List<String> value) {
    _tratamento = value;
    prefs.setStringList('ff_tratamento', value);
  }

  void addToTratamento(String value) {
    tratamento.add(value);
    prefs.setStringList('ff_tratamento', _tratamento);
  }

  void removeFromTratamento(String value) {
    tratamento.remove(value);
    prefs.setStringList('ff_tratamento', _tratamento);
  }

  void removeAtIndexFromTratamento(int index) {
    tratamento.removeAt(index);
    prefs.setStringList('ff_tratamento', _tratamento);
  }

  void updateTratamentoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    tratamento[index] = updateFn(_tratamento[index]);
    prefs.setStringList('ff_tratamento', _tratamento);
  }

  void insertAtIndexInTratamento(int index, String value) {
    tratamento.insert(index, value);
    prefs.setStringList('ff_tratamento', _tratamento);
  }

  List<String> _antiparasitario = _kAntiparasitarioOptions.toList();
  List<String> get antiparasitario => _antiparasitario;
  set antiparasitario(List<String> value) {
    _antiparasitario = value;
    prefs.setStringList('ff_antiparasitario', value);
  }

  void addToAntiparasitario(String value) {
    antiparasitario.add(value);
    prefs.setStringList('ff_antiparasitario', _antiparasitario);
  }

  void removeFromAntiparasitario(String value) {
    antiparasitario.remove(value);
    prefs.setStringList('ff_antiparasitario', _antiparasitario);
  }

  void removeAtIndexFromAntiparasitario(int index) {
    antiparasitario.removeAt(index);
    prefs.setStringList('ff_antiparasitario', _antiparasitario);
  }

  void updateAntiparasitarioAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    antiparasitario[index] = updateFn(_antiparasitario[index]);
    prefs.setStringList('ff_antiparasitario', _antiparasitario);
  }

  void insertAtIndexInAntiparasitario(int index, String value) {
    antiparasitario.insert(index, value);
    prefs.setStringList('ff_antiparasitario', _antiparasitario);
  }

  List<String> _protocoloReprodutivo = _kProtocoloReprodutivoOptions.toList();
  List<String> get protocoloReprodutivo => _protocoloReprodutivo;
  set protocoloReprodutivo(List<String> value) {
    _protocoloReprodutivo = value;
    prefs.setStringList('ff_protocoloReprodutivo', value);
  }

  void addToProtocoloReprodutivo(String value) {
    protocoloReprodutivo.add(value);
    prefs.setStringList('ff_protocoloReprodutivo', _protocoloReprodutivo);
  }

  void removeFromProtocoloReprodutivo(String value) {
    protocoloReprodutivo.remove(value);
    prefs.setStringList('ff_protocoloReprodutivo', _protocoloReprodutivo);
  }

  void removeAtIndexFromProtocoloReprodutivo(int index) {
    protocoloReprodutivo.removeAt(index);
    prefs.setStringList('ff_protocoloReprodutivo', _protocoloReprodutivo);
  }

  void updateProtocoloReprodutivoAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    protocoloReprodutivo[index] = updateFn(_protocoloReprodutivo[index]);
    prefs.setStringList('ff_protocoloReprodutivo', _protocoloReprodutivo);
  }

  void insertAtIndexInProtocoloReprodutivo(int index, String value) {
    protocoloReprodutivo.insert(index, value);
    prefs.setStringList('ff_protocoloReprodutivo', _protocoloReprodutivo);
  }

  bool _refreshSanidade = false;
  bool get refreshSanidade => _refreshSanidade;
  set refreshSanidade(bool value) {
    _refreshSanidade = value;
    if (value) _notifyRefresh('refreshSanidade');
  }

  double _valueDouble2 = 0.0;
  double get valueDouble2 => _valueDouble2;
  set valueDouble2(double value) {
    _valueDouble2 = value;
  }

  String _valueFormat2 = '';
  String get valueFormat2 => _valueFormat2;
  set valueFormat2(String value) {
    _valueFormat2 = value;
  }

  DateTime? _dateTeste;
  DateTime? get dateTeste => _dateTeste;
  set dateTeste(DateTime? value) {
    _dateTeste = value;
  }

  bool _refreshPainel = false;
  bool get refreshPainel => _refreshPainel;
  set refreshPainel(bool value) {
    _refreshPainel = value;
    if (value) _notifyRefresh('refreshPainel');
  }

  List<AnosStruct> _anos = [];
  List<AnosStruct> get anos => _anos;
  set anos(List<AnosStruct> value) {
    _anos = value;
    prefs.setStringList('ff_anos', value.map((x) => x.serialize()).toList());
  }

  void addToAnos(AnosStruct value) {
    anos.add(value);
    prefs.setStringList('ff_anos', _anos.map((x) => x.serialize()).toList());
  }

  void removeFromAnos(AnosStruct value) {
    anos.remove(value);
    prefs.setStringList('ff_anos', _anos.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromAnos(int index) {
    anos.removeAt(index);
    prefs.setStringList('ff_anos', _anos.map((x) => x.serialize()).toList());
  }

  void updateAnosAtIndex(
    int index,
    AnosStruct Function(AnosStruct) updateFn,
  ) {
    anos[index] = updateFn(_anos[index]);
    prefs.setStringList('ff_anos', _anos.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInAnos(int index, AnosStruct value) {
    anos.insert(index, value);
    prefs.setStringList('ff_anos', _anos.map((x) => x.serialize()).toList());
  }

  AnimalSelecionadoStruct _matrizSelecionada = AnimalSelecionadoStruct();
  AnimalSelecionadoStruct get matrizSelecionada => _matrizSelecionada;
  set matrizSelecionada(AnimalSelecionadoStruct value) {
    _matrizSelecionada = value;
    notifyListeners();
  }

  void updateMatrizSelecionadaStruct(
      Function(AnimalSelecionadoStruct) updateFn) {
    updateFn(_matrizSelecionada);
    notifyListeners();
  }

  AnimalSelecionadoStruct _reprodutorSelecionado = AnimalSelecionadoStruct();
  AnimalSelecionadoStruct get reprodutorSelecionado => _reprodutorSelecionado;
  set reprodutorSelecionado(AnimalSelecionadoStruct value) {
    _reprodutorSelecionado = value;
    notifyListeners();
  }

  void updateReprodutorSelecionadoStruct(
      Function(AnimalSelecionadoStruct) updateFn) {
    updateFn(_reprodutorSelecionado);
    notifyListeners();
  }

  bool _visibilidadeGraficoPrincipal = false;
  bool get visibilidadeGraficoPrincipal => _visibilidadeGraficoPrincipal;
  set visibilidadeGraficoPrincipal(bool value) {
    _visibilidadeGraficoPrincipal = value;
  }

  int _qtdAnosRebGraficoPrincipal = 0;
  int get qtdAnosRebGraficoPrincipal => _qtdAnosRebGraficoPrincipal;
  set qtdAnosRebGraficoPrincipal(int value) {
    _qtdAnosRebGraficoPrincipal = value;
  }

  int _lotesAtivos = 0;
  int get lotesAtivos => _lotesAtivos;
  set lotesAtivos(int value) {
    _lotesAtivos = value;
  }

  int _lotesInativos = 0;
  int get lotesInativos => _lotesInativos;
  set lotesInativos(int value) {
    _lotesInativos = value;
  }

  int _qtdAnimaisEmLotesAtivos = 0;
  int get qtdAnimaisEmLotesAtivos => _qtdAnimaisEmLotesAtivos;
  set qtdAnimaisEmLotesAtivos(int value) {
    _qtdAnimaisEmLotesAtivos = value;
  }

  PropriedadeStruct _propriedadeSelecionadaa = PropriedadeStruct();
  PropriedadeStruct get propriedadeSelecionadaa => _propriedadeSelecionadaa;
  set propriedadeSelecionadaa(PropriedadeStruct value) {
    _propriedadeSelecionadaa = value;
  }

  void updatePropriedadeSelecionadaaStruct(
      Function(PropriedadeStruct) updateFn) {
    updateFn(_propriedadeSelecionadaa);
  }

  bool _refreshAnimalSelecionado = false;
  bool get refreshAnimalSelecionado => _refreshAnimalSelecionado;
  set refreshAnimalSelecionado(bool value) {
    _refreshAnimalSelecionado = value;
    if (value) _notifyRefresh('refreshAnimalSelecionado');
  }

  int _qtdSanidades = 0;
  int get qtdSanidades => _qtdSanidades;
  set qtdSanidades(int value) {
    _qtdSanidades = value;
  }

  int _qtdVacinacao = 0;
  int get qtdVacinacao => _qtdVacinacao;
  set qtdVacinacao(int value) {
    _qtdVacinacao = value;
  }


  List<RebanhoExportStruct> _rebanhoExport = [];
  List<RebanhoExportStruct> get rebanhoExport => _rebanhoExport;
  set rebanhoExport(List<RebanhoExportStruct> value) {
    _rebanhoExport = value;
  }

  void addToRebanhoExport(RebanhoExportStruct value) {
    rebanhoExport.add(value);
  }

  void removeFromRebanhoExport(RebanhoExportStruct value) {
    rebanhoExport.remove(value);
  }

  void removeAtIndexFromRebanhoExport(int index) {
    rebanhoExport.removeAt(index);
  }

  void updateRebanhoExportAtIndex(
    int index,
    RebanhoExportStruct Function(RebanhoExportStruct) updateFn,
  ) {
    rebanhoExport[index] = updateFn(_rebanhoExport[index]);
  }

  void insertAtIndexInRebanhoExport(int index, RebanhoExportStruct value) {
    rebanhoExport.insert(index, value);
  }

  List<dynamic> _rebanhoJSON = [];
  List<dynamic> get rebanhoJSON => _rebanhoJSON;
  set rebanhoJSON(List<dynamic> value) {
    _rebanhoJSON = value;
  }

  void addToRebanhoJSON(dynamic value) {
    rebanhoJSON.add(value);
  }

  void removeFromRebanhoJSON(dynamic value) {
    rebanhoJSON.remove(value);
  }

  void removeAtIndexFromRebanhoJSON(int index) {
    rebanhoJSON.removeAt(index);
  }

  void updateRebanhoJSONAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    rebanhoJSON[index] = updateFn(_rebanhoJSON[index]);
  }

  void insertAtIndexInRebanhoJSON(int index, dynamic value) {
    rebanhoJSON.insert(index, value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}
