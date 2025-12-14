// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class _PeriodoRebanho {
  final String label;
  final int machos;
  final int femeas;
  final int total;

  _PeriodoRebanho({
    required this.label,
    required this.machos,
    required this.femeas,
    required this.total,
  });

  factory _PeriodoRebanho.fromJson(Map<String, dynamic> j) {
    final label = (j['mes_ano_texto'] ?? j['label'] ?? '').toString();

    final machos = (j['quantidade_macho'] as num?)?.toInt() ??
        (j['machos'] as num?)?.toInt() ??
        0;
    final femeas = (j['quantidade_femea'] as num?)?.toInt() ??
        (j['femeas'] as num?)?.toInt() ??
        0;
    final total = (j['quantidade_total'] as num?)?.toInt() ??
        (j['total'] as num?)?.toInt() ??
        (machos + femeas);

    return _PeriodoRebanho(
      label: label.isEmpty ? '-' : label,
      machos: machos,
      femeas: femeas,
      total: total,
    );
  }
}

class RebanhoPeriodoChart extends StatefulWidget {
  const RebanhoPeriodoChart({
    super.key,
    this.width,
    this.height,
    this.items,
  });

  final double? width;
  final double? height;
  final dynamic items;

  @override
  State<RebanhoPeriodoChart> createState() => _RebanhoPeriodoChartState();
}

class _RebanhoPeriodoChartState extends State<RebanhoPeriodoChart> {
  List<_PeriodoRebanho> _parseItems(dynamic raw) {
    if (raw == null) return const <_PeriodoRebanho>[];

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

    return listDyn.map<_PeriodoRebanho>((e) {
      if (e is Map<String, dynamic>) return _PeriodoRebanho.fromJson(e);
      if (e is Map) {
        return _PeriodoRebanho.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)));
      }
      if (e is String) {
        try {
          final m = jsonDecode(e) as Map<String, dynamic>;
          return _PeriodoRebanho.fromJson(m);
        } catch (_) {
          return _PeriodoRebanho(label: '-', machos: 0, femeas: 0, total: 0);
        }
      }
      return _PeriodoRebanho(label: '-', machos: 0, femeas: 0, total: 0);
    }).toList();
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

    return SizedBox(
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
        series: <CartesianSeries<_PeriodoRebanho, String>>[
          StackedColumnSeries<_PeriodoRebanho, String>(
            name: 'Machos',
            color: machosColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.machos,
          ),
          StackedColumnSeries<_PeriodoRebanho, String>(
            name: 'Fêmeas',
            color: femeasColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.femeas,
          ),
          ColumnSeries<_PeriodoRebanho, String>(
            name: 'Total',
            color: totalColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.total,
          ),
        ],
      ),
    );
  }
}
