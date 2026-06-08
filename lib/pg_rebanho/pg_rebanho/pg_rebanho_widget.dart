import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_rebanho_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pg_rebanho/cc_add_animal/cc_add_animal_widget.dart';
import '/pg_rebanho/cc_add_nascimento/cc_add_nascimento_widget.dart';
import '/pg_rebanho/cc_add_semen/cc_add_semen_widget.dart';
import '/pg_rebanho/cc_edt_animal/cc_edt_animal_widget.dart';
import '/pg_rebanho/modal_adicionar/modal_adicionar_widget.dart';
import '/pg_rebanho/modal_more/modal_more_widget.dart';
import '/pg_rebanho/pp_filtro_rebanho/pp_filtro_rebanho_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'dart:async';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_rebanho_model.dart';
export 'pg_rebanho_model.dart';

class PgRebanhoWidget extends StatefulWidget {
  const PgRebanhoWidget({super.key});

  static String routeName = 'pgRebanho';
  static String routePath = '/rebanho';

  @override
  State<PgRebanhoWidget> createState() => _PgRebanhoWidgetState();
}

class _PgRebanhoWidgetState extends State<PgRebanhoWidget> {
  late PgRebanhoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgRebanhoModel());

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.propriedadesUser = await PropriedadesTable().queryRows(
        queryFn: (q) =>
            q.or("userID.eq.$currentUserUid, usersID.like.$currentUserUid"),
      );
      await _loadRebanhos(refreshCounters: true);
      _model.disposeRefreshListener =
          FFAppState().onRefresh('refreshRebanho', () async {
        FFAppState().refreshRebanho = false;
        await _loadRebanhos(resetPage: true, refreshCounters: true);
      });
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

  bool _hasRebanhoFilters() {
    final s = FFAppState();
    return s.filtroSexo.isNotEmpty ||
        s.filtroStatusRebanho.isNotEmpty ||
        s.filtroCategoria.isNotEmpty ||
        s.filtroDataNacimentoDe != null ||
        s.filtroDataNacimentoAte != null ||
        s.filtroLoteId.isNotEmpty ||
        s.filtroLoteNome.isNotEmpty ||
        s.filtroRaca.isNotEmpty ||
        s.filtroOrigem.isNotEmpty;
  }

  int _rebanhoTotalPages() {
    final pages = (_model.rebanhosTotal / FFAppConstants.limit).ceil();
    return pages < 1 ? 1 : pages;
  }

  List<RebanhoDTStruct> _parseRebanhos(ApiCallResponse response) {
    final body = response.jsonBody;
    if (body is! Iterable) {
      return [];
    }
    return body
        .map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap)
        .withoutNulls
        .toList()
        .cast<RebanhoDTStruct>();
  }

  Future<void> _loadRebanhos({
    bool resetPage = false,
    bool refreshCounters = false,
  }) async {
    if (resetPage) {
      _model.pageNum = 1;
    }

    final requestId = ++_model.rebanhosRequestId;
    if (mounted) {
      safeSetState(() {
        _model.isLoadingRebanhos = true;
      });
    }

    try {
      final dataNascimentoDe = dateTimeFormat(
        "yyyy-MM-dd",
        FFAppState().filtroDataNacimentoDe,
        locale: FFLocalizations.of(context).languageCode,
      );
      final dataNascimentoAte = dateTimeFormat(
        "yyyy-MM-dd",
        FFAppState().filtroDataNacimentoAte,
        locale: FFLocalizations.of(context).languageCode,
      );
      final idPropriedade = FFAppState().propriedadeSelecionada.idPropriedade;
      final pesquisa = _model.textController.text;

      final buscaFuture =
          FunctionsSupabaseRebanhoGroup.buscarRebanhoFiltrosCall.call(
        pCategoria: FFAppState().filtroCategoria,
        pDataNascimentoDe: dataNascimentoDe,
        pDataNascimentoAte: dataNascimentoAte,
        pIdPropriedade: idPropriedade,
        pLoteNome: FFAppState().filtroLoteId.isNotEmpty
            ? FFAppState().filtroLoteId
            : FFAppState().filtroLoteNome,
        pOrigem: FFAppState().filtroOrigem,
        pRaca: FFAppState().filtroRaca,
        pSexo: FFAppState().filtroSexo,
        pStatus: FFAppState().filtroStatusRebanho,
        pPesquisa: pesquisa,
        pLimite: FFAppConstants.limit,
        pOffset:
            functions.calcDeslocamento(_model.pageNum, FFAppConstants.limit),
      );
      final countFuture =
          FunctionsSupabaseRebanhoGroup.countRebanhoFiltrosCall.call(
        pIdPropriedade: idPropriedade,
        pCategoria: FFAppState().filtroCategoria,
        pDataNascimentoDe: dataNascimentoDe,
        pDataNascimentoAte: dataNascimentoAte,
        pLoteID: FFAppState().filtroLoteId,
        pOrigem: FFAppState().filtroOrigem,
        pRaca: FFAppState().filtroRaca,
        pSexo: FFAppState().filtroSexo,
        pStatus: FFAppState().filtroStatusRebanho,
        pPesquisa: pesquisa,
      );
      final activeCountFuture = refreshCounters
          ? FunctionsSupabaseRebanhoGroup.countRebanhoFiltrosCall.call(
              pIdPropriedade: idPropriedade,
              pStatus: 'Na propriedade',
            )
          : null;

      final responses = await Future.wait<ApiCallResponse>([
        buscaFuture,
        countFuture,
        if (activeCountFuture != null) activeCountFuture,
      ]);
      if (!mounted || requestId != _model.rebanhosRequestId) {
        return;
      }

      final countTotal = valueOrDefault<int>(
        (responses[1].jsonBody ?? ''),
        0,
      );
      final totalPages = (countTotal / FFAppConstants.limit).ceil();
      if (countTotal > 0 && _model.pageNum > totalPages) {
        _model.pageNum = totalPages;
        await _loadRebanhos(refreshCounters: refreshCounters);
        return;
      }

      final activeTotal = responses.length > 2
          ? valueOrDefault<int>((responses[2].jsonBody ?? ''), 0)
          : FFAppState().qtdAnimaisNaPropriedade;

      safeSetState(() {
        _model.buscaRebanhos = responses[0];
        _model.countRebanhos = responses[1];
        _model.rebanhosPage = _parseRebanhos(responses[0]);
        _model.rebanhosTotal = countTotal;
        _model.pageTotal = totalPages < 1 ? 1 : totalPages;
        _model.isLoadingRebanhos = false;
        _model.hasLoadedRebanhos = true;
        if (refreshCounters) {
          FFAppState().qtdAnimaisRebanho = activeTotal;
          FFAppState().qtdAnimaisNaPropriedade = activeTotal;
        }
      });
    } finally {
      if (mounted && requestId == _model.rebanhosRequestId) {
        safeSetState(() {
          _model.isLoadingRebanhos = false;
        });
      }
    }
  }

  Future<void> _goToRebanhoPage(int page) async {
    final totalPages = _rebanhoTotalPages();
    final targetPage = page < 1
        ? 1
        : page > totalPages
            ? totalPages
            : page;
    if (targetPage == _model.pageNum) {
      return;
    }
    _model.pageNum = targetPage;
    await _loadRebanhos();
  }

  Widget _buildRebanhoPagination(BuildContext context) {
    if (!_model.hasLoadedRebanhos || _model.rebanhosTotal == 0) {
      return const SizedBox.shrink();
    }

    final totalPages = _rebanhoTotalPages();
    final canGoBack = _model.pageNum > 1 && !_model.isLoadingRebanhos;
    final canGoForward =
        _model.pageNum < totalPages && !_model.isLoadingRebanhos;

    Color iconColor(bool enabled) => enabled
        ? FlutterFlowTheme.of(context).primaryText
        : FlutterFlowTheme.of(context).accent3;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterFlowIconButton(
            borderColor: FlutterFlowTheme.of(context).customColor5,
            borderRadius: 6.0,
            borderWidth: 1.0,
            buttonSize: 44.0,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            icon: Icon(
              Icons.keyboard_double_arrow_left,
              color: iconColor(canGoBack),
              size: 22.0,
            ),
            onPressed: canGoBack ? () async => _goToRebanhoPage(1) : null,
          ),
          FlutterFlowIconButton(
            borderColor: FlutterFlowTheme.of(context).customColor5,
            borderRadius: 6.0,
            borderWidth: 1.0,
            buttonSize: 44.0,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            icon: Icon(
              Icons.keyboard_arrow_left_sharp,
              color: iconColor(canGoBack),
              size: 22.0,
            ),
            onPressed: canGoBack
                ? () async => _goToRebanhoPage(_model.pageNum - 1)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_model.pageNum} de $totalPages - ${_model.rebanhosTotal} animais',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
          FlutterFlowIconButton(
            borderColor: FlutterFlowTheme.of(context).customColor5,
            borderRadius: 6.0,
            borderWidth: 1.0,
            buttonSize: 44.0,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            icon: Icon(
              Icons.keyboard_arrow_right_sharp,
              color: iconColor(canGoForward),
              size: 22.0,
            ),
            onPressed: canGoForward
                ? () async => _goToRebanhoPage(_model.pageNum + 1)
                : null,
          ),
          FlutterFlowIconButton(
            borderColor: FlutterFlowTheme.of(context).customColor5,
            borderRadius: 6.0,
            borderWidth: 1.0,
            buttonSize: 44.0,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            icon: Icon(
              Icons.keyboard_double_arrow_right_outlined,
              color: iconColor(canGoForward),
              size: 22.0,
            ),
            onPressed:
                canGoForward ? () async => _goToRebanhoPage(totalPages) : null,
          ),
        ].divide(const SizedBox(width: 6.0)),
      ),
    );
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
                      if (FFAppState().pageRebanho == 'rebanho')
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
                                        'Rebanho',
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 40.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
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
                                                              -1.0, 1.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  followerAnchor:
                                                      const AlignmentDirectional(
                                                              -1.0, -1.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  builder: (dialogContext) {
                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(
                                                                  dialogContext)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child:
                                                            ModalAdicionarWidget(
                                                          action: (page) async {
                                                            _model.stap = page!;
                                                            safeSetState(() {});
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              text: 'Adicionar',
                                              icon: const Icon(
                                                Icons.add,
                                                size: 24.0,
                                              ),
                                              options: FFButtonOptions(
                                                height: 56.0,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        24.0, 0.0, 24.0, 0.0),
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
                                                    BorderRadius.circular(6.0),
                                                hoverColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 56.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .customColor2,
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
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
                                                  focusNode:
                                                      _model.textFieldFocusNode,
                                                  onChanged: (_) =>
                                                      EasyDebounce.debounce(
                                                    '_model.textController',
                                                    const Duration(
                                                        milliseconds: 250),
                                                    () async {
                                                      _model.pageNum = 1;
                                                      FFAppState()
                                                              .refreshRebanho =
                                                          true;
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                  autofocus: false,
                                                  obscureText: false,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent3,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    hintText: 'Pesquisar',
                                                    hintStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .labelMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent3,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                        color:
                                                            Color(0x00000000),
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                        width: 1.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    filled: true,
                                                    fillColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .customColor2,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    prefixIcon: Icon(
                                                      Icons.search_sharp,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .accent3,
                                                      size: 24.0,
                                                    ),
                                                    suffixIcon: _model
                                                            .textController!
                                                            .text
                                                            .isNotEmpty
                                                        ? InkWell(
                                                            onTap: () async {
                                                              _model
                                                                  .textController
                                                                  ?.clear();
                                                              _model.pageNum =
                                                                  1;
                                                              FFAppState()
                                                                      .refreshRebanho =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: const Icon(
                                                              Icons.clear,
                                                              size: 22,
                                                            ),
                                                          )
                                                        : null,
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
                                                          Colors.transparent,
                                                      alignment:
                                                          const AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(
                                                                  dialogContext)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child:
                                                            const PpFiltroRebanhoWidget(),
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
                                                        .fromSTEB(
                                                        16.0, 0.0, 16.0, 0.0),
                                                iconPadding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
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
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 24.0)),
                                      ),
                                    ].divide(const SizedBox(width: 24.0)),
                                  ),
                                  if (_hasRebanhoFilters())
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.filter_list,
                                            size: 16.0,
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                          ),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            'Filtros ativos',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          InkWell(
                                            onTap: () {
                                              final s = FFAppState();
                                              s.filtroSexo = '';
                                              s.filtroStatusRebanho = '';
                                              s.filtroCategoria = '';
                                              s.filtroDataNacimentoDe = null;
                                              s.filtroDataNacimentoAte = null;
                                              s.filtroLoteId = '';
                                              s.filtroRaca = '';
                                              s.filtroOrigem = '';
                                              s.filtroLoteNome = '';
                                              _model.pageNum = 1;
                                              s.refreshRebanho = true;
                                              safeSetState(() {});
                                            },
                                            child: Text(
                                              'Limpar',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    fontSize: 13.0,
                                                    letterSpacing: 0.0,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          width: 500.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
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
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Animais na propriedade',
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
                                                          BorderRadius.circular(
                                                              8.0),
                                                      child: Image.asset(
                                                        'assets/images/Icone_Animal_1-removebg-preview.png',
                                                        width: 48.0,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${valueOrDefault<String>(
                                                        FFAppState()
                                                            .qtdAnimaisNaPropriedade
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
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                            fontSize: 24.0,
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
                                                  ].divide(const SizedBox(
                                                      width: 12.0)),
                                                ),
                                              ].divide(
                                                  const SizedBox(height: 16.0)),
                                            ),
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
                                              padding:
                                                  const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Animais registrados',
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
                                                      if (FFAppState()
                                                              .navegacao !=
                                                          'rebanhos')
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          child: Image.asset(
                                                            'assets/images/Icone_Animal_1-removebg-preview.png',
                                                            width: 48.0,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      Text(
                                                        '${valueOrDefault<String>(
                                                          (_model.qtdAnimais
                                                                      ?.jsonBody ??
                                                                  '')
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
                                                              fontSize: 24.0,
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
                                                    ].divide(const SizedBox(
                                                        width: 12.0)),
                                                  ),
                                                ].divide(const SizedBox(
                                                    height: 16.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ].divide(const SizedBox(width: 24.0)),
                                  ),
                                  Divider(
                                    height: 24.0,
                                    thickness: 2.0,
                                    color: FlutterFlowTheme.of(context)
                                        .customColor5,
                                  ),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final rebanhos =
                                            _model.rebanhosPage.toList();
                                        if (_model.isLoadingRebanhos &&
                                            !_model.hasLoadedRebanhos) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        if (rebanhos.isEmpty) {
                                          final temPropriedade = FFAppState()
                                              .propriedadeSelecionada
                                              .idPropriedade
                                              .isNotEmpty;
                                          return Center(
                                            child: EmptyRebanhoWidget(
                                              message: temPropriedade
                                                  ? 'Nenhum animal encontrado'
                                                  : 'Nenhuma propriedade selecionada',
                                            ),
                                          );
                                        }

                                        return FlutterFlowDataTable<
                                            RebanhoDTStruct>(
                                          controller: _model
                                              .paginatedDataTableController,
                                          data: rebanhos,
                                          columnsBuilder: (onSortChanged) => [
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Número do animal',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
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
                                                  'Nome',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Sexo',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Nascimento',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
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
                                                  'Status',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Categoria',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  'Raça',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              label: DefaultTextStyle.merge(
                                                softWrap: true,
                                                child: Text(
                                                  ' ',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .labelLarge
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelLarge
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelLarge
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                              fixedWidth: 60.0,
                                            ),
                                          ],
                                          dataRowBuilder: (rebanhosItem,
                                                  rebanhosIndex,
                                                  selected,
                                                  onSelectChanged) =>
                                              DataRow(
                                            color: WidgetStateProperty.all(
                                              rebanhosIndex % 2 == 0
                                                  ? FlutterFlowTheme.of(context)
                                                      .secondaryBackground
                                                  : FlutterFlowTheme.of(context)
                                                      .customColor11,
                                            ),
                                            cells: [
                                              Text(
                                                valueOrDefault<String>(
                                                  rebanhosItem.numeroAnimal,
                                                  'N/A',
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.network(
                                                      rebanhosItem.sexo ==
                                                              'Macho'
                                                          ? 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/4cg1mjibvkyf/Sexomacho.png'
                                                          : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/25fnoszaf5de/Sexofemea.png',
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
                                                ].divide(
                                                    const SizedBox(width: 8.0)),
                                              ),
                                              Text(
                                                valueOrDefault<String>(
                                                  dateTimeFormat(
                                                    "d/M/y",
                                                    functions.converterParaData(
                                                        rebanhosItem
                                                            .dataNascimento),
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  ),
                                                  'N/A',
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                decoration: BoxDecoration(
                                                  color: valueOrDefault<Color>(
                                                    () {
                                                      if (rebanhosItem.status ==
                                                          'Vendido') {
                                                        return const Color(
                                                            0xFFF5D7D4);
                                                      } else if (rebanhosItem
                                                              .status ==
                                                          'Na propriedade') {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .customColor7;
                                                      } else {
                                                        return FlutterFlowTheme
                                                                .of(context)
                                                            .customColor2;
                                                      }
                                                    }(),
                                                    FlutterFlowTheme.of(context)
                                                        .customColor2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 2.0, 8.0, 2.0),
                                                  child: Text(
                                                    valueOrDefault<String>(
                                                      rebanhosItem.status,
                                                      'N/A',
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
                                                          color: valueOrDefault<
                                                              Color>(
                                                            () {
                                                              if (rebanhosItem
                                                                      .status ==
                                                                  'Vendido') {
                                                                return FlutterFlowTheme.of(
                                                                        context)
                                                                    .error;
                                                              } else if (rebanhosItem
                                                                      .status ==
                                                                  'Na propriedade') {
                                                                return FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary;
                                                              } else {
                                                                return FlutterFlowTheme.of(
                                                                        context)
                                                                    .icon;
                                                              }
                                                            }(),
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .icon,
                                                          ),
                                                          fontSize: 12.0,
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
                                                ),
                                              ),
                                              Text(
                                                valueOrDefault<String>(
                                                  rebanhosItem.categoria,
                                                  'N/A',
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                              Text(
                                                valueOrDefault<String>(
                                                  rebanhosItem.raca,
                                                  'N/A',
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Builder(
                                                    builder: (context) =>
                                                        FlutterFlowIconButton(
                                                      borderRadius: 8.0,
                                                      buttonSize: 40.0,
                                                      fillColor: const Color(
                                                          0x0028A365),
                                                      icon: Icon(
                                                        Icons.keyboard_control,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .accent3,
                                                        size: 24.0,
                                                      ),
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
                                                                    ModalMoreWidget(
                                                                  rebanhoId:
                                                                      rebanhosItem
                                                                          .id,
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
                                          emptyBuilder: () => Center(
                                            child: EmptyRebanhoWidget(
                                              message: _hasRebanhoFilters()
                                                  ? 'Nenhum animal encontrado para os filtros aplicados'
                                                  : null,
                                            ),
                                          ),
                                          onSortChanged:
                                              (columnIndex, ascending) async {
                                            _model.rebanhosPage = functions
                                                .rebanhoSortingFunction(
                                                    _model.rebanhosPage
                                                        .toList(),
                                                    columnIndex,
                                                    ascending)!
                                                .toList()
                                                .cast<RebanhoDTStruct>();
                                            safeSetState(() {});
                                          },
                                          paginated: true,
                                          selectable: false,
                                          hidePaginator: true,
                                          showFirstLastButtons: true,
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
                                          hideDefaultHorizontalDivider: true,
                                          horizontalDividerColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                          horizontalDividerThickness: 1.0,
                                          addVerticalDivider: false,
                                        );
                                      },
                                    ),
                                  ),
                                  _buildRebanhoPagination(context),
                                  Container(
                                    decoration: const BoxDecoration(),
                                    child: _model.rebanhosTotal < 0
                                        ? Visibility(
                                            visible: responsiveVisibility(
                                              context: context,
                                              phone: false,
                                              tablet: false,
                                              tabletLandscape: false,
                                              desktop: false,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FutureBuilder<ApiCallResponse>(
                                                  future:
                                                      FunctionsSupabaseRebanhoGroup
                                                          .countRebanhoFiltrosCall
                                                          .call(
                                                    pIdPropriedade: FFAppState()
                                                        .propriedadeSelecionada
                                                        .idPropriedade,
                                                    pCategoria: FFAppState()
                                                        .filtroCategoria,
                                                    pDataNascimentoDe:
                                                        dateTimeFormat(
                                                      "yyyy-MM-dd",
                                                      FFAppState()
                                                          .filtroDataNacimentoDe,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    ),
                                                    pDataNascimentoAte:
                                                        dateTimeFormat(
                                                      "yyyy-MM-dd",
                                                      FFAppState()
                                                          .filtroDataNacimentoAte,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    ),
                                                    pLoteID: FFAppState()
                                                        .filtroLoteId,
                                                    pOrigem: FFAppState()
                                                        .filtroOrigem,
                                                    pRaca:
                                                        FFAppState().filtroRaca,
                                                    pSexo:
                                                        FFAppState().filtroSexo,
                                                    pStatus: FFAppState()
                                                        .filtroStatusRebanho,
                                                    pPesquisa: _model
                                                        .textController.text,
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
                                                    if (snapshot.hasError) {
                                                      return Center(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .error_outline_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .error,
                                                              size: 36.0,
                                                            ),
                                                            const SizedBox(
                                                                height: 8.0),
                                                            Text(
                                                              'Erro ao carregar',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    final containerCountRebanhoFiltrosResponse =
                                                        snapshot.data!;

                                                    return Container(
                                                      height: 56.0,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                        border: Border.all(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .customColor5,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
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
                                                              _model.pageNum =
                                                                  1;
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .refreshRebanho =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: Container(
                                                              height: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          6.0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          0.0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          6.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          0.0),
                                                                ),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
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
                                                                    _model.pageNum >
                                                                            1
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
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
                                                              if (_model
                                                                      .pageNum >
                                                                  1) {
                                                                _model.pageNum =
                                                                    _model.pageNum +
                                                                        -1;
                                                                safeSetState(
                                                                    () {});
                                                                FFAppState()
                                                                        .refreshRebanho =
                                                                    true;
                                                                safeSetState(
                                                                    () {});
                                                              }
                                                            },
                                                            child: Container(
                                                              height: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
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
                                                                    _model.pageNum >
                                                                            1
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
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
                                                                    text: valueOrDefault<
                                                                        String>(
                                                                      _model
                                                                          .pageNum
                                                                          .toString(),
                                                                      '1',
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
                                                                  ),
                                                                  const TextSpan(
                                                                    text:
                                                                        ' de ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: valueOrDefault<
                                                                        String>(
                                                                      ((containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit)
                                                                              .ceil())
                                                                          .toString(),
                                                                      '1',
                                                                    ),
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
                                                                          color:
                                                                              FlutterFlowTheme.of(context).accent3,
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .poppins(
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
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
                                                              if (_model
                                                                      .pageNum <
                                                                  valueOrDefault<
                                                                      int>(
                                                                    (containerCountRebanhoFiltrosResponse.jsonBody /
                                                                            FFAppConstants.limit)
                                                                        .ceil(),
                                                                    1,
                                                                  )) {
                                                                _model.pageNum =
                                                                    _model.pageNum +
                                                                        1;
                                                                safeSetState(
                                                                    () {});
                                                                FFAppState()
                                                                        .refreshRebanho =
                                                                    true;
                                                                safeSetState(
                                                                    () {});
                                                              }
                                                            },
                                                            child: Container(
                                                              height: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
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
                                                                    _model
                                                                                .pageNum <
                                                                            valueOrDefault<
                                                                                int>(
                                                                              (containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                              1,
                                                                            )
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
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
                                                              _model.pageNum =
                                                                  valueOrDefault<
                                                                      int>(
                                                                (containerCountRebanhoFiltrosResponse
                                                                            .jsonBody /
                                                                        FFAppConstants
                                                                            .limit)
                                                                    .ceil(),
                                                                1,
                                                              );
                                                              safeSetState(
                                                                  () {});
                                                              FFAppState()
                                                                      .refreshRebanho =
                                                                  true;
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                            child: Container(
                                                              height: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0.0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          6.0),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          6.0),
                                                                ),
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
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
                                                                    _model
                                                                                .pageNum ==
                                                                            valueOrDefault<
                                                                                int>(
                                                                              (containerCountRebanhoFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                              1,
                                                                            )
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .accent3
                                                                        : FlutterFlowTheme.of(context)
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
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ].divide(const SizedBox(height: 24.0)),
                              ),
                            ),
                          ),
                        ),
                      if (FFAppState().pageRebanho == 'addAnimal')
                        Flexible(
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ccAddAnimalModel,
                              updateCallback: () => safeSetState(() {}),
                              child: CcAddAnimalWidget(
                                action: (page) async {
                                  _model.stap = page!;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      if (FFAppState().pageRebanho == 'editAnimal')
                        Flexible(
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ccEdtAnimalModel,
                              updateCallback: () => safeSetState(() {}),
                              child: CcEdtAnimalWidget(
                                action: (page) async {
                                  _model.stap = page!;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      if (FFAppState().pageRebanho == 'addNascimento')
                        Flexible(
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ccAddNascimentoModel,
                              updateCallback: () => safeSetState(() {}),
                              child: CcAddNascimentoWidget(
                                action: (page) async {
                                  _model.stap = page!;
                                  safeSetState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      if (FFAppState().pageRebanho == 'addSemen')
                        Flexible(
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: wrapWithModel(
                              model: _model.ccAddSemenModel,
                              updateCallback: () => safeSetState(() {}),
                              child: CcAddSemenWidget(
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
  }
}
