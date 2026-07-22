import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/pg_rebanho/pp_filtro_rebanho/pp_filtro_rebanho_widget.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/remover_animal_de_lote_anterior.dart'
    show removerAnimalDeLoteAnterior;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_edit_lote_model.dart';
export 'pg_edit_lote_model.dart';

class PgEditLoteWidget extends StatefulWidget {
  const PgEditLoteWidget({
    super.key,
    required this.idLote,
    required this.loteNome,
  });

  final String? idLote;
  final String? loteNome;

  static String routeName = 'pgEditLote';
  static String routePath = '/editlote';

  @override
  State<PgEditLoteWidget> createState() => _PgEditLoteWidgetState();
}

class _PgEditLoteWidgetState extends State<PgEditLoteWidget>
    with TickerProviderStateMixin {
  late PgEditLoteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String _normalizeIdRebanho(String? value) => value?.trim() ?? '';

  bool _rebanhoLoteAtivo(RebanhoRow row) =>
      row.deletado?.trim().toUpperCase() != 'SIM';

  bool _loteIdAusenteOuInvalido(String? value) {
    final normalized = value?.trim().toLowerCase();
    return normalized == null || normalized.isEmpty || normalized == 'null';
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgEditLoteModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.loteEdit = await LotesTable().queryRows(
        queryFn: (q) => q.eqOrNull('id_lote', widget.idLote),
      );
      _model.animaisDentroLote = [];
      _model.animaisSelecionados = [];
      _model.index = 0;
      safeSetState(() {});
      final ativoRaw =
          (_model.loteEdit?.firstOrNull?.ativo ?? '').trim().toLowerCase();
      final isAtivo = ativoRaw == 'ativo' ||
          ativoRaw == 'true' ||
          ativoRaw == '1' ||
          ativoRaw == 'sim';
      _model.ativo = isAtivo;
      _model.switchValue = isAtivo;
      safeSetState(() {});

      // Mesma regra que PgViewLoteWidget._loadAnimaisDoLote: o vínculo do lote
      // vem de rebanho.loteID/loteNome.
      final animaisStructs = await _loadAnimaisDoLoteParaEdicao();
      for (final struct in animaisStructs) {
        _model.addToAnimaisSelecionados(struct);
        _model.addToAnimaisDentroLote(struct);
      }
      safeSetState(() {});

      _model.disposeRefreshListener =
          FFAppState().onRefresh('refreshRebanho', () {
        FFAppState().refreshRebanho = false;
        safeSetState(() => _model.apiRequestCompleter = null);
      });
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.nomeLoteFocusNode ??= FocusNode();

    _model.anotacoesFocusNode ??= FocusNode();

    _model.dataEntradaLoteFocusNode ??= FocusNode();

    _model.pesquisaTextController ??= TextEditingController();
    _model.pesquisaFocusNode ??= FocusNode();

    _model.pesquisaDentroTextController ??= TextEditingController();
    _model.pesquisaDentroFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  /// Alinhado a [PgViewLoteWidget._loadAnimaisDoLote].
  /// Carrega animais pelo vínculo atual. loteNome é fallback só para legado sem loteID.
  Future<List<RebanhoDTStruct>> _loadAnimaisDoLoteParaEdicao() async {
    if (widget.idLote == null || widget.idLote!.isEmpty) return [];
    final lote = _model.loteEdit?.firstOrNull;
    if (lote == null) return [];

    final idPropriedadeLote = lote.idPropriedade;
    if (idPropriedadeLote == null || idPropriedadeLote.isEmpty) return [];

    final idsSeen = <String>{};
    final list = <RebanhoDTStruct>[];

    void addIfNew(RebanhoRow row) {
      final id = _normalizeIdRebanho(row.idRebanho);
      if (id.isNotEmpty && _rebanhoLoteAtivo(row) && idsSeen.add(id)) {
        list.add(_rebanhoRowToStruct(row));
      }
    }

    final byLoteID = await RebanhoTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('loteID', widget.idLote)
          .eqOrNull('idPropriedade', idPropriedadeLote),
      limit: 10000,
    );
    for (final row in byLoteID) {
      addIfNew(row);
    }

    final nomeLote = lote.nome;
    if (nomeLote != null && nomeLote.trim().isNotEmpty) {
      final byLoteNome = await RebanhoTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('loteNome', nomeLote.trim())
            .eqOrNull('idPropriedade', idPropriedadeLote),
        limit: 10000,
      );
      for (final row in byLoteNome) {
        if (_loteIdAusenteOuInvalido(row.loteID)) {
          addIfNew(row);
        }
      }

      final byLoteIDAsName = await RebanhoTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('loteID', nomeLote.trim())
            .eqOrNull('idPropriedade', idPropriedadeLote),
        limit: 10000,
      );
      for (final row in byLoteIDAsName) {
        addIfNew(row);
      }
    }

    return list;
  }

  RebanhoDTStruct _rebanhoRowToStruct(RebanhoRow row) {
    return RebanhoDTStruct(
      id: row.id,
      createdAt: row.createdAt.toString(),
      idPropriedade: row.idPropriedade,
      numeroAnimal: row.numeroAnimal,
      chip: row.chip,
      codRegistro: row.codRegistro,
      nome: row.nome,
      sexo: row.sexo,
      categoria: row.categoria,
      dataNascimento: row.dataNascimento?.toString(),
      pesoNascimento: row.pesoNascimento,
      porte: row.porte,
      raca: row.raca,
      loteID: row.loteID,
      dataEntradaLote: row.dataEntradaLote?.toString(),
      rebanhoIdMatriz: row.rebanhoIdMatriz,
      rebanhoIdReprodutor: row.rebanhoIdReprodutor,
      dataDesmama: row.dataDesmama?.toString(),
      pesoDesmama: row.pesoDesmama,
      pesoAtual: row.pesoAtual,
      status: row.status,
      origem: row.origem,
      anotacoes: row.anotacoes,
      idRebanho: row.idRebanho,
      deletado: row.deletado,
      updatedAt: row.updatedAt?.toString(),
      loteNome: row.loteNome,
      tipo: row.tipo,
      dataAcao: row.dataAcao?.toString(),
      valorCompra: row.valorCompra,
      dataUltimaPesagem: row.dataUltimaPesagem?.toString(),
      nomeConcat: row.nomeConcat,
      dataVenda: row.dataVenda?.toString(),
      valorVenda: row.valorVenda,
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return FutureBuilder<ApiCallResponse>(
      future: (_model.apiRequestCompleter ??= Completer<ApiCallResponse>()
            ..complete(
                FunctionsSupabaseRebanhoGroup.buscarRebanhoFiltrosCall.call(
              pCategoria: FFAppState().filtroCategoria,
              pDataNascimentoDe: dateTimeFormat(
                "yyyy-MM-dd",
                FFAppState().filtroDataNacimentoDe,
              ),
              pDataNascimentoAte: dateTimeFormat(
                "yyyy-MM-dd",
                FFAppState().filtroDataNacimentoAte,
              ),
              pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
              pLoteNome: FFAppState().filtroLoteNome.isNotEmpty
                  ? FFAppState().filtroLoteNome
                  : '',
              pOrigem: FFAppState().filtroOrigem,
              pRaca: FFAppState().filtroRaca,
              pSexo: FFAppState().filtroSexo,
              pStatus: 'Na propriedade',
              pLimite: FFAppConstants.limit,
              pOffset: functions.calcDeslocamento(
                  _model.pageNumAdd, FFAppConstants.limit),
              pPesquisa: _model.pesquisaTextController.text,
            )))
          .future,
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: FlutterFlowTheme.of(context).error,
                    size: 48.0,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Erro ao carregar dados',
                    style: FlutterFlowTheme.of(context).titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Verifique sua conexão e tente novamente.',
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () =>
                        safeSetState(() => _model.apiRequestCompleter = null),
                    icon: const Icon(Icons.refresh_rounded, size: 18.0),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }
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
                    child: FutureBuilder<List<LotesRow>>(
                      future: LotesTable().querySingleRow(
                        queryFn: (q) => q.eqOrNull('id_lote', widget.idLote),
                      ),
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
                        if (!snapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                          );
                        }
                        List<LotesRow> containerLotesRowList = snapshot.data!;

                        final containerLotesRow =
                            containerLotesRowList.isNotEmpty
                                ? containerLotesRowList.first
                                : null;

                        return Container(
                          width: double.infinity,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              wrapWithModel(
                                model: _model.sideBarModel,
                                updateCallback: () => safeSetState(() {}),
                                child: const SideBarWidget(),
                              ),
                              Flexible(
                                child: Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, 0.0),
                                  child: FutureBuilder<ApiCallResponse>(
                                    future: FunctionsSupabaseRebanhoGroup
                                        .buscarRebanhoFiltrosCall
                                        .call(
                                      pCategoria: FFAppState().filtroCategoria,
                                      pDataNascimentoDe: dateTimeFormat(
                                        "yyyy-MM-dd",
                                        FFAppState().filtroDataNacimentoDe,
                                      ),
                                      pDataNascimentoAte: dateTimeFormat(
                                        "yyyy-MM-dd",
                                        FFAppState().filtroDataNacimentoAte,
                                      ),
                                      pIdPropriedade: FFAppState()
                                          .propriedadeSelecionada
                                          .idPropriedade,
                                      pLoteNome: FFAppState().filtroLoteNome,
                                      pOrigem: FFAppState().filtroOrigem,
                                      pRaca: FFAppState().filtroRaca,
                                      pSexo: FFAppState().filtroSexo,
                                      pStatus: FFAppState().filtroStatusRebanho,
                                      pLimite: FFAppConstants.limit,
                                      pOffset: functions.calcDeslocamento(
                                          _model.pageNumAdd,
                                          FFAppConstants.limit),
                                      pPesquisa:
                                          _model.pesquisaTextController.text,
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.error_outline_rounded,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .error,
                                                size: 36.0,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Erro ao carregar',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      final containerAnimaisForaBuscarRebanhoFiltrosResponse =
                                          snapshot.data!;

                                      return Container(
                                        width: 920.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Editar lote',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 40.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                                SizedBox(
                                                  height: 700.0,
                                                  child: Column(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            const Alignment(
                                                                0.0, 0),
                                                        child: TabBar(
                                                          labelColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                          unselectedLabelColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .secondaryText,
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                          unselectedLabelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleMedium
                                                                        .fontStyle,
                                                                  ),
                                                          indicatorColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary,
                                                          tabs: const [
                                                            Tab(
                                                              text:
                                                                  'Informações',
                                                            ),
                                                            Tab(
                                                              text: 'Animais',
                                                            ),
                                                          ],
                                                          controller: _model
                                                              .tabBarController,
                                                          onTap: (i) async {
                                                            [
                                                              () async {},
                                                              () async {}
                                                            ][i]();
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: TabBarView(
                                                          controller: _model
                                                              .tabBarController,
                                                          children: [
                                                            SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Nome do lote*',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                            ),
                                                                            TextFormField(
                                                                              controller: _model.nomeLoteTextController ??= TextEditingController(
                                                                                text: valueOrDefault<String>(
                                                                                  containerLotesRow?.nome,
                                                                                  'Nome',
                                                                                ),
                                                                              ),
                                                                              focusNode: _model.nomeLoteFocusNode,
                                                                              autofocus: false,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                isDense: false,
                                                                                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                hintText: 'Nome do lote',
                                                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      color: const Color(0xFFBEBEBE),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                errorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: FlutterFlowTheme.of(context).customColor2,
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                              validator: _model.nomeLoteTextControllerValidator.asValidator(context),
                                                                            ),
                                                                          ].divide(const SizedBox(height: 8.0)),
                                                                        ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            24.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Anotações',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            100.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              const Color(0xFFF1F1F1),
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        child:
                                                                            TextFormField(
                                                                          controller: _model.anotacoesTextController ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              containerLotesRow?.anotacoes,
                                                                              'anotações',
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.anotacoesFocusNode,
                                                                          autofocus:
                                                                              false,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(context).accent3,
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                _model.loteEdit?.firstOrNull?.anotacoes,
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .anotacoesTextControllerValidator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        80.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          blurRadius:
                                                                              1.0,
                                                                          color:
                                                                              Color(0x1A000000),
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            2.0,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .customColor12,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          24.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            'Este lote está ativo?',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                          Builder(
                                                                            builder:
                                                                                (context) {
                                                                              final ativoValue = (containerLotesRow?.ativo ?? '').trim().toLowerCase();
                                                                              final isAtivo = ativoValue == 'ativo' || ativoValue == 'true' || ativoValue == '1' || ativoValue == 'sim';

                                                                              return Switch.adaptive(
                                                                                value: _model.switchValue ??= isAtivo,
                                                                                onChanged: (newValue) async {
                                                                                  safeSetState(() => _model.switchValue = newValue);
                                                                                },
                                                                                activeColor: FlutterFlowTheme.of(context).primary,
                                                                                activeTrackColor: FlutterFlowTheme.of(context).primary,
                                                                                inactiveTrackColor: FlutterFlowTheme.of(context).alternate,
                                                                                inactiveThumbColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              );
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if ((_model
                                                                              .loteEdit
                                                                              ?.firstOrNull
                                                                              ?.ativo ==
                                                                          'Inativo') ||
                                                                      (_model.switchValue ==
                                                                          false))
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children:
                                                                                [
                                                                              Text(
                                                                                'Motivo',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              Builder(
                                                                                builder: (context) {
                                                                                  final currentMotivo = _model.motivoCleared ? null : _model.dropDownLotesValue;
                                                                                  final hasMotivo = currentMotivo != null && currentMotivo.trim().isNotEmpty;

                                                                                  return Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: FlutterFlowDropDown<String>(
                                                                                          controller: _model.dropDownLotesValueController ??= FormFieldController<String>(
                                                                                            _model.dropDownLotesValue ??= containerLotesRow?.motivo,
                                                                                          ),
                                                                                          options: const [
                                                                                            'Lote vendido'
                                                                                          ],
                                                                                          onChanged: (val) => safeSetState(() {
                                                                                            _model.motivoCleared = false;
                                                                                            _model.dropDownLotesValue = val;
                                                                                          }),
                                                                                          height: 56.0,
                                                                                          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                fontSize: 16.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w600,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                          hintText: 'Selecionar',
                                                                                          icon: Icon(
                                                                                            Icons.keyboard_arrow_down_rounded,
                                                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                                                            size: 24.0,
                                                                                          ),
                                                                                          fillColor: const Color(0xFFF1F1F1),
                                                                                          elevation: 2.0,
                                                                                          borderColor: Colors.transparent,
                                                                                          borderWidth: 0.0,
                                                                                          borderRadius: 8.0,
                                                                                          margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                          hidesUnderline: true,
                                                                                          isOverButton: false,
                                                                                          isSearchable: false,
                                                                                          isMultiSelect: false,
                                                                                        ),
                                                                                      ),
                                                                                      if (hasMotivo) ...[
                                                                                        const SizedBox(width: 8.0),
                                                                                        IconButton(
                                                                                          icon: Icon(
                                                                                            Icons.close,
                                                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                                                            size: 20.0,
                                                                                          ),
                                                                                          onPressed: () async {
                                                                                            safeSetState(() {
                                                                                              _model.motivoCleared = true;
                                                                                              _model.dropDownLotesValue = null;
                                                                                              _model.dropDownLotesValueController?.value = null;
                                                                                            });
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ],
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ].divide(const SizedBox(height: 8.0)),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children:
                                                                                [
                                                                              Text(
                                                                                'Data',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              Builder(
                                                                                builder: (context) {
                                                                                  final hasDate = !_model.dataMotivoCleared && _model.datePicked != null;

                                                                                  return Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Stack(
                                                                                          children: [
                                                                                            TextFormField(
                                                                                              controller: _model.dataEntradaLoteTextController ??= TextEditingController(
                                                                                                text: valueOrDefault<String>(
                                                                                                  _model.datePicked != null
                                                                                                      ? dateTimeFormat(
                                                                                                          "d/M/y",
                                                                                                          _model.datePicked,
                                                                                                          locale: FFLocalizations.of(context).languageCode,
                                                                                                        )
                                                                                                      : _model.dataMotivoCleared
                                                                                                          ? 'dd/mm/aaaa'
                                                                                                          : valueOrDefault<String>(
                                                                                                              dateTimeFormat(
                                                                                                                "d/M/y",
                                                                                                                containerLotesRow?.dataMotivo,
                                                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                                                              ),
                                                                                                              'dd/mm/aaaa',
                                                                                                            ),
                                                                                                  'dd/mm/yyyy',
                                                                                                ),
                                                                                              ),
                                                                                              focusNode: _model.dataEntradaLoteFocusNode,
                                                                                              autofocus: false,
                                                                                              readOnly: true,
                                                                                              obscureText: false,
                                                                                              decoration: InputDecoration(
                                                                                                isDense: false,
                                                                                                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                                      font: GoogleFonts.poppins(
                                                                                                        fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                                      ),
                                                                                                      fontSize: 16.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                                    ),
                                                                                                hintText: valueOrDefault<String>(
                                                                                                  _model.datePicked != null
                                                                                                      ? dateTimeFormat(
                                                                                                          "d/M/y",
                                                                                                          _model.datePicked,
                                                                                                          locale: FFLocalizations.of(context).languageCode,
                                                                                                        )
                                                                                                      : _model.dataMotivoCleared
                                                                                                          ? 'dd/mm/aaaa'
                                                                                                          : dateTimeFormat(
                                                                                                              "d/M/y",
                                                                                                              containerLotesRow?.dataMotivo,
                                                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                                                            ),
                                                                                                  'dd/mm/aaaa',
                                                                                                ),
                                                                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                                      font: GoogleFonts.poppins(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: const Color(0xFFBEBEBE),
                                                                                                      fontSize: 16.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                                    ),
                                                                                                enabledBorder: OutlineInputBorder(
                                                                                                  borderSide: const BorderSide(
                                                                                                    color: Color(0x00000000),
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                                ),
                                                                                                focusedBorder: OutlineInputBorder(
                                                                                                  borderSide: const BorderSide(
                                                                                                    color: Color(0x00000000),
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                                ),
                                                                                                errorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                                ),
                                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                                  borderSide: BorderSide(
                                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                                    width: 1.0,
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                                ),
                                                                                                filled: true,
                                                                                                fillColor: FlutterFlowTheme.of(context).customColor2,
                                                                                                suffixIcon: Icon(
                                                                                                  Icons.calendar_today,
                                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                ),
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.poppins(
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    fontSize: 16.0,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                              validator: _model.dataEntradaLoteTextControllerValidator.asValidator(context),
                                                                                            ),
                                                                                            InkWell(
                                                                                              splashColor: Colors.transparent,
                                                                                              focusColor: Colors.transparent,
                                                                                              hoverColor: Colors.transparent,
                                                                                              highlightColor: Colors.transparent,
                                                                                              onTap: () async {
                                                                                                final datePickedDate = await showDatePicker(
                                                                                                  context: context,
                                                                                                  initialDate: getCurrentTimestamp,
                                                                                                  firstDate: DateTime(1900),
                                                                                                  lastDate: DateTime(2050),
                                                                                                  builder: (context, child) {
                                                                                                    return wrapInMaterialDatePickerTheme(
                                                                                                      context,
                                                                                                      child!,
                                                                                                      headerBackgroundColor: FlutterFlowTheme.of(context).primary,
                                                                                                      headerForegroundColor: FlutterFlowTheme.of(context).info,
                                                                                                      headerTextStyle: FlutterFlowTheme.of(context).headlineLarge.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FontWeight.w600,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 32.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                                                          ),
                                                                                                      pickerBackgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                      pickerForegroundColor: FlutterFlowTheme.of(context).primaryText,
                                                                                                      selectedDateTimeBackgroundColor: FlutterFlowTheme.of(context).primary,
                                                                                                      selectedDateTimeForegroundColor: FlutterFlowTheme.of(context).info,
                                                                                                      actionButtonForegroundColor: FlutterFlowTheme.of(context).primaryText,
                                                                                                      iconSize: 24.0,
                                                                                                    );
                                                                                                  },
                                                                                                );

                                                                                                if (datePickedDate != null) {
                                                                                                  safeSetState(() {
                                                                                                    _model.dataMotivoCleared = false;
                                                                                                    _model.datePicked = DateTime(
                                                                                                      datePickedDate.year,
                                                                                                      datePickedDate.month,
                                                                                                      datePickedDate.day,
                                                                                                    );
                                                                                                  });
                                                                                                } else if (_model.datePicked != null) {
                                                                                                  safeSetState(() {
                                                                                                    _model.datePicked = getCurrentTimestamp;
                                                                                                  });
                                                                                                }
                                                                                                safeSetState(() {
                                                                                                  _model.dataEntradaLoteTextController?.text = dateTimeFormat(
                                                                                                    "d/M/y",
                                                                                                    _model.datePicked,
                                                                                                    locale: FFLocalizations.of(context).languageCode,
                                                                                                  );
                                                                                                });
                                                                                              },
                                                                                              child: Container(
                                                                                                width: double.infinity,
                                                                                                height: 56.0,
                                                                                                decoration: const BoxDecoration(),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      if (hasDate) ...[
                                                                                        const SizedBox(width: 8.0),
                                                                                        IconButton(
                                                                                          icon: Icon(
                                                                                            Icons.close,
                                                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                                                            size: 20.0,
                                                                                          ),
                                                                                          onPressed: () async {
                                                                                            safeSetState(() {
                                                                                              _model.dataMotivoCleared = true;
                                                                                              _model.datePicked = null;
                                                                                              _model.dataEntradaLoteTextController?.text = 'dd/mm/aaaa';
                                                                                            });
                                                                                          },
                                                                                        ),
                                                                                      ],
                                                                                    ],
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ].divide(const SizedBox(height: 8.0)),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children:
                                                                                [
                                                                              Text(
                                                                                'Valor da venda (R\$)',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              Container(
                                                                                height: 56.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).customColor2,
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: 60.0,
                                                                                    child: custom_widgets.CurrencyInputBR(
                                                                                      width: double.infinity,
                                                                                      height: 60.0,
                                                                                      initialValue: valueOrDefault<double>(
                                                                                        containerLotesRow?.valorVenda,
                                                                                        0.0,
                                                                                      ),
                                                                                      hintText: 'R\$ 0,00',
                                                                                      fillColor: FlutterFlowTheme.of(context).customColor2,
                                                                                      borderColor: Colors.transparent,
                                                                                      focusedBorderColor: Colors.transparent,
                                                                                      textColor: FlutterFlowTheme.of(context).secondaryText,
                                                                                      fontSize: 16.0,
                                                                                      borderRadius: 8.0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ].divide(const SizedBox(height: 8.0)),
                                                                          ),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              width: 24.0)),
                                                                    ),
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          blurRadius:
                                                                              1.0,
                                                                          color:
                                                                              Color(0x1A000000),
                                                                          offset:
                                                                              Offset(
                                                                            0.0,
                                                                            2.0,
                                                                          ),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .customColor12,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          24.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                'Animais neste lote (${valueOrDefault<String>(
                                                                                  _model.animaisDentroLote.where((e) => ((_model.pesquisaDentroTextController.text == '') && (_model.filtroRightCategoria == '') && (_model.filtroRightSexo == '') && (_model.filtroRightRaca == '') && (_model.filtroRightOrigem == '') && (_model.filtroRightStatusRebanho == '') && (_model.filtroRightDataNacimentoDe == null) && (_model.filtroRightDataNacimentoAte == null) && (_model.filtroRightLoteNome == '')) || ((e.numeroAnimal.contains(_model.pesquisaDentroTextController.text) || e.nome.toLowerCase().contains(_model.pesquisaDentroTextController.text.toLowerCase()) || e.chip.contains(_model.pesquisaDentroTextController.text)) && ((_model.filtroRightSexo == '') || (e.sexo == _model.filtroRightSexo)) && ((_model.filtroRightCategoria == '') || (e.categoria == _model.filtroRightCategoria)) && ((_model.filtroRightRaca == '') || (e.raca == _model.filtroRightRaca)) && ((_model.filtroRightOrigem == '') || (e.origem == _model.filtroRightOrigem)) && ((_model.filtroRightStatusRebanho == '') || (e.status == _model.filtroRightStatusRebanho)) && ((_model.filtroRightDataNacimentoDe == null) || (functions.converterParaData(e.dataNascimento) != null && !functions.converterParaData(e.dataNascimento)!.isBefore(_model.filtroRightDataNacimentoDe!))) && ((_model.filtroRightDataNacimentoAte == null) || (functions.converterParaData(e.dataNascimento) != null && !functions.converterParaData(e.dataNascimento)!.isAfter(_model.filtroRightDataNacimentoAte!))) && ((_model.filtroRightLoteNome == '') || (e.loteNome == _model.filtroRightLoteNome)))).toList().length.toString(),
                                                                                  '0',
                                                                                )})',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 18.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              InkWell(
                                                                                splashColor: Colors.transparent,
                                                                                focusColor: Colors.transparent,
                                                                                hoverColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  safeSetState(() {
                                                                                    _model.tabBarController!.animateTo(
                                                                                      min(_model.tabBarController!.length - 1, _model.tabBarController!.index + 1),
                                                                                      duration: const Duration(milliseconds: 300),
                                                                                      curve: Curves.ease,
                                                                                    );
                                                                                  });
                                                                                },
                                                                                child: Text(
                                                                                  'Ver todos',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).accent3,
                                                                                        fontSize: 16.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          if (_model
                                                                              .animaisDentroLote
                                                                              .isEmpty)
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                safeSetState(() {
                                                                                  _model.tabBarController!.animateTo(
                                                                                    min(_model.tabBarController!.length - 1, _model.tabBarController!.index + 1),
                                                                                    duration: const Duration(milliseconds: 300),
                                                                                    curve: Curves.ease,
                                                                                  );
                                                                                });
                                                                              },
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                children: [
                                                                                  Opacity(
                                                                                    opacity: 0.4,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(8.0),
                                                                                        child: SvgPicture.asset(
                                                                                          'assets/images/Rebanho.svg',
                                                                                          width: 78.0,
                                                                                          height: 58.0,
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    'Nenhum animal foi adicionado neste lote.',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                  ),
                                                                                  Text(
                                                                                    'Clique aqui para adicionar',
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(context).secondary,
                                                                                          fontSize: 12.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          if (_model
                                                                              .animaisDentroLote
                                                                              .isNotEmpty)
                                                                            Container(
                                                                              child: Builder(
                                                                                builder: (context) {
                                                                                  final animais = _model.animaisDentroLote.where((e) => ((_model.pesquisaDentroTextController.text == '') && (_model.filtroRightCategoria == '') && (_model.filtroRightSexo == '') && (_model.filtroRightRaca == '') && (_model.filtroRightOrigem == '') && (_model.filtroRightStatusRebanho == '') && (_model.filtroRightDataNacimentoDe == null) && (_model.filtroRightDataNacimentoAte == null) && (_model.filtroRightLoteNome == '')) || ((e.numeroAnimal.contains(_model.pesquisaDentroTextController.text) || e.nome.toLowerCase().contains(_model.pesquisaDentroTextController.text.toLowerCase()) || e.chip.contains(_model.pesquisaDentroTextController.text)) && ((_model.filtroRightSexo == '') || (e.sexo == _model.filtroRightSexo)) && ((_model.filtroRightCategoria == '') || (e.categoria == _model.filtroRightCategoria)) && ((_model.filtroRightRaca == '') || (e.raca == _model.filtroRightRaca)) && ((_model.filtroRightOrigem == '') || (e.origem == _model.filtroRightOrigem)) && ((_model.filtroRightStatusRebanho == '') || (e.status == _model.filtroRightStatusRebanho)) && ((_model.filtroRightDataNacimentoDe == null) || (functions.converterParaData(e.dataNascimento) != null && !functions.converterParaData(e.dataNascimento)!.isBefore(_model.filtroRightDataNacimentoDe!))) && ((_model.filtroRightDataNacimentoAte == null) || (functions.converterParaData(e.dataNascimento) != null && !functions.converterParaData(e.dataNascimento)!.isAfter(_model.filtroRightDataNacimentoAte!))) && ((_model.filtroRightLoteNome == '') || (e.loteNome == _model.filtroRightLoteNome)))).toList().take(4).toList();

                                                                                  return ListView.builder(
                                                                                    padding: EdgeInsets.zero,
                                                                                    primary: false,
                                                                                    shrinkWrap: true,
                                                                                    scrollDirection: Axis.vertical,
                                                                                    itemCount: animais.length,
                                                                                    itemBuilder: (context, animaisIndex) {
                                                                                      final animaisItem = animais[animaisIndex];
                                                                                      return Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Column(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Row(
                                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                                      children: [
                                                                                                        ClipRRect(
                                                                                                          borderRadius: BorderRadius.circular(0.0),
                                                                                                          child: Image.asset(
                                                                                                            'assets/images/Group_11_3_(1).png',
                                                                                                            width: 24.0,
                                                                                                            height: 24.0,
                                                                                                            fit: BoxFit.contain,
                                                                                                          ),
                                                                                                        ),
                                                                                                        if (animaisItem.sexo == 'Macho')
                                                                                                          ClipRRect(
                                                                                                            borderRadius: BorderRadius.circular(0.0),
                                                                                                            child: Image.asset(
                                                                                                              'assets/images/Sexomacho.png',
                                                                                                              width: 24.0,
                                                                                                              height: 24.0,
                                                                                                              fit: BoxFit.cover,
                                                                                                            ),
                                                                                                          ),
                                                                                                        if (animaisItem.sexo == 'Fêmea')
                                                                                                          ClipRRect(
                                                                                                            borderRadius: BorderRadius.circular(0.0),
                                                                                                            child: Image.asset(
                                                                                                              'assets/images/Sexofemea.png',
                                                                                                              width: 24.0,
                                                                                                              height: 24.0,
                                                                                                              fit: BoxFit.cover,
                                                                                                            ),
                                                                                                          ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '${valueOrDefault<String>(
                                                                                                        animaisItem.numeroAnimal,
                                                                                                        '0000',
                                                                                                      )} • ${valueOrDefault<String>(
                                                                                                            animaisItem.nome,
                                                                                                            'S/N',
                                                                                                          ) == 'null' ? 'S/N' : valueOrDefault<String>(
                                                                                                          animaisItem.nome,
                                                                                                          'S/N',
                                                                                                        )} • ${dateTimeFormat(
                                                                                                        "d/M/y",
                                                                                                        functions.converterParaData(animaisItem.dataNascimento),
                                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                                      )}',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 16.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.w500,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '${valueOrDefault<String>(
                                                                                                        animaisItem.categoria,
                                                                                                        'S/C',
                                                                                                      )} • ${valueOrDefault<String>(
                                                                                                        animaisItem.raca,
                                                                                                        'S/R',
                                                                                                      )}',
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FontWeight.normal,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            color: FlutterFlowTheme.of(context).customColor6,
                                                                                                            fontSize: 14.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.normal,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                    if (animaisItem.loteID != 'null')
                                                                                                      Row(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          ClipRRect(
                                                                                                            borderRadius: BorderRadius.circular(0.0),
                                                                                                            child: Image.asset(
                                                                                                              'assets/images/Lotes4343434.png',
                                                                                                              width: 24.0,
                                                                                                              height: 24.0,
                                                                                                              fit: BoxFit.contain,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Text(
                                                                                                            valueOrDefault<String>(
                                                                                                                      animaisItem.loteNome,
                                                                                                                      'S/L',
                                                                                                                    ) ==
                                                                                                                    'null'
                                                                                                                ? 'S/L'
                                                                                                                : valueOrDefault<String>(
                                                                                                                    animaisItem.loteNome,
                                                                                                                    'S/L',
                                                                                                                  ),
                                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                  font: GoogleFonts.poppins(
                                                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                  ),
                                                                                                                  letterSpacing: 0.0,
                                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                          ),
                                                                                                        ].divide(const SizedBox(width: 8.0)),
                                                                                                      ),
                                                                                                  ].divide(const SizedBox(height: 8.0)),
                                                                                                ),
                                                                                              ].divide(const SizedBox(width: 16.0)),
                                                                                            ),
                                                                                          ),
                                                                                          Divider(
                                                                                            height: 0.0,
                                                                                            thickness: 1.0,
                                                                                            color: FlutterFlowTheme.of(context).customColor5,
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                        ].divide(const SizedBox(height: 16.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]
                                                                    .divide(const SizedBox(
                                                                        height:
                                                                            24.0))
                                                                    .addToStart(
                                                                        const SizedBox(
                                                                            height:
                                                                                24.0)),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      24.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        2.0),
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          378.0,
                                                                      height:
                                                                          600.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                                2.0,
                                                                            color:
                                                                                Color(0x19000000),
                                                                            offset:
                                                                                Offset(
                                                                              2.0,
                                                                              4.0,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).customColor12,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            24.0),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Animais fora do lote (${valueOrDefault<String>(
                                                                                (containerAnimaisForaBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.length.toString(),
                                                                                '0',
                                                                              )})',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: 18.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                            ),
                                                                            Container(
                                                                              height: 56.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).customColor2,
                                                                                borderRadius: BorderRadius.circular(6.0),
                                                                              ),
                                                                              child: Align(
                                                                                alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                child: SizedBox(
                                                                                  width: 327.0,
                                                                                  child: TextFormField(
                                                                                    controller: _model.pesquisaTextController,
                                                                                    focusNode: _model.pesquisaFocusNode,
                                                                                    onChanged: (_) => EasyDebounce.debounce(
                                                                                      '_model.pesquisaTextController',
                                                                                      const Duration(milliseconds: 250),
                                                                                      () async {
                                                                                        safeSetState(() => _model.apiRequestCompleter = null);
                                                                                      },
                                                                                    ),
                                                                                    autofocus: false,
                                                                                    obscureText: false,
                                                                                    decoration: InputDecoration(
                                                                                      isDense: true,
                                                                                      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            fontSize: 16.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                          ),
                                                                                      hintText: 'Pesquisar',
                                                                                      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            fontSize: 16.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                          ),
                                                                                      enabledBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(
                                                                                          color: Color(0x00000000),
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      focusedBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(
                                                                                          color: Color(0x00000000),
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      errorBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).error,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      focusedErrorBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).error,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      filled: true,
                                                                                      fillColor: FlutterFlowTheme.of(context).customColor2,
                                                                                      hoverColor: Colors.transparent,
                                                                                      prefixIcon: Icon(
                                                                                        Icons.search_sharp,
                                                                                        color: FlutterFlowTheme.of(context).accent3,
                                                                                        size: 24.0,
                                                                                      ),
                                                                                      suffixIcon: _model.pesquisaTextController!.text.isNotEmpty
                                                                                          ? InkWell(
                                                                                              onTap: () async {
                                                                                                _model.pesquisaTextController?.clear();
                                                                                                safeSetState(() => _model.apiRequestCompleter = null);
                                                                                                safeSetState(() {});
                                                                                              },
                                                                                              child: const Icon(
                                                                                                Icons.clear,
                                                                                                size: 22,
                                                                                              ),
                                                                                            )
                                                                                          : null,
                                                                                    ),
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                    validator: _model.pesquisaTextControllerValidator.asValidator(context),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Builder(
                                                                              builder: (context) => FFButtonWidget(
                                                                                onPressed: () async {
                                                                                  await showDialog(
                                                                                    context: context,
                                                                                    builder: (dialogContext) {
                                                                                      return Dialog(
                                                                                        elevation: 0,
                                                                                        insetPadding: EdgeInsets.zero,
                                                                                        backgroundColor: Colors.transparent,
                                                                                        alignment: const AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                                        child: GestureDetector(
                                                                                          onTap: () {
                                                                                            FocusScope.of(dialogContext).unfocus();
                                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                                          },
                                                                                          child: const PpFiltroRebanhoWidget(),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                  _model.pageNumAdd = 1;
                                                                                  safeSetState(() => _model.apiRequestCompleter = null);
                                                                                },
                                                                                text: 'Filtrar',
                                                                                icon: const Icon(
                                                                                  Icons.filter_list,
                                                                                  size: 15.0,
                                                                                ),
                                                                                options: FFButtonOptions(
                                                                                  height: 40.0,
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  iconAlignment: IconAlignment.end,
                                                                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                  color: const Color(0x0028A365),
                                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).icon,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                  elevation: 0.0,
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).customColor12,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              height: 0.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                            if (responsiveVisibility(
                                                                              context: context,
                                                                              phone: false,
                                                                              tablet: false,
                                                                              tabletLandscape: false,
                                                                              desktop: false,
                                                                            ))
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: 40.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                  border: Border.all(
                                                                                    color: FlutterFlowTheme.of(context).customColor12,
                                                                                  ),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.arrow_upward_rounded,
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            size: 14.0,
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.arrow_downward_rounded,
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            size: 14.0,
                                                                                          ),
                                                                                          Text(
                                                                                            'Crescente',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          ),
                                                                                        ].divide(const SizedBox(width: 8.0)),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 24.0,
                                                                                        child: VerticalDivider(
                                                                                          thickness: 2.0,
                                                                                          color: FlutterFlowTheme.of(context).tertiary,
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Alfabética',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).secondary,
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.keyboard_arrow_down_sharp,
                                                                                            color: FlutterFlowTheme.of(context).secondary,
                                                                                            size: 24.0,
                                                                                          ),
                                                                                        ].divide(const SizedBox(width: 8.0)),
                                                                                      ),
                                                                                    ].divide(const SizedBox(width: 8.0)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Theme(
                                                                                  data: ThemeData(
                                                                                    checkboxTheme: CheckboxThemeData(
                                                                                      visualDensity: VisualDensity.compact,
                                                                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(4.0),
                                                                                      ),
                                                                                    ),
                                                                                    unselectedWidgetColor: FlutterFlowTheme.of(context).primaryText,
                                                                                  ),
                                                                                  child: Checkbox(
                                                                                    value: _model.checkboxValue ??= false,
                                                                                    onChanged: (newValue) async {
                                                                                      safeSetState(() => _model.checkboxValue = newValue!);
                                                                                      if (newValue!) {
                                                                                        final todosAnimais = (containerAnimaisForaBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => (e.status != 'Sêmen') && (e.status != 'Fora da propriedade')).where((e) => !(_model.animaisDentroLote.where((d) => d.idRebanho == e.idRebanho).toList().isNotEmpty)).toList();
                                                                                        for (final item in todosAnimais) {
                                                                                          if (!_model.animaisSelecionados.contains(item)) {
                                                                                            _model.addToAnimaisSelecionados(item);
                                                                                          }
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                      } else {
                                                                                        final todosAnimais = (containerAnimaisForaBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => (e.status != 'Sêmen') && (e.status != 'Fora da propriedade')).toList();
                                                                                        for (final item in todosAnimais) {
                                                                                          _model.removeFromAnimaisSelecionados(item);
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                      }
                                                                                    },
                                                                                    side: BorderSide(
                                                                                      width: 2,
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                    ),
                                                                                    activeColor: FlutterFlowTheme.of(context).primary,
                                                                                    checkColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  'Selecionar todos da página',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ].divide(const SizedBox(width: 8.0)),
                                                                            ),
                                                                            Flexible(
                                                                              child: Builder(
                                                                                builder: (context) {
                                                                                  final animais = (containerAnimaisForaBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => (e.status != 'Sêmen') || (e.status != 'Fora da propriedade')).toList().toList();

                                                                                  return ListView.builder(
                                                                                    padding: EdgeInsets.zero,
                                                                                    shrinkWrap: true,
                                                                                    scrollDirection: Axis.vertical,
                                                                                    itemCount: animais.length,
                                                                                    itemBuilder: (context, animaisIndex) {
                                                                                      final animaisItem = animais[animaisIndex];
                                                                                      return Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                if (_model.animaisSelecionados.contains(animaisItem) || (_model.animaisDentroLote.where((e) => e.idRebanho == animaisItem.idRebanho).toList().isNotEmpty))
                                                                                                  InkWell(
                                                                                                    splashColor: Colors.transparent,
                                                                                                    focusColor: Colors.transparent,
                                                                                                    hoverColor: Colors.transparent,
                                                                                                    highlightColor: Colors.transparent,
                                                                                                    onTap: () async {
                                                                                                      if (!(_model.animaisDentroLote.where((e) => e.idRebanho == animaisItem.idRebanho).toList().isNotEmpty)) {
                                                                                                        _model.removeFromAnimaisSelecionados(animaisItem);
                                                                                                        safeSetState(() {});
                                                                                                      }
                                                                                                    },
                                                                                                    child: Icon(
                                                                                                      Icons.check_box_rounded,
                                                                                                      color: valueOrDefault<Color>(
                                                                                                        _model.animaisDentroLote.where((e) => e.idRebanho == animaisItem.idRebanho).toList().isNotEmpty ? FlutterFlowTheme.of(context).accent3 : FlutterFlowTheme.of(context).primary,
                                                                                                        FlutterFlowTheme.of(context).primary,
                                                                                                      ),
                                                                                                      size: 24.0,
                                                                                                    ),
                                                                                                  ),
                                                                                                if (!_model.animaisSelecionados.contains(animaisItem) && !(_model.animaisDentroLote.where((e) => e.idRebanho == animaisItem.idRebanho).toList().isNotEmpty))
                                                                                                  InkWell(
                                                                                                    splashColor: Colors.transparent,
                                                                                                    focusColor: Colors.transparent,
                                                                                                    hoverColor: Colors.transparent,
                                                                                                    highlightColor: Colors.transparent,
                                                                                                    onTap: () async {
                                                                                                      _model.addToAnimaisSelecionados(animaisItem);
                                                                                                      safeSetState(() {});
                                                                                                    },
                                                                                                    child: Icon(
                                                                                                      Icons.check_box_outline_blank_rounded,
                                                                                                      color: FlutterFlowTheme.of(context).customColor6,
                                                                                                      size: 24.0,
                                                                                                    ),
                                                                                                  ),
                                                                                                Flexible(
                                                                                                  child: Column(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          ClipRRect(
                                                                                                            borderRadius: BorderRadius.circular(0.0),
                                                                                                            child: Image.asset(
                                                                                                              'assets/images/Group_11_3_(1).png',
                                                                                                              width: 24.0,
                                                                                                              height: 24.0,
                                                                                                              fit: BoxFit.contain,
                                                                                                            ),
                                                                                                          ),
                                                                                                          if (animaisItem.sexo == 'Macho')
                                                                                                            ClipRRect(
                                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/Sexomacho.png',
                                                                                                                width: 24.0,
                                                                                                                height: 24.0,
                                                                                                                fit: BoxFit.cover,
                                                                                                              ),
                                                                                                            ),
                                                                                                          if (animaisItem.sexo == 'Fêmea')
                                                                                                            ClipRRect(
                                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/Sexofemea.png',
                                                                                                                width: 24.0,
                                                                                                                height: 24.0,
                                                                                                                fit: BoxFit.cover,
                                                                                                              ),
                                                                                                            ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      Text(
                                                                                                        '${valueOrDefault<String>(
                                                                                                          animaisItem.numeroAnimal,
                                                                                                          '0000',
                                                                                                        )} • ${valueOrDefault<String>(
                                                                                                              animaisItem.nome,
                                                                                                              'S/N',
                                                                                                            ) == 'null' ? 'S/N' : valueOrDefault<String>(
                                                                                                            animaisItem.nome,
                                                                                                            'S/N',
                                                                                                          )} • ${dateTimeFormat(
                                                                                                          "d/M/y",
                                                                                                          functions.converterParaData(animaisItem.dataNascimento),
                                                                                                          locale: FFLocalizations.of(context).languageCode,
                                                                                                        )}',
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.poppins(
                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              fontSize: 16.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        '${valueOrDefault<String>(
                                                                                                          animaisItem.categoria,
                                                                                                          'S/C',
                                                                                                        )} • ${valueOrDefault<String>(
                                                                                                          animaisItem.raca,
                                                                                                          'S/R',
                                                                                                        )}',
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.poppins(
                                                                                                                fontWeight: FontWeight.normal,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              color: FlutterFlowTheme.of(context).customColor6,
                                                                                                              fontSize: 14.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FontWeight.normal,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                      ),
                                                                                                      if (animaisItem.loteID != 'null')
                                                                                                        Row(
                                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                                          children: [
                                                                                                            ClipRRect(
                                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/Lotes4343434.png',
                                                                                                                width: 24.0,
                                                                                                                height: 24.0,
                                                                                                                fit: BoxFit.contain,
                                                                                                              ),
                                                                                                            ),
                                                                                                            Flexible(
                                                                                                              child: Text(
                                                                                                                valueOrDefault<String>(
                                                                                                                          animaisItem.loteNome,
                                                                                                                          'S/L',
                                                                                                                        ) ==
                                                                                                                        'null'
                                                                                                                    ? 'S/L'
                                                                                                                    : valueOrDefault<String>(
                                                                                                                        animaisItem.loteNome,
                                                                                                                        'S/L',
                                                                                                                      ),
                                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                      font: GoogleFonts.poppins(
                                                                                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                      ),
                                                                                                                      letterSpacing: 0.0,
                                                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                    ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ].divide(const SizedBox(width: 8.0)),
                                                                                                        ),
                                                                                                    ].divide(const SizedBox(height: 8.0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ].divide(const SizedBox(width: 16.0)),
                                                                                            ),
                                                                                          ),
                                                                                          Divider(
                                                                                            height: 0.0,
                                                                                            thickness: 1.0,
                                                                                            color: FlutterFlowTheme.of(context).customColor5,
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                FutureBuilder<ApiCallResponse>(
                                                                                  future: FunctionsSupabaseRebanhoGroup.countRebanhoFiltrosCall.call(
                                                                                    pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                    pCategoria: FFAppState().filtroCategoria,
                                                                                    pDataNascimentoDe: dateTimeFormat(
                                                                                      "yyyy-MM-dd",
                                                                                      FFAppState().filtroDataNacimentoDe,
                                                                                    ),
                                                                                    pDataNascimentoAte: dateTimeFormat(
                                                                                      "yyyy-MM-dd",
                                                                                      FFAppState().filtroDataNacimentoAte,
                                                                                    ),
                                                                                    pLoteID: FFAppState().filtroLoteId,
                                                                                    pOrigem: FFAppState().filtroOrigem,
                                                                                    pRaca: FFAppState().filtroRaca,
                                                                                    pSexo: FFAppState().filtroSexo,
                                                                                    pStatus: FFAppState().filtroStatusRebanho,
                                                                                    pPesquisa: _model.pesquisaTextController.text,
                                                                                  ),
                                                                                  builder: (context, snapshot) {
                                                                                    // Customize what your widget looks like when it's loading.
                                                                                    if (!snapshot.hasData) {
                                                                                      return Center(
                                                                                        child: SizedBox(
                                                                                          width: 50.0,
                                                                                          height: 50.0,
                                                                                          child: CircularProgressIndicator(
                                                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                                                              FlutterFlowTheme.of(context).primary,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    if (snapshot.hasError) {
                                                                                      return Center(
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            Icon(
                                                                                              Icons.error_outline_rounded,
                                                                                              color: FlutterFlowTheme.of(context).error,
                                                                                              size: 36.0,
                                                                                            ),
                                                                                            const SizedBox(height: 8.0),
                                                                                            Text(
                                                                                              'Erro ao carregar',
                                                                                              style: FlutterFlowTheme.of(context).bodySmall,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      );
                                                                                    }
                                                                                    final containerCountRebanhoFiltrosResponse = snapshot.data!;

                                                                                    return Container(
                                                                                      height: 56.0,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                        border: Border.all(
                                                                                          color: FlutterFlowTheme.of(context).customColor5,
                                                                                        ),
                                                                                      ),
                                                                                      child: Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              _model.pageNumAdd = 1;
                                                                                              safeSetState(() {});
                                                                                              safeSetState(() => _model.apiRequestCompleter = null);
                                                                                            },
                                                                                            child: Container(
                                                                                              height: double.infinity,
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                borderRadius: const BorderRadius.only(
                                                                                                  bottomLeft: Radius.circular(6.0),
                                                                                                  bottomRight: Radius.circular(0.0),
                                                                                                  topLeft: Radius.circular(6.0),
                                                                                                  topRight: Radius.circular(0.0),
                                                                                                ),
                                                                                                border: Border.all(
                                                                                                  color: FlutterFlowTheme.of(context).customColor5,
                                                                                                ),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                                                                                                child: Icon(
                                                                                                  Icons.keyboard_double_arrow_left,
                                                                                                  color: valueOrDefault<Color>(
                                                                                                    _model.pageNumAdd > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                                    FlutterFlowTheme.of(context).primaryText,
                                                                                                  ),
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              if (_model.pageNumAdd > 1) {
                                                                                                _model.pageNumAdd = _model.pageNumAdd + -1;
                                                                                                safeSetState(() {});
                                                                                                safeSetState(() => _model.apiRequestCompleter = null);
                                                                                              }
                                                                                            },
                                                                                            child: Container(
                                                                                              height: double.infinity,
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                border: Border.all(
                                                                                                  color: FlutterFlowTheme.of(context).customColor5,
                                                                                                ),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.all(12.0),
                                                                                                child: Icon(
                                                                                                  Icons.keyboard_arrow_left_sharp,
                                                                                                  color: valueOrDefault<Color>(
                                                                                                    _model.pageNumAdd > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                                    FlutterFlowTheme.of(context).primaryText,
                                                                                                  ),
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                            child: RichText(
                                                                                              textScaler: MediaQuery.of(context).textScaler,
                                                                                              text: TextSpan(
                                                                                                children: [
                                                                                                  TextSpan(
                                                                                                    text: valueOrDefault<String>(
                                                                                                      _model.pageNumAdd.toString(),
                                                                                                      '1',
                                                                                                    ),
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          font: GoogleFonts.poppins(
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                          fontSize: 16.0,
                                                                                                          letterSpacing: 0.0,
                                                                                                          fontWeight: FontWeight.w600,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                  ),
                                                                                                  const TextSpan(
                                                                                                    text: ' de ',
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 16.0,
                                                                                                    ),
                                                                                                  ),
                                                                                                  TextSpan(
                                                                                                    text: valueOrDefault<String>(
                                                                                                      ((containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil()).toString(),
                                                                                                      '1',
                                                                                                    ),
                                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                          font: GoogleFonts.poppins(
                                                                                                            fontWeight: FontWeight.w500,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                          color: FlutterFlowTheme.of(context).accent3,
                                                                                                          fontSize: 16.0,
                                                                                                          letterSpacing: 0.0,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                  )
                                                                                                ],
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.poppins(
                                                                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              if (_model.pageNumAdd <
                                                                                                  valueOrDefault<int>(
                                                                                                    (containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                                    1,
                                                                                                  )) {
                                                                                                _model.pageNumAdd = _model.pageNumAdd + 1;
                                                                                                safeSetState(() {});
                                                                                                safeSetState(() => _model.apiRequestCompleter = null);
                                                                                              }
                                                                                            },
                                                                                            child: Container(
                                                                                              height: double.infinity,
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                border: Border.all(
                                                                                                  color: FlutterFlowTheme.of(context).customColor5,
                                                                                                ),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.all(12.0),
                                                                                                child: Icon(
                                                                                                  Icons.keyboard_arrow_right_sharp,
                                                                                                  color: valueOrDefault<Color>(
                                                                                                    _model.pageNumAdd <
                                                                                                            valueOrDefault<int>(
                                                                                                              (containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                                              1,
                                                                                                            )
                                                                                                        ? FlutterFlowTheme.of(context).primaryText
                                                                                                        : FlutterFlowTheme.of(context).accent3,
                                                                                                    FlutterFlowTheme.of(context).primaryText,
                                                                                                  ),
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              _model.pageNumAdd = valueOrDefault<int>(
                                                                                                (containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                                1,
                                                                                              );
                                                                                              safeSetState(() {});
                                                                                              safeSetState(() => _model.apiRequestCompleter = null);
                                                                                            },
                                                                                            child: Container(
                                                                                              height: double.infinity,
                                                                                              decoration: BoxDecoration(
                                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                borderRadius: const BorderRadius.only(
                                                                                                  bottomLeft: Radius.circular(0.0),
                                                                                                  bottomRight: Radius.circular(6.0),
                                                                                                  topLeft: Radius.circular(0.0),
                                                                                                  topRight: Radius.circular(6.0),
                                                                                                ),
                                                                                                border: Border.all(
                                                                                                  color: FlutterFlowTheme.of(context).customColor5,
                                                                                                ),
                                                                                              ),
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.all(12.0),
                                                                                                child: Icon(
                                                                                                  Icons.keyboard_double_arrow_right_outlined,
                                                                                                  color: valueOrDefault<Color>(
                                                                                                    _model.pageNumAdd ==
                                                                                                            valueOrDefault<int>(
                                                                                                              (containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                                              1,
                                                                                                            )
                                                                                                        ? FlutterFlowTheme.of(context).accent3
                                                                                                        : FlutterFlowTheme.of(context).primaryText,
                                                                                                    FlutterFlowTheme.of(context).primaryText,
                                                                                                  ),
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ].divide(const SizedBox(height: 16.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      FlutterFlowIconButton(
                                                                        borderRadius:
                                                                            6.0,
                                                                        buttonSize:
                                                                            40.0,
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).primary,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .arrow_forward_ios,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).info,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          if (_model
                                                                              .animaisSelecionados
                                                                              .isEmpty) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text(
                                                                                  'Nenhum animal selecionado',
                                                                                  style: TextStyle(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                ),
                                                                                duration: const Duration(milliseconds: 4000),
                                                                                backgroundColor: FlutterFlowTheme.of(context).error,
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }

                                                                          final idProp = FFAppState()
                                                                              .propriedadeSelecionada
                                                                              .idPropriedade;
                                                                          final destNome = _model.nomeLoteTextController.text.trim().isNotEmpty
                                                                              ? _model.nomeLoteTextController.text.trim()
                                                                              : (containerLotesRow?.nome ?? widget.loteNome ?? '').trim();
                                                                          final destId =
                                                                              (containerLotesRow?.idLote ?? widget.idLote ?? '').trim();

                                                                          final conflitos = _model
                                                                              .animaisSelecionados
                                                                              .where((a) => functions.animalEstaEmOutroLote(
                                                                                    a,
                                                                                    nomeLoteDestino: destNome.isEmpty ? null : destNome,
                                                                                    idLoteDestino: destId.isEmpty ? null : destId,
                                                                                  ))
                                                                              .toList();

                                                                          if (conflitos
                                                                              .isNotEmpty) {
                                                                            final linhas =
                                                                                conflitos.map((a) {
                                                                              final prev = a.loteNome.trim().isNotEmpty && a.loteNome.trim().toLowerCase() != 'null' ? a.loteNome.trim() : a.loteID.trim();
                                                                              return '• ${a.numeroAnimal} — ${a.nome.isNotEmpty ? a.nome : 'sem nome'} (${prev.isEmpty ? 'outro lote' : 'lote: $prev'})';
                                                                            }).join('\n');

                                                                            final aceitou = await showDialog<bool>(
                                                                                  context: context,
                                                                                  builder: (alertDialogContext) {
                                                                                    return AlertDialog(
                                                                                      title: const Text('Animal em outro lote'),
                                                                                      content: SingleChildScrollView(
                                                                                        child: Text(
                                                                                          'Os animais abaixo já estão cadastrados em outro lote:\n\n$linhas\n\nDeseja removê-los do lote anterior para adicionar a este lote?',
                                                                                        ),
                                                                                      ),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          onPressed: () => Navigator.pop(alertDialogContext, false),
                                                                                          child: const Text('Cancelar'),
                                                                                        ),
                                                                                        TextButton(
                                                                                          onPressed: () => Navigator.pop(alertDialogContext, true),
                                                                                          child: const Text('Sim, concordo'),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                ) ??
                                                                                false;

                                                                            if (!aceitou) {
                                                                              return;
                                                                            }

                                                                            for (final a
                                                                                in conflitos) {
                                                                              await removerAnimalDeLoteAnterior(
                                                                                idPropriedade: idProp,
                                                                                idRebanho: a.idRebanho,
                                                                                loteNomeHint: a.loteNome.trim().isNotEmpty && a.loteNome.trim().toLowerCase() != 'null' ? a.loteNome.trim() : null,
                                                                                loteIdHint: a.loteID.trim().isNotEmpty && a.loteID.trim().toLowerCase() != 'null' ? a.loteID.trim() : null,
                                                                              );
                                                                            }
                                                                          }

                                                                          if (!context
                                                                              .mounted) {
                                                                            return;
                                                                          }

                                                                          final idsConflito = conflitos
                                                                              .map((e) => e.idRebanho)
                                                                              .toSet();
                                                                          _model.animaisDentroLote = _model
                                                                              .animaisSelecionados
                                                                              .map((a) {
                                                                            if (idsConflito.contains(a.idRebanho)) {
                                                                              final m = Map<String, dynamic>.from(a.toMap());
                                                                              m['loteID'] = null;
                                                                              m['loteNome'] = null;
                                                                              return RebanhoDTStruct.fromMap(m);
                                                                            }
                                                                            return a;
                                                                          }).toList();

                                                                          safeSetState(
                                                                              () {});
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            SnackBar(
                                                                              content: Text(
                                                                                'Animais adicionados',
                                                                                style: TextStyle(
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                ),
                                                                              ),
                                                                              duration: const Duration(milliseconds: 4000),
                                                                              backgroundColor: FlutterFlowTheme.of(context).secondary,
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        2.0),
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          378.0,
                                                                      height:
                                                                          600.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                                2.0,
                                                                            color:
                                                                                Color(0x19000000),
                                                                            offset:
                                                                                Offset(
                                                                              2.0,
                                                                              4.0,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).customColor12,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            24.0),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Animais neste lote (${valueOrDefault<String>(
                                                                                _model.animaisDentroLote.length.toString(),
                                                                                '0',
                                                                              )})',
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: 18.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                            ),
                                                                            Container(
                                                                              height: 56.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).customColor2,
                                                                                borderRadius: BorderRadius.circular(6.0),
                                                                              ),
                                                                              child: Align(
                                                                                alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                child: SizedBox(
                                                                                  width: 327.0,
                                                                                  child: TextFormField(
                                                                                    controller: _model.pesquisaDentroTextController,
                                                                                    focusNode: _model.pesquisaDentroFocusNode,
                                                                                    onChanged: (_) => EasyDebounce.debounce(
                                                                                      '_model.pesquisaDentroTextController',
                                                                                      const Duration(milliseconds: 250),
                                                                                      () => safeSetState(() {}),
                                                                                    ),
                                                                                    autofocus: false,
                                                                                    obscureText: false,
                                                                                    decoration: InputDecoration(
                                                                                      isDense: true,
                                                                                      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            fontSize: 16.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                          ),
                                                                                      hintText: 'Pesquisar',
                                                                                      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w600,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            fontSize: 16.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                          ),
                                                                                      enabledBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(
                                                                                          color: Color(0x00000000),
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      focusedBorder: OutlineInputBorder(
                                                                                        borderSide: const BorderSide(
                                                                                          color: Color(0x00000000),
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      errorBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).error,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      focusedErrorBorder: OutlineInputBorder(
                                                                                        borderSide: BorderSide(
                                                                                          color: FlutterFlowTheme.of(context).error,
                                                                                          width: 1.0,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(6.0),
                                                                                      ),
                                                                                      filled: true,
                                                                                      fillColor: FlutterFlowTheme.of(context).customColor2,
                                                                                      hoverColor: Colors.transparent,
                                                                                      prefixIcon: Icon(
                                                                                        Icons.search_sharp,
                                                                                        color: FlutterFlowTheme.of(context).accent3,
                                                                                        size: 24.0,
                                                                                      ),
                                                                                      suffixIcon: _model.pesquisaDentroTextController!.text.isNotEmpty
                                                                                          ? InkWell(
                                                                                              onTap: () async {
                                                                                                _model.pesquisaDentroTextController?.clear();
                                                                                                safeSetState(() {});
                                                                                              },
                                                                                              child: const Icon(
                                                                                                Icons.clear,
                                                                                                size: 22,
                                                                                              ),
                                                                                            )
                                                                                          : null,
                                                                                    ),
                                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          fontSize: 16.0,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                                    validator: _model.pesquisaDentroTextControllerValidator.asValidator(context),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Builder(
                                                                              builder: (context) => FFButtonWidget(
                                                                                onPressed: () async {
                                                                                  // Save left-side global filter state
                                                                                  final savedSexo = FFAppState().filtroSexo;
                                                                                  final savedCategoria = FFAppState().filtroCategoria;
                                                                                  final savedRaca = FFAppState().filtroRaca;
                                                                                  final savedOrigem = FFAppState().filtroOrigem;
                                                                                  final savedStatus = FFAppState().filtroStatusRebanho;
                                                                                  final savedDataDe = FFAppState().filtroDataNacimentoDe;
                                                                                  final savedDataAte = FFAppState().filtroDataNacimentoAte;
                                                                                  final savedLoteId = FFAppState().filtroLoteId;
                                                                                  final savedLoteNome = FFAppState().filtroLoteNome;
                                                                                  // Pre-set global state with right-side values
                                                                                  FFAppState().filtroSexo = _model.filtroRightSexo;
                                                                                  FFAppState().filtroCategoria = _model.filtroRightCategoria;
                                                                                  FFAppState().filtroRaca = _model.filtroRightRaca;
                                                                                  FFAppState().filtroOrigem = _model.filtroRightOrigem;
                                                                                  FFAppState().filtroStatusRebanho = _model.filtroRightStatusRebanho;
                                                                                  FFAppState().filtroDataNacimentoDe = _model.filtroRightDataNacimentoDe;
                                                                                  FFAppState().filtroDataNacimentoAte = _model.filtroRightDataNacimentoAte;
                                                                                  FFAppState().filtroLoteId = _model.filtroRightLoteId;
                                                                                  FFAppState().filtroLoteNome = _model.filtroRightLoteNome;
                                                                                  await showDialog(
                                                                                    context: context,
                                                                                    builder: (dialogContext) {
                                                                                      return Dialog(
                                                                                        elevation: 0,
                                                                                        insetPadding: EdgeInsets.zero,
                                                                                        backgroundColor: Colors.transparent,
                                                                                        alignment: const AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                                        child: GestureDetector(
                                                                                          onTap: () {
                                                                                            FocusScope.of(dialogContext).unfocus();
                                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                                          },
                                                                                          child: const PpFiltroRebanhoWidget(),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                  // Capture new values into local right-side state
                                                                                  _model.filtroRightSexo = FFAppState().filtroSexo;
                                                                                  _model.filtroRightCategoria = FFAppState().filtroCategoria;
                                                                                  _model.filtroRightRaca = FFAppState().filtroRaca;
                                                                                  _model.filtroRightOrigem = FFAppState().filtroOrigem;
                                                                                  _model.filtroRightStatusRebanho = FFAppState().filtroStatusRebanho;
                                                                                  _model.filtroRightDataNacimentoDe = FFAppState().filtroDataNacimentoDe;
                                                                                  _model.filtroRightDataNacimentoAte = FFAppState().filtroDataNacimentoAte;
                                                                                  _model.filtroRightLoteId = FFAppState().filtroLoteId;
                                                                                  _model.filtroRightLoteNome = FFAppState().filtroLoteNome;
                                                                                  // Restore left-side global filter state
                                                                                  FFAppState().filtroSexo = savedSexo;
                                                                                  FFAppState().filtroCategoria = savedCategoria;
                                                                                  FFAppState().filtroRaca = savedRaca;
                                                                                  FFAppState().filtroOrigem = savedOrigem;
                                                                                  FFAppState().filtroStatusRebanho = savedStatus;
                                                                                  FFAppState().filtroDataNacimentoDe = savedDataDe;
                                                                                  FFAppState().filtroDataNacimentoAte = savedDataAte;
                                                                                  FFAppState().filtroLoteId = savedLoteId;
                                                                                  FFAppState().filtroLoteNome = savedLoteNome;
                                                                                  safeSetState(() {});
                                                                                },
                                                                                text: 'Filtrar',
                                                                                icon: const Icon(
                                                                                  Icons.filter_list,
                                                                                  size: 15.0,
                                                                                ),
                                                                                options: FFButtonOptions(
                                                                                  height: 40.0,
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  iconAlignment: IconAlignment.end,
                                                                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                  color: const Color(0x0028A365),
                                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).icon,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                      ),
                                                                                  elevation: 0.0,
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).customColor12,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Divider(
                                                                              height: 0.0,
                                                                              thickness: 1.0,
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                            if (responsiveVisibility(
                                                                              context: context,
                                                                              phone: false,
                                                                              tablet: false,
                                                                              tabletLandscape: false,
                                                                              desktop: false,
                                                                            ))
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: 40.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                  border: Border.all(
                                                                                    color: FlutterFlowTheme.of(context).customColor12,
                                                                                  ),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.arrow_upward_rounded,
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            size: 14.0,
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.arrow_downward_rounded,
                                                                                            color: FlutterFlowTheme.of(context).accent3,
                                                                                            size: 14.0,
                                                                                          ),
                                                                                          Text(
                                                                                            'Crescente',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          ),
                                                                                        ].divide(const SizedBox(width: 8.0)),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 24.0,
                                                                                        child: VerticalDivider(
                                                                                          thickness: 2.0,
                                                                                          color: FlutterFlowTheme.of(context).tertiary,
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Alfabética',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  color: FlutterFlowTheme.of(context).secondary,
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.keyboard_arrow_down_sharp,
                                                                                            color: FlutterFlowTheme.of(context).secondary,
                                                                                            size: 24.0,
                                                                                          ),
                                                                                        ].divide(const SizedBox(width: 8.0)),
                                                                                      ),
                                                                                    ].divide(const SizedBox(width: 8.0)),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                if (_model.animaisDentroLote.isNotEmpty)
                                                                                  FFButtonWidget(
                                                                                    onPressed: () async {
                                                                                      var confirmDialogResponse = await showDialog<bool>(
                                                                                            context: context,
                                                                                            builder: (alertDialogContext) {
                                                                                              return AlertDialog(
                                                                                                content: const Text('Deseja  realmente remover todos os animais do lote?'),
                                                                                                actions: [
                                                                                                  TextButton(
                                                                                                    onPressed: () => Navigator.pop(alertDialogContext, false),
                                                                                                    child: const Text('Não'),
                                                                                                  ),
                                                                                                  TextButton(
                                                                                                    onPressed: () => Navigator.pop(alertDialogContext, true),
                                                                                                    child: const Text('Sim'),
                                                                                                  ),
                                                                                                ],
                                                                                              );
                                                                                            },
                                                                                          ) ??
                                                                                          false;
                                                                                      if (confirmDialogResponse) {
                                                                                        _model.index = 0;
                                                                                        safeSetState(() {});
                                                                                        while (_model.index < _model.animaisDentroLote.length) {
                                                                                          if ((_model.animaisDentroLote.elementAtOrNull(_model.index)?.loteNome != null && _model.animaisDentroLote.elementAtOrNull(_model.index)?.loteNome != '') && (_model.animaisDentroLote.elementAtOrNull(_model.index)?.loteNome != 'null') && (_model.animaisDentroLote.elementAtOrNull(_model.index)?.loteNome == containerLotesRow?.nome)) {
                                                                                            _model.addToAnimaisRetiradosLote(_model.animaisDentroLote.elementAtOrNull(_model.index)!);
                                                                                            safeSetState(() {});
                                                                                          }
                                                                                          _model.removeFromAnimaisDentroLote(_model.animaisDentroLote.elementAtOrNull(_model.index)!);
                                                                                          safeSetState(() {});
                                                                                          _model.index = _model.index + 1;
                                                                                          safeSetState(() {});
                                                                                        }
                                                                                        _model.animaisDentroLote = [];
                                                                                        _model.animaisSelecionados = [];
                                                                                        safeSetState(() {});
                                                                                      }
                                                                                      _model.index = 0;
                                                                                      safeSetState(() {});
                                                                                    },
                                                                                    text: 'Remover Todos',
                                                                                    options: FFButtonOptions(
                                                                                      height: 40.0,
                                                                                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                      color: FlutterFlowTheme.of(context).error,
                                                                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                            color: Colors.white,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                          ),
                                                                                      elevation: 0.0,
                                                                                      borderRadius: BorderRadius.circular(8.0),
                                                                                    ),
                                                                                  ),
                                                                              ].divide(const SizedBox(width: 8.0)),
                                                                            ),
                                                                            Flexible(
                                                                              child: Builder(
                                                                                builder: (context) {
                                                                                  final animais = _model.animaisDentroLote.where((e) => ((_model.pesquisaDentroTextController.text == '') && (_model.filtroRightCategoria == '') && (_model.filtroRightSexo == '') && (_model.filtroRightRaca == '') && (_model.filtroRightOrigem == '') && (_model.filtroRightStatusRebanho == '') && (_model.filtroRightDataNacimentoDe == null) && (_model.filtroRightDataNacimentoAte == null) && (_model.filtroRightLoteNome == '')) || ((e.numeroAnimal.trim().toLowerCase().contains(_model.pesquisaDentroTextController.text.trim().toLowerCase())) && ((_model.filtroRightSexo == '') || (e.sexo == _model.filtroRightSexo)) && ((_model.filtroRightCategoria == '') || (e.categoria == _model.filtroRightCategoria)) && ((_model.filtroRightRaca == '') || (e.raca == _model.filtroRightRaca)) && ((_model.filtroRightOrigem == '') || (e.origem == _model.filtroRightOrigem)) && ((_model.filtroRightStatusRebanho == '') || (e.status == _model.filtroRightStatusRebanho)) && ((_model.filtroRightDataNacimentoDe == null) || (functions.converterParaData(e.dataNascimento) != null && !functions.converterParaData(e.dataNascimento)!.isBefore(_model.filtroRightDataNacimentoDe!))) && ((_model.filtroRightDataNacimentoAte == null) || (functions.converterParaData(e.dataNascimento) != null && !functions.converterParaData(e.dataNascimento)!.isAfter(_model.filtroRightDataNacimentoAte!))) && ((_model.filtroRightLoteNome == '') || (e.loteNome == _model.filtroRightLoteNome)))).toList().take(_model.mostrarAdicionados).toList();

                                                                                  return ListView.builder(
                                                                                    padding: EdgeInsets.zero,
                                                                                    shrinkWrap: true,
                                                                                    scrollDirection: Axis.vertical,
                                                                                    itemCount: animais.length,
                                                                                    itemBuilder: (context, animaisIndex) {
                                                                                      final animaisItem = animais[animaisIndex];
                                                                                      return Column(
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                InkWell(
                                                                                                  splashColor: Colors.transparent,
                                                                                                  focusColor: Colors.transparent,
                                                                                                  hoverColor: Colors.transparent,
                                                                                                  highlightColor: Colors.transparent,
                                                                                                  onTap: () async {
                                                                                                    var confirmDialogResponse = await showDialog<bool>(
                                                                                                          context: context,
                                                                                                          builder: (alertDialogContext) {
                                                                                                            return AlertDialog(
                                                                                                              content: const Text('Deseja remover este animal do lote?'),
                                                                                                              actions: [
                                                                                                                TextButton(
                                                                                                                  onPressed: () => Navigator.pop(alertDialogContext, false),
                                                                                                                  child: const Text('Não'),
                                                                                                                ),
                                                                                                                TextButton(
                                                                                                                  onPressed: () => Navigator.pop(alertDialogContext, true),
                                                                                                                  child: const Text('Sim'),
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                        ) ??
                                                                                                        false;
                                                                                                    if (confirmDialogResponse) {
                                                                                                      if ((animaisItem.loteNome != '') && (animaisItem.loteNome != 'null') && (animaisItem.loteNome == containerLotesRow?.nome)) {
                                                                                                        _model.addToAnimaisRetiradosLote(animaisItem);
                                                                                                        safeSetState(() {});
                                                                                                      }
                                                                                                      _model.removeFromAnimaisSelecionados(animaisItem);
                                                                                                      safeSetState(() {});
                                                                                                      _model.removeFromAnimaisDentroLote(animaisItem);
                                                                                                      safeSetState(() {});
                                                                                                    }
                                                                                                  },
                                                                                                  child: Icon(
                                                                                                    Icons.check_box_rounded,
                                                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                                                    size: 24.0,
                                                                                                  ),
                                                                                                ),
                                                                                                Flexible(
                                                                                                  child: Column(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                                        children: [
                                                                                                          ClipRRect(
                                                                                                            borderRadius: BorderRadius.circular(0.0),
                                                                                                            child: Image.asset(
                                                                                                              'assets/images/Group_11_3_(1).png',
                                                                                                              width: 24.0,
                                                                                                              height: 24.0,
                                                                                                              fit: BoxFit.contain,
                                                                                                            ),
                                                                                                          ),
                                                                                                          if (animaisItem.sexo == 'Macho')
                                                                                                            ClipRRect(
                                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/Sexomacho.png',
                                                                                                                width: 24.0,
                                                                                                                height: 24.0,
                                                                                                                fit: BoxFit.cover,
                                                                                                              ),
                                                                                                            ),
                                                                                                          if (animaisItem.sexo == 'Fêmea')
                                                                                                            ClipRRect(
                                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/Sexofemea.png',
                                                                                                                width: 24.0,
                                                                                                                height: 24.0,
                                                                                                                fit: BoxFit.cover,
                                                                                                              ),
                                                                                                            ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      Text(
                                                                                                        '${valueOrDefault<String>(
                                                                                                          animaisItem.numeroAnimal,
                                                                                                          '0000',
                                                                                                        )} • ${valueOrDefault<String>(
                                                                                                              animaisItem.nome,
                                                                                                              'S/N',
                                                                                                            ) == 'null' ? 'S/N' : valueOrDefault<String>(
                                                                                                            animaisItem.nome,
                                                                                                            'S/N',
                                                                                                          )} • ${dateTimeFormat(
                                                                                                          "d/M/y",
                                                                                                          functions.converterParaData(animaisItem.dataNascimento),
                                                                                                          locale: FFLocalizations.of(context).languageCode,
                                                                                                        )}',
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.poppins(
                                                                                                                fontWeight: FontWeight.w500,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              fontSize: 16.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        '${valueOrDefault<String>(
                                                                                                          animaisItem.categoria,
                                                                                                          'S/C',
                                                                                                        )} • ${valueOrDefault<String>(
                                                                                                          animaisItem.raca,
                                                                                                          'S/R',
                                                                                                        )}',
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.poppins(
                                                                                                                fontWeight: FontWeight.normal,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              color: FlutterFlowTheme.of(context).customColor6,
                                                                                                              fontSize: 14.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FontWeight.normal,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                      ),
                                                                                                      if (animaisItem.loteID != 'null')
                                                                                                        Row(
                                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                                          children: [
                                                                                                            ClipRRect(
                                                                                                              borderRadius: BorderRadius.circular(0.0),
                                                                                                              child: Image.asset(
                                                                                                                'assets/images/Lotes4343434.png',
                                                                                                                width: 24.0,
                                                                                                                height: 24.0,
                                                                                                                fit: BoxFit.contain,
                                                                                                              ),
                                                                                                            ),
                                                                                                            Flexible(
                                                                                                              child: Text(
                                                                                                                valueOrDefault<String>(
                                                                                                                          animaisItem.loteNome,
                                                                                                                          'S/L',
                                                                                                                        ) ==
                                                                                                                        'null'
                                                                                                                    ? 'S/L'
                                                                                                                    : valueOrDefault<String>(
                                                                                                                        animaisItem.loteNome,
                                                                                                                        'S/L',
                                                                                                                      ),
                                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                      font: GoogleFonts.poppins(
                                                                                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                      ),
                                                                                                                      letterSpacing: 0.0,
                                                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                    ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ].divide(const SizedBox(width: 8.0)),
                                                                                                        ),
                                                                                                    ].divide(const SizedBox(height: 8.0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ].divide(const SizedBox(width: 16.0)),
                                                                                            ),
                                                                                          ),
                                                                                          Divider(
                                                                                            height: 0.0,
                                                                                            thickness: 1.0,
                                                                                            color: FlutterFlowTheme.of(context).customColor5,
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                if (_model.mostrarAdicionados > 20)
                                                                                  InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      _model.mostrarAdicionados = _model.mostrarAdicionados + -5;
                                                                                      safeSetState(() {});
                                                                                    },
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Mostrar menos',
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.keyboard_arrow_up,
                                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                                          size: 24.0,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                if (_model.mostrarAdicionados < _model.animaisDentroLote.length)
                                                                                  InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      _model.mostrarAdicionados = _model.mostrarAdicionados + 5;
                                                                                      safeSetState(() {});
                                                                                    },
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Mostrar mais',
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).secondary,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                        Icon(
                                                                                          Icons.keyboard_arrow_down_outlined,
                                                                                          color: FlutterFlowTheme.of(context).secondary,
                                                                                          size: 24.0,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ].divide(const SizedBox(height: 16.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_model.tabBarCurrentIndex !=
                                                    3)
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      FFButtonWidget(
                                                        onPressed: () async {
                                                          _model.animaisDentroLote =
                                                              [];
                                                          _model.animaisSelecionados =
                                                              [];
                                                          _model.index = 0;
                                                          safeSetState(() {});

                                                          context.pushNamed(
                                                              PgLotesWidget
                                                                  .routeName);
                                                        },
                                                        text: 'Cancelar',
                                                        options:
                                                            FFButtonOptions(
                                                          width: 160.0,
                                                          height: 56.0,
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
                                                          iconPadding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          color: Colors.white,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: const Color(
                                                                        0xFF28A365),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                      FFButtonWidget(
                                                        onPressed: () async {
                                                          _model.index = 0;
                                                          safeSetState(() {});
                                                          // Primeiro remove do lote os animais retirados (para não incluí-los na atualização em massa)
                                                          if (_model
                                                              .animaisRetiradosLote
                                                              .isNotEmpty) {
                                                            while (_model
                                                                    .index <
                                                                _model
                                                                    .animaisRetiradosLote
                                                                    .length) {
                                                              await RebanhoTable()
                                                                  .update(
                                                                data: {
                                                                  'loteID':
                                                                      'null',
                                                                  'loteNome':
                                                                      'null',
                                                                  'updated_at':
                                                                      supaSerialize<
                                                                              DateTime>(
                                                                          getCurrentTimestamp),
                                                                },
                                                                matchingRows:
                                                                    (rows) => rows
                                                                        .eqOrNull(
                                                                  'idRebanho',
                                                                  _model
                                                                      .animaisRetiradosLote
                                                                      .elementAtOrNull(
                                                                          _model
                                                                              .index)
                                                                      ?.idRebanho,
                                                                ),
                                                              );
                                                              _model.index =
                                                                  _model.index +
                                                                      1;
                                                              safeSetState(
                                                                  () {});
                                                            }
                                                            _model.index = 0;
                                                            safeSetState(() {});
                                                          }
                                                          // Atualiza cada animal listado no lote (inclui os vindos de outro lote),
                                                          // para que nome/status/venda fiquem consistentes ao salvar.
                                                          final animaisRetiradosIds = _model
                                                              .animaisRetiradosLote
                                                              .map((e) => e
                                                                  .idRebanho
                                                                  .trim())
                                                              .where((e) =>
                                                                  e.isNotEmpty)
                                                              .toSet();
                                                          final animaisParaAtualizar =
                                                              <RebanhoDTStruct>[];
                                                          final animaisIdsSeen =
                                                              <String>{};
                                                          void addAnimalParaAtualizar(
                                                              RebanhoDTStruct
                                                                  animal) {
                                                            final id = animal
                                                                .idRebanho
                                                                .trim();
                                                            if (id.isEmpty ||
                                                                animaisRetiradosIds
                                                                    .contains(
                                                                        id) ||
                                                                !animaisIdsSeen
                                                                    .add(id)) {
                                                              return;
                                                            }
                                                            animaisParaAtualizar
                                                                .add(animal);
                                                          }

                                                          for (final animal
                                                              in _model
                                                                  .animaisDentroLote) {
                                                            addAnimalParaAtualizar(
                                                                animal);
                                                          }
                                                          final animaisCarregados =
                                                              await _loadAnimaisDoLoteParaEdicao();
                                                          for (final animal
                                                              in animaisCarregados) {
                                                            addAnimalParaAtualizar(
                                                                animal);
                                                          }

                                                          final novoLoteNome = _model
                                                                  .nomeLoteTextController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? _model
                                                                  .nomeLoteTextController
                                                                  .text
                                                              : containerLotesRow
                                                                      ?.nome ??
                                                                  widget
                                                                      .loteNome;
                                                          await SupaFlow.client
                                                              .rpc(
                                                            'salvar_lote_status_e_sincronizar_animais',
                                                            params: {
                                                              'p_id_propriedade':
                                                                  containerLotesRow
                                                                          ?.idPropriedade ??
                                                                      FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                              'p_id_lote':
                                                                  containerLotesRow
                                                                          ?.idLote ??
                                                                      widget
                                                                          .idLote,
                                                              'p_nome':
                                                                  novoLoteNome,
                                                              'p_anotacoes': _model
                                                                          .anotacoesTextController
                                                                          .text !=
                                                                      ''
                                                                  ? _model
                                                                      .anotacoesTextController
                                                                      .text
                                                                  : _model
                                                                      .loteEdit
                                                                      ?.firstOrNull
                                                                      ?.anotacoes,
                                                              'p_ativo':
                                                                  _model.switchValue ==
                                                                          true
                                                                      ? 'Ativo'
                                                                      : 'Inativo',
                                                              'p_motivo': _model
                                                                          .switchValue ==
                                                                      true
                                                                  ? null
                                                                  : _model
                                                                          .motivoCleared
                                                                      ? null
                                                                      : (_model
                                                                              .dropDownLotesValue ??
                                                                          containerLotesRow
                                                                              ?.motivo),
                                                              'p_data_motivo': _model
                                                                          .switchValue ==
                                                                      true
                                                                  ? null
                                                                  : _model
                                                                          .dataMotivoCleared
                                                                      ? null
                                                                      : supaSerialize<
                                                                          DateTime>(_model
                                                                              .datePicked ??
                                                                          containerLotesRow
                                                                              ?.dataMotivo),
                                                              'p_valor_venda': _model
                                                                          .switchValue ==
                                                                      true
                                                                  ? null
                                                                  : FFAppState()
                                                                      .valueDouble2,
                                                              'p_id_animais': functions.converterListaParaJSON(animaisParaAtualizar
                                                                  .map((e) => e
                                                                      .idRebanho)
                                                                  .where((e) => e
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                  .toList()),
                                                            },
                                                          );
                                                          _model.animaisDentroLote =
                                                              [];
                                                          _model.animaisSelecionados =
                                                              [];
                                                          _model.animaisRetiradosLote =
                                                              [];
                                                          safeSetState(() {});
                                                          FFAppState()
                                                                  .refreshLotes =
                                                              true;
                                                          safeSetState(() {});
                                                          unawaited(
                                                            () async {
                                                              await action_blocks
                                                                  .countLotes(
                                                                      context);
                                                            }(),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Lote atualizado com sucesso',
                                                                style:
                                                                    TextStyle(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          4000),
                                                              backgroundColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                            ),
                                                          );

                                                          context.pushNamed(
                                                              PgLotesWidget
                                                                  .routeName);
                                                        },
                                                        text: 'Salvar',
                                                        options:
                                                            FFButtonOptions(
                                                          width: 160.0,
                                                          height: 56.0,
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
                                                          iconPadding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                      ),
                                                    ].divide(const SizedBox(
                                                        width: 24.0)),
                                                  ),
                                              ].divide(
                                                  const SizedBox(height: 24.0)),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
