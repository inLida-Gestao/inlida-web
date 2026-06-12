import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '../data/piquete_backend_store.dart';
import 'mapa_demarcacao_real_widget.dart';
import 'piquete_prototype_store.dart';
import 'piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PiqueteFormResult {
  const PiqueteFormResult({
    required this.retiroId,
    required this.nome,
    required this.areaHa,
    required this.forrageiras,
    required this.anotacoes,
    required this.pontos,
    required this.animaisIds,
    required this.lotesIds,
  });

  final String retiroId;
  final String nome;
  final double areaHa;
  final List<String> forrageiras;
  final String anotacoes;
  final List<MapPoint> pontos;
  final List<String> animaisIds;
  final List<String> lotesIds;
}

class PiqueteFormMockWidget extends StatefulWidget {
  const PiqueteFormMockWidget({
    super.key,
    this.initial,
    required this.onCancel,
    required this.onSave,
  });

  final PiquetePrototype? initial;
  final VoidCallback onCancel;
  final ValueChanged<PiqueteFormResult> onSave;

  @override
  State<PiqueteFormMockWidget> createState() => _PiqueteFormMockWidgetState();
}

class _PiqueteFormMockWidgetState extends State<PiqueteFormMockWidget> {
  final _store = PiqueteBackendStore.instance;
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _anotacoesController = TextEditingController();
  final _searchAvailableController = TextEditingController();
  final _searchSelectedController = TextEditingController();
  final _animalLoteFilterController = TextEditingController();
  Timer? _selectorSearchDebounce;

  late String _retiroId;
  late List<String> _forrageirasSelecionadas;
  late String _mode;
  late List<MapPoint> _pontos;
  late List<String> _animaisIds;
  late List<String> _lotesIds;
  late bool _areaEditadaManualmente;
  List<AnimalPrototype> _animalOptionsPage = const [];
  List<LotePrototype> _loteOptionsPage = const [];
  int _animalOffset = 0;
  int _loteOffset = 0;
  int _animalRequestId = 0;
  int _loteRequestId = 0;
  bool _animalHasNext = false;
  bool _loteHasNext = false;
  bool _loadingAnimals = false;
  bool _loadingLotes = false;
  String? _animalOptionsError;
  String? _loteOptionsError;
  String _animalStatusFilter = '';
  String _animalSexoFilter = '';
  String _animalCategoriaFilter = '';
  String _animalRacaFilter = '';
  String _animalOrigemFilter = '';
  DateTime? _animalNascimentoDeFilter;
  DateTime? _animalNascimentoAteFilter;
  String _loteStatusFilter = '';
  DateTime? _loteCriacaoDeFilter;
  DateTime? _loteCriacaoAteFilter;

  static const _selectorPageSize = PiqueteBackendStore.optionsPageSize;
  static const _animalSexoOptions = ['Fêmea', 'Macho'];
  static const _animalCategoriaFemeaOptions = [
    'Bezerra',
    'Novilha',
    'Vaca Multipara',
    'Vaca Primipara',
  ];
  static const _animalCategoriaMachoOptions = [
    'Boi Gordo',
    'Boi Magro',
    'Garrote',
    'Rufião',
    'Touro',
    'Bezerro',
  ];
  static const _loteStatusOptions = ['Ativo', 'Inativo'];
  static const _forrageiraOptions = [
    'Brachiaria ruziensis',
    'Massai (Panicum maximum)',
    'Mombaça',
    'Tifton 85',
    'Capim elefante',
  ];

  @override
  void initState() {
    super.initState();
    _applyInitial(widget.initial);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadInitialSelectorData());
    });
  }

  @override
  void didUpdateWidget(covariant PiqueteFormMockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialIdentity(widget.initial) !=
        _initialIdentity(oldWidget.initial)) {
      _applyInitial(widget.initial);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadInitialSelectorData());
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _anotacoesController.dispose();
    _searchAvailableController.dispose();
    _searchSelectedController.dispose();
    _animalLoteFilterController.dispose();
    _selectorSearchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retiro = _retiroId.isEmpty ? null : _store.retiroById(_retiroId);
    final limite = _store.limitePropriedade;
    if (limite == null) {
      return PrototypeCard(
        child: PrototypeEmptyState(
          title: 'Cadastre o limite da propriedade',
          message:
              'Antes de criar ou editar piquetes, demarque o limite total da propriedade na página de piquetes.',
          icon: Icons.map_outlined,
          action: PrototypeSecondaryButton(
            label: 'Voltar',
            icon: Icons.arrow_back_rounded,
            onPressed: widget.onCancel,
          ),
        ),
      );
    }
    final newPiqueteSemRetiro = widget.initial == null && retiro == null;
    final piqueteAreas = newPiqueteSemRetiro
        ? const <PiqueteMapArea>[]
        : _existingPiqueteAreas();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrototypeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(
                    width: 340,
                    child: _DropdownField(
                      label: 'Retiro',
                      value: _retiroId,
                      items: [
                        const DropdownMenuItem(
                          value: PiqueteBackendStore.semRetiroId,
                          child: Text('Sem retiro'),
                        ),
                        ..._store.retiros.map(
                          (r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(r.nome),
                          ),
                        ),
                      ],
                      onChanged: _selectRetiro,
                    ),
                  ),
                  SizedBox(
                    width: 340,
                    child: _TextField(
                      label: 'Nome do piquete',
                      hint: 'Ex.: Tradição Campeira',
                      controller: _nomeController,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: _TextField(
                      label: 'Área (ha)',
                      hint: '23',
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _areaEditadaManualmente = true,
                    ),
                  ),
                  SizedBox(
                    width: 340,
                    child: _MultiSelectField(
                      label: 'Forrageiras',
                      values: _forrageirasSelecionadas,
                      options: _forrageiraOptions,
                      onChanged: (values) => safeSetState(
                        () => _forrageirasSelecionadas = values,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _TextField(
                label: 'Anotações',
                hint: 'Observações sobre manejo, água, sombra ou descanso.',
                controller: _anotacoesController,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        MapaDemarcacaoRealWidget(
          title: retiro == null
              ? 'Demarcação do piquete sem retiro'
              : 'Demarcação dentro de ${retiro.nome}',
          points: _pontos,
          retiroPoints: retiro?.pontos ?? limite.pontos,
          piqueteAreas: piqueteAreas,
          editable: true,
          height: 548,
          preferUserLocation: newPiqueteSemRetiro,
          onChanged: _handleMapChanged,
          onImported: _handleKmlImported,
        ),
        const SizedBox(height: 22),
        PrototypeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar no piquete',
                style: GoogleFonts.poppins(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'Adicionar animal',
                      selected: _mode == 'animal',
                      onTap: () => _selectMode('animal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModeButton(
                      label: 'Adicionar lote',
                      selected: _mode == 'lote',
                      onTap: () => _selectMode('lote'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _mode == 'animal' ? _buildAnimalSelector() : _buildLoteSelector(),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrototypeSecondaryButton(
              label: 'Cancelar',
              onPressed: widget.onCancel,
            ),
            PrototypePrimaryButton(
              label: 'Salvar',
              icon: Icons.check_rounded,
              onPressed: _submit,
            ),
          ].divide(const SizedBox(width: 14)),
        ),
      ],
    );
  }

  Widget _buildAnimalSelector() {
    final selectedQuery = _searchSelectedController.text.trim().toLowerCase();
    final selectedSet = _animaisIds.toSet();
    final available =
        _animalOptionsPage.where((a) => !selectedSet.contains(a.id)).toList();
    final selected = _selectedAnimais().where((a) {
      return selectedQuery.isEmpty ||
          a.nome.toLowerCase().contains(selectedQuery) ||
          a.numero.toLowerCase().contains(selectedQuery);
    }).toList();

    return _DualPanel<AnimalPrototype>(
      leftTitle: 'Animais fora deste piquete',
      rightTitle: 'Animais neste piquete (${_animaisIds.length})',
      leftItems: available,
      rightItems: selected,
      leftSearch: _searchAvailableController,
      rightSearch: _searchSelectedController,
      leftLoading: _loadingAnimals,
      leftErrorMessage: _animalOptionsError,
      leftFilters: _buildAnimalFilters(),
      leftPageLabel: _pageLabel(
        offset: _animalOffset,
        itemCount: _animalOptionsPage.length,
        hasNext: _animalHasNext,
      ),
      leftHasPrevious: _animalOffset > 0,
      leftHasNext: _animalHasNext,
      leftOnPreviousPage: _loadingAnimals
          ? null
          : () => _loadAnimalOptions(
                offset: (_animalOffset - _selectorPageSize)
                    .clamp(0, _animalOffset)
                    .toInt(),
              ),
      leftOnNextPage: _loadingAnimals
          ? null
          : () => _loadAnimalOptions(
                offset: _animalOffset + _selectorPageSize,
              ),
      emptyRightMessage:
          'Nenhum animal foi adicionado neste piquete. Selecione um animal à esquerda.',
      itemBuilder: (animal) => _AnimalTile(animal: animal),
      onAdd: (animal) => safeSetState(() {
        if (!_animaisIds.contains(animal.id)) _animaisIds.add(animal.id);
      }),
      onRemove: (animal) =>
          safeSetState(() => _animaisIds.removeWhere((id) => id == animal.id)),
      onSearchChanged: _scheduleAvailableSearch,
      onSelectedSearchChanged: () => safeSetState(() {}),
    );
  }

  void _selectRetiro(String? value) {
    final nextValue = value ?? PiqueteBackendStore.semRetiroId;
    if (nextValue == _retiroId) {
      return;
    }

    safeSetState(() {
      _retiroId = nextValue;
      if (widget.initial == null) {
        _pontos = [];
        if (!_areaEditadaManualmente) {
          _areaController.text = '0';
        }
      }
    });
    unawaited(_loadPiquetesDoRetiro(nextValue));
  }

  Future<void> _loadPiquetesDoRetiro(String retiroId) async {
    try {
      await _store.selectRetiro(retiroId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível carregar os piquetes deste retiro.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _loadInitialSelectorData() async {
    try {
      await _store.ensureSelectedOptions(
        animaisIds: _animaisIds,
        lotesIds: _lotesIds,
      );
      if (mounted) safeSetState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível carregar os itens já selecionados.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }

    await _loadCurrentModeOptions(reset: true);
  }

  void _selectMode(String mode) {
    if (_mode == mode) return;
    safeSetState(() => _mode = mode);
    unawaited(_loadCurrentModeOptions(reset: true));
  }

  Future<void> _loadCurrentModeOptions({bool reset = false}) {
    if (_mode == 'lote') {
      return _loadLoteOptions(reset: reset);
    }
    return _loadAnimalOptions(reset: reset);
  }

  void _scheduleAvailableSearch() {
    _selectorSearchDebounce?.cancel();
    _selectorSearchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(_loadCurrentModeOptions(reset: true));
    });
  }

  Future<void> _loadAnimalOptions({
    int? offset,
    bool reset = false,
  }) async {
    final nextOffset = reset ? 0 : (offset ?? _animalOffset);
    final requestId = ++_animalRequestId;
    safeSetState(() {
      _loadingAnimals = true;
      _animalOptionsError = null;
      if (reset) _animalOffset = 0;
    });

    try {
      final page = await _store.buscarAnimaisDisponiveisPage(
        piqueteId: widget.initial?.id ?? '',
        pesquisa: _searchAvailableController.text.trim(),
        offset: nextOffset,
        limit: _selectorPageSize,
        status: _animalStatusFilter,
        sexo: _animalSexoFilter,
        categoria: _animalCategoriaFilter,
        raca: _animalRacaFilter,
        origem: _animalOrigemFilter,
        lote: _animalLoteFilterController.text.trim(),
        dataNascimentoDe: _dateParam(_animalNascimentoDeFilter),
        dataNascimentoAte: _dateParam(_animalNascimentoAteFilter),
      );
      if (!mounted || requestId != _animalRequestId) return;
      safeSetState(() {
        _animalOptionsPage = page.items;
        _animalOffset = page.offset;
        _animalHasNext = page.hasNext;
        _loadingAnimals = false;
      });
    } catch (_) {
      if (!mounted || requestId != _animalRequestId) return;
      safeSetState(() {
        _animalOptionsPage = const [];
        _animalHasNext = false;
        _loadingAnimals = false;
        _animalOptionsError =
            _store.errorMessage ?? 'Não foi possível carregar os animais.';
      });
    }
  }

  Future<void> _loadLoteOptions({
    int? offset,
    bool reset = false,
  }) async {
    final nextOffset = reset ? 0 : (offset ?? _loteOffset);
    final requestId = ++_loteRequestId;
    safeSetState(() {
      _loadingLotes = true;
      _loteOptionsError = null;
      if (reset) _loteOffset = 0;
    });

    try {
      final page = await _store.buscarLotesDisponiveisPage(
        piqueteId: widget.initial?.id ?? '',
        pesquisa: _searchAvailableController.text.trim(),
        offset: nextOffset,
        limit: _selectorPageSize,
        status: _loteStatusFilter,
        dataCriacaoDe: _dateParam(_loteCriacaoDeFilter),
        dataCriacaoAte: _dateParam(_loteCriacaoAteFilter),
      );
      if (!mounted || requestId != _loteRequestId) return;
      safeSetState(() {
        _loteOptionsPage = page.items;
        _loteOffset = page.offset;
        _loteHasNext = page.hasNext;
        _loadingLotes = false;
      });
    } catch (_) {
      if (!mounted || requestId != _loteRequestId) return;
      safeSetState(() {
        _loteOptionsPage = const [];
        _loteHasNext = false;
        _loadingLotes = false;
        _loteOptionsError =
            _store.errorMessage ?? 'Não foi possível carregar os lotes.';
      });
    }
  }

  Widget _buildAnimalFilters() {
    final racaOptions = _appStateOptions(FFAppState().raca);
    final origemOptions = _appStateOptions(FFAppState().origemRebanho);
    final statusOptions = _appStateOptions(FFAppState().statusRebanho);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 155,
              child: _FilterDropdown(
                label: 'Status',
                value: _animalStatusFilter,
                options: statusOptions,
                hint: 'Todos',
                onChanged: (value) => _setAnimalFilter(
                  status: value ?? '',
                ),
              ),
            ),
            SizedBox(
              width: 135,
              child: _FilterDropdown(
                label: 'Sexo',
                value: _animalSexoFilter,
                options: _animalSexoOptions,
                hint: 'Todos',
                onChanged: (value) => _setAnimalFilter(
                  sexo: value ?? '',
                  clearCategoria: true,
                ),
              ),
            ),
            SizedBox(
              width: 170,
              child: _FilterDropdown(
                label: 'Categoria',
                value: _animalCategoriaFilter,
                options: _categoriaOptions,
                hint: 'Todas',
                onChanged: (value) => _setAnimalFilter(
                  categoria: value ?? '',
                ),
              ),
            ),
            SizedBox(
              width: 170,
              child: _FilterDropdown(
                label: 'Raça',
                value: _animalRacaFilter,
                options: racaOptions,
                hint: 'Todas',
                onChanged: (value) => _setAnimalFilter(
                  raca: value ?? '',
                ),
              ),
            ),
            SizedBox(
              width: 165,
              child: _FilterDropdown(
                label: 'Origem',
                value: _animalOrigemFilter,
                options: origemOptions,
                hint: 'Todas',
                onChanged: (value) => _setAnimalFilter(
                  origem: value ?? '',
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: _TextField(
                label: 'Lote',
                hint: 'Nome ou ID',
                controller: _animalLoteFilterController,
                onChanged: (_) => _scheduleAvailableSearch(),
              ),
            ),
            SizedBox(
              width: 150,
              child: _DateFilterField(
                label: 'Nascimento de',
                value: _animalNascimentoDeFilter,
                onPick: () => _pickAnimalNascimentoDe(),
                onClear: _animalNascimentoDeFilter == null
                    ? null
                    : () => _setAnimalFilter(nascimentoDe: null),
              ),
            ),
            SizedBox(
              width: 150,
              child: _DateFilterField(
                label: 'Nascimento até',
                value: _animalNascimentoAteFilter,
                onPick: () => _pickAnimalNascimentoAte(),
                onClear: _animalNascimentoAteFilter == null
                    ? null
                    : () => _setAnimalFilter(nascimentoAte: null),
              ),
            ),
          ],
        ),
        if (_hasAnimalFilters) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _clearAnimalFilters,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
            label: const Text('Limpar filtros'),
          ),
        ],
      ],
    );
  }

  Widget _buildLoteFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 155,
              child: _FilterDropdown(
                label: 'Status',
                value: _loteStatusFilter,
                options: _loteStatusOptions,
                hint: 'Todos',
                onChanged: (value) => _setLoteFilter(
                  status: value ?? '',
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: _DateFilterField(
                label: 'Criação de',
                value: _loteCriacaoDeFilter,
                onPick: () => _pickLoteCriacaoDe(),
                onClear: _loteCriacaoDeFilter == null
                    ? null
                    : () => _setLoteFilter(criacaoDe: null),
              ),
            ),
            SizedBox(
              width: 150,
              child: _DateFilterField(
                label: 'Criação até',
                value: _loteCriacaoAteFilter,
                onPick: () => _pickLoteCriacaoAte(),
                onClear: _loteCriacaoAteFilter == null
                    ? null
                    : () => _setLoteFilter(criacaoAte: null),
              ),
            ),
          ],
        ),
        if (_hasLoteFilters) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _clearLoteFilters,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
            label: const Text('Limpar filtros'),
          ),
        ],
      ],
    );
  }

  List<String> get _categoriaOptions {
    if (_animalSexoFilter == 'Fêmea') {
      return _animalCategoriaFemeaOptions;
    }
    if (_animalSexoFilter == 'Macho') {
      return _animalCategoriaMachoOptions;
    }
    return [
      ..._animalCategoriaFemeaOptions,
      ..._animalCategoriaMachoOptions,
    ];
  }

  bool get _hasAnimalFilters =>
      _animalStatusFilter.isNotEmpty ||
      _animalSexoFilter.isNotEmpty ||
      _animalCategoriaFilter.isNotEmpty ||
      _animalRacaFilter.isNotEmpty ||
      _animalOrigemFilter.isNotEmpty ||
      _animalLoteFilterController.text.trim().isNotEmpty ||
      _animalNascimentoDeFilter != null ||
      _animalNascimentoAteFilter != null;

  bool get _hasLoteFilters =>
      _loteStatusFilter.isNotEmpty ||
      _loteCriacaoDeFilter != null ||
      _loteCriacaoAteFilter != null;

  List<String> _appStateOptions(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  void _setAnimalFilter({
    String? status,
    String? sexo,
    String? categoria,
    String? raca,
    String? origem,
    Object? nascimentoDe = _dateFilterNotChanged,
    Object? nascimentoAte = _dateFilterNotChanged,
    bool clearCategoria = false,
  }) {
    safeSetState(() {
      if (status != null) _animalStatusFilter = status;
      if (sexo != null) _animalSexoFilter = sexo;
      if (categoria != null) _animalCategoriaFilter = categoria;
      if (raca != null) _animalRacaFilter = raca;
      if (origem != null) _animalOrigemFilter = origem;
      if (nascimentoDe != _dateFilterNotChanged) {
        _animalNascimentoDeFilter = nascimentoDe as DateTime?;
      }
      if (nascimentoAte != _dateFilterNotChanged) {
        _animalNascimentoAteFilter = nascimentoAte as DateTime?;
      }
      if (clearCategoria) _animalCategoriaFilter = '';
    });
    unawaited(_loadAnimalOptions(reset: true));
  }

  void _setLoteFilter({
    String? status,
    Object? criacaoDe = _dateFilterNotChanged,
    Object? criacaoAte = _dateFilterNotChanged,
  }) {
    safeSetState(() {
      if (status != null) _loteStatusFilter = status;
      if (criacaoDe != _dateFilterNotChanged) {
        _loteCriacaoDeFilter = criacaoDe as DateTime?;
      }
      if (criacaoAte != _dateFilterNotChanged) {
        _loteCriacaoAteFilter = criacaoAte as DateTime?;
      }
    });
    unawaited(_loadLoteOptions(reset: true));
  }

  void _clearAnimalFilters() {
    safeSetState(() {
      _animalStatusFilter = '';
      _animalSexoFilter = '';
      _animalCategoriaFilter = '';
      _animalRacaFilter = '';
      _animalOrigemFilter = '';
      _animalNascimentoDeFilter = null;
      _animalNascimentoAteFilter = null;
      _animalLoteFilterController.clear();
    });
    unawaited(_loadAnimalOptions(reset: true));
  }

  void _clearLoteFilters() {
    safeSetState(() {
      _loteStatusFilter = '';
      _loteCriacaoDeFilter = null;
      _loteCriacaoAteFilter = null;
    });
    unawaited(_loadLoteOptions(reset: true));
  }

  Future<void> _pickAnimalNascimentoDe() async {
    final picked = await _pickFilterDate(_animalNascimentoDeFilter);
    if (picked == null) return;
    _setAnimalFilter(nascimentoDe: picked);
  }

  Future<void> _pickAnimalNascimentoAte() async {
    final picked = await _pickFilterDate(_animalNascimentoAteFilter);
    if (picked == null) return;
    _setAnimalFilter(nascimentoAte: picked);
  }

  Future<void> _pickLoteCriacaoDe() async {
    final picked = await _pickFilterDate(_loteCriacaoDeFilter);
    if (picked == null) return;
    _setLoteFilter(criacaoDe: picked);
  }

  Future<void> _pickLoteCriacaoAte() async {
    final picked = await _pickFilterDate(_loteCriacaoAteFilter);
    if (picked == null) return;
    _setLoteFilter(criacaoAte: picked);
  }

  Future<DateTime?> _pickFilterDate(DateTime? initialDate) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: FlutterFlowTheme.of(context).primary,
                ),
          ),
          child: child!,
        );
      },
    );
  }

  static const Object _dateFilterNotChanged = Object();

  String _dateParam(DateTime? date) {
    if (date == null) return '';
    return date.toIso8601String().split('T').first;
  }

  void _handleMapChanged(List<MapPoint> value) {
    safeSetState(() {
      _pontos = value;
      if (!_areaEditadaManualmente) {
        final area = estimateMapAreaHa(value);
        _areaController.text = area > 0 ? area.toStringAsFixed(2) : '0';
      }
    });
  }

  void _handleKmlImported(List<MapPoint> value) {
    safeSetState(() {
      _pontos = value;
      _areaEditadaManualmente = false;
      final area = estimateMapAreaHa(value);
      _areaController.text = area > 0 ? area.toStringAsFixed(2) : '0';
    });
  }

  String _pageLabel({
    required int offset,
    required int itemCount,
    required bool hasNext,
  }) {
    if (itemCount == 0) return 'Nenhum item nesta busca';
    final first = offset + 1;
    final last = offset + itemCount;
    return hasNext
        ? 'Exibindo $first-$last de mais resultados'
        : 'Exibindo $first-$last';
  }

  List<AnimalPrototype> _selectedAnimais() {
    final loadedById = {
      for (final animal in _store.animaisByIds(_animaisIds)) animal.id: animal,
    };
    return _animaisIds.map((id) {
      return loadedById[id] ??
          AnimalPrototype(
            id: id,
            numero: id,
            nome: 'Animal selecionado',
            sexo: '',
            categoria: '',
            raca: '',
            dataNascimento: '',
            loteNome: '',
          );
    }).toList();
  }

  List<LotePrototype> _selectedLotes() {
    final loadedById = {
      for (final lote in _store.lotesByIds(_lotesIds)) lote.id: lote,
    };
    return _lotesIds.map((id) {
      return loadedById[id] ??
          LotePrototype(
            id: id,
            nome: 'Lote selecionado',
            qtdAnimais: 0,
            status: 'Ativo',
          );
    }).toList();
  }

  Widget _buildLoteSelector() {
    final selectedQuery = _searchSelectedController.text.trim().toLowerCase();
    final selectedSet = _lotesIds.toSet();
    final available =
        _loteOptionsPage.where((l) => !selectedSet.contains(l.id)).toList();
    final selected = _selectedLotes().where((l) {
      return selectedQuery.isEmpty ||
          l.nome.toLowerCase().contains(selectedQuery);
    }).toList();

    return _DualPanel<LotePrototype>(
      leftTitle: 'Lotes fora deste piquete',
      rightTitle: 'Lotes neste piquete (${_lotesIds.length})',
      leftItems: available,
      rightItems: selected,
      leftSearch: _searchAvailableController,
      rightSearch: _searchSelectedController,
      leftLoading: _loadingLotes,
      leftErrorMessage: _loteOptionsError,
      leftFilters: _buildLoteFilters(),
      leftPageLabel: _pageLabel(
        offset: _loteOffset,
        itemCount: _loteOptionsPage.length,
        hasNext: _loteHasNext,
      ),
      leftHasPrevious: _loteOffset > 0,
      leftHasNext: _loteHasNext,
      leftOnPreviousPage: _loadingLotes
          ? null
          : () => _loadLoteOptions(
                offset: (_loteOffset - _selectorPageSize)
                    .clamp(0, _loteOffset)
                    .toInt(),
              ),
      leftOnNextPage: _loadingLotes
          ? null
          : () => _loadLoteOptions(
                offset: _loteOffset + _selectorPageSize,
              ),
      emptyRightMessage:
          'Nenhum lote foi adicionado neste piquete. Selecione um lote à esquerda.',
      itemBuilder: (lote) => _LoteTile(lote: lote),
      onAdd: (lote) => safeSetState(() {
        if (!_lotesIds.contains(lote.id)) _lotesIds.add(lote.id);
      }),
      onRemove: (lote) =>
          safeSetState(() => _lotesIds.removeWhere((id) => id == lote.id)),
      onSearchChanged: _scheduleAvailableSearch,
      onSelectedSearchChanged: () => safeSetState(() {}),
    );
  }

  void _submit() {
    final initial = widget.initial;
    final typedNome = _nomeController.text.trim();
    final parsedArea =
        double.tryParse(_areaController.text.replaceAll(',', '.'));
    final nome = typedNome.isNotEmpty ? typedNome : (initial?.nome ?? '');
    final area = (parsedArea != null && parsedArea > 0)
        ? parsedArea
        : (initial?.areaHa ?? 0);
    final retiroId = _retiroId;
    final fallbackForrageiras = initial?.forrageiras.isNotEmpty == true
        ? initial!.forrageiras
        : [_forrageiraOptions.first];
    final forrageiras = _forrageirasSelecionadas.isNotEmpty
        ? _forrageirasSelecionadas
        : fallbackForrageiras;
    final pontos = _pontos.length >= 3 ? _pontos : (initial?.pontos ?? []);

    if (nome.isEmpty || area <= 0 || forrageiras.isEmpty || pontos.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Informe nome, área, ao menos uma forrageira e 3 pontos no mapa.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    widget.onSave(
      PiqueteFormResult(
        retiroId: retiroId,
        nome: nome,
        areaHa: area,
        forrageiras: forrageiras,
        anotacoes: _anotacoesController.text.trim(),
        pontos: pontos,
        animaisIds: _animaisIds,
        lotesIds: _lotesIds,
      ),
    );
  }

  void _applyInitial(PiquetePrototype? initial) {
    _retiroId = initial?.retiroId ??
        _store.selectedRetiro?.id ??
        PiqueteBackendStore.semRetiroId;
    final initialForrageiras = initial?.forrageiras
            .where((forrageira) => forrageira.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    _forrageirasSelecionadas = initialForrageiras.isNotEmpty
        ? initialForrageiras
        : [_forrageiraOptions.first];
    _mode = (initial?.lotesIds.isNotEmpty ?? false) ? 'lote' : 'animal';
    _pontos = initial?.pontos.toList() ?? [];
    _animaisIds = initial?.animaisIds.toList() ?? [];
    _lotesIds = initial?.lotesIds.toList() ?? [];
    _areaEditadaManualmente = initial != null;
    _nomeController.text = initial?.nome ?? '';
    _areaController.text = _formatAreaForInput(initial?.areaHa ?? 0);
    _anotacoesController.text = initial?.anotacoes ?? '';
    _searchAvailableController.clear();
    _searchSelectedController.clear();
    _animalLoteFilterController.clear();
    _animalOptionsPage = const [];
    _loteOptionsPage = const [];
    _animalOffset = 0;
    _loteOffset = 0;
    _animalHasNext = false;
    _loteHasNext = false;
    _loadingAnimals = false;
    _loadingLotes = false;
    _animalOptionsError = null;
    _loteOptionsError = null;
    _animalStatusFilter = '';
    _animalSexoFilter = '';
    _animalCategoriaFilter = '';
    _animalRacaFilter = '';
    _animalOrigemFilter = '';
    _animalNascimentoDeFilter = null;
    _animalNascimentoAteFilter = null;
    _loteStatusFilter = '';
    _loteCriacaoDeFilter = null;
    _loteCriacaoAteFilter = null;
  }

  String _formatAreaForInput(double area) {
    if (area <= 0) return '0';
    if (area < 1) return area.toStringAsFixed(2);
    if (area % 1 == 0) return area.toStringAsFixed(0);
    return area.toStringAsFixed(2);
  }

  List<PiqueteMapArea> _existingPiqueteAreas() {
    final currentPiqueteId = widget.initial?.id;
    return _store
        .piquetesDoRetiro(_retiroId)
        .where((piquete) => piquete.id != currentPiqueteId)
        .where((piquete) => piquete.pontos.length >= 3)
        .map(
          (piquete) => PiqueteMapArea(
            name: piquete.nome,
            points: piquete.pontos,
          ),
        )
        .toList();
  }

  String _initialIdentity(PiquetePrototype? piquete) => piquete?.id ?? 'novo';
}

class _DualPanel<T> extends StatelessWidget {
  const _DualPanel({
    required this.leftTitle,
    required this.rightTitle,
    required this.leftItems,
    required this.rightItems,
    required this.leftSearch,
    required this.rightSearch,
    required this.emptyRightMessage,
    required this.itemBuilder,
    required this.onAdd,
    required this.onRemove,
    required this.onSearchChanged,
    this.onSelectedSearchChanged,
    this.leftLoading = false,
    this.leftErrorMessage,
    this.leftFilters,
    this.leftPageLabel,
    this.leftHasPrevious = false,
    this.leftHasNext = false,
    this.leftOnPreviousPage,
    this.leftOnNextPage,
  });

  final String leftTitle;
  final String rightTitle;
  final List<T> leftItems;
  final List<T> rightItems;
  final TextEditingController leftSearch;
  final TextEditingController rightSearch;
  final String emptyRightMessage;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onAdd;
  final ValueChanged<T> onRemove;
  final VoidCallback onSearchChanged;
  final VoidCallback? onSelectedSearchChanged;
  final bool leftLoading;
  final String? leftErrorMessage;
  final Widget? leftFilters;
  final String? leftPageLabel;
  final bool leftHasPrevious;
  final bool leftHasNext;
  final VoidCallback? leftOnPreviousPage;
  final VoidCallback? leftOnNextPage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final left = _SelectionPanel<T>(
          title: leftTitle,
          items: leftItems,
          searchController: leftSearch,
          itemBuilder: itemBuilder,
          actionIcon: Icons.chevron_right_rounded,
          actionLabel: 'Adicionar',
          onAction: onAdd,
          onSearchChanged: onSearchChanged,
          loading: leftLoading,
          errorMessage: leftErrorMessage,
          filters: leftFilters,
          pageLabel: leftPageLabel,
          hasPrevious: leftHasPrevious,
          hasNext: leftHasNext,
          onPreviousPage: leftOnPreviousPage,
          onNextPage: leftOnNextPage,
        );
        final right = _SelectionPanel<T>(
          title: rightTitle,
          items: rightItems,
          searchController: rightSearch,
          itemBuilder: itemBuilder,
          actionIcon: Icons.chevron_left_rounded,
          actionLabel: 'Remover',
          onAction: onRemove,
          emptyMessage: emptyRightMessage,
          onSearchChanged: onSelectedSearchChanged ?? onSearchChanged,
        );
        if (narrow) {
          return Column(
            children: [left, const SizedBox(height: 18), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 24),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _SelectionPanel<T> extends StatelessWidget {
  const _SelectionPanel({
    required this.title,
    required this.items,
    required this.searchController,
    required this.itemBuilder,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
    required this.onSearchChanged,
    this.emptyMessage,
    this.loading = false,
    this.errorMessage,
    this.filters,
    this.pageLabel,
    this.hasPrevious = false,
    this.hasNext = false,
    this.onPreviousPage,
    this.onNextPage,
  });

  final String title;
  final List<T> items;
  final TextEditingController searchController;
  final Widget Function(T item) itemBuilder;
  final IconData actionIcon;
  final String actionLabel;
  final ValueChanged<T> onAction;
  final VoidCallback onSearchChanged;
  final String? emptyMessage;
  final bool loading;
  final String? errorMessage;
  final Widget? filters;
  final String? pageLabel;
  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border.all(color: theme.customColor5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          PrototypeSearchField(
            controller: searchController,
            hint: 'Pesquisar',
            onChanged: (_) => onSearchChanged(),
          ),
          if (filters != null) ...[
            const SizedBox(height: 14),
            filters!,
          ],
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 58),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 58),
              child: PrototypeEmptyState(
                title: 'Não foi possível carregar',
                message: errorMessage!,
                icon: Icons.warning_amber_rounded,
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 58),
              child: PrototypeEmptyState(
                title: 'Nada por aqui',
                message: emptyMessage ?? 'Nenhum item encontrado para seleção.',
                icon: Icons.inbox_outlined,
              ),
            )
          else
            ...items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.customColor5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: itemBuilder(item)),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => onAction(item),
                      icon: Icon(actionIcon, size: 18),
                      label: Text(actionLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.secondary,
                        side: BorderSide(color: theme.secondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (!loading &&
              errorMessage == null &&
              (pageLabel != null || hasPrevious || hasNext)) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    pageLabel ?? '',
                    style: GoogleFonts.poppins(
                      color: theme.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: hasPrevious ? onPreviousPage : null,
                  child: const Text('Anterior'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: hasNext ? onNextPage : null,
                  child: const Text('Próxima'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({required this.animal});

  final AnimalPrototype animal;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${animal.numero} • ${animal.nome} • ${animal.dataNascimento}',
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${animal.categoria} • ${animal.raca} • ${animal.loteNome}',
          style: GoogleFonts.poppins(
            color: theme.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoteTile extends StatelessWidget {
  const _LoteTile({required this.lote});

  final LotePrototype lote;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Icon(Icons.bubble_chart_outlined, color: theme.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lote.nome,
                style: GoogleFonts.poppins(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${lote.qtdAnimais} animais',
                style: GoogleFonts.poppins(
                  color: theme.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PrototypeBadge(
          label: lote.status,
          color: lote.status == 'Ativo' ? theme.primary : theme.secondaryText,
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: theme.customColor2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? theme.secondary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? theme.secondary : theme.secondaryText,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final effectiveOptions = [
      if (value.isNotEmpty && !options.contains(value)) value,
      ...options,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? '' : value,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: '',
              child: Text(hint),
            ),
            ...effectiveOptions.map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ),
            ),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.customColor2,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final text = value == null
        ? 'Selecionar'
        : dateTimeFormat(
            'd/M/y',
            value,
            locale: FFLocalizations.of(context).languageCode,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPick,
          child: Container(
            height: 46,
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
            decoration: BoxDecoration(
              color: theme.customColor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: value == null
                          ? theme.secondaryText
                          : theme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onClear != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onClear,
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.secondaryText,
                      size: 18,
                    ),
                  )
                else
                  Icon(
                    Icons.calendar_today_outlined,
                    color: theme.secondaryText,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.customColor2,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.customColor2,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.values,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final List<String> values;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showPicker(context),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.customColor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: values.isEmpty
                      ? Text(
                          'Selecionar forrageiras',
                          style: GoogleFonts.poppins(
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: values
                              .map(
                                (value) => PrototypeBadge(
                                  label: value,
                                  icon: Icons.grass_outlined,
                                  color: theme.secondary,
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = values.toSet();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = FlutterFlowTheme.of(context);
            return AlertDialog(
              backgroundColor: theme.secondaryBackground,
              title: Text(
                'Selecionar forrageiras',
                style: GoogleFonts.poppins(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    final checked = selected.contains(option);
                    return CheckboxListTile(
                      value: checked,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: theme.primary,
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value ?? false) {
                            selected.add(option);
                          } else {
                            selected.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    options
                        .where((option) => selected.contains(option))
                        .toList(),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}
