import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
                      await actions.batchInsertSupabaseRebanho(
                        _model.listaJson.toList(),
                        FFAppState().propriedadeSelecionada.idPropriedade,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Upload finalizado com sucesso',
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
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content: const Text('Selecione uma propriedade primeiro'),
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
                      await actions.batchInsertSupabaseLotes(
                        _model.listaJson.toList(),
                        FFAppState().propriedadeSelecionada.idPropriedade,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Upload finalizado com sucesso',
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
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content: const Text('Selecione uma propriedade primeiro'),
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
                      await actions.batchInsertSupabaseReproducao(
                        _model.listaJson.toList(),
                        FFAppState().propriedadeSelecionada.idPropriedade,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Upload finalizado com sucesso',
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
                    }
                  } else {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content: const Text('Selecione uma propriedade primeiro'),
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
            ].divide(const SizedBox(height: 4.0)),
          ),
        ),
      ),
    );
  }
}
