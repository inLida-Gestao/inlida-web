import '/flutter_flow/flutter_flow_theme.dart';
import '/pg_lotes/lote_lista_config.dart';
import 'package:flutter/material.dart';

class LoteListaPaginacaoWidget extends StatelessWidget {
  const LoteListaPaginacaoWidget({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final int page;
  final int pageSize;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final normalizedPageSize = normalizarLoteAnimaisPageSize(pageSize);
    final normalizedPage = ajustarPaginaLote(
      page: page,
      totalItems: totalItems,
      pageSize: normalizedPageSize,
    );
    final totalPages = calcularTotalPaginasLote(
      totalItems: totalItems,
      pageSize: normalizedPageSize,
    );
    final range = faixaPaginaLote(
      page: normalizedPage,
      totalItems: totalItems,
      pageSize: normalizedPageSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${range.start}–${range.end} de $totalItems',
                style: FlutterFlowTheme.of(context).bodySmall,
              ),
            ),
            SizedBox(
              height: 44.0,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: normalizedPageSize,
                  borderRadius: BorderRadius.circular(8.0),
                  items: loteAnimaisPageSizeOptions
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value por página'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null && value != normalizedPageSize) {
                      onPageSizeChanged(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _PaginationButton(
              tooltip: 'Primeira página',
              icon: Icons.keyboard_double_arrow_left,
              enabled: normalizedPage > 1,
              onPressed: () => onPageChanged(1),
            ),
            _PaginationButton(
              tooltip: 'Página anterior',
              icon: Icons.keyboard_arrow_left,
              enabled: normalizedPage > 1,
              onPressed: () => onPageChanged(normalizedPage - 1),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 64.0),
              child: Text(
                '$normalizedPage de $totalPages',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
            ),
            _PaginationButton(
              tooltip: 'Próxima página',
              icon: Icons.keyboard_arrow_right,
              enabled: normalizedPage < totalPages,
              onPressed: () => onPageChanged(normalizedPage + 1),
            ),
            _PaginationButton(
              tooltip: 'Última página',
              icon: Icons.keyboard_double_arrow_right,
              enabled: normalizedPage < totalPages,
              onPressed: () => onPageChanged(totalPages),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 44.0, height: 44.0),
      padding: EdgeInsets.zero,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 24.0),
    );
  }
}
