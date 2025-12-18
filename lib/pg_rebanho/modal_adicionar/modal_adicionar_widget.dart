import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'modal_adicionar_model.dart';
export 'modal_adicionar_model.dart';

class ModalAdicionarWidget extends StatefulWidget {
  const ModalAdicionarWidget({
    super.key,
    required this.action,
  });

  final Future Function(String? page)? action;

  @override
  State<ModalAdicionarWidget> createState() => _ModalAdicionarWidgetState();
}

class _ModalAdicionarWidgetState extends State<ModalAdicionarWidget> {
  late ModalAdicionarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalAdicionarModel());

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

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
      child: Container(
        width: 200.0,
        constraints: const BoxConstraints(
          maxWidth: 200.0,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x33000000),
              offset: Offset(
                2.0,
                2.0,
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
                if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                  FFAppState().matrizSelecionada = AnimalSelecionadoStruct();
                  FFAppState().reprodutorSelecionado =
                      AnimalSelecionadoStruct();
                  FFAppState().refreshAnimalSelecionado = false;

                  _model.lotes2 = await LotesTable().queryRows(
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
                  FFAppState().rebanhoLotesSelecionar = [];
                  safeSetState(() {});
                  while (_model.index < _model.lotes2!.length) {
                    FFAppState().addToRebanhoLotesSelecionar(LotesDTStruct(
                      idLote:
                          _model.lotes2?.elementAtOrNull(_model.index)?.idLote,
                      nome: _model.lotes2?.elementAtOrNull(_model.index)?.nome,
                    ));
                    safeSetState(() {});
                    _model.index = _model.index + 1;
                    safeSetState(() {});
                  }
                  Navigator.pop(context);

                  context.pushNamed(PgRebanhoAddNascimentoWidget.routeName);
                } else {
                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        content: const Text('Selecione uma propriedade'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertDialogContext),
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }

                safeSetState(() {});
              },
              text: 'Nascimento',
              icon: const Icon(
                Icons.add,
                size: 24.0,
              ),
              options: FFButtonOptions(
                height: 56.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primary,
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
                if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                  FFAppState().matrizSelecionada = AnimalSelecionadoStruct();
                  FFAppState().reprodutorSelecionado =
                      AnimalSelecionadoStruct();
                  FFAppState().refreshAnimalSelecionado = false;

                  _model.lotes = await LotesTable().queryRows(
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
                  FFAppState().rebanhoLotesSelecionar = [];
                  safeSetState(() {});
                  while (_model.index < _model.lotes!.length) {
                    FFAppState().addToRebanhoLotesSelecionar(LotesDTStruct(
                      idLote:
                          _model.lotes?.elementAtOrNull(_model.index)?.idLote,
                      nome: _model.lotes?.elementAtOrNull(_model.index)?.nome,
                    ));
                    safeSetState(() {});
                    _model.index = _model.index + 1;
                    safeSetState(() {});
                  }
                  Navigator.pop(context);

                  context.pushNamed(PgRebanhoAddWidget.routeName);
                } else {
                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        content: const Text('Selecione uma propriedade'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertDialogContext),
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }

                safeSetState(() {});
              },
              text: 'Animal',
              icon: const Icon(
                Icons.add,
                size: 24.0,
              ),
              options: FFButtonOptions(
                height: 56.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primary,
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
                if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                  Navigator.pop(context);

                  context.pushNamed(PgRebanhoAddSemenWidget.routeName);
                } else {
                  await showDialog(
                    context: context,
                    builder: (alertDialogContext) {
                      return AlertDialog(
                        content: const Text('Selecione uma propriedade'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(alertDialogContext),
                            child: const Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              text: 'Sêmen',
              icon: const Icon(
                Icons.add,
                size: 24.0,
              ),
              options: FFButtonOptions(
                height: 56.0,
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.white,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).titleSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primary,
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
          ],
        ),
      ),
    );
  }
}
