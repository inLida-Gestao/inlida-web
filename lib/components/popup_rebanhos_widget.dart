import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'popup_rebanhos_model.dart';
export 'popup_rebanhos_model.dart';

class PopupRebanhosWidget extends StatefulWidget {
  const PopupRebanhosWidget({
    super.key,
    required this.sexo,
    bool? reproducao,
    this.tipoReproducao,
    bool? sanidade,
  }) : reproducao = reproducao ?? false,
       sanidade = sanidade ?? false;

  final String? sexo;
  final bool reproducao;
  final String? tipoReproducao;
  final bool sanidade;

  @override
  State<PopupRebanhosWidget> createState() => _PopupRebanhosWidgetState();
}

class _PopupRebanhosWidgetState extends State<PopupRebanhosWidget> {
  late PopupRebanhosModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupRebanhosModel());

    _model.pesquisarTextController ??= TextEditingController();
    _model.pesquisarFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: FutureBuilder<ApiCallResponse>(
        future: FunctionsSupabaseRebanhoGroup.buscarRebanhoFiltrosCall.call(
          pCategoria: FFAppState().filtroCategoria,
          pDataNascimento: dateTimeFormat(
            "yyyy-MM-dd",
            FFAppState().filtroDataNacimento,
            locale: FFLocalizations.of(context).languageCode,
          ),
          pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
          pLoteNome: FFAppState().filtroLoteId,
          pOrigem: FFAppState().filtroOrigem,
          pRaca: FFAppState().filtroRaca,
          pSexo: widget.sanidade == true ? '' : widget.sexo,
          pLimite: FFAppConstants.limit,
          pOffset: 0,
          pPesquisa: _model.pesquisarTextController.text,
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
          final containerBuscarRebanhoFiltrosResponse = snapshot.data!;

          return Container(
            height: 450.0,
            constraints: const BoxConstraints(
              maxWidth: 920.0,
            ),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
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
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        hoverColor: FlutterFlowTheme.of(context).customColor2,
                        hoverIconColor:
                            FlutterFlowTheme.of(context).primaryText,
                        icon: Icon(
                          Icons.close_sharp,
                          color: FlutterFlowTheme.of(context).tertiary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _model.pesquisarTextController,
                        focusNode: _model.pesquisarFocusNode,
                        onChanged: (_) => EasyDebounce.debounce(
                          '_model.pesquisarTextController',
                          const Duration(milliseconds: 250),
                          () => safeSetState(() {}),
                        ),
                        autofocus: false,
                        obscureText: false,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                          hintText: 'Pesquisar',
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).tertiary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).tertiary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).error,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          prefixIcon: Icon(
                            Icons.search_sharp,
                            color: FlutterFlowTheme.of(context).accent3,
                            size: 24.0,
                          ),
                          suffixIcon: _model
                                  .pesquisarTextController!.text.isNotEmpty
                              ? InkWell(
                                  onTap: () async {
                                    _model.pesquisarTextController?.clear();
                                    safeSetState(() {});
                                  },
                                  child: Icon(
                                    Icons.clear,
                                    color: FlutterFlowTheme.of(context).accent3,
                                    size: 22,
                                  ),
                                )
                              : null,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                              lineHeight: 1.0,
                            ),
                        cursorColor: FlutterFlowTheme.of(context).primaryText,
                        validator: _model.pesquisarTextControllerValidator
                            .asValidator(context),
                      ),
                    ),
                  ),
                  if (!((containerBuscarRebanhoFiltrosResponse.jsonBody
                          .toList()
                          .map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap)
                          .toList() as Iterable<RebanhoDTStruct?>)
                      .withoutNulls
                      .isNotEmpty))
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x41000040),
                              offset: Offset(
                                2.0,
                                2.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              32.0, 32.0, 32.0, 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/Mask_group.png',
                                  height: 74.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Nenhum animal foi cadastrado nesta propriedade.',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ].divide(const SizedBox(height: 24.0)),
                          ),
                        ),
                      ),
                    ),
                  if (((containerBuscarRebanhoFiltrosResponse.jsonBody
                              .toList()
                              .map<RebanhoDTStruct?>(
                                  RebanhoDTStruct.maybeFromMap)
                              .toList() as Iterable<RebanhoDTStruct?>)
                          .withoutNulls
                          .isNotEmpty) &&
                      (widget.sanidade == true))
                    Flexible(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 8.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 500.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final animais =
                                    ((containerBuscarRebanhoFiltrosResponse
                                                        .jsonBody
                                                        .toList()
                                                        .map<RebanhoDTStruct?>(
                                                            RebanhoDTStruct
                                                                .maybeFromMap)
                                                        .toList()
                                                    as Iterable<
                                                        RebanhoDTStruct?>)
                                                .withoutNulls
                                                .where((e) =>
                                                    e.status ==
                                                    'Na propriedade')
                                                .toList()
                                                .toList() ??
                                            [])
                                        .take(20)
                                        .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: animais.length,
                                  itemBuilder: (context, animaisIndex) {
                                    final animaisItem = animais[animaisIndex];
                                    return Container(
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
                                                    24.0, 12.0, 24.0, 12.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (animaisItem.sexo ==
                                                    'Fêmea') {
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                }

                                                FFAppState()
                                                        .refreshAnimalSelecionado =
                                                    true;
                                                safeSetState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            animaisItem.numeroAnimal,
                                                            'S/N',
                                                          )} • ${animaisItem.nome == 'null' ? 'S/N' : valueOrDefault<String>(
                                                              animaisItem.nome,
                                                              'S/N',
                                                            )} • ${valueOrDefault<String>(
                                                            () {
                                                              if (valueOrDefault<String>(
                                                                    animaisItem.dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  ) == 'null') {
                                                                return 'N/A';
                                                              } else if (valueOrDefault<String>(
                                                                        animaisItem.dataNascimento,
                                                                        'xx/xx/xxxx',
                                                                      ) == '') {
                                                                return 'N/A';
                                                              } else {
                                                                return dateTimeFormat(
                                                                  "d/M/y",
                                                                  functions.converterParaData(
                                                                      valueOrDefault<String>(
                                                                    animaisItem.dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  )),
                                                                  locale: FFLocalizations.of(context).languageCode,
                                                                );
                                                              }
                                                            }(),
                                                            'N/A',
                                                          )}',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                                color: const Color(
                                                                    0xFF474747),
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ].divide(const SizedBox(
                                                          height: 2.0)),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 0.0,
                                            thickness: 1.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (((containerBuscarRebanhoFiltrosResponse.jsonBody
                              .toList()
                              .map<RebanhoDTStruct?>(
                                  RebanhoDTStruct.maybeFromMap)
                              .toList() as Iterable<RebanhoDTStruct?>)
                          .withoutNulls
                          .isNotEmpty) &&
                      (widget.sexo == 'Fêmea') &&
                      (widget.sanidade == false))
                    Flexible(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 8.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 500.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final animais =
                                    ((containerBuscarRebanhoFiltrosResponse
                                                        .jsonBody
                                                        .toList()
                                                        .map<RebanhoDTStruct?>(
                                                            RebanhoDTStruct
                                                                .maybeFromMap)
                                                        .toList()
                                                    as Iterable<
                                                        RebanhoDTStruct?>)
                                                .withoutNulls
                                                .where((e) =>
                                                    (e.status ==
                                                        'Na propriedade') &&
                                                    (e.categoria != 'Bezerra'))
                                                .toList()
                                                .toList() ??
                                            [])
                                        .take(20)
                                        .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: animais.length,
                                  itemBuilder: (context, animaisIndex) {
                                    final animaisItem = animais[animaisIndex];
                                    return Container(
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
                                                    24.0, 12.0, 24.0, 12.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (animaisItem.sexo ==
                                                    'Fêmea') {
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                }

                                                FFAppState()
                                                        .refreshAnimalSelecionado =
                                                    true;
                                                safeSetState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            valueOrDefault<
                                                                        String>(
                                                                      animaisItem
                                                                          .numeroAnimal,
                                                                      '0000',
                                                                    ) ==
                                                                    'null'
                                                                ? 'S/N'
                                                                : valueOrDefault<
                                                                    String>(
                                                                    animaisItem
                                                                        .numeroAnimal,
                                                                    'S/N',
                                                                  ),
                                                            'S/N',
                                                          )} • ${animaisItem.nome == 'null' ? 'S/N' : valueOrDefault<String>(
                                                              animaisItem.nome,
                                                              'S/N',
                                                            )} • ${valueOrDefault<String>(
                                                            () {
                                                              if (valueOrDefault<
                                                                      String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  ) ==
                                                                  'null') {
                                                                return 'N/A';
                                                              } else if (valueOrDefault<
                                                                          String>(
                                                                        animaisItem
                                                                            .dataNascimento,
                                                                        'xx/xx/xxxx',
                                                                      ) ==
                                                                      '') {
                                                                return 'N/A';
                                                              } else {
                                                                return dateTimeFormat(
                                                                  "d/M/y",
                                                                  functions.converterParaData(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  )),
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                );
                                                              }
                                                            }(),
                                                            'N/A',
                                                          )}',
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
                                                                color: const Color(
                                                                    0xFF474747),
                                                                fontSize: 16.0,
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
                                                      ].divide(const SizedBox(
                                                          height: 2.0)),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 0.0,
                                            thickness: 1.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (((containerBuscarRebanhoFiltrosResponse.jsonBody
                              .toList()
                              .map<RebanhoDTStruct?>(
                                  RebanhoDTStruct.maybeFromMap)
                              .toList() as Iterable<RebanhoDTStruct?>)
                          .withoutNulls
                          .isNotEmpty) &&
                      (widget.sexo == 'Macho') &&
                      (widget.reproducao == false) &&
                      (widget.sanidade == false))
                    Flexible(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 8.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 500.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final animais =
                                    ((containerBuscarRebanhoFiltrosResponse
                                                        .jsonBody
                                                        .toList()
                                                        .map<RebanhoDTStruct?>(
                                                            RebanhoDTStruct
                                                                .maybeFromMap)
                                                        .toList()
                                                    as Iterable<
                                                        RebanhoDTStruct?>)
                                                .withoutNulls
                                                .where((e) =>
                                                    e.status ==
                                                    'Na propriedade')
                                                .toList()
                                                .toList() ??
                                            [])
                                        .take(20)
                                        .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: animais.length,
                                  itemBuilder: (context, animaisIndex) {
                                    final animaisItem = animais[animaisIndex];
                                    return Container(
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
                                                    24.0, 12.0, 24.0, 12.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (animaisItem.sexo ==
                                                    'Fêmea') {
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                }

                                                FFAppState()
                                                        .refreshAnimalSelecionado =
                                                    true;
                                                safeSetState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            valueOrDefault<
                                                                        String>(
                                                                      animaisItem
                                                                          .numeroAnimal,
                                                                      '0000',
                                                                    ) ==
                                                                    'null'
                                                                ? 'S/N'
                                                                : valueOrDefault<
                                                                    String>(
                                                                    animaisItem
                                                                        .numeroAnimal,
                                                                    'S/N',
                                                                  ),
                                                            'S/N',
                                                          )} • ${animaisItem.nome == 'null' ? 'S/N' : valueOrDefault<String>(
                                                              animaisItem.nome,
                                                              'S/N',
                                                            )} • ${valueOrDefault<String>(
                                                            () {
                                                              if (valueOrDefault<
                                                                      String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  ) ==
                                                                  'null') {
                                                                return 'N/A';
                                                              } else if (valueOrDefault<
                                                                          String>(
                                                                        animaisItem
                                                                            .dataNascimento,
                                                                        'xx/xx/xxxx',
                                                                      ) ==
                                                                      '') {
                                                                return 'N/A';
                                                              } else {
                                                                return dateTimeFormat(
                                                                  "d/M/y",
                                                                  functions.converterParaData(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  )),
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                );
                                                              }
                                                            }(),
                                                            'N/A',
                                                          )}',
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
                                                                color: const Color(
                                                                    0xFF474747),
                                                                fontSize: 16.0,
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
                                                      ].divide(const SizedBox(
                                                          height: 2.0)),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 0.0,
                                            thickness: 1.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (((containerBuscarRebanhoFiltrosResponse.jsonBody
                              .toList()
                              .map<RebanhoDTStruct?>(
                                  RebanhoDTStruct.maybeFromMap)
                              .toList() as Iterable<RebanhoDTStruct?>)
                          .withoutNulls
                          .isNotEmpty) &&
                      (widget.sexo == 'Macho') &&
                      (widget.reproducao == true) &&
                      (widget.tipoReproducao == 'Monta Natural') &&
                      (widget.sanidade == false))
                    Flexible(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 8.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 500.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final animais =
                                    ((containerBuscarRebanhoFiltrosResponse
                                                        .jsonBody
                                                        .toList()
                                                        .map<RebanhoDTStruct?>(
                                                            RebanhoDTStruct
                                                                .maybeFromMap)
                                                        .toList()
                                                    as Iterable<
                                                        RebanhoDTStruct?>)
                                                .withoutNulls
                                                .where((e) =>
                                                    (e.status ==
                                                        'Na propriedade') &&
                                                    (e.categoria == 'Touro'))
                                                .toList()
                                                .toList() ??
                                            [])
                                        .take(20)
                                        .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: animais.length,
                                  itemBuilder: (context, animaisIndex) {
                                    final animaisItem = animais[animaisIndex];
                                    return Container(
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
                                                    24.0, 12.0, 24.0, 12.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (animaisItem.sexo ==
                                                    'Fêmea') {
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                }

                                                FFAppState()
                                                        .refreshAnimalSelecionado =
                                                    true;
                                                safeSetState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            valueOrDefault<
                                                                        String>(
                                                                      animaisItem
                                                                          .numeroAnimal,
                                                                      '0000',
                                                                    ) ==
                                                                    'null'
                                                                ? 'S/N'
                                                                : valueOrDefault<
                                                                    String>(
                                                                    animaisItem
                                                                        .numeroAnimal,
                                                                    'S/N',
                                                                  ),
                                                            'S/N',
                                                          )} • ${animaisItem.nome == 'null' ? 'S/N' : valueOrDefault<String>(
                                                              animaisItem.nome,
                                                              'S/N',
                                                            )} • ${valueOrDefault<String>(
                                                            () {
                                                              if (valueOrDefault<
                                                                      String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  ) ==
                                                                  'null') {
                                                                return 'N/A';
                                                              } else if (valueOrDefault<
                                                                          String>(
                                                                        animaisItem
                                                                            .dataNascimento,
                                                                        'xx/xx/xxxx',
                                                                      ) ==
                                                                      '') {
                                                                return 'N/A';
                                                              } else {
                                                                return dateTimeFormat(
                                                                  "d/M/y",
                                                                  functions.converterParaData(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  )),
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                );
                                                              }
                                                            }(),
                                                            'N/A',
                                                          )}',
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
                                                                color: const Color(
                                                                    0xFF474747),
                                                                fontSize: 16.0,
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
                                                      ].divide(const SizedBox(
                                                          height: 2.0)),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 0.0,
                                            thickness: 1.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (((containerBuscarRebanhoFiltrosResponse.jsonBody
                              .toList()
                              .map<RebanhoDTStruct?>(
                                  RebanhoDTStruct.maybeFromMap)
                              .toList() as Iterable<RebanhoDTStruct?>)
                          .withoutNulls
                          .isNotEmpty) &&
                      (widget.sexo == 'Macho') &&
                      (widget.reproducao == true) &&
                      (widget.tipoReproducao == 'Inseminação') &&
                      (widget.sanidade == false))
                    Flexible(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 8.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxHeight: 500.0,
                          ),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final animais =
                                    ((containerBuscarRebanhoFiltrosResponse
                                                        .jsonBody
                                                        .toList()
                                                        .map<RebanhoDTStruct?>(
                                                            RebanhoDTStruct
                                                                .maybeFromMap)
                                                        .toList()
                                                    as Iterable<
                                                        RebanhoDTStruct?>)
                                                .withoutNulls
                                                .where(
                                                    (e) => e.status == 'Sêmen')
                                                .toList()
                                                .toList() ??
                                            [])
                                        .take(20)
                                        .toList();

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  itemCount: animais.length,
                                  itemBuilder: (context, animaisIndex) {
                                    final animaisItem = animais[animaisIndex];
                                    return Container(
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
                                                    24.0, 12.0, 24.0, 12.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (animaisItem.sexo ==
                                                    'Fêmea') {
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      AnimalSelecionadoStruct(
                                                    numAnimal: animaisItem
                                                        .numeroAnimal,
                                                    nomeAnimal:
                                                        animaisItem.nome,
                                                    dataNascAnimal: animaisItem
                                                        .dataNascimento,
                                                    racaAnimal:
                                                        animaisItem.raca,
                                                    categoria:
                                                        animaisItem.categoria,
                                                    idAnimal:
                                                        animaisItem.idRebanho,
                                                  );
                                                  safeSetState(() {});
                                                }

                                                FFAppState()
                                                        .refreshAnimalSelecionado =
                                                    true;
                                                safeSetState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${valueOrDefault<String>(
                                                            valueOrDefault<
                                                                        String>(
                                                                      animaisItem
                                                                          .numeroAnimal,
                                                                      '0000',
                                                                    ) ==
                                                                    'null'
                                                                ? 'S/N'
                                                                : valueOrDefault<
                                                                    String>(
                                                                    animaisItem
                                                                        .numeroAnimal,
                                                                    'S/N',
                                                                  ),
                                                            'S/N',
                                                          )} • ${animaisItem.nome == 'null' ? 'S/N' : valueOrDefault<String>(
                                                              animaisItem.nome,
                                                              'S/N',
                                                            )} • ${valueOrDefault<String>(
                                                            () {
                                                              if (valueOrDefault<
                                                                      String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  ) ==
                                                                  'null') {
                                                                return 'N/A';
                                                              } else if (valueOrDefault<
                                                                          String>(
                                                                        animaisItem
                                                                            .dataNascimento,
                                                                        'xx/xx/xxxx',
                                                                      ) ==
                                                                      '') {
                                                                return 'N/A';
                                                              } else {
                                                                return dateTimeFormat(
                                                                  "d/M/y",
                                                                  functions.converterParaData(
                                                                      valueOrDefault<
                                                                          String>(
                                                                    animaisItem
                                                                        .dataNascimento,
                                                                    'xx/xx/xxxx',
                                                                  )),
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                );
                                                              }
                                                            }(),
                                                            'N/A',
                                                          )}',
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
                                                                color: const Color(
                                                                    0xFF474747),
                                                                fontSize: 16.0,
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
                                                      ].divide(const SizedBox(
                                                          height: 2.0)),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.keyboard_arrow_right,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 24.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            height: 0.0,
                                            thickness: 1.0,
                                            color: FlutterFlowTheme.of(context)
                                                .alternate,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
