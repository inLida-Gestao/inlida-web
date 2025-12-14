import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'empty_rebanho_model.dart';
export 'empty_rebanho_model.dart';

class EmptyRebanhoWidget extends StatefulWidget {
  const EmptyRebanhoWidget({super.key});

  @override
  State<EmptyRebanhoWidget> createState() => _EmptyRebanhoWidgetState();
}

class _EmptyRebanhoWidgetState extends State<EmptyRebanhoWidget> {
  late EmptyRebanhoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyRebanhoModel());

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

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (FFAppState().navegacao != 'rebanhos')
            Opacity(
              opacity: 0.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/images/Icone_Animal_1-removebg-preview.png',
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Opacity(
            opacity: 0.5,
            child: Text(
              'Nenhuma propriedade selecionada',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 24.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ),
        ].divide(const SizedBox(height: 8.0)),
      ),
    );
  }
}
