import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/reproducao/modal_excluir_reproducao/modal_excluir_reproducao_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modal_more_reproducao_model.dart';
export 'modal_more_reproducao_model.dart';

class ModalMoreReproducaoWidget extends StatefulWidget {
  const ModalMoreReproducaoWidget({
    super.key,
    required this.reproducaoID,
  });

  final String? reproducaoID;

  @override
  State<ModalMoreReproducaoWidget> createState() =>
      _ModalMoreReproducaoWidgetState();
}

class _ModalMoreReproducaoWidgetState extends State<ModalMoreReproducaoWidget> {
  late ModalMoreReproducaoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalMoreReproducaoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 12.0, 0.0),
      child: Container(
        width: 215.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x33000000),
              offset: Offset(
                0.0,
                0.0,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FFButtonWidget(
              onPressed: () async {
                context.pushNamed(
                  PgReproducaoViewAnimalWidget.routeName,
                  queryParameters: {
                    'idReproducao': serializeParam(
                      widget.reproducaoID,
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              },
              text: 'Visualizar',
              icon: const Icon(
                Icons.remove_red_eye,
                size: 24.0,
              ),
              options: FFButtonOptions(
                height: 56.0,
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: const Color(0xFF474747),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            FFButtonWidget(
              onPressed: () async {
                context.pushNamed(
                  PgReproducaoEditAnimalWidget.routeName,
                  queryParameters: {
                    'idReproducao': serializeParam(
                      widget.reproducaoID,
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              },
              text: 'Editar',
              icon: const Icon(
                Icons.edit,
                size: 24.0,
              ),
              options: FFButtonOptions(
                height: 56.0,
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: const Color(0xFF474747),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleSmall.fontStyle,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            Builder(
              builder: (context) => FFButtonWidget(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: ModalExcluirReproducaoWidget(
                          reproducaoId: widget.reproducaoID!,
                        ),
                      );
                    },
                  );

                  Navigator.pop(context);
                },
                text: 'Excluir',
                icon: const Icon(
                  Icons.delete,
                  size: 24.0,
                ),
                options: FFButtonOptions(
                  height: 56.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Colors.white,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: const Color(0xFFCC3729),
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
