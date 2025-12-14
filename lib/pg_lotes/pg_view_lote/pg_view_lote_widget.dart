import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/pg_rebanho/modal_more/modal_more_widget.dart';
import '/pg_rebanho/pp_filtro_rebanho/pp_filtro_rebanho_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_view_lote_model.dart';
export 'pg_view_lote_model.dart';

class PgViewLoteWidget extends StatefulWidget {
  const PgViewLoteWidget({
    super.key,
    required this.loteNome,
  });

  final String? loteNome;

  static String routeName = 'pgViewLote';
  static String routePath = '/viewlote';

  @override
  State<PgViewLoteWidget> createState() => _PgViewLoteWidgetState();
}

class _PgViewLoteWidgetState extends State<PgViewLoteWidget>
    with TickerProviderStateMixin {
  late PgViewLoteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgViewLoteModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.lote = await LotesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id_lote',
          widget.loteNome,
        ),
      );
      if (_model.lote?.firstOrNull?.ativo == 'Ativo') {
        _model.ativo = true;
        safeSetState(() {});
      } else {
        _model.ativo = false;
        safeSetState(() {});
      }
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.nomeLoteFocusNode ??= FocusNode();

    _model.anotacoesFocusNode ??= FocusNode();

    _model.dataEntradaLoteTextController ??= TextEditingController();
    _model.dataEntradaLoteFocusNode ??= FocusNode();

    _model.pesquisaTextController ??= TextEditingController();
    _model.pesquisaFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.dataEntradaLoteTextController?.text = dateTimeFormat(
            "d/M/y",
            _model.lote?.firstOrNull?.dataMotivo,
            locale: FFLocalizations.of(context).languageCode,
          );
        }));
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
              pDataNascimento: dateTimeFormat(
                "yyyy-MM-dd",
                FFAppState().filtroDataNacimento,
                locale: FFLocalizations.of(context).languageCode,
              ),
              pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
              pLoteNome: widget.loteNome,
              pOrigem: FFAppState().filtroOrigem,
              pRaca: FFAppState().filtroRaca,
              pSexo: FFAppState().filtroSexo,
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
        final pgViewLoteBuscarRebanhoFiltrosResponse = snapshot.data!;

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
                        queryFn: (q) => q.eqOrNull(
                          'nome',
                          widget.loteNome,
                        ),
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
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Container(
                                    width: 920.0,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Lote',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent3,
                                                                fontSize: 18.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                    Text(
                                                      valueOrDefault<String>(
                                                        containerLotesRow?.nome,
                                                        'Nome lote',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            fontSize: 32.0,
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
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: containerLotesRow
                                                              ?.ativo ==
                                                          'Ativo'
                                                      ? const Color(0xFFD6F5E5)
                                                      : const Color(0xFFF5D7D4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 2.0, 8.0, 2.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        containerLotesRow
                                                                    ?.ativo ==
                                                                'Ativo'
                                                            ? 'Ativo'
                                                            : 'Inativo',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: containerLotesRow
                                                                              ?.ativo ==
                                                                          'Ativo'
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary
                                                                      : const Color(
                                                                          0xFFCC3729),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        const SizedBox(width: 8.0)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: const Alignment(0.0, 0),
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
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
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
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
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
                                                        text: 'Informações',
                                                      ),
                                                      Tab(
                                                        text: 'Animais',
                                                      ),
                                                    ],
                                                    controller:
                                                        _model.tabBarController,
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
                                                    controller:
                                                        _model.tabBarController,
                                                    children: [
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Flexible(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Nome do lote*',
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.nomeLoteTextController ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              containerLotesRow?.nome,
                                                                        ),
                                                                        focusNode:
                                                                            _model.nomeLoteFocusNode,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              containerLotesRow?.nome,
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
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
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
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
                                                                            .nomeLoteTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ].divide(const SizedBox(
                                                                  width: 24.0)),
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
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                                Container(
                                                                  height: 100.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFF1F1F1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model.anotacoesTextController ??=
                                                                            TextEditingController(
                                                                      text: containerLotesRow
                                                                          ?.anotacoes,
                                                                    ),
                                                                    focusNode:
                                                                        _model
                                                                            .anotacoesFocusNode,
                                                                    autofocus:
                                                                        false,
                                                                    readOnly:
                                                                        true,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      isDense:
                                                                          false,
                                                                      labelStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          containerLotesRow
                                                                              ?.anotacoes,
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                const Color(0xFFBEBEBE),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedErrorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    validator: _model
                                                                        .anotacoesTextControllerValidator
                                                                        .asValidator(
                                                                            context),
                                                                  ),
                                                                ),
                                                              ].divide(const SizedBox(
                                                                  height: 8.0)),
                                                            ),
                                                            Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 80.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    blurRadius:
                                                                        1.0,
                                                                    color: Color(
                                                                        0x1A000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6.0),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor12,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                            24.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Este lote está ativo?',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                    Switch
                                                                        .adaptive(
                                                                      value: _model
                                                                          .switchValue ??= containerLotesRow?.ativo ==
                                                                              'Ativo'
                                                                          ? true
                                                                          : false,
                                                                      onChanged: (containerLotesRow?.ativo == 'Ativo'
                                                                              ? true
                                                                              : false)
                                                                          ? null
                                                                          : (newValue) async {
                                                                              safeSetState(() => _model.switchValue = newValue);
                                                                            },
                                                                      activeColor: (containerLotesRow?.ativo == 'Ativo'
                                                                              ? true
                                                                              : false)
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .tertiary
                                                                          : FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                      activeTrackColor: (containerLotesRow?.ativo == 'Ativo'
                                                                              ? true
                                                                              : false)
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .primary
                                                                          : FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                      inactiveTrackColor: (containerLotesRow?.ativo == 'Ativo'
                                                                              ? true
                                                                              : false)
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .tertiary
                                                                          : FlutterFlowTheme.of(context)
                                                                              .alternate,
                                                                      inactiveThumbColor: (containerLotesRow?.ativo == 'Ativo'
                                                                              ? true
                                                                              : false)
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondaryBackground
                                                                          : FlutterFlowTheme.of(context)
                                                                              .secondaryBackground,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            if (containerLotesRow
                                                                    ?.ativo ==
                                                                'Inativo')
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Motivo',
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
                                                                        FlutterFlowDropDown<
                                                                            String>(
                                                                          controller: _model.dropDownLotesValueController ??=
                                                                              FormFieldController<String>(
                                                                            _model.dropDownLotesValue ??=
                                                                                _model.lote?.firstOrNull?.motivo,
                                                                          ),
                                                                          options: const [
                                                                            'Lote vendido'
                                                                          ],
                                                                          onChanged: (val) =>
                                                                              safeSetState(() => _model.dropDownLotesValue = val),
                                                                          height:
                                                                              56.0,
                                                                          textStyle: FlutterFlowTheme.of(context)
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
                                                                          hintText:
                                                                              'Selecionar',
                                                                          icon:
                                                                              Icon(
                                                                            Icons.keyboard_arrow_down_rounded,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            size:
                                                                                24.0,
                                                                          ),
                                                                          fillColor:
                                                                              const Color(0xFFF1F1F1),
                                                                          elevation:
                                                                              2.0,
                                                                          borderColor:
                                                                              Colors.transparent,
                                                                          borderWidth:
                                                                              0.0,
                                                                          borderRadius:
                                                                              8.0,
                                                                          margin: const EdgeInsetsDirectional.fromSTEB(
                                                                              12.0,
                                                                              0.0,
                                                                              12.0,
                                                                              0.0),
                                                                          hidesUnderline:
                                                                              true,
                                                                          isOverButton:
                                                                              false,
                                                                          isSearchable:
                                                                              false,
                                                                          isMultiSelect:
                                                                              false,
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Data',
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
                                                                        Stack(
                                                                          children: [
                                                                            TextFormField(
                                                                              controller: _model.dataEntradaLoteTextController,
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
                                                                                hintText: dateTimeFormat(
                                                                                  "d/M/y",
                                                                                  _model.lote?.firstOrNull?.dataMotivo,
                                                                                  locale: FFLocalizations.of(context).languageCode,
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
                                                                              maxLines: null,
                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                              validator: _model.dataEntradaLoteTextControllerValidator.asValidator(context),
                                                                            ),
                                                                            Container(
                                                                              width: double.infinity,
                                                                              height: 50.0,
                                                                              decoration: const BoxDecoration(),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Valor da venda (R\$)',
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
                                                                              56.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                const AlignmentDirectional(0.0, 0.0),
                                                                            child:
                                                                                SizedBox(
                                                                              width: double.infinity,
                                                                              height: 60.0,
                                                                              child: custom_widgets.CurrencyInputBR(
                                                                                width: double.infinity,
                                                                                height: 60.0,
                                                                                initialValue: _model.lote?.firstOrNull?.valorVenda,
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
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ].divide(const SizedBox(
                                                                    width:
                                                                        24.0)),
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
                                                                    color: Color(
                                                                        0x1A000000),
                                                                    offset:
                                                                        Offset(
                                                                      0.0,
                                                                      2.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6.0),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor12,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                            24.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Animais neste lote (${valueOrDefault<String>(
                                                                            (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.length.toString(),
                                                                            '0',
                                                                          )})',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          focusColor:
                                                                              Colors.transparent,
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap:
                                                                              () async {
                                                                            safeSetState(() {
                                                                              _model.tabBarController!.animateTo(
                                                                                min(_model.tabBarController!.length - 1, _model.tabBarController!.index + 1),
                                                                                duration: const Duration(milliseconds: 300),
                                                                                curve: Curves.ease,
                                                                              );
                                                                            });
                                                                          },
                                                                          child:
                                                                              Text(
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
                                                                    if ((pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList()
                                                                                as Iterable<RebanhoDTStruct?>)
                                                                            .withoutNulls.isEmpty)
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          safeSetState(
                                                                              () {
                                                                            _model.tabBarController!.animateTo(
                                                                              min(_model.tabBarController!.length - 1, _model.tabBarController!.index + 1),
                                                                              duration: const Duration(milliseconds: 300),
                                                                              curve: Curves.ease,
                                                                            );
                                                                          });
                                                                        },
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
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
                                                                    Container(
                                                                      child:
                                                                          Builder(
                                                                        builder:
                                                                            (context) {
                                                                          final animais =
                                                                              (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.take(3).toList().toList() ?? [];

                                                                          return ListView
                                                                              .builder(
                                                                            padding:
                                                                                EdgeInsets.zero,
                                                                            primary:
                                                                                false,
                                                                            shrinkWrap:
                                                                                true,
                                                                            scrollDirection:
                                                                                Axis.vertical,
                                                                            itemCount:
                                                                                animais.length,
                                                                            itemBuilder:
                                                                                (context, animaisIndex) {
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
                                                                  ].divide(const SizedBox(
                                                                      height:
                                                                          16.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          ]
                                                              .divide(const SizedBox(
                                                                  height: 24.0))
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
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              if ((pgViewLoteBuscarRebanhoFiltrosResponse
                                                                          .jsonBody
                                                                          .toList()
                                                                          .map<RebanhoDTStruct?>(
                                                                              RebanhoDTStruct.maybeFromMap)
                                                                          .toList() as Iterable<RebanhoDTStruct?>)
                                                                      .withoutNulls.isNotEmpty)
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            168.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                              blurRadius: 4.0,
                                                                              color: Color(0x33000000),
                                                                              offset: Offset(
                                                                                0.0,
                                                                                2.0,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).customColor5,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Unidade Animal (UA)',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      fontSize: 18.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              Text(
                                                                                valueOrDefault<String>(
                                                                                  formatNumber(
                                                                                    valueOrDefault<double>(
                                                                                          functions.somarTotal((pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>)
                                                                                              .withoutNulls
                                                                                              .map((e) => valueOrDefault<double>(
                                                                                                    e.pesoAtual,
                                                                                                    0.0,
                                                                                                  ))
                                                                                              .toList()),
                                                                                          0.0,
                                                                                        ) /
                                                                                        450.ceil(),
                                                                                    formatType: FormatType.compact,
                                                                                  ),
                                                                                  '0',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      fontSize: 32.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            168.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                              blurRadius: 4.0,
                                                                              color: Color(0x33000000),
                                                                              offset: Offset(
                                                                                0.0,
                                                                                2.0,
                                                                              ),
                                                                            )
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).customColor5,
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Peso médio (kg)',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      fontSize: 18.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              Text(
                                                                                valueOrDefault<String>(
                                                                                  formatNumber(
                                                                                    valueOrDefault<double>(
                                                                                          functions.somarTotal((pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>)
                                                                                              .withoutNulls
                                                                                              .map((e) => valueOrDefault<double>(
                                                                                                    e.pesoAtual,
                                                                                                    0.0,
                                                                                                  ))
                                                                                              .toList()),
                                                                                          0.0,
                                                                                        ) /
                                                                                        valueOrDefault<int>(
                                                                                          (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.length,
                                                                                          0,
                                                                                        ),
                                                                                    formatType: FormatType.compact,
                                                                                  ),
                                                                                  '0',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      fontSize: 32.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ].divide(const SizedBox(
                                                                      width:
                                                                          32.0)),
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
                                                                          4.0,
                                                                      color: Color(
                                                                          0x33000000),
                                                                      offset:
                                                                          Offset(
                                                                        0.0,
                                                                        2.0,
                                                                      ),
                                                                    )
                                                                  ],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6.0),
                                                                  border: Border
                                                                      .all(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor5,
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                              24.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Total de animais neste lote por categoria',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                              fontSize: 18.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            42.0,
                                                                            0.0,
                                                                            42.0),
                                                                        child:
                                                                            Text(
                                                                          'Total: ${valueOrDefault<String>(
                                                                            (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.length.toString(),
                                                                            '0',
                                                                          )} animais',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children:
                                                                            [
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 130.0,
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Vaca Multípara',
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
                                                                                    valueOrDefault<String>(
                                                                                      (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Vaca Multipara').toList().length.toString(),
                                                                                      '0',
                                                                                    ),
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
                                                                                ].divide(const SizedBox(height: 8.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 130.0,
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Vaca Primípara',
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
                                                                                    valueOrDefault<String>(
                                                                                      (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Vaca Primipara').toList().length.toString(),
                                                                                      '0',
                                                                                    ),
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
                                                                                ].divide(const SizedBox(height: 8.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 130.0,
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Bezerro',
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
                                                                                    valueOrDefault<String>(
                                                                                      (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Bezerro').toList().length.toString(),
                                                                                      '0',
                                                                                    ),
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
                                                                                ].divide(const SizedBox(height: 8.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 130.0,
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Bezerra',
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
                                                                                    valueOrDefault<String>(
                                                                                      (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Bezerra').toList().length.toString(),
                                                                                      '0',
                                                                                    ),
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
                                                                                ].divide(const SizedBox(height: 8.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            child:
                                                                                Container(
                                                                              width: 130.0,
                                                                              decoration: const BoxDecoration(),
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Boi gordo',
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
                                                                                    valueOrDefault<String>(
                                                                                      (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Boi Gordo').toList().length.toString(),
                                                                                      '0',
                                                                                    ),
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
                                                                                ].divide(const SizedBox(height: 8.0)),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ].divide(const SizedBox(width: 24.0)),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            24.0,
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children:
                                                                              [
                                                                            Flexible(
                                                                              child: Container(
                                                                                width: 130.0,
                                                                                decoration: const BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Garrote',
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
                                                                                      valueOrDefault<String>(
                                                                                        (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Garrote').toList().length.toString(),
                                                                                        '0',
                                                                                      ),
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
                                                                                  ].divide(const SizedBox(height: 8.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Container(
                                                                                width: 130.0,
                                                                                decoration: const BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Touro',
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
                                                                                      valueOrDefault<String>(
                                                                                        (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Touro').toList().length.toString(),
                                                                                        '0',
                                                                                      ),
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
                                                                                  ].divide(const SizedBox(height: 8.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Container(
                                                                                width: 130.0,
                                                                                decoration: const BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Novilha',
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
                                                                                      valueOrDefault<String>(
                                                                                        (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Novilha').toList().length.toString(),
                                                                                        '0',
                                                                                      ),
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
                                                                                  ].divide(const SizedBox(height: 8.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Container(
                                                                                width: 130.0,
                                                                                decoration: const BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Boi Magro',
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
                                                                                      valueOrDefault<String>(
                                                                                        (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Boi Magro').toList().length.toString(),
                                                                                        '0',
                                                                                      ),
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
                                                                                  ].divide(const SizedBox(height: 8.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Flexible(
                                                                              child: Container(
                                                                                width: 130.0,
                                                                                decoration: const BoxDecoration(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      'Rufião',
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
                                                                                      valueOrDefault<String>(
                                                                                        (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => e.categoria == 'Rufião').toList().length.toString(),
                                                                                        '0',
                                                                                      ),
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
                                                                                  ].divide(const SizedBox(height: 8.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ].divide(const SizedBox(width: 24.0)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            2.0),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        blurRadius:
                                                                            2.0,
                                                                        color: Color(
                                                                            0x19000000),
                                                                        offset:
                                                                            Offset(
                                                                          2.0,
                                                                          4.0,
                                                                        ),
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor12,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            24.0),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
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
                                                                                (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.length.toString(),
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
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Container(
                                                                                  height: 56.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).customColor2,
                                                                                    borderRadius: BorderRadius.circular(6.0),
                                                                                  ),
                                                                                  child: Align(
                                                                                    alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                    child: SizedBox(
                                                                                      width: 216.0,
                                                                                      child: TextFormField(
                                                                                        controller: _model.pesquisaTextController,
                                                                                        focusNode: _model.pesquisaFocusNode,
                                                                                        onChanged: (_) => EasyDebounce.debounce(
                                                                                          '_model.pesquisaTextController',
                                                                                          const Duration(milliseconds: 250),
                                                                                          () async {
                                                                                            safeSetState(() => _model.apiRequestCompleter = null);
                                                                                            await _model.waitForApiRequestCompleted();
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
                                                                                                    await _model.waitForApiRequestCompleted();
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
                                                                                    },
                                                                                    text: 'Filtrar',
                                                                                    icon: const Icon(
                                                                                      Icons.filter_list,
                                                                                      size: 24.0,
                                                                                    ),
                                                                                    options: FFButtonOptions(
                                                                                      height: 56.0,
                                                                                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                            ),
                                                                                            color: FlutterFlowTheme.of(context).secondary,
                                                                                            fontSize: 18.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                          ),
                                                                                      elevation: 0.0,
                                                                                      borderSide: BorderSide(
                                                                                        color: FlutterFlowTheme.of(context).secondary,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ].divide(const SizedBox(width: 8.0)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Container(
                                                                          decoration:
                                                                              const BoxDecoration(),
                                                                          child:
                                                                              Builder(
                                                                            builder:
                                                                                (context) {
                                                                              final rebanhos = (pgViewLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.toList() ?? [];
                                                                              if (rebanhos.isEmpty) {
                                                                                return const Center(
                                                                                  child: EmptyWidget(),
                                                                                );
                                                                              }

                                                                              return FlutterFlowDataTable<RebanhoDTStruct>(
                                                                                controller: _model.paginatedDataTableController,
                                                                                data: rebanhos,
                                                                                columnsBuilder: (onSortChanged) => [
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Número',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 80.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Nome',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Sexo',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Nascimento',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Status',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 110.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Categoria',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Raça',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        ' ',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 60.0,
                                                                                  ),
                                                                                ],
                                                                                dataRowBuilder: (rebanhosItem, rebanhosIndex, selected, onSelectChanged) => DataRow(
                                                                                  color: WidgetStateProperty.all(
                                                                                    rebanhosIndex % 2 == 0 ? FlutterFlowTheme.of(context).secondaryBackground : FlutterFlowTheme.of(context).customColor11,
                                                                                  ),
                                                                                  cells: [
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        rebanhosItem.numeroAnimal,
                                                                                        'N/A',
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
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        rebanhosItem.nome == 'null'
                                                                                            ? 'Sem nome'
                                                                                            : valueOrDefault<String>(
                                                                                                rebanhosItem.nome,
                                                                                                'N/A',
                                                                                              ),
                                                                                        'N/A',
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
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(8.0),
                                                                                          child: Image.network(
                                                                                            rebanhosItem.sexo == 'Macho' ? 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/4cg1mjibvkyf/Sexomacho.png' : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/25fnoszaf5de/Sexofemea.png',
                                                                                            width: 24.0,
                                                                                            height: 24.0,
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                        Text(
                                                                                          valueOrDefault<String>(
                                                                                            rebanhosItem.sexo,
                                                                                            'N/A',
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
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        dateTimeFormat(
                                                                                          "d/M/y",
                                                                                          functions.converterParaData(rebanhosItem.dataNascimento),
                                                                                          locale: FFLocalizations.of(context).languageCode,
                                                                                        ),
                                                                                        'N/A',
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
                                                                                    Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: valueOrDefault<Color>(
                                                                                          () {
                                                                                            if (rebanhosItem.status == 'Vendido') {
                                                                                              return const Color(0xFFF5D7D4);
                                                                                            } else if (rebanhosItem.status == 'Na propriedade') {
                                                                                              return FlutterFlowTheme.of(context).customColor7;
                                                                                            } else {
                                                                                              return FlutterFlowTheme.of(context).customColor2;
                                                                                            }
                                                                                          }(),
                                                                                          FlutterFlowTheme.of(context).customColor2,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(100.0),
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                                                                                        child: Text(
                                                                                          valueOrDefault<String>(
                                                                                            rebanhosItem.status,
                                                                                            'N/A',
                                                                                          ).maybeHandleOverflow(
                                                                                            maxChars: 10,
                                                                                            replacement: '…',
                                                                                          ),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: valueOrDefault<Color>(
                                                                                                  () {
                                                                                                    if (rebanhosItem.status == 'Vendido') {
                                                                                                      return FlutterFlowTheme.of(context).error;
                                                                                                    } else if (rebanhosItem.status == 'Na propriedade') {
                                                                                                      return FlutterFlowTheme.of(context).secondary;
                                                                                                    } else {
                                                                                                      return FlutterFlowTheme.of(context).icon;
                                                                                                    }
                                                                                                  }(),
                                                                                                  FlutterFlowTheme.of(context).icon,
                                                                                                ),
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        rebanhosItem.categoria,
                                                                                        'N/A',
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
                                                                                    Text(
                                                                                      valueOrDefault<String>(
                                                                                        rebanhosItem.raca,
                                                                                        'N/A',
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
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        Builder(
                                                                                          builder: (context) => FlutterFlowIconButton(
                                                                                            borderRadius: 8.0,
                                                                                            buttonSize: 40.0,
                                                                                            fillColor: const Color(0x0028A365),
                                                                                            icon: Icon(
                                                                                              Icons.keyboard_control,
                                                                                              color: FlutterFlowTheme.of(context).accent3,
                                                                                              size: 24.0,
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              await showAlignedDialog(
                                                                                                barrierColor: Colors.transparent,
                                                                                                context: context,
                                                                                                isGlobal: false,
                                                                                                avoidOverflow: true,
                                                                                                targetAnchor: const AlignmentDirectional(1.0, 1.0).resolve(Directionality.of(context)),
                                                                                                followerAnchor: const AlignmentDirectional(1.0, -1.0).resolve(Directionality.of(context)),
                                                                                                builder: (dialogContext) {
                                                                                                  return Material(
                                                                                                    color: Colors.transparent,
                                                                                                    child: GestureDetector(
                                                                                                      onTap: () {
                                                                                                        FocusScope.of(dialogContext).unfocus();
                                                                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                                                                      },
                                                                                                      child: ModalMoreWidget(
                                                                                                        rebanhoId: rebanhosItem.id,
                                                                                                      ),
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ].map((c) => DataCell(c)).toList(),
                                                                                ),
                                                                                emptyBuilder: () => const Center(
                                                                                  child: EmptyWidget(),
                                                                                ),
                                                                                paginated: false,
                                                                                selectable: false,
                                                                                height: 1100.0,
                                                                                headingRowHeight: 56.0,
                                                                                dataRowHeight: 48.0,
                                                                                columnSpacing: 20.0,
                                                                                headingRowColor: FlutterFlowTheme.of(context).customColor11,
                                                                                sortIconColor: FlutterFlowTheme.of(context).primaryText,
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                addHorizontalDivider: true,
                                                                                addTopAndBottomDivider: false,
                                                                                hideDefaultHorizontalDivider: true,
                                                                                horizontalDividerColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                horizontalDividerThickness: 1.0,
                                                                                addVerticalDivider: false,
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            FutureBuilder<ApiCallResponse>(
                                                                              future: FunctionsSupabaseRebanhoGroup.countRebanhoFiltrosCall.call(
                                                                                pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                pCategoria: FFAppState().filtroCategoria,
                                                                                pDataNascimento: dateTimeFormat(
                                                                                  "yyyy-MM-dd",
                                                                                  FFAppState().filtroDataNacimento,
                                                                                  locale: FFLocalizations.of(context).languageCode,
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
                                                                      ].divide(const SizedBox(
                                                                              height: 16.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ].divide(const SizedBox(
                                                                height: 24.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_model.tabBarCurrentIndex != 3)
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                FFButtonWidget(
                                                  onPressed: () async {
                                                    context.pushNamed(
                                                        PgLotesWidget
                                                            .routeName);
                                                  },
                                                  text: 'Voltar',
                                                  options: FFButtonOptions(
                                                    width: 160.0,
                                                    height: 56.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: Colors.white,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color:
                                                              const Color(0xFF28A365),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                    elevation: 0.0,
                                                    borderSide: BorderSide(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                                FFButtonWidget(
                                                  onPressed: () async {
                                                    context.pushNamed(
                                                      PgEditLoteWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'loteNome':
                                                            serializeParam(
                                                          widget.loteNome,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                  text: 'Editar',
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 24.0,
                                                  ),
                                                  options: FFButtonOptions(
                                                    width: 160.0,
                                                    height: 56.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                                16.0, 0.0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                              ].divide(const SizedBox(width: 24.0)),
                                            ),
                                        ].divide(const SizedBox(height: 24.0)),
                                      ),
                                    ),
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
