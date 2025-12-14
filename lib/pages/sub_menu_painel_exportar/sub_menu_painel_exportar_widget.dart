import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sub_menu_painel_exportar_model.dart';
export 'sub_menu_painel_exportar_model.dart';

class SubMenuPainelExportarWidget extends StatefulWidget {
  const SubMenuPainelExportarWidget({super.key});

  @override
  State<SubMenuPainelExportarWidget> createState() =>
      _SubMenuPainelExportarWidgetState();
}

class _SubMenuPainelExportarWidgetState
    extends State<SubMenuPainelExportarWidget> {
  late SubMenuPainelExportarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubMenuPainelExportarModel());

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
                  if (FFAppState().propriedadeSelecionada.idPropriedade == '') {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content: const Text('Selecione uma propriedade primeiro.'),
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Exportando aguarde.',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        ),
                        duration: const Duration(milliseconds: 2000),
                        backgroundColor: FlutterFlowTheme.of(context).secondary,
                      ),
                    );
                    await actions.exportRebanhoExcel(
                      'rebanho_${FFAppState().propriedadeSelecionada.nome}_${dateTimeFormat(
                        "d_M_yy_HH_mm_ss",
                        getCurrentTimestamp,
                        locale: FFLocalizations.of(context).languageCode,
                      )}',
                      FFAppState().propriedadeSelecionada.idPropriedade,
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
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
                tabletLandscape: false,
                desktop: false,
              ))
                Container(
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
              InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  if (FFAppState().propriedadeSelecionada.idPropriedade == '') {
                    await showDialog(
                      context: context,
                      builder: (alertDialogContext) {
                        return AlertDialog(
                          content: const Text('Selecione uma propriedade primeiro.'),
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Exportando aguarde.',
                          style: TextStyle(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        ),
                        duration: const Duration(milliseconds: 2000),
                        backgroundColor: FlutterFlowTheme.of(context).secondary,
                      ),
                    );
                    await actions.exportReproducaoExcel(
                      'reproducao_${FFAppState().propriedadeSelecionada.nome}_${dateTimeFormat(
                        "d_M_yy_HH_mm_ss",
                        getCurrentTimestamp,
                        locale: FFLocalizations.of(context).languageCode,
                      )}',
                      FFAppState().propriedadeSelecionada.idPropriedade,
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
