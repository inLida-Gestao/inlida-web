// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class DiagnosticosPeriodoTable extends StatefulWidget {
  const DiagnosticosPeriodoTable({
    super.key,
    this.width,
    this.height,
    this.jsonBody,
  });

  final double? width;
  final double? height;
  final dynamic jsonBody;

  @override
  State<DiagnosticosPeriodoTable> createState() =>
      _DiagnosticosPeriodoTableState();
}

class _DiagnosticosPeriodoTableState extends State<DiagnosticosPeriodoTable> {
  final ScrollController _scrollHorizontal = ScrollController();
  int? _hoveredRowIndex;

  @override
  void dispose() {
    _scrollHorizontal.dispose();
    super.dispose();
  }

  String _fmtDataIso(String? s) {
    if (s == null || s.isEmpty) return '—';
    final p = s.trim();
    if (p.length < 10) return p;
    final y = p.substring(0, 4);
    final m = p.substring(5, 7);
    final d = p.substring(8, 10);
    return '$d/$m/$y';
  }

  List<_LinhaResumo> _parseLinhas(dynamic raw) {
    dynamic list;
    if (raw is Map) {
      list = raw['linhas'];
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          list = decoded['linhas'];
        } else if (decoded is List) {
          list = decoded;
        }
      } catch (_) {
        return [];
      }
    } else {
      list = getJsonField(raw, r'''$.linhas''', true);
    }

    if (list is! List) {
      return [];
    }

    return list.map<_LinhaResumo>((e) {
      if (e is Map) {
        return _LinhaResumo.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)));
      }
      return const _LinhaResumo();
    }).toList();
  }

  String? _dataUltimoFromBody(dynamic b) {
    if (b == null) return null;
    if (b is String) {
      return getJsonField(b, r'''$.data_ultimo_dg''') as String?;
    }
    if (b is Map) {
      return b['data_ultimo_dg'] as String?;
    }
    return getJsonField(b, r'''$.data_ultimo_dg''') as String?;
  }

  bool? _okFromBody(dynamic b) {
    if (b is Map && b.containsKey('ok')) {
      return b['ok'] as bool?;
    }
    return getJsonField(b, r'''$.ok''') as bool?;
  }

  String? _erroFromBody(dynamic b) {
    if (b is Map && b['error'] != null) {
      return b['error'] as String?;
    }
    return getJsonField(b, r'''$.error''') as String?;
  }

  double _heightForParent(BoxConstraints c) {
    final h = widget.height;
    if (h != null && h.isFinite && !h.isNegative) {
      return h;
    }
    if (c.maxHeight.isFinite && c.maxHeight < double.infinity) {
      return c.maxHeight;
    }
    return 300.0;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = _heightForParent(constraints);
        return _buildContent(context, w, h);
      },
    );
  }

  Widget _buildContent(BuildContext context, double w, double h) {
    final body = widget.jsonBody;

    if (_okFromBody(body) == false) {
      final err =
          _erroFromBody(body) ?? 'Não foi possível carregar o relatório.';
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text(
            err,
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ),
      );
    }

    final linhas = _parseLinhas(body);
    if (linhas.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text(
            'Sem dados no período.',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ),
      );
    }

    final dg = _dataUltimoFromBody(body);
    final totalRow = linhas.where((row) => _isTotalRow(row)).firstOrNull;
    final categoryRows = linhas.where((row) => !_isTotalRow(row)).toList();
    const double larguraTabela = 784.0;

    return SizedBox(
      width: w,
      height: h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Scrollbar(
              controller: _scrollHorizontal,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(4),
              child: SingleChildScrollView(
                controller: _scrollHorizontal,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: larguraTabela,
                  child: _tableFrame(
                    context,
                    categoryRows: categoryRows,
                    totalRow: totalRow,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              text: 'Data do último DG: ',
              children: [
                TextSpan(
                  text: _fmtDataIso(dg),
                  style: const TextStyle(
                    color: Color(0xFF5B655D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: const Color(0xFF9AA39B),
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _tableFrame(
    BuildContext context, {
    required List<_LinhaResumo> categoryRows,
    required _LinhaResumo? totalRow,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFECEFEC)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _headerRow(context),
          ...categoryRows.asMap().entries.map(
                (entry) => _dataRow(
                  context,
                  entry.value,
                  rowIndex: entry.key,
                  isLast:
                      totalRow == null && entry.key == categoryRows.length - 1,
                ),
              ),
          if (totalRow != null) _totalRow(context, totalRow),
        ],
      ),
    );
  }

  Widget _headerRow(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F8F5),
        border: Border(
          bottom: BorderSide(color: Color(0xFFCFE2D5), width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerCell(context, 'Categoria', flex: 15, align: TextAlign.start),
          _headerCell(context, 'Matrizes'),
          _headerCell(context, 'Prenhez'),
          _headerCell(context, 'Vazio'),
          _headerCell(context, 'Outros'),
          _headerCell(context, 'Prenhas de IA'),
          _headerCell(context, 'Prenhas de touro'),
          _headerCell(context, 'Prenhez (%)', flex: 11, align: TextAlign.end),
        ],
      ),
    );
  }

  Widget _dataRow(
    BuildContext context,
    _LinhaResumo row, {
    required int rowIndex,
    required bool isLast,
  }) {
    final hovered = _hoveredRowIndex == rowIndex;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRowIndex = rowIndex),
      onExit: (_) => setState(() => _hoveredRowIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: hovered ? const Color(0xFFFAFCFB) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : const Color(0xFFF1F4F1),
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: _rowContent(context, row),
        ),
      ),
    );
  }

  Widget _totalRow(BuildContext context, _LinhaResumo row) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6F1),
        border: Border(
          top: BorderSide(color: Color(0xFFCFE2D5), width: 2),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50.0),
        child: _rowContent(context, row, isTotal: true),
      ),
    );
  }

  Widget _rowContent(
    BuildContext context,
    _LinhaResumo row, {
    bool isTotal = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _categoryCell(context, row.categoria, isTotal: isTotal),
        _numberCell(context, row.matrizes, isTotal: isTotal),
        _numberCell(context, row.prenhez, isTotal: isTotal),
        _numberCell(context, row.vazio, isTotal: isTotal),
        _numberCell(context, row.outros, isTotal: isTotal),
        _numberCell(context, row.prenhasIa, isTotal: isTotal),
        _numberCell(context, row.prenhasTouro, isTotal: isTotal),
        _percentCell(context, row.prenhezPct, isTotal: isTotal),
      ],
    );
  }

  Widget _headerCell(
    BuildContext context,
    String text, {
    int flex = 10,
    TextAlign align = TextAlign.center,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          align == TextAlign.start ? 16 : 8,
          12,
          align == TextAlign.end ? 12 : 8,
          12,
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FlutterFlowTheme.of(context)
              .bodyMedium
              .override(
                fontFamily: 'Poppins',
                color: const Color(0xFF5B7065),
                fontSize: 11.0,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w700,
              )
              .copyWith(height: 1.25),
        ),
      ),
    );
  }

  Widget _categoryCell(
    BuildContext context,
    String categoria, {
    required bool isTotal,
  }) {
    return Expanded(
      flex: 15,
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(16, isTotal ? 14 : 13, 12, isTotal ? 14 : 13),
        child: Text(
          isTotal ? 'Total' : _rotuloCategoria(categoria),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: FlutterFlowTheme.of(context)
              .bodyMedium
              .override(
                fontFamily: 'Poppins',
                color:
                    isTotal ? const Color(0xFF145232) : const Color(0xFF26302B),
                fontSize: 13.5,
                letterSpacing: 0.0,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              )
              .copyWith(height: 1.25),
        ),
      ),
    );
  }

  Widget _numberCell(
    BuildContext context,
    int value, {
    required bool isTotal,
  }) {
    return Expanded(
      flex: 10,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isTotal ? 14 : 13,
        ),
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Poppins',
                color: value > 0
                    ? const Color(0xFF145232)
                    : const Color(0xFF9AA39B),
                fontSize: 13.5,
                letterSpacing: 0.0,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _percentCell(
    BuildContext context,
    double percent, {
    required bool isTotal,
  }) {
    final colors = _percentColors(percent);
    return Expanded(
      flex: 11,
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(8, isTotal ? 14 : 13, 12, isTotal ? 14 : 13),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(minWidth: 64),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              '${percent.toStringAsFixed(2)}%',
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: colors.foreground,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isTotalRow(_LinhaResumo row) {
    return row.categoria.trim().toLowerCase() == 'total';
  }

  _PercentColors _percentColors(double percent) {
    if (percent > 70) {
      return const _PercentColors(
        background: Color(0xFFE6F6EE),
        foreground: Color(0xFF147A45),
      );
    }
    if (percent >= 40) {
      return const _PercentColors(
        background: Color(0xFFF7E4BE),
        foreground: Color(0xFF8A5A0E),
      );
    }
    return const _PercentColors(
      background: Color(0xFFFCEAE8),
      foreground: Color(0xFFC0392B),
    );
  }

  String _rotuloCategoria(String c) {
    if (c == 'Novilha') return 'Novilhas';
    return c;
  }
}

class _PercentColors {
  const _PercentColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

class _LinhaResumo {
  const _LinhaResumo({
    this.categoria = '',
    this.matrizes = 0,
    this.prenhez = 0,
    this.vazio = 0,
    this.outros = 0,
    this.prenhasIa = 0,
    this.prenhasTouro = 0,
    this.prenhezPct = 0.0,
  });

  final String categoria;
  final int matrizes;
  final int prenhez;
  final int vazio;
  final int outros;
  final int prenhasIa;
  final int prenhasTouro;
  final double prenhezPct;

  factory _LinhaResumo.fromJson(Map<String, dynamic> j) {
    double pct = 0.0;
    final pr = j['prenhez_pct'];
    if (pr is num) {
      pct = pr.toDouble();
    }
    return _LinhaResumo(
      categoria: j['categoria'] as String? ?? '',
      matrizes: (j['matrizes'] as num?)?.toInt() ?? 0,
      prenhez: (j['prenhez'] as num?)?.toInt() ?? 0,
      vazio: (j['vazio'] as num?)?.toInt() ?? 0,
      outros: (j['outros'] as num?)?.toInt() ?? 0,
      prenhasIa: (j['prenhas_ia'] as num?)?.toInt() ?? 0,
      prenhasTouro: (j['prenhas_touro'] as num?)?.toInt() ?? 0,
      prenhezPct: pct,
    );
  }
}
