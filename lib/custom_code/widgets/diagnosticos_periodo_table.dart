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

    return list
        .map<_LinhaResumo>((e) {
          if (e is Map) {
            return _LinhaResumo.fromJson(
                e.map((k, v) => MapEntry(k.toString(), v)));
          }
          return const _LinhaResumo();
        })
        .toList();
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
      final err = _erroFromBody(body) ?? 'Não foi possível carregar o relatório.';
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
    final base = FlutterFlowTheme.of(context).bodyMedium;
    final corFundo = FlutterFlowTheme.of(context).secondaryBackground;
    final theme = Theme.of(context);
    final linhaDiv = theme.dividerColor;
    const pad = 6.0;
    final headerBg = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.07),
      corFundo,
    );
    // Soma de FixedColumnWidth (784): evita colunas a serem esmagadas.
    const double larguraTabela = 784.0;

    final bordaFina = BorderSide(color: linhaDiv, width: 1.0);
    final tabela = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        top: bordaFina,
        left: bordaFina,
        right: bordaFina,
        bottom: bordaFina,
        horizontalInside: bordaFina,
        verticalInside: bordaFina,
        borderRadius: BorderRadius.circular(8.0),
      ),
      columnWidths: const {
        0: FixedColumnWidth(112),
        1: FixedColumnWidth(72),
        2: FixedColumnWidth(72),
        3: FixedColumnWidth(72),
        4: FixedColumnWidth(72),
        5: FixedColumnWidth(100),
        6: FixedColumnWidth(100),
        7: FixedColumnWidth(84),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: headerBg),
          children: [
            _celCab(base, 'Categoria'),
            _celCab(base, 'Matrizes'),
            _celCab(base, 'Prenhez'),
            _celCab(base, 'Vazio'),
            _celCab(base, 'Outros'),
            _celCab(base, 'Prenhas de IA'),
            _celCab(base, 'Prenhas de touro'),
            _celCab(base, 'Prenhez (%)'),
          ],
        ),
        ...linhas.map((row) {
          final isTotal = row.categoria == 'Total';
          return TableRow(
            decoration: BoxDecoration(
              color: isTotal
                  ? Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.04),
                      corFundo,
                    )
                  : corFundo,
            ),
            children: [
              _celCategoria(base, row.categoria, isTotal, pad,
                  isTotal: isTotal),
              _celNum(base, row.matrizes, isTotal, pad, center: true),
              _celNum(base, row.prenhez, isTotal, pad, center: true),
              _celNum(base, row.vazio, isTotal, pad, center: true),
              _celNum(base, row.outros, isTotal, pad, center: true),
              _celNum(base, row.prenhasIa, isTotal, pad, center: true),
              _celNum(base, row.prenhasTouro, isTotal, pad, center: true),
              Padding(
                padding: const EdgeInsets.all(pad),
                child: Text(
                  '${row.prenhezPct.toStringAsFixed(2)}%',
                  textAlign: TextAlign.center,
                  style: _estiloCelda(base, isTotal),
                ),
              ),
            ],
          );
        }),
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: w, maxHeight: h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Scrollbar(
              controller: _scrollHorizontal,
              thumbVisibility: true,
              thickness: 6,
              radius: const Radius.circular(4),
              child: SingleChildScrollView(
                controller: _scrollHorizontal,
                scrollDirection: Axis.horizontal,
                child: Material(
                  color: corFundo,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: larguraTabela,
                    child: tabela,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2),
              child: Text(
                'Data do último DG: ${_fmtDataIso(dg)}',
                style: base.override(
                  fontFamily: 'Poppins',
                  fontSize: 12.0,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle _estiloCelda(TextStyle base, bool isTotal) {
    return base.override(
      fontFamily: 'Poppins',
      fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
      fontSize: 12.0,
    );
  }

  static Widget _celCab(TextStyle base, String t) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: base.override(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _celCategoria(
    TextStyle base,
    String categoria,
    bool isDestaque,
    double pad, {
    required bool isTotal,
  }) {
    final c = categoria;
    final rot = _rotuloCategoria(c);
    Text child;
    if (c == 'Vaca Multipara' || rot == 'Vaca Multipara') {
      child = Text(
        'Vaca\nMultipara',
        textAlign: TextAlign.center,
        style: _estiloCelda(base, isDestaque).copyWith(height: 1.2),
      );
    } else if (c == 'Vaca Primipara' || rot == 'Vaca Primipara') {
      child = Text(
        'Vaca\nPrimipara',
        textAlign: TextAlign.center,
        style: _estiloCelda(base, isDestaque).copyWith(height: 1.2),
      );
    } else {
      child = Text(
        rot,
        textAlign: TextAlign.center,
        style: _estiloCelda(base, isDestaque),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, pad * 1.2, pad, pad * 1.2),
      child: child,
    );
  }

  static Widget _celNum(
    TextStyle base,
    int n,
    bool isTotal,
    double pad, {
    bool center = true,
  }) {
    return Padding(
      padding: EdgeInsets.all(pad),
      child: Text(
        '$n',
        textAlign: center ? TextAlign.center : TextAlign.end,
        style: _estiloCelda(base, isTotal),
      ),
    );
  }

  String _rotuloCategoria(String c) {
    if (c == 'Novilha') return 'Novilhas';
    return c;
  }
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
