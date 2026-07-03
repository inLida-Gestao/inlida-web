import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pg_piquete/data/piquete_backend_store.dart';
import '/pg_piquete/prototype/mapa_demarcacao_real_widget.dart';
import '/pg_piquete/prototype/piquete_movimentacao_modal_widget.dart';
import '/pg_piquete/prototype/piquete_prototype_store.dart';
import '/pg_piquete/prototype/piquete_prototype_widgets.dart';
import '../modal_excluir_piquete/modal_excluir_piquete_widget.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pg_piquete_model.dart';
export 'pg_piquete_model.dart';

class PgPiqueteWidget extends StatefulWidget {
  const PgPiqueteWidget({super.key});

  static String routeName = 'pgPiquete';
  static String routePath = '/piquete';

  @override
  State<PgPiqueteWidget> createState() => _PgPiqueteWidgetState();
}

class _PgPiqueteWidgetState extends State<PgPiqueteWidget> {
  static const _existingRetiroColor = Color(0xFF7C3AED);

  late PgPiqueteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _store = PiqueteBackendStore.instance;
  late final VoidCallback _disposePiqueteRefresh;
  String? _selectedPiqueteId;
  String _mapContentMode = 'animais';
  final Set<String> _expandedRetiroIds = {};
  final Set<String> _expandedPiqueteIds = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgPiqueteModel());
    FFAppState().navegacao = 'piquetes';
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _store.addListener(_onStoreChanged);
    _disposePiqueteRefresh = FFAppState().onRefresh(
      'refreshPiquete',
      _handlePiqueteRefresh,
    );
    _loadPiquetes();
  }

  @override
  void dispose() {
    _disposePiqueteRefresh();
    _store.removeListener(_onStoreChanged);
    _model.dispose();
    super.dispose();
  }

  void _onStoreChanged() => safeSetState(() {});

  void _handlePiqueteRefresh() {
    _model.textController?.clear();
    _selectedPiqueteId = null;
    _loadPiquetes();
  }

  Future<void> _loadPiquetes() async {
    try {
      await _store.load();
    } catch (_) {
      // A mensagem amigável fica no store e é exibida na tela.
    }
  }

  List<PiquetePrototype> get _piquetesFiltrados {
    final retiro = _store.selectedRetiro;
    final query = (_model.textController?.text ?? '').trim().toLowerCase();
    final source = _store.mostrandoPiquetesSemRetiro
        ? _store.piquetesSemRetiro
        : (retiro == null
            ? const <PiquetePrototype>[]
            : _store.piquetesDoRetiro(retiro.id));
    return source.where((piquete) {
      if (query.isEmpty) return true;
      return piquete.nome.toLowerCase().contains(query) ||
          piquete.forrageira.toLowerCase().contains(query);
    }).toList();
  }

  PiquetePrototype? get _selectedPiquete {
    final selectedId = _selectedPiqueteId;
    if (selectedId != null && selectedId.isNotEmpty) {
      final selected = _store.piqueteById(selectedId);
      if (selected != null) return selected;
    }
    return null;
  }

  Future<void> _selectPiqueteFromTree(PiquetePrototype piquete) async {
    final wasSelected = _selectedPiqueteId == piquete.id;
    safeSetState(() {
      _selectedPiqueteId = piquete.id;
      if (wasSelected) {
        if (_expandedPiqueteIds.contains(piquete.id)) {
          _expandedPiqueteIds.remove(piquete.id);
        } else {
          _expandedPiqueteIds.add(piquete.id);
        }
      } else {
        _expandedPiqueteIds.add(piquete.id);
      }
      if (piquete.retiroId.isNotEmpty) {
        _expandedRetiroIds.add(piquete.retiroId);
      }
    });

    try {
      if (piquete.retiroId.isEmpty) {
        if (!_store.mostrandoPiquetesSemRetiro) {
          await _store.selectPiquetesSemRetiro();
        }
      } else if (_store.selectedRetiro?.id != piquete.retiroId) {
        await _store.selectRetiro(piquete.retiroId);
      }
      await _store.loadPiqueteDetail(piquete.id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ?? 'Não foi possível carregar o piquete.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _selectPiquetesSemLimites() async {
    safeSetState(() => _selectedPiqueteId = null);
    try {
      await _store.selectPiquetesSemRetiro();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível carregar os piquetes sem retiro.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _selectLimites(String id) async {
    safeSetState(() {
      _selectedPiqueteId = null;
    });
    try {
      await _store.selectRetiro(id);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ?? 'Não foi possível carregar o retiro.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  void _openAddPiquete() {
    if (!_store.temLimitePropriedade) {
      _showLimiteRequiredSnack();
      return;
    }
    context.pushNamed(PgAddPiqueteWidget.routeName);
  }

  Future<void> _openRetiroDialog({RetiroPrototype? initial}) async {
    if (!_store.temLimitePropriedade) {
      _showLimiteRequiredSnack();
      return;
    }

    if (initial == null) {
      try {
        await _store.load();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _store.errorMessage ??
                  'Não foi possível atualizar os retiros existentes.',
            ),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }

    if (!mounted) return;
    final refreshedInitial =
        initial == null ? null : (_store.retiroById(initial.id) ?? initial);
    await _showRetiroDialog(initial: refreshedInitial);
  }

  void _showLimiteRequiredSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Cadastre o limite da propriedade antes de criar retiros ou piquetes.',
        ),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PiquetePrototypeScaffold(
      scaffoldKey: scaffoldKey,
      headerModel: _model.headerModel,
      sideBarModel: _model.sideBarModel,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(28, 28, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrototypePageHeader(
              title: 'Piquetes',
              subtitle: 'Limite da propriedade, retiros e áreas de pastejo',
              actions: [
                PrototypeSecondaryButton(
                  label: _store.temLimitePropriedade
                      ? 'Editar limite'
                      : 'Criar limite',
                  icon: Icons.map_outlined,
                  onPressed: () => _showLimiteDialog(
                    initial: _store.limitePropriedade,
                  ),
                ),
                PrototypeSecondaryButton(
                  label: 'Adicionar retiro',
                  icon: Icons.add_location_alt_outlined,
                  onPressed: _openRetiroDialog,
                ),
                PrototypePrimaryButton(
                  label: 'Adicionar piquete',
                  icon: Icons.add_rounded,
                  onPressed: _openAddPiquete,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 232,
                  child: _buildLimiteMetricCard(context),
                ),
                SizedBox(
                  width: 232,
                  child: PrototypeMetricCard(
                    title: 'Retiros cadastrados',
                    value: _store.retiros.length.toString(),
                    icon: Icons.account_tree_outlined,
                  ),
                ),
                SizedBox(
                  width: 232,
                  child: PrototypeMetricCard(
                    title: 'Piquetes cadastrados',
                    value: _store.totalPiquetes.toString(),
                    icon: kPiqueteMenuIcon,
                  ),
                ),
                SizedBox(
                  width: 232,
                  child: PrototypeMetricCard(
                    title: 'Animais em piquetes',
                    value: _store.totalAnimaisEmPiquetes.toString(),
                    iconAsset: kPiqueteCowIconAsset,
                  ),
                ),
                SizedBox(
                  width: 232,
                  child: PrototypeMetricCard(
                    title: 'Lotes em piquetes',
                    value: _store.totalLotesEmPiquetes.toString(),
                    iconAsset: kPiqueteLoteIconAsset,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_store.loading &&
                _store.retiros.isEmpty &&
                _store.piquetesSemRetiro.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_store.errorMessage != null &&
                _store.retiros.isEmpty &&
                _store.piquetesSemRetiro.isEmpty)
              Center(
                child: SizedBox(
                  width: 640,
                  child: PrototypeEmptyState(
                    title: 'Não foi possível carregar os piquetes',
                    message: _store.errorMessage!,
                    icon: Icons.warning_amber_rounded,
                    action: PrototypePrimaryButton(
                      label: 'Tentar novamente',
                      icon: Icons.refresh_rounded,
                      onPressed: _loadPiquetes,
                    ),
                  ),
                ),
              )
            else if (_store.retiros.isEmpty && _store.piquetesSemRetiro.isEmpty)
              Center(
                child: SizedBox(
                  width: 640,
                  child: PrototypeEmptyState(
                    title: 'Nenhum piquete cadastrado',
                    message:
                        'Cadastre o limite da propriedade e depois organize áreas em retiros e piquetes.',
                    icon: Icons.crop_square_rounded,
                    action: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        PrototypePrimaryButton(
                          label: 'Adicionar piquete',
                          icon: Icons.add_rounded,
                          onPressed: _openAddPiquete,
                        ),
                        PrototypeSecondaryButton(
                          label: _store.temLimitePropriedade
                              ? 'Criar retiro'
                              : 'Criar limite',
                          icon: Icons.add_location_alt_outlined,
                          onPressed: _store.temLimitePropriedade
                              ? _openRetiroDialog
                              : () => _showLimiteDialog(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              _buildPiqueteWorkspace(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLimiteMetricCard(BuildContext context) {
    final limite = _store.limitePropriedade;
    return SizedBox(
      height: 92,
      child: PrototypeCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(kPiqueteRadius),
          onTap: () => _showLimiteDialog(initial: limite),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: kPiquetePrimarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  limite == null ? Icons.add_location_alt_outlined : Icons.map,
                  color: kPiquetePrimary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Limite cadastrado',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: kPiqueteTextMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      limite == null
                          ? 'Criar limite'
                          : '${limite.areaHa.toStringAsFixed(0)} ha',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: kPiqueteTextStrong,
                        fontSize: limite == null ? 17 : 21,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    if (limite != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${limite.areaDisponivelHa.toStringAsFixed(1)} ha disponíveis',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: kPiqueteTextSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                limite == null
                    ? Icons.add_rounded
                    : Icons.edit_location_alt_outlined,
                color: kPiquetePrimaryDark,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPiqueteWorkspace(BuildContext context) {
    final selected = _selectedPiquete;
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1040;
        final explorer = _buildPiqueteTreePanel(context);
        final map = _buildPiqueteMap(context, selected: selected);

        if (narrow) {
          return Column(
            children: [
              explorer,
              const SizedBox(height: 16),
              map,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 378, child: explorer),
            const SizedBox(width: 16),
            Expanded(child: map),
          ],
        );
      },
    );
  }

  Widget _buildPiqueteTreePanel(BuildContext context) {
    final showingSemRetiro = _store.mostrandoPiquetesSemRetiro;
    final piquetesPorRetiro = _store.retiros
        .fold<int>(0, (total, retiro) => total + retiro.piquetesCount);
    return PrototypeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Áreas de pastejo',
                  style: GoogleFonts.poppins(
                    color: kPiqueteTextStrong,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PrototypeBadge(
                label: '${_store.totalPiquetes} piquetes',
                icon: kPiqueteMenuIcon,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PiqueteSegmentedTabs(
            showingSemRetiro: showingSemRetiro,
            retiroCount: piquetesPorRetiro,
            semRetiroCount: _store.piquetesSemRetiro.length,
            onRetirosTap: () {
              final selectedRetiro = _store.selectedRetiro;
              final retiro = selectedRetiro ?? _store.retiros.firstOrNull;
              if (retiro != null) _selectLimites(retiro.id);
            },
            onSemRetiroTap: _selectPiquetesSemLimites,
          ),
          const SizedBox(height: 14),
          PrototypeSearchField(
            controller: _model.textController!,
            hint: 'Pesquisar piquete ou retiro',
            onChanged: (_) => safeSetState(() {}),
          ),
          const SizedBox(height: 14),
          if (showingSemRetiro)
            _buildSemRetiroTree(context)
          else
            _buildRetirosTree(context),
        ],
      ),
    );
  }

  Widget _buildRetirosTree(BuildContext context) {
    final query = (_model.textController?.text ?? '').trim().toLowerCase();
    final visibleRetiros = _store.retiros.where((retiro) {
      if (query.isEmpty) return true;
      final piquetes = _store.piquetesDoRetiro(retiro.id);
      return retiro.nome.toLowerCase().contains(query) ||
          piquetes.any((piquete) => _piqueteMatchesQuery(piquete, query));
    }).toList();

    if (visibleRetiros.isEmpty) {
      return PrototypeEmptyState(
        title: 'Nenhum retiro encontrado',
        message: 'Ajuste a busca ou cadastre um novo retiro.',
        icon: Icons.search_off_rounded,
        action: PrototypeSecondaryButton(
          label: 'Adicionar retiro',
          icon: Icons.add_location_alt_outlined,
          onPressed: _openRetiroDialog,
        ),
      );
    }

    return Column(
      children: visibleRetiros
          .map((retiro) {
            final expanded =
                _expandedRetiroIds.contains(retiro.id) || query.isNotEmpty;
            final allPiquetesDoRetiro = _store.piquetesDoRetiro(retiro.id);
            final piquetes = _filteredPiquetes(
              allPiquetesDoRetiro,
              query,
              includeAllWhenQueryMatchesGroup:
                  retiro.nome.toLowerCase().contains(query),
            );
            return _RetiroTreeCard(
              retiro: retiro,
              piquetes: piquetes,
              previewPiquetes: allPiquetesDoRetiro,
              expanded: expanded,
              selectedPiqueteId: _selectedPiqueteId,
              expandedPiqueteIds: _expandedPiqueteIds,
              onHeaderTap: () => _toggleRetiro(retiro),
              onEdit: () => _openRetiroDialog(initial: retiro),
              onDelete: () => _deleteRetiro(retiro),
              onPiqueteTap: (piquete) => _selectPiqueteFromTree(piquete),
            );
          })
          .toList()
          .divide(const SizedBox(height: 10)),
    );
  }

  Widget _buildSemRetiroTree(BuildContext context) {
    final piquetes = _filteredPiquetes(
      _store.piquetesSemRetiro,
      (_model.textController?.text ?? '').trim().toLowerCase(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPiqueteLimit.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(kPiqueteRadius),
            border: Border.all(color: kPiqueteLimit.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF8A5A00),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Piquetes cadastrados diretamente no limite da propriedade.',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8A5A00),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (piquetes.isEmpty)
          PrototypeEmptyState(
            title: 'Nenhum piquete sem retiro',
            message: 'Adicione um piquete direto no limite da propriedade.',
            icon: Icons.crop_square_rounded,
            action: PrototypePrimaryButton(
              label: 'Adicionar piquete',
              onPressed: () => context.pushNamed(PgAddPiqueteWidget.routeName),
            ),
          )
        else
          Column(
            children: piquetes
                .map(
                  (piquete) => _PiqueteTreeTile(
                    piquete: piquete,
                    selected: _selectedPiqueteId == piquete.id,
                    expanded: _expandedPiqueteIds.contains(piquete.id),
                    compact: false,
                    onTap: () => _selectPiqueteFromTree(piquete),
                  ),
                )
                .toList()
                .divide(const SizedBox(height: 10)),
          ),
      ],
    );
  }

  List<PiquetePrototype> _filteredPiquetes(
    List<PiquetePrototype> piquetes,
    String query, {
    bool includeAllWhenQueryMatchesGroup = false,
  }) {
    if (query.isEmpty || includeAllWhenQueryMatchesGroup) return piquetes;
    return piquetes
        .where((piquete) => _piqueteMatchesQuery(piquete, query))
        .toList();
  }

  bool _piqueteMatchesQuery(PiquetePrototype piquete, String query) {
    if (query.isEmpty) return true;
    return piquete.nome.toLowerCase().contains(query) ||
        piquete.forrageira.toLowerCase().contains(query);
  }

  Future<void> _toggleRetiro(RetiroPrototype retiro) async {
    final expanded = _expandedRetiroIds.contains(retiro.id);
    safeSetState(() {
      if (expanded) {
        _expandedRetiroIds.remove(retiro.id);
      } else {
        _expandedRetiroIds.add(retiro.id);
      }
      _selectedPiqueteId = null;
    });
    await _selectLimites(retiro.id);
  }

  Widget _buildPiqueteMap(
    BuildContext context, {
    required PiquetePrototype? selected,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final retiroDoPiquete = selected?.retiroId.isEmpty ?? true
        ? null
        : _store.retiroById(selected?.retiroId);
    final retiroSelecionado =
        selected == null && !_store.mostrandoPiquetesSemRetiro
            ? _store.selectedRetiro
            : null;
    final piquetesDoContexto = selected == null
        ? _piquetesFiltrados
        : (selected.retiroId.isEmpty
            ? _store.piquetesSemRetiro
            : _store.piquetesDoRetiro(selected.retiroId));
    final referencePoints = selected != null && retiroDoPiquete != null
        ? retiroDoPiquete.pontos
        : (_store.limitePropriedade?.pontos ?? const <MapPoint>[]);
    final primaryPoints =
        selected?.pontos ?? retiroSelecionado?.pontos ?? const <MapPoint>[];
    final title =
        selected?.nome ?? retiroSelecionado?.nome ?? 'Selecione um piquete';
    final legendLabel = title;
    final selectedId = selected?.id;
    final markerLabel =
        _mapContentMode == 'lotes' ? 'Animais em lotes' : 'Animais sem lote';
    final overlayAreas = piquetesDoContexto
        .where(
            (piquete) => piquete.id != selectedId && piquete.pontos.length > 1)
        .map(
          (piquete) => PiqueteMapArea(
            name: piquete.nome,
            points: piquete.pontos,
            legendLabel: piquete.nome,
            fillOpacity: 0.18,
            borderStrokeWidth: 2.2,
            markerCount: _piqueteMapContentCount(piquete),
            markerLabel: '$markerLabel • ${piquete.nome}',
          ),
        )
        .toList();
    final primaryMarkers = selected == null || _mapContentMode != 'lotes'
        ? const <PiqueteMapMarker>[]
        : _store
            .lotesByIds(selected.lotesIds)
            .map(
              (lote) => PiqueteMapMarker(
                count: lote.qtdAnimais,
                label: lote.nome,
              ),
            )
            .toList();
    final contentToggle = _PiqueteMapContentToggle(
      mode: _mapContentMode,
      lotesCount: piquetesDoContexto.fold<int>(
        0,
        (total, piquete) => total + _piqueteLoteAnimalCount(piquete),
      ),
      animaisSemLoteCount: piquetesDoContexto.fold<int>(
        0,
        (total, piquete) => total + piquete.totalAnimaisIndividuais,
      ),
      onChanged: (mode) => safeSetState(() => _mapContentMode = mode),
    );

    return MapaDemarcacaoRealWidget(
      title: title,
      points: primaryPoints,
      retiroPoints: referencePoints,
      referenceLegendLabel: retiroDoPiquete?.nome ?? 'Limite',
      piqueteAreas: overlayAreas,
      pointsLegendLabel: legendLabel,
      height: 640,
      primaryMarkerCount: primaryMarkers.isNotEmpty || selected == null
          ? null
          : _piqueteMapContentCount(selected),
      primaryMarkerLabel:
          selected == null ? null : '$markerLabel • ${selected.nome}',
      primaryMarkers: primaryMarkers,
      actions: [
        contentToggle,
        if (selected != null) ...[
          PrototypePrimaryButton(
            label: 'Movimentar animais',
            icon: Icons.compare_arrows_rounded,
            onPressed: () => _showMovimentarAnimaisDialog(selected),
          ),
          PrototypeSecondaryButton(
            label: 'Ver histórico',
            icon: Icons.history_rounded,
            onPressed: () => _openPiqueteView(selected),
          ),
          PrototypeSecondaryButton(
            label: 'Editar piquete',
            icon: Icons.edit_outlined,
            onPressed: () => _openPiqueteEdit(selected),
          ),
          OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(selected),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Excluir piquete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.error,
              side: BorderSide(color: theme.error),
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kPiqueteRadius),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ] else if (retiroSelecionado != null) ...[
          PrototypeSecondaryButton(
            label: 'Editar retiro',
            icon: Icons.edit_location_alt_outlined,
            onPressed: () => _openRetiroDialog(initial: retiroSelecionado),
          ),
          OutlinedButton.icon(
            onPressed: () => _deleteRetiro(retiroSelecionado),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Excluir retiro'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.error,
              side: BorderSide(color: theme.error),
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kPiqueteRadius),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PrototypePrimaryButton(
            label: 'Adicionar piquete',
            icon: Icons.add_rounded,
            onPressed: _openAddPiquete,
          ),
        ] else
          PrototypePrimaryButton(
            label: 'Adicionar piquete',
            icon: Icons.add_rounded,
            onPressed: _openAddPiquete,
          ),
      ],
    );
  }

  int _piqueteLoteAnimalCount(PiquetePrototype piquete) {
    if (piquete.animaisLotesCount > 0) return piquete.animaisLotesCount;
    return piquete.totalLotes;
  }

  int _piqueteMapContentCount(PiquetePrototype piquete) {
    if (_mapContentMode == 'lotes') {
      return _piqueteLoteAnimalCount(piquete);
    }
    return piquete.totalAnimaisIndividuais;
  }

  Future<void> _showMovimentarAnimaisDialog(PiquetePrototype piquete) async {
    PiquetePrototype loaded = piquete;
    try {
      loaded = await _store.loadPiqueteDetail(piquete.id) ?? piquete;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível carregar os animais do piquete.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final viewport = MediaQuery.sizeOf(dialogContext);
        return Dialog(
          insetPadding: const EdgeInsets.all(14),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 820,
              maxHeight: (viewport.height - 28).clamp(560.0, 880.0),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: PiqueteMovimentacaoModalWidget(
                initial: loaded,
                onClose: () => Navigator.pop(dialogContext),
                onChanged: (updated) {
                  loaded = updated;
                  if (!mounted) return;
                  safeSetState(() => _selectedPiqueteId = updated.id);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openPiqueteEdit(PiquetePrototype piquete) {
    context.pushNamed(
      PgEditPiqueteWidget.routeName,
      queryParameters: {
        'idPiquete': serializeParam(
          piquete.id,
          ParamType.String,
        ),
        'piqueteNome': serializeParam(
          piquete.nome,
          ParamType.String,
        ),
      }.withoutNulls,
    );
  }

  void _openPiqueteView(PiquetePrototype piquete) {
    context.pushNamed(
      PgViewPiqueteWidget.routeName,
      queryParameters: {
        'idPiquete': serializeParam(
          piquete.id,
          ParamType.String,
        ),
        'piqueteNome': serializeParam(
          piquete.nome,
          ParamType.String,
        ),
      }.withoutNulls,
    );
  }

  Future<void> _showLimiteDialog({
    LimitePropriedadePrototype? initial,
  }) async {
    final editing = initial != null;
    final nomeController = TextEditingController(
      text: initial?.nome ?? '',
    );
    final areaController = TextEditingController(
      text: _formatAreaInput(initial?.areaHa ?? 0),
    );
    final anotacoesController =
        TextEditingController(text: initial?.anotacoes ?? '');
    var pontos = initial?.pontos.toList() ?? <MapPoint>[];
    var areaEditedManually = editing;
    var updatingAreaFromMap = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final viewport = MediaQuery.sizeOf(context);
            final maxDialogHeight = viewport.height > 520
                ? viewport.height - 48
                : viewport.height - 24;
            return Dialog(
              insetPadding: const EdgeInsets.all(32),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1380,
                  maxHeight: maxDialogHeight,
                ),
                child: SingleChildScrollView(
                  child: PrototypeCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PrototypePageHeader(
                          title: editing
                              ? 'Editar limite da propriedade'
                              : 'Criar limite da propriedade',
                          subtitle:
                              'Demarque a área total onde retiros e piquetes podem existir',
                          actions: [
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 980;
                            final mapHeight =
                                (viewport.height - (narrow ? 300 : 250))
                                    .clamp(narrow ? 420.0 : 500.0,
                                        narrow ? 540.0 : 620.0)
                                    .toDouble();
                            final inputs = SizedBox(
                              width: narrow ? double.infinity : 290,
                              child: Column(
                                children: [
                                  _PrototypeTextField(
                                    controller: nomeController,
                                    label: 'Nome do limite',
                                    hint: 'Ex.: Fazenda Santa Maria',
                                  ),
                                  const SizedBox(height: 14),
                                  _PrototypeTextField(
                                    controller: areaController,
                                    label: 'Área total (ha)',
                                    hint: 'Ex.: 120',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) {
                                      if (!updatingAreaFromMap) {
                                        areaEditedManually = true;
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _PrototypeTextField(
                                    controller: anotacoesController,
                                    label: 'Observações',
                                    hint: 'Referências, matrícula, divisas...',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            );
                            final map = MapaDemarcacaoRealWidget(
                              title: 'Limite da propriedade',
                              points: pontos,
                              editable: true,
                              height: mapHeight,
                              pointsLegendLabel:
                                  editing ? 'Limite em edição' : 'Novo limite',
                              preferUserLocation: !editing,
                              onChanged: (value) => setDialogState(() {
                                pontos = value;
                                if (!areaEditedManually) {
                                  updatingAreaFromMap = true;
                                  _updateAreaControllerFromMap(
                                    areaController,
                                    pontos,
                                  );
                                  updatingAreaFromMap = false;
                                }
                              }),
                              onImported: (value) => setDialogState(() {
                                pontos = value;
                                areaEditedManually = false;
                                updatingAreaFromMap = true;
                                _updateAreaControllerFromMap(
                                  areaController,
                                  pontos,
                                );
                                updatingAreaFromMap = false;
                              }),
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  inputs,
                                  const SizedBox(height: 18),
                                  map,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                inputs,
                                const SizedBox(width: 22),
                                Expanded(child: map),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (editing)
                              OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  await _deleteLimitePropriedade(initial);
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                label: const Text('Excluir limite'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      FlutterFlowTheme.of(context).error,
                                  side: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                  ),
                                  minimumSize: const Size(44, 52),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(kPiqueteRadius),
                                  ),
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Row(
                              children: [
                                PrototypeSecondaryButton(
                                  label: 'Cancelar',
                                  onPressed: () => Navigator.pop(dialogContext),
                                ),
                                PrototypePrimaryButton(
                                  label: editing
                                      ? 'Salvar alterações'
                                      : 'Salvar limite',
                                  icon: Icons.check_rounded,
                                  onPressed: () {
                                    final nome = nomeController.text.trim();
                                    final area = double.tryParse(
                                          areaController.text
                                              .replaceAll(',', '.'),
                                        ) ??
                                        0;
                                    if (nome.isEmpty ||
                                        area <= 0 ||
                                        pontos.length < 3) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Informe nome, área e ao menos 3 pontos no mapa.',
                                          ),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .error,
                                        ),
                                      );
                                      return;
                                    }
                                    () async {
                                      try {
                                        await _store.saveLimitePropriedade(
                                          limite: initial,
                                          nome: nome,
                                          areaHa: area,
                                          anotacoes:
                                              anotacoesController.text.trim(),
                                          pontos: pontos,
                                        );
                                        if (!dialogContext.mounted) return;
                                        Navigator.pop(dialogContext);
                                      } catch (_) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _store.errorMessage ??
                                                  'Não foi possível salvar o limite da propriedade.',
                                            ),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                          ),
                                        );
                                      }
                                    }();
                                  },
                                ),
                              ].divide(const SizedBox(width: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nomeController.dispose();
    areaController.dispose();
    anotacoesController.dispose();
  }

  Future<void> _showRetiroDialog({RetiroPrototype? initial}) async {
    final editing = initial != null;
    final existingRetiroAreas = _existingRetiroAreas(except: initial);
    final nomeController = TextEditingController(text: initial?.nome ?? '');
    final areaController = TextEditingController(
      text: _formatAreaInput(initial?.areaInformadaHa ?? 0),
    );
    final anotacoesController =
        TextEditingController(text: initial?.anotacoes ?? '');
    var pontos = initial?.pontos.toList() ?? <MapPoint>[];
    var areaEditedManually = editing;
    var updatingAreaFromMap = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final viewport = MediaQuery.sizeOf(context);
            final maxDialogHeight = viewport.height > 520
                ? viewport.height - 48
                : viewport.height - 24;
            return Dialog(
              insetPadding: const EdgeInsets.all(32),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1380,
                  maxHeight: maxDialogHeight,
                ),
                child: SingleChildScrollView(
                  child: PrototypeCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PrototypePageHeader(
                          title: editing ? 'Editar retiro' : 'Criar retiro',
                          subtitle: existingRetiroAreas.isEmpty
                              ? (editing
                                  ? 'Ajuste dados e, se necessário, a demarcação do retiro'
                                  : 'Informe os dados do retiro. A demarcação da área é opcional.')
                              : (editing
                                  ? 'Outros retiros aparecem em roxo para evitar sobreposição'
                                  : 'Retiros já cadastrados aparecem em roxo. A demarcação da área é opcional.'),
                          actions: [
                            IconButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 980;
                            final mapHeight =
                                (viewport.height - (narrow ? 300 : 250))
                                    .clamp(narrow ? 420.0 : 500.0,
                                        narrow ? 540.0 : 620.0)
                                    .toDouble();
                            final inputs = SizedBox(
                              width: narrow ? double.infinity : 290,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _PrototypeTextField(
                                    controller: nomeController,
                                    label: 'Nome do retiro',
                                    hint: 'Ex.: Retiro Sede',
                                  ),
                                  const SizedBox(height: 14),
                                  _PrototypeTextField(
                                    controller: areaController,
                                    label: 'Área total (ha)',
                                    hint: 'Ex.: 120',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) {
                                      if (!updatingAreaFromMap) {
                                        areaEditedManually = true;
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _PrototypeTextField(
                                    controller: anotacoesController,
                                    label: 'Observações',
                                    hint: 'Referências, acesso, manejo...',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            );
                            final map = MapaDemarcacaoRealWidget(
                              title: 'Área do retiro',
                              points: pontos,
                              retiroPoints:
                                  _store.limitePropriedade?.pontos ?? const [],
                              piqueteAreas: existingRetiroAreas,
                              pointsLegendLabel:
                                  editing ? 'Retiro em edição' : 'Novo retiro',
                              editable: true,
                              height: mapHeight,
                              preferUserLocation: !editing,
                              onChanged: (value) => setDialogState(() {
                                pontos = value;
                                if (!areaEditedManually) {
                                  updatingAreaFromMap = true;
                                  _updateAreaControllerFromMap(
                                    areaController,
                                    pontos,
                                  );
                                  updatingAreaFromMap = false;
                                }
                              }),
                              onImported: (value) => setDialogState(() {
                                pontos = value;
                                areaEditedManually = false;
                                updatingAreaFromMap = true;
                                _updateAreaControllerFromMap(
                                  areaController,
                                  pontos,
                                );
                                updatingAreaFromMap = false;
                              }),
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  inputs,
                                  const SizedBox(height: 18),
                                  map,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                inputs,
                                const SizedBox(width: 22),
                                Expanded(child: map),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (editing)
                              OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(dialogContext);
                                  await _deleteRetiro(initial);
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                label: const Text('Excluir retiro'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      FlutterFlowTheme.of(context).error,
                                  side: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                  ),
                                  minimumSize: const Size(44, 52),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(kPiqueteRadius),
                                  ),
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            Row(
                              children: [
                                PrototypeSecondaryButton(
                                  label: 'Cancelar',
                                  onPressed: () => Navigator.pop(dialogContext),
                                ),
                                PrototypePrimaryButton(
                                  label: editing
                                      ? 'Salvar alterações'
                                      : 'Salvar retiro',
                                  icon: Icons.check_rounded,
                                  onPressed: () {
                                    final nome = nomeController.text.trim();
                                    final area = double.tryParse(
                                          areaController.text
                                              .replaceAll(',', '.'),
                                        ) ??
                                        0;
                                    if (nome.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Informe o nome do retiro. Área e demarcação no mapa são opcionais.',
                                          ),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .error,
                                        ),
                                      );
                                      return;
                                    }
                                    () async {
                                      try {
                                        if (editing) {
                                          await _store.updateRetiro(
                                            retiro: initial,
                                            nome: nome,
                                            areaHa: area,
                                            anotacoes:
                                                anotacoesController.text.trim(),
                                            pontos: pontos,
                                          );
                                        } else {
                                          await _store.addRetiro(
                                            nome: nome,
                                            areaHa: area,
                                            anotacoes:
                                                anotacoesController.text.trim(),
                                            pontos: pontos,
                                          );
                                        }
                                        if (!dialogContext.mounted) return;
                                        Navigator.pop(dialogContext);
                                      } catch (_) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _store.errorMessage ??
                                                  'Não foi possível salvar o retiro.',
                                            ),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .error,
                                          ),
                                        );
                                      }
                                    }();
                                  },
                                ),
                              ].divide(const SizedBox(width: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nomeController.dispose();
    areaController.dispose();
    anotacoesController.dispose();
  }

  List<PiqueteMapArea> _existingRetiroAreas({RetiroPrototype? except}) {
    final exceptId = except?.id;
    return _store.retiros
        .where((retiro) => retiro.id != exceptId)
        .where((retiro) => retiro.pontos.length >= 3)
        .map(
          (retiro) => PiqueteMapArea(
            name: retiro.nome,
            points: retiro.pontos,
            color: _existingRetiroColor,
            legendLabel: 'Retiro existente',
            fillOpacity: 0.20,
            borderStrokeWidth: 3.2,
          ),
        )
        .toList();
  }

  Future<void> _deleteLimitePropriedade(
    LimitePropriedadePrototype limite,
  ) async {
    final confirmed = await _confirmDelete(
      title: 'Excluir limite da propriedade',
      message:
          'Tem certeza que deseja excluir o limite "${limite.nome}"? Retiros e piquetes existentes permanecem cadastrados, mas será necessário criar um novo limite antes de novas demarcações.',
      confirmLabel: 'Excluir limite',
    );
    if (!confirmed) return;

    try {
      await _store.deleteLimitePropriedade(limite.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Limite excluído'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível excluir o limite da propriedade.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _deleteRetiro(RetiroPrototype retiro) async {
    final confirmed = await _confirmDelete(
      title: 'Excluir retiro',
      message:
          'Tem certeza que deseja excluir o retiro "${retiro.nome}"? Os piquetes vinculados serão mantidos e movidos para "Sem retiro".',
      confirmLabel: 'Excluir retiro',
    );
    if (!confirmed) return;

    try {
      await _store.deleteRetiro(retiro.id);
      if (!mounted) return;
      safeSetState(() => _selectedPiqueteId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Retiro excluído'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ?? 'Não foi possível excluir o retiro.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = FlutterFlowTheme.of(dialogContext);
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: theme.error),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _showDeleteDialog(PiquetePrototype piquete) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: ModalExcluirPiqueteWidget(
            idPiquete: piquete.id,
            piqueteNome: piquete.nome,
          ),
        );
      },
    );
  }

  void _updateAreaControllerFromMap(
    TextEditingController controller,
    List<MapPoint> pontos,
  ) {
    final areaHa = estimateMapAreaHa(pontos);
    final text = areaHa > 0 ? _formatAreaInput(areaHa) : '0';
    if (controller.text == text) return;

    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatAreaInput(double areaHa) {
    final decimals = areaHa >= 10 ? 1 : 2;
    return areaHa.toStringAsFixed(decimals).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _RetiroTreeCard extends StatelessWidget {
  const _RetiroTreeCard({
    required this.retiro,
    required this.piquetes,
    required this.previewPiquetes,
    required this.expanded,
    required this.selectedPiqueteId,
    required this.expandedPiqueteIds,
    required this.onHeaderTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPiqueteTap,
  });

  final RetiroPrototype retiro;
  final List<PiquetePrototype> piquetes;
  final List<PiquetePrototype> previewPiquetes;
  final bool expanded;
  final String? selectedPiqueteId;
  final Set<String> expandedPiqueteIds;
  final VoidCallback onHeaderTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<PiquetePrototype> onPiqueteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPiqueteSurface,
        borderRadius: BorderRadius.circular(kPiqueteRadius),
        border: Border.all(color: kPiqueteBorder),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(kPiqueteRadius),
            onTap: onHeaderTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    color: kPiqueteTextMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  _AreaPreviewBox(
                    points: retiro.pontos,
                    fallbackAreas: previewPiquetes
                        .where((piquete) => piquete.pontos.length >= 3)
                        .map((piquete) => piquete.pontos)
                        .toList(),
                    color: kPiqueteLimit,
                    size: 58,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          retiro.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: kPiqueteTextStrong,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            PrototypeBadge(
                              label: '${retiro.areaHa.toStringAsFixed(0)} ha',
                              icon: Icons.crop_square_rounded,
                            ),
                            PrototypeBadge(
                              label: '${retiro.piquetesCount} piquetes',
                              icon: kPiqueteMenuIcon,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Ações do retiro',
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: kPiqueteTextMuted,
                    ),
                    onSelected: (action) {
                      if (action == 'edit') onEdit();
                      if (action == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar retiro'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir retiro'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 12, 12),
              child: piquetes.isEmpty
                  ? _RetiroEmptyPiquetes(retiro: retiro)
                  : Column(
                      children: piquetes
                          .map(
                            (piquete) => _PiqueteTreeTile(
                              piquete: piquete,
                              selected: selectedPiqueteId == piquete.id,
                              expanded: expandedPiqueteIds.contains(piquete.id),
                              compact: true,
                              onTap: () => onPiqueteTap(piquete),
                            ),
                          )
                          .toList()
                          .divide(const SizedBox(height: 8)),
                    ),
            ),
        ],
      ),
    );
  }
}

class _RetiroEmptyPiquetes extends StatelessWidget {
  const _RetiroEmptyPiquetes({required this.retiro});

  final RetiroPrototype retiro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPiqueteSurface,
        borderRadius: BorderRadius.circular(kPiqueteRadius),
        border: Border.all(color: kPiqueteBorder),
      ),
      child: Text(
        'Nenhum piquete carregado em ${retiro.nome}.',
        style: GoogleFonts.poppins(
          color: kPiqueteTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PiqueteTreeTile extends StatelessWidget {
  const _PiqueteTreeTile({
    required this.piquete,
    required this.selected,
    required this.expanded,
    required this.compact,
    required this.onTap,
  });

  final PiquetePrototype piquete;
  final bool selected;
  final bool expanded;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalAnimais =
        piquete.totalAnimaisIndividuais + piquete.animaisLotesCount;
    final occupied = totalAnimais > 0 || piquete.totalLotes > 0;
    return InkWell(
      borderRadius: BorderRadius.circular(kPiqueteRadius),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 10 : 12),
        decoration: BoxDecoration(
          color: selected ? kPiquetePrimarySurface : kPiqueteSurface,
          borderRadius: BorderRadius.circular(kPiqueteRadius),
          border: Border.all(
            color: selected ? kPiquetePrimary : kPiqueteBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AreaPreviewBox(
                  points: piquete.pontos,
                  color: kPiquetePrimary,
                  size: compact ? 38 : 42,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        piquete.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: selected
                              ? kPiquetePrimaryDark
                              : kPiqueteTextStrong,
                          fontSize: compact ? 13.5 : 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: occupied
                                  ? kPiquetePrimary
                                  : const Color(0xFFB8C1BA),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              occupied
                                  ? '$totalAnimais animais'
                                  : 'Sem animais',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: kPiqueteTextMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${piquete.areaHa.toStringAsFixed(0)} ha',
                  style: GoogleFonts.poppins(
                    color: kPiqueteTextStrong,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  color: kPiqueteTextMuted,
                  size: 20,
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: kPiqueteSurface,
                  borderRadius: BorderRadius.circular(kPiqueteRadius),
                  border: Border.all(color: kPiqueteBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PiqueteDetailCell(
                            label: 'ÁREA',
                            value: '${piquete.areaHa.toStringAsFixed(0)} ha',
                            icon: Icons.hexagon_outlined,
                            iconColor: kPiquetePrimary,
                          ),
                        ),
                        Expanded(
                          child: _PiqueteDetailCell(
                            label: 'ANIMAIS',
                            value: totalAnimais.toString(),
                            iconAsset: kPiqueteCowIconAsset,
                            iconColor: kPiquetePrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: kPiqueteBorder),
                    Row(
                      children: [
                        Expanded(
                          child: _PiqueteDetailCell(
                            label: 'LOTES',
                            value: '${piquete.totalLotes} lotes',
                            iconAsset: kPiqueteLoteIconAsset,
                            iconColor: kPiquetePrimary,
                          ),
                        ),
                        Expanded(
                          child: _PiqueteDetailCell(
                            label: 'SITUAÇÃO',
                            value: occupied ? 'Ocupado' : 'Livre',
                            icon: Icons.circle,
                            iconColor: occupied
                                ? const Color(0xFFE39F22)
                                : const Color(0xFFB8C1BA),
                            valueColor: occupied
                                ? const Color(0xFF8A5A00)
                                : kPiqueteTextMuted,
                            iconSurface: occupied
                                ? const Color(0xFFFFE5B5)
                                : kPiqueteFieldSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PiqueteDetailCell extends StatelessWidget {
  const _PiqueteDetailCell({
    required this.label,
    required this.value,
    required this.iconColor,
    this.icon,
    this.iconAsset,
    this.valueColor,
    this.iconSurface,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? iconAsset;
  final Color iconColor;
  final Color? valueColor;
  final Color? iconSurface;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: kPiqueteBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconSurface ?? kPiquetePrimarySurface,
              borderRadius: BorderRadius.circular(kPiqueteRadius),
            ),
            child: iconAsset == null
                ? Icon(icon, color: iconColor, size: 16)
                : Center(
                    child: iconAsset == kPiqueteCowIconAsset
                        ? Image.asset(
                            iconAsset!,
                            width: piqueteAssetIconSize(iconAsset, 18),
                            height: piqueteAssetIconSize(iconAsset, 18),
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            kPiqueteMenuIcon,
                            color: iconColor,
                            size: 16,
                          ),
                  ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: kPiqueteTextSoft,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: valueColor ?? kPiqueteTextStrong,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaPreviewBox extends StatelessWidget {
  const _AreaPreviewBox({
    required this.points,
    required this.color,
    required this.size,
    this.fallbackAreas = const [],
  });

  final List<MapPoint> points;
  final List<List<MapPoint>> fallbackAreas;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(kPiqueteRadius),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: CustomPaint(
          painter: _AreaPreviewPainter(
            points: points,
            fallbackAreas: fallbackAreas,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _AreaPreviewPainter extends CustomPainter {
  const _AreaPreviewPainter({
    required this.points,
    required this.fallbackAreas,
    required this.color,
  });

  final List<MapPoint> points;
  final List<List<MapPoint>> fallbackAreas;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final areas = points.length >= 3
        ? [points]
        : fallbackAreas.where((area) => area.length >= 3).toList();
    if (areas.isEmpty) {
      final paint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final center = Offset(size.width / 2, size.height / 2);
      canvas.drawCircle(
          center, math.min(size.width, size.height) * 0.22, paint);
      return;
    }

    final allPoints = areas.expand((area) => area).toList();
    final minLat = allPoints.map((point) => point.latitude).reduce(math.min);
    final maxLat = allPoints.map((point) => point.latitude).reduce(math.max);
    final minLng = allPoints.map((point) => point.longitude).reduce(math.min);
    final maxLng = allPoints.map((point) => point.longitude).reduce(math.max);
    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();
    if (latSpan == 0 || lngSpan == 0) return;

    final normalizedAreas = areas
        .map((area) => area.map((point) {
              final x = ((point.longitude - minLng) / lngSpan) * size.width;
              final y = size.height -
                  ((point.latitude - minLat) / latSpan) * size.height;
              return Offset(x, y);
            }).toList())
        .toList();

    final allOffsets = normalizedAreas.expand((area) => area).toList();
    final bounds = _boundsFor(allOffsets);
    final scale = math.min(
          bounds.width == 0 ? 1.0 : size.width / bounds.width,
          bounds.height == 0 ? 1.0 : size.height / bounds.height,
        ) *
        0.82;
    final dx = (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final dy = (size.height - bounds.height * scale) / 2 - bounds.top * scale;
    for (final normalized in normalizedAreas) {
      final path = Path();
      for (var i = 0; i < normalized.length; i++) {
        final point = normalized[i];
        final offset = Offset(point.dx * scale + dx, point.dy * scale + dy);
        if (i == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.20)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  Rect _boundsFor(List<Offset> offsets) {
    final left = offsets.map((offset) => offset.dx).reduce(math.min);
    final right = offsets.map((offset) => offset.dx).reduce(math.max);
    final top = offsets.map((offset) => offset.dy).reduce(math.min);
    final bottom = offsets.map((offset) => offset.dy).reduce(math.max);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  bool shouldRepaint(covariant _AreaPreviewPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.fallbackAreas != fallbackAreas ||
        oldDelegate.color != color;
  }
}

class _PiqueteSegmentedTabs extends StatelessWidget {
  const _PiqueteSegmentedTabs({
    required this.showingSemRetiro,
    required this.retiroCount,
    required this.semRetiroCount,
    required this.onRetirosTap,
    required this.onSemRetiroTap,
  });

  final bool showingSemRetiro;
  final int retiroCount;
  final int semRetiroCount;
  final VoidCallback onRetirosTap;
  final VoidCallback onSemRetiroTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F0),
        borderRadius: BorderRadius.circular(kPiqueteRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PiqueteSegmentButton(
              label: 'Por retiro',
              count: retiroCount,
              selected: !showingSemRetiro,
              onTap: onRetirosTap,
            ),
          ),
          Expanded(
            child: _PiqueteSegmentButton(
              label: 'Sem retiro',
              count: semRetiroCount,
              selected: showingSemRetiro,
              onTap: onSemRetiroTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _PiqueteSegmentButton extends StatelessWidget {
  const _PiqueteSegmentButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kPiqueteRadius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPiquetePrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(kPiqueteRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : kPiqueteTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.26)
                    : const Color(0xFFDDE4DE),
                borderRadius: BorderRadius.circular(kPiqueteRadius),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : kPiqueteTextMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PiqueteMapContentToggle extends StatelessWidget {
  const _PiqueteMapContentToggle({
    required this.mode,
    required this.lotesCount,
    required this.animaisSemLoteCount,
    required this.onChanged,
  });

  final String mode;
  final int lotesCount;
  final int animaisSemLoteCount;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F0),
        borderRadius: BorderRadius.circular(kPiqueteRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PiqueteMapToggleButton(
            label: 'Lotes',
            count: lotesCount,
            selected: mode == 'lotes',
            onTap: () => onChanged('lotes'),
          ),
          _PiqueteMapToggleButton(
            label: 'Animais sem lote',
            count: animaisSemLoteCount,
            selected: mode == 'animais',
            onTap: () => onChanged('animais'),
          ),
        ],
      ),
    );
  }
}

class _PiqueteMapToggleButton extends StatelessWidget {
  const _PiqueteMapToggleButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kPiqueteRadius),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kPiquetePrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(kPiqueteRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : kPiqueteTextMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.26)
                    : const Color(0xFFDDE4DE),
                borderRadius: BorderRadius.circular(kPiqueteRadius),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  color: selected ? Colors.white : kPiqueteTextMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrototypeTextField extends StatelessWidget {
  const _PrototypeTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
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
              borderRadius: BorderRadius.circular(kPiqueteRadius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
