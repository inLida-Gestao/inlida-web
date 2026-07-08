import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../data/piquete_backend_store.dart';
import '../prototype/piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modal_excluir_piquete_model.dart';
export 'modal_excluir_piquete_model.dart';

class ModalExcluirPiqueteWidget extends StatefulWidget {
  const ModalExcluirPiqueteWidget({
    super.key,
    required this.idPiquete,
    required this.piqueteNome,
  });

  final String idPiquete;
  final String piqueteNome;

  @override
  State<ModalExcluirPiqueteWidget> createState() =>
      _ModalExcluirPiqueteWidgetState();
}

class _ModalExcluirPiqueteWidgetState extends State<ModalExcluirPiqueteWidget> {
  late ModalExcluirPiqueteModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ModalExcluirPiqueteModel());
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
      child: Container(
        width: 520.0,
        decoration: BoxDecoration(
          color: kPiqueteSurface,
          borderRadius: BorderRadius.circular(kPiqueteRadius),
          border: Border.all(color: kPiqueteBorder),
          boxShadow: const [
            BoxShadow(
              blurRadius: 24,
              color: Color(0x2410281C),
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: kPiqueteDangerSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: kPiqueteDanger,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Excluir piquete',
                          style: GoogleFonts.poppins(
                            color: kPiqueteTextStrong,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tem certeza que deseja excluir o piquete ${widget.piqueteNome}? Essa ação é irreversível.',
                          style: GoogleFonts.poppins(
                            color: kPiqueteTextMuted,
                            fontSize: 14.0,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPiqueteTextMuted,
                      side: const BorderSide(color: kPiqueteBorder),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kPiqueteRadius),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await PiqueteBackendStore.instance
                            .deletePiquete(widget.idPiquete);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Piquete excluído',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            duration: const Duration(milliseconds: 4000),
                            backgroundColor: FlutterFlowTheme.of(context).error,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              PiqueteBackendStore.instance.errorMessage ??
                                  'Não foi possível excluir o piquete.',
                            ),
                            backgroundColor: FlutterFlowTheme.of(context).error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPiqueteDanger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kPiqueteRadius),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Excluir'),
                  ),
                ].divide(const SizedBox(width: 12.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
