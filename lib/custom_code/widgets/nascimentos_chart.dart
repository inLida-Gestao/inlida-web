// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Modelo unificado que aceita QUALQUER FORMATO:
/// - machos / femeas / total (Edge Functions novas)
/// - proj_6m / proj_8m para projeções antigas
class _PeriodoUniversal {
  final String mes;
  final String label;
  final int machos;
  final int femeas;
  final int total;

  _PeriodoUniversal({
    required this.mes,
    required this.label,
    required this.machos,
    required this.femeas,
    required this.total,
  });

  factory _PeriodoUniversal.fromJson(Map<String, dynamic> j) {
    //
    // FORMATO 1 — Edge Functions novas (machos/femeas/total)
    //
    if (j.containsKey('machos') ||
        j.containsKey('femeas') ||
        j.containsKey('total')) {
      return _PeriodoUniversal(
        mes: j['bucket_ini'] as String? ?? '1970-01-01',
        label: j['label'] as String? ?? '-',
        machos: (j['machos'] as num? ?? 0).toInt(),
        femeas: (j['femeas'] as num? ?? 0).toInt(),
        total: (j['total'] as num? ?? 0).toInt(),
      );
    }

    //
    // FORMATO 2 — Projeções antigas (proj_6m + proj_8m)
    //
    final m6 = (j['proj_6m_machos'] as num? ?? 0).toInt();
    final f6 = (j['proj_6m_femeas'] as num? ?? 0).toInt();
    final m8 = (j['proj_8m_machos'] as num? ?? 0).toInt();
    final f8 = (j['proj_8m_femeas'] as num? ?? 0).toInt();

    return _PeriodoUniversal(
      mes: j['mes'] as String? ?? '1970-01-01',
      label: j['label'] as String? ?? '-',
      machos: m6 + m8,
      femeas: f6 + f8,
      total: m6 + m8 + f6 + f8,
    );
  }
}

class NascimentosChart extends StatefulWidget {
  const NascimentosChart({
    super.key,
    this.width,
    this.height,
    this.items,
    this.titulo,
  });

  final double? width;
  final double? height;
  final dynamic items;
  final String? titulo;

  @override
  State<NascimentosChart> createState() => _NascimentosChartState();
}

class _NascimentosChartState extends State<NascimentosChart> {
  DateTime _safeParse(String s) {
    return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  double _resolvedHeight(BoxConstraints constraints) {
    if (widget.height != null) return widget.height!;
    if (constraints.hasBoundedHeight && constraints.maxHeight.isFinite) {
      final h = constraints.maxHeight;
      if (h > 0) return h;
    }
    return 280.0;
  }

  double? _resolvedWidth(BoxConstraints constraints) {
    if (widget.width != null) return widget.width!;
    if (constraints.hasBoundedWidth && constraints.maxWidth.isFinite) {
      final w = constraints.maxWidth;
      if (w > 0) return w;
    }
    return null;
  }

  List<_PeriodoUniversal> _parseItems(dynamic raw) {
    if (raw == null) return const <_PeriodoUniversal>[];

    List<dynamic> listDyn;

    // RAW pode ser List, Map ou String JSON
    if (raw is List) {
      listDyn = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          listDyn = decoded;
        } else if (decoded is Map && decoded['items'] is List) {
          listDyn = decoded['items'] as List;
        } else {
          listDyn = const [];
        }
      } catch (_) {
        listDyn = const [];
      }
    } else if (raw is Map && raw['items'] is List) {
      listDyn = raw['items'] as List;
    } else {
      listDyn = const [];
    }

    final items = listDyn.map<_PeriodoUniversal>((e) {
      if (e is Map<String, dynamic>) {
        return _PeriodoUniversal.fromJson(e);
      } else if (e is Map) {
        return _PeriodoUniversal.fromJson(
          e.map((k, v) => MapEntry(k.toString(), v)),
        );
      } else if (e is String) {
        return _PeriodoUniversal.fromJson(jsonDecode(e));
      } else {
        return _PeriodoUniversal(
          mes: '1970-01-01',
          label: '-',
          machos: 0,
          femeas: 0,
          total: 0,
        );
      }
    }).toList()
      ..sort((a, b) => _safeParse(a.mes).compareTo(_safeParse(b.mes)));

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final data = _parseItems(widget.items);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = _resolvedWidth(constraints);
        final h = _resolvedHeight(constraints);

        if (data.isEmpty) {
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

        const machosColor = Color(0xFF3B82F6);
        const femeasColor = Color(0xFFE11D8D);
        const totalColor = Colors.deepPurple;

        final rotate = MediaQuery.of(context).size.width < 380 ? -55 : -30;

        return Column(
          children: [
            if (widget.titulo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.titulo!,
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
              ),
            SizedBox(
              width: w,
              height: h,
              child: SfCartesianChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.top,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                primaryXAxis: CategoryAxis(
                  labelRotation: rotate,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: const NumericAxis(
                  minimum: 0,
                  majorGridLines: MajorGridLines(width: 0),
                  axisLine: AxisLine(width: 0),
                ),
                series: <CartesianSeries<_PeriodoUniversal, String>>[
                  StackedColumnSeries<_PeriodoUniversal, String>(
                    name: 'Machos',
                    color: machosColor,
                    dataSource: data,
                    xValueMapper: (p, _) => p.label,
                    yValueMapper: (p, _) => p.machos,
                  ),
                  StackedColumnSeries<_PeriodoUniversal, String>(
                    name: 'Fêmeas',
                    color: femeasColor,
                    dataSource: data,
                    xValueMapper: (p, _) => p.label,
                    yValueMapper: (p, _) => p.femeas,
                  ),
                  ColumnSeries<_PeriodoUniversal, String>(
                    name: 'Total',
                    color: totalColor,
                    dataSource: data,
                    xValueMapper: (p, _) => p.label,
                    yValueMapper: (p, _) => p.total,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
