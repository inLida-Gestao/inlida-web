import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/pg_piquete/data/piquete_backend_store.dart';
import '/pg_piquete/prototype/mapa_demarcacao_real_widget.dart';
import '/pg_piquete/prototype/piquete_prototype_store.dart';
import '/pg_piquete/prototype/piquete_prototype_widgets.dart';
import '../modal_excluir_piquete/modal_excluir_piquete_widget.dart';
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
    final piquetes = _piquetesFiltrados;
    if (piquetes.isEmpty) return null;

    final selectedId = _selectedPiqueteId;
    if (selectedId != null && selectedId.isNotEmpty) {
      for (final piquete in piquetes) {
        if (piquete.id == selectedId) return piquete;
      }
    }

    return piquetes.first;
  }

  void _selectPiquete(PiquetePrototype piquete) {
    safeSetState(() => _selectedPiqueteId = piquete.id);
  }

  void _selectPiquetesSemLimites() {
    safeSetState(() => _selectedPiqueteId = null);
    _store.selectPiquetesSemRetiro();
  }

  void _selectLimites(String id) {
    safeSetState(() => _selectedPiqueteId = null);
    _store.selectRetiro(id);
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
    final retiro = _store.selectedRetiro;

    return PiquetePrototypeScaffold(
      scaffoldKey: scaffoldKey,
      headerModel: _model.headerModel,
      sideBarModel: _model.sideBarModel,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(32, 34, 32, 34),
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
            const SizedBox(height: 28),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              children: [
                SizedBox(
                  width: 280,
                  child: _buildLimiteMetricCard(context),
                ),
                SizedBox(
                  width: 280,
                  child: PrototypeMetricCard(
                    title: 'Retiros cadastrados',
                    value: _store.retiros.length.toString(),
                    icon: Icons.account_tree_outlined,
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: PrototypeMetricCard(
                    title: 'Piquetes cadastrados',
                    value: _store.totalPiquetes.toString(),
                    icon: Icons.crop_square_rounded,
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: PrototypeMetricCard(
                    title: 'Animais em piquetes',
                    value: _store.totalAnimaisEmPiquetes.toString(),
                    iconAsset: kPiqueteCowIconAsset,
                  ),
                ),
                SizedBox(
                  width: 280,
                  child: PrototypeMetricCard(
                    title: 'Lotes em piquetes',
                    value: _store.totalLotesEmPiquetes.toString(),
                    icon: Icons.bubble_chart_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
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
            else if (_store.retiros.isEmpty)
              _buildPiqueteWorkspace(context)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 1180;
                  final retiros = _buildRetirosPanel(context);
                  final workspace = retiro == null
                      ? _buildPiqueteWorkspace(context)
                      : _buildPiqueteWorkspace(context, retiro: retiro);
                  if (narrow) {
                    return Column(
                      children: [
                        retiros,
                        const SizedBox(height: 20),
                        workspace,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 330, child: retiros),
                      const SizedBox(width: 24),
                      Expanded(child: workspace),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimiteMetricCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final limite = _store.limitePropriedade;
    return SizedBox(
      height: 116,
      child: PrototypeCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showLimiteDialog(initial: limite),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  limite == null ? Icons.add_location_alt_outlined : Icons.map,
                  color: theme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
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
                        color: theme.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                        color: theme.primaryText,
                        fontSize: limite == null ? 18 : 24,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    if (limite != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${limite.areaDisponivelHa.toStringAsFixed(1)} ha disponíveis',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: theme.secondaryText,
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
                color: theme.secondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetirosPanel(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retiros',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecione um retiro ou veja os piquetes sem retiro.',
            style: GoogleFonts.poppins(
              color: theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _selectPiquetesSemLimites,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _store.mostrandoPiquetesSemRetiro
                      ? theme.primary.withValues(alpha: 0.10)
                      : theme.customColor2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _store.mostrandoPiquetesSemRetiro
                        ? theme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sem retiro',
                            style: GoogleFonts.poppins(
                              color: _store.mostrandoPiquetesSemRetiro
                                  ? theme.secondary
                                  : theme.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        PrototypeBadge(
                          label: '${_store.piquetesSemRetiro.length} piquetes',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Piquetes sem vínculo com retiro',
                      style: GoogleFonts.poppins(
                        color: theme.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ..._store.retiros.map((retiro) {
            final selected = _store.selectedRetiro?.id == retiro.id;
            final count = retiro.piquetesCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _selectLimites(retiro.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.primary.withValues(alpha: 0.10)
                        : theme.customColor2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? theme.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              retiro.nome,
                              style: GoogleFonts.poppins(
                                color: selected
                                    ? theme.secondary
                                    : theme.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          PrototypeBadge(label: '$count piquetes'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${retiro.areaHa.toStringAsFixed(0)} ha demarcados',
                        style: GoogleFonts.poppins(
                          color: theme.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPiqueteWorkspace(
    BuildContext context, {
    RetiroPrototype? retiro,
  }) {
    final piquetesDoContexto = retiro == null
        ? _store.piquetesSemRetiro
        : _store.piquetesDoRetiro(retiro.id);
    final piquetesFiltrados = _piquetesFiltrados;
    final selected = _selectedPiquete;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 920;
        final list = _buildPiqueteCompactList(
          context,
          piquetes: piquetesFiltrados,
          selected: selected,
          retiro: retiro,
        );
        final main = Column(
          children: [
            _buildPiqueteMap(
              context,
              piquetes: piquetesDoContexto,
              selected: selected,
              retiro: retiro,
            ),
            const SizedBox(height: 18),
            _buildPiqueteInlineDetails(
              context,
              selected,
              retiro: retiro,
              piquetesDoContexto: piquetesDoContexto,
            ),
          ],
        );

        if (narrow) {
          return Column(
            children: [
              list,
              const SizedBox(height: 18),
              main,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 310, child: list),
            const SizedBox(width: 18),
            Expanded(child: main),
          ],
        );
      },
    );
  }

  Widget _buildPiqueteMap(
    BuildContext context, {
    required List<PiquetePrototype> piquetes,
    required PiquetePrototype? selected,
    RetiroPrototype? retiro,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final selectedId = selected?.id;
    final areas = <PiqueteMapArea>[
      if (retiro != null && retiro.pontos.length > 1)
        PiqueteMapArea(
          name: 'Retiro ${retiro.nome}',
          points: retiro.pontos,
        ),
      ...piquetes.where((piquete) => piquete.pontos.length > 1).map(
            (piquete) => PiqueteMapArea(
              name: selectedId == piquete.id
                  ? '${piquete.nome} selecionado'
                  : piquete.nome,
              points: piquete.pontos,
            ),
          )
    ];

    return MapaDemarcacaoRealWidget(
      title: retiro?.nome ?? 'Piquetes sem retiro',
      points: const [],
      retiroPoints: _store.limitePropriedade?.pontos ?? const [],
      piqueteAreas: areas,
      retiroAsPrimary: _store.limitePropriedade != null,
      height: 560,
      actions: [
        if (retiro != null)
          OutlinedButton.icon(
            onPressed: () => _openRetiroDialog(initial: retiro),
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: const Text('Editar retiro'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.secondary,
              side: BorderSide(color: theme.secondary),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if (retiro != null)
          OutlinedButton.icon(
            onPressed: () => _deleteRetiro(retiro),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Excluir retiro'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.error,
              side: BorderSide(color: theme.error),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPiqueteCompactList(
    BuildContext context, {
    required List<PiquetePrototype> piquetes,
    required PiquetePrototype? selected,
    RetiroPrototype? retiro,
  }) {
    final theme = FlutterFlowTheme.of(context);
    final title = retiro == null ? 'Piquetes sem retiro' : 'Piquetes';
    final subtitle = retiro == null
        ? '${piquetes.length} piquetes sem vínculo com retiro'
        : '${piquetes.length} piquetes em ${retiro.nome}';

    return PrototypeCard(
      padding: const EdgeInsets.all(18),
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: theme.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          PrototypeSearchField(
            controller: _model.textController!,
            hint: 'Pesquisar piquete',
            onChanged: (_) => safeSetState(() {}),
          ),
          const SizedBox(height: 14),
          if (piquetes.isEmpty)
            PrototypeEmptyState(
              title: retiro == null
                  ? 'Nenhum piquete sem retiro'
                  : 'Nenhum piquete neste retiro',
              message: retiro == null
                  ? 'Adicione um piquete diretamente dentro do limite da propriedade.'
                  : 'Adicione um piquete dentro do retiro selecionado.',
              icon: Icons.crop_square_rounded,
              action: PrototypePrimaryButton(
                label: 'Adicionar piquete',
                onPressed: () =>
                    context.pushNamed(PgAddPiqueteWidget.routeName),
              ),
            )
          else
            Column(
              children: piquetes
                  .map(
                    (piquete) => _PiqueteCompactTile(
                      piquete: piquete,
                      selected: selected?.id == piquete.id,
                      onTap: () => _selectPiquete(piquete),
                    ),
                  )
                  .toList()
                  .divide(const SizedBox(height: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildPiqueteInlineDetails(
    BuildContext context,
    PiquetePrototype? piquete, {
    RetiroPrototype? retiro,
    required List<PiquetePrototype> piquetesDoContexto,
  }) {
    if (piquete == null) {
      return PrototypeCard(
        child: PrototypeEmptyState(
          title: 'Selecione um piquete',
          message:
              'Clique em um item da lista lateral para ver dados, ocupação e ações rápidas.',
          icon: Icons.touch_app_outlined,
          action: PrototypePrimaryButton(
            label: 'Adicionar piquete',
            onPressed: () => context.pushNamed(PgAddPiqueteWidget.routeName),
          ),
        ),
      );
    }

    final theme = FlutterFlowTheme.of(context);
    final totalAnimais =
        piquete.totalAnimaisIndividuais + piquete.animaisLotesCount;
    final ocupado = totalAnimais > 0 || piquete.totalLotes > 0;
    final forrageiras = piquete.forrageiras
        .map((forrageira) => forrageira.trim())
        .where((forrageira) => forrageira.isNotEmpty)
        .toList();

    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      piquete.nome,
                      style: GoogleFonts.poppins(
                        color: theme.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      retiro == null
                          ? 'Piquete sem retiro vinculado'
                          : 'Dentro de ${retiro.nome}',
                      style: GoogleFonts.poppins(
                        color: theme.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 8,
                    buttonSize: 42,
                    icon: Icon(
                      Icons.remove_red_eye_outlined,
                      color: theme.primaryText,
                      size: 22,
                    ),
                    onPressed: () => _openPiqueteView(piquete),
                  ),
                  FlutterFlowIconButton(
                    borderRadius: 8,
                    buttonSize: 42,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.secondary,
                      size: 22,
                    ),
                    onPressed: () => _openPiqueteEdit(piquete),
                  ),
                  FlutterFlowIconButton(
                    borderRadius: 8,
                    buttonSize: 42,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.error,
                      size: 22,
                    ),
                    onPressed: () => _showDeleteDialog(piquete),
                  ),
                ],
              ),
            ].divide(const SizedBox(width: 14)),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 680;
              final tiles = [
                _RetiroSummaryTile(
                  icon: Icons.crop_square_rounded,
                  label: 'Área',
                  value: '${piquete.areaHa.toStringAsFixed(0)} ha',
                  helper: '${piquete.pontos.length} pontos demarcados',
                ),
                _RetiroSummaryTile(
                  iconAsset: kPiqueteCowIconAsset,
                  label: 'Animais',
                  value: totalAnimais.toString(),
                  helper:
                      '${piquete.totalAnimaisIndividuais} individuais + ${piquete.animaisLotesCount} via lotes',
                ),
                _RetiroSummaryTile(
                  icon: Icons.bubble_chart_outlined,
                  label: 'Lotes',
                  value: piquete.totalLotes.toString(),
                  helper: piquete.totalLotes == 1
                      ? '1 lote vinculado'
                      : '${piquete.totalLotes} lotes vinculados',
                ),
              ];

              if (narrow) {
                return Column(
                  children: tiles
                      .map((tile) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: tile,
                          ))
                      .toList(),
                );
              }

              return Row(
                children: tiles
                    .map((tile) => Expanded(child: tile))
                    .toList()
                    .divide(const SizedBox(width: 14)),
              );
            },
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PrototypeBadge(
                label: ocupado ? 'Ocupado' : 'Livre',
                icon: ocupado
                    ? Icons.check_circle_outline_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: ocupado ? theme.secondary : theme.secondaryText,
              ),
              PrototypeBadge(
                label: '${piquetesDoContexto.length} piquetes no contexto',
                icon: Icons.view_sidebar_outlined,
              ),
              ...forrageiras.map(
                (forrageira) => PrototypeBadge(
                  label: forrageira,
                  icon: Icons.grass_outlined,
                  color: theme.secondary,
                ),
              ),
            ],
          ),
          if (piquete.anotacoes.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Anotações',
              style: GoogleFonts.poppins(
                color: theme.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              piquete.anotacoes.trim(),
              style: GoogleFonts.poppins(
                color: theme.secondaryText,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
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
                                    borderRadius: BorderRadius.circular(8),
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
                          title: editing ? 'Editar retiro' : 'Criar retiro',
                          subtitle: existingRetiroAreas.isEmpty
                              ? (editing
                                  ? 'Ajuste dados e demarcação do retiro'
                                  : 'Demarque uma área interna do limite da propriedade')
                              : (editing
                                  ? 'Outros retiros aparecem em roxo para evitar sobreposição'
                                  : 'Retiros já cadastrados aparecem em roxo para evitar sobreposição'),
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
                                    borderRadius: BorderRadius.circular(8),
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

class _PiqueteCompactTile extends StatelessWidget {
  const _PiqueteCompactTile({
    required this.piquete,
    required this.selected,
    required this.onTap,
  });

  final PiquetePrototype piquete;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final totalAnimais =
        piquete.totalAnimaisIndividuais + piquete.animaisLotesCount;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? theme.secondary.withValues(alpha: 0.12)
              : theme.customColor2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.secondary : theme.customColor5,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    piquete.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: selected ? theme.secondary : theme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: selected ? theme.secondary : theme.secondaryText,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PrototypeBadge(
                  label: '${piquete.areaHa.toStringAsFixed(0)} ha',
                  icon: Icons.crop_square_rounded,
                  color: selected ? theme.secondary : null,
                ),
                PrototypeBadge(
                  label: '$totalAnimais animais',
                  iconAsset: kPiqueteCowIconAsset,
                  color: selected ? theme.secondary : null,
                ),
                if (piquete.totalLotes > 0)
                  PrototypeBadge(
                    label: '${piquete.totalLotes} lotes',
                    icon: Icons.bubble_chart_outlined,
                    color: selected ? theme.secondary : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RetiroSummaryTile extends StatelessWidget {
  const _RetiroSummaryTile({
    required this.label,
    required this.value,
    required this.helper,
    this.icon,
    this.iconAsset,
  });

  final IconData? icon;
  final String? iconAsset;
  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.customColor2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.customColor5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconAsset == null
                ? Icon(icon, color: theme.primary, size: 24)
                : Center(
                    child: Image.asset(
                      iconAsset!,
                      width: piqueteAssetIconSize(iconAsset, 24),
                      height: piqueteAssetIconSize(iconAsset, 24),
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: theme.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: theme.primaryText,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  helper,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: theme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
