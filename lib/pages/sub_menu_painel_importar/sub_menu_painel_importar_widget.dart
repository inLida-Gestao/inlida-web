import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/custom_code/actions/index.dart' as actions;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:download/download.dart';
import 'package:provider/provider.dart';
import '/pages/pp_importar_pesagem/pp_importar_pesagem_widget.dart';
import '/pages/pp_instrucoes_importacao/pp_instrucoes_importacao_widget.dart';
import 'sub_menu_painel_importar_model.dart';
export 'sub_menu_painel_importar_model.dart';

class SubMenuPainelImportarWidget extends StatefulWidget {
  const SubMenuPainelImportarWidget({super.key});

  @override
  State<SubMenuPainelImportarWidget> createState() =>
      _SubMenuPainelImportarWidgetState();
}

class _SubMenuPainelImportarWidgetState
    extends State<SubMenuPainelImportarWidget> {
  late SubMenuPainelImportarModel _model;

  String _csvEscape(String value) {
    final needsQuotes =
        value.contains(';') || value.contains('"') || value.contains('\n');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  Future<void> _exportFailedRowsCsv(List<dynamic> failedRows) async {
    final buffer = StringBuffer();
    buffer.writeln('Linha;Numero;Nome;Motivo;Erro');

    for (final row in failedRows) {
      final map =
          row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{};

      final linha = (map['linha']?.toString() ?? '').trim();
      final numero = (map['numeroAnimal']?.toString() ?? '').trim();
      final nome = (map['nome']?.toString() ?? '').trim();
      final motivo = (map['motivo']?.toString() ?? '').trim();
      final erro = (map['erro']?.toString() ?? '').trim();

      buffer.writeln(
        '${_csvEscape(linha)};${_csvEscape(numero)};${_csvEscape(nome)};${_csvEscape(motivo)};${_csvEscape(erro)}',
      );
    }

    final csvContent = '\uFEFF${buffer.toString()}';
    final bytes = utf8.encode(csvContent);
    final now = DateTime.now();
    final fileName =
        'erros_importacao_rebanho_${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';

    await download(Stream.fromIterable(bytes), fileName);
  }

  Future<void> _exportFailedRowsCsvLotes(List<dynamic> failedRows) async {
    final buffer = StringBuffer();
    buffer.writeln('Linha;ID_Lote;Nome;Motivo;Erro');

    for (final row in failedRows) {
      final map =
          row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{};

      final linha = (map['linha']?.toString() ?? '').trim();
      final idLote = (map['id_lote']?.toString() ?? '').trim();
      final nome = (map['nome']?.toString() ?? '').trim();
      final motivo = (map['motivo']?.toString() ?? '').trim();
      final erro = (map['erro']?.toString() ?? '').trim();

      buffer.writeln(
        '${_csvEscape(linha)};${_csvEscape(idLote)};${_csvEscape(nome)};${_csvEscape(motivo)};${_csvEscape(erro)}',
      );
    }

    final csvContent = '\uFEFF${buffer.toString()}';
    final bytes = utf8.encode(csvContent);
    final now = DateTime.now();
    final fileName =
        'erros_importacao_lotes_${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';

    await download(Stream.fromIterable(bytes), fileName);
  }

  Future<void> _exportFailedRowsCsvReproducao(List<dynamic> failedRows) async {
    final buffer = StringBuffer();
    buffer.writeln('Linha;ID_Reproducao;Numero_Matriz;Nome_Matriz;Motivo;Erro');

    for (final row in failedRows) {
      final map =
          row is Map ? Map<String, dynamic>.from(row) : <String, dynamic>{};

      final linha = (map['linha']?.toString() ?? '').trim();
      final idReproducao = (map['id_reproducao']?.toString() ?? '').trim();
      final numeroMatriz = (map['numeroMatriz']?.toString() ?? '').trim();
      final nomeMatriz = (map['nomeMatriz']?.toString() ?? '').trim();
      final motivo = (map['motivo']?.toString() ?? '').trim();
      final erro = (map['erro']?.toString() ?? '').trim();

      buffer.writeln(
        '${_csvEscape(linha)};${_csvEscape(idReproducao)};${_csvEscape(numeroMatriz)};${_csvEscape(nomeMatriz)};${_csvEscape(motivo)};${_csvEscape(erro)}',
      );
    }

    final csvContent = '\uFEFF${buffer.toString()}';
    final bytes = utf8.encode(csvContent);
    final now = DateTime.now();
    final fileName =
        'erros_importacao_reproducao_${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';

    await download(Stream.fromIterable(bytes), fileName);
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubMenuPainelImportarModel());

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
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
      child: Material(
        color: Colors.transparent,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Container(
          width: 250.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  final nav = Navigator.of(context);
                  nav.pop();
                  await showDialog(
                    context: nav.context,
                    builder: (dialogContext) {
                      return Dialog(
                        elevation: 0,
                        insetPadding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        alignment: const AlignmentDirectional(0.0, 0.0)
                            .resolve(Directionality.of(nav.context)),
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(dialogContext).unfocus();
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: const PpInstrucoesImportacaoWidget(),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.table_chart_outlined,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                        Text(
                          'Planilhas modelo',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ].divide(const SizedBox(width: 10.0)),
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                    final selectedFiles = await selectFiles(
                      multiFile: false,
                    );
                    if (selectedFiles != null) {
                      safeSetState(
                          () => _model.isDataUploading_uploadDataP89 = true);
                      var selectedUploadedFiles = <FFUploadedFile>[];

                      try {
                        selectedUploadedFiles = selectedFiles
                            .map((m) => FFUploadedFile(
                                  name: m.storagePath.split('/').last,
                                  bytes: m.bytes,
                                  originalFilename: m.originalFilename,
                                ))
                            .toList();
                      } finally {
                        _model.isDataUploading_uploadDataP89 = false;
                      }
                      if (selectedUploadedFiles.length ==
                          selectedFiles.length) {
                        safeSetState(() {
                          _model.uploadedLocalFile_uploadDataP89 =
                              selectedUploadedFiles.first;
                        });
                      } else {
                        safeSetState(() {});
                        return;
                      }
                    }

                    if ((_model.uploadedLocalFile_uploadDataP89.bytes
                            ?.isNotEmpty ??
                        false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Realizando upload aguarde.',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                          duration: const Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondary,
                        ),
                      );
                      _model.listaJson = [];
                      safeSetState(() {});
                      _model.json = await actions.parseCsvToJsonRebanho2(
                        _model.uploadedLocalFile_uploadDataP89,
                      );
                      _model.listaJson = _model.json!.toList().cast<dynamic>();
                      safeSetState(() {});
                      if (_model.listaJson.isEmpty) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Nenhum registro válido encontrado. Verifique se o arquivo é CSV ou XLSX válido e tente novamente.',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                            duration: const Duration(milliseconds: 5000),
                            backgroundColor: FlutterFlowTheme.of(context).error,
                          ),
                        );
                        return;
                      }
                      final importResult =
                          await actions.batchInsertSupabaseRebanho(
                        _model.listaJson.toList(),
                        FFAppState().propriedadeSelecionada.idPropriedade,
                      );
                      final bool success = importResult['success'] == true;
                      final int created =
                          (importResult['created'] as num?)?.toInt() ?? 0;
                      final int updated =
                          (importResult['updated'] as num?)?.toInt() ?? 0;
                      final int failed =
                          (importResult['failed'] as num?)?.toInt() ?? 0;
                      final List<dynamic> failedRows =
                          (importResult['failedRows'] as List<dynamic>? ?? [])
                              .toList();
                      FFAppState().refreshRebanho = true;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Upload finalizado. Criados: $created • Atualizados: $updated • Falhas: $failed'
                                : 'Upload finalizado com inconsistências. Criados: $created • Atualizados: $updated • Falhas: $failed',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                          duration: const Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondary,
                        ),
                      );

                      if (failedRows.isNotEmpty && context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            final previewRows = failedRows.take(100).toList();
                            return AlertDialog(
                              title:
                                  const Text('Linhas com erro na importação'),
                              content: SizedBox(
                                width: 500.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        failedRows.length > 100
                                            ? 'Mostrando 100 de ${failedRows.length} erros.'
                                            : 'Total de erros: ${failedRows.length}.',
                                        style:
                                            FlutterFlowTheme.of(dialogContext)
                                                .bodyMedium,
                                      ),
                                      const SizedBox(height: 12.0),
                                      ...previewRows.map((row) {
                                        final map = row is Map
                                            ? Map<String, dynamic>.from(row)
                                            : <String, dynamic>{};
                                        final linha =
                                            map['linha']?.toString() ?? '-';
                                        final numero =
                                            (map['numeroAnimal']?.toString() ??
                                                    '')
                                                .trim();
                                        final nome =
                                            (map['nome']?.toString() ?? '')
                                                .trim();
                                        final motivo =
                                            (map['motivo']?.toString() ??
                                                    map['erro']?.toString() ??
                                                    'Erro não identificado.')
                                                .trim();

                                        final numeroDisplay =
                                            numero.isEmpty ? '-' : numero;
                                        final nomeDisplay =
                                            nome.isEmpty ? '-' : nome;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Text(
                                            'Linha $linha • Número: $numeroDisplay • Nome: $nomeDisplay\nMotivo: $motivo',
                                            style: FlutterFlowTheme.of(
                                                    dialogContext)
                                                .bodyMedium,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _exportFailedRowsCsv(failedRows);
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'CSV de erros exportado com sucesso.',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 3000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao exportar CSV: $e',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Exportar CSV'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content:
                              const Text('Selecione uma propriedade primeiro'),
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
                    Navigator.pop(context);
                  }

                  safeSetState(() {});
                },
                child: Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (FFAppState().navegacao != 'rebanhos')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'assets/images/Icone_Animal_1-removebg-preview.png',
                              width: 24.0,
                              height: 24.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Text(
                          'Rebanho',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ].divide(const SizedBox(width: 10.0)),
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                    final selectedFiles = await selectFiles(
                      multiFile: false,
                    );
                    if (selectedFiles != null) {
                      safeSetState(
                          () => _model.isDataUploading_uploadDataP8979 = true);
                      var selectedUploadedFiles = <FFUploadedFile>[];

                      try {
                        selectedUploadedFiles = selectedFiles
                            .map((m) => FFUploadedFile(
                                  name: m.storagePath.split('/').last,
                                  bytes: m.bytes,
                                  originalFilename: m.originalFilename,
                                ))
                            .toList();
                      } finally {
                        _model.isDataUploading_uploadDataP8979 = false;
                      }
                      if (selectedUploadedFiles.length ==
                          selectedFiles.length) {
                        safeSetState(() {
                          _model.uploadedLocalFile_uploadDataP8979 =
                              selectedUploadedFiles.first;
                        });
                      } else {
                        safeSetState(() {});
                        return;
                      }
                    }

                    if ((_model.uploadedLocalFile_uploadDataP8979.bytes
                            ?.isNotEmpty ??
                        false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Realizando upload aguarde.',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                          duration: const Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondary,
                        ),
                      );
                      _model.listaJson = [];
                      safeSetState(() {});
                      _model.jsonLotes = await actions.parseCsvToJsonLotes(
                        _model.uploadedLocalFile_uploadDataP8979,
                      );
                      _model.listaJson =
                          _model.jsonLotes!.toList().cast<dynamic>();
                      safeSetState(() {});
                      final importResult =
                          await actions.batchInsertSupabaseLotes(
                        _model.listaJson.toList(),
                        FFAppState().propriedadeSelecionada.idPropriedade,
                      );
                      final bool success = importResult['success'] == true;
                      final List<dynamic> failedRows =
                          (importResult['failedRows'] as List<dynamic>? ?? [])
                              .toList();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Upload finalizado com sucesso'
                                : 'Upload finalizado com inconsistências. Verifique os dados da planilha.',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                          duration: const Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondary,
                        ),
                      );

                      if (failedRows.isNotEmpty && context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            final previewRows = failedRows.take(100).toList();
                            return AlertDialog(
                              title:
                                  const Text('Linhas com erro na importação'),
                              content: SizedBox(
                                width: 500.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        failedRows.length > 100
                                            ? 'Mostrando 100 de ${failedRows.length} erros.'
                                            : 'Total de erros: ${failedRows.length}.',
                                        style:
                                            FlutterFlowTheme.of(dialogContext)
                                                .bodyMedium,
                                      ),
                                      const SizedBox(height: 12.0),
                                      ...previewRows.map((row) {
                                        final map = row is Map
                                            ? Map<String, dynamic>.from(row)
                                            : <String, dynamic>{};
                                        final linha =
                                            map['linha']?.toString() ?? '-';
                                        final idLote =
                                            (map['id_lote']?.toString() ?? '')
                                                .trim();
                                        final nome =
                                            (map['nome']?.toString() ?? '')
                                                .trim();
                                        final motivo =
                                            (map['motivo']?.toString() ??
                                                    map['erro']?.toString() ??
                                                    'Erro não identificado.')
                                                .trim();

                                        final idLoteDisplay =
                                            idLote.isEmpty ? '-' : idLote;
                                        final nomeDisplay =
                                            nome.isEmpty ? '-' : nome;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Text(
                                            'Linha $linha • ID Lote: $idLoteDisplay • Nome: $nomeDisplay\nMotivo: $motivo',
                                            style: FlutterFlowTheme.of(
                                                    dialogContext)
                                                .bodyMedium,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _exportFailedRowsCsvLotes(
                                          failedRows);
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'CSV de erros exportado com sucesso.',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 3000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao exportar CSV: $e',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Exportar CSV'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content:
                              const Text('Selecione uma propriedade primeiro'),
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
                    Navigator.pop(context);
                  }

                  safeSetState(() {});
                },
                child: Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (FFAppState().navegacao != 'rebanhos')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SvgPicture.asset(
                              'assets/images/Lotes.svg',
                              width: 24.0,
                              height: 24.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Text(
                          'Lotes',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ].divide(const SizedBox(width: 10.0)),
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                    final selectedFiles = await selectFiles(
                      multiFile: false,
                    );
                    if (selectedFiles != null) {
                      safeSetState(
                          () => _model.isDataUploading_uploadDataP897 = true);
                      var selectedUploadedFiles = <FFUploadedFile>[];

                      try {
                        selectedUploadedFiles = selectedFiles
                            .map((m) => FFUploadedFile(
                                  name: m.storagePath.split('/').last,
                                  bytes: m.bytes,
                                  originalFilename: m.originalFilename,
                                ))
                            .toList();
                      } finally {
                        _model.isDataUploading_uploadDataP897 = false;
                      }
                      if (selectedUploadedFiles.length ==
                          selectedFiles.length) {
                        safeSetState(() {
                          _model.uploadedLocalFile_uploadDataP897 =
                              selectedUploadedFiles.first;
                        });
                      } else {
                        safeSetState(() {});
                        return;
                      }
                    }

                    if ((_model.uploadedLocalFile_uploadDataP897.bytes
                            ?.isNotEmpty ??
                        false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Realizando upload aguarde.',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                          ),
                          duration: const Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondary,
                        ),
                      );
                      _model.listaJson = [];
                      safeSetState(() {});
                      _model.jsonReproducao =
                          await actions.parseCsvToJsonReproducao(
                        _model.uploadedLocalFile_uploadDataP897,
                      );
                      _model.listaJson =
                          _model.jsonReproducao!.toList().cast<dynamic>();
                      safeSetState(() {});
                      final importResult =
                          await actions.batchInsertSupabaseReproducao(
                        _model.listaJson.toList(),
                        FFAppState().propriedadeSelecionada.idPropriedade,
                      );
                      final bool success = importResult['success'] == true;
                      final List<dynamic> failedRows =
                          (importResult['failedRows'] as List<dynamic>? ?? [])
                              .toList();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Upload finalizado com sucesso'
                                : 'Upload finalizado com inconsistências. Verifique os dados da planilha.',
                            style: TextStyle(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                          duration: const Duration(milliseconds: 4000),
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondary,
                        ),
                      );

                      if (failedRows.isNotEmpty && context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (dialogContext) {
                            final previewRows = failedRows.take(100).toList();
                            return AlertDialog(
                              title:
                                  const Text('Linhas com erro na importação'),
                              content: SizedBox(
                                width: 500.0,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        failedRows.length > 100
                                            ? 'Mostrando 100 de ${failedRows.length} erros.'
                                            : 'Total de erros: ${failedRows.length}.',
                                        style:
                                            FlutterFlowTheme.of(dialogContext)
                                                .bodyMedium,
                                      ),
                                      const SizedBox(height: 12.0),
                                      ...previewRows.map((row) {
                                        final map = row is Map
                                            ? Map<String, dynamic>.from(row)
                                            : <String, dynamic>{};
                                        final linha =
                                            map['linha']?.toString() ?? '-';
                                        final idReproducao =
                                            (map['id_reproducao']?.toString() ??
                                                    '')
                                                .trim();
                                        final numeroMatriz =
                                            (map['numeroMatriz']?.toString() ??
                                                    '')
                                                .trim();
                                        final nomeMatriz =
                                            (map['nomeMatriz']?.toString() ??
                                                    '')
                                                .trim();
                                        final motivo =
                                            (map['motivo']?.toString() ??
                                                    map['erro']?.toString() ??
                                                    'Erro não identificado.')
                                                .trim();

                                        final idDisplay = idReproducao.isEmpty
                                            ? '-'
                                            : idReproducao;
                                        final numeroDisplay =
                                            numeroMatriz.isEmpty
                                                ? '-'
                                                : numeroMatriz;
                                        final nomeDisplay = nomeMatriz.isEmpty
                                            ? '-'
                                            : nomeMatriz;

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Text(
                                            'Linha $linha • ID Reprodução: $idDisplay\nNº Matriz: $numeroDisplay • Nome Matriz: $nomeDisplay\nMotivo: $motivo',
                                            style: FlutterFlowTheme.of(
                                                    dialogContext)
                                                .bodyMedium,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await _exportFailedRowsCsvReproducao(
                                          failedRows);
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'CSV de erros exportado com sucesso.',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 3000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao exportar CSV: $e',
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            duration: const Duration(
                                                milliseconds: 4000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Exportar CSV'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content:
                              const Text('Selecione uma propriedade primeiro'),
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
                    Navigator.pop(context);
                  }

                  safeSetState(() {});
                },
                child: Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (FFAppState().navegacao != 'rebanhos')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SvgPicture.asset(
                              'assets/images/Reproducao.svg',
                              width: 24.0,
                              height: 24.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Text(
                          'Reprodução',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ].divide(const SizedBox(width: 10.0)),
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().propriedadeSelecionada.idPropriedade != '') {
                    Navigator.pop(context);
                    await showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return const PpImportarPesagemWidget();
                      },
                    );
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content:
                              const Text('Selecione uma propriedade primeiro'),
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
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (FFAppState().navegacao != 'rebanhos')
                          Icon(
                            Icons.monitor_weight_outlined,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                        Text(
                          'Pesagem',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                        ),
                      ].divide(const SizedBox(width: 10.0)),
                    ),
                  ),
                ),
              ),
            ].divide(const SizedBox(height: 4.0)),
          ),
        ),
      ),
    );
  }
}
