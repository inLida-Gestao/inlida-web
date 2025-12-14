import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/sanidade/cc_add_sanidade_animal/cc_add_sanidade_animal_widget.dart';
import '/sanidade/cc_add_sanidade_lote/cc_add_sanidade_lote_widget.dart';
import 'package:flutter/material.dart';
import 'modal_add_sanidade_model.dart';
export 'modal_add_sanidade_model.dart';

class ModalAddSanidadeWidget extends StatefulWidget {
  const ModalAddSanidadeWidget({
    super.key,
    required this.action,
  });

  final Future Function(String? page)? action;

  @override
  State<ModalAddSanidadeWidget> createState() => _ModalAddSanidadeWidgetState();
}

class _ModalAddSanidadeWidgetState extends State<ModalAddSanidadeWidget> {
  late ModalAddSanidadeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalAddSanidadeModel());

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
              offset: Offset(2.0, 2.0),
            )
          ],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return Dialog(
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      alignment: const AlignmentDirectional(0, 0),
                      child: GestureDetector(
                        onTap: () => FocusScope.of(dialogContext).unfocus(),
                        child: CcAddSanidadeAnimalWidget(
                          action: widget.action,
                        ),
                      ),
                    );
                  },
                );
                await widget.action?.call('pgSanidade');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.add,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      'Animal',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Poppins',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) {
                    return Dialog(
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      alignment: const AlignmentDirectional(0, 0),
                      child: GestureDetector(
                        onTap: () => FocusScope.of(dialogContext).unfocus(),
                        child: CcAddSanidadeLoteWidget(
                          action: widget.action,
                        ),
                      ),
                    );
                  },
                );
                await widget.action?.call('pgSanidade');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.add,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      'Lote',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Poppins',
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
