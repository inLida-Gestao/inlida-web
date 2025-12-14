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
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_add_lote_model.dart';
export 'pg_add_lote_model.dart';

class PgAddLoteWidget extends StatefulWidget {
  const PgAddLoteWidget({super.key});

  static String routeName = 'pgAddLote';
  static String routePath = '/addlote';

  @override
  State<PgAddLoteWidget> createState() => _PgAddLoteWidgetState();
}

class _PgAddLoteWidgetState extends State<PgAddLoteWidget>
    with TickerProviderStateMixin {
  late PgAddLoteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgAddLoteModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.nomeLoteTextController ??= TextEditingController();
    _model.nomeLoteFocusNode ??= FocusNode();

    _model.anotacoesTextController ??= TextEditingController();
    _model.anotacoesFocusNode ??= FocusNode();

    _model.switchValue = true;
    _model.dataEntradaLoteTextController ??= TextEditingController();
    _model.dataEntradaLoteFocusNode ??= FocusNode();

    _model.pesquisaTextController1 ??= TextEditingController();
    _model.pesquisaFocusNode1 ??= FocusNode();

    _model.pesquisaTextController2 ??= TextEditingController();
    _model.pesquisaFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
              pOrigem: FFAppState().filtroOrigem,
              pRaca: FFAppState().filtroRaca,
              pSexo: FFAppState().filtroSexo,
              pStatus: 'Na propriedade',
              pLimite: FFAppConstants.limit,
              pOffset: functions.calcDeslocamento(
                  _model.pageNumAdd, FFAppConstants.limit),
              pPesquisa: _model.pesquisaTextController1.text,
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
        final pgAddLoteBuscarRebanhoFiltrosResponse = snapshot.data!;

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
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
                                      Text(
                                        'Adicionar lote',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 40.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: const Alignment(0.0, 0),
                                              child: TabBar(
                                                labelColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                unselectedLabelColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                labelStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                      letterSpacing: 0.0,
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
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
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
                                                          letterSpacing: 0.0,
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
                                                    FlutterFlowTheme.of(context)
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
                                                              MainAxisSize.max,
                                                          children: [
                                                            Expanded(
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
                                                                  ),
                                                                  TextFormField(
                                                                    controller:
                                                                        _model
                                                                            .nomeLoteTextController,
                                                                    focusNode:
                                                                        _model
                                                                            .nomeLoteFocusNode,
                                                                    autofocus:
                                                                        false,
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
                                                                          'Nome do lote',
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
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor2,
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
                                                                        .nomeLoteTextControllerValidator
                                                                        .asValidator(
                                                                            context),
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
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Anotações',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller: _model
                                                                    .anotacoesTextController,
                                                                focusNode: _model
                                                                    .anotacoesFocusNode,
                                                                autofocus:
                                                                    false,
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
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .accent3,
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  hintText:
                                                                      'Anotações',
                                                                  hintStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        color: const Color(
                                                                            0xFFBEBEBE),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        const BorderSide(
                                                                      color: Color(
                                                                          0x00000000),
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  focusedErrorBorder:
                                                                      OutlineInputBorder(
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .error,
                                                                      width:
                                                                          1.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  filled: true,
                                                                  fillColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                ),
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
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                cursorColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
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
                                                          width:
                                                              double.infinity,
                                                          height: 80.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                blurRadius: 1.0,
                                                                color: Color(
                                                                    0x1A000000),
                                                                offset: Offset(
                                                                  0.0,
                                                                  2.0,
                                                                ),
                                                              )
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                            border: Border.all(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .customColor12,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
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
                                                                Switch.adaptive(
                                                                  value: _model
                                                                      .switchValue!,
                                                                  onChanged:
                                                                      (newValue) async {
                                                                    safeSetState(() =>
                                                                        _model.switchValue =
                                                                            newValue);
                                                                  },
                                                                  activeColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                  activeTrackColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                  inactiveTrackColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .alternate,
                                                                  inactiveThumbColor:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        if (_model
                                                                .switchValue ==
                                                            false)
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Motivo',
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
                                                                    FlutterFlowDropDown<
                                                                        String>(
                                                                      controller: _model
                                                                          .dropDownLotesValueController ??= FormFieldController<
                                                                              String>(
                                                                          null),
                                                                      options: const [
                                                                        'Lote vendido'
                                                                      ],
                                                                      onChanged:
                                                                          (val) =>
                                                                              safeSetState(() => _model.dropDownLotesValue = val),
                                                                      height:
                                                                          56.0,
                                                                      textStyle: FlutterFlowTheme.of(
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
                                                                      hintText:
                                                                          'Selecionar',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      fillColor:
                                                                          const Color(
                                                                              0xFFF1F1F1),
                                                                      elevation:
                                                                          2.0,
                                                                      borderColor:
                                                                          Colors
                                                                              .transparent,
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
                                                                      height:
                                                                          8.0)),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Data',
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
                                                                    Stack(
                                                                      children: [
                                                                        TextFormField(
                                                                          controller:
                                                                              _model.dataEntradaLoteTextController,
                                                                          focusNode:
                                                                              _model.dataEntradaLoteFocusNode,
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
                                                                            hintText:
                                                                                'dd/mm/aaaa',
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
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                            suffixIcon:
                                                                                Icon(
                                                                              Icons.calendar_today,
                                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                                            ),
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
                                                                          maxLines:
                                                                              null,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .dataEntradaLoteTextControllerValidator
                                                                              .asValidator(context),
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
                                                                            final datePickedDate =
                                                                                await showDatePicker(
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

                                                                            if (datePickedDate !=
                                                                                null) {
                                                                              safeSetState(() {
                                                                                _model.datePicked = DateTime(
                                                                                  datePickedDate.year,
                                                                                  datePickedDate.month,
                                                                                  datePickedDate.day,
                                                                                );
                                                                              });
                                                                            } else if (_model.datePicked !=
                                                                                null) {
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
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                48.0,
                                                                            decoration:
                                                                                const BoxDecoration(),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ].divide(const SizedBox(
                                                                      height:
                                                                          8.0)),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Valor da venda (R\$)',
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
                                                                    SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          60.0,
                                                                      child: custom_widgets
                                                                          .CurrencyInputBR(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            60.0,
                                                                        initialValue:
                                                                            0.0,
                                                                        hintText:
                                                                            'R\$ 0,00',
                                                                        fillColor:
                                                                            FlutterFlowTheme.of(context).customColor2,
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        focusedBorderColor:
                                                                            Colors.transparent,
                                                                        textColor:
                                                                            FlutterFlowTheme.of(context).secondaryText,
                                                                        fontSize:
                                                                            16.0,
                                                                        borderRadius:
                                                                            8.0,
                                                                      ),
                                                                    ),
                                                                  ].divide(const SizedBox(
                                                                      height:
                                                                          8.0)),
                                                                ),
                                                              ),
                                                            ].divide(const SizedBox(
                                                                width: 24.0)),
                                                          ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                blurRadius: 1.0,
                                                                color: Color(
                                                                    0x1A000000),
                                                                offset: Offset(
                                                                  0.0,
                                                                  2.0,
                                                                ),
                                                              )
                                                            ],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                            border: Border.all(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .customColor12,
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
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
                                                                      'Animais neste lote (0)',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                18.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                    Text(
                                                                      'Ver todos',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    safeSetState(
                                                                        () {
                                                                      _model
                                                                          .tabBarController!
                                                                          .animateTo(
                                                                        min(
                                                                            _model.tabBarController!.length -
                                                                                1,
                                                                            _model.tabBarController!.index +
                                                                                1),
                                                                        duration:
                                                                            const Duration(milliseconds: 300),
                                                                        curve: Curves
                                                                            .ease,
                                                                      );
                                                                    });
                                                                  },
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Opacity(
                                                                        opacity:
                                                                            0.4,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              16.0),
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            child:
                                                                                SvgPicture.asset(
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                              ].divide(const SizedBox(
                                                                  height:
                                                                      16.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                          .divide(const SizedBox(
                                                              height: 24.0))
                                                          .addToStart(const SizedBox(
                                                              height: 24.0)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      2.0),
                                                          child: Container(
                                                            width: 378.0,
                                                            height:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
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
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Animais fora do lote (${valueOrDefault<String>(
                                                                      (pgAddLoteBuscarRebanhoFiltrosResponse
                                                                              .jsonBody
                                                                              .toList()
                                                                              .map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap)
                                                                              .toList() as Iterable<RebanhoDTStruct?>)
                                                                          .withoutNulls
                                                                          .where((e) => (e.loteID == 'null') || (e.loteID == ''))
                                                                          .toList()
                                                                          .length
                                                                          .toString(),
                                                                      '0',
                                                                    )})',
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
                                                                              18.0,
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
                                                                    height:
                                                                        56.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor2,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6.0),
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          const AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            327.0,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              _model.pesquisaTextController1,
                                                                          focusNode:
                                                                              _model.pesquisaFocusNode1,
                                                                          onChanged: (_) =>
                                                                              EasyDebounce.debounce(
                                                                            '_model.pesquisaTextController1',
                                                                            const Duration(milliseconds: 250),
                                                                            () async {
                                                                              safeSetState(() => _model.apiRequestCompleter = null);
                                                                            },
                                                                          ),
                                                                          autofocus:
                                                                              false,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                true,
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
                                                                                'Pesquisar',
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
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            prefixIcon:
                                                                                Icon(
                                                                              Icons.search_sharp,
                                                                              color: FlutterFlowTheme.of(context).accent3,
                                                                              size: 24.0,
                                                                            ),
                                                                            suffixIcon: _model.pesquisaTextController1!.text.isNotEmpty
                                                                                ? InkWell(
                                                                                    onTap: () async {
                                                                                      _model.pesquisaTextController1?.clear();
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
                                                                              .pesquisaTextController1Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) =>
                                                                            FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        await showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (dialogContext) {
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
                                                                      text:
                                                                          'Filtrar',
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .filter_list,
                                                                        size:
                                                                            15.0,
                                                                      ),
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            40.0,
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconAlignment:
                                                                            IconAlignment.end,
                                                                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: const Color(
                                                                            0x0028A365),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).icon,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).customColor12,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(100.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    height: 0.0,
                                                                    thickness:
                                                                        1.0,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor5,
                                                                  ),
                                                                  if (responsiveVisibility(
                                                                    context:
                                                                        context,
                                                                    phone:
                                                                        false,
                                                                    tablet:
                                                                        false,
                                                                    tabletLandscape:
                                                                        false,
                                                                    desktop:
                                                                        false,
                                                                  ))
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          40.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(100.0),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).customColor12,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            12.0,
                                                                            8.0,
                                                                            12.0,
                                                                            8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children:
                                                                              [
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
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Theme(
                                                                        data:
                                                                            ThemeData(
                                                                          checkboxTheme:
                                                                              CheckboxThemeData(
                                                                            visualDensity:
                                                                                VisualDensity.compact,
                                                                            materialTapTargetSize:
                                                                                MaterialTapTargetSize.shrinkWrap,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                          ),
                                                                          unselectedWidgetColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                        ),
                                                                        child:
                                                                            Checkbox(
                                                                          value: _model.checkboxValue1 ??=
                                                                              false,
                                                                          onChanged:
                                                                              (newValue) async {
                                                                            safeSetState(() =>
                                                                                _model.checkboxValue1 = newValue!);
                                                                            if (newValue!) {
                                                                              _model.animaisSelecionados = [];
                                                                              safeSetState(() {});
                                                                              _model.animaisSelecionados = (pgAddLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.toList().cast<RebanhoDTStruct>();
                                                                              safeSetState(() {});
                                                                            }
                                                                          },
                                                                          side: (FlutterFlowTheme.of(context).primaryText != null)
                                                                              ? BorderSide(
                                                                                  width: 2,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                )
                                                                              : null,
                                                                          activeColor:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          checkColor:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        'Selecionar todos da página',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        final animais =
                                                                            (pgAddLoteBuscarRebanhoFiltrosResponse.jsonBody.toList().map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap).toList() as Iterable<RebanhoDTStruct?>).withoutNulls.where((e) => (e.status != 'Sêmen') || (e.status != 'Fora da propriedade')).toList().toList() ??
                                                                                [];

                                                                        return ListView
                                                                            .builder(
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                          shrinkWrap:
                                                                              true,
                                                                          scrollDirection:
                                                                              Axis.vertical,
                                                                          itemCount:
                                                                              animais.length,
                                                                          itemBuilder:
                                                                              (context, animaisIndex) {
                                                                            final animaisItem =
                                                                                animais[animaisIndex];
                                                                            return Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                  child: Row(
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
                                                                                          value: _model.checkboxValueMap2[animaisItem] ??= false,
                                                                                          onChanged: (newValue) async {
                                                                                            safeSetState(() => _model.checkboxValueMap2[animaisItem] = newValue!);
                                                                                            if (newValue!) {
                                                                                              _model.addToAnimaisSelecionados(animaisItem);
                                                                                              safeSetState(() {});
                                                                                            } else {
                                                                                              _model.removeFromAnimaisSelecionados(animaisItem);
                                                                                              safeSetState(() {});
                                                                                            }
                                                                                          },
                                                                                          side: (FlutterFlowTheme.of(context).primaryText != null)
                                                                                              ? BorderSide(
                                                                                                  width: 2,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                )
                                                                                              : null,
                                                                                          activeColor: FlutterFlowTheme.of(context).primary,
                                                                                          checkColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        ),
                                                                                      ),
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
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      FutureBuilder<
                                                                          ApiCallResponse>(
                                                                        future: FunctionsSupabaseRebanhoGroup
                                                                            .countRebanhoFiltrosCall
                                                                            .call(
                                                                          pIdPropriedade: FFAppState()
                                                                              .propriedadeSelecionada
                                                                              .idPropriedade,
                                                                          pCategoria:
                                                                              FFAppState().filtroCategoria,
                                                                          pDataNascimento:
                                                                              dateTimeFormat(
                                                                            "yyyy-MM-dd",
                                                                            FFAppState().filtroDataNacimento,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ),
                                                                          pLoteID:
                                                                              FFAppState().filtroLoteId,
                                                                          pOrigem:
                                                                              FFAppState().filtroOrigem,
                                                                          pRaca:
                                                                              FFAppState().filtroRaca,
                                                                          pSexo:
                                                                              FFAppState().filtroSexo,
                                                                          pStatus:
                                                                              FFAppState().filtroStatusRebanho,
                                                                          pPesquisa: _model
                                                                              .pesquisaTextController1
                                                                              .text,
                                                                        ),
                                                                        builder:
                                                                            (context,
                                                                                snapshot) {
                                                                          // Customize what your widget looks like when it's loading.
                                                                          if (!snapshot
                                                                              .hasData) {
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
                                                                          final containerCountRebanhoFiltrosResponse =
                                                                              snapshot.data!;

                                                                          return Container(
                                                                            height:
                                                                                56.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                              border: Border.all(
                                                                                color: FlutterFlowTheme.of(context).customColor5,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Row(
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
                                                                    height:
                                                                        16.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FlutterFlowIconButton(
                                                              borderRadius: 6.0,
                                                              buttonSize: 40.0,
                                                              fillColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_forward_ios,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .info,
                                                                size: 24.0,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                if (_model
                                                                    .animaisSelecionados
                                                                    .isNotEmpty) {
                                                                  _model.animaisDentroLote = _model
                                                                      .animaisSelecionados
                                                                      .toList()
                                                                      .cast<
                                                                          RebanhoDTStruct>();
                                                                  safeSetState(
                                                                      () {});
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'Nenhum animal selecionado',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                        ),
                                                                      ),
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              4000),
                                                                      backgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .error,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ].divide(const SizedBox(
                                                              height: 8.0)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      2.0),
                                                          child: Container(
                                                            width: 378.0,
                                                            height:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
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
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Animais neste lote (${valueOrDefault<String>(
                                                                      (pgAddLoteBuscarRebanhoFiltrosResponse
                                                                              .jsonBody
                                                                              .toList()
                                                                              .map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap)
                                                                              .toList() as Iterable<RebanhoDTStruct?>)
                                                                          .withoutNulls
                                                                          .where((e) => (e.loteID == 'null') || (e.loteID == ''))
                                                                          .toList()
                                                                          .length
                                                                          .toString(),
                                                                      '0',
                                                                    )})',
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
                                                                              18.0,
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
                                                                    height:
                                                                        56.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor2,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6.0),
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          const AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            327.0,
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              _model.pesquisaTextController2,
                                                                          focusNode:
                                                                              _model.pesquisaFocusNode2,
                                                                          onChanged: (_) =>
                                                                              EasyDebounce.debounce(
                                                                            '_model.pesquisaTextController2',
                                                                            const Duration(milliseconds: 250),
                                                                            () =>
                                                                                safeSetState(() {}),
                                                                          ),
                                                                          autofocus:
                                                                              false,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                true,
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
                                                                                'Pesquisar',
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
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(6.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            prefixIcon:
                                                                                Icon(
                                                                              Icons.search_sharp,
                                                                              color: FlutterFlowTheme.of(context).accent3,
                                                                              size: 24.0,
                                                                            ),
                                                                            suffixIcon: _model.pesquisaTextController2!.text.isNotEmpty
                                                                                ? InkWell(
                                                                                    onTap: () async {
                                                                                      _model.pesquisaTextController2?.clear();
                                                                                      safeSetState(() {});
                                                                                    },
                                                                                    child: const Icon(
                                                                                      Icons.clear,
                                                                                      size: 22,
                                                                                    ),
                                                                                  )
                                                                                : null,
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
                                                                              .pesquisaTextController2Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) =>
                                                                            FFButtonWidget(
                                                                      onPressed:
                                                                          () async {
                                                                        await showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (dialogContext) {
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
                                                                      text:
                                                                          'Filtrar',
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .filter_list,
                                                                        size:
                                                                            15.0,
                                                                      ),
                                                                      options:
                                                                          FFButtonOptions(
                                                                        height:
                                                                            40.0,
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            16.0,
                                                                            0.0,
                                                                            16.0,
                                                                            0.0),
                                                                        iconAlignment:
                                                                            IconAlignment.end,
                                                                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                        color: const Color(
                                                                            0x0028A365),
                                                                        textStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(context).icon,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                            ),
                                                                        elevation:
                                                                            0.0,
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).customColor12,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(100.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                    height: 0.0,
                                                                    thickness:
                                                                        1.0,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .customColor5,
                                                                  ),
                                                                  if (responsiveVisibility(
                                                                    context:
                                                                        context,
                                                                    phone:
                                                                        false,
                                                                    tablet:
                                                                        false,
                                                                    tabletLandscape:
                                                                        false,
                                                                    desktop:
                                                                        false,
                                                                  ))
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          40.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(100.0),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).customColor12,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                                                            12.0,
                                                                            8.0,
                                                                            12.0,
                                                                            8.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children:
                                                                              [
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
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      if (_model
                                                                              .animaisDentroLote.isNotEmpty)
                                                                        FFButtonWidget(
                                                                          onPressed:
                                                                              () async {
                                                                            var confirmDialogResponse = await showDialog<bool>(
                                                                                  context: context,
                                                                                  builder: (alertDialogContext) {
                                                                                    return AlertDialog(
                                                                                      content: const Text('Deseja remover todos os animais do lote?'),
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
                                                                              _model.animaisDentroLote = [];
                                                                              safeSetState(() {});
                                                                            }
                                                                          },
                                                                          text:
                                                                              'Remover Todos',
                                                                          options:
                                                                              FFButtonOptions(
                                                                            height:
                                                                                40.0,
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                16.0,
                                                                                0.0,
                                                                                16.0,
                                                                                0.0),
                                                                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                0.0),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).error,
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
                                                                            elevation:
                                                                                0.0,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                        ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Flexible(
                                                                    child:
                                                                        Builder(
                                                                      builder:
                                                                          (context) {
                                                                        final animais = _model
                                                                            .animaisDentroLote
                                                                            .where((e) =>
                                                                                ((_model.pesquisaTextController2.text == '') && (FFAppState().filtroCategoria == '') && (FFAppState().filtroSexo == '') && (FFAppState().filtroRaca == '') && (FFAppState().filtroOrigem == '') && (FFAppState().filtroStatusRebanho == '') && (FFAppState().filtroDataNacimento == null)) ||
                                                                                ((e.numeroAnimal.contains(_model.pesquisaTextController2.text) || e.nome.toLowerCase().contains(_model.pesquisaTextController2.text.toLowerCase()) || e.chip.contains(_model.pesquisaTextController2.text)) && ((FFAppState().filtroSexo == '') || (e.sexo == FFAppState().filtroSexo)) && ((FFAppState().filtroCategoria == '') || (e.categoria == FFAppState().filtroCategoria)) && ((FFAppState().filtroRaca == '') || (e.raca == FFAppState().filtroRaca)) && ((FFAppState().filtroOrigem == '') || (e.origem == FFAppState().filtroOrigem)) && ((FFAppState().filtroStatusRebanho == '') || (e.status == FFAppState().filtroStatusRebanho)) && ((FFAppState().filtroDataNacimento == null) && (functions.converterParaData(e.dataNascimento) == FFAppState().filtroDataNacimento))))
                                                                            .toList()
                                                                            .take(_model.mostrarAdicionados)
                                                                            .toList();

                                                                        return ListView
                                                                            .builder(
                                                                          padding:
                                                                              EdgeInsets.zero,
                                                                          shrinkWrap:
                                                                              true,
                                                                          scrollDirection:
                                                                              Axis.vertical,
                                                                          itemCount:
                                                                              animais.length,
                                                                          itemBuilder:
                                                                              (context, animaisIndex) {
                                                                            final animaisItem =
                                                                                animais[animaisIndex];
                                                                            return Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                                                                                  child: Row(
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
                                                                                          value: _model.checkboxValueMap3[animaisItem] ??= true,
                                                                                          onChanged: (newValue) async {
                                                                                            safeSetState(() => _model.checkboxValueMap3[animaisItem] = newValue!);

                                                                                            if (!newValue!) {
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
                                                                                                _model.removeFromAnimaisDentroLote(animaisItem);
                                                                                                safeSetState(() {});
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                          side: (FlutterFlowTheme.of(context).primaryText != null)
                                                                                              ? BorderSide(
                                                                                                  width: 2,
                                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                                )
                                                                                              : null,
                                                                                          activeColor: FlutterFlowTheme.of(context).primary,
                                                                                          checkColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        ),
                                                                                      ),
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
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      if (_model
                                                                              .mostrarAdicionados >
                                                                          5)
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
                                                                            _model.mostrarAdicionados =
                                                                                _model.mostrarAdicionados + -5;
                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
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
                                                                      if (_model
                                                                              .mostrarAdicionados <
                                                                          _model
                                                                              .animaisDentroLote
                                                                              .length)
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
                                                                            _model.mostrarAdicionados =
                                                                                _model.mostrarAdicionados + 5;
                                                                            safeSetState(() {});
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
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
                                                                ].divide(const SizedBox(
                                                                    height:
                                                                        16.0)),
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
                                      if (_model.tabBarCurrentIndex != 3)
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            FFButtonWidget(
                                              onPressed: () {
                                                print('Button pressed ...');
                                              },
                                              text: 'Cancelar',
                                              options: FFButtonOptions(
                                                width: 160.0,
                                                height: 56.0,
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                iconPadding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color: Colors.white,
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                      color: const Color(0xFF28A365),
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
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            FFButtonWidget(
                                              onPressed: () async {
                                                _model.idLote =
                                                    random_data.randomString(
                                                  20,
                                                  20,
                                                  true,
                                                  false,
                                                  true,
                                                );
                                                safeSetState(() {});
                                                await LotesTable().insert({
                                                  'id_propriedade': FFAppState()
                                                      .propriedadeSelecionada
                                                      .idPropriedade,
                                                  'id_animais': functions
                                                      .converterListaParaJSON(
                                                          _model
                                                              .animaisDentroLote
                                                              .map((e) =>
                                                                  e.idRebanho)
                                                              .toList()),
                                                  'nome': _model
                                                      .nomeLoteTextController
                                                      .text,
                                                  'anotacoes': _model
                                                      .anotacoesTextController
                                                      .text,
                                                  'ativo':
                                                      _model.switchValue == true
                                                          ? 'Ativo'
                                                          : 'Inativo',
                                                  'id_lote': _model.idLote,
                                                  'deletado': 'NAO',
                                                  'motivo':
                                                      _model.dropDownLotesValue,
                                                  'data_motivo':
                                                      supaSerialize<DateTime>(
                                                          _model.datePicked),
                                                  'valorVenda':
                                                      FFAppState().valueDouble2,
                                                });
                                                _model.index = 0;
                                                safeSetState(() {});
                                                while (_model.index <
                                                    _model.animaisDentroLote
                                                        .length) {
                                                  await RebanhoTable().update(
                                                    data: {
                                                      'loteID': _model.idLote,
                                                      'loteNome': _model
                                                          .nomeLoteTextController
                                                          .text,
                                                      'updated_at': supaSerialize<
                                                              DateTime>(
                                                          getCurrentTimestamp),
                                                      'dataEntradaLote':
                                                          supaSerialize<
                                                                  DateTime>(
                                                              getCurrentTimestamp),
                                                      'dataVenda': supaSerialize<
                                                          DateTime>(_model.datePicked ?? functions.converterParaData(_model
                                                              .animaisDentroLote
                                                              .elementAtOrNull(
                                                                  _model.index)
                                                              ?.dataVenda)),
                                                      'valorVenda': FFAppState()
                                                              .valueDouble2 ?? _model
                                                              .animaisDentroLote
                                                              .elementAtOrNull(
                                                                  _model.index)
                                                              ?.valorVenda,
                                                    },
                                                    matchingRows: (rows) =>
                                                        rows.eqOrNull(
                                                      'idRebanho',
                                                      _model.animaisDentroLote
                                                          .elementAtOrNull(
                                                              _model.index)
                                                          ?.idRebanho,
                                                    ),
                                                  );
                                                  _model.index =
                                                      _model.index + 1;
                                                  safeSetState(() {});
                                                }
                                                _model.animaisDentroLote = [];
                                                _model.animaisSelecionados = [];
                                                safeSetState(() {});
                                                unawaited(
                                                  () async {
                                                    await action_blocks
                                                        .countLotes(context);
                                                  }(),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Lote cadastrado com sucesso',
                                                      style: TextStyle(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    duration: const Duration(
                                                        milliseconds: 4000),
                                                    backgroundColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                  ),
                                                );

                                                context.pushNamed(
                                                    PgLotesWidget.routeName);
                                              },
                                              text: 'Salvar',
                                              options: FFButtonOptions(
                                                width: 160.0,
                                                height: 56.0,
                                                padding: const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                iconPadding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                textStyle: FlutterFlowTheme.of(
                                                        context)
                                                    .titleSmall
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    BorderRadius.circular(8.0),
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
