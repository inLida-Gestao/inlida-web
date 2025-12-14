import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_widget.dart';
import '/components/loading_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/instant_timer.dart';
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
        FFAppState().navegacao = 'painel';
        safeSetState(() {});
        _model.instantTimer = InstantTimer.periodic(
          duration: const Duration(milliseconds: 250),
          callback: (timer) async {
            if (FFAppState().refreshPainel == true) {
              safeSetState(() => _model.apiRequestCompleter1 = null);
              safeSetState(() => _model.apiRequestCompleter2 = null);
              FFAppState().refreshPainel = false;
              safeSetState(() {});
            }
          },
          startImmediately: true,
        );
      }

      navigate();
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 4,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

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
                    child: Container(
                      width: double.infinity,
                      height: 100.0,
                      decoration: const BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          wrapWithModel(
                            model: _model.sideBarModel,
                            updateCallback: () => safeSetState(() {}),
                            child: const SideBarWidget(),
                          ),
                          Expanded(
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: MediaQuery.sizeOf(context).height * 1.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
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
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                if (FFAppState()
                                                            .propriedadeSelecionada
                                                            .idPropriedade !=
                                                        '')
                                                  Container(
                                                    decoration: const BoxDecoration(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  5.0,
                                                                  0.0,
                                                                  5.0,
                                                                  0.0),
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
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    hintText:
                                                                        'Selecionar ano',
                                                                    icon: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                                                                    width: 80.0,
                                                                    height:
                                                                        48.0,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    hintText:
                                                                        'Mês',
                                                                    icon: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                                                                ].divide(const SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ].divide(const SizedBox(
                                                                height: 4.0)),
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
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    hintText:
                                                                        'Selecionar ano',
                                                                    icon: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                                                                    width: 80.0,
                                                                    height:
                                                                        48.0,
                                                                    textStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    hintText:
                                                                        'Mês',
                                                                    icon: Icon(
                                                                      Icons
                                                                          .keyboard_arrow_down_rounded,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                                                                ].divide(const SizedBox(
                                                                    width:
                                                                        8.0)),
                                                              ),
                                                            ].divide(const SizedBox(
                                                                height: 4.0)),
                                                          ),
                                                        ].divide(const SizedBox(
                                                            width: 8.0)),
                                                      ),
                                                    ),
                                                  ),
                                                Builder(
                                                  builder: (context) =>
                                                      FFButtonWidget(
                                                    onPressed: () async {
                                                      await showAlignedDialog(
                                                        barrierColor:
                                                            Colors.transparent,
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
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
                                                      iconAlignment:
                                                          IconAlignment.end,
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
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
                                                                fontSize: 18.0,
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
                                                Builder(
                                                  builder: (context) =>
                                                      FFButtonWidget(
                                                    onPressed: () async {
                                                      await showAlignedDialog(
                                                        barrierColor:
                                                            Colors.transparent,
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
                                                              .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
                                                      iconAlignment:
                                                          IconAlignment.end,
                                                      iconPadding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
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
                                                                fontSize: 18.0,
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
                                                        ].divide(const SizedBox(
                                                            width: 4.0)),
                                                      ),
                                                    ),
                                                  ),
                                              ].divide(const SizedBox(width: 16.0)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
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
                                                                        padding:
                                                                            const EdgeInsets.all(24.0),
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
                                                                                        final lista = (listaRebanhoAnimalListaRebanhosPropriedadeResponse.jsonBody.toList().map<ListaRebanhoPropriedadeStruct?>(ListaRebanhoPropriedadeStruct.maybeFromMap).toList() as Iterable<ListaRebanhoPropriedadeStruct?>).withoutNulls.toList() ?? [];
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
                                                                                                    LinearPercentIndicator(
                                                                                                      percent: listaItem.porcentagem / 100,
                                                                                                      width: MediaQuery.sizeOf(context).width * 0.17,
                                                                                                      lineHeight: 12.0,
                                                                                                      animation: true,
                                                                                                      animateFromLastPercent: true,
                                                                                                      progressColor: FlutterFlowTheme.of(context).primary,
                                                                                                      backgroundColor: FlutterFlowTheme.of(context).customColor5,
                                                                                                      barRadius: const Radius.circular(8.0),
                                                                                                      padding: EdgeInsets.zero,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '${listaItem.porcentagem.toString()}% (${listaItem.quantidade.toString()})',
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
                                                                        padding:
                                                                            const EdgeInsets.all(24.0),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  'Rebanho por período (Cabeça)',
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
                                                                              ].divide(const SizedBox(width: 8.0)),
                                                                            ),
                                                                            if (FFAppState().propriedadeSelecionada.idPropriedade != '')
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
                                                                                  final containerAnosComRebanhoResponse = snapshot.data!;

                                                                                  return Container(
                                                                                    decoration: const BoxDecoration(),
                                                                                    child: Visibility(
                                                                                      visible: FunctionsSupabaseRebanhoGroup.anosComRebanhoCall
                                                                                              .ano(
                                                                                                containerAnosComRebanhoResponse.jsonBody,
                                                                                              )!.isNotEmpty,
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
                                                                                          2025,
                                                                                        ),
                                                                                        startMonth: valueOrDefault<int>(
                                                                                          _model.dropDownValue2,
                                                                                          1,
                                                                                        ),
                                                                                        endYear: valueOrDefault<int>(
                                                                                          _model.dropDownValue3,
                                                                                          2025,
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
                                                                                  final containerChartRebGraficoQtdRebanhoPeriodoResponse = snapshot.data!;

                                                                                  return Container(
                                                                                    decoration: const BoxDecoration(),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        if ((FFAppState().propriedadeSelecionada.idPropriedade != '') &&
                                                                                            (FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall
                                                                                                    .anos(
                                                                                                      containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                    )!.isNotEmpty))
                                                                                          SizedBox(
                                                                                            width: double.infinity,
                                                                                            height: 400.0,
                                                                                            child: FlutterFlowBarChart(
                                                                                              barData: [
                                                                                                FFBarChartData(
                                                                                                  yData: FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall.qtdMacho(
                                                                                                    containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                  )!,
                                                                                                  color: const Color(0xFF2973CC),
                                                                                                ),
                                                                                                FFBarChartData(
                                                                                                  yData: FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall.qtdFemea(
                                                                                                    containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                  )!,
                                                                                                  color: const Color(0xFFC429CC),
                                                                                                ),
                                                                                                FFBarChartData(
                                                                                                  yData: FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall.qtdTotal(
                                                                                                    containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                  )!,
                                                                                                  color: FlutterFlowTheme.of(context).primary,
                                                                                                )
                                                                                              ],
                                                                                              xLabels: FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall.mesAno(
                                                                                                containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                              )!,
                                                                                              barWidth: 20.0,
                                                                                              barBorderRadius: const BorderRadius.only(
                                                                                                bottomLeft: Radius.circular(0.0),
                                                                                                bottomRight: Radius.circular(0.0),
                                                                                                topLeft: Radius.circular(8.0),
                                                                                                topRight: Radius.circular(6.0),
                                                                                              ),
                                                                                              barSpace: 0.0,
                                                                                              groupSpace: 16.0,
                                                                                              alignment: BarChartAlignment.start,
                                                                                              chartStylingInfo: ChartStylingInfo(
                                                                                                enableTooltip: true,
                                                                                                tooltipBackgroundColor: FlutterFlowTheme.of(context).customColor2,
                                                                                                backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                showGrid: true,
                                                                                                showBorder: false,
                                                                                              ),
                                                                                              axisBounds: const AxisBounds(),
                                                                                              xAxisLabelInfo: const AxisLabelInfo(
                                                                                                showLabels: true,
                                                                                                labelInterval: 10.0,
                                                                                                reservedSize: 28.0,
                                                                                              ),
                                                                                              yAxisLabelInfo: AxisLabelInfo(
                                                                                                showLabels: true,
                                                                                                labelInterval: 1000.0,
                                                                                                labelFormatter: LabelFormatter(
                                                                                                  numberFormat: (val) => formatNumber(
                                                                                                    val,
                                                                                                    formatType: FormatType.custom,
                                                                                                    format: '',
                                                                                                    locale: 'pt_BR',
                                                                                                  ),
                                                                                                ),
                                                                                                reservedSize: 42.0,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        if ((FFAppState().propriedadeSelecionada.idPropriedade != '') &&
                                                                                            (FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall
                                                                                                    .anos(
                                                                                                      containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                    )!.isNotEmpty))
                                                                                          Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                                                            child: Row(
                                                                                              mainAxisSize: MainAxisSize.max,
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 10.0,
                                                                                                      height: 10.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: const Color(0xFF2973CC),
                                                                                                        borderRadius: BorderRadius.circular(100.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Macho',
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
                                                                                                  ].divide(const SizedBox(width: 6.0)),
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 10.0,
                                                                                                      height: 10.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: const Color(0xFFC429CC),
                                                                                                        borderRadius: BorderRadius.circular(100.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Fêmea',
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
                                                                                                  ].divide(const SizedBox(width: 6.0)),
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 10.0,
                                                                                                      height: 10.0,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: FlutterFlowTheme.of(context).primary,
                                                                                                        borderRadius: BorderRadius.circular(100.0),
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Total',
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
                                                                                                  ].divide(const SizedBox(width: 6.0)),
                                                                                                ),
                                                                                              ].divide(const SizedBox(width: 8.0)),
                                                                                            ),
                                                                                          ),
                                                                                        if ((FFAppState().propriedadeSelecionada.idPropriedade == '') ||
                                                                                            (FunctionsSupabaseRebanhoGroup.graficoQtdRebanhoPeriodoCall
                                                                                                    .anos(
                                                                                                      containerChartRebGraficoQtdRebanhoPeriodoResponse.jsonBody,
                                                                                                    )
                                                                                                    ?.length ==
                                                                                                0))
                                                                                          Expanded(
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 48.0, 0.0, 48.0),
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
                                                              ].divide(const SizedBox(
                                                                  width: 24.0)),
                                                            ),
                                                          ),
                                                        ]
                                                            .addToStart(
                                                                const SizedBox(
                                                                    height:
                                                                        24.0))
                                                            .addToEnd(const SizedBox(
                                                                height: 24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
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
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Bezerros ',
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
                                                                                  'Taxa de desmama por período (%)',
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
                                                                                  valueOrDefault<String>(
                                                                                    '${valueOrDefault<String>(
                                                                                      FunctionsSupabaseRebanhoGroup.qtdAnimaisDesmamaCall
                                                                                          .pctDesmamados(
                                                                                            containerQtdAnimaisDesmamaResponse.jsonBody,
                                                                                          )
                                                                                          ?.toString(),
                                                                                      '0',
                                                                                    )}%',
                                                                                    '0',
                                                                                  ),
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
                                                            ].divide(const SizedBox(
                                                                width: 32.0)),
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
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioMesValue
                                                                          ?.toString(),
                                                                      '01',
                                                                    )}-01',
                                                                    fim:
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimMesValue
                                                                          ?.toString(),
                                                                      '12',
                                                                    )}-01',
                                                                    sexo: valueOrDefault<
                                                                        String>(
                                                                      _model
                                                                          .ddIdadeValue,
                                                                      'M',
                                                                    ),
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
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
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
                                                                                  FlutterFlowDropDown<String>(
                                                                                    controller: _model.ddIdadeValueController ??= FormFieldController<String>(
                                                                                      _model.ddIdadeValue ??= 'T',
                                                                                    ),
                                                                                    options: List<String>.from([
                                                                                      'M',
                                                                                      'F',
                                                                                      'T'
                                                                                    ]),
                                                                                    optionLabels: const [
                                                                                      'Macho',
                                                                                      'Fêmea',
                                                                                      'Todos'
                                                                                    ],
                                                                                    onChanged: (val) => safeSetState(() => _model.ddIdadeValue = val),
                                                                                    width: 104.0,
                                                                                    height: 40.0,
                                                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    hintText: 'Macho',
                                                                                    icon: Icon(
                                                                                      Icons.keyboard_arrow_down_rounded,
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      size: 24.0,
                                                                                    ),
                                                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    elevation: 2.0,
                                                                                    borderColor: FlutterFlowTheme.of(context).customColor5,
                                                                                    borderWidth: 0.0,
                                                                                    borderRadius: 4.0,
                                                                                    margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                    hidesUnderline: true,
                                                                                    isOverButton: false,
                                                                                    isSearchable: false,
                                                                                    isMultiSelect: false,
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
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioMesValue
                                                                          ?.toString(),
                                                                      '01',
                                                                    )}-01',
                                                                    fim:
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimMesValue
                                                                          ?.toString(),
                                                                      '12',
                                                                    )}-01',
                                                                    sexo: valueOrDefault<
                                                                        String>(
                                                                      _model
                                                                          .ddPesoValue,
                                                                      'M',
                                                                    ),
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
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
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
                                                                                  FlutterFlowDropDown<String>(
                                                                                    controller: _model.ddPesoValueController ??= FormFieldController<String>(
                                                                                      _model.ddPesoValue ??= 'T',
                                                                                    ),
                                                                                    options: List<String>.from([
                                                                                      'M',
                                                                                      'F',
                                                                                      'T'
                                                                                    ]),
                                                                                    optionLabels: const [
                                                                                      'Macho',
                                                                                      'Fêmea',
                                                                                      'Todos'
                                                                                    ],
                                                                                    onChanged: (val) => safeSetState(() => _model.ddPesoValue = val),
                                                                                    width: 104.0,
                                                                                    height: 40.0,
                                                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    hintText: 'Macho',
                                                                                    icon: Icon(
                                                                                      Icons.keyboard_arrow_down_rounded,
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      size: 24.0,
                                                                                    ),
                                                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    elevation: 2.0,
                                                                                    borderColor: FlutterFlowTheme.of(context).customColor5,
                                                                                    borderWidth: 0.0,
                                                                                    borderRadius: 4.0,
                                                                                    margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                    hidesUnderline: true,
                                                                                    isOverButton: false,
                                                                                    isSearchable: false,
                                                                                    isMultiSelect: false,
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
                                                            ].divide(const SizedBox(
                                                                width: 32.0)),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
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
                                                                          '${valueOrDefault<String>(
                                                                        _model
                                                                            .dDInicioAnoValue,
                                                                        '2025',
                                                                      )}-${valueOrDefault<String>(
                                                                        _model
                                                                            .dDInicioMesValue
                                                                            ?.toString(),
                                                                        '01',
                                                                      )}-01',
                                                                      fim:
                                                                          '${valueOrDefault<String>(
                                                                        _model
                                                                            .dDFimAnoValue,
                                                                        '2025',
                                                                      )}-${valueOrDefault<String>(
                                                                        _model
                                                                            .dDFimMesValue
                                                                            ?.toString(),
                                                                        '12',
                                                                      )}-01',
                                                                      idPropriedade: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
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
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(
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
                                                                                Container(
                                                                                  width: double.infinity,
                                                                                  height: double.infinity,
                                                                                  constraints: const BoxConstraints(
                                                                                    maxHeight: 350.0,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                    child: SizedBox(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                      child: custom_widgets.NascimentosChart(
                                                                                        width: double.infinity,
                                                                                        height: double.infinity,
                                                                                        items: getJsonField(
                                                                                          containerNascimentosPeriodoResponse.jsonBody,
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
                                                                    future: SupabaseEdgeGroup
                                                                        .mortalidadePeriodoCall
                                                                        .call(
                                                                      inicio:
                                                                          '${valueOrDefault<String>(
                                                                        _model
                                                                            .dDInicioAnoValue,
                                                                        '2025',
                                                                      )}-${valueOrDefault<String>(
                                                                        _model
                                                                            .dDInicioMesValue
                                                                            ?.toString(),
                                                                        '01',
                                                                      )}-01',
                                                                      fim:
                                                                          '${valueOrDefault<String>(
                                                                        _model
                                                                            .dDFimAnoValue,
                                                                        '2025',
                                                                      )}-${valueOrDefault<String>(
                                                                        _model
                                                                            .dDFimMesValue
                                                                            ?.toString(),
                                                                        '12',
                                                                      )}-01',
                                                                      idPropriedade: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      causa: _model.dropDownMotivoMorteValue != null &&
                                                                              _model.dropDownMotivoMorteValue !=
                                                                                  ''
                                                                          ? _model
                                                                              .dropDownMotivoMorteValue
                                                                          : '',
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
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisSize: MainAxisSize.max,
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
                                                                                      child: Text(
                                                                                        'Mortalidade no período (cabeça)',
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
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        if (_model.dropDownMotivoMorteValue != null && _model.dropDownMotivoMorteValue != '')
                                                                                          InkWell(
                                                                                            splashColor: Colors.transparent,
                                                                                            focusColor: Colors.transparent,
                                                                                            hoverColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () async {
                                                                                              safeSetState(() {
                                                                                                _model.dropDownMotivoMorteValueController?.reset();
                                                                                                _model.dropDownMotivoMorteValue = null;
                                                                                              });
                                                                                            },
                                                                                            child: Icon(
                                                                                              Icons.replay,
                                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                                              size: 24.0,
                                                                                            ),
                                                                                          ),
                                                                                        FlutterFlowDropDown<String>(
                                                                                          controller: _model.dropDownMotivoMorteValueController ??= FormFieldController<String>(null),
                                                                                          options: const [
                                                                                            'ACIDENTE',
                                                                                            'ANIMAL PEÇONHENTO',
                                                                                            'ATAQUE AVE',
                                                                                            'DOENÇA',
                                                                                            'ESTRESSE TÉRMICO',
                                                                                            'INTOXICAÇÃO',
                                                                                            'NEONATO',
                                                                                            'PARTO DISTÓCICO',
                                                                                            'PREDADOR'
                                                                                          ],
                                                                                          onChanged: (val) => safeSetState(() => _model.dropDownMotivoMorteValue = val),
                                                                                          width: 140.0,
                                                                                          height: 40.0,
                                                                                          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w600,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                fontSize: 14.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w600,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                          hintText: 'Causa',
                                                                                          icon: Icon(
                                                                                            Icons.keyboard_arrow_down_rounded,
                                                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                                                            size: 24.0,
                                                                                          ),
                                                                                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                          elevation: 2.0,
                                                                                          borderColor: FlutterFlowTheme.of(context).customColor5,
                                                                                          borderWidth: 0.0,
                                                                                          borderRadius: 8.0,
                                                                                          margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                          hidesUnderline: true,
                                                                                          isOverButton: false,
                                                                                          isSearchable: false,
                                                                                          isMultiSelect: false,
                                                                                        ),
                                                                                      ].divide(const SizedBox(width: 16.0)),
                                                                                    ),
                                                                                  ],
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
                                                                                        child: custom_widgets.MortalidadeChart(
                                                                                          width: double.infinity,
                                                                                          height: double.infinity,
                                                                                          items: getJsonField(
                                                                                            containerMortalidadePeriodoResponse.jsonBody,
                                                                                            r'''$.items''',
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
                                                              ].divide(const SizedBox(
                                                                  width: 24.0)),
                                                            ),
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
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioMesValue
                                                                          ?.toString(),
                                                                      '01',
                                                                    )}-01',
                                                                    fim:
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimMesValue
                                                                          ?.toString(),
                                                                      '12',
                                                                    )}-01',
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
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
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(16.0),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    child: custom_widgets.NascimentosChart(
                                                                                      width: double.infinity,
                                                                                      height: double.infinity,
                                                                                      items: getJsonField(
                                                                                        containerDesmamaPeriodoResponse.jsonBody,
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
                                                                  future: SupabaseEdgeGroup
                                                                      .projecaoDesmamasCall
                                                                      .call(
                                                                    inicio:
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDInicioMesValue
                                                                          ?.toString(),
                                                                      '01',
                                                                    )}-01',
                                                                    fim:
                                                                        '${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimAnoValue,
                                                                      '2025',
                                                                    )}-${valueOrDefault<String>(
                                                                      _model
                                                                          .dDFimMesValue
                                                                          ?.toString(),
                                                                      '12',
                                                                    )}-01',
                                                                    idPropriedade:
                                                                        FFAppState()
                                                                            .propriedadeSelecionada
                                                                            .idPropriedade,
                                                                    agrupar:
                                                                        'mes',
                                                                    sexo: _model
                                                                        .ddProjDesmamaValue,
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
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
                                                                                    child: Text(
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
                                                                                  ),
                                                                                  FlutterFlowDropDown<String>(
                                                                                    controller: _model.ddProjDesmamaValueController ??= FormFieldController<String>(
                                                                                      _model.ddProjDesmamaValue ??= 'Macho',
                                                                                    ),
                                                                                    options: List<String>.from([
                                                                                      'Macho',
                                                                                      'Fêmea',
                                                                                      'Todos'
                                                                                    ]),
                                                                                    optionLabels: const [
                                                                                      'Todos',
                                                                                      'Fêmea',
                                                                                      'Todos'
                                                                                    ],
                                                                                    onChanged: (val) => safeSetState(() => _model.ddProjDesmamaValue = val),
                                                                                    width: 104.0,
                                                                                    height: 40.0,
                                                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    hintText: 'Macho',
                                                                                    icon: Icon(
                                                                                      Icons.keyboard_arrow_down_rounded,
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      size: 24.0,
                                                                                    ),
                                                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    elevation: 2.0,
                                                                                    borderColor: FlutterFlowTheme.of(context).customColor5,
                                                                                    borderWidth: 0.0,
                                                                                    borderRadius: 4.0,
                                                                                    margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                    hidesUnderline: true,
                                                                                    isOverButton: false,
                                                                                    isSearchable: false,
                                                                                    isMultiSelect: false,
                                                                                  ),
                                                                                  FlutterFlowDropDown<String>(
                                                                                    controller: _model.ddMesesValueController ??= FormFieldController<String>(
                                                                                      _model.ddMesesValue ??= '6',
                                                                                    ),
                                                                                    options: List<String>.from([
                                                                                      '6',
                                                                                      '7',
                                                                                      '8'
                                                                                    ]),
                                                                                    optionLabels: const [
                                                                                      '6',
                                                                                      '7',
                                                                                      '8'
                                                                                    ],
                                                                                    onChanged: (val) => safeSetState(() => _model.ddMesesValue = val),
                                                                                    width: 104.0,
                                                                                    height: 40.0,
                                                                                    textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w600,
                                                                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    hintText: '6',
                                                                                    icon: Icon(
                                                                                      Icons.keyboard_arrow_down_rounded,
                                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                                      size: 24.0,
                                                                                    ),
                                                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    elevation: 2.0,
                                                                                    borderColor: FlutterFlowTheme.of(context).customColor5,
                                                                                    borderWidth: 0.0,
                                                                                    borderRadius: 4.0,
                                                                                    margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                                                                                    hidesUnderline: true,
                                                                                    isOverButton: false,
                                                                                    isSearchable: false,
                                                                                    isMultiSelect: false,
                                                                                  ),
                                                                                ].divide(const SizedBox(width: 12.0)),
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
                                                                                  child: custom_widgets.ProjecaoDesmamasChart(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
                                                                                    items: getJsonField(
                                                                                      containerProjecaoDesmamasResponse.jsonBody,
                                                                                      r'''$.items''',
                                                                                    ),
                                                                                    filtroSexo: _model.ddProjDesmamaValue!,
                                                                                    filtroIdadeMeses: _model.ddMesesValue!,
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
                                                            ].divide(const SizedBox(
                                                                width: 24.0)),
                                                          ),
                                                        ),
                                                      ]
                                                          .divide(const SizedBox(
                                                              height: 32.0))
                                                          .addToEnd(const SizedBox(
                                                              height: 24.0)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
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
                                                        Expanded(
                                                          child: Padding(
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
                                                                      idPropriedade: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      dataInicio:
                                                                          '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                      dataFim:
                                                                          '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-29',
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
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                      idPropriedade: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      dataInicio:
                                                                          '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                      dataFim:
                                                                          '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-29',
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
                                                                            padding:
                                                                                const EdgeInsets.all(24.0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                              ].divide(const SizedBox(
                                                                  width: 32.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
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
                                                                        .taxaPrenhezGetCall
                                                                        .call(
                                                                      idPropriedade: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      dataInicio:
                                                                          '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                      dataFim:
                                                                          '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-29',
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
                                                                      final containerTaxaPrenhezGetResponse =
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
                                                                              double.infinity,
                                                                          constraints:
                                                                              const BoxConstraints(
                                                                            minHeight:
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
                                                                                Expanded(
                                                                                  child: Container(
                                                                                    constraints: const BoxConstraints(
                                                                                      maxHeight: 350.0,
                                                                                    ),
                                                                                    decoration: const BoxDecoration(),
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        if (containerTaxaPrenhezGetResponse.succeeded)
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
                                                                                                child: custom_widgets.TaxaPrenhezChart(
                                                                                                  width: double.infinity,
                                                                                                  height: double.infinity,
                                                                                                  prenhezData: containerTaxaPrenhezGetResponse.jsonBody,
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
                                                                  ),
                                                                ),
                                                                if (responsiveVisibility(
                                                                  context:
                                                                      context,
                                                                  phone: false,
                                                                  tablet: false,
                                                                  tabletLandscape:
                                                                      false,
                                                                  desktop:
                                                                      false,
                                                                ))
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
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
                                                                      Container(
                                                                    width: double
                                                                        .infinity,
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                      minHeight:
                                                                          433.0,
                                                                      maxWidth:
                                                                          550.0,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(const SizedBox(
                                                                  width: 32.0)),
                                                            ),
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
                                                                        '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                    dataFinal:
                                                                        '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-01',
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
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
                                                                        '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                    dataFinal:
                                                                        '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-01',
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Text(
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
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: double.infinity,
                                                                                constraints: const BoxConstraints(
                                                                                  maxHeight: 350.0,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                                                                  child: SizedBox(
                                                                                    width: double.infinity,
                                                                                    height: double.infinity,
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
                                                            ].divide(const SizedBox(
                                                                width: 24.0)),
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
                                                                        padding:
                                                                            const EdgeInsets.all(24.0),
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
                                                                        padding:
                                                                            const EdgeInsets.all(24.0),
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
                                                              ].divide(const SizedBox(
                                                                  width: 24.0)),
                                                            ),
                                                          ),
                                                      ]
                                                          .divide(const SizedBox(
                                                              height: 24.0))
                                                          .addToEnd(const SizedBox(
                                                              height: 24.0)),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
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
                                                                        '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                    fim:
                                                                        '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-29',
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
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
                                                                        '${_model.dDInicioAnoValue}-${_model.dDInicioMesValue?.toString()}-01',
                                                                    fim:
                                                                        '${_model.dDFimAnoValue}-${_model.dDFimMesValue?.toString()}-29',
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
                                                                          padding:
                                                                              const EdgeInsets.all(24.0),
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
                                                            ].divide(const SizedBox(
                                                                width: 24.0)),
                                                          ),
                                                        ),
                                                      ]
                                                          .divide(const SizedBox(
                                                              height: 12.0))
                                                          .addToEnd(const SizedBox(
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
}
