import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pg_rebanho/modal_excluir_animal/modal_excluir_animal_widget.dart';
import '/pg_rebanho/pp_add_pessagem/pp_add_pessagem_widget.dart';
import 'dart:async';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'modal_more_model.dart';
export 'modal_more_model.dart';

class ModalMoreWidget extends StatefulWidget {
  const ModalMoreWidget({
    super.key,
    required this.rebanhoId,
  });

  final int? rebanhoId;

  @override
  State<ModalMoreWidget> createState() => _ModalMoreWidgetState();
}

class _ModalMoreWidgetState extends State<ModalMoreWidget> {
  late ModalMoreModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalMoreModel());

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
                FFAppState().crias = [];
                safeSetState(() {});
                _model.rebanho = await RebanhoTable().queryRows(
                  queryFn: (q) => q.eqOrNull(
                    'id',
                    widget.rebanhoId,
                  ),
                );
                if (_model.rebanho?.firstOrNull?.sexo == 'Fêmea') {
                  _model.criasMatriz = await RebanhoTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull(
                          'rebanhoIdMatriz',
                          _model.rebanho?.firstOrNull?.idRebanho,
                        )
                        .eqOrNull(
                          'idPropriedade',
                          FFAppState().propriedadeSelecionada.idPropriedade,
                        )
                        .eqOrNull(
                          'deletado',
                          'NAO',
                        ),
                  );
                  if (_model.criasMatriz != null &&
                      (_model.criasMatriz)!.isNotEmpty) {
                    FFAppState().crias = [];
                    safeSetState(() {});
                    _model.indexCrias = 0;
                    safeSetState(() {});
                    while (_model.indexCrias < _model.criasMatriz!.length) {
                      final criasMatrizRow = _model.criasMatriz?.elementAtOrNull(_model.indexCrias);
                      if ((criasMatrizRow?.id == widget.rebanhoId) ||
                          (criasMatrizRow?.idRebanho == _model.rebanho?.firstOrNull?.idRebanho) ||
                          (criasMatrizRow?.numeroAnimal == _model.rebanho?.firstOrNull?.numeroAnimal)) {
                        _model.indexCrias = _model.indexCrias + 1;
                        safeSetState(() {});
                        continue;
                      }
                      FFAppState().addToCrias(AnimaisStruct(
                        idRebanho: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.idRebanho,
                        sexo: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.sexo,
                        numeroAnimal: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.numeroAnimal,
                        nome: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.nome,
                        dataNascimento: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.dataNascimento
                            ?.toString(),
                        categoria: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.categoria,
                        raca: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.raca,
                        loteNome: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.loteNome,
                        rebanhoIdMatriz: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.rebanhoIdMatriz,
                        rebanhoIdReprodutor: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.rebanhoIdReprodutor,
                        status: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.status,
                        id: _model.criasMatriz
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.id,
                      ));
                      safeSetState(() {});
                      _model.indexCrias = _model.indexCrias + 1;
                      safeSetState(() {});
                    }
                    _model.indexCrias = 0;
                    safeSetState(() {});
                  }
                }
                if (_model.rebanho?.firstOrNull?.sexo == 'Macho') {
                  _model.criasReprodutor = await RebanhoTable().queryRows(
                    queryFn: (q) => q
                        .eqOrNull(
                          'rebanhoIdReprodutor',
                          _model.rebanho?.firstOrNull?.idRebanho,
                        )
                        .eqOrNull(
                          'idPropriedade',
                          FFAppState().propriedadeSelecionada.idPropriedade,
                        )
                        .eqOrNull(
                          'deletado',
                          'NAO',
                        ),
                  );
                  if (_model.criasReprodutor != null &&
                      (_model.criasReprodutor)!.isNotEmpty) {
                    _model.indexCrias = 0;
                    safeSetState(() {});
                    while (_model.indexCrias < _model.criasReprodutor!.length) {
                      final criasReprodutorRow = _model.criasReprodutor?.elementAtOrNull(_model.indexCrias);
                      if ((criasReprodutorRow?.id == widget.rebanhoId) ||
                          (criasReprodutorRow?.idRebanho == _model.rebanho?.firstOrNull?.idRebanho) ||
                          (criasReprodutorRow?.numeroAnimal == _model.rebanho?.firstOrNull?.numeroAnimal)) {
                        _model.indexCrias = _model.indexCrias + 1;
                        safeSetState(() {});
                        continue;
                      }
                      FFAppState().addToCrias(AnimaisStruct(
                        idRebanho: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.idRebanho,
                        sexo: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.sexo,
                        numeroAnimal: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.numeroAnimal,
                        nome: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.nome,
                        dataNascimento: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.dataNascimento
                            ?.toString(),
                        categoria: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.categoria,
                        raca: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.raca,
                        loteNome: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.loteNome,
                        rebanhoIdMatriz: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.rebanhoIdMatriz,
                        rebanhoIdReprodutor: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.rebanhoIdReprodutor,
                        status: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.status,
                        id: _model.criasReprodutor
                            ?.elementAtOrNull(_model.indexCrias)
                            ?.id,
                      ));
                      safeSetState(() {});
                      _model.indexCrias = _model.indexCrias + 1;
                      safeSetState(() {});
                    }
                    _model.indexCrias = 0;
                    safeSetState(() {});
                  }
                }
                _model.histPesagens = await HistoricoPesagensTable().queryRows(
                  queryFn: (q) => q.eqOrNull(
                    'idRebanho',
                    _model.rebanho?.firstOrNull?.idRebanho,
                  ),
                );
                if (_model.histPesagens != null &&
                    (_model.histPesagens)!.isNotEmpty) {
                  FFAppState().histPesagens = [];
                  safeSetState(() {});
                  while (_model.indexPesagens < _model.histPesagens!.length) {
                    FFAppState().addToHistPesagens(HistoricoPesagensStruct(
                      id: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.id,
                      idRebanho: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.idRebanho,
                      dataPesagem: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.dataPesagem,
                      tipo: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.tipo,
                      peso: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.peso,
                      deletado: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.deletado,
                      createdAt: _model.histPesagens
                          ?.elementAtOrNull(_model.indexPesagens)
                          ?.createdAt
                          .toString(),
                    ));
                    safeSetState(() {});
                    _model.indexPesagens = _model.indexPesagens + 1;
                    safeSetState(() {});
                  }
                  _model.indexPesagens = 0;
                  safeSetState(() {});
                }
                Navigator.pop(context);

                context.pushNamed(
                  PgRebanhoViewWidget.routeName,
                  queryParameters: {
                    'rebanhoId': serializeParam(
                      widget.rebanhoId,
                      ParamType.int,
                    ),
                  }.withoutNulls,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );

                safeSetState(() {});
              },
              text: 'Visualizar',
              icon: const Icon(
                Icons.remove_red_eye,
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
                  Navigator.pop(context);
                  await showDialog(
                    barrierColor: const Color(0x29000000),
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: PpAddPessagemWidget(
                          rebanhoId: widget.rebanhoId!,
                        ),
                      );
                    },
                  );
                },
                text: 'Adicionar pesagem',
                icon: const Icon(
                  Icons.add,
                  size: 24.0,
                ),
                options: FFButtonOptions(
                  height: 56.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 0.0, 16.0, 0.0),
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
            ),
            FFButtonWidget(
              onPressed: () async {
                _model.rebanhoPrincipal = await RebanhoTable().queryRows(
                  queryFn: (q) => q.eqOrNull(
                    'id',
                    widget.rebanhoId,
                  ),
                );
                _model.matriz = await RebanhoTable().queryRows(
                  queryFn: (q) => q
                      .eqOrNull(
                        'numeroAnimal',
                        _model.rebanhoPrincipal?.firstOrNull?.numeroMatriz,
                      )
                      .eqOrNull(
                        'dataNascimento',
                        supaSerialize<DateTime>(functions.converterParaData(
                            _model.rebanhoPrincipal?.firstOrNull?.dataNascMatriz
                                ?.toString())),
                      )
                      .eqOrNull(
                        'raca',
                        _model.rebanhoPrincipal?.firstOrNull?.racaMatriz,
                      ),
                );
                _model.reprodutor = await RebanhoTable().queryRows(
                  queryFn: (q) => q
                      .eqOrNull(
                        'numeroAnimal',
                        _model.rebanhoPrincipal?.firstOrNull?.numeroReprodutor,
                      )
                      .eqOrNull(
                        'dataNascimento',
                        supaSerialize<DateTime>(functions.converterParaData(
                            _model.rebanhoPrincipal?.firstOrNull
                                ?.dataNascReprodutor
                                ?.toString())),
                      )
                      .eqOrNull(
                        'raca',
                        _model.rebanhoPrincipal?.firstOrNull?.racaReprodutor,
                      ),
                );
                FFAppState().matrizSelecionada = AnimalSelecionadoStruct(
                  numAnimal: _model.matriz?.firstOrNull?.numeroAnimal,
                  nomeAnimal: _model.matriz?.firstOrNull?.nome,
                  dataNascAnimal:
                      _model.matriz?.firstOrNull?.dataNascimento?.toString(),
                  racaAnimal: _model.matriz?.firstOrNull?.raca,
                );
                FFAppState().reprodutorSelecionado = AnimalSelecionadoStruct(
                  numAnimal: _model.reprodutor?.firstOrNull?.numeroAnimal,
                  nomeAnimal: _model.reprodutor?.firstOrNull?.nome,
                  dataNascAnimal: _model.reprodutor?.firstOrNull?.dataNascimento
                      ?.toString(),
                  racaAnimal: _model.reprodutor?.firstOrNull?.raca,
                );
                safeSetState(() {});
                unawaited(
                  () async {
                    await RebanhoTable().update(
                      data: {
                        'rebanhoIdMatriz':
                            _model.matriz?.firstOrNull?.idRebanho,
                        'rebanhoIdReprodutor':
                            _model.reprodutor?.firstOrNull?.idRebanho,
                      },
                      matchingRows: (rows) => rows.eqOrNull(
                        'id',
                        widget.rebanhoId,
                      ),
                    );
                  }(),
                );

                context.pushNamed(
                  PgRebanhoEditWidget.routeName,
                  queryParameters: {
                    'rebanhoId': serializeParam(
                      widget.rebanhoId,
                      ParamType.int,
                    ),
                  }.withoutNulls,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: const TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.fade,
                      duration: Duration(milliseconds: 0),
                    ),
                  },
                );

                safeSetState(() {});
              },
              text: 'Editar',
              icon: const Icon(
                Icons.edit,
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
                  Navigator.pop(context);
                  await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(context)),
                        child: ModalExcluirAnimalWidget(
                          rebanhoId: widget.rebanhoId!,
                        ),
                      );
                    },
                  );
                },
                text: 'Excluir',
                icon: const Icon(
                  Icons.delete,
                  size: 24.0,
                ),
                options: FFButtonOptions(
                  height: 56.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 0.0, 16.0, 0.0),
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
