import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class LoteListaAbasWidget extends StatelessWidget {
  const LoteListaAbasWidget({
    super.key,
    required this.selectedIndex,
    required this.disponiveisCount,
    required this.noLoteCount,
    required this.onChanged,
  });

  final int selectedIndex;
  final int disponiveisCount;
  final int noLoteCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).customColor2,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          _LoteListaAba(
            label: 'Disponíveis ($disponiveisCount)',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _LoteListaAba(
            label: 'No lote ($noLoteCount)',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _LoteListaAba extends StatelessWidget {
  const _LoteListaAba({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: onTap,
          child: Container(
            height: 48.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? FlutterFlowTheme.of(context).primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: selected
                        ? FlutterFlowTheme.of(context).info
                        : FlutterFlowTheme.of(context).primaryText,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
