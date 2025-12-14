import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/propriedades/edit_propriedade/edit_propriedade_widget.dart';
import '/propriedades/excluir_propriedade/excluir_propriedade_widget.dart';
import '/propriedades/view_propriedade/view_propriedade_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sub_menu_prop_model.dart';
export 'sub_menu_prop_model.dart';

class SubMenuPropWidget extends StatefulWidget {
  const SubMenuPropWidget({
    super.key,
    required this.idPropriedade,
  });

  final String? idPropriedade;

  @override
  State<SubMenuPropWidget> createState() => _SubMenuPropWidgetState();
}

class _SubMenuPropWidgetState extends State<SubMenuPropWidget> {
  late SubMenuPropModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SubMenuPropModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136.0,
      height: 168.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
          )
        ],
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              FFAppState().propriedadeEdit = widget.idPropriedade!;
              Navigator.pop(context);
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                isDismissible: false,
                enableDrag: false,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: const ViewPropriedadeWidget(),
                  );
                },
              ).then((value) => safeSetState(() {}));
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
                    Icon(
                      Icons.remove_red_eye_outlined,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 22.0,
                    ),
                    Text(
                      'Visualizar',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
              FFAppState().propriedadeEdit = widget.idPropriedade!;
              _model.updatePage(() {});
              Navigator.pop(context);
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                isDismissible: false,
                enableDrag: false,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: const EditPropriedadeWidget(),
                  );
                },
              ).then((value) => safeSetState(() {}));
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
                    Icon(
                      Icons.edit_outlined,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 22.0,
                    ),
                    Text(
                      'Editar',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
          Builder(
            builder: (context) => InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return Dialog(
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      alignment: const AlignmentDirectional(0.0, 0.0)
                          .resolve(Directionality.of(context)),
                      child: ExcluirPropriedadeWidget(
                        idPropriedade: widget.idPropriedade!,
                      ),
                    );
                  },
                );
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
                      FaIcon(
                        FontAwesomeIcons.trashAlt,
                        color: FlutterFlowTheme.of(context).error,
                        size: 20.0,
                      ),
                      Text(
                        'Excluir',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).error,
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
          ),
        ],
      ),
    );
  }
}
