import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_view_piquete_model.dart';
export 'pg_view_piquete_model.dart';

class PgViewPiqueteWidget extends StatefulWidget {
  const PgViewPiqueteWidget({
    super.key,
    required this.idPiquete,
    required this.piqueteNome,
  });

  final String? idPiquete;
  final String? piqueteNome;

  static String routeName = 'pgViewPiquete';
  static String routePath = '/viewpiquete';

  @override
  State<PgViewPiqueteWidget> createState() => _PgViewPiqueteWidgetState();
}

class _PgViewPiqueteWidgetState extends State<PgViewPiqueteWidget> {
  late PgViewPiqueteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Lotes carregados e filtrados
  List<LotesRow> _todosLotes = [];
  bool _loadingLotes = false;

  // Expansão inline: lote expandido e animais carregados
  String? _expandedLoteId;
  List<RebanhoRow> _animaisDoLote = [];
  bool _loadingAnimais = false;

  // Animais diretamente no piquete (view "com animal")
  List<RebanhoRow> _animaisPiquete = [];
  bool _loadingAnimaisPiquete = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgViewPiqueteModel());
    _model.pesquisaController ??= TextEditingController();
    _model.pesquisaFocusNode ??= FocusNode();
    _model.animalPesquisaController ??= TextEditingController();
    _model.animalPesquisaFocusNode ??= FocusNode();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.piqueteRows = await PiqueteTable().queryRows(
        queryFn: (q) => q.eqOrNull('id_piquete', widget.idPiquete),
      );
      safeSetState(() {});
      _carregarLotes();
      _carregarAnimaisPiquete();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  Future<void> _carregarLotes() async {
    final piquete = _model.piqueteRows.firstOrNull;
    if (piquete == null || piquete.idLotes.isEmpty) return;

    safeSetState(() => _loadingLotes = true);
    final lotes = await LotesTable().queryRows(
      queryFn: (q) => q
          .inFilterOrNull('id_lote', piquete.idLotes)
          .neqOrNull('deletado', 'SIM'),
    );
    safeSetState(() {
      _todosLotes = lotes;
      _loadingLotes = false;
    });
  }

  Future<void> _carregarAnimaisPiquete() async {
    final piquete = _model.piqueteRows.firstOrNull;
    if (piquete == null || piquete.idRebanhos.isEmpty) return;

    safeSetState(() => _loadingAnimaisPiquete = true);
    final animais = await RebanhoTable().queryRows(
      queryFn: (q) => q
          .inFilterOrNull('idRebanho', piquete.idRebanhos)
          .eqOrNull('deletado', 'NAO'),
    );
    safeSetState(() {
      _animaisPiquete = animais;
      _loadingAnimaisPiquete = false;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ── Lotes filtering/pagination ──
  List<LotesRow> get _lotesFiltrados {
    final q = _model.pesquisaController?.text.toLowerCase() ?? '';
    if (q.isEmpty) return _todosLotes;
    return _todosLotes
        .where((l) => (l.nome ?? '').toLowerCase().contains(q))
        .toList();
  }

  List<LotesRow> get _lotesPagina {
    final filtered = _lotesFiltrados;
    final start = (_model.pageNum - 1) * PgViewPiqueteModel.pageSize;
    final end =
        (start + PgViewPiqueteModel.pageSize).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int get _totalPaginas =>
      (_lotesFiltrados.length / PgViewPiqueteModel.pageSize).ceil().clamp(1, 999);

  // ── Animais filtering/pagination ──
  List<RebanhoRow> get _animaisFiltrados {
    final q = _model.animalPesquisaController?.text.toLowerCase() ?? '';
    if (q.isEmpty) return _animaisPiquete;
    return _animaisPiquete.where((a) {
      final nome = (a.nome ?? '').toLowerCase();
      final numero = (a.numeroAnimal ?? '').toLowerCase();
      return nome.contains(q) || numero.contains(q);
    }).toList();
  }

  List<RebanhoRow> get _animaisPagina {
    final filtered = _animaisFiltrados;
    final start =
        (_model.animalPageNum - 1) * PgViewPiqueteModel.pageSize;
    final end =
        (start + PgViewPiqueteModel.pageSize).clamp(0, filtered.length);
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end);
  }

  int get _totalPaginasAnimais =>
      (_animaisFiltrados.length / PgViewPiqueteModel.pageSize)
          .ceil()
          .clamp(1, 999);

  Map<String, int> get _contagemPorCategoria {
    final map = <String, int>{};
    for (final a in _animaisPiquete) {
      final cat = a.categoria ?? 'Sem categoria';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final piquete = _model.piqueteRows.firstOrNull;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              wrapWithModel(
                model: _model.headerModel,
                updateCallback: () => safeSetState(() {}),
                child: const HeaderWidget(),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wrapWithModel(
                        model: _model.sideBarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const SideBarWidget(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 34.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Título ──────────────────────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      FlutterFlowIconButton(
                                        borderRadius: 8.0,
                                        buttonSize: 40.0,
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 24.0,
                                        ),
                                        onPressed: () => context.safePop(),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Piquete',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF8E8E8E),
                                            ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              widget.piqueteNome,
                                              'Piquete',
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: 40.0,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF181818),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32.0),

                              // ── Campos de detalhe ─────────────────────
                              if (piquete != null) ...[
                                _buildReadField(
                                    context, 'Nome', piquete.nome ?? '-'),
                                const SizedBox(height: 32.0),
                                _buildReadField(
                                  context,
                                  'Área (ha)',
                                  piquete.area != null
                                      ? piquete.area!.toStringAsFixed(2)
                                      : '-',
                                ),
                                const SizedBox(height: 32.0),
                                _buildReadField(
                                  context,
                                  'Forrageira',
                                  piquete.forrageria.isNotEmpty
                                      ? piquete.forrageria.join(', ')
                                      : '-',
                                ),
                                const SizedBox(height: 32.0),
                                _buildReadField(
                                  context,
                                  'Anotações',
                                  piquete.anotacoes?.isNotEmpty == true
                                      ? piquete.anotacoes!
                                      : '',
                                  minHeight: 88.0,
                                  alignTop: true,
                                ),
                                const SizedBox(height: 32.0),

                                // ── Card de lotes (só quando tipo = Lote) ──
                                if (piquete.idLotes.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFFEDEDED)),
                                    borderRadius: BorderRadius.circular(6.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x40000000),
                                        blurRadius: 4.0,
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Cabeçalho do card
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Lotes neste piquete (${_todosLotes.length})',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF181818),
                                                ),
                                              ),
                                            ),
                                            // Search bar
                                            SizedBox(
                                              width: 314.0,
                                              height: 56.0,
                                              child: TextField(
                                                controller:
                                                    _model.pesquisaController,
                                                focusNode:
                                                    _model.pesquisaFocusNode,
                                                onChanged: (_) =>
                                                    safeSetState(() {
                                                  _model.pageNum = 1;
                                                }),
                                                decoration: InputDecoration(
                                                  hintText: 'Pesquisar',
                                                  hintStyle: GoogleFonts.poppins(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                        0xFF8E8E8E),
                                                  ),
                                                  prefixIcon: const Icon(
                                                    Icons.search,
                                                    size: 24.0,
                                                    color: Color(0xFF8E8E8E),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xFFF1F1F1),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16.0,
                                                          horizontal: 24.0),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                    borderSide:
                                                        BorderSide.none,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                    borderSide:
                                                        BorderSide.none,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                    borderSide:
                                                        BorderSide.none,
                                                  ),
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF181818),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            // Filtrar button
                                            Container(
                                              height: 56.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFF1E7A4C)),
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                              child: TextButton.icon(
                                                onPressed: () {},
                                                icon: const FaIcon(
                                                  FontAwesomeIcons.sliders,
                                                  size: 16.0,
                                                  color: Color(0xFF1E7A4C),
                                                ),
                                                label: Text(
                                                  'Filtrar',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                        0xFF1E7A4C),
                                                  ),
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 24.0,
                                                          vertical: 12.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Cabeçalho das colunas
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0, vertical: 10.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: _buildColHeader(
                                                  context, 'Nome'),
                                            ),
                                            Expanded(
                                              child: _buildColHeader(
                                                  context, 'Data início'),
                                            ),
                                            Expanded(
                                              child: _buildColHeader(
                                                  context, 'Data fim'),
                                            ),
                                            const SizedBox(width: 20.0),
                                          ],
                                        ),
                                      ),

                                      // Linhas da tabela
                                      if (_loadingLotes)
                                        const Padding(
                                          padding: EdgeInsets.all(32.0),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else if (_lotesFiltrados.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(32.0),
                                          child: Center(
                                            child: Text(
                                              'Nenhum lote neste piquete.',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.0,
                                                color: const Color(0xFF8E8E8E),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Column(
                                          children: List.generate(
                                            _lotesPagina.length,
                                            (index) {
                                              final lote = _lotesPagina[index];
                                              final isEven = index % 2 != 0;
                                              return _buildLoteRow(
                                                  context, lote, isEven);
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (piquete.idLotes.isNotEmpty)
                                  const SizedBox(height: 16.0),

                                // ── Paginação lotes ──────────────────────
                                if (piquete.idLotes.isNotEmpty && _totalPaginas > 1)
                                  Center(
                                    child: _buildPaginacao(context),
                                  ),

                                // ── Seção animais (view "com animal") ────
                                if (piquete.idRebanhos.isNotEmpty) ...[
                                  const SizedBox(height: 32.0),
                                  _buildCategoriaCard(context),
                                  const SizedBox(height: 32.0),
                                  _buildAnimaisTableCard(context),
                                  const SizedBox(height: 16.0),
                                  if (_totalPaginasAnimais > 1)
                                    Center(
                                      child: _buildAnimaisPaginacao(context),
                                    ),
                                ],
                              ],

                              const SizedBox(height: 24.0),

                              // ── Botões ────────────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Voltar
                                  Container(
                                    height: 56.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color(0xFF1E7A4C)),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: TextButton(
                                      onPressed: () => context.safePop(),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                      ),
                                      child: Text(
                                        'Voltar',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E7A4C),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24.0),
                                  // Editar
                                  SizedBox(
                                    height: 56.0,
                                    child: FFButtonWidget(
                                      onPressed: () {
                                        context.pushNamed(
                                          PgEditPiqueteWidget.routeName,
                                          queryParameters: {
                                            'idPiquete': serializeParam(
                                              widget.idPiquete,
                                              ParamType.String,
                                            ),
                                            'piqueteNome': serializeParam(
                                              widget.piqueteNome,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      text: 'Editar',
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 20.0,
                                        color: Colors.white,
                                      ),
                                      options: FFButtonOptions(
                                        height: 56.0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        color: const Color(0xFF28A365),
                                        textStyle: GoogleFonts.poppins(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(6.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Campo de leitura ─────────────────────────────────────────────────────

  Widget _buildReadField(
    BuildContext context,
    String label,
    String value, {
    double minHeight = 56.0,
    bool alignTop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFBEBEBE),
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight),
          padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(6.0),
          ),
          alignment: alignTop ? Alignment.topLeft : Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF181818),
            ),
          ),
        ),
      ],
    );
  }

  // ── Cabeçalho de coluna ──────────────────────────────────────────────────

  Widget _buildColHeader(BuildContext context, String label) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF474747),
            letterSpacing: 0.12,
          ),
        ),
        const SizedBox(width: 5.0),
        const Icon(
          Icons.unfold_more,
          size: 16.0,
          color: Color(0xFF474747),
        ),
      ],
    );
  }

  // ── Toggle expand lote ──────────────────────────────────────────────────

  Future<void> _toggleExpandLote(LotesRow lote) async {
    if (_expandedLoteId == lote.idLote) {
      // Fechar
      safeSetState(() {
        _expandedLoteId = null;
        _animaisDoLote = [];
      });
      return;
    }

    safeSetState(() {
      _expandedLoteId = lote.idLote;
      _animaisDoLote = [];
      _loadingAnimais = true;
    });

    // Buscar animais do lote via id_animais do lote OU via loteID do rebanho
    final piquete = _model.piqueteRows.firstOrNull;
    List<RebanhoRow> animais = [];

    // Animais que estão no lote E no piquete (intersecção)
    if (piquete != null && piquete.idRebanhos.isNotEmpty) {
      animais = await RebanhoTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('loteID', lote.idLote)
            .inFilterOrNull('idRebanho', piquete.idRebanhos)
            .eqOrNull('deletado', 'NAO'),
      );
    }

    // Fallback: todos animais do lote
    if (animais.isEmpty) {
      animais = await RebanhoTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('loteID', lote.idLote)
            .eqOrNull('deletado', 'NAO'),
      );
    }

    safeSetState(() {
      _animaisDoLote = animais;
      _loadingAnimais = false;
    });
  }

  // ── Linha de lote ────────────────────────────────────────────────────────

  Widget _buildLoteRow(BuildContext context, LotesRow lote, bool isEven) {
    final isExpanded = _expandedLoteId == lote.idLote;

    return Container(
      color: isEven ? const Color(0xFFF8F8F8) : Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                // Nome + Ver animais
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        valueOrDefault<String>(lote.nome, '-'),
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF474747),
                          height: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _toggleExpandLote(lote),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ver animais',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E7A4C),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 18.0,
                                color: const Color(0xFF1E7A4C),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Data início
                Expanded(
                  child: Text(
                    lote.dataEntradaPiquete != null
                        ? dateTimeFormat(
                            'dd/MM/yyyy',
                            lote.dataEntradaPiquete,
                            locale:
                                FFLocalizations.of(context).languageCode,
                          )
                        : '-',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                      height: 1.5,
                    ),
                  ),
                ),
                // Data fim + menu
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lote.dataSaidaPiquete != null
                              ? dateTimeFormat(
                                  'dd/MM/yyyy',
                                  lote.dataSaidaPiquete,
                                  locale: FFLocalizations.of(context)
                                      .languageCode,
                                )
                              : '-',
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF474747),
                            height: 1.5,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 20.0,
                          color: Color(0xFF474747),
                        ),
                        onSelected: (value) {
                          if (value == 'ver') {
                            context.pushNamed(
                              PgViewLoteWidget.routeName,
                              queryParameters: {
                                'idLote': serializeParam(
                                  lote.idLote,
                                  ParamType.String,
                                ),
                                'loteNome': serializeParam(
                                  lote.nome,
                                  ParamType.String,
                                ),
                              }.withoutNulls,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'ver',
                            child: Text(
                              'Ver lote',
                              style: GoogleFonts.poppins(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Card expandido: Animais neste lote ──
          if (isExpanded)
            _buildAnimaisCard(context, lote),
          const Divider(height: 1.0, color: Color(0xFFEDEDED)),
        ],
      ),
    );
  }

  // ── Card "Animais neste lote" ──────────────────────────────────────────

  Widget _buildAnimaisCard(BuildContext context, LotesRow lote) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEDEDED)),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animais neste lote (${_animaisDoLote.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF181818),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    GestureDetector(
                      onTap: () {
                        // Ver histórico - futura implementação
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 16.0,
                            color: Color(0xFF1E7A4C),
                          ),
                          const SizedBox(width: 2.0),
                          Text(
                            'Ver histórico',
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E7A4C),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Ver lote
                GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      PgViewLoteWidget.routeName,
                      queryParameters: {
                        'idLote': serializeParam(
                          lote.idLote,
                          ParamType.String,
                        ),
                        'loteNome': serializeParam(
                          lote.nome,
                          ParamType.String,
                        ),
                      }.withoutNulls,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Ver lote',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E7A4C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // Animais
            if (_loadingAnimais)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_animaisDoLote.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum animal neste lote.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: const Color(0xFF8E8E8E),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: _animaisDoLote
                    .map((a) => _buildAnimalItem(context, a, lote))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ── Item de animal ─────────────────────────────────────────────────────

  Widget _buildAnimalItem(
      BuildContext context, RebanhoRow animal, LotesRow lote) {
    final isFemea = animal.sexo?.toLowerCase() != 'macho';
    final sexoColor = isFemea ? const Color(0xFFC429CC) : const Color(0xFF2973CC);
    final sexoIcon = isFemea ? Icons.female : Icons.male;

    final dataEntrada = animal.dataEntradaLote != null
        ? dateTimeFormat('dd/MM/yyyy', animal.dataEntradaLote,
            locale: FFLocalizations.of(context).languageCode)
        : null;

    final dataNasc = animal.dataNascimento != null
        ? dateTimeFormat('dd/MM/yyyy', animal.dataNascimento,
            locale: FFLocalizations.of(context).languageCode)
        : null;

    return SizedBox(
      width: 380.0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEDEDED)),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícones: rebanho + sexo
            Row(
              children: [
                const Icon(
                  Icons.pets,
                  size: 24.0,
                  color: Color(0xFFB1CC29),
                ),
                const SizedBox(width: 2.0),
                Icon(
                  sexoIcon,
                  size: 24.0,
                  color: sexoColor,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Linha 1: número • nome • data nascimento
            Wrap(
              spacing: 4.0,
              children: [
                Text(
                  valueOrDefault<String>(animal.numeroAnimal, '-'),
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF474747),
                  ),
                ),
                Text(
                  '•',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF474747),
                  ),
                ),
                Text(
                  valueOrDefault<String>(animal.nome, '-'),
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF474747),
                  ),
                ),
                if (dataNasc != null) ...[
                  Text(
                    '•',
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                    ),
                  ),
                  Text(
                    dataNasc,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2.0),
            // Linha 2: categoria • raça
            Row(
              children: [
                Text(
                  valueOrDefault<String>(animal.categoria, '-'),
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: const Color(0xFF5F5F5F),
                  ),
                ),
                Text(
                  ' • ',
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF474747),
                  ),
                ),
                Text(
                  valueOrDefault<String>(animal.raca, '-'),
                  style: GoogleFonts.poppins(
                    fontSize: 14.0,
                    color: const Color(0xFF5F5F5F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            // Linha 3: ícone lote + "Lote X (entrou em dd/mm/yyyy)"
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1.0),
                  child: Icon(
                    Icons.workspaces_outlined,
                    size: 17.0,
                    color: Color(0xFF5F5F5F),
                  ),
                ),
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    '${lote.nome ?? '-'}${dataEntrada != null ? ' (entrou em $dataEntrada)' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      color: const Color(0xFF5F5F5F),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Card: Total de animais neste piquete por categoria ──────────────────

  static const _categoriasOrdem = [
    'Vaca multípara',
    'Garrote',
    'Vaca Primípara',
    'Touro',
    'Bezerro',
    'Novilha',
    'Bezerra',
    'Boi Magro',
    'Boi gordo',
    'Rufião',
  ];

  Widget _buildCategoriaCard(BuildContext context) {
    final total = _animaisPiquete.length;
    final contagem = _contagemPorCategoria;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEDEDED)),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total de animais neste piquete por categoria',
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF181818),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 43.0),
          // Categorias em pares (2 por linha)
          for (int i = 0; i < _categoriasOrdem.length; i += 2)
            Padding(
              padding: EdgeInsets.only(
                  bottom: i + 2 < _categoriasOrdem.length ? 24.0 : 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCategoriaBar(
                      _categoriasOrdem[i],
                      contagem[_categoriasOrdem[i]] ?? 0,
                      total,
                    ),
                  ),
                  const SizedBox(width: 32.0),
                  Expanded(
                    child: i + 1 < _categoriasOrdem.length
                        ? _buildCategoriaBar(
                            _categoriasOrdem[i + 1],
                            contagem[_categoriasOrdem[i + 1]] ?? 0,
                            total,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24.0),
          Text(
            'Total: $total animais',
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              color: const Color(0xFF181818),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaBar(String categoria, int count, int total) {
    final pct = total > 0 ? count / total : 0.0;
    final pctStr =
        total > 0 ? '${(pct * 100).round()}% ($count)' : '$count';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoria,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF474747),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      if (pct > 0)
                        Container(
                          height: 8.0,
                          width: constraints.maxWidth * pct,
                          decoration: BoxDecoration(
                            color: const Color(0xFF28A365),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0),
            SizedBox(
              width: 45.0,
              child: Text(
                pctStr,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF474747),
                  height: 1.17,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Card: Animais neste piquete (tabela) ──────────────────────────────

  Widget _buildAnimaisTableCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEDEDED)),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4.0,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho: título + pesquisa + filtrar + histórico
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Animais neste piquete (${_animaisFiltrados.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF181818),
                    ),
                  ),
                ),
                // Search bar
                SizedBox(
                  width: 216.0,
                  height: 56.0,
                  child: TextField(
                    controller: _model.animalPesquisaController,
                    focusNode: _model.animalPesquisaFocusNode,
                    onChanged: (_) => safeSetState(() {
                      _model.animalPageNum = 1;
                    }),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E8E8E),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 24.0,
                        color: Color(0xFF8E8E8E),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF181818),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Filtrar button
                Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFF1E7A4C)),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const FaIcon(
                      FontAwesomeIcons.sliders,
                      size: 16.0,
                      color: Color(0xFF1E7A4C),
                    ),
                    label: Text(
                      'Filtrar',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E7A4C),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Histórico button
                Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFF1E7A4C)),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.history,
                      size: 24.0,
                      color: Color(0xFF1E7A4C),
                    ),
                    label: Text(
                      'Histórico',
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E7A4C),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cabeçalho das colunas
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(child: _buildColHeader(context, 'Número')),
                Expanded(child: _buildColHeader(context, 'Nome')),
                Expanded(child: _buildColHeader(context, 'Sexo')),
                Expanded(child: _buildColHeader(context, 'Nascimento')),
                Expanded(child: _buildColHeader(context, 'Status')),
                Expanded(child: _buildColHeader(context, 'Categoria')),
                Expanded(child: _buildColHeader(context, 'Raça')),
              ],
            ),
          ),

          // Linhas da tabela
          if (_loadingAnimaisPiquete)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_animaisFiltrados.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Nenhum animal neste piquete.',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    color: const Color(0xFF8E8E8E),
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                _animaisPagina.length,
                (index) {
                  final animal = _animaisPagina[index];
                  final isEven = index % 2 != 0;
                  return _buildAnimalTableRow(context, animal, isEven);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimalTableRow(
      BuildContext context, RebanhoRow animal, bool isEven) {
    final isFemea = animal.sexo?.toLowerCase() != 'macho';
    final sexoColor =
        isFemea ? const Color(0xFFC429CC) : const Color(0xFF2973CC);
    final sexoIcon = isFemea ? Icons.female : Icons.male;
    final sexoLabel = isFemea ? 'Fêmea' : 'Macho';

    final dataNasc = animal.dataNascimento != null
        ? dateTimeFormat('dd/MM/yyyy', animal.dataNascimento,
            locale: FFLocalizations.of(context).languageCode)
        : '-';

    return Container(
      color: isEven ? const Color(0xFFF8F8F8) : Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 16.0),
            child: Row(
              children: [
                // Número
                Expanded(
                  child: Text(
                    valueOrDefault<String>(animal.numeroAnimal, '-'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                      height: 1.5,
                    ),
                  ),
                ),
                // Nome
                Expanded(
                  child: Text(
                    valueOrDefault<String>(animal.nome, '-'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                      height: 1.5,
                    ),
                  ),
                ),
                // Sexo (ícone + texto)
                Expanded(
                  child: Row(
                    children: [
                      Icon(sexoIcon, size: 24.0, color: sexoColor),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          sexoLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF474747),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Nascimento
                Expanded(
                  child: Text(
                    dataNasc,
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                      height: 1.5,
                    ),
                  ),
                ),
                // Status
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildStatusBadge(animal.status),
                  ),
                ),
                // Categoria
                Expanded(
                  child: Text(
                    valueOrDefault<String>(animal.categoria, '-'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                      height: 1.5,
                    ),
                  ),
                ),
                // Raça
                Expanded(
                  child: Text(
                    valueOrDefault<String>(animal.raca, '-'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0, color: Color(0xFFEDEDED)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    final label = status ?? '-';

    switch (status?.toLowerCase()) {
      case 'na propriedade':
        bgColor = const Color(0xFFD6F5E5);
        textColor = const Color(0xFF1E7A4C);
        break;
      case 'vendido':
      case 'vendida':
        bgColor = const Color(0xFFF5D7D4);
        textColor = const Color(0xFFCC3729);
        break;
      default:
        bgColor = const Color(0xFFF1F1F1);
        textColor = const Color(0xFF5F5F5F);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          color: textColor,
        ),
      ),
    );
  }

  // ── Paginação animais ─────────────────────────────────────────────────

  Widget _buildAnimaisPaginacao(BuildContext context) {
    final total = _totalPaginasAnimais;
    final current = _model.animalPageNum;

    final pages = <int>[];
    for (int i = 1; i <= total; i++) {
      if (i == 1 || i == total || (i >= current - 1 && i <= current + 1)) {
        pages.add(i);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPagBtn('«', current > 1,
            () => safeSetState(() => _model.animalPageNum = 1)),
        _buildPagBtn('<', current > 1,
            () => safeSetState(() => _model.animalPageNum = current - 1)),
        for (int i = 0; i < pages.length; i++) ...[
          if (i > 0 && pages[i] - pages[i - 1] > 1)
            _buildPagBtn('…', false, null),
          _buildPagBtn(
            '${pages[i]}',
            true,
            () => safeSetState(() => _model.animalPageNum = pages[i]),
            isActive: pages[i] == current,
          ),
        ],
        _buildPagBtn('>', current < total,
            () => safeSetState(() => _model.animalPageNum = current + 1)),
        _buildPagBtn('»', current < total,
            () => safeSetState(() => _model.animalPageNum = total)),
      ],
    );
  }

  // ── Paginação lotes ───────────────────────────────────────────────────

  Widget _buildPaginacao(BuildContext context) {
    final total = _totalPaginas;
    final current = _model.pageNum;

    // Gera lista de páginas visíveis (máx 5 ao redor da atual)
    final pages = <int>[];
    for (int i = 1; i <= total; i++) {
      if (i == 1 || i == total || (i >= current - 1 && i <= current + 1)) {
        pages.add(i);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPagBtn('«', current > 1,
            () => safeSetState(() => _model.pageNum = 1)),
        _buildPagBtn('<', current > 1,
            () => safeSetState(() => _model.pageNum = current - 1)),
        for (int i = 0; i < pages.length; i++) ...[
          if (i > 0 && pages[i] - pages[i - 1] > 1)
            _buildPagBtn('…', false, null),
          _buildPagBtn(
            '${pages[i]}',
            true,
            () => safeSetState(() => _model.pageNum = pages[i]),
            isActive: pages[i] == current,
          ),
        ],
        _buildPagBtn('>', current < total,
            () => safeSetState(() => _model.pageNum = current + 1)),
        _buildPagBtn('»', current < total,
            () => safeSetState(() => _model.pageNum = total)),
      ],
    );
  }

  Widget _buildPagBtn(
    String label,
    bool enabled,
    VoidCallback? onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 56.0,
        constraints: const BoxConstraints(minWidth: 56.0),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEDEDED) : Colors.white,
          border: Border.all(color: const Color(0xFFEDEDED)),
          borderRadius: label == '«'
              ? const BorderRadius.only(
                  topLeft: Radius.circular(6.0),
                  bottomLeft: Radius.circular(6.0))
              : label == '»'
                  ? const BorderRadius.only(
                      topRight: Radius.circular(6.0),
                      bottomRight: Radius.circular(6.0))
                  : BorderRadius.zero,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: isActive
                ? const Color(0xFF5F5F5F)
                : enabled
                    ? const Color(0xFF474747)
                    : const Color(0xFFBEBEBE),
          ),
        ),
      ),
    );
  }
}
