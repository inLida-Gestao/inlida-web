import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_widget.dart';
import '/components/loading_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/pages/pp_instrucoes_importacao/pp_instrucoes_importacao_widget.dart';
import '/pages/sub_menu_painel_exportar/sub_menu_painel_exportar_widget.dart';
import '/pages/sub_menu_painel_importar/sub_menu_painel_importar_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dart:async';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'painel_model.dart';
export 'painel_model.dart';

/// Taxa de natalidade na aba Reprodução: `false` oculta o cartão (só período global, sem Lote/Touro/Inseminador).
const bool _painelMostrarCartaoTaxaNatalidade = true;

class PainelWidget extends StatefulWidget {
  const PainelWidget({super.key});

  static String routeName = 'Painel';
  static String routePath = '/painel';

  @override
  State<PainelWidget> createState() => _PainelWidgetState();
}

class _PainelWidgetState extends State<PainelWidget>
    with TickerProviderStateMixin {
  late PainelModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PainelModel());

    // Sincronizar sidebar imediatamente ao entrar no Painel.
    FFAppState().navegacao = 'painel';

    // Defaults do gráfico "Rebanho por período": sempre iniciar no ano atual.
    final currentYear = DateTime.now().year;
    _model.dropDownValue1 ??= currentYear;
    _model.dropDownValue2 ??= 1;
    _model.dropDownValue3 ??= currentYear;
    _model.dropDownValue4 ??= 12;

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      Function() navigate = () {};
      _model.acessoUser =
          await FunctionsSupabaseRebanhoGroup.validarAcessoUserCall.call(
        pUserId: currentUserUid,
      );

      safeSetState(() => _model.apiRequestCompleter2 = null);
      safeSetState(() => _model.apiRequestCompleter2 = null);
      if (FunctionsSupabaseRebanhoGroup.validarAcessoUserCall.acesso(
            (_model.acessoUser?.jsonBody ?? ''),
          ) ==
          'Cancelado') {
        GoRouter.of(context).prepareAuthEvent();
        await authManager.signOut();
        GoRouter.of(context).clearRedirectLocation();

        navigate =
            () => context.goNamedAuth(LoginWidget.routeName, context.mounted);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Seu período de acesso grátis finalizou, assine para continuar ter acesso a plataforma.',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
      } else {
        _model.disposeRefreshListener =
            FFAppState().onRefresh('refreshPainel', () {
          FFAppState().refreshPainel = false;
          safeSetState(() => _model.apiRequestCompleter1 = null);
          safeSetState(() => _model.apiRequestCompleter2 = null);
        });
      }

      navigate();
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 4,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    if (FFAppState().refreshPainel == true) {
      _model.apiRequestCompleter1 = null;
      _model.apiRequestCompleter2 = null;
      FFAppState().refreshPainel = false;
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
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.headerModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const HeaderWidget(),
                  ),
                  Expanded(
                    child: SizedBox.expand(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          wrapWithModel(
                            model: _model.sideBarModel,
                            updateCallback: () => safeSetState(() {}),
                            child: const SideBarWidget(),
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 32.0, 24.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Painel',
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
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  if ((FFAppState()
                                                              .propriedadeSelecionada
                                                              .idPropriedade !=
                                                          '') &&
                                                      (_model.tabBarCurrentIndex !=
                                                          0))
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(5.0,
                                                                0.0, 5.0, 0.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    FlutterFlowDropDown<
                                                                        String>(
                                                                      controller: _model
                                                                              .dDInicioAnoValueController ??=
                                                                          FormFieldController<
                                                                              String>(
                                                                        _model.dDInicioAnoValue ??=
                                                                            dateTimeFormat(
                                                                          "yyyy",
                                                                          getCurrentTimestamp,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ),
                                                                      ),
                                                                      options:
                                                                          functions
                                                                              .gerarAnos()!,
                                                                      onChanged:
                                                                          (val) async {
                                                                        safeSetState(() =>
                                                                            _model.dDInicioAnoValue =
                                                                                val);
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      width:
                                                                          156.0,
                                                                      height:
                                                                          48.0,
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                14.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          'Selecionar ano',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      elevation:
                                                                          2.0,
                                                                      borderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor2,
                                                                      borderWidth:
                                                                          0.0,
                                                                      borderRadius:
                                                                          8.0,
                                                                      margin: const EdgeInsetsDirectional
                                                                          .fromSTEB(
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
                                                                    FlutterFlowDropDown<
                                                                        int>(
                                                                      controller: _model
                                                                              .dDInicioMesValueController ??=
                                                                          FormFieldController<
                                                                              int>(
                                                                        _model.dDInicioMesValue ??=
                                                                            1,
                                                                      ),
                                                                      options: List<
                                                                          int>.from([
                                                                        1,
                                                                        2,
                                                                        3,
                                                                        4,
                                                                        5,
                                                                        6,
                                                                        7,
                                                                        8,
                                                                        9,
                                                                        10,
                                                                        11,
                                                                        12
                                                                      ]),
                                                                      optionLabels: const [
                                                                        '1',
                                                                        '2',
                                                                        '3',
                                                                        '4',
                                                                        '5',
                                                                        '6',
                                                                        '7',
                                                                        '8',
                                                                        '9',
                                                                        '10',
                                                                        '11',
                                                                        '12'
                                                                      ],
                                                                      onChanged:
                                                                          (val) async {
                                                                        safeSetState(() =>
                                                                            _model.dDInicioMesValue =
                                                                                val);
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      width:
                                                                          80.0,
                                                                      height:
                                                                          48.0,
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          'Mês',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      elevation:
                                                                          2.0,
                                                                      borderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor2,
                                                                      borderWidth:
                                                                          0.0,
                                                                      borderRadius:
                                                                          8.0,
                                                                      margin: const EdgeInsetsDirectional
                                                                          .fromSTEB(
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
                                                                  ].divide(
                                                                      const SizedBox(
                                                                          width:
                                                                              8.0)),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      height:
                                                                          4.0)),
                                                            ),
                                                            Text(
                                                              'Até',
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
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    FlutterFlowDropDown<
                                                                        String>(
                                                                      controller: _model
                                                                              .dDFimAnoValueController ??=
                                                                          FormFieldController<
                                                                              String>(
                                                                        _model.dDFimAnoValue ??=
                                                                            dateTimeFormat(
                                                                          "yyyy",
                                                                          getCurrentTimestamp,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ),
                                                                      ),
                                                                      options:
                                                                          functions
                                                                              .gerarAnos()!,
                                                                      onChanged:
                                                                          (val) async {
                                                                        safeSetState(() =>
                                                                            _model.dDFimAnoValue =
                                                                                val);
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      width:
                                                                          156.0,
                                                                      height:
                                                                          48.0,
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          'Selecionar ano',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      elevation:
                                                                          2.0,
                                                                      borderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor2,
                                                                      borderWidth:
                                                                          0.0,
                                                                      borderRadius:
                                                                          8.0,
                                                                      margin: const EdgeInsetsDirectional
                                                                          .fromSTEB(
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
                                                                    FlutterFlowDropDown<
                                                                        int>(
                                                                      controller: _model
                                                                              .dDFimMesValueController ??=
                                                                          FormFieldController<
                                                                              int>(
                                                                        _model.dDFimMesValue ??=
                                                                            12,
                                                                      ),
                                                                      options: List<
                                                                          int>.from([
                                                                        1,
                                                                        2,
                                                                        3,
                                                                        4,
                                                                        5,
                                                                        6,
                                                                        7,
                                                                        8,
                                                                        9,
                                                                        10,
                                                                        11,
                                                                        12
                                                                      ]),
                                                                      optionLabels: const [
                                                                        '1',
                                                                        '2',
                                                                        '3',
                                                                        '4',
                                                                        '5',
                                                                        '6',
                                                                        '7',
                                                                        '8',
                                                                        '9',
                                                                        '10',
                                                                        '11',
                                                                        '12'
                                                                      ],
                                                                      onChanged:
                                                                          (val) async {
                                                                        safeSetState(() =>
                                                                            _model.dDFimMesValue =
                                                                                val);
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                                      width:
                                                                          80.0,
                                                                      height:
                                                                          48.0,
                                                                      textStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          'Mês',
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                        size:
                                                                            24.0,
                                                                      ),
                                                                      elevation:
                                                                          2.0,
                                                                      borderColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .customColor2,
                                                                      borderWidth:
                                                                          0.0,
                                                                      borderRadius:
                                                                          8.0,
                                                                      margin: const EdgeInsetsDirectional
                                                                          .fromSTEB(
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
                                                                  ].divide(
                                                                      const SizedBox(
                                                                          width:
                                                                              8.0)),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      height:
                                                                          4.0)),
                                                            ),
                                                          ].divide(
                                                              const SizedBox(
                                                                  width: 8.0)),
                                                        ),
                                                      ),
                                                    ),
                                                  Builder(
                                                    builder: (context) =>
                                                        FFButtonWidget(
                                                      onPressed: () async {
                                                        await showAlignedDialog(
                                                          barrierColor: Colors
                                                              .transparent,
                                                          context: context,
                                                          isGlobal: false,
                                                          avoidOverflow: true,
                                                          targetAnchor:
                                                              const AlignmentDirectional(
                                                                      1.0, 1.0)
                                                                  .resolve(
                                                                      Directionality.of(
                                                                          context)),
                                                          followerAnchor:
                                                              const AlignmentDirectional(
                                                                      1.0, -1.0)
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
                                                                    const SubMenuPainelImportarWidget(),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      text: 'Importar',
                                                      icon: const Icon(
                                                        Icons
                                                            .keyboard_arrow_down_sharp,
                                                        size: 24.0,
                                                      ),
                                                      options: FFButtonOptions(
                                                        width: 150.0,
                                                        height: 48.0,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(16.0,
                                                                0.0, 16.0, 0.0),
                                                        iconAlignment:
                                                            IconAlignment.end,
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                0.0, 0.0, 0.0),
                                                        color: FlutterFlowTheme
                                                                .of(context)
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
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      18.0,
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
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                    ),
                                                  ),
                                                  Builder(
                                                    builder: (context) =>
                                                        FFButtonWidget(
                                                      onPressed: () async {
                                                        await showAlignedDialog(
                                                          barrierColor: Colors
                                                              .transparent,
                                                          context: context,
                                                          isGlobal: false,
                                                          avoidOverflow: true,
                                                          targetAnchor:
                                                              const AlignmentDirectional(
                                                                      1.0, 1.0)
                                                                  .resolve(
                                                                      Directionality.of(
                                                                          context)),
                                                          followerAnchor:
                                                              const AlignmentDirectional(
                                                                      1.0, -1.0)
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
                                                                    const SubMenuPainelExportarWidget(),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      text: 'Exportar',
                                                      icon: const Icon(
                                                        Icons
                                                            .keyboard_arrow_down_sharp,
                                                        size: 24.0,
                                                      ),
                                                      options: FFButtonOptions(
                                                        width: 150.0,
                                                        height: 48.0,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(16.0,
                                                                0.0, 16.0, 0.0),
                                                        iconAlignment:
                                                            IconAlignment.end,
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(0.0,
                                                                0.0, 0.0, 0.0),
                                                        color: FlutterFlowTheme
                                                                .of(context)
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
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      18.0,
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
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                    ),
                                                  ),
                                                  if (responsiveVisibility(
                                                    context: context,
                                                    phone: false,
                                                    tablet: false,
                                                    tabletLandscape: false,
                                                    desktop: false,
                                                  ))
                                                    Builder(
                                                      builder: (context) =>
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
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (dialogContext) {
                                                              return Dialog(
                                                                elevation: 0,
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                alignment: const AlignmentDirectional(
                                                                        0.0,
                                                                        0.0)
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
                                                                      const PpInstrucoesImportacaoWidget(),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            FaIcon(
                                                              FontAwesomeIcons
                                                                  .questionCircle,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .icon,
                                                              size: 24.0,
                                                            ),
                                                            Text(
                                                              'Instruções para importar',
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
                                                                    fontSize:
                                                                        12.0,
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
                                                              const SizedBox(
                                                                  width: 4.0)),
                                                        ),
                                                      ),
                                                    ),
                                                ].divide(const SizedBox(
                                                    width: 16.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              24.0, 24.0, 24.0, 0.0),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: const Alignment(-1.0, 0),
                                            child: TabBar(
                                              isScrollable: true,
                                              labelColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              unselectedLabelColor:
                                                  FlutterFlowTheme.of(context)
                                                      .accent3,
                                              labelStyle: FlutterFlowTheme.of(
                                                      context)
                                                  .titleMedium
                                                  .override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleMedium
                                                              .fontStyle,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
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
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                              indicatorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              indicatorWeight: 3.0,
                                              tabs: const [
                                                Tab(
                                                  text: 'Propriedade',
                                                ),
                                                Tab(
                                                  text: 'Produção',
                                                ),
                                                Tab(
                                                  text: 'Reprodução',
                                                ),
                                                Tab(
                                                  text: 'Vendas',
                                                ),
                                              ],
                                              controller:
                                                  _model.tabBarController,
                                              onTap: (i) async {
                                                [
                                                  () async {},
                                                  () async {},
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
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              children: [
                                                SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    4.0,
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: (_model.apiRequestCompleter1 ??= Completer<
                                                                          ApiCallResponse>()
                                                                        ..complete(FunctionsSupabaseRebanhoGroup
                                                                            .listaRebanhosPropriedadeCall
                                                                            .call(
                                                                          propertyId: FFAppState()
                                                                              .propriedadeSelecionada
                                                                              .idPropriedade,
                                                                        )))
                                                                      .future,
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final listaRebanhoAnimalListaRebanhosPropriedadeResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Container(
                                                                      width:
                                                                          458.0,
                                                                      height:
                                                                          625.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                                4.0,
                                                                            color:
                                                                                Color(0x33000000),
                                                                            offset:
                                                                                Offset(
                                                                              0.0,
                                                                              2.0,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
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
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children:
                                                                              [
                                                                            Flexible(
                                                                              child: SingleChildScrollView(
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Rebanho atual por categoria animal (%)',
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
                                                                                      ],
                                                                                    ),
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        final lista = (listaRebanhoAnimalListaRebanhosPropriedadeResponse.jsonBody.toList().map<ListaRebanhoPropriedadeStruct?>(ListaRebanhoPropriedadeStruct.maybeFromMap).toList() as Iterable<ListaRebanhoPropriedadeStruct?>).withoutNulls.toList();
                                                                                        if (lista.isEmpty) {
                                                                                          return const Center(
                                                                                            child: SizedBox(
                                                                                              height: 300.0,
                                                                                              child: EmptyWidget(),
                                                                                            ),
                                                                                          );
                                                                                        }

                                                                                        return Column(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: List.generate(lista.length, (listaIndex) {
                                                                                            final listaItem = lista[listaIndex];
                                                                                            return Column(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              children: [
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      listaItem.categoria,
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
                                                                                                  ],
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      child: LayoutBuilder(
                                                                                                        builder: (context, constraints) {
                                                                                                          return LinearPercentIndicator(
                                                                                                            percent: listaItem.porcentagem / 100,
                                                                                                            width: constraints.maxWidth,
                                                                                                            lineHeight: 12.0,
                                                                                                            animation: true,
                                                                                                            animateFromLastPercent: true,
                                                                                                            progressColor: FlutterFlowTheme.of(context).primary,
                                                                                                            backgroundColor: FlutterFlowTheme.of(context).customColor5,
                                                                                                            barRadius: const Radius.circular(8.0),
                                                                                                            padding: EdgeInsets.zero,
                                                                                                          );
                                                                                                        },
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '${listaItem.porcentagem.toString()}% (${listaItem.quantidade.toString()})',
                                                                                                      maxLines: 1,
                                                                                                      softWrap: false,
                                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            fontSize: 12.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ].divide(const SizedBox(width: 8.0)),
                                                                                                ),
                                                                                              ].divide(const SizedBox(height: 4.0)),
                                                                                            );
                                                                                          }).divide(const SizedBox(height: 24.0)),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ].divide(const SizedBox(height: 24.0)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            FutureBuilder<ApiCallResponse>(
                                                                              future: FunctionsSupabaseRebanhoGroup.countRebanhoFiltrosCall.call(
                                                                                pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                pStatus: 'Na propriedade',
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
                                                                                final textCountRebanhoFiltrosResponse = snapshot.data!;

                                                                                return Text(
                                                                                  'Total: ${valueOrDefault<String>(
                                                                                    textCountRebanhoFiltrosResponse.jsonBody.toString(),
                                                                                    '0',
                                                                                  )}',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                );
                                                                              },
                                                                            ),
                                                                          ].divide(const SizedBox(height: 24.0)),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                Flexible(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        4.0,
                                                                        0.0),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                                4.0,
                                                                            color:
                                                                                Color(0x33000000),
                                                                            offset:
                                                                                Offset(
                                                                              0.0,
                                                                              2.0,
                                                                            ),
                                                                          )
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            24.0),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Flexible(
                                                                                  child: Text(
                                                                                    'Rebanho por período (Cabeça)',
                                                                                    textAlign: TextAlign.center,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: 2,
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
                                                                                ),
                                                                              ].divide(const SizedBox(width: 8.0)),
                                                                            ),
                                                                            if (FFAppState().propriedadeSelecionada.idPropriedade !=
                                                                                '')
                                                                              FutureBuilder<ApiCallResponse>(
                                                                                future: FunctionsSupabaseRebanhoGroup.anosComRebanhoCall.call(
                                                                                  propertyId: FFAppState().propriedadeSelecionada.idPropriedade,
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
                                                                                  final containerAnosComRebanhoResponse = snapshot.data!;

                                                                                  return Container(
                                                                                    decoration: const BoxDecoration(),
                                                                                    child: Visibility(
                                                                                      visible: FunctionsSupabaseRebanhoGroup.anosComRebanhoCall
                                                                                          .ano(
                                                                                            containerAnosComRebanhoResponse.jsonBody,
                                                                                          )!
                                                                                          .isNotEmpty,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 36.0),
                                                                                        child: Wrap(
                                                                                          spacing: 16.0,
                                                                                          runSpacing: 8.0,
                                                                                          alignment: WrapAlignment.start,
                                                                                          crossAxisAlignment: WrapCrossAlignment.end,
                                                                                          direction: Axis.horizontal,
                                                                                          runAlignment: WrapAlignment.start,
                                                                                          verticalDirection: VerticalDirection.down,
                                                                                          clipBehavior: Clip.none,
                                                                                          children: [
                                                                                            Column(
                                                                                              mainAxisSize: MainAxisSize.min,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text(
                                                                                                  'Início',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        font: GoogleFonts.poppins(
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                        letterSpacing: 0.0,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  children: [
                                                                                                    FlutterFlowDropDown<int>(
                                                                                                      controller: _model.dropDownValueController1 ??= FormFieldController<int>(
                                                                                                        _model.dropDownValue1 ??= FunctionsSupabaseRebanhoGroup.anosComRebanhoCall
                                                                                                            .ano(
                                                                                                              containerAnosComRebanhoResponse.jsonBody,
                                                                                                            )
                                                                                                            ?.firstOrNull,
                                                                                                      ),
                                                                                                      options: List<int>.from(FunctionsSupabaseRebanhoGroup.anosComRebanhoCall.ano(
                                                                                                        containerAnosComRebanhoResponse.jsonBody,
                                                                                                      )!),
                                                                                                      optionLabels: FunctionsSupabaseRebanhoGroup.anosComRebanhoCall
                                                                                                          .ano(
                                                                                                            containerAnosComRebanhoResponse.jsonBody,
                                                                                                          )!
                                                                                                          .map((e) => e.toString())
                                                                                                          .toList(),
                                                                                                      onChanged: (val) => safeSetState(() => _model.dropDownValue1 = val),
                                                                                                      width: 156.0,
                                                                                                      height: 48.0,
                                                                                                      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                      hintText: 'Selecionar ano',
                                                                                                      icon: Icon(
                                                                                                        Icons.keyboard_arrow_down_rounded,
                                                                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                        size: 24.0,
                                                                                                      ),
                                                                                                      elevation: 2.0,
                                                                                                      borderColor: FlutterFlowTheme.of(context).customColor2,
                                                                                                      borderWidth: 0.0,
                                                                                                      borderRadius: 8.0,
                                                                                                      margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                                      hidesUnderline: true,
                                                                                                      isOverButton: false,
                                                                                                      isSearchable: false,
                                                                                                      isMultiSelect: false,
                                                                                                    ),
                                                                                                    FlutterFlowDropDown<int>(
                                                                                                      controller: _model.dropDownValueController2 ??= FormFieldController<int>(
                                                                                                        _model.dropDownValue2 ??= 1,
                                                                                                      ),
                                                                                                      options: List<int>.from([
                                                                                                        1,
                                                                                                        2,
                                                                                                        3,
                                                                                                        4,
                                                                                                        5,
                                                                                                        6,
                                                                                                        7,
                                                                                                        8,
                                                                                                        9,
                                                                                                        10,
                                                                                                        11,
                                                                                                        12
                                                                                                      ]),
                                                                                                      optionLabels: const [
                                                                                                        '1',
                                                                                                        '2',
                                                                                                        '3',
                                                                                                        '4',
                                                                                                        '5',
                                                                                                        '6',
                                                                                                        '7',
                                                                                                        '8',
                                                                                                        '9',
                                                                                                        '10',
                                                                                                        '11',
                                                                                                        '12'
                                                                                                      ],
                                                                                                      onChanged: (val) => safeSetState(() => _model.dropDownValue2 = val),
                                                                                                      width: 80.0,
                                                                                                      height: 48.0,
                                                                                                      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                      hintText: 'Mês',
                                                                                                      icon: Icon(
                                                                                                        Icons.keyboard_arrow_down_rounded,
                                                                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                        size: 24.0,
                                                                                                      ),
                                                                                                      elevation: 2.0,
                                                                                                      borderColor: FlutterFlowTheme.of(context).customColor2,
                                                                                                      borderWidth: 0.0,
                                                                                                      borderRadius: 8.0,
                                                                                                      margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                                      hidesUnderline: true,
                                                                                                      isOverButton: false,
                                                                                                      isSearchable: false,
                                                                                                      isMultiSelect: false,
                                                                                                    ),
                                                                                                  ].divide(const SizedBox(width: 8.0)),
                                                                                                ),
                                                                                              ].divide(const SizedBox(height: 4.0)),
                                                                                            ),
                                                                                            Column(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Text(
                                                                                                  'Fim',
                                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                        font: GoogleFonts.poppins(
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                        ),
                                                                                                        letterSpacing: 0.0,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                                  children: [
                                                                                                    FlutterFlowDropDown<int>(
                                                                                                      controller: _model.dropDownValueController3 ??= FormFieldController<int>(
                                                                                                        _model.dropDownValue3 ??= FunctionsSupabaseRebanhoGroup.anosComRebanhoCall
                                                                                                            .ano(
                                                                                                              containerAnosComRebanhoResponse.jsonBody,
                                                                                                            )
                                                                                                            ?.firstOrNull,
                                                                                                      ),
                                                                                                      options: List<int>.from(FunctionsSupabaseRebanhoGroup.anosComRebanhoCall.ano(
                                                                                                        containerAnosComRebanhoResponse.jsonBody,
                                                                                                      )!),
                                                                                                      optionLabels: FunctionsSupabaseRebanhoGroup.anosComRebanhoCall
                                                                                                          .ano(
                                                                                                            containerAnosComRebanhoResponse.jsonBody,
                                                                                                          )!
                                                                                                          .map((e) => e.toString())
                                                                                                          .toList(),
                                                                                                      onChanged: (val) => safeSetState(() => _model.dropDownValue3 = val),
                                                                                                      width: 156.0,
                                                                                                      height: 48.0,
                                                                                                      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                      hintText: 'Selecionar ano',
                                                                                                      icon: Icon(
                                                                                                        Icons.keyboard_arrow_down_rounded,
                                                                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                        size: 24.0,
                                                                                                      ),
                                                                                                      elevation: 2.0,
                                                                                                      borderColor: FlutterFlowTheme.of(context).customColor2,
                                                                                                      borderWidth: 0.0,
                                                                                                      borderRadius: 8.0,
                                                                                                      margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                                      hidesUnderline: true,
                                                                                                      isOverButton: false,
                                                                                                      isSearchable: false,
                                                                                                      isMultiSelect: false,
                                                                                                    ),
                                                                                                    FlutterFlowDropDown<int>(
                                                                                                      controller: _model.dropDownValueController4 ??= FormFieldController<int>(
                                                                                                        _model.dropDownValue4 ??= 12,
                                                                                                      ),
                                                                                                      options: List<int>.from([
                                                                                                        1,
                                                                                                        2,
                                                                                                        3,
                                                                                                        4,
                                                                                                        5,
                                                                                                        6,
                                                                                                        7,
                                                                                                        8,
                                                                                                        9,
                                                                                                        10,
                                                                                                        11,
                                                                                                        12
                                                                                                      ]),
                                                                                                      optionLabels: const [
                                                                                                        '1',
                                                                                                        '2',
                                                                                                        '3',
                                                                                                        '4',
                                                                                                        '5',
                                                                                                        '6',
                                                                                                        '7',
                                                                                                        '8',
                                                                                                        '9',
                                                                                                        '10',
                                                                                                        '11',
                                                                                                        '12'
                                                                                                      ],
                                                                                                      onChanged: (val) => safeSetState(() => _model.dropDownValue4 = val),
                                                                                                      width: 80.0,
                                                                                                      height: 48.0,
                                                                                                      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                            font: GoogleFonts.poppins(
                                                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                          ),
                                                                                                      hintText: 'Mês',
                                                                                                      icon: Icon(
                                                                                                        Icons.keyboard_arrow_down_rounded,
                                                                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                        size: 24.0,
                                                                                                      ),
                                                                                                      elevation: 2.0,
                                                                                                      borderColor: FlutterFlowTheme.of(context).customColor2,
                                                                                                      borderWidth: 0.0,
                                                                                                      borderRadius: 8.0,
                                                                                                      margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                                      hidesUnderline: true,
                                                                                                      isOverButton: false,
                                                                                                      isSearchable: false,
                                                                                                      isMultiSelect: false,
                                                                                                    ),
                                                                                                  ].divide(const SizedBox(width: 8.0)),
                                                                                                ),
                                                                                              ].divide(const SizedBox(height: 4.0)),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
                                                                                              child: FlutterFlowIconButton(
                                                                                                borderRadius: 8.0,
                                                                                                buttonSize: 40.0,
                                                                                                fillColor: FlutterFlowTheme.of(context).primary,
                                                                                                icon: Icon(
                                                                                                  Icons.refresh_sharp,
                                                                                                  color: FlutterFlowTheme.of(context).info,
                                                                                                  size: 24.0,
                                                                                                ),
                                                                                                showLoadingIndicator: true,
                                                                                                onPressed: () async {
                                                                                                  safeSetState(() => _model.apiRequestCompleter2 = null);
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            Flexible(
                                                                              child: FutureBuilder<ApiCallResponse>(
                                                                                future: (_model.apiRequestCompleter2 ??= Completer<ApiCallResponse>()
                                                                                      ..complete(FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall.call(
                                                                                        propertyId: FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                        startYear: valueOrDefault<int>(
                                                                                          _model.dropDownValue1,
                                                                                          DateTime.now().year,
                                                                                        ),
                                                                                        startMonth: valueOrDefault<int>(
                                                                                          _model.dropDownValue2,
                                                                                          1,
                                                                                        ),
                                                                                        endYear: valueOrDefault<int>(
                                                                                          _model.dropDownValue3,
                                                                                          DateTime.now().year,
                                                                                        ),
                                                                                        endMonth: valueOrDefault<int>(
                                                                                          _model.dropDownValue4,
                                                                                          12,
                                                                                        ),
                                                                                      )))
                                                                                    .future,
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
                                                                                  final containerChartRebGraficoQtdRebanhoPeriodoResponse = snapshot.data!;

                                                                                  return Container(
                                                                                    decoration: const BoxDecoration(),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        if ((FFAppState().propriedadeSelecionada.idPropriedade != '') &&
                                                                                            (FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall
                                                                                                .anos(
                                                                                                  containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                )!
                                                                                                .isNotEmpty))
                                                                                          SizedBox(
                                                                                            width: double.infinity,
                                                                                            height: 400.0,
                                                                                            child: custom_widgets.RebanhoPeriodoChart(
                                                                                              width: double.infinity,
                                                                                              height: 400.0,
                                                                                              items: containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                            ),
                                                                                          ),
                                                                                        if ((FFAppState().propriedadeSelecionada.idPropriedade == '') ||
                                                                                            (FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall
                                                                                                    .anos(
                                                                                                      containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                    )
                                                                                                    ?.length ==
                                                                                                0))
                                                                                          Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 48.0),
                                                                                            child: SizedBox(
                                                                                              height: 300.0,
                                                                                              child: wrapWithModel(
                                                                                                model: _model.emptyModel,
                                                                                                updateCallback: () => safeSetState(() {}),
                                                                                                child: const EmptyWidget(),
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
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                          ),
                                                        ]
                                                            .addToStart(
                                                                const SizedBox(
                                                                    height:
                                                                        24.0))
                                                            .addToEnd(
                                                                const SizedBox(
                                                                    height:
                                                                        24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 24.0, 0.0, 0.0),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Bezerros ',
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
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              if (responsiveVisibility(
                                                                context:
                                                                    context,
                                                                phone: false,
                                                                tablet: false,
                                                                tabletLandscape:
                                                                    false,
                                                              ))
                                                                Expanded(
                                                                  child: FutureBuilder<
                                                                      ApiCallResponse>(
                                                                    future: FunctionsSupabaseRebanhoGroup
                                                                        .qtdAnimaisMortalidadeCall
                                                                        .call(
                                                                      propertyId: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      startYear:
                                                                          functions
                                                                              .converterTextoEmNumero(_model.dDInicioAnoValue),
                                                                      startMonth:
                                                                          _model
                                                                              .dDInicioMesValue,
                                                                      endYear: functions
                                                                          .converterTextoEmNumero(
                                                                              _model.dDFimAnoValue),
                                                                      endMonth:
                                                                          _model
                                                                              .dDFimMesValue,
                                                                    ),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      // Customize what your widget looks like when it's loading.
                                                                      if (!snapshot
                                                                          .hasData) {
                                                                        return Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                50.0,
                                                                            height:
                                                                                50.0,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                                FlutterFlowTheme.of(context).primary,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      final containerQtdAnimaisMortalidadeResponse =
                                                                          snapshot
                                                                              .data!;

                                                                      return Material(
                                                                        color: Colors
                                                                            .transparent,
                                                                        elevation:
                                                                            2.0,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              168.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                BorderRadius.circular(6.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Taxa de mortalidade pré-desmama por período (%)',
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
                                                                                Text(
                                                                                  '${valueOrDefault<String>(
                                                                                    FunctionsSupabaseRebanhoGroup.qtdAnimaisMortalidadeCall
                                                                                        .taxaMortalidade(
                                                                                          containerQtdAnimaisMortalidadeResponse.jsonBody,
                                                                                        )
                                                                                        ?.toString(),
                                                                                    '0',
                                                                                  )}%',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
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
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              if (responsiveVisibility(
                                                                context:
                                                                    context,
                                                                phone: false,
                                                                tablet: false,
                                                                tabletLandscape:
                                                                    false,
                                                              ))
                                                                Expanded(
                                                                  child: FutureBuilder<
                                                                      ApiCallResponse>(
                                                                    future: FunctionsSupabaseRebanhoGroup
                                                                        .qtdAnimaisDesmamaCall
                                                                        .call(
                                                                      propertyId: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      startYear:
                                                                          functions
                                                                              .converterTextoEmNumero(_model.dDInicioAnoValue),
                                                                      startMonth:
                                                                          _model
                                                                              .dDInicioMesValue,
                                                                      endYear: functions
                                                                          .converterTextoEmNumero(
                                                                              _model.dDFimAnoValue),
                                                                      endMonth:
                                                                          _model
                                                                              .dDFimMesValue,
                                                                    ),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      // Customize what your widget looks like when it's loading.
                                                                      if (!snapshot
                                                                          .hasData) {
                                                                        return Center(
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                50.0,
                                                                            height:
                                                                                50.0,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                                FlutterFlowTheme.of(context).primary,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      final containerQtdAnimaisDesmamaResponse =
                                                                          snapshot
                                                                              .data!;

                                                                      return Material(
                                                                        color: Colors
                                                                            .transparent,
                                                                        elevation:
                                                                            2.0,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              168.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                BorderRadius.circular(6.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Taxa de aproveitamento ao Desmame (Desmamados/Nascidos) por período (%)',
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
                                                                                Text(
                                                                                  () {
                                                                                    final pct = FunctionsSupabaseRebanhoGroup.qtdAnimaisDesmamaCall.pctDesmamados(
                                                                                      containerQtdAnimaisDesmamaResponse.jsonBody,
                                                                                    );
                                                                                    if (pct == null) {
                                                                                      return '0.00%';
                                                                                    }
                                                                                    return '${pct.toStringAsFixed(2)}%';
                                                                                  }(),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
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
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        32.0)),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .idadeDesmamaCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    sexo: _model.filtroSexoIdadeDesmamaValues.isEmpty ||
                                                                            _model.filtroSexoIdadeDesmamaValues.length ==
                                                                                2
                                                                        ? 'T'
                                                                        : _model
                                                                            .filtroSexoIdadeDesmamaValues
                                                                            .first,
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerIdadeDesmamaResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
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
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      'Idade desmama (Meses)',
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
                                                                                  ),
                                                                                  _buildMultiFilterChip(
                                                                                    context,
                                                                                    label: 'Sexo',
                                                                                    selectedValues: _model.filtroSexoIdadeDesmamaValues,
                                                                                    options: const [
                                                                                      'M',
                                                                                      'F'
                                                                                    ],
                                                                                    optionLabels: const [
                                                                                      'Macho',
                                                                                      'Fêmea'
                                                                                    ],
                                                                                    onChanged: (vals) {
                                                                                      safeSetState(() {
                                                                                        _model.filtroSexoIdadeDesmamaValues = vals;
                                                                                      });
                                                                                    },
                                                                                    onClear: () {
                                                                                      safeSetState(() {
                                                                                        _model.filtroSexoIdadeDesmamaValues = [];
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Expanded(
                                                                                child: SizedBox(
                                                                                  width: double.infinity,
                                                                                  height: 80.0,
                                                                                  child: custom_widgets.MetricReadOnlySlider(
                                                                                    width: double.infinity,
                                                                                    height: 80.0,
                                                                                    items: SupabaseEdgeGroup.idadeDesmamaCall.items(
                                                                                      containerIdadeDesmamaResponse.jsonBody,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .pesoDesmamaCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    sexo: _model.filtroSexoPesoDesmamaValues.isEmpty ||
                                                                            _model.filtroSexoPesoDesmamaValues.length ==
                                                                                2
                                                                        ? 'T'
                                                                        : _model
                                                                            .filtroSexoPesoDesmamaValues
                                                                            .first,
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerPesoDesmamaResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
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
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      'Peso desmama (kg)',
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
                                                                                  ),
                                                                                  _buildMultiFilterChip(
                                                                                    context,
                                                                                    label: 'Sexo',
                                                                                    selectedValues: _model.filtroSexoPesoDesmamaValues,
                                                                                    options: const [
                                                                                      'M',
                                                                                      'F'
                                                                                    ],
                                                                                    optionLabels: const [
                                                                                      'Macho',
                                                                                      'Fêmea'
                                                                                    ],
                                                                                    onChanged: (vals) {
                                                                                      safeSetState(() {
                                                                                        _model.filtroSexoPesoDesmamaValues = vals;
                                                                                      });
                                                                                    },
                                                                                    onClear: () {
                                                                                      safeSetState(() {
                                                                                        _model.filtroSexoPesoDesmamaValues = [];
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Expanded(
                                                                                child: SizedBox(
                                                                                  width: double.infinity,
                                                                                  height: 80.0,
                                                                                  child: custom_widgets.MetricReadOnlySlider(
                                                                                    width: double.infinity,
                                                                                    height: 80.0,
                                                                                    items: SupabaseEdgeGroup.pesoDesmamaCall.items(
                                                                                      containerPesoDesmamaResponse.jsonBody,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        32.0)),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .nascimentosPeriodoCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    raca: _model
                                                                            .filtroRacaNascimentoValues
                                                                            .isNotEmpty
                                                                        ? _model
                                                                            .filtroRacaNascimentoValues
                                                                            .join(',')
                                                                        : '',
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerNascimentosPeriodoResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Text(
                                                                                            'Nascimentos no período (cabeça)',
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
                                                                                        ),
                                                                                        const SizedBox(width: 12.0),
                                                                                        _buildTotalBadge(
                                                                                          context,
                                                                                          _sumField(
                                                                                            SupabaseEdgeGroup.nascimentosPeriodoCall.items(
                                                                                                  containerNascimentosPeriodoResponse.jsonBody,
                                                                                                ) ??
                                                                                                containerNascimentosPeriodoResponse.jsonBody,
                                                                                            'total',
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  _buildMultiFilterChip(
                                                                                    context,
                                                                                    label: 'Raça',
                                                                                    selectedValues: _model.filtroRacaNascimentoValues,
                                                                                    options: FFAppState().raca,
                                                                                    optionLabels: FFAppState().raca,
                                                                                    onChanged: (vals) {
                                                                                      safeSetState(() {
                                                                                        _model.filtroRacaNascimentoValues = vals;
                                                                                      });
                                                                                    },
                                                                                    onClear: () {
                                                                                      safeSetState(() {
                                                                                        _model.filtroRacaNascimentoValues = [];
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ].divide(const SizedBox(width: 16.0)),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    constraints: const BoxConstraints(
                                                                                      maxHeight: 350.0,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    ),
                                                                                    child: containerNascimentosPeriodoResponse.succeeded
                                                                                        ? custom_widgets.NascimentosChart(
                                                                                            items: SupabaseEdgeGroup.nascimentosPeriodoCall.items(
                                                                                                  containerNascimentosPeriodoResponse.jsonBody,
                                                                                                ) ??
                                                                                                containerNascimentosPeriodoResponse.jsonBody,
                                                                                          )
                                                                                        : Center(
                                                                                            child: Text(
                                                                                              'Falha ao carregar dados.',
                                                                                              style: FlutterFlowTheme.of(context).labelMedium,
                                                                                            ),
                                                                                          ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .mortalidadePeriodoCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    causa: _model
                                                                            .filtroMotivoMorteMortalidadeValues
                                                                            .isNotEmpty
                                                                        ? _model
                                                                            .filtroMotivoMorteMortalidadeValues
                                                                            .join(',')
                                                                        : '',
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerMortalidadePeriodoResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Text(
                                                                                            'Mortalidade de bezerros no Período (cabeça)',
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
                                                                                        ),
                                                                                        const SizedBox(width: 12.0),
                                                                                        _buildTotalBadge(
                                                                                          context,
                                                                                          _sumField(
                                                                                            SupabaseEdgeGroup.mortalidadePeriodoCall.items(
                                                                                                  containerMortalidadePeriodoResponse.jsonBody,
                                                                                                ) ??
                                                                                                containerMortalidadePeriodoResponse.jsonBody,
                                                                                            'total',
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  _buildMultiFilterChip(
                                                                                    context,
                                                                                    label: 'Causa',
                                                                                    selectedValues: _model.filtroMotivoMorteMortalidadeValues,
                                                                                    options: const [
                                                                                      'ACIDENTE',
                                                                                      'ANIMAL PEÇONHENTO',
                                                                                      'ATAQUE AVE',
                                                                                      'DESCONHECIDA',
                                                                                      'DOENÇA',
                                                                                      'ESTRESSE TÉRMICO',
                                                                                      'INTOXICAÇÃO',
                                                                                      'MANTIMENTO',
                                                                                      'NATIMORTO',
                                                                                      'NEONATO',
                                                                                      'PARTO DISTÓCICO',
                                                                                      'PREDADOR',
                                                                                    ],
                                                                                    optionLabels: const [
                                                                                      'ACIDENTE',
                                                                                      'ANIMAL PEÇONHENTO',
                                                                                      'ATAQUE AVE',
                                                                                      'DESCONHECIDA',
                                                                                      'DOENÇA',
                                                                                      'ESTRESSE TÉRMICO',
                                                                                      'INTOXICAÇÃO',
                                                                                      'MANTIMENTO',
                                                                                      'NATIMORTO',
                                                                                      'NEONATO',
                                                                                      'PARTO DISTÓCICO',
                                                                                      'PREDADOR',
                                                                                    ],
                                                                                    onChanged: (vals) {
                                                                                      safeSetState(() {
                                                                                        _model.filtroMotivoMorteMortalidadeValues = vals;
                                                                                      });
                                                                                    },
                                                                                    onClear: () {
                                                                                      safeSetState(() {
                                                                                        _model.filtroMotivoMorteMortalidadeValues = [];
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ].divide(const SizedBox(width: 16.0)),
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    decoration: const BoxDecoration(),
                                                                                    child: SizedBox(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                      child: containerMortalidadePeriodoResponse.succeeded
                                                                                          ? custom_widgets.MortalidadeChart(
                                                                                              items: SupabaseEdgeGroup.mortalidadePeriodoCall.items(
                                                                                                    containerMortalidadePeriodoResponse.jsonBody,
                                                                                                  ) ??
                                                                                                  containerMortalidadePeriodoResponse.jsonBody,
                                                                                            )
                                                                                          : Center(
                                                                                              child: Text(
                                                                                                'Falha ao carregar dados.',
                                                                                                style: FlutterFlowTheme.of(context).labelMedium,
                                                                                              ),
                                                                                            ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        24.0)),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .desmamaPeriodoCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    agrupar:
                                                                        'mes',
                                                                    sexo:
                                                                        'todos',
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerDesmamaPeriodoResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            480.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          minHeight:
                                                                              480.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    'Desmamas no período (cabeça)',
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
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildTotalBadge(
                                                                                    context,
                                                                                    _sumField(
                                                                                      SupabaseEdgeGroup.desmamaPeriodoCall.items(
                                                                                            containerDesmamaPeriodoResponse.jsonBody,
                                                                                          ) ??
                                                                                          containerDesmamaPeriodoResponse.jsonBody,
                                                                                      'total',
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(16.0),
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    constraints: const BoxConstraints(
                                                                                      maxHeight: 350.0,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    ),
                                                                                    child: containerDesmamaPeriodoResponse.succeeded
                                                                                        ? custom_widgets.NascimentosChart(
                                                                                            items: SupabaseEdgeGroup.desmamaPeriodoCall.items(
                                                                                                  containerDesmamaPeriodoResponse.jsonBody,
                                                                                                ) ??
                                                                                                containerDesmamaPeriodoResponse.jsonBody,
                                                                                          )
                                                                                        : Center(
                                                                                            child: Text(
                                                                                              'Falha ao carregar dados.',
                                                                                              style: FlutterFlowTheme.of(context).labelMedium,
                                                                                            ),
                                                                                          ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .projecaoDesmamasCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    agrupar:
                                                                        'mes',
                                                                    sexo: _model.filtroSexoProjDesmamaValues.isEmpty ||
                                                                            _model.filtroSexoProjDesmamaValues.length ==
                                                                                2
                                                                        ? 'Todos'
                                                                        : _model
                                                                            .filtroSexoProjDesmamaValues
                                                                            .first,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerProjecaoDesmamasResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            480.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              SingleChildScrollView(
                                                                                scrollDirection: Axis.horizontal,
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Projeção de desmamas no período (cabeça)',
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
                                                                                        const SizedBox(width: 12.0),
                                                                                        _buildTotalBadge(
                                                                                          context,
                                                                                          _sumProjecaoDesmamas(
                                                                                            SupabaseEdgeGroup.projecaoDesmamasCall.items(
                                                                                                  containerProjecaoDesmamasResponse.jsonBody,
                                                                                                ) ??
                                                                                                containerProjecaoDesmamasResponse.jsonBody,
                                                                                            _model.ddMesesValue ?? '6',
                                                                                            _model.filtroSexoProjDesmamaValues.isEmpty || _model.filtroSexoProjDesmamaValues.length == 2 ? 'Todos' : _model.filtroSexoProjDesmamaValues.first,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    const SizedBox(width: 12.0),
                                                                                    _buildMultiFilterChip(
                                                                                      context,
                                                                                      label: 'Sexo',
                                                                                      selectedValues: _model.filtroSexoProjDesmamaValues,
                                                                                      options: const [
                                                                                        'Macho',
                                                                                        'Fêmea'
                                                                                      ],
                                                                                      optionLabels: const [
                                                                                        'Macho',
                                                                                        'Fêmea'
                                                                                      ],
                                                                                      onChanged: (vals) {
                                                                                        safeSetState(() {
                                                                                          _model.filtroSexoProjDesmamaValues = vals;
                                                                                        });
                                                                                      },
                                                                                      onClear: () {
                                                                                        safeSetState(() {
                                                                                          _model.filtroSexoProjDesmamaValues = [];
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                    const SizedBox(width: 12.0),
                                                                                    _buildSingleFilterChip(
                                                                                      context,
                                                                                      label: 'Meses',
                                                                                      selectedValue: _model.ddMesesValue,
                                                                                      options: const [
                                                                                        '6',
                                                                                        '7',
                                                                                        '8'
                                                                                      ],
                                                                                      optionLabels: const [
                                                                                        '6 meses',
                                                                                        '7 meses',
                                                                                        '8 meses'
                                                                                      ],
                                                                                      onChanged: (val) {
                                                                                        safeSetState(() {
                                                                                          _model.ddMesesValue = val;
                                                                                        });
                                                                                      },
                                                                                      onClear: () {
                                                                                        safeSetState(() {
                                                                                          _model.ddMesesValue = '6';
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 350.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: containerProjecaoDesmamasResponse.succeeded
                                                                                      ? custom_widgets.ProjecaoDesmamasChart(
                                                                                          items: SupabaseEdgeGroup.projecaoDesmamasCall.items(
                                                                                                containerProjecaoDesmamasResponse.jsonBody,
                                                                                              ) ??
                                                                                              containerProjecaoDesmamasResponse.jsonBody,
                                                                                          filtroSexo: _model.filtroSexoProjDesmamaValues.isEmpty || _model.filtroSexoProjDesmamaValues.length == 2 ? 'Todos' : _model.filtroSexoProjDesmamaValues.first,
                                                                                          filtroIdadeMeses: _model.ddMesesValue,
                                                                                        )
                                                                                      : Center(
                                                                                          child: Text(
                                                                                            'Falha ao carregar dados.',
                                                                                            style: FlutterFlowTheme.of(context).labelMedium,
                                                                                          ),
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        24.0)),
                                                          ),
                                                        ),
                                                      ]
                                                          .divide(
                                                              const SizedBox(
                                                                  height: 32.0))
                                                          .addToEnd(
                                                              const SizedBox(
                                                                  height:
                                                                      24.0)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 24.0, 0.0, 0.0),
                                                  child: SingleChildScrollView(
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(
                                                      parent:
                                                          BouncingScrollPhysics(),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Reprodução',
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
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupaEdgeGroup
                                                                      .reproducaoIdadeMediaPrimeraCriaCall
                                                                      .call(
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    dataInicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    dataFim:
                                                                        _painelPeriodoDataFim(),
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerReproducaoIdadeMediaPrimeraCriaResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            550.0,
                                                                        height:
                                                                            200.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxWidth:
                                                                              550.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    'Idade média da primeira cria (meses)',
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
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                width: double.infinity,
                                                                                height: 100.0,
                                                                                child: custom_widgets.MetricReadOnlySlider(
                                                                                  width: double.infinity,
                                                                                  height: 100.0,
                                                                                  items: getJsonField(
                                                                                    containerReproducaoIdadeMediaPrimeraCriaResponse.jsonBody,
                                                                                    r'''$.items''',
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupaEdgeGroup
                                                                      .intervaloEntrePartosMesesCall
                                                                      .call(
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    dataInicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    dataFim:
                                                                        _painelPeriodoDataFim(),
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerIntervaloEntrePartosMesesResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            550.0,
                                                                        height:
                                                                            200.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxWidth:
                                                                              550.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    'Intervalo entre partos (meses)',
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
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                width: double.infinity,
                                                                                height: 100.0,
                                                                                child: custom_widgets.MetricReadOnlySlider(
                                                                                  width: double.infinity,
                                                                                  height: 100.0,
                                                                                  items: getJsonField(
                                                                                    containerIntervaloEntrePartosMesesResponse.jsonBody,
                                                                                    r'''$.items''',
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        32.0)),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  24.0,
                                                                  0.0),
                                                          child: Wrap(
                                                            spacing: 24.0,
                                                            runSpacing: 24.0,
                                                            alignment:
                                                                WrapAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                width: 550.0,
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  key: ValueKey(
                                                                    'taxa_concepcao_future_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}_${_model.filtroLoteTaxaConcepcaoValues.join(',')}_${_model.filtroTouroTaxaConcepcaoValues.join(',')}_${_model.filtroInseminadorTaxaConcepcaoValues.join(',')}_${_model.filtroRessincTaxaConcepcaoValues.join(',')}',
                                                                  ),
                                                                  future: () {
                                                                    final taxaConcepcaoKey =
                                                                        'taxa_concepcao_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}_${_model.filtroLoteTaxaConcepcaoValues.join(',')}_${_model.filtroTouroTaxaConcepcaoValues.join(',')}_${_model.filtroInseminadorTaxaConcepcaoValues.join(',')}_${_model.filtroRessincTaxaConcepcaoValues.join(',')}';
                                                                    if (_model
                                                                            .taxaConcepcaoFutureKey !=
                                                                        taxaConcepcaoKey) {
                                                                      _model.taxaConcepcaoFutureKey =
                                                                          taxaConcepcaoKey;
                                                                      _model.taxaConcepcaoFuture = SupabaseEdgeGroup
                                                                          .taxaConcepcaoGetCall
                                                                          .call(
                                                                        idPropriedade: FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                        dataInicio:
                                                                            _painelPeriodoDataInicio(),
                                                                        dataFim:
                                                                            _painelPeriodoDataFim(),
                                                                        pLoteId: _model
                                                                            .filtroLoteTaxaConcepcaoValues
                                                                            .join(','),
                                                                        pIdRebanhoReprodutor: _model
                                                                            .filtroTouroTaxaConcepcaoValues
                                                                            .join(','),
                                                                        pInseminador: _model
                                                                            .filtroInseminadorTaxaConcepcaoValues
                                                                            .join(','),
                                                                        pRessinc: _model
                                                                            .filtroRessincTaxaConcepcaoValues
                                                                            .join(','),
                                                                      );
                                                                    }
                                                                    return _model
                                                                        .taxaConcepcaoFuture;
                                                                  }(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Não mostrar loading no container inteiro, apenas no gráfico
                                                                    final isLoading = snapshot.connectionState ==
                                                                            ConnectionState
                                                                                .waiting ||
                                                                        !snapshot
                                                                            .hasData;
                                                                    final containerTaxaConcepcaoResponse = snapshot
                                                                            .hasData
                                                                        ? snapshot
                                                                            .data!
                                                                        : null;

                                                                    final dataInicioStr =
                                                                        _painelPeriodoDataInicio();
                                                                    final dataFimStr =
                                                                        _painelPeriodoDataFim();

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            433.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              433.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Text(
                                                                                    'Taxa de concepção',
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
                                                                                ],
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                                                child: RepaintBoundary(
                                                                                  child: Wrap(
                                                                                    spacing: 8.0,
                                                                                    runSpacing: 8.0,
                                                                                    children: [
                                                                                      FutureBuilder<List<dynamic>>(
                                                                                        key: ValueKey('lotes_filtro_taxa_concepcao_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}'),
                                                                                        future: () {
                                                                                          final dataInicioFiltro = _painelPeriodoDataInicio();
                                                                                          final dataFimFiltro = _painelPeriodoDataFim();

                                                                                          return Future.wait([
                                                                                            ReproducaoTable().queryRows(
                                                                                              queryFn: (q) => q
                                                                                                  .eqOrNull(
                                                                                                    'id_propriedade',
                                                                                                    FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                                  )
                                                                                                  .eqOrNull(
                                                                                                    'deletado',
                                                                                                    'NAO',
                                                                                                  )
                                                                                                  .or('and(data_inseminacao.gte.$dataInicioFiltro,data_inseminacao.lte.$dataFimFiltro),and(data_inicial.gte.$dataInicioFiltro,data_inicial.lte.$dataFimFiltro)'),
                                                                                              limit: 5000,
                                                                                            ),
                                                                                            LotesTable().queryRows(
                                                                                              queryFn: (q) => q
                                                                                                  .eqOrNull(
                                                                                                    'id_propriedade',
                                                                                                    FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                                  )
                                                                                                  .eqOrNull(
                                                                                                    'deletado',
                                                                                                    'NAO',
                                                                                                  ),
                                                                                              limit: 5000,
                                                                                            ),
                                                                                          ]);
                                                                                        }(),
                                                                                        builder: (context, lotesSnapshot) {
                                                                                          if (!lotesSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          final reproRows = lotesSnapshot.data![0] as List<ReproducaoRow>;
                                                                                          final lotesRows = lotesSnapshot.data![1] as List<LotesRow>;

                                                                                          final lotesComReproducao = reproRows.map((e) => e.idLote).withoutNulls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();

                                                                                          final lotes = lotesRows.where((e) {
                                                                                            final idLote = e.idLote?.trim();
                                                                                            return idLote != null && idLote.isNotEmpty && lotesComReproducao.contains(idLote);
                                                                                          }).toList();

                                                                                          final loteOptions = lotes.map((e) => e.idLote?.trim() ?? '').where((e) => e.isNotEmpty).toList();
                                                                                          final loteLabels = lotes.map((e) => e.nome?.trim() ?? '').where((e) => e.isNotEmpty).toList();

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Lote',
                                                                                            selectedValues: _model.filtroLoteTaxaConcepcaoValues,
                                                                                            options: loteOptions,
                                                                                            optionLabels: loteLabels,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroLoteTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroLoteTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      FutureBuilder<List<({String id, String nome})>>(
                                                                                        key: ValueKey('touros_filtro_taxa_concepcao_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}'),
                                                                                        future: _carregarTourosPeriodo(),
                                                                                        builder: (context, tourosSnapshot) {
                                                                                          if (!tourosSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          final touros = tourosSnapshot.data!;

                                                                                          final touroOptions = touros.map((e) => e.id).toList();
                                                                                          final touroLabels = touros.map((e) => e.nome).toList();

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Touro',
                                                                                            selectedValues: _model.filtroTouroTaxaConcepcaoValues,
                                                                                            options: touroOptions,
                                                                                            optionLabels: touroLabels,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroTouroTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroTouroTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      FutureBuilder<List<ReproducaoRow>>(
                                                                                        key: ValueKey('inseminadores_filtro_taxa_concepcao_${FFAppState().propriedadeSelecionada.idPropriedade}'),
                                                                                        future: ReproducaoTable().queryRows(
                                                                                          queryFn: (q) => q
                                                                                              .eqOrNull(
                                                                                                'id_propriedade',
                                                                                                FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'deletado',
                                                                                                'NAO',
                                                                                              ),
                                                                                        ),
                                                                                        builder: (context, reproSnapshot) {
                                                                                          if (!reproSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          final rows = reproSnapshot.data!;
                                                                                          final inseminadores = rows.map((e) => e.inseminador).withoutNulls.map((e) => e.trim()).where((e) => e.isNotEmpty).toList().unique((e) => e);

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Inseminador',
                                                                                            selectedValues: _model.filtroInseminadorTaxaConcepcaoValues,
                                                                                            options: inseminadores,
                                                                                            optionLabels: inseminadores,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroInseminadorTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroInseminadorTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      FutureBuilder<List<ReproducaoRow>>(
                                                                                        key: ValueKey('ressinc_filtro_taxa_concepcao_${FFAppState().propriedadeSelecionada.idPropriedade}'),
                                                                                        future: ReproducaoTable().queryRows(
                                                                                          queryFn: (q) => q
                                                                                              .eqOrNull(
                                                                                                'id_propriedade',
                                                                                                FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'deletado',
                                                                                                'NAO',
                                                                                              ),
                                                                                        ),
                                                                                        builder: (context, reproSnapshot) {
                                                                                          if (!reproSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          // Protocolos gravados em reproducao.ressinc. 'NAO'/vazio = sem ressinc
                                                                                          // e 'SIM' é legado (já excluído no backend), então ficam de fora.
                                                                                          const protocolosConhecidos = ['Tradicional', 'Precoce', 'Superprecoce'];
                                                                                          int rankProtocolo(String valor) {
                                                                                            final idx = protocolosConhecidos.indexOf(valor);
                                                                                            return idx < 0 ? protocolosConhecidos.length : idx;
                                                                                          }

                                                                                          final protocolos = reproSnapshot.data!.map((e) => e.ressinc).withoutNulls.map((e) => e.trim()).where((e) => e.isNotEmpty && e != 'NAO' && e != 'SIM').toList().unique((e) => e);
                                                                                          protocolos.sort((a, b) {
                                                                                            final porRank = rankProtocolo(a).compareTo(rankProtocolo(b));
                                                                                            return porRank != 0 ? porRank : a.compareTo(b);
                                                                                          });
                                                                                          if (protocolos.isEmpty) {
                                                                                            return const SizedBox.shrink();
                                                                                          }
                                                                                          // '-' vem de importação por planilha: marca ressinc sem protocolo definido.
                                                                                          final protocoloLabels = protocolos.map((e) => e == '-' ? 'Sem protocolo' : e).toList();

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Ressinc',
                                                                                            selectedValues: _model.filtroRessincTaxaConcepcaoValues,
                                                                                            options: protocolos,
                                                                                            optionLabels: protocoloLabels,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroRessincTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroRessincTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 350.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: isLoading
                                                                                      ? Center(
                                                                                          child: SizedBox(
                                                                                            width: 50.0,
                                                                                            height: 50.0,
                                                                                            child: CircularProgressIndicator(
                                                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                                                FlutterFlowTheme.of(context).primary,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : (containerTaxaConcepcaoResponse != null && containerTaxaConcepcaoResponse.succeeded)
                                                                                          ? SizedBox(
                                                                                              width: double.infinity,
                                                                                              height: double.infinity,
                                                                                              child: custom_widgets.TaxaPrenhezChart(
                                                                                                key: ValueKey(
                                                                                                  'taxa_concepcao_${FFAppState().propriedadeSelecionada.idPropriedade}_$dataInicioStr-${dataFimStr}_${_model.filtroLoteTaxaConcepcaoValues.join(',')}_${_model.filtroTouroTaxaConcepcaoValues.join(',')}_${_model.filtroInseminadorTaxaConcepcaoValues.join(',')}_${_model.filtroRessincTaxaConcepcaoValues.join(',')}',
                                                                                                ),
                                                                                                width: double.infinity,
                                                                                                height: double.infinity,
                                                                                                prenhezData: containerTaxaConcepcaoResponse.bodyText,
                                                                                              ),
                                                                                            )
                                                                                          : Center(
                                                                                              child: Text(
                                                                                                (containerTaxaConcepcaoResponse != null && !containerTaxaConcepcaoResponse.succeeded) ? _mensagemErroTaxaConcepcao(containerTaxaConcepcaoResponse) : 'Sem dados de reprodução no período.',
                                                                                                style: FlutterFlowTheme.of(context).labelMedium,
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 550.0,
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  key: ValueKey(
                                                                    'taxa_prenhez2_future_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}_${_model.filtroLoteTaxaConcepcaoValues.join(',')}_${_model.filtroTouroTaxaConcepcaoValues.join(',')}_${_model.filtroInseminadorTaxaConcepcaoValues.join(',')}',
                                                                  ),
                                                                  future: () {
                                                                    final taxaPrenhez2Key =
                                                                        'taxa_prenhez2_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}_${_model.filtroLoteTaxaConcepcaoValues.join(',')}_${_model.filtroTouroTaxaConcepcaoValues.join(',')}_${_model.filtroInseminadorTaxaConcepcaoValues.join(',')}_${_model.filtroTipoTaxaPrenhezValue}';
                                                                    if (_model
                                                                            .taxaPrenhez2FutureKey !=
                                                                        taxaPrenhez2Key) {
                                                                      _model.taxaPrenhez2FutureKey =
                                                                          taxaPrenhez2Key;
                                                                      _model.taxaPrenhez2Future = SupabaseEdgeGroup
                                                                          .taxaPrenhez2GetCall
                                                                          .call(
                                                                        idPropriedade: FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                        dataInicio:
                                                                            _painelPeriodoDataInicio(),
                                                                        dataFim:
                                                                            _painelPeriodoDataFim(),
                                                                        pLoteId: _model
                                                                            .filtroLoteTaxaConcepcaoValues
                                                                            .join(','),
                                                                        pIdRebanhoReprodutor: _model
                                                                            .filtroTouroTaxaConcepcaoValues
                                                                            .join(','),
                                                                        pInseminador: _model
                                                                            .filtroInseminadorTaxaConcepcaoValues
                                                                            .join(','),
                                                                        pTipoReproducao: _model
                                                                                    .filtroTipoTaxaPrenhezValue ==
                                                                                'Todos'
                                                                            ? ''
                                                                            : _model
                                                                                .filtroTipoTaxaPrenhezValue,
                                                                      );
                                                                    }
                                                                    return _model
                                                                        .taxaPrenhez2Future;
                                                                  }(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    final isLoading = snapshot.connectionState ==
                                                                            ConnectionState
                                                                                .waiting ||
                                                                        !snapshot
                                                                            .hasData;
                                                                    final containerTaxaPrenhez2Response = snapshot
                                                                            .hasData
                                                                        ? snapshot
                                                                            .data!
                                                                        : null;

                                                                    final dataInicioStr =
                                                                        _painelPeriodoDataInicio();
                                                                    final dataFimStr =
                                                                        _painelPeriodoDataFim();

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        height:
                                                                            433.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              433.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Text(
                                                                                    'Taxa de prenhez',
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
                                                                                ],
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                                                child: RepaintBoundary(
                                                                                  child: Wrap(
                                                                                    spacing: 8.0,
                                                                                    runSpacing: 8.0,
                                                                                    children: [
                                                                                      FutureBuilder<List<dynamic>>(
                                                                                        key: ValueKey('lotes_filtro_taxa_prenhez2_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}'),
                                                                                        future: () {
                                                                                          final dataInicioFiltro = _painelPeriodoDataInicio();
                                                                                          final dataFimFiltro = _painelPeriodoDataFim();

                                                                                          return Future.wait([
                                                                                            ReproducaoTable().queryRows(
                                                                                              queryFn: (q) => q
                                                                                                  .eqOrNull(
                                                                                                    'id_propriedade',
                                                                                                    FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                                  )
                                                                                                  .eqOrNull(
                                                                                                    'deletado',
                                                                                                    'NAO',
                                                                                                  )
                                                                                                  .or('and(data_inseminacao.gte.$dataInicioFiltro,data_inseminacao.lte.$dataFimFiltro),and(data_inicial.gte.$dataInicioFiltro,data_inicial.lte.$dataFimFiltro)'),
                                                                                              limit: 5000,
                                                                                            ),
                                                                                            LotesTable().queryRows(
                                                                                              queryFn: (q) => q
                                                                                                  .eqOrNull(
                                                                                                    'id_propriedade',
                                                                                                    FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                                  )
                                                                                                  .eqOrNull(
                                                                                                    'deletado',
                                                                                                    'NAO',
                                                                                                  ),
                                                                                              limit: 5000,
                                                                                            ),
                                                                                          ]);
                                                                                        }(),
                                                                                        builder: (context, lotesSnapshot) {
                                                                                          if (!lotesSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          final reproRows = lotesSnapshot.data![0] as List<ReproducaoRow>;
                                                                                          final lotesRows = lotesSnapshot.data![1] as List<LotesRow>;

                                                                                          final lotesComReproducao = reproRows.map((e) => e.idLote).withoutNulls.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();

                                                                                          final lotes = lotesRows.where((e) {
                                                                                            final idLote = e.idLote?.trim();
                                                                                            return idLote != null && idLote.isNotEmpty && lotesComReproducao.contains(idLote);
                                                                                          }).toList();

                                                                                          final loteOptions = lotes.map((e) => e.idLote?.trim() ?? '').where((e) => e.isNotEmpty).toList();
                                                                                          final loteLabels = lotes.map((e) => e.nome?.trim() ?? '').where((e) => e.isNotEmpty).toList();

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Lote',
                                                                                            selectedValues: _model.filtroLoteTaxaConcepcaoValues,
                                                                                            options: loteOptions,
                                                                                            optionLabels: loteLabels,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroLoteTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroLoteTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      FutureBuilder<List<({String id, String nome})>>(
                                                                                        key: ValueKey('touros_filtro_taxa_prenhez2_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}'),
                                                                                        future: _carregarTourosPeriodo(),
                                                                                        builder: (context, tourosSnapshot) {
                                                                                          if (!tourosSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          final touros = tourosSnapshot.data!;

                                                                                          final touroOptions = touros.map((e) => e.id).toList();
                                                                                          final touroLabels = touros.map((e) => e.nome).toList();

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Touro',
                                                                                            selectedValues: _model.filtroTouroTaxaConcepcaoValues,
                                                                                            options: touroOptions,
                                                                                            optionLabels: touroLabels,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroTouroTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroTouroTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      FutureBuilder<List<ReproducaoRow>>(
                                                                                        key: ValueKey('inseminadores_filtro_taxa_prenhez2_${FFAppState().propriedadeSelecionada.idPropriedade}'),
                                                                                        future: ReproducaoTable().queryRows(
                                                                                          queryFn: (q) => q
                                                                                              .eqOrNull(
                                                                                                'id_propriedade',
                                                                                                FFAppState().propriedadeSelecionada.idPropriedade,
                                                                                              )
                                                                                              .eqOrNull(
                                                                                                'deletado',
                                                                                                'NAO',
                                                                                              ),
                                                                                        ),
                                                                                        builder: (context, reproSnapshot) {
                                                                                          if (!reproSnapshot.hasData) {
                                                                                            return const SizedBox(
                                                                                              height: 48.0,
                                                                                              child: Center(
                                                                                                child: SizedBox(
                                                                                                  width: 20.0,
                                                                                                  height: 20.0,
                                                                                                  child: CircularProgressIndicator(strokeWidth: 2.0),
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                          final rows = reproSnapshot.data!;
                                                                                          final inseminadores = rows.map((e) => e.inseminador).withoutNulls.map((e) => e.trim()).where((e) => e.isNotEmpty).toList().unique((e) => e);

                                                                                          return _buildMultiFilterChip(
                                                                                            context,
                                                                                            label: 'Inseminador',
                                                                                            selectedValues: _model.filtroInseminadorTaxaConcepcaoValues,
                                                                                            options: inseminadores,
                                                                                            optionLabels: inseminadores,
                                                                                            onChanged: (vals) {
                                                                                              safeSetState(() {
                                                                                                _model.filtroInseminadorTaxaConcepcaoValues = vals;
                                                                                              });
                                                                                            },
                                                                                            onClear: () {
                                                                                              safeSetState(() {
                                                                                                _model.filtroInseminadorTaxaConcepcaoValues = [];
                                                                                              });
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      _buildSingleFilterChip(
                                                                                        context,
                                                                                        label: 'Tipo de reprodução',
                                                                                        selectedValue: _model.filtroTipoTaxaPrenhezValue == 'Todos' ? null : _model.filtroTipoTaxaPrenhezValue,
                                                                                        options: const [
                                                                                          'Monta Natural',
                                                                                          'Inseminação',
                                                                                        ],
                                                                                        optionLabels: const [
                                                                                          'Monta natural',
                                                                                          'Inseminação',
                                                                                        ],
                                                                                        onChanged: (val) {
                                                                                          safeSetState(() {
                                                                                            _model.filtroTipoTaxaPrenhezValue = val;
                                                                                          });
                                                                                        },
                                                                                        onClear: () {
                                                                                          safeSetState(() {
                                                                                            _model.filtroTipoTaxaPrenhezValue = 'Todos';
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 350.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: isLoading
                                                                                      ? Center(
                                                                                          child: SizedBox(
                                                                                            width: 50.0,
                                                                                            height: 50.0,
                                                                                            child: CircularProgressIndicator(
                                                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                                                FlutterFlowTheme.of(context).primary,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                      : (containerTaxaPrenhez2Response != null && containerTaxaPrenhez2Response.succeeded)
                                                                                          ? SizedBox(
                                                                                              width: double.infinity,
                                                                                              height: double.infinity,
                                                                                              child: custom_widgets.TaxaPrenhezChart(
                                                                                                key: ValueKey(
                                                                                                  'taxa_prenhez2_chart_${FFAppState().propriedadeSelecionada.idPropriedade}_$dataInicioStr-${dataFimStr}_${_model.filtroLoteTaxaConcepcaoValues.join(',')}_${_model.filtroTouroTaxaConcepcaoValues.join(',')}_${_model.filtroInseminadorTaxaConcepcaoValues.join(',')}_${_model.filtroTipoTaxaPrenhezValue}',
                                                                                                ),
                                                                                                width: double.infinity,
                                                                                                height: double.infinity,
                                                                                                prenhezData: containerTaxaPrenhez2Response.bodyText,
                                                                                              ),
                                                                                            )
                                                                                          : Center(
                                                                                              child: Text(
                                                                                                (containerTaxaPrenhez2Response != null && !containerTaxaPrenhez2Response.succeeded) ? _mensagemErroTaxaPrenhez2(containerTaxaPrenhez2Response) : 'Sem dados de reprodução no período.',
                                                                                                style: FlutterFlowTheme.of(context).labelMedium,
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              // Taxa de natalidade: edge taxa-natalidade (só período global). Oculto por padrão.
                                                              if (!_painelMostrarCartaoTaxaNatalidade)
                                                                const SizedBox
                                                                    .shrink()
                                                              else
                                                                SizedBox(
                                                                  width: 550.0,
                                                                  child: FutureBuilder<
                                                                      ApiCallResponse>(
                                                                    key:
                                                                        ValueKey(
                                                                      'taxa_natalidade_future_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}',
                                                                    ),
                                                                    future: () {
                                                                      final taxaNatalidadeKey =
                                                                          'taxa_natalidade_${FFAppState().propriedadeSelecionada.idPropriedade}_${_model.dDInicioAnoValue}_${_model.dDInicioMesValue}_${_model.dDFimAnoValue}_${_model.dDFimMesValue}';
                                                                      if (_model
                                                                              .taxaNatalidadeFutureKey !=
                                                                          taxaNatalidadeKey) {
                                                                        _model.taxaNatalidadeFutureKey =
                                                                            taxaNatalidadeKey;
                                                                        _model.taxaNatalidadeFuture = SupabaseEdgeGroup
                                                                            .taxaNatalidadeGetCall
                                                                            .call(
                                                                          idPropriedade: FFAppState()
                                                                              .propriedadeSelecionada
                                                                              .idPropriedade,
                                                                          dataInicio:
                                                                              _painelPeriodoDataInicio(),
                                                                          dataFim:
                                                                              _painelPeriodoDataFim(),
                                                                        );
                                                                      }
                                                                      return _model
                                                                          .taxaNatalidadeFuture;
                                                                    }(),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      final isLoading =
                                                                          snapshot.connectionState == ConnectionState.waiting ||
                                                                              !snapshot.hasData;
                                                                      final containerTaxaNatalidadeResponse = snapshot
                                                                              .hasData
                                                                          ? snapshot
                                                                              .data!
                                                                          : null;

                                                                      final dataInicioStr =
                                                                          _painelPeriodoDataInicio();
                                                                      final dataFimStr =
                                                                          _painelPeriodoDataFim();

                                                                      return Material(
                                                                        color: Colors
                                                                            .transparent,
                                                                        elevation:
                                                                            2.0,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
                                                                        ),
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              433.0,
                                                                          constraints:
                                                                              const BoxConstraints(
                                                                            maxHeight:
                                                                                433.0,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                BorderRadius.circular(6.0),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Text(
                                                                                      'Taxa de natalidade',
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
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                                                  child: Text(
                                                                                    'Período do painel (sem filtros de lote/touro/inseminador).',
                                                                                    style: FlutterFlowTheme.of(context).labelSmall,
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    constraints: const BoxConstraints(
                                                                                      maxHeight: 350.0,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    ),
                                                                                    child: isLoading
                                                                                        ? Center(
                                                                                            child: SizedBox(
                                                                                              width: 50.0,
                                                                                              height: 50.0,
                                                                                              child: CircularProgressIndicator(
                                                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                                                  FlutterFlowTheme.of(context).primary,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : (containerTaxaNatalidadeResponse != null && containerTaxaNatalidadeResponse.succeeded)
                                                                                            ? SizedBox(
                                                                                                width: double.infinity,
                                                                                                height: double.infinity,
                                                                                                child: custom_widgets.TaxaPrenhezChart(
                                                                                                  key: ValueKey(
                                                                                                    'taxa_natalidade_${FFAppState().propriedadeSelecionada.idPropriedade}_$dataInicioStr-$dataFimStr',
                                                                                                  ),
                                                                                                  width: double.infinity,
                                                                                                  height: double.infinity,
                                                                                                  prenhezData: containerTaxaNatalidadeResponse.bodyText,
                                                                                                ),
                                                                                              )
                                                                                            : Center(
                                                                                                child: Text(
                                                                                                  (containerTaxaNatalidadeResponse != null && !containerTaxaNatalidadeResponse.succeeded) ? _mensagemErroTaxaNatalidade(containerTaxaNatalidadeResponse) : 'Sem dados de natalidade no período.',
                                                                                                  style: FlutterFlowTheme.of(context).labelMedium,
                                                                                                  textAlign: TextAlign.center,
                                                                                                ),
                                                                                              ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupaEdgeGroup
                                                                      .reproducaoPartosCategoriaCall
                                                                      .call(
                                                                    dataInicial:
                                                                        _painelPeriodoDataInicio(),
                                                                    dataFinal:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerReproducaoPartosCategoriaResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              433.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Text(
                                                                                    'Partos por categoria no período',
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
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildTotalBadge(
                                                                                    context,
                                                                                    _sumPartosCategorias(
                                                                                      getJsonField(
                                                                                        containerReproducaoPartosCategoriaResponse.jsonBody,
                                                                                        r'''$.items''',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 350.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    child: custom_widgets.PartosCategoriaChart(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                      items: getJsonField(
                                                                                        containerReproducaoPartosCategoriaResponse.jsonBody,
                                                                                        r'''$.items''',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupaEdgeGroup
                                                                      .reproducaoProjecaoPartosCall
                                                                      .call(
                                                                    dataInicial:
                                                                        _painelPeriodoDataInicio(),
                                                                    dataFinal:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    tipoReproducao: _model
                                                                                .filtroTipoReproducaoPartosValue ==
                                                                            'Todos'
                                                                        ? ''
                                                                        : _model
                                                                            .filtroTipoReproducaoPartosValue,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerReproducaoProjecaoPartosResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      'Projeção de partos por categoria no período',
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
                                                                                  ),
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildTotalBadge(
                                                                                    context,
                                                                                    _sumPartosCategorias(
                                                                                      getJsonField(
                                                                                        containerReproducaoProjecaoPartosResponse.jsonBody,
                                                                                        r'''$.items''',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildSingleFilterChip(
                                                                                    context,
                                                                                    label: 'Tipo de reprodução',
                                                                                    selectedValue: _model.filtroTipoReproducaoPartosValue == 'Todos' ? null : _model.filtroTipoReproducaoPartosValue,
                                                                                    options: const [
                                                                                      'Inseminação',
                                                                                      'Monta Natural',
                                                                                    ],
                                                                                    optionLabels: const [
                                                                                      'Inseminação',
                                                                                      'Monta natural',
                                                                                    ],
                                                                                    onChanged: (val) {
                                                                                      safeSetState(() {
                                                                                        _model.filtroTipoReproducaoPartosValue = val;
                                                                                      });
                                                                                    },
                                                                                    onClear: () {
                                                                                      safeSetState(() {
                                                                                        _model.filtroTipoReproducaoPartosValue = 'Todos';
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                                                                  child: Container(
                                                                                    width: double.infinity,
                                                                                    constraints: const BoxConstraints(
                                                                                      maxHeight: 350.0,
                                                                                    ),
                                                                                    decoration: BoxDecoration(
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    ),
                                                                                    child: custom_widgets.ProjecaoPartosChart(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                      items: getJsonField(
                                                                                        containerReproducaoProjecaoPartosResponse.jsonBody,
                                                                                        r'''$.items''',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        24.0)),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupaEdgeGroup
                                                                      .reproducaoDiagnosticosCategoriaCall
                                                                      .call(
                                                                    dataInicial:
                                                                        _painelPeriodoDataInicio(),
                                                                    dataFinal:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    categoria: _model.filtroCategoriadiagnosticoValue !=
                                                                            'Todos'
                                                                        ? _model
                                                                            .filtroCategoriadiagnosticoValue
                                                                        : '',
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerReproducaoDiagnosticosCategoriaResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              433.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Flexible(
                                                                                          child: Text(
                                                                                            'Diagnósticos reprodutivos por categoria',
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
                                                                                        ),
                                                                                        const SizedBox(width: 12.0),
                                                                                        _buildTotalBadge(
                                                                                          context,
                                                                                          _sumPartosCategorias(
                                                                                            getJsonField(
                                                                                              containerReproducaoDiagnosticosCategoriaResponse.jsonBody,
                                                                                              r'''$.items''',
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 8.0),
                                                                                  _buildSingleFilterChip(
                                                                                    context,
                                                                                    label: 'Categoria',
                                                                                    selectedValue: _model.filtroCategoriadiagnosticoValue == 'Todos' ? null : _model.filtroCategoriadiagnosticoValue,
                                                                                    options: const [
                                                                                      'Não diagnosticado',
                                                                                      'Absorção',
                                                                                      'Aborto',
                                                                                      'Natimorto',
                                                                                      'Prenhez',
                                                                                      'Vazio',
                                                                                    ],
                                                                                    optionLabels: const [
                                                                                      'Não diagnosticado',
                                                                                      'Absorção',
                                                                                      'Aborto',
                                                                                      'Natimorto',
                                                                                      'Prenhez',
                                                                                      'Vazio',
                                                                                    ],
                                                                                    onChanged: (val) {
                                                                                      safeSetState(() {
                                                                                        _model.filtroCategoriadiagnosticoValue = val;
                                                                                      });
                                                                                    },
                                                                                    onClear: () {
                                                                                      safeSetState(() {
                                                                                        _model.filtroCategoriadiagnosticoValue = 'Todos';
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 8.0),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 350.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    child: custom_widgets.DiagnosticosCategoriaChart(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                      items: getJsonField(
                                                                                        containerReproducaoDiagnosticosCategoriaResponse.jsonBody,
                                                                                        r'''$.items''',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  key: ValueKey(
                                                                    'relatorio_estacao_${FFAppState().propriedadeSelecionada.idPropriedade}_${_painelPeriodoDataInicio()}_${_painelPeriodoDataFim()}',
                                                                  ),
                                                                  future: SupaEdgeGroup
                                                                      .reproducaoDiagnosticosPeriodoCall
                                                                      .call(
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    dataInicial:
                                                                        _painelPeriodoDataInicio(),
                                                                    dataFinal:
                                                                        _painelPeriodoDataFim(),
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerReproducaoDiagnosticosPeriodoResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            460.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              460.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    'Relatório da estação',
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
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildTotalBadge(
                                                                                    context,
                                                                                    _expostasTotalRelatorioEstacao(
                                                                                      containerReproducaoDiagnosticosPeriodoResponse.jsonBody,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 8.0),
                                                                              Expanded(
                                                                                child: Container(
                                                                                  width: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 380.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: custom_widgets.DiagnosticosPeriodoTable(
                                                                                    width: double.infinity,
                                                                                    jsonBody: containerReproducaoDiagnosticosPeriodoResponse.jsonBody,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        24.0)),
                                                          ),
                                                        ),
                                                        if (responsiveVisibility(
                                                          context: context,
                                                          phone: false,
                                                          tablet: false,
                                                          tabletLandscape:
                                                              false,
                                                          desktop: false,
                                                        ))
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
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    elevation:
                                                                        2.0,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6.0),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          433.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
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
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              'Desmamas no período (cabeça)',
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
                                                                              width: double.infinity,
                                                                              height: double.infinity,
                                                                              constraints: const BoxConstraints(
                                                                                maxHeight: 350.0,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Material(
                                                                    color: Colors
                                                                        .transparent,
                                                                    elevation:
                                                                        2.0,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6.0),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          433.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
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
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              'Projeção de desmamas no período (cabeça)',
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
                                                                              width: double.infinity,
                                                                              height: double.infinity,
                                                                              constraints: const BoxConstraints(
                                                                                maxHeight: 350.0,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                          ),
                                                      ]
                                                          .divide(
                                                              const SizedBox(
                                                                  height: 24.0))
                                                          .addToEnd(
                                                              const SizedBox(
                                                                  height:
                                                                      24.0)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 24.0, 0.0, 0.0),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Vendas',
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
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  4.0,
                                                                  24.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            children: [
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .vendidosPorCategoriasPeriodoCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerVendidosPorCategoriasPeriodoResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      'Animais vendidos por categoria no período (cabeça)',
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
                                                                                  ),
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildTotalBadge(
                                                                                    context,
                                                                                    _sumVendidosTodos(
                                                                                      getJsonField(
                                                                                        containerVendidosPorCategoriasPeriodoResponse.jsonBody,
                                                                                        r'''$.items''',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: double.infinity,
                                                                                constraints: const BoxConstraints(
                                                                                  maxHeight: 350.0,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                ),
                                                                                child: SizedBox(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  child: custom_widgets.VendidosCategoriaChart(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    items: getJsonField(
                                                                                      containerVendidosPorCategoriasPeriodoResponse.jsonBody,
                                                                                      r'''$.items''',
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: FutureBuilder<
                                                                    ApiCallResponse>(
                                                                  future: SupabaseEdgeGroup
                                                                      .precoMedioCategoriaCall
                                                                      .call(
                                                                    inicio:
                                                                        _painelPeriodoDataInicio(),
                                                                    fim:
                                                                        _painelPeriodoDataFim(),
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                  ),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    // Customize what your widget looks like when it's loading.
                                                                    if (!snapshot
                                                                        .hasData) {
                                                                      return Center(
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).primary,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    final containerPrecoMedioCategoriaResponse =
                                                                        snapshot
                                                                            .data!;

                                                                    return Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      elevation:
                                                                          2.0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6.0),
                                                                      ),
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            433.0,
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          maxHeight:
                                                                              433.0,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(6.0),
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Flexible(
                                                                                    child: Text(
                                                                                      'Preço médio por categoria no período (cabeça) (R\$)',
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
                                                                                  ),
                                                                                  const SizedBox(width: 12.0),
                                                                                  _buildTextBadge(
                                                                                    context,
                                                                                    'Média: ${_avgPrecoMedio(
                                                                                      SupabaseEdgeGroup.precoMedioCategoriaCall.items(
                                                                                        containerPrecoMedioCategoriaResponse.jsonBody,
                                                                                      ),
                                                                                    )}',
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: double.infinity,
                                                                                constraints: const BoxConstraints(
                                                                                  maxHeight: 350.0,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                ),
                                                                                child: SizedBox(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  child: custom_widgets.PrecoMedioCategoriaChart(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    items: SupabaseEdgeGroup.precoMedioCategoriaCall.items(
                                                                                      containerPrecoMedioCategoriaResponse.jsonBody,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ].divide(
                                                                const SizedBox(
                                                                    width:
                                                                        24.0)),
                                                          ),
                                                        ),
                                                      ]
                                                          .divide(
                                                              const SizedBox(
                                                                  height: 12.0))
                                                          .addToEnd(
                                                              const SizedBox(
                                                                  height:
                                                                      24.0)),
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if ((FFAppState().loading == true) &&
                  responsiveVisibility(
                    context: context,
                    phone: false,
                    tablet: false,
                    tabletLandscape: false,
                    desktop: false,
                  ))
                wrapWithModel(
                  model: _model.loadingModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const LoadingWidget(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _mensagemErroTaxaConcepcao(ApiCallResponse response) {
    var msg =
        'Não foi possível carregar a taxa de concepção (HTTP ${response.statusCode}). Verifique a função calcular_taxa_prenhez e a edge taxa-prenhez no Supabase.';
    if (response.statusCode == -1 && response.exception != null) {
      msg = '$msg\n${response.exceptionMessage}';
    }
    return msg;
  }

  String _mensagemErroTaxaPrenhez2(ApiCallResponse response) {
    var msg =
        'Não foi possível carregar a taxa de prenhez (HTTP ${response.statusCode}). Verifique a função calcular_taxa_prenhez2 e a edge taxa-prenhez2 no Supabase.';
    if (response.statusCode == -1 && response.exception != null) {
      msg = '$msg\n${response.exceptionMessage}';
    }
    return msg;
  }

  String _mensagemErroTaxaNatalidade(ApiCallResponse response) {
    var msg =
        'Não foi possível carregar a taxa de natalidade (HTTP ${response.statusCode}). Verifique a função calcular_taxa_natalidade e a edge taxa-natalidade no Supabase.';
    if (response.statusCode == -1 && response.exception != null) {
      msg = '$msg\n${response.exceptionMessage}';
    }
    return msg;
  }

  /// Primeiro dia do mês inicial do filtro global do painel (ISO yyyy-MM-dd).
  String _painelPeriodoDataInicio() {
    final ano = int.tryParse(valueOrDefault<String>(
          _model.dDInicioAnoValue,
          '${DateTime.now().year}',
        )) ??
        DateTime.now().year;
    final mes = valueOrDefault<int>(_model.dDInicioMesValue, 1).clamp(1, 12);
    return '${ano.toString().padLeft(4, '0')}-${mes.toString().padLeft(2, '0')}-01';
  }

  /// Último dia do mês final do filtro global do painel (ISO yyyy-MM-dd).
  ///
  /// Várias RPCs comparam `data <= fim`. Usar só o dia 1 no mês final cortava
  /// quase todo o último mês. Usar dia 29 fixo (vendidos/preço) errava fevereiro
  /// e meses de 31 dias. Este helper alinha todos os gráficos ao mesmo intervalo.
  String _painelPeriodoDataFim() {
    final ano = int.tryParse(valueOrDefault<String>(
          _model.dDFimAnoValue,
          '${DateTime.now().year}',
        )) ??
        DateTime.now().year;
    final mes = valueOrDefault<int>(_model.dDFimMesValue, 12).clamp(1, 12);
    final ultimoDia = DateTime(ano, mes + 1, 0).day;
    return '${ano.toString().padLeft(4, '0')}-${mes.toString().padLeft(2, '0')}-${ultimoDia.toString().padLeft(2, '0')}';
  }

  /// Lista de touros (id + nome) com reprodução no período selecionado do painel.
  ///
  /// Calculada no banco via RPC `painel_touros_periodo` para evitar o limite de
  /// linhas do PostgREST: antes a lista era montada puxando todas as linhas de
  /// `reproducao` e deduplicando no cliente, mas a consulta era cortada em ~1000
  /// linhas e touros além disso sumiam do filtro.
  Future<List<({String id, String nome})>> _carregarTourosPeriodo() async {
    final response = await SupaFlow.client.rpc(
      'painel_touros_periodo',
      params: {
        'id_propriedade_param':
            FFAppState().propriedadeSelecionada.idPropriedade,
        'data_inicio_param': _painelPeriodoDataInicio(),
        'data_fim_param': _painelPeriodoDataFim(),
      },
    );
    final rows = (response as List?) ?? const [];
    return rows
        .map((row) {
          final map = (row as Map).cast<String, dynamic>();
          final id = (map['id_rebanho_reprodutor'] ?? '').toString().trim();
          final nome = (map['nome'] ?? '').toString().trim();
          return (id: id, nome: nome.isNotEmpty ? nome : 'Touro S/N');
        })
        .where((touro) => touro.id.isNotEmpty)
        .toList();
  }

  /// Soma o campo [field] de uma lista dinâmica de itens JSON.
  int _sumField(dynamic items, String field) {
    if (items == null) return 0;
    List<dynamic> list;
    if (items is List) {
      list = items;
    } else if (items is Map && items['items'] is List) {
      list = items['items'] as List;
    } else {
      return 0;
    }
    int total = 0;
    for (final e in list) {
      if (e is Map) {
        total += ((e[field] as num?) ?? 0).toInt();
      }
    }
    return total;
  }

  /// Soma projeção de desmamas conforme filtro de idade e sexo.
  int _sumProjecaoDesmamas(
      dynamic items, String filtroIdadeMeses, String filtroSexo) {
    if (items == null) return 0;
    List<dynamic> list;
    if (items is List) {
      list = items;
    } else if (items is Map && items['items'] is List) {
      list = items['items'] as List;
    } else {
      return 0;
    }
    final sexo = filtroSexo.toLowerCase().trim();
    final isTodos = sexo == 'todos';
    final isMacho = sexo == 'macho';
    int total = 0;
    for (final e in list) {
      if (e is Map) {
        final m = (e['proj_${filtroIdadeMeses}m_machos'] as num?)?.toInt() ?? 0;
        final f = (e['proj_${filtroIdadeMeses}m_femeas'] as num?)?.toInt() ?? 0;
        if (isTodos) {
          total += m + f;
        } else if (isMacho) {
          total += m;
        } else {
          total += f;
        }
      }
    }
    return total;
  }

  /// Soma campos de categorias de partos (Novilha + Primípara + Multípara).
  int _sumPartosCategorias(dynamic items) {
    if (items == null) return 0;
    List<dynamic> list;
    if (items is List) {
      list = items;
    } else if (items is Map && items['items'] is List) {
      list = items['items'] as List;
    } else {
      return 0;
    }
    int total = 0;
    for (final e in list) {
      if (e is Map) {
        total += ((e['Novilha'] as num?) ?? 0).toInt();
        total += ((e['Primípara'] as num?) ?? 0).toInt();
        total += ((e['Multípara'] as num?) ?? 0).toInt();
      }
    }
    return total;
  }

  /// Registros de reprodução expostos no período (relatório da estação / edge).
  int _expostasTotalRelatorioEstacao(dynamic jsonBody) {
    if (jsonBody == null) return 0;
    final v = getJsonField(jsonBody, r'''$.expostas_total''');
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  /// Soma o campo 'todos' (ou 'Todos') de uma lista de itens vendidos.
  int _sumVendidosTodos(dynamic items) {
    if (items == null) return 0;
    List<dynamic> list;
    if (items is List) {
      list = items;
    } else if (items is Map && items['items'] is List) {
      list = items['items'] as List;
    } else {
      return 0;
    }
    int total = 0;
    for (final e in list) {
      if (e is Map) {
        final v = e['todos'] ?? e['Todos'] ?? e['total'];
        if (v is num) {
          total += v.toInt();
        }
      }
    }
    return total;
  }

  /// Calcula a média do campo 'todos' para preço médio e formata como R$.
  String _avgPrecoMedio(dynamic items) {
    if (items == null) return 'R\$ 0,00';
    List<dynamic> list;
    if (items is List) {
      list = items;
    } else if (items is Map && items['items'] is List) {
      list = items['items'] as List;
    } else {
      return 'R\$ 0,00';
    }
    double soma = 0;
    int count = 0;
    for (final e in list) {
      if (e is Map) {
        final v = e['todos'] ?? e['Todos'];
        if (v is num && v > 0) {
          soma += v.toDouble();
          count++;
        }
      }
    }
    if (count == 0) return 'R\$ 0,00';
    final media = soma / count;
    return 'R\$ ${media.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _buildTextBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              fontSize: 14.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
      ),
    );
  }

  Widget _buildTotalBadge(BuildContext context, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Text(
        'Total: $total',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              fontSize: 14.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
      ),
    );
  }

  Widget _buildMultiFilterChip(
    BuildContext context, {
    required String label,
    required List<String> selectedValues,
    required List<String> options,
    required List<String> optionLabels,
    required void Function(List<String>) onChanged,
    required VoidCallback onClear,
  }) {
    final isActive = selectedValues.isNotEmpty;
    const greenColor = Color(0xFF1E7A4C);
    const grayLabel = Color(0xFF8E8E8E);
    const borderColor = Color(0xFFBEBEBE);

    String displayValue = '';
    if (selectedValues.length == 1) {
      final idx = options.indexOf(selectedValues.first);
      displayValue = idx >= 0 && idx < optionLabels.length
          ? optionLabels[idx]
          : selectedValues.first;
    } else if (selectedValues.length > 1) {
      displayValue = '${selectedValues.length} selecionados';
    }

    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: () async {
          final result = await showDialog<List<String>>(
            context: context,
            builder: (dialogContext) {
              final tempSelected = List<String>.from(selectedValues);
              return StatefulBuilder(
                builder: (ctx, setDialogState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    titlePadding:
                        const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    contentPadding:
                        const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                    actionsPadding:
                        const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2F2F2F),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (tempSelected.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  setDialogState(() {
                                    tempSelected.clear();
                                  });
                                },
                                child: Text(
                                  'Limpar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: greenColor,
                                  ),
                                ),
                              ),
                            IconButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close,
                                  size: 22.0, color: Color(0xFF8E8E8E)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    content: SizedBox(
                      width: 340.0,
                      height: 320.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (ctx, i) {
                          final isItemSelected =
                              tempSelected.contains(options[i]);
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                if (isItemSelected) {
                                  tempSelected.remove(options[i]);
                                } else {
                                  tempSelected.add(options[i]);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22.0,
                                    height: 22.0,
                                    decoration: BoxDecoration(
                                      color: isItemSelected
                                          ? greenColor
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(
                                        color: isItemSelected
                                            ? greenColor
                                            : borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isItemSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 16.0)
                                        : null,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      optionLabels[i],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.0,
                                        fontWeight: isItemSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isItemSelected
                                            ? greenColor
                                            : const Color(0xFF2F2F2F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        height: 44.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(tempSelected);
                          },
                          child: Text(
                            'Aplicar',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F2F2F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                isActive ? 8.0 : 16.0,
                0.0,
                0.0,
                0.0,
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: grayLabel,
                  height: 1.3,
                ),
              ),
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: 1.0,
                  height: 24.0,
                  color: borderColor,
                ),
              ),
            if (isActive)
              Text(
                displayValue,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: greenColor,
                  height: 1.3,
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                isActive ? 0.0 : 8.0,
                0.0,
                12.0,
                0.0,
              ),
              child: const Icon(
                Icons.expand_more,
                color: greenColor,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleFilterChip(
    BuildContext context, {
    required String label,
    required String? selectedValue,
    required List<String> options,
    required List<String> optionLabels,
    required void Function(String) onChanged,
    required VoidCallback onClear,
  }) {
    final isActive = selectedValue != null && selectedValue.isNotEmpty;
    const greenColor = Color(0xFF1E7A4C);
    const grayLabel = Color(0xFF8E8E8E);
    const borderColor = Color(0xFFBEBEBE);

    String displayValue = '';
    if (isActive) {
      final idx = options.indexOf(selectedValue);
      displayValue = idx >= 0 && idx < optionLabels.length
          ? optionLabels[idx]
          : selectedValue;
    }

    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (dialogContext) {
              String? tempSelected = selectedValue;
              return StatefulBuilder(
                builder: (ctx, setDialogState) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    titlePadding:
                        const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                    contentPadding:
                        const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 0.0),
                    actionsPadding:
                        const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2F2F2F),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close,
                              size: 22.0, color: Color(0xFF8E8E8E)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    content: SizedBox(
                      width: 340.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (ctx, i) {
                          final isItemSelected = tempSelected == options[i];
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                tempSelected = options[i];
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22.0,
                                    height: 22.0,
                                    decoration: BoxDecoration(
                                      color: isItemSelected
                                          ? greenColor
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isItemSelected
                                            ? greenColor
                                            : borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isItemSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 14.0)
                                        : null,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Text(
                                      optionLabels[i],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.0,
                                        fontWeight: isItemSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isItemSelected
                                            ? greenColor
                                            : const Color(0xFF2F2F2F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        height: 44.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(tempSelected);
                          },
                          child: Text(
                            'Aplicar',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F2F2F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                isActive ? 8.0 : 16.0,
                0.0,
                0.0,
                0.0,
              ),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: grayLabel,
                  height: 1.3,
                ),
              ),
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: 1.0,
                  height: 24.0,
                  color: borderColor,
                ),
              ),
            if (isActive)
              Text(
                displayValue,
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: greenColor,
                  height: 1.3,
                ),
              ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                isActive ? 0.0 : 8.0,
                0.0,
                12.0,
                0.0,
              ),
              child: const Icon(
                Icons.expand_more,
                color: greenColor,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
