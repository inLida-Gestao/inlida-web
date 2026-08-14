import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/pg_lotes/lote_ordenacao.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal simples para escolher o campo e a direção de ordenação da lista de
/// animais nas telas de criar/editar lote. Retorna um [OrdenacaoLote] via
/// `Navigator.pop(context, resultado)`.
class PpOrdenarRebanhoWidget extends StatefulWidget {
  const PpOrdenarRebanhoWidget({
    super.key,
    this.campoAtual = '',
    this.ascAtual = true,
  });

  final String campoAtual;
  final bool ascAtual;

  @override
  State<PpOrdenarRebanhoWidget> createState() =>
      _PpOrdenarRebanhoWidgetState();
}

class _PpOrdenarRebanhoWidgetState extends State<PpOrdenarRebanhoWidget> {
  late String _campo;
  late bool _asc;

  @override
  void initState() {
    super.initState();
    _campo = widget.campoAtual;
    _asc = widget.ascAtual;
  }

  void _selecionarCampo(String campo) {
    setState(() => _campo = campo);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 320.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ordenar',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.close_rounded,
                      color: FlutterFlowTheme.of(context).secondary,
                      size: 24.0,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              _buildOpcaoCampo(
                context,
                label: 'Número do animal',
                campo: kOrdenarNumero,
              ),
              _buildOpcaoCampo(
                context,
                label: 'Data de nascimento',
                campo: kOrdenarNascimento,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Direção',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodySmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondary,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: _buildOpcaoDirecao(
                      context,
                      label: 'Crescente',
                      icon: Icons.arrow_upward_rounded,
                      asc: true,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildOpcaoDirecao(
                      context,
                      label: 'Decrescente',
                      icon: Icons.arrow_downward_rounded,
                      asc: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, const OrdenacaoLote('', true)),
                    child: Text(
                      'Limpar ordenação',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).error,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      OrdenacaoLote(_campo, _asc),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcaoCampo(
    BuildContext context, {
    required String label,
    required String campo,
  }) {
    final selecionado = _campo == campo;
    return InkWell(
      onTap: () => _selecionarCampo(campo),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              selecionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selecionado
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondary,
              size: 20.0,
            ),
            const SizedBox(width: 12.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight:
                          selecionado ? FontWeight.w600 : FontWeight.w400,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoDirecao(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool asc,
  }) {
    final selecionado = _asc == asc;
    return InkWell(
      onTap: () => setState(() => _asc = asc),
      child: Container(
        padding:
            const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
        decoration: BoxDecoration(
          color: selecionado
              ? FlutterFlowTheme.of(context).primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100.0),
          border: Border.all(
            color: selecionado
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).customColor12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selecionado
                  ? FlutterFlowTheme.of(context).primary
                  : FlutterFlowTheme.of(context).secondary,
              size: 16.0,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    ),
                    color: selecionado
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondary,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
