import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import '/actions/actions.dart' as action_blocks;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modal_excluir_lote_model.dart';
export 'modal_excluir_lote_model.dart';

class ModalExcluirLoteWidget extends StatefulWidget {
  const ModalExcluirLoteWidget({
    super.key,
    required this.idLote,
  });

  final String? idLote;

  @override
  State<ModalExcluirLoteWidget> createState() => _ModalExcluirLoteWidgetState();
}

class _ModalExcluirLoteWidgetState extends State<ModalExcluirLoteWidget> {
  late ModalExcluirLoteModel _model;

  bool _isActiveRow(Map<String, dynamic> row) {
    return row['deletado']?.toString().trim().toUpperCase() != 'SIM';
  }

  Future<int> _countActiveRowsWithLote({
    required String table,
    required String idColumn,
    required String propertyColumn,
    required String idLote,
    required String idPropriedade,
  }) async {
    const batchSize = 1000;
    var offset = 0;
    var total = 0;

    while (true) {
      final rows = await SupaFlow.client
          .from(table)
          .select('id,deletado')
          .eq(idColumn, idLote)
          .eq(propertyColumn, idPropriedade)
          .range(offset, offset + batchSize - 1);

      for (final row in rows) {
        if (_isActiveRow(Map<String, dynamic>.from(row))) {
          total++;
        }
      }

      if (rows.length < batchSize) {
        return total;
      }
      offset += batchSize;
    }
  }

  Future<void> _showBlockedDeleteDialog({
    required int animaisCount,
    required int reproducoesCount,
  }) async {
    final motivos = <String>[
      if (animaisCount > 0)
        '$animaisCount ${animaisCount == 1 ? 'animal vinculado' : 'animais vinculados'}',
      if (reproducoesCount > 0)
        '$reproducoesCount ${reproducoesCount == 1 ? 'reprodução vinculada' : 'reproduções vinculadas'}',
    ];

    await showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Lote não pode ser excluído'),
          content: Text(
            'Este lote possui ${motivos.join(' e ')}. '
            'Remova ou transfira os vínculos antes de excluir o lote.',
          ),
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

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalExcluirLoteModel());

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
      child: FutureBuilder<List<LotesRow>>(
        future: LotesTable().querySingleRow(
          queryFn: (q) => q.eqOrNull(
            'id_lote',
            widget.idLote,
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            );
          }
          List<LotesRow> containerLotesRowList = snapshot.data!;

          final containerLotesRow = containerLotesRowList.isNotEmpty
              ? containerLotesRowList.first
              : null;

          return Container(
            width: 534.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Excluir lote',
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
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.triangleExclamation,
                        color: Color(0xFFCC3729),
                        size: 48.0,
                      ),
                      Flexible(
                        child: Text(
                          'Tem certeza que deseja excluir o lote ${containerLotesRow?.nome}? Essa ação é irreversível.',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ),
                    ].divide(const SizedBox(width: 12.0)),
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
                          width: 133.0,
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: const Color(0x0028A365),
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
                                    color: const Color(0xFFCC3729),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderSide: const BorderSide(
                            color: Color(0xFFCC3729),
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          final idLote = widget.idLote?.trim();
                          final idPropriedade =
                              containerLotesRow?.idPropriedade?.trim();
                          if (idLote == null ||
                              idLote.isEmpty ||
                              idPropriedade == null ||
                              idPropriedade.isEmpty) {
                            await showDialog(
                              context: context,
                              builder: (alertDialogContext) {
                                return AlertDialog(
                                  title: const Text('Não foi possível excluir'),
                                  content: const Text(
                                    'Não foi possível validar os vínculos deste lote. Tente novamente.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(alertDialogContext),
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          final animaisCount = await _countActiveRowsWithLote(
                            table: 'rebanho',
                            idColumn: 'loteID',
                            propertyColumn: 'idPropriedade',
                            idLote: idLote,
                            idPropriedade: idPropriedade,
                          );
                          if (!context.mounted) {
                            return;
                          }

                          final reproducoesCount =
                              await _countActiveRowsWithLote(
                            table: 'reproducao',
                            idColumn: 'id_lote',
                            propertyColumn: 'id_propriedade',
                            idLote: idLote,
                            idPropriedade: idPropriedade,
                          );
                          if (!context.mounted) {
                            return;
                          }

                          if (animaisCount > 0 || reproducoesCount > 0) {
                            await _showBlockedDeleteDialog(
                              animaisCount: animaisCount,
                              reproducoesCount: reproducoesCount,
                            );
                            return;
                          }

                          await LotesTable().update(
                            data: {
                              'deletado': 'SIM',
                            },
                            matchingRows: (rows) => rows.eqOrNull(
                              'id_lote',
                              widget.idLote,
                            ),
                          );
                          if (!context.mounted) {
                            return;
                          }

                          FFAppState().refreshLotes = true;
                          safeSetState(() {});
                          unawaited(
                            () async {
                              await action_blocks.countLotes(context);
                            }(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Lote excluído',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              duration: const Duration(milliseconds: 4000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).error,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        text: 'Excluir',
                        options: FFButtonOptions(
                          width: 106.0,
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: const Color(0xFFCC3729),
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
                    ].divide(const SizedBox(width: 12.0)),
                  ),
                ].divide(const SizedBox(height: 48.0)),
              ),
            ),
          );
        },
      ),
    );
  }
}
