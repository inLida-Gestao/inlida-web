import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/popup_rebanhos_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_reproducao_edit_animal_model.dart';
export 'pg_reproducao_edit_animal_model.dart';

class PgReproducaoEditAnimalWidget extends StatefulWidget {
  const PgReproducaoEditAnimalWidget({
    super.key,
    required this.idReproducao,
  });

  final String? idReproducao;

  static String routeName = 'pgReproducaoEditAnimal';
  static String routePath = '/editar-reproducao-animal';

  @override
  State<PgReproducaoEditAnimalWidget> createState() =>
      _PgReproducaoEditAnimalWidgetState();
}

class _PgReproducaoEditAnimalWidgetState
    extends State<PgReproducaoEditAnimalWidget> {
  late PgReproducaoEditAnimalModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgReproducaoEditAnimalModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.reproducaoBuscaEdit = await ReproducaoTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id_reproducao',
          widget.idReproducao,
        ),
      );
      _model.tipoReproducao =
          _model.reproducaoBuscaEdit!.firstOrNull!.tipoReproducao!;
      _model.score = _model.reproducaoBuscaEdit?.firstOrNull?.scoreCorporal;
      _model.partidaSemen =
          _model.reproducaoBuscaEdit?.firstOrNull?.partidaSemen;
      _model.ressinc = _model.reproducaoBuscaEdit?.firstOrNull?.ressinc == 'SIM'
          ? true
          : false;
      _model.parida = _model.reproducaoBuscaEdit?.firstOrNull?.parida == 'SIM'
          ? true
          : false;
      safeSetState(() {});
    });

    _model.dataInseminacaoFocusNode ??= FocusNode();

    _model.dataPartidaSemenFocusNode ??= FocusNode();

    _model.dataInicialFocusNode ??= FocusNode();

    _model.dataFinalFocusNode ??= FocusNode();

    _model.nomeInseminadorFocusNode ??= FocusNode();

    _model.dataParidaFocusNode ??= FocusNode();

    _model.dataStatusFocusNode ??= FocusNode();

    _model.anotacoesFocusNode ??= FocusNode();

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

    return FutureBuilder<List<ReproducaoRow>>(
      future: ReproducaoTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id_reproducao',
          widget.idReproducao,
        ),
      ),
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
        List<ReproducaoRow> pgReproducaoEditAnimalReproducaoRowList =
            snapshot.data!;

        final pgReproducaoEditAnimalReproducaoRow =
            pgReproducaoEditAnimalReproducaoRowList.isNotEmpty
                ? pgReproducaoEditAnimalReproducaoRowList.first
                : null;

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          wrapWithModel(
                            model: _model.sideBarModel,
                            updateCallback: () => safeSetState(() {}),
                            child: const SideBarWidget(),
                          ),
                                                    Flexible(
                                                        child: Align(
                                                            alignment: const AlignmentDirectional(0.0, -1.0),
                                                            child: FutureBuilder<List<RebanhoRow>>(
                                                                future: RebanhoTable().queryRows(
                                                                    queryFn: (q) => q
                                                                            .eqOrNull(
                                                                                'idPropriedade',
                                                                                FFAppState()
                                                                                        .propriedadeSelecionada
                                                                                        .idPropriedade,
                                                                            )
                                                                            .eqOrNull(
                                                                                'deletado',
                                                                                'NAO',
                                                                            )
                                                                            .eqOrNull(
                                                                                'status',
                                                                                'Na propriedade',
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<RebanhoRow> pgRebanhRebanhoRowList =
                                      snapshot.data!;

                                  return Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 920.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          32.0, 34.0, 32.0, 34.0),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Editar reprodução de um animal',
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
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              ].divide(const SizedBox(width: 24.0)),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tipo de reprodução',
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
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Flexible(
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.tipoReproducao =
                                                              'Inseminação';
                                                          safeSetState(() {});
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 74.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .customColor2,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                            border: Border.all(
                                                              color: _model
                                                                          .tipoReproducao ==
                                                                      'Inseminação'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary
                                                                  : Colors
                                                                      .transparent,
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
                                                              children: [
                                                                if (_model
                                                                        .tipoReproducao !=
                                                                    'Inseminação')
                                                                  Icon(
                                                                    Icons
                                                                        .circle_outlined,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                if (_model
                                                                        .tipoReproducao ==
                                                                    'Inseminação')
                                                                  FaIcon(
                                                                    FontAwesomeIcons
                                                                        .dotCircle,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    size: 24.0,
                                                                  ),
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Inseminação',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              20.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          _model.tipoReproducao =
                                                              'Monta Natural';
                                                          safeSetState(() {});
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 74.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .customColor2,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6.0),
                                                            border: Border.all(
                                                              color: _model
                                                                          .tipoReproducao ==
                                                                      'Monta Natural'
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary
                                                                  : Colors
                                                                      .transparent,
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
                                                              children: [
                                                                if (_model
                                                                        .tipoReproducao !=
                                                                    'Monta Natural')
                                                                  Icon(
                                                                    Icons
                                                                        .circle_outlined,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                if (_model
                                                                        .tipoReproducao ==
                                                                    'Monta Natural')
                                                                  FaIcon(
                                                                    FontAwesomeIcons
                                                                        .dotCircle,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    size: 24.0,
                                                                  ),
                                                                Padding(
                                                                  padding: const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          10.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    'Monta Natural',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              20.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(width: 8.0)),
                                                ),
                                              ].divide(const SizedBox(height: 8.0)),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Matriz*',
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
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                          Flexible(
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 56.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor2,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        12.0,
                                                                        0.0,
                                                                        12.0,
                                                                        0.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      '${valueOrDefault<String>(
                                                                        pgReproducaoEditAnimalReproducaoRow?.numMatriz ==
                                                                                'null'
                                                                            ? 'S/N'
                                                                            : valueOrDefault<String>(
                                                                                pgReproducaoEditAnimalReproducaoRow?.numMatriz,
                                                                                'S/N',
                                                                              ),
                                                                        'S/N',
                                                                      )} • ${valueOrDefault<String>(
                                                                        pgReproducaoEditAnimalReproducaoRow?.nomeMatriz ==
                                                                                'null'
                                                                            ? 'S/N'
                                                                            : valueOrDefault<String>(
                                                                                pgReproducaoEditAnimalReproducaoRow?.nomeMatriz,
                                                                                'S/N',
                                                                              ),
                                                                        'S/N',
                                                                      )} • ${valueOrDefault<String>(
                                                                        () {
                                                                          if (pgReproducaoEditAnimalReproducaoRow?.nascimentoMatriz ==
                                                                              null) {
                                                                            return 'N/A';
                                                                          } else if (pgReproducaoEditAnimalReproducaoRow?.nascimentoMatriz ==
                                                                              null) {
                                                                            return 'N/A';
                                                                          } else {
                                                                            return dateTimeFormat(
                                                                              "d/M/y",
                                                                              pgReproducaoEditAnimalReproducaoRow?.nascimentoMatriz,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            );
                                                                          }
                                                                        }(),
                                                                        'N/A',
                                                                      )}',
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
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ].divide(const SizedBox(
                                                            width: 16.0)),
                                                      ),
                                                    ].divide(
                                                        const SizedBox(height: 8.0)),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                                                                            'Escore corporal',
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
                                                    ),
                                                    Container(
                                                      width: 327.0,
                                                      height: 56.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .customColor2,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    10.0,
                                                                    12.0,
                                                                    10.0,
                                                                    12.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            FlutterFlowIconButton(
                                                              borderRadius:
                                                                  100.0,
                                                              buttonSize: 30.0,
                                                              fillColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                              icon: FaIcon(
                                                                FontAwesomeIcons
                                                                    .minus,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                size: 14.0,
                                                              ),
                                                              onPressed: (_model
                                                                          .score ==
                                                                      0.5)
                                                                  ? null
                                                                  : () async {
                                                                      _model.score =
                                                                          _model.score! +
                                                                              -0.5;
                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                _model.score
                                                                    ?.toString(),
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
                                                            FlutterFlowIconButton(
                                                              borderRadius:
                                                                  100.0,
                                                              buttonSize: 30.0,
                                                              fillColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .tertiary,
                                                              icon: Icon(
                                                                Icons.add,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
                                                                size: 14.0,
                                                              ),
                                                              onPressed: (_model
                                                                          .score ==
                                                                      5.0)
                                                                  ? null
                                                                  : () async {
                                                                      _model.score =
                                                                          _model.score! +
                                                                              0.5;
                                                                      safeSetState(
                                                                          () {});
                                                                    },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(height: 8.0)),
                                                ),
                                              ].divide(const SizedBox(width: 16.0)),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Reprodutor*',
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
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Flexible(
                                                      child: Builder(
                                                        builder: (context) =>
                                                            InkWell(
                                                          splashColor: Colors
                                                              .transparent,
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () async {
                                                            await showDialog(
                                                              barrierColor: Colors
                                                                  .transparent,
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
                                                                        SizedBox(
                                                                      height:
                                                                          450.0,
                                                                      width:
                                                                          370.0,
                                                                      child:
                                                                          PopupRebanhosWidget(
                                                                        sexo:
                                                                            'Macho',
                                                                        reproducao:
                                                                            true,
                                                                        tipoReproducao:
                                                                            _model.tipoReproducao,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            height: 56.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .customColor2,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          12.0,
                                                                          0.0,
                                                                          12.0,
                                                                          0.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    '${valueOrDefault<String>(
                                                                      FFAppState().reprodutorSelecionado.numAnimal ==
                                                                              'null'
                                                                          ? 'S/N'
                                                                          : valueOrDefault<
                                                                              String>(
                                                                              FFAppState().reprodutorSelecionado.numAnimal,
                                                                              'S/N',
                                                                            ),
                                                                      'S/N',
                                                                    )} • ${valueOrDefault<String>(
                                                                      FFAppState().reprodutorSelecionado.nomeAnimal ==
                                                                              'null'
                                                                          ? 'S/N'
                                                                          : valueOrDefault<
                                                                              String>(
                                                                              FFAppState().reprodutorSelecionado.nomeAnimal,
                                                                              'S/N',
                                                                            ),
                                                                      'S/N',
                                                                    )} • ${valueOrDefault<String>(
                                                                      () {
                                                                        if (FFAppState().reprodutorSelecionado.dataNascAnimal ==
                                                                            'null') {
                                                                          return 'N/A';
                                                                        } else if (FFAppState().reprodutorSelecionado.dataNascAnimal ==
                                                                                '') {
                                                                          return 'N/A';
                                                                        } else {
                                                                          return valueOrDefault<
                                                                              String>(
                                                                            dateTimeFormat(
                                                                              "d/M/y",
                                                                              functions.converterParaData(FFAppState().reprodutorSelecionado.dataNascAnimal),
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            'N/A',
                                                                          );
                                                                        }
                                                                      }(),
                                                                      'N/A',
                                                                    )}',
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
                                                                  Icon(
                                                                    Icons
                                                                        .open_in_new_rounded,
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                    size: 24.0,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
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
                                                        FFAppState()
                                                                .reprodutorSelecionado =
                                                            AnimalSelecionadoStruct();
                                                        safeSetState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.close,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .accent3,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(width: 16.0)),
                                                ),
                                              ].divide(const SizedBox(height: 8.0)),
                                            ),
                                            if (pgReproducaoEditAnimalReproducaoRow
                                                    ?.tipoReproducao ==
                                                'Inseminação')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Data da inseminação*',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                  ),
                                                  Stack(
                                                    children: [
                                                      TextFormField(
                                                        controller: _model
                                                                .dataInseminacaoTextController ??=
                                                            TextEditingController(
                                                          text: valueOrDefault<
                                                              String>(
                                                            _model.datePicked1 !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    "d/M/y",
                                                                    _model
                                                                        .datePicked1,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )
                                                                : dateTimeFormat(
                                                                    "d/M/y",
                                                                    pgReproducaoEditAnimalReproducaoRow
                                                                        ?.dataInseminacao,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ),
                                                            'dd/mm/yyyy',
                                                          ),
                                                        ),
                                                        focusNode: _model
                                                            .dataInseminacaoFocusNode,
                                                        autofocus: false,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                          hintText:
                                                              'dd/mm/aaaa',
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
                                                                    color: const Color(
                                                                        0xFFBEBEBE),
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
                                                                        8.0),
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
                                                                        8.0),
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
                                                                        8.0),
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
                                                                        8.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor2,
                                                          suffixIcon: Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
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
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                            .dataInseminacaoTextControllerValidator
                                                            .asValidator(
                                                                context),
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
                                                          final datePicked1Date =
                                                              await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                getCurrentTimestamp,
                                                            firstDate:
                                                                DateTime(1900),
                                                            lastDate:
                                                                DateTime(2050),
                                                            builder: (context,
                                                                child) {
                                                              return wrapInMaterialDatePickerTheme(
                                                                context,
                                                                child!,
                                                                headerBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                headerForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                headerTextStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              32.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .headlineLarge
                                                                              .fontStyle,
                                                                        ),
                                                                pickerBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                pickerForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                selectedDateTimeBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                selectedDateTimeForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                actionButtonForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                iconSize: 24.0,
                                                              );
                                                            },
                                                          );

                                                          if (datePicked1Date !=
                                                              null) {
                                                            safeSetState(() {
                                                              _model.datePicked1 =
                                                                  DateTime(
                                                                datePicked1Date
                                                                    .year,
                                                                datePicked1Date
                                                                    .month,
                                                                datePicked1Date
                                                                    .day,
                                                              );
                                                            });
                                                          } else if (_model
                                                                  .datePicked1 !=
                                                              null) {
                                                            safeSetState(() {
                                                              _model.datePicked1 =
                                                                  getCurrentTimestamp;
                                                            });
                                                          }
                                                          safeSetState(() {
                                                            _model.dataInseminacaoTextController
                                                                    ?.text =
                                                                dateTimeFormat(
                                                              "d/M/y",
                                                              _model
                                                                  .datePicked1,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            );
                                                          });

                                                          safeSetState(() {});
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 56.0,
                                                          decoration:
                                                              const BoxDecoration(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(const SizedBox(height: 8.0)),
                                              ),
                                            if (pgReproducaoEditAnimalReproducaoRow
                                                    ?.tipoReproducao ==
                                                'Inseminação')
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Data de partida do sêmen',
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
                                                                fontSize: 16.0,
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
                                                        Stack(
                                                          children: [
                                                            TextFormField(
                                                              controller: _model
                                                                      .dataPartidaSemenTextController ??=
                                                                  TextEditingController(
                                                                text:
                                                                    valueOrDefault<
                                                                        String>(
                                                                  _model.datePicked2 !=
                                                                          null
                                                                      ? dateTimeFormat(
                                                                          "d/M/y",
                                                                          _model
                                                                              .datePicked2,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        )
                                                                      : dateTimeFormat(
                                                                          "d/M/y",
                                                                          pgReproducaoEditAnimalReproducaoRow
                                                                              ?.dataPartidaSemen,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ),
                                                                  'dd/mm/yyyy',
                                                                ),
                                                              ),
                                                              focusNode: _model
                                                                  .dataPartidaSemenFocusNode,
                                                              autofocus: false,
                                                              obscureText:
                                                                  false,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: false,
                                                                labelStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                hintText:
                                                                    'dd/mm/aaaa',
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
                                                                              8.0),
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
                                                                              8.0),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                filled: true,
                                                                fillColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor2,
                                                                suffixIcon:
                                                                    Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
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
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              validator: _model
                                                                  .dataPartidaSemenTextControllerValidator
                                                                  .asValidator(
                                                                      context),
                                                            ),
                                                            InkWell(
                                                              splashColor: Colors
                                                                  .transparent,
                                                              focusColor: Colors
                                                                  .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () async {
                                                                final datePicked2Date =
                                                                    await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      getCurrentTimestamp,
                                                                  firstDate:
                                                                      DateTime(
                                                                          1900),
                                                                  lastDate:
                                                                      DateTime(
                                                                          2050),
                                                                  builder:
                                                                      (context,
                                                                          child) {
                                                                    return wrapInMaterialDatePickerTheme(
                                                                      context,
                                                                      child!,
                                                                      headerBackgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                      headerForegroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .info,
                                                                      headerTextStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                32.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                      pickerBackgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondaryBackground,
                                                                      pickerForegroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                      selectedDateTimeBackgroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                      selectedDateTimeForegroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .info,
                                                                      actionButtonForegroundColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .primaryText,
                                                                      iconSize:
                                                                          24.0,
                                                                    );
                                                                  },
                                                                );

                                                                if (datePicked2Date !=
                                                                    null) {
                                                                  safeSetState(
                                                                      () {
                                                                    _model.datePicked2 =
                                                                        DateTime(
                                                                      datePicked2Date
                                                                          .year,
                                                                      datePicked2Date
                                                                          .month,
                                                                      datePicked2Date
                                                                          .day,
                                                                    );
                                                                  });
                                                                } else if (_model
                                                                        .datePicked2 !=
                                                                    null) {
                                                                  safeSetState(
                                                                      () {
                                                                    _model.datePicked2 =
                                                                        getCurrentTimestamp;
                                                                  });
                                                                }
                                                                safeSetState(
                                                                    () {
                                                                  _model.dataPartidaSemenTextController
                                                                          ?.text =
                                                                      dateTimeFormat(
                                                                    "d/M/y",
                                                                    _model
                                                                        .datePicked2,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  );
                                                                });
                                                              },
                                                              child: Container(
                                                                width: double
                                                                    .infinity,
                                                                height: 56.0,
                                                                decoration:
                                                                    const BoxDecoration(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ].divide(const SizedBox(
                                                          height: 8.0)),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Partida do sêmen',
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
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                      Container(
                                                        width: 327.0,
                                                        height: 56.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .customColor2,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      10.0,
                                                                      12.0,
                                                                      10.0,
                                                                      12.0),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              FlutterFlowIconButton(
                                                                borderRadius:
                                                                    100.0,
                                                                buttonSize:
                                                                    30.0,
                                                                fillColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .tertiary,
                                                                icon: FaIcon(
                                                                  FontAwesomeIcons
                                                                      .minus,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  size: 14.0,
                                                                ),
                                                                onPressed: (_model
                                                                            .partidaSemen ==
                                                                        1)
                                                                    ? null
                                                                    : () async {
                                                                        _model.partidaSemen =
                                                                            _model.partidaSemen! +
                                                                                -1;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                              ),
                                                              Text(
                                                                valueOrDefault<
                                                                    String>(
                                                                  _model
                                                                      .partidaSemen
                                                                      ?.toString(),
                                                                  '1',
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
                                                              ),
                                                              FlutterFlowIconButton(
                                                                borderRadius:
                                                                    100.0,
                                                                buttonSize:
                                                                    30.0,
                                                                fillColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .tertiary,
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  size: 14.0,
                                                                ),
                                                                onPressed: (_model
                                                                            .partidaSemen ==
                                                                        5)
                                                                    ? null
                                                                    : () async {
                                                                        _model.partidaSemen =
                                                                            _model.partidaSemen! +
                                                                                1;
                                                                        safeSetState(
                                                                            () {});
                                                                      },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        const SizedBox(height: 8.0)),
                                                  ),
                                                ].divide(const SizedBox(width: 16.0)),
                                              ),
                                            if ((pgReproducaoEditAnimalReproducaoRow
                                                        ?.tipoReproducao ==
                                                    'Inseminação') &&
                                                (pgReproducaoEditAnimalReproducaoRow
                                                        ?.dataInseminacao !=
                                                    null))
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Previsão do parto',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 56.0,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .customColor2,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            valueOrDefault<
                                                                String>(
                                                              dateTimeFormat(
                                                                "d/M/y",
                                                                functions.dataMais295(_model.datePicked1 !=
                                                                        null
                                                                    ? _model
                                                                        .datePicked1!
                                                                    : pgReproducaoEditAnimalReproducaoRow!
                                                                        .dataInseminacao!),
                                                                locale: FFLocalizations.of(
                                                                        context)
                                                                    .languageCode,
                                                              ),
                                                              'dd/mm/yyyy',
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
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    'Data da inseminação + 295 dias',
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
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent3,
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
                                                ].divide(const SizedBox(height: 8.0)),
                                              ),
                                            if (pgReproducaoEditAnimalReproducaoRow
                                                    ?.tipoReproducao ==
                                                'Monta Natural')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Data da inicial*',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                  ),
                                                  Stack(
                                                    children: [
                                                      TextFormField(
                                                        controller: _model
                                                                .dataInicialTextController ??=
                                                            TextEditingController(
                                                          text: valueOrDefault<
                                                              String>(
                                                            _model.datePicked3 !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    "d/M/y",
                                                                    _model
                                                                        .datePicked3,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )
                                                                : dateTimeFormat(
                                                                    "d/M/y",
                                                                    pgReproducaoEditAnimalReproducaoRow
                                                                        ?.dataInicial,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ),
                                                            'dd/mm/yyyy',
                                                          ),
                                                        ),
                                                        focusNode: _model
                                                            .dataInicialFocusNode,
                                                        autofocus: false,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                          hintText:
                                                              valueOrDefault<
                                                                  String>(
                                                            _model.datePicked3 !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    "d/M/y",
                                                                    _model
                                                                        .datePicked3,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )
                                                                : dateTimeFormat(
                                                                    "d/M/y",
                                                                    pgReproducaoEditAnimalReproducaoRow
                                                                        ?.dataInicial,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ),
                                                            'dd/mm/yyyy',
                                                          ),
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
                                                                    color: const Color(
                                                                        0xFFBEBEBE),
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
                                                                        8.0),
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
                                                                        8.0),
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
                                                                        8.0),
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
                                                                        8.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor2,
                                                          suffixIcon: Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
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
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                            .dataInicialTextControllerValidator
                                                            .asValidator(
                                                                context),
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
                                                          final datePicked3Date =
                                                              await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                getCurrentTimestamp,
                                                            firstDate:
                                                                DateTime(1900),
                                                            lastDate:
                                                                DateTime(2050),
                                                            builder: (context,
                                                                child) {
                                                              return wrapInMaterialDatePickerTheme(
                                                                context,
                                                                child!,
                                                                headerBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                headerForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                headerTextStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              32.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .headlineLarge
                                                                              .fontStyle,
                                                                        ),
                                                                pickerBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                pickerForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                selectedDateTimeBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                selectedDateTimeForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                actionButtonForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                iconSize: 24.0,
                                                              );
                                                            },
                                                          );

                                                          if (datePicked3Date !=
                                                              null) {
                                                            safeSetState(() {
                                                              _model.datePicked3 =
                                                                  DateTime(
                                                                datePicked3Date
                                                                    .year,
                                                                datePicked3Date
                                                                    .month,
                                                                datePicked3Date
                                                                    .day,
                                                              );
                                                            });
                                                          } else if (_model
                                                                  .datePicked3 !=
                                                              null) {
                                                            safeSetState(() {
                                                              _model.datePicked3 =
                                                                  getCurrentTimestamp;
                                                            });
                                                          }
                                                          safeSetState(() {
                                                            _model.dataInicialTextController
                                                                    ?.text =
                                                                dateTimeFormat(
                                                              "d/M/y",
                                                              _model
                                                                  .datePicked3,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            );
                                                          });
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 56.0,
                                                          decoration:
                                                              const BoxDecoration(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(const SizedBox(height: 8.0)),
                                              ),
                                            if (pgReproducaoEditAnimalReproducaoRow
                                                    ?.tipoReproducao ==
                                                'Monta Natural')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Data da final*',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                  ),
                                                  Stack(
                                                    children: [
                                                      TextFormField(
                                                        controller: _model
                                                                .dataFinalTextController ??=
                                                            TextEditingController(
                                                          text: valueOrDefault<
                                                              String>(
                                                            _model.datePicked4 !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    "d/M/y",
                                                                    _model
                                                                        .datePicked4,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )
                                                                : dateTimeFormat(
                                                                    "d/M/y",
                                                                    pgReproducaoEditAnimalReproducaoRow
                                                                        ?.dataFinal,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ),
                                                            'dd/mm/yyyy',
                                                          ),
                                                        ),
                                                        focusNode: _model
                                                            .dataFinalFocusNode,
                                                        autofocus: false,
                                                        obscureText: false,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          labelStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelMedium
                                                                        .fontStyle,
                                                                  ),
                                                          hintText:
                                                              valueOrDefault<
                                                                  String>(
                                                            _model.datePicked4 !=
                                                                    null
                                                                ? dateTimeFormat(
                                                                    "d/M/y",
                                                                    _model
                                                                        .datePicked4,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  )
                                                                : dateTimeFormat(
                                                                    "d/M/y",
                                                                    pgReproducaoEditAnimalReproducaoRow
                                                                        ?.dataFinal,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ),
                                                            'dd/mm/yyyy',
                                                          ),
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
                                                                    color: const Color(
                                                                        0xFFBEBEBE),
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
                                                                        8.0),
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
                                                                        8.0),
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
                                                                        8.0),
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
                                                                        8.0),
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .customColor2,
                                                          suffixIcon: Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
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
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                            .dataFinalTextControllerValidator
                                                            .asValidator(
                                                                context),
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
                                                          final datePicked4Date =
                                                              await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                                getCurrentTimestamp,
                                                            firstDate:
                                                                DateTime(1900),
                                                            lastDate:
                                                                DateTime(2050),
                                                            builder: (context,
                                                                child) {
                                                              return wrapInMaterialDatePickerTheme(
                                                                context,
                                                                child!,
                                                                headerBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                headerForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                headerTextStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              32.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .headlineLarge
                                                                              .fontStyle,
                                                                        ),
                                                                pickerBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryBackground,
                                                                pickerForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                selectedDateTimeBackgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                selectedDateTimeForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .info,
                                                                actionButtonForegroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                iconSize: 24.0,
                                                              );
                                                            },
                                                          );

                                                          if (datePicked4Date !=
                                                              null) {
                                                            safeSetState(() {
                                                              _model.datePicked4 =
                                                                  DateTime(
                                                                datePicked4Date
                                                                    .year,
                                                                datePicked4Date
                                                                    .month,
                                                                datePicked4Date
                                                                    .day,
                                                              );
                                                            });
                                                          } else if (_model
                                                                  .datePicked4 !=
                                                              null) {
                                                            safeSetState(() {
                                                              _model.datePicked4 =
                                                                  getCurrentTimestamp;
                                                            });
                                                          }
                                                          safeSetState(() {
                                                            _model.dataFinalTextController
                                                                    ?.text =
                                                                dateTimeFormat(
                                                              "d/M/y",
                                                              _model
                                                                  .datePicked4,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            );
                                                          });
                                                        },
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 56.0,
                                                          decoration:
                                                              const BoxDecoration(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(const SizedBox(height: 8.0)),
                                              ),
                                            if (pgReproducaoEditAnimalReproducaoRow
                                                    ?.tipoReproducao ==
                                                'Inseminação')
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Inseminador',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                  ),
                                                  TextFormField(
                                                    controller: _model
                                                            .nomeInseminadorTextController ??=
                                                        TextEditingController(
                                                      text:
                                                          pgReproducaoEditAnimalReproducaoRow
                                                              ?.inseminador,
                                                    ),
                                                    focusNode: _model
                                                        .nomeInseminadorFocusNode,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: false,
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
                                                                fontSize: 16.0,
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
                                                      hintText:
                                                          pgReproducaoEditAnimalReproducaoRow
                                                              ?.inseminador,
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
                                                                color: const Color(
                                                                    0xFFBEBEBE),
                                                                fontSize: 16.0,
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
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .customColor2,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                        .nomeInseminadorTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ].divide(const SizedBox(height: 8.0)),
                                              ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if (_model.ressinc == true)
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
                                                      _model.ressinc = false;
                                                      safeSetState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons.check_box_rounded,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                if (_model.ressinc == false)
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
                                                      _model.ressinc = true;
                                                      safeSetState(() {});
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .check_box_outline_blank,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                Text(
                                                  'Ressincronização',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ].divide(const SizedBox(width: 8.0)),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    if (_model.parida == true)
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
                                                                                                                    _model.parida = false;
                                                          safeSetState(() {});
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .check_box_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                    if (_model.parida == false)
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
                                                                                                                    _model.parida = true;
                                                          safeSetState(() {});
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .check_box_outline_blank,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .alternate,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                    Text(
                                                      'Parida',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            font: GoogleFonts
                                                                .poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      const SizedBox(width: 8.0)),
                                                ),
                                                if (_model.parida == true)
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Data do parto',
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
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                      Stack(
                                                        children: [
                                                          SizedBox(
                                                            width: 200.0,
                                                            child:
                                                                TextFormField(
                                                              controller: _model
                                                                      .dataParidaTextController ??=
                                                                  TextEditingController(
                                                                text:
                                                                    valueOrDefault<
                                                                        String>(
                                                                  _model.datePicked5 !=
                                                                          null
                                                                      ? dateTimeFormat(
                                                                          "d/M/y",
                                                                          _model
                                                                              .datePicked5,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        )
                                                                      : dateTimeFormat(
                                                                          "d/M/y",
                                                                          pgReproducaoEditAnimalReproducaoRow
                                                                              ?.dataParto,
                                                                          locale:
                                                                              FFLocalizations.of(context).languageCode,
                                                                        ),
                                                                  'dd/mm/aaaa',
                                                                ),
                                                              ),
                                                              focusNode: _model
                                                                  .dataParidaFocusNode,
                                                              autofocus: false,
                                                              readOnly: true,
                                                              obscureText:
                                                                  false,
                                                              decoration:
                                                                  InputDecoration(
                                                                isDense: false,
                                                                labelStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .fontStyle,
                                                                    ),
                                                                hintText:
                                                                    'dd/mm/aaaa',
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
                                                                              8.0),
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
                                                                              8.0),
                                                                ),
                                                                errorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                focusedErrorBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .error,
                                                                    width: 1.0,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                                filled: true,
                                                                fillColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .customColor2,
                                                                suffixIcon:
                                                                    Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
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
                                                              cursorColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              validator: _model
                                                                  .dataParidaTextControllerValidator
                                                                  .asValidator(
                                                                      context),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              final datePicked5Date =
                                                                  await showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    getCurrentTimestamp,
                                                                firstDate:
                                                                    DateTime(
                                                                        1900),
                                                                lastDate:
                                                                    DateTime(
                                                                        2050),
                                                                builder:
                                                                    (context,
                                                                        child) {
                                                                  return wrapInMaterialDatePickerTheme(
                                                                    context,
                                                                    child!,
                                                                    headerBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    headerForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .info,
                                                                    headerTextStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              32.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .headlineLarge
                                                                              .fontStyle,
                                                                        ),
                                                                    pickerBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                    pickerForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    selectedDateTimeBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    selectedDateTimeForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .info,
                                                                    actionButtonForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    iconSize:
                                                                        24.0,
                                                                  );
                                                                },
                                                              );

                                                              if (datePicked5Date !=
                                                                  null) {
                                                                safeSetState(
                                                                    () {
                                                                  _model.datePicked5 =
                                                                      DateTime(
                                                                    datePicked5Date
                                                                        .year,
                                                                    datePicked5Date
                                                                        .month,
                                                                    datePicked5Date
                                                                        .day,
                                                                  );
                                                                });
                                                              } else if (_model
                                                                      .datePicked5 !=
                                                                  null) {
                                                                safeSetState(
                                                                    () {
                                                                  _model.datePicked5 =
                                                                      getCurrentTimestamp;
                                                                });
                                                              }
                                                              safeSetState(() {
                                                                _model.dataParidaTextController
                                                                        ?.text =
                                                                    dateTimeFormat(
                                                                  "d/M/y",
                                                                  _model
                                                                      .datePicked5,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                );
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 200.0,
                                                              height: 56.0,
                                                              decoration:
                                                                  const BoxDecoration(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                              ].divide(const SizedBox(width: 16.0)),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                                                                                'Diagnóstico*',
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
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                      if (pgRebanhRebanhoRowList
                                                          .where((e) =>
                                                              e.sexo == 'Macho')
                                                          .toList()
                                                          .isNotEmpty)
                                                        FlutterFlowDropDown<
                                                            String>(
                                                          controller: _model
                                                                  .dropDownStatusValueController ??=
                                                              FormFieldController<
                                                                  String>(
                                                            _model.dropDownStatusValue ??=
                                                                pgReproducaoEditAnimalReproducaoRow
                                                                            ?.statusReproducao ==
                                                                        'Parida'
                                                                    ? 'Não diagnosticado'
                                                                    : pgReproducaoEditAnimalReproducaoRow
                                                                        ?.statusReproducao,
                                                          ),
                                                          options: const [
                                                            'Não diagnosticado',
                                                            'Absorção',
                                                            'Aborto',
                                                            'Prenhez',
                                                            'Vazio'
                                                          ],
                                                          onChanged: (val) =>
                                                              safeSetState(() =>
                                                                  _model.dropDownStatusValue =
                                                                      val),
                                                          height: 56.0,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
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
                                                          hintText:
                                                              'Selecionar',
                                                          icon: Icon(
                                                            Icons
                                                                .keyboard_arrow_down_rounded,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            size: 24.0,
                                                          ),
                                                          fillColor:
                                                              const Color(0xFFF1F1F1),
                                                          elevation: 2.0,
                                                          borderColor: Colors
                                                              .transparent,
                                                          borderWidth: 0.0,
                                                          borderRadius: 8.0,
                                                          margin:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      12.0,
                                                                      0.0,
                                                                      12.0,
                                                                      0.0),
                                                          hidesUnderline: true,
                                                          isOverButton: false,
                                                          isSearchable: false,
                                                          isMultiSelect: false,
                                                        ),
                                                    ].divide(
                                                        const SizedBox(height: 8.0)),
                                                  ),
                                                ),
                                                Container(
                                                  width: 327.0,
                                                  decoration: const BoxDecoration(),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                                                                                'Data do diagnóstico',
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
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                      Stack(
                                                        children: [
                                                          TextFormField(
                                                            controller: _model
                                                                    .dataStatusTextController ??=
                                                                TextEditingController(
                                                              text:
                                                                  valueOrDefault<
                                                                      String>(
                                                                _model.datePicked6 !=
                                                                        null
                                                                    ? dateTimeFormat(
                                                                        "d/M/y",
                                                                        _model
                                                                            .datePicked6,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      )
                                                                    : dateTimeFormat(
                                                                        "d/M/y",
                                                                        pgReproducaoEditAnimalReproducaoRow
                                                                            ?.dataStatus,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      ),
                                                                'dd/mm/yyyy',
                                                              ),
                                                            ),
                                                            focusNode: _model
                                                                .dataStatusFocusNode,
                                                            autofocus: false,
                                                            obscureText: false,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: false,
                                                              labelStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .labelMedium
                                                                            .fontStyle,
                                                                      ),
                                                              hintText:
                                                                  valueOrDefault<
                                                                      String>(
                                                                _model.datePicked6 !=
                                                                        null
                                                                    ? dateTimeFormat(
                                                                        "d/M/y",
                                                                        _model
                                                                            .datePicked6,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      )
                                                                    : dateTimeFormat(
                                                                        "d/M/y",
                                                                        pgReproducaoEditAnimalReproducaoRow
                                                                            ?.dataStatus,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      ),
                                                                'dd/mm/yyyy',
                                                              ),
                                                              hintStyle:
                                                                  FlutterFlowTheme.of(
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
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
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
                                                                            8.0),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .error,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              filled: true,
                                                              fillColor: FlutterFlowTheme
                                                                      .of(context)
                                                                  .customColor2,
                                                              suffixIcon: Icon(
                                                                Icons
                                                                    .calendar_today,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryText,
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
                                                            cursorColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                            validator: _model
                                                                .dataStatusTextControllerValidator
                                                                .asValidator(
                                                                    context),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              final datePicked6Date =
                                                                  await showDatePicker(
                                                                context:
                                                                    context,
                                                                initialDate:
                                                                    getCurrentTimestamp,
                                                                firstDate:
                                                                    DateTime(
                                                                        1900),
                                                                lastDate:
                                                                    DateTime(
                                                                        2050),
                                                                builder:
                                                                    (context,
                                                                        child) {
                                                                  return wrapInMaterialDatePickerTheme(
                                                                    context,
                                                                    child!,
                                                                    headerBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    headerForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .info,
                                                                    headerTextStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              32.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .headlineLarge
                                                                              .fontStyle,
                                                                        ),
                                                                    pickerBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                    pickerForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    selectedDateTimeBackgroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                    selectedDateTimeForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .info,
                                                                    actionButtonForegroundColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    iconSize:
                                                                        24.0,
                                                                  );
                                                                },
                                                              );

                                                              if (datePicked6Date !=
                                                                  null) {
                                                                safeSetState(
                                                                    () {
                                                                  _model.datePicked6 =
                                                                      DateTime(
                                                                    datePicked6Date
                                                                        .year,
                                                                    datePicked6Date
                                                                        .month,
                                                                    datePicked6Date
                                                                        .day,
                                                                  );
                                                                });
                                                              } else if (_model
                                                                      .datePicked6 !=
                                                                  null) {
                                                                safeSetState(
                                                                    () {
                                                                  _model.datePicked6 =
                                                                      getCurrentTimestamp;
                                                                });
                                                              }
                                                              safeSetState(() {
                                                                _model.dataStatusTextController
                                                                        ?.text =
                                                                    dateTimeFormat(
                                                                  "d/M/y",
                                                                  _model
                                                                      .datePicked6,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                );
                                                              });
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              height: 56.0,
                                                              decoration:
                                                                  const BoxDecoration(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ].divide(
                                                        const SizedBox(height: 8.0)),
                                                  ),
                                                ),
                                              ].divide(const SizedBox(width: 16.0)),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Anotações',
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
                                                ),
                                                Container(
                                                  height: 100.0,
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F1F1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: TextFormField(
                                                    controller: _model
                                                            .anotacoesTextController ??=
                                                        TextEditingController(
                                                      text:
                                                          pgReproducaoEditAnimalReproducaoRow
                                                              ?.anotacoes,
                                                    ),
                                                    focusNode: _model
                                                        .anotacoesFocusNode,
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: false,
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
                                                                fontSize: 16.0,
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
                                                      hintText:
                                                          pgReproducaoEditAnimalReproducaoRow
                                                              ?.anotacoes,
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
                                                                color: const Color(
                                                                    0xFFBEBEBE),
                                                                fontSize: 16.0,
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
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                        .anotacoesTextControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ].divide(const SizedBox(height: 8.0)),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                FFButtonWidget(
                                                  onPressed: () async {
                                                    context.pushNamed(
                                                        PgReproducaoWidget
                                                            .routeName);
                                                  },
                                                  text: 'Cancelar',
                                                  options: FFButtonOptions(
                                                    width: 218.0,
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
                                                                  .primary,
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
                                                              .primary,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                ),
                                                FFButtonWidget(
                                                  onPressed: () async {
                                                    if (_model.tipoReproducao ==
                                                        'Inseminação') {
                                                      await ReproducaoTable()
                                                          .update(
                                                        data: {
                                                          'tipo_reproducao':
                                                              _model
                                                                  .tipoReproducao,
                                                          'score_corporal':
                                                              _model.score,
                                                          'data_inseminacao': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked1 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataInseminacao),
                                                          'data_partida_semen': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked2 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataPartidaSemen),
                                                          'partida_semen':
                                                              _model
                                                                  .partidaSemen,
                                                          'previsao_parto': supaSerialize<
                                                              DateTime>(functions.dataMais295(_model
                                                                      .datePicked1 !=
                                                                  null
                                                              ? _model
                                                                  .datePicked1!
                                                              : pgReproducaoEditAnimalReproducaoRow!
                                                                  .dataInseminacao!)),
                                                          'data_inicial': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked3 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataInicial),
                                                          'data_final': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked4 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataFinal),
                                                          'status_reproducao':
                                                              _model
                                                                  .dropDownStatusValue,
                                                          'inseminador': _model
                                                              .nomeInseminadorTextController
                                                              .text,
                                                          'anotacoes': _model
                                                              .anotacoesTextController
                                                              .text,
                                                          'updated_at':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  getCurrentTimestamp),
                                                          'data_status': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked6 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataStatus),
                                                          'numReprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .numAnimal,
                                                          'nomeReprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .nomeAnimal,
                                                          'nascimentoReprodutor':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions.converterParaData(
                                                                      FFAppState()
                                                                          .reprodutorSelecionado
                                                                          .dataNascAnimal)),
                                                          'racaReprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .racaAnimal,
                                                          'id_rebanho_matriz':
                                                              FFAppState()
                                                                  .matrizSelecionada
                                                                  .idAnimal,
                                                          'id_rebanho_reprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .idAnimal,
                                                          'ressinc':
                                                              _model.ressinc ==
                                                                      true
                                                                  ? 'SIM'
                                                                  : 'NAO',
                                                          'parida':
                                                              _model.parida ==
                                                                      true
                                                                  ? 'SIM'
                                                                  : 'NAO',
                                                          'data_parto': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked5 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataParto),
                                                        },
                                                        matchingRows: (rows) =>
                                                            rows.eqOrNull(
                                                          'id_reproducao',
                                                          widget.idReproducao,
                                                        ),
                                                      );
                                                    } else {
                                                      await ReproducaoTable()
                                                          .update(
                                                        data: {
                                                          'tipo_reproducao':
                                                              _model
                                                                  .tipoReproducao,
                                                          'score_corporal':
                                                              _model.score,
                                                          'data_inicial': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked3 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataInicial),
                                                          'data_final': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked4 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataFinal),
                                                          'status_reproducao':
                                                              _model
                                                                  .dropDownStatusValue,
                                                          'inseminador': _model
                                                              .nomeInseminadorTextController
                                                              .text,
                                                          'anotacoes': _model
                                                              .anotacoesTextController
                                                              .text,
                                                          'updated_at':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  getCurrentTimestamp),
                                                          'data_status': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked6 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataStatus),
                                                          'numReprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .numAnimal,
                                                          'nomeReprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .nomeAnimal,
                                                          'nascimentoReprodutor':
                                                              supaSerialize<
                                                                      DateTime>(
                                                                  functions.converterParaData(
                                                                      FFAppState()
                                                                          .reprodutorSelecionado
                                                                          .dataNascAnimal)),
                                                          'racaReprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .racaAnimal,
                                                          'id_rebanho_matriz':
                                                              FFAppState()
                                                                  .matrizSelecionada
                                                                  .idAnimal,
                                                          'id_rebanho_reprodutor':
                                                              FFAppState()
                                                                  .reprodutorSelecionado
                                                                  .idAnimal,
                                                          'ressinc':
                                                              _model.ressinc ==
                                                                      true
                                                                  ? 'SIM'
                                                                  : 'NAO',
                                                          'parida':
                                                              _model.parida ==
                                                                      true
                                                                  ? 'SIM'
                                                                  : 'NAO',
                                                          'data_parto': supaSerialize<
                                                              DateTime>(_model
                                                                  .datePicked5 ?? pgReproducaoEditAnimalReproducaoRow
                                                                  ?.dataParto),
                                                        },
                                                        matchingRows: (rows) =>
                                                            rows.eqOrNull(
                                                          'id_reproducao',
                                                          widget.idReproducao,
                                                        ),
                                                      );
                                                    }

                                                    await action_blocks
                                                        .countReproducoes(
                                                            context);
                                                    FFAppState()
                                                            .refreshReproducao =
                                                        true;
                                                    safeSetState(() {});

                                                    context.pushNamed(
                                                        PgReproducaoWidget
                                                            .routeName);
                                                  },
                                                  text: 'Salvar',
                                                  options: FFButtonOptions(
                                                    width: 218.0,
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
                                                            6.0),
                                                  ),
                                                ),
                                              ].divide(const SizedBox(width: 24.0)),
                                            ),
                                          ].divide(const SizedBox(height: 24.0)),
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
