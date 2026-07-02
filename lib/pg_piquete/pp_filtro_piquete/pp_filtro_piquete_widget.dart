import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pp_filtro_piquete_model.dart';
export 'pp_filtro_piquete_model.dart';

class PpFiltroPiqueteWidget extends StatefulWidget {
  const PpFiltroPiqueteWidget({super.key});

  @override
  State<PpFiltroPiqueteWidget> createState() => _PpFiltroPiqueteWidgetState();
}

class _PpFiltroPiqueteWidgetState extends State<PpFiltroPiqueteWidget> {
  late PpFiltroPiqueteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PpFiltroPiqueteModel());
    _model.areaMin = FFAppState().filtroAreaMin;
    _model.areaMax = FFAppState().filtroAreaMax == 9999
        ? 100
        : FFAppState().filtroAreaMax;
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
      child: Container(
        width: 496.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(6.0),
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
                    borderRadius: 6.0,
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
              // Forrageira dropdown
              FutureBuilder<List<ForrageirasRow>>(
                future: ForrageirasTable().queryRows(
                  queryFn: (q) => q.order('nome', ascending: true),
                ),
                builder: (context, snapshot) {
                  final forrageiras = snapshot.data ?? [];
                  final options =
                      forrageiras.map((f) => f.nome).toList();

                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Forrageira',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
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
                              controller:
                                  _model.dDForrageiraValueController ??=
                                      FormFieldController<String>(
                                _model.dDForrageiraValue ??=
                                    FFAppState().filtroPiqueteForrageira.isEmpty
                                        ? null
                                        : FFAppState().filtroPiqueteForrageira,
                              ),
                              options: options,
                              onChanged: (val) async {
                                safeSetState(
                                    () => _model.dDForrageiraValue = val);
                                FFAppState().filtroPiqueteForrageira =
                                    _model.dDForrageiraValue ?? '';
                                safeSetState(() {});
                              },
                              height: 56.0,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                              fillColor: const Color(0xFFF1F1F1),
                              elevation: 2.0,
                              borderColor: Colors.transparent,
                              borderWidth: 0.0,
                              borderRadius: 6.0,
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
                    ],
                  );
                },
              ),
              // Area slider
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Área do piquete (ha)',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  Text(
                    '${_model.areaMin.toStringAsFixed(0)} - ${_model.areaMax.toStringAsFixed(0)}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                        ),
                  ),
                  RangeSlider(
                    values: RangeValues(_model.areaMin, _model.areaMax),
                    min: 0,
                    max: 100,
                    activeColor: FlutterFlowTheme.of(context).primary,
                    inactiveColor:
                        FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                    onChanged: (values) {
                      safeSetState(() {
                        _model.areaMin = values.start;
                        _model.areaMax = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                      Text(
                        '100',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                ].divide(const SizedBox(height: 8.0)),
              ),
              // Buttons
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      FFAppState().filtroPiqueteForrageira = '';
                      FFAppState().filtroAreaMin = 0;
                      FFAppState().filtroAreaMax = 9999;
                      FFAppState().refreshPiquete = true;
                      safeSetState(() {});
                      safeSetState(() {
                        _model.dDForrageiraValueController?.reset();
                        _model.dDForrageiraValue = null;
                        _model.areaMin = 0;
                        _model.areaMax = 100;
                      });
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
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      FFAppState().filtroAreaMin = _model.areaMin;
                      FFAppState().filtroAreaMax =
                          _model.areaMax >= 100 ? 9999 : _model.areaMax;
                      FFAppState().refreshPiquete = true;
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
                      borderRadius: BorderRadius.circular(6.0),
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
