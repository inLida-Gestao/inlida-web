import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_rebanho_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/pg_lotes/cc_add_lote/cc_add_lote_widget.dart';
import '/pg_lotes/pp_filtro_lote/pp_filtro_lote_widget.dart';
import '/pg_lotes/sub_menu_lotes/sub_menu_lotes_widget.dart';
import '/actions/actions.dart' as action_blocks;
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
import 'pg_lotes_model.dart';
export 'pg_lotes_model.dart';

class PgLotesWidget extends StatefulWidget {
  const PgLotesWidget({super.key});

  static String routeName = 'pgLotes';
  static String routePath = '/lotes';

  @override
  State<PgLotesWidget> createState() => _PgLotesWidgetState();
}

class _PgLotesWidgetState extends State<PgLotesWidget> {
  late PgLotesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgLotesModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        Future(() async {
          await action_blocks.countLotes(context);
        }),
        Future(() async {
          _model.instantTimer = InstantTimer.periodic(
            duration: const Duration(milliseconds: 250),
            callback: (timer) async {
              if (FFAppState().refreshLotes == true) {
                safeSetState(() => _model.apiRequestCompleter = null);
                FFAppState().refreshLotes = false;
                safeSetState(() {});
              }
            },
            startImmediately: true,
          );
        }),
      ]);
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
                FunctionsSupabaseRebanhoGroup.buscarLotesFiltrosCall.call(
              pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
              pPesquisa: _model.textController.text,
              pLimite: FFAppConstants.limit,
              pOffset: functions.calcDeslocamento(
                  _model.pageNum, FFAppConstants.limit),
              pStatus: FFAppState().filtroStatusLote,
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
        final pgLotesBuscarLotesFiltrosResponse = snapshot.data!;

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
                          if (_model.stap == 'rebanho')
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      32.0, 34.0, 32.0, 34.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Lotes',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 40.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              FFButtonWidget(
                                                onPressed: () async {
                                                  context.pushNamed(
                                                      PgAddLoteWidget
                                                          .routeName);
                                                },
                                                text: 'Adicionar',
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 24.0,
                                                ),
                                                options: FFButtonOptions(
                                                  height: 56.0,
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          24.0, 0.0, 24.0, 0.0),
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
                                                        font:
                                                            GoogleFonts.poppins(
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
                                                        fontSize: 18.0,
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
                                                          6.0),
                                                  hoverColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              ),
                                              Container(
                                                height: 56.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .customColor2,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      const AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: SizedBox(
                                                    width: 327.0,
                                                    child: TextFormField(
                                                      controller:
                                                          _model.textController,
                                                      focusNode: _model
                                                          .textFieldFocusNode,
                                                      onChanged: (_) =>
                                                          EasyDebounce.debounce(
                                                        '_model.textController',
                                                        const Duration(
                                                            milliseconds: 2000),
                                                        () async {
                                                          safeSetState(() =>
                                                              _model.apiRequestCompleter =
                                                                  null);
                                                        },
                                                      ),
                                                      autofocus: false,
                                                      obscureText: false,
                                                      decoration:
                                                          InputDecoration(
                                                        isDense: true,
                                                        labelStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                        hintText: 'Pesquisar',
                                                        hintStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              const BorderSide(
                                                            color: Color(
                                                                0x00000000),
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        focusedErrorBorder:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            width: 1.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        filled: true,
                                                        fillColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .customColor2,
                                                        prefixIcon: Icon(
                                                          Icons.search_sharp,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent3,
                                                          size: 24.0,
                                                        ),
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
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                      cursorColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                      validator: _model
                                                          .textControllerValidator
                                                          .asValidator(context),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Builder(
                                                builder: (context) =>
                                                    FFButtonWidget(
                                                  onPressed: () async {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: const AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      dialogContext)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            child:
                                                                const PpFiltroLoteWidget(),
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
                                                        .secondaryBackground,
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
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondary,
                                                              fontSize: 18.0,
                                                              letterSpacing:
                                                                  0.0,
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
                                                              .secondary,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                ),
                                              ),
                                            ].divide(const SizedBox(width: 24.0)),
                                          ),
                                        ].divide(const SizedBox(width: 24.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child:
                                                FutureBuilder<ApiCallResponse>(
                                              future:
                                                  FunctionsSupabaseRebanhoGroup
                                                      .countRebanhosComLoteCall
                                                      .call(
                                                propriedade: FFAppState()
                                                    .propriedadeSelecionada
                                                    .idPropriedade,
                                              ),
                                              builder: (context, snapshot) {
                                                // Customize what your widget looks like when it's loading.
                                                if (!snapshot.hasData) {
                                                  return Center(
                                                    child: SizedBox(
                                                      width: 50.0,
                                                      height: 50.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                final containerCountRebanhosComLoteResponse =
                                                    snapshot.data!;

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryBackground,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        blurRadius: 4.0,
                                                        color:
                                                            Color(0x40000000),
                                                        offset: Offset(
                                                          2.0,
                                                          2.0,
                                                        ),
                                                      )
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    border: Border.all(
                                                      color: const Color(0xFFEDEDED),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(24.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Animais nos lotes',
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
                                                                fontSize: 18.0,
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
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            if (FFAppState()
                                                                    .navegacao !=
                                                                'rebanhos')
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child:
                                                                    Image.asset(
                                                                  'assets/images/Icone_Animal_1-removebg-preview.png',
                                                                  width: 48.0,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            Text(
                                                              '${valueOrDefault<String>(
                                                                containerCountRebanhosComLoteResponse
                                                                    .jsonBody
                                                                    .toString(),
                                                                '0',
                                                              )} animais',
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
                                                                        24.0,
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
                                                          ].divide(const SizedBox(
                                                              width: 12.0)),
                                                        ),
                                                      ].divide(const SizedBox(
                                                          height: 16.0)),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    blurRadius: 4.0,
                                                    color: Color(0x40000000),
                                                    offset: Offset(
                                                      2.0,
                                                      2.0,
                                                    ),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: const Color(0xFFEDEDED),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Lotes ativos',
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
                                                            fontSize: 18.0,
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
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: SvgPicture
                                                              .network(
                                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/rm1vc2z93cr5/Lotes.svg',
                                                            width: 48.0,
                                                            height: 36.0,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            FFAppState()
                                                                .lotesAtivos
                                                                .toString(),
                                                            '0',
                                                          )} lotes',
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
                                                                fontSize: 24.0,
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
                                                      ].divide(const SizedBox(
                                                          width: 12.0)),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 16.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                boxShadow: const [
                                                  BoxShadow(
                                                    blurRadius: 4.0,
                                                    color: Color(0x40000000),
                                                    offset: Offset(
                                                      2.0,
                                                      2.0,
                                                    ),
                                                  )
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: const Color(0xFFEDEDED),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Lotes inativos',
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
                                                            fontSize: 18.0,
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
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: SvgPicture
                                                              .network(
                                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/rm1vc2z93cr5/Lotes.svg',
                                                            width: 48.0,
                                                            height: 36.0,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            FFAppState()
                                                                .lotesInativos
                                                                .toString(),
                                                            '0',
                                                          )} Inativos',
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
                                                                fontSize: 24.0,
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
                                                      ].divide(const SizedBox(
                                                          width: 12.0)),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 16.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 24.0)),
                                      ),
                                      Expanded(
                                        child: Builder(
                                          builder: (context) {
                                            final lote =
                                                (pgLotesBuscarLotesFiltrosResponse
                                                                .jsonBody
                                                                .toList()
                                                                .map<LotesStruct?>(
                                                                    LotesStruct
                                                                        .maybeFromMap)
                                                                .toList()
                                                            as Iterable<
                                                                LotesStruct?>)
                                                        .withoutNulls
                                                        .toList() ??
                                                    [];
                                            if (lote.isEmpty) {
                                              return const Center(
                                                child: EmptyRebanhoWidget(),
                                              );
                                            }

                                            return FlutterFlowDataTable<
                                                LotesStruct>(
                                              controller: _model
                                                  .paginatedDataTableController,
                                              data: lote,
                                              columnsBuilder: (onSortChanged) =>
                                                  [
                                                DataColumn2(
                                                  label: DefaultTextStyle.merge(
                                                    softWrap: true,
                                                    child: Text(
                                                      'Nome do lote',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                  onSort: onSortChanged,
                                                ),
                                                DataColumn2(
                                                  label: DefaultTextStyle.merge(
                                                    softWrap: true,
                                                    child: Text(
                                                      'Número de animais',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                  onSort: onSortChanged,
                                                ),
                                                DataColumn2(
                                                  label: DefaultTextStyle.merge(
                                                    softWrap: true,
                                                    child: Text(
                                                      'Status do lote',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                  onSort: onSortChanged,
                                                ),
                                                DataColumn2(
                                                  label: DefaultTextStyle.merge(
                                                    softWrap: true,
                                                    child: Text(
                                                      ' ',
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelLarge
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelLarge
                                                                      .fontStyle,
                                                                ),
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelLarge
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              dataRowBuilder: (loteItem,
                                                      loteIndex,
                                                      selected,
                                                      onSelectChanged) =>
                                                  DataRow(
                                                color:
                                                    WidgetStateProperty.all(
                                                  loteIndex % 2 == 0
                                                      ? FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryBackground
                                                      : FlutterFlowTheme.of(
                                                              context)
                                                          .customColor11,
                                                ),
                                                cells: [
                                                  Text(
                                                    valueOrDefault<String>(
                                                      loteItem.nome,
                                                      'Nome Lote',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Container(
                                                    decoration: const BoxDecoration(),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        loteItem
                                                            .qtdRebanhosNoLote
                                                            .toString(),
                                                        '0',
                                                      ),
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
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: loteItem.ativo ==
                                                              'Ativo'
                                                          ? const Color(0xFFD6F5E5)
                                                          : const Color(0xFFF5D7D4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  2.0,
                                                                  8.0,
                                                                  2.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            loteItem.ativo ==
                                                                    'Ativo'
                                                                ? 'Ativo'
                                                                : 'Inativo',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
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
                                                                  color: loteItem
                                                                              .ativo ==
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
                                                        ].divide(const SizedBox(
                                                            width: 8.0)),
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Builder(
                                                        builder: (context) =>
                                                            FlutterFlowIconButton(
                                                          borderRadius: 8.0,
                                                          buttonSize: 40.0,
                                                          fillColor:
                                                              const Color(0x0028A365),
                                                          icon: Icon(
                                                            Icons
                                                                .keyboard_control,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .accent3,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () async {
                                                            await showAlignedDialog(
                                                              barrierColor: Colors
                                                                  .transparent,
                                                              context: context,
                                                              isGlobal: false,
                                                              avoidOverflow:
                                                                  true,
                                                              targetAnchor:
                                                                  const AlignmentDirectional(
                                                                          1.0,
                                                                          1.0)
                                                                      .resolve(
                                                                          Directionality.of(
                                                                              context)),
                                                              followerAnchor:
                                                                  const AlignmentDirectional(
                                                                          1.0,
                                                                          -1.0)
                                                                      .resolve(
                                                                          Directionality.of(
                                                                              context)),
                                                              builder:
                                                                  (dialogContext) {
                                                                return Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              dialogContext)
                                                                          .unfocus();
                                                                      FocusManager
                                                                          .instance
                                                                          .primaryFocus
                                                                          ?.unfocus();
                                                                    },
                                                                    child:
                                                                        SubMenuLotesWidget(
                                                                      loteNome:
                                                                          loteItem
                                                                              .nome,
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
                                                ]
                                                    .map((c) => DataCell(c))
                                                    .toList(),
                                              ),
                                              emptyBuilder: () => const Center(
                                                child: EmptyRebanhoWidget(),
                                              ),
                                              paginated: false,
                                              selectable: false,
                                              headingRowHeight: 56.0,
                                              dataRowHeight: 48.0,
                                              columnSpacing: 20.0,
                                              headingRowColor:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor11,
                                              sortIconColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              addHorizontalDivider: true,
                                              addTopAndBottomDivider: false,
                                              hideDefaultHorizontalDivider:
                                                  true,
                                              horizontalDividerColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              horizontalDividerThickness: 1.0,
                                              addVerticalDivider: false,
                                            );
                                          },
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FutureBuilder<ApiCallResponse>(
                                            future:
                                                FunctionsSupabaseRebanhoGroup
                                                    .countLotesFiltrosCall
                                                    .call(
                                              pIdPropriedade: FFAppState()
                                                  .propriedadeSelecionada
                                                  .idPropriedade,
                                              pPesquisa:
                                                  _model.textController.text,
                                              pStatus:
                                                  FFAppState().filtroStatusLote,
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              final containerCountLotesFiltrosResponse =
                                                  snapshot.data!;

                                              return Container(
                                                height: 56.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .customColor5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.pageNum = 1;
                                                        safeSetState(() {});
                                                        safeSetState(() => _model
                                                                .apiRequestCompleter =
                                                            null);
                                                      },
                                                      child: Container(
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              const BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    6.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    6.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    0.0),
                                                          ),
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .customColor5,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      24.0,
                                                                      12.0,
                                                                      24.0,
                                                                      12.0),
                                                          child: Icon(
                                                            Icons
                                                                .keyboard_double_arrow_left,
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              _model.pageNum > 1
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3,
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                            ),
                                                            size: 24.0,
                                                          ),
                                                        ),
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
                                                      onTap: () async {
                                                        if (_model.pageNum >
                                                            1) {
                                                          _model.pageNum =
                                                              _model.pageNum +
                                                                  -1;
                                                          safeSetState(() {});
                                                          safeSetState(() =>
                                                              _model.apiRequestCompleter =
                                                                  null);
                                                        }
                                                      },
                                                      child: Container(
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .customColor5,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      24.0,
                                                                      12.0,
                                                                      24.0,
                                                                      12.0),
                                                          child: Icon(
                                                            Icons
                                                                .keyboard_arrow_left_sharp,
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              _model.pageNum > 1
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3,
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                            ),
                                                            size: 24.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  24.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                      child: RichText(
                                                        textScaler:
                                                            MediaQuery.of(
                                                                    context)
                                                                .textScaler,
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  valueOrDefault<
                                                                      String>(
                                                                _model.pageNum
                                                                    .toString(),
                                                                '1',
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
                                                            const TextSpan(
                                                              text: ' de ',
                                                              style: TextStyle(
                                                                fontSize: 16.0,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  valueOrDefault<
                                                                      String>(
                                                                ((containerCountLotesFiltrosResponse.jsonBody /
                                                                            FFAppConstants.limit)
                                                                        .ceil())
                                                                    .toString(),
                                                                '1',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                                                    fontSize:
                                                                        16.0,
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
                                                            )
                                                          ],
                                                          style: FlutterFlowTheme
                                                                  .of(context)
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
                                                      onTap: () async {
                                                        if (_model.pageNum <
                                                            valueOrDefault<int>(
                                                              (containerCountLotesFiltrosResponse
                                                                          .jsonBody /
                                                                      FFAppConstants
                                                                          .limit)
                                                                  .ceil(),
                                                              1,
                                                            )) {
                                                          _model.pageNum =
                                                              _model.pageNum +
                                                                  1;
                                                          safeSetState(() {});
                                                          safeSetState(() =>
                                                              _model.apiRequestCompleter =
                                                                  null);
                                                        }
                                                      },
                                                      child: Container(
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .customColor5,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      24.0,
                                                                      12.0,
                                                                      24.0,
                                                                      12.0),
                                                          child: Icon(
                                                            Icons
                                                                .keyboard_arrow_right_sharp,
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              _model.pageNum <
                                                                      valueOrDefault<
                                                                          int>(
                                                                        (containerCountLotesFiltrosResponse.jsonBody /
                                                                                FFAppConstants.limit)
                                                                            .ceil(),
                                                                        1,
                                                                      )
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3,
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                            ),
                                                            size: 24.0,
                                                          ),
                                                        ),
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
                                                      onTap: () async {
                                                        _model.pageNum =
                                                            valueOrDefault<int>(
                                                          (containerCountLotesFiltrosResponse
                                                                      .jsonBody /
                                                                  FFAppConstants
                                                                      .limit)
                                                              .ceil(),
                                                          1,
                                                        );
                                                        safeSetState(() {});
                                                        safeSetState(() => _model
                                                                .apiRequestCompleter =
                                                            null);
                                                      },
                                                      child: Container(
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryBackground,
                                                          borderRadius:
                                                              const BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    6.0),
                                                            topLeft:
                                                                Radius.circular(
                                                                    0.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    6.0),
                                                          ),
                                                          border: Border.all(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .customColor5,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      24.0,
                                                                      12.0,
                                                                      24.0,
                                                                      12.0),
                                                          child: Icon(
                                                            Icons
                                                                .keyboard_double_arrow_right_outlined,
                                                            color:
                                                                valueOrDefault<
                                                                    Color>(
                                                              _model.pageNum ==
                                                                      valueOrDefault<
                                                                          int>(
                                                                        (containerCountLotesFiltrosResponse.jsonBody /
                                                                                FFAppConstants.limit)
                                                                            .ceil(),
                                                                        1,
                                                                      )
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .accent3
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
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
                                    ].divide(const SizedBox(height: 24.0)),
                                  ),
                                ),
                              ),
                            ),
                          if (_model.stap == 'addLote')
                            Flexible(
                              child: Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: wrapWithModel(
                                  model: _model.ccAddLoteModel,
                                  updateCallback: () => safeSetState(() {}),
                                  child: CcAddLoteWidget(
                                    action: (page) async {
                                      _model.stap = page!;
                                      safeSetState(() {});
                                    },
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
