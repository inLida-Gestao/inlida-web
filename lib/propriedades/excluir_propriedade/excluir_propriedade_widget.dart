import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'excluir_propriedade_model.dart';
export 'excluir_propriedade_model.dart';

class ExcluirPropriedadeWidget extends StatefulWidget {
  const ExcluirPropriedadeWidget({
    super.key,
    required this.idPropriedade,
  });

  final String? idPropriedade;

  @override
  State<ExcluirPropriedadeWidget> createState() =>
      _ExcluirPropriedadeWidgetState();
}

class _ExcluirPropriedadeWidgetState extends State<ExcluirPropriedadeWidget> {
  late ExcluirPropriedadeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExcluirPropriedadeModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.propriedade = await PropriedadesTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'idPropriedade',
          widget.idPropriedade,
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: FutureBuilder<ApiCallResponse>(
        future: FunctionsSupabaseRebanhoGroup.qTDRebanhoPropriedadeCall.call(
          pIdPropriedade: widget.idPropriedade,
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
          final containerQTDRebanhoPropriedadeResponse = snapshot.data!;

          return Container(
            width: 534.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Excluir propriedade',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 24.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.exclamationTriangle,
                        color: FlutterFlowTheme.of(context).error,
                        size: 48.0,
                      ),
                      Flexible(
                        child: Text(
                          'Essa propriedade possui ${valueOrDefault<String>(
                            containerQTDRebanhoPropriedadeResponse.jsonBody
                                .toString(),
                            '0',
                          )} animais que serão excluídos.',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ].divide(const SizedBox(width: 24.0)),
                  ),
                  Flexible(
                    child: Text(
                      'Tem certeza de que deseja excluir a propriedade ${_model.propriedade?.firstOrNull?.nome}? Essa ação é irreversível.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        text: 'Cancelar',
                        options: FFButtonOptions(
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: const Color(0x00CC3729),
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
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 18.0,
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
                            color: FlutterFlowTheme.of(context).error,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          await PropriedadesTable().update(
                            data: {
                              'deletado': 'SIM',
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'idPropriedade',
                              widget.idPropriedade,
                            ),
                          );
                          await RebanhoTable().update(
                            data: {
                              'deletado': 'SIM',
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'idPropriedade',
                              widget.idPropriedade,
                            ),
                          );
                          await LotesTable().update(
                            data: {
                              'deletado': 'SIM',
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id_propriedade',
                              widget.idPropriedade,
                            ),
                          );
                          await ReproducaoTable().update(
                            data: {
                              'deletado': 'SIM',
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id_propriedade',
                              widget.idPropriedade,
                            ),
                          );
                          await SanidadeTable().update(
                            data: {
                              'deletado': 'SIM',
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id_propriedade',
                              widget.idPropriedade,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Propriedade deletada',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                ),
                              ),
                              duration: const Duration(milliseconds: 4000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).error,
                            ),
                          );
                          FFAppState().refreshPropriedades = true;
                          safeSetState(() {});
                          Navigator.pop(context);
                        },
                        text: 'Excluir',
                        options: FFButtonOptions(
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).error,
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
                                    fontSize: 18.0,
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
                    ].divide(const SizedBox(width: 16.0)),
                  ),
                ].divide(const SizedBox(height: 32.0)),
              ),
            ),
          );
        },
      ),
    );
  }
}
