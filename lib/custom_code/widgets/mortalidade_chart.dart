// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

//
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Modelo unificado para o período
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
    return _PeriodoUniversal(
      mes: j['bucket_ini'] as String? ?? '1970-01-01',
      label: j['label'] as String? ?? '-',
      machos: (j['machos'] as num? ?? 0).toInt(),
      femeas: (j['femeas'] as num? ?? 0).toInt(),
      total: (j['total'] as num? ?? 0).toInt(),
    );
  }
}

class MortalidadeChart extends StatefulWidget {
  const MortalidadeChart({
    super.key,
    this.width,
    this.height,
    required this.items,
    this.titulo,
  });

  final double? width;
  final double? height;
  final dynamic items;
  final String? titulo;

  @override
  State<MortalidadeChart> createState() => _MortalidadeChartState();
}

class _MortalidadeChartState extends State<MortalidadeChart> {
  DateTime _safeParse(String s) {
    return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  List<_PeriodoUniversal> _parseItems(dynamic raw) {
    if (raw == null) return const <_PeriodoUniversal>[];

    List<dynamic> listDyn;

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
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? 280.0;

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
  }
}
