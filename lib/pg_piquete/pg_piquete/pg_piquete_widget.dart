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
  late PgPiqueteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _store = PiqueteBackendStore.instance;
  late final VoidCallback _disposePiqueteRefresh;

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
              subtitle: 'Limites da propriedade e áreas de pastejo',
              actions: [
                PrototypeSecondaryButton(
                  label: 'Adicionar limites',
                  icon: Icons.map_outlined,
                  onPressed: _showRetiroDialog,
                ),
                PrototypePrimaryButton(
                  label: 'Adicionar piquete',
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      context.pushNamed(PgAddPiqueteWidget.routeName),
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
                  child: PrototypeMetricCard(
                    title: 'Limites cadastrados',
                    value: _store.retiros.length.toString(),
                    icon: Icons.map_rounded,
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
                        'Você pode cadastrar piquetes diretamente ou criar limites da propriedade para agrupar áreas maiores da fazenda.',
                    icon: Icons.crop_square_rounded,
                    action: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        PrototypePrimaryButton(
                          label: 'Adicionar piquete',
                          icon: Icons.add_rounded,
                          onPressed: () =>
                              context.pushNamed(PgAddPiqueteWidget.routeName),
                        ),
                        PrototypeSecondaryButton(
                          label: 'Criar limites',
                          icon: Icons.add_location_alt_outlined,
                          onPressed: _showRetiroDialog,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_store.retiros.isEmpty)
              _buildPiquetesSemRetiroDetail(context)
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 1050;
                  final retiros = _buildRetirosPanel(context);
                  final detail = retiro == null
                      ? _buildPiquetesSemRetiroDetail(context)
                      : _buildRetiroDetail(context, retiro);
                  if (narrow) {
                    return Column(
                      children: [
                        retiros,
                        const SizedBox(height: 20),
                        detail,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 330, child: retiros),
                      const SizedBox(width: 24),
                      Expanded(child: detail),
                    ],
                  );
                },
              ),
          ],
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
            'Limites da propriedade',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Selecione os limites ou veja os piquetes sem vínculo.',
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
              onTap: _store.selectPiquetesSemRetiro,
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
                            'Sem limites',
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
                      'Piquetes sem vínculo com limites',
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
                onTap: () => _store.selectRetiro(retiro.id),
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

  Widget _buildRetiroDetail(BuildContext context, RetiroPrototype retiro) {
    final theme = FlutterFlowTheme.of(context);
    final piquetesDoRetiro = _store.piquetesDoRetiro(retiro.id);
    final piquetes = _piquetesFiltrados;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrototypePrimaryButton(
              label: 'Editar limites',
              icon: Icons.edit_location_alt_outlined,
              onPressed: () => _showRetiroDialog(initial: retiro),
            ),
          ],
        ),
        const SizedBox(height: 14),
        MapaDemarcacaoRealWidget(
          title: retiro.nome,
          points: const [],
          retiroPoints: retiro.pontos,
          piqueteAreas: piquetesDoRetiro
              .where((piquete) => piquete.pontos.length > 1)
              .map(
                (piquete) => PiqueteMapArea(
                  name: piquete.nome,
                  points: piquete.pontos,
                ),
              )
              .toList(),
          retiroAsPrimary: true,
          height: 560,
        ),
        const SizedBox(height: 22),
        _buildRetiroSummary(context, retiro, piquetesDoRetiro),
        const SizedBox(height: 22),
        PrototypeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Piquetes nestes limites',
                          style: GoogleFonts.poppins(
                            color: theme.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${piquetes.length} piquetes encontrados em ${retiro.nome}',
                          style: GoogleFonts.poppins(
                            color: theme.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrototypeSearchField(
                    controller: _model.textController!,
                    hint: 'Pesquisar piquete',
                    onChanged: (_) => safeSetState(() {}),
                  ),
                ].divide(const SizedBox(width: 16)),
              ),
              const SizedBox(height: 20),
              if (piquetes.isEmpty)
                PrototypeEmptyState(
                  title: 'Nenhum piquete nestes limites',
                  message:
                      'Adicione um piquete dentro dos limites selecionados para validar a ocupação por animais ou lotes.',
                  icon: Icons.crop_square_rounded,
                  action: PrototypePrimaryButton(
                    label: 'Adicionar piquete',
                    onPressed: () =>
                        context.pushNamed(PgAddPiqueteWidget.routeName),
                  ),
                )
              else
                _buildPiqueteTable(context, piquetes),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPiquetesSemRetiroDetail(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final piquetesSemRetiro = _store.piquetesSemRetiro;
    final piquetes = _piquetesFiltrados;

    return Column(
      children: [
        MapaDemarcacaoRealWidget(
          title: 'Piquetes sem limites',
          points: const [],
          piqueteAreas: piquetesSemRetiro
              .where((piquete) => piquete.pontos.length > 1)
              .map(
                (piquete) => PiqueteMapArea(
                  name: piquete.nome,
                  points: piquete.pontos,
                ),
              )
              .toList(),
          height: 560,
        ),
        const SizedBox(height: 22),
        _buildPiquetesSemRetiroSummary(context, piquetesSemRetiro),
        const SizedBox(height: 22),
        PrototypeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Piquetes sem limites',
                          style: GoogleFonts.poppins(
                            color: theme.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${piquetes.length} piquetes encontrados sem vínculo com limites',
                          style: GoogleFonts.poppins(
                            color: theme.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrototypeSearchField(
                    controller: _model.textController!,
                    hint: 'Pesquisar piquete',
                    onChanged: (_) => safeSetState(() {}),
                  ),
                ].divide(const SizedBox(width: 16)),
              ),
              const SizedBox(height: 20),
              if (piquetes.isEmpty)
                PrototypeEmptyState(
                  title: 'Nenhum piquete sem limites',
                  message:
                      'Adicione um piquete avulso para propriedades que não utilizam limites agrupadores.',
                  icon: Icons.crop_square_rounded,
                  action: PrototypePrimaryButton(
                    label: 'Adicionar piquete',
                    onPressed: () =>
                        context.pushNamed(PgAddPiqueteWidget.routeName),
                  ),
                )
              else
                _buildPiqueteTable(context, piquetes),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPiquetesSemRetiroSummary(
    BuildContext context,
    List<PiquetePrototype> piquetes,
  ) {
    final theme = FlutterFlowTheme.of(context);
    final areaTotal =
        piquetes.fold<double>(0, (total, piquete) => total + piquete.areaHa);
    final animaisIndividuais =
        piquetes.fold<int>(0, (total, p) => total + p.totalAnimaisIndividuais);
    final animaisEmLotes =
        piquetes.fold<int>(0, (total, p) => total + p.animaisLotesCount);
    final forrageiras = piquetes
        .expand((piquete) => piquete.forrageiras)
        .map((forrageira) => forrageira.trim())
        .where((forrageira) => forrageira.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo dos piquetes sem limites',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final tiles = [
                _RetiroSummaryTile(
                  icon: Icons.crop_square_rounded,
                  label: 'Área total',
                  value: '${areaTotal.toStringAsFixed(0)} ha',
                  helper: '${piquetes.length} piquetes avulsos',
                ),
                _RetiroSummaryTile(
                  iconAsset: kPiqueteCowIconAsset,
                  label: 'Animais',
                  value: (animaisIndividuais + animaisEmLotes).toString(),
                  helper:
                      '$animaisIndividuais individuais + $animaisEmLotes via lotes',
                ),
                _RetiroSummaryTile(
                  icon: Icons.grass_outlined,
                  label: 'Forrageiras',
                  value:
                      forrageiras.isEmpty ? '0' : forrageiras.length.toString(),
                  helper: forrageiras.isEmpty
                      ? 'Nenhuma forrageira cadastrada'
                      : forrageiras.join(', '),
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
        ],
      ),
    );
  }

  Widget _buildRetiroSummary(
    BuildContext context,
    RetiroPrototype retiro,
    List<PiquetePrototype> piquetes,
  ) {
    final theme = FlutterFlowTheme.of(context);
    final animaisIndividuais =
        piquetes.fold<int>(0, (total, p) => total + p.totalAnimaisIndividuais);
    final animaisEmLotes =
        piquetes.fold<int>(0, (total, p) => total + p.animaisLotesCount);
    final totalAnimais = piquetes.isEmpty
        ? retiro.animaisCount
        : animaisIndividuais + animaisEmLotes;
    final forrageirasFonte = piquetes.isEmpty
        ? retiro.forrageiras
        : piquetes.expand((piquete) => piquete.forrageiras);
    final forrageiras = forrageirasFonte
        .map((forrageira) => forrageira.trim())
        .where((forrageira) => forrageira.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo dos limites da propriedade',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final tiles = [
                _RetiroSummaryTile(
                  icon: Icons.map_outlined,
                  label: 'Área total',
                  value: '${retiro.areaHa.toStringAsFixed(0)} ha',
                  helper: '${piquetes.length} piquetes nestes limites',
                ),
                _RetiroSummaryTile(
                  iconAsset: kPiqueteCowIconAsset,
                  label: 'Animais',
                  value: totalAnimais.toString(),
                  helper:
                      '$animaisIndividuais individuais + $animaisEmLotes via lotes',
                ),
                _RetiroSummaryTile(
                  icon: Icons.grass_outlined,
                  label: 'Forrageiras',
                  value:
                      forrageiras.isEmpty ? '0' : forrageiras.length.toString(),
                  helper: forrageiras.isEmpty
                      ? 'Nenhuma forrageira cadastrada'
                      : forrageiras.join(', '),
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
          if (forrageiras.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: forrageiras
                  .map(
                    (forrageira) => PrototypeBadge(
                      label: forrageira,
                      icon: Icons.grass_outlined,
                      color: theme.secondary,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPiqueteTable(
    BuildContext context,
    List<PiquetePrototype> piquetes,
  ) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          color: theme.customColor11,
          child: const Row(
            children: [
              Expanded(flex: 3, child: _HeaderCell('Nome')),
              Expanded(child: _HeaderCell('Área')),
              Expanded(flex: 2, child: _HeaderCell('Forrageira')),
              Expanded(flex: 2, child: _HeaderCell('Conteúdo')),
              SizedBox(width: 158),
            ],
          ),
        ),
        ...piquetes.map((piquete) {
          final animais = piquete.totalAnimaisIndividuais;
          final lotes = piquete.totalLotes;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.customColor5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    piquete.nome,
                    style: GoogleFonts.poppins(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                    child: Text('${piquete.areaHa.toStringAsFixed(0)} ha')),
                Expanded(flex: 2, child: Text(piquete.forrageira)),
                Expanded(
                  flex: 2,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (animais > 0)
                        PrototypeBadge(
                          label: '$animais animais',
                          iconAsset: kPiqueteCowIconAsset,
                        ),
                      if (lotes > 0)
                        PrototypeBadge(
                          label: '$lotes lotes',
                          icon: Icons.bubble_chart_outlined,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 158,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 8,
                        buttonSize: 40,
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          color: theme.primaryText,
                          size: 22,
                        ),
                        onPressed: () => context.pushNamed(
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
                        ),
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 8,
                        buttonSize: 40,
                        icon: Icon(
                          Icons.edit_outlined,
                          color: theme.secondary,
                          size: 22,
                        ),
                        onPressed: () => context.pushNamed(
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
                        ),
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 8,
                        buttonSize: 40,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: theme.error,
                          size: 22,
                        ),
                        onPressed: () => _showDeleteDialog(piquete),
                      ),
                    ],
                  ),
                ),
              ].divide(const SizedBox(width: 12)),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showRetiroDialog({RetiroPrototype? initial}) async {
    final editing = initial != null;
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
                          title: editing
                              ? 'Editar limites da propriedade'
                              : 'Criar limites da propriedade',
                          subtitle: editing
                              ? 'Ajuste dados e demarcação dos limites'
                              : 'Demarque a área principal da fazenda',
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
                                    label: 'Nome dos limites',
                                    hint: 'Ex.: Limites Sede',
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
                              title: 'Área dos limites',
                              points: pontos,
                              editable: true,
                              height: mapHeight,
                              preferUserLocation: true,
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PrototypeSecondaryButton(
                              label: 'Cancelar',
                              onPressed: () => Navigator.pop(dialogContext),
                            ),
                            PrototypePrimaryButton(
                              label: editing
                                  ? 'Salvar alterações'
                                  : 'Salvar limites',
                              icon: Icons.check_rounded,
                              onPressed: () {
                                final nome = nomeController.text.trim();
                                final area = double.tryParse(
                                      areaController.text.replaceAll(',', '.'),
                                    ) ??
                                    0;
                                if (nome.isEmpty ||
                                    area <= 0 ||
                                    pontos.length < 3) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Informe nome, área e ao menos 3 pontos no mapa.',
                                      ),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).error,
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _store.errorMessage ??
                                              'Não foi possível salvar os limites da propriedade.',
                                        ),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context).error,
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: FlutterFlowTheme.of(context).secondaryText,
        fontWeight: FontWeight.w700,
        fontSize: 13,
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
