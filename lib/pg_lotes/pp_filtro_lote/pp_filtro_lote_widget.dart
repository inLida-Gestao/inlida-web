import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pp_filtro_lote_model.dart';
export 'pp_filtro_lote_model.dart';

class PpFiltroLoteWidget extends StatefulWidget {
  const PpFiltroLoteWidget({super.key});

  @override
  State<PpFiltroLoteWidget> createState() => _PpFiltroLoteWidgetState();
}

class _PpFiltroLoteWidgetState extends State<PpFiltroLoteWidget> {
  late PpFiltroLoteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PpFiltroLoteModel());

    _model.dataCriacaoDeTextController ??= TextEditingController();
    _model.dataCriacaoDeFocusNode ??= FocusNode();
    _model.dataCriacaoAteTextController ??= TextEditingController();
    _model.dataCriacaoAteFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {
          _model.dataCriacaoDeTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataCriacaoLoteDe,
              locale: FFLocalizations.of(context).languageCode,
            ),
            'dd/mm/aaaa',
          );
          _model.dataCriacaoAteTextController?.text = valueOrDefault<String>(
            dateTimeFormat(
              "d/M/y",
              FFAppState().filtroDataCriacaoLoteAte,
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 496.0,
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
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status do lote',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                        FlutterFlowDropDown<String>(
                          controller: _model.dDStatusLoteValueController ??=
                              FormFieldController<String>(
                            _model.dDStatusLoteValue ??=
                                FFAppState().filtroStatusLote,
                          ),
                          options: const ['Ativo', 'Inativo'],
                          onChanged: (val) async {
                            safeSetState(() => _model.dDStatusLoteValue = val);
                            FFAppState().filtroStatusLote =
                                _model.dDStatusLoteValue!;
                            safeSetState(() {});
                          },
                          height: 56.0,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
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
                          margin: const EdgeInsetsDirectional.fromSTEB(
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
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data de criação',
                    style:
                        FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'De',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .bodySmall
                                              .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .bodySmall
                                            .fontStyle,
                                  ),
                            ),
                            Stack(
                              children: [
                                TextFormField(
                                  controller: _model
                                      .dataCriacaoDeTextController,
                                  focusNode: _model
                                      .dataCriacaoDeFocusNode,
                                  autofocus: false,
                                  readOnly: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    hintText: 'dd/mm/aaaa',
                                    hintStyle:
                                        FlutterFlowTheme.of(
                                                context)
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
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                              8.0),
                                    ),
                                    focusedBorder:
                                        OutlineInputBorder(
                                      borderSide: const BorderSide(
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
                                      color:
                                          FlutterFlowTheme.of(
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
                                      .dataCriacaoDeTextControllerValidator
                                      .asValidator(context),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor:
                                      Colors.transparent,
                                  onTap: () async {
                                    final datePickedDeDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          getCurrentTimestamp,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2050),
                                      builder: (context, child) {
                                        return Theme(
                                          data:
                                              ThemeData.light(
                                            useMaterial3: false,
                                          ),
                                          child:
                                              wrapInMaterialDatePickerTheme(
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
                                          ),
                                        );
                                      },
                                    );

                                    if (datePickedDeDate != null) {
                                      safeSetState(() {
                                        _model.datePickedDe =
                                            DateTime(
                                          datePickedDeDate.year,
                                          datePickedDeDate.month,
                                          datePickedDeDate.day,
                                        );
                                      });
                                    }
                                    safeSetState(() {
                                      _model.dataCriacaoDeTextController
                                              ?.text =
                                          dateTimeFormat(
                                        "d/M/y",
                                        _model.datePickedDe,
                                        locale:
                                            FFLocalizations.of(
                                                    context)
                                                .languageCode,
                                      );
                                    });
                                    FFAppState()
                                            .filtroDataCriacaoLoteDe =
                                        _model.datePickedDe;
                                    safeSetState(() {});
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
                          ].divide(const SizedBox(height: 4.0)),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Até',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontStyle:
                                          FlutterFlowTheme.of(
                                                  context)
                                              .bodySmall
                                              .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle:
                                        FlutterFlowTheme.of(
                                                context)
                                            .bodySmall
                                            .fontStyle,
                                  ),
                            ),
                            Stack(
                              children: [
                                TextFormField(
                                  controller: _model
                                      .dataCriacaoAteTextController,
                                  focusNode: _model
                                      .dataCriacaoAteFocusNode,
                                  autofocus: false,
                                  readOnly: true,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: false,
                                    hintText: 'dd/mm/aaaa',
                                    hintStyle:
                                        FlutterFlowTheme.of(
                                                context)
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
                                      borderSide: const BorderSide(
                                        color: Color(0x00000000),
                                        width: 1.0,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(
                                              8.0),
                                    ),
                                    focusedBorder:
                                        OutlineInputBorder(
                                      borderSide: const BorderSide(
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
                                      color:
                                          FlutterFlowTheme.of(
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
                                      .dataCriacaoAteTextControllerValidator
                                      .asValidator(context),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor:
                                      Colors.transparent,
                                  onTap: () async {
                                    final datePickedAteDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          getCurrentTimestamp,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2050),
                                      builder: (context, child) {
                                        return Theme(
                                          data:
                                              ThemeData.light(
                                            useMaterial3: false,
                                          ),
                                          child:
                                              wrapInMaterialDatePickerTheme(
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
                                          ),
                                        );
                                      },
                                    );

                                    if (datePickedAteDate != null) {
                                      safeSetState(() {
                                        _model.datePickedAte =
                                            DateTime(
                                          datePickedAteDate.year,
                                          datePickedAteDate.month,
                                          datePickedAteDate.day,
                                        );
                                      });
                                    }
                                    safeSetState(() {
                                      _model.dataCriacaoAteTextController
                                              ?.text =
                                          dateTimeFormat(
                                        "d/M/y",
                                        _model.datePickedAte,
                                        locale:
                                            FFLocalizations.of(
                                                    context)
                                                .languageCode,
                                      );
                                    });
                                    FFAppState()
                                            .filtroDataCriacaoLoteAte =
                                        _model.datePickedAte;
                                    safeSetState(() {});
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
                          ].divide(const SizedBox(height: 4.0)),
                        ),
                      ),
                    ],
                  ),
                ].divide(const SizedBox(height: 8.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      FFAppState().filtroStatusLote = '';
                      FFAppState().filtroDataCriacaoLoteDe = null;
                      FFAppState().filtroDataCriacaoLoteAte = null;
                      FFAppState().refreshLotes = true;
                      safeSetState(() {});
                      safeSetState(() {
                        _model.dDStatusLoteValueController?.reset();
                        _model.dDStatusLoteValue = null;
                      });
                      safeSetState(() {
                        _model.dataCriacaoDeTextController?.text =
                            valueOrDefault<String>(
                          dateTimeFormat(
                            "d/M/y",
                            FFAppState().filtroDataCriacaoLoteDe,
                            locale:
                                FFLocalizations.of(context).languageCode,
                          ),
                          'dd/mm/aaaa',
                        );
                        _model.dataCriacaoAteTextController?.text =
                            valueOrDefault<String>(
                          dateTimeFormat(
                            "d/M/y",
                            FFAppState().filtroDataCriacaoLoteAte,
                            locale:
                                FFLocalizations.of(context).languageCode,
                          ),
                          'dd/mm/aaaa',
                        );
                      });
                      Navigator.pop(context);
                    },
                    text: 'Limpar',
                    options: FFButtonOptions(
                      width: 112.0,
                      height: 56.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
                      FFAppState().refreshLotes = true;
                      safeSetState(() {});
                      Navigator.pop(context);
                    },
                    text: 'Aplicar filtro',
                    options: FFButtonOptions(
                      width: 160.0,
                      height: 56.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
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
      ),
    );
  }
}
