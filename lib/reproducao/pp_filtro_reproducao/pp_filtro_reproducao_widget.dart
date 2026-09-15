import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/popup_rebanhos_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pp_filtro_reproducao_model.dart';
export 'pp_filtro_reproducao_model.dart';

class PpFiltroReproducaoWidget extends StatefulWidget {
  const PpFiltroReproducaoWidget({super.key});

  @override
  State<PpFiltroReproducaoWidget> createState() =>
      _PpFiltroReproducaoWidgetState();
}

class _PpFiltroReproducaoWidgetState extends State<PpFiltroReproducaoWidget> {
  late PpFiltroReproducaoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PpFiltroReproducaoModel());

    _model.dataReproducaoDeTextController ??= TextEditingController();
    _model.dataReproducaoDeFocusNode ??= FocusNode();
    _model.dataReproducaoAteTextController ??= TextEditingController();
    _model.dataReproducaoAteFocusNode ??= FocusNode();

    _model.dataPartoDeTextController ??= TextEditingController();
    _model.dataPartoDeFocusNode ??= FocusNode();
    _model.dataPartoAteTextController ??= TextEditingController();
    _model.dataPartoAteFocusNode ??= FocusNode();

    _model.dataDiagnosticoDeTextController ??= TextEditingController();
    _model.dataDiagnosticoDeFocusNode ??= FocusNode();
    _model.dataDiagnosticoAteTextController ??= TextEditingController();
    _model.dataDiagnosticoAteFocusNode ??= FocusNode();

    final appState = FFAppState();
    _model.datePickedReproDe = appState.filtroDataReproducaoDe;
    _model.datePickedReproAte = appState.filtroDataReproducaoAte;
    _model.datePickedPartoDe = appState.filtroDataPartoDe;
    _model.datePickedPartoAte = appState.filtroDataPartoAte;
    _model.datePickedDiagDe = appState.filtroDataDiagnosticoDe;
    _model.datePickedDiagAte = appState.filtroDataDiagnosticoAte;
    _model.matrizFiltroSelecionada = appState.filtroMatrizSelecionada;
    _model.reprodutorFiltroSelecionado = appState.filtroReprodutorSelecionado;

    _model.lotesFuture ??= LotesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
            'id_propriedade',
            FFAppState().propriedadeSelecionada.idPropriedade,
          )
          .eqOrNull(
            'deletado',
            'NAO',
          ),
    );

    _model.reproducaoFuture ??= ReproducaoTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
            'id_propriedade',
            FFAppState().propriedadeSelecionada.idPropriedade,
          )
          .eqOrNull(
            'deletado',
            'NAO',
          ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.dataReproducaoDeTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataReproducaoDe,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
          _model.dataReproducaoAteTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataReproducaoAte,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
          _model.dataPartoDeTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataPartoDe,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
          _model.dataPartoAteTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataPartoAte,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
          _model.dataDiagnosticoDeTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataDiagnosticoDe,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
          _model.dataDiagnosticoAteTextController?.text =
              valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataDiagnosticoAte,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
        }));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  String _animalFilterLabel(AnimalSelecionadoStruct animal) {
    final numero = animal.numAnimal.trim();
    final nome = animal.nomeAnimal.trim();
    final nascimento = animal.dataNascAnimal.trim();
    final nascimentoLabel = nascimento.isEmpty || nascimento == 'null'
        ? 'N/A'
        : dateTimeFormat(
            'd/M/y',
            functions.converterParaData(nascimento),
            locale: FFLocalizations.of(context).languageCode,
          );

    return '${numero.isEmpty || numero == 'null' ? 'S/N' : numero} • '
        '${nome.isEmpty || nome == 'null' ? 'S/N' : nome} • '
        '${nascimentoLabel.isEmpty ? 'N/A' : nascimentoLabel}';
  }

  Widget _buildDiagnosticoFilter() {
    const diagnosticoOptions = [
      'Não diagnosticado',
      'Absorção',
      'Aborto',
      'Natimorto',
      'Prenhez',
      'Vazio',
    ];
    final savedDiagnosticos = FFAppState()
        .filtroStatusReproducao
        .where((diagnostico) => diagnosticoOptions.contains(diagnostico))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diagnóstico',
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
        FlutterFlowDropDown<String>(
          multiSelectController: _model.dDDiagnosticoValueController ??=
              FormListFieldController<String>(
            _model.dDDiagnosticoValue ??= savedDiagnosticos,
          ),
          options: diagnosticoOptions,
          onMultiSelectChanged: (val) async {
            safeSetState(() => _model.dDDiagnosticoValue = val ?? []);
          },
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
          isMultiSelect: true,
        ),
      ].divide(const SizedBox(height: 8.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: FutureBuilder<List<LotesRow>>(
        future: _model.lotesFuture,
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

          return Container(
            width: MediaQuery.sizeOf(context).width >= 920.0
                ? 880.0
                : MediaQuery.sizeOf(context).width * 0.92,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtrar',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 24.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 8.0,
                        buttonSize: 40.0,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF8EA321),
                          size: 24.0,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Data de reprodução',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: _model
                                                    .dataReproducaoDeTextController,
                                                focusNode: _model
                                                    .dataReproducaoDeFocusNode,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  labelText: 'De',
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'dd/mm/aaaa',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: const Color(
                                                            0xFFBEBEBE),
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .customColor2,
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .dataReproducaoDeTextControllerValidator
                                                    ?.asValidator(context),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final datePickedReproDeDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        getCurrentTimestamp,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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

                                                  if (datePickedReproDeDate !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePickedReproDe =
                                                          DateTime(
                                                        datePickedReproDeDate
                                                            .year,
                                                        datePickedReproDeDate
                                                            .month,
                                                        datePickedReproDeDate
                                                            .day,
                                                      );
                                                    });
                                                  }
                                                  safeSetState(() {
                                                    _model
                                                        .dataReproducaoDeTextController
                                                        ?.text = dateTimeFormat(
                                                      "d/M/y",
                                                      _model.datePickedReproDe,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: _model
                                                    .dataReproducaoAteTextController,
                                                focusNode: _model
                                                    .dataReproducaoAteFocusNode,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  labelText: 'Até',
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'dd/mm/aaaa',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: const Color(
                                                            0xFFBEBEBE),
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .customColor2,
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .dataReproducaoAteTextControllerValidator
                                                    ?.asValidator(context),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final datePickedReproAteDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        getCurrentTimestamp,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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

                                                  if (datePickedReproAteDate !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePickedReproAte =
                                                          DateTime(
                                                        datePickedReproAteDate
                                                            .year,
                                                        datePickedReproAteDate
                                                            .month,
                                                        datePickedReproAteDate
                                                            .day,
                                                      );
                                                    });
                                                  }
                                                  safeSetState(() {
                                                    _model
                                                        .dataReproducaoAteTextController
                                                        ?.text = dateTimeFormat(
                                                      "d/M/y",
                                                      _model.datePickedReproAte,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Previsão de parto',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: _model
                                                    .dataPartoDeTextController,
                                                focusNode:
                                                    _model.dataPartoDeFocusNode,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  labelText: 'De',
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'dd/mm/aaaa',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: const Color(
                                                            0xFFBEBEBE),
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .customColor2,
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .dataPartoDeTextControllerValidator
                                                    ?.asValidator(context),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final datePickedPartoDeDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        getCurrentTimestamp,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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

                                                  if (datePickedPartoDeDate !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePickedPartoDe =
                                                          DateTime(
                                                        datePickedPartoDeDate
                                                            .year,
                                                        datePickedPartoDeDate
                                                            .month,
                                                        datePickedPartoDeDate
                                                            .day,
                                                      );
                                                    });
                                                  }
                                                  safeSetState(() {
                                                    _model
                                                        .dataPartoDeTextController
                                                        ?.text = dateTimeFormat(
                                                      "d/M/y",
                                                      _model.datePickedPartoDe,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: _model
                                                    .dataPartoAteTextController,
                                                focusNode: _model
                                                    .dataPartoAteFocusNode,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  labelText: 'Até',
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'dd/mm/aaaa',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: const Color(
                                                            0xFFBEBEBE),
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .customColor2,
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .dataPartoAteTextControllerValidator
                                                    ?.asValidator(context),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final datePickedPartoAteDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        getCurrentTimestamp,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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

                                                  if (datePickedPartoAteDate !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePickedPartoAte =
                                                          DateTime(
                                                        datePickedPartoAteDate
                                                            .year,
                                                        datePickedPartoAteDate
                                                            .month,
                                                        datePickedPartoAteDate
                                                            .day,
                                                      );
                                                    });
                                                  }
                                                  safeSetState(() {
                                                    _model
                                                        .dataPartoAteTextController
                                                        ?.text = dateTimeFormat(
                                                      "d/M/y",
                                                      _model.datePickedPartoAte,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                            ].divide(const SizedBox(width: 24.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Data do diagnóstico',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: _model
                                                    .dataDiagnosticoDeTextController,
                                                focusNode: _model
                                                    .dataDiagnosticoDeFocusNode,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  labelText: 'De',
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'dd/mm/aaaa',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: const Color(
                                                            0xFFBEBEBE),
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .customColor2,
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .dataDiagnosticoDeTextControllerValidator
                                                    ?.asValidator(context),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final datePickedDiagDeDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        getCurrentTimestamp,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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

                                                  if (datePickedDiagDeDate !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePickedDiagDe =
                                                          DateTime(
                                                        datePickedDiagDeDate
                                                            .year,
                                                        datePickedDiagDeDate
                                                            .month,
                                                        datePickedDiagDeDate
                                                            .day,
                                                      );
                                                    });
                                                  }
                                                  safeSetState(() {
                                                    _model
                                                        .dataDiagnosticoDeTextController
                                                        ?.text = dateTimeFormat(
                                                      "d/M/y",
                                                      _model.datePickedDiagDe,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              TextFormField(
                                                controller: _model
                                                    .dataDiagnosticoAteTextController,
                                                focusNode: _model
                                                    .dataDiagnosticoAteFocusNode,
                                                autofocus: false,
                                                readOnly: true,
                                                obscureText: false,
                                                decoration: InputDecoration(
                                                  isDense: false,
                                                  labelText: 'Até',
                                                  labelStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelMedium
                                                                .fontStyle,
                                                      ),
                                                  hintText: 'dd/mm/aaaa',
                                                  hintStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .labelMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .fontStyle,
                                                        ),
                                                        color: const Color(
                                                            0xFFBEBEBE),
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
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Color(0x00000000),
                                                      width: 1.0,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
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
                                                            8.0),
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
                                                            8.0),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .customColor2,
                                                  suffixIcon: Icon(
                                                    Icons.calendar_today,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                  ),
                                                ),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
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
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                validator: _model
                                                    .dataDiagnosticoAteTextControllerValidator
                                                    ?.asValidator(context),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final datePickedDiagAteDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        getCurrentTimestamp,
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2050),
                                                    builder: (context, child) {
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
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .headlineLarge
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      32.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
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

                                                  if (datePickedDiagAteDate !=
                                                      null) {
                                                    safeSetState(() {
                                                      _model.datePickedDiagAte =
                                                          DateTime(
                                                        datePickedDiagAteDate
                                                            .year,
                                                        datePickedDiagAteDate
                                                            .month,
                                                        datePickedDiagAteDate
                                                            .day,
                                                      );
                                                    });
                                                  }
                                                  safeSetState(() {
                                                    _model
                                                        .dataDiagnosticoAteTextController
                                                        ?.text = dateTimeFormat(
                                                      "d/M/y",
                                                      _model.datePickedDiagAte,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration:
                                                      const BoxDecoration(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                              Expanded(
                                child: _buildDiagnosticoFilter(),
                              ),
                            ].divide(const SizedBox(width: 24.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Categorias',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    FlutterFlowDropDown<String>(
                                      controller:
                                          _model.dDCatRebanhoValueController ??=
                                              FormFieldController<String>(
                                        _model.dDCatRebanhoValue ??=
                                            FFAppState().filtroCategoriaRepro,
                                      ),
                                      options: const [
                                        'Bezerra',
                                        'Bezerro',
                                        'Boi Gordo',
                                        'Boi Magro',
                                        'Garrote',
                                        'Novilha',
                                        'Rufião',
                                        'Touro',
                                        'Vaca Multipara',
                                        'Vaca Primipara'
                                      ],
                                      onChanged: (val) async {
                                        safeSetState(() =>
                                            _model.dDCatRebanhoValue = val);
                                      },
                                      height: 56.0,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      hintText: 'Selecionar',
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 24.0,
                                      ),
                                      fillColor: const Color(0xFFF1F1F1),
                                      elevation: 2.0,
                                      borderColor: Colors.transparent,
                                      borderWidth: 0.0,
                                      borderRadius: 8.0,
                                      margin:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      hidesUnderline: true,
                                      isOverButton: false,
                                      isSearchable: false,
                                      isMultiSelect: false,
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                            ].divide(const SizedBox(width: 24.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tipo de reprodução',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    FlutterFlowDropDown<String>(
                                      controller: _model
                                              .dDTipoReproducaoValueController ??=
                                          FormFieldController<String>(
                                        _model.dDTipoReproducaoValue ??=
                                            FFAppState().filtroTipoReproducao,
                                      ),
                                      options: const [
                                        'Inseminação',
                                        'Monta Natural',
                                      ],
                                      onChanged: (val) async {
                                        safeSetState(() =>
                                            _model.dDTipoReproducaoValue = val);
                                      },
                                      height: 56.0,
                                      textStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      hintText: 'Selecionar',
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 24.0,
                                      ),
                                      fillColor: const Color(0xFFF1F1F1),
                                      elevation: 2.0,
                                      borderColor: Colors.transparent,
                                      borderWidth: 0.0,
                                      borderRadius: 8.0,
                                      margin:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      hidesUnderline: true,
                                      isOverButton: false,
                                      isSearchable: false,
                                      isMultiSelect: false,
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                            ].divide(const SizedBox(width: 24.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lote',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    Builder(builder: (context) {
                                      final loteIds = List<String>.from(
                                          containerLotesRowList
                                              .map((e) => e.idLote)
                                              .withoutNulls
                                              .toList());
                                      final savedLote =
                                          FFAppState().filtroLoteNome;
                                      final savedLoteId = loteIds.isNotEmpty
                                          ? containerLotesRowList
                                              .where((e) => e.nome == savedLote)
                                              .map((e) => e.idLote)
                                              .firstOrNull
                                          : null;
                                      final initialValue =
                                          (savedLoteId != null &&
                                                  loteIds.contains(savedLoteId))
                                              ? savedLoteId
                                              : null;
                                      return FlutterFlowDropDown<String>(
                                        controller: _model
                                                .dropDownLoteValueController ??=
                                            FormFieldController<String>(
                                          _model.dropDownLoteValue ??=
                                              initialValue,
                                        ),
                                        options: loteIds,
                                        optionLabels: containerLotesRowList
                                            .map((e) => e.nome)
                                            .withoutNulls
                                            .toList(),
                                        onChanged: (val) async {
                                          safeSetState(() =>
                                              _model.dropDownLoteValue = val);
                                        },
                                        height: 56.0,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        hintText: 'Selecionar',
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24.0,
                                        ),
                                        fillColor: const Color(0xFFF1F1F1),
                                        elevation: 2.0,
                                        borderColor: Colors.transparent,
                                        borderWidth: 0.0,
                                        borderRadius: 8.0,
                                        margin: const EdgeInsetsDirectional
                                            .fromSTEB(12.0, 0.0, 12.0, 0.0),
                                        hidesUnderline: true,
                                        isOverButton: false,
                                        isSearchable: false,
                                        isMultiSelect: false,
                                      );
                                    }),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Inseminador',
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
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    FutureBuilder<List<ReproducaoRow>>(
                                      future: _model.reproducaoFuture,
                                      builder: (context, reproSnapshot) {
                                        final inseminadorOptions =
                                            reproSnapshot.hasData
                                                ? reproSnapshot.data!
                                                    .map((e) => e.inseminador)
                                                    .withoutNulls
                                                    .toList()
                                                    .unique((e) => e)
                                                : <String>[];
                                        return FlutterFlowDropDown<String>(
                                          controller: _model
                                                  .dropDownInseminadorValueController ??=
                                              FormFieldController<String>(
                                            _model.dropDownInseminadorValue ??=
                                                FFAppState().filtroInseminador,
                                          ),
                                          options: inseminadorOptions,
                                          onChanged: (val) async {
                                            safeSetState(() => _model
                                                    .dropDownInseminadorValue =
                                                val);
                                          },
                                          height: 56.0,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
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
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                          hintText: 'Selecionar',
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            size: 24.0,
                                          ),
                                          fillColor: const Color(0xFFF1F1F1),
                                          elevation: 2.0,
                                          borderColor: Colors.transparent,
                                          borderWidth: 0.0,
                                          borderRadius: 8.0,
                                          margin: const EdgeInsetsDirectional
                                              .fromSTEB(12.0, 0.0, 12.0, 0.0),
                                          hidesUnderline: true,
                                          isOverButton: false,
                                          isSearchable: false,
                                          isMultiSelect: false,
                                        );
                                      },
                                    ),
                                  ].divide(const SizedBox(height: 8.0)),
                                ),
                              ),
                            ].divide(const SizedBox(width: 24.0)),
                          ),
                          Container(
                            decoration: const BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Matriz*',
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
                                              fontSize: 16.0,
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
                                          Flexible(
                                            child: Builder(
                                              builder: (context) => InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final selecaoCadastro =
                                                      FFAppState()
                                                          .matrizSelecionada;
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      _model
                                                          .matrizFiltroSelecionada;
                                                  await showDialog(
                                                    barrierColor:
                                                        Colors.transparent,
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
                                                        child: const SizedBox(
                                                          height: 450.0,
                                                          width: 370.0,
                                                          child:
                                                              PopupRebanhosWidget(
                                                            sexo: 'Fêmea',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  final selecaoFiltro =
                                                      FFAppState()
                                                          .matrizSelecionada;
                                                  FFAppState()
                                                          .matrizSelecionada =
                                                      selecaoCadastro;
                                                  safeSetState(() {
                                                    _model.matrizFiltroSelecionada =
                                                        selecaoFiltro;
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .customColor2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(12.0, 0.0,
                                                            12.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          _animalFilterLabel(
                                                            _model
                                                                .matrizFiltroSelecionada,
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
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .open_in_new_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                                          if (_model.matrizFiltroSelecionada
                                                  .numAnimal !=
                                              '')
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                safeSetState(() {
                                                  _model.matrizFiltroSelecionada =
                                                      AnimalSelecionadoStruct();
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .accent3,
                                                size: 24.0,
                                              ),
                                            ),
                                        ].divide(const SizedBox(width: 16.0)),
                                      ),
                                    ].divide(const SizedBox(height: 8.0)),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reprodutor*',
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
                                              fontSize: 16.0,
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
                                          Flexible(
                                            child: Builder(
                                              builder: (context) => InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  final selecaoCadastro =
                                                      FFAppState()
                                                          .reprodutorSelecionado;
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      _model
                                                          .reprodutorFiltroSelecionado;
                                                  await showDialog(
                                                    barrierColor:
                                                        Colors.transparent,
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
                                                        child: const SizedBox(
                                                          height: 450.0,
                                                          width: 370.0,
                                                          child:
                                                              PopupRebanhosWidget(
                                                            sexo: 'Macho',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  final selecaoFiltro =
                                                      FFAppState()
                                                          .reprodutorSelecionado;
                                                  FFAppState()
                                                          .reprodutorSelecionado =
                                                      selecaoCadastro;
                                                  safeSetState(() {
                                                    _model.reprodutorFiltroSelecionado =
                                                        selecaoFiltro;
                                                  });
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .customColor2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(12.0, 0.0,
                                                            12.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          _animalFilterLabel(
                                                            _model
                                                                .reprodutorFiltroSelecionado,
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
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .open_in_new_rounded,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                                          if (_model.reprodutorFiltroSelecionado
                                                  .numAnimal !=
                                              '')
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                safeSetState(() {
                                                  _model.reprodutorFiltroSelecionado =
                                                      AnimalSelecionadoStruct();
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .accent3,
                                                size: 24.0,
                                              ),
                                            ),
                                        ].divide(const SizedBox(width: 16.0)),
                                      ),
                                    ].divide(const SizedBox(height: 8.0)),
                                  ),
                                ),
                              ].divide(const SizedBox(width: 24.0)),
                            ),
                          ),
                        ].divide(const SizedBox(height: 24.0)),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FFButtonWidget(
                        onPressed: () async {
                          final appState = FFAppState();
                          appState.filtroDataReproducaoDe = null;
                          appState.filtroDataReproducaoAte = null;
                          appState.filtroDataPartoDe = null;
                          appState.filtroDataPartoAte = null;
                          appState.filtroDataDiagnosticoDe = null;
                          appState.filtroDataDiagnosticoAte = null;
                          appState.filtroStatusReproducao = [];
                          appState.filtroCategoriaRepro = '';
                          appState.filtroTipoReproducao = '';
                          appState.filtroLoteNome = '';
                          appState.filtroInseminador = '';
                          appState.filtroIDMatriz = '';
                          appState.filtroIDReprodutor = '';
                          appState.filtroMatrizSelecionada =
                              AnimalSelecionadoStruct();
                          appState.filtroReprodutorSelecionado =
                              AnimalSelecionadoStruct();
                          safeSetState(() {
                            _model.datePickedReproDe = null;
                            _model.datePickedReproAte = null;
                            _model.datePickedPartoDe = null;
                            _model.datePickedPartoAte = null;
                            _model.datePickedDiagDe = null;
                            _model.datePickedDiagAte = null;
                            _model.matrizFiltroSelecionada =
                                AnimalSelecionadoStruct();
                            _model.reprodutorFiltroSelecionado =
                                AnimalSelecionadoStruct();
                            _model.dDCatRebanhoValueController?.reset();
                            _model.dDCatRebanhoValue = null;
                            _model.dDDiagnosticoValueController?.value = [];
                            _model.dDDiagnosticoValue = [];
                            _model.dDTipoReproducaoValueController?.reset();
                            _model.dDTipoReproducaoValue = null;
                            _model.dropDownLoteValueController?.reset();
                            _model.dropDownLoteValue = null;
                            _model.dropDownInseminadorValueController?.reset();
                            _model.dropDownInseminadorValue = null;
                          });
                          safeSetState(() {
                            _model.dataReproducaoDeTextController?.text =
                                valueOrDefault<String>(
                              dateTimeFormat(
                                "d/M/y",
                                _model.datePickedReproDe,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              'dd/mm/aaaa',
                            );
                            _model.dataReproducaoAteTextController?.text =
                                valueOrDefault<String>(
                              dateTimeFormat(
                                "d/M/y",
                                _model.datePickedReproAte,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              'dd/mm/aaaa',
                            );

                            _model.dataPartoDeTextController?.text =
                                valueOrDefault<String>(
                              dateTimeFormat(
                                "d/M/y",
                                _model.datePickedPartoDe,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              'dd/mm/aaaa',
                            );
                            _model.dataPartoAteTextController?.text =
                                valueOrDefault<String>(
                              dateTimeFormat(
                                "d/M/y",
                                _model.datePickedPartoAte,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              'dd/mm/aaaa',
                            );

                            _model.dataDiagnosticoDeTextController?.text =
                                valueOrDefault<String>(
                              dateTimeFormat(
                                "d/M/y",
                                _model.datePickedDiagDe,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              'dd/mm/aaaa',
                            );
                            _model.dataDiagnosticoAteTextController?.text =
                                valueOrDefault<String>(
                              dateTimeFormat(
                                "d/M/y",
                                _model.datePickedDiagAte,
                                locale:
                                    FFLocalizations.of(context).languageCode,
                              ),
                              'dd/mm/aaaa',
                            );
                          });
                          appState.refreshReproducao = true;
                          safeSetState(() {});
                          Navigator.pop(context);
                        },
                        text: 'Limpar',
                        options: FFButtonOptions(
                          width: 112.0,
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: Colors.white,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFF28A365),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          final appState = FFAppState();
                          appState.filtroDataReproducaoDe =
                              _model.datePickedReproDe;
                          appState.filtroDataReproducaoAte =
                              _model.datePickedReproAte;
                          appState.filtroDataPartoDe = _model.datePickedPartoDe;
                          appState.filtroDataPartoAte =
                              _model.datePickedPartoAte;
                          appState.filtroDataDiagnosticoDe =
                              _model.datePickedDiagDe;
                          appState.filtroDataDiagnosticoAte =
                              _model.datePickedDiagAte;
                          appState.filtroStatusReproducao = List<String>.from(
                            _model.dDDiagnosticoValue ?? const [],
                          );
                          appState.filtroCategoriaRepro =
                              _model.dDCatRebanhoValue ?? '';
                          appState.filtroTipoReproducao =
                              _model.dDTipoReproducaoValue ?? '';
                          appState.filtroLoteNome = containerLotesRowList
                                  .where((lote) =>
                                      lote.idLote == _model.dropDownLoteValue)
                                  .map((lote) => lote.nome)
                                  .firstOrNull ??
                              '';
                          appState.filtroInseminador =
                              _model.dropDownInseminadorValue ?? '';
                          appState.filtroMatrizSelecionada =
                              _model.matrizFiltroSelecionada;
                          appState.filtroReprodutorSelecionado =
                              _model.reprodutorFiltroSelecionado;
                          appState.filtroIDMatriz =
                              _model.matrizFiltroSelecionada.idAnimal.trim();
                          appState.filtroIDReprodutor = _model
                              .reprodutorFiltroSelecionado.idAnimal
                              .trim();
                          appState.refreshReproducao = true;
                          safeSetState(() {});
                          Navigator.pop(context);
                        },
                        text: 'Aplicar filtro',
                        options: FFButtonOptions(
                          width: 160.0,
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
                  ),
                ].divide(const SizedBox(height: 24.0)),
              ),
            ),
          );
        },
      ),
    );
  }
}
