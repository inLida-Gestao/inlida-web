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

class DiagnosticosCategoriaChart extends StatefulWidget {
  const DiagnosticosCategoriaChart({
    super.key,
    this.width,
    this.height,
    required this.items,
  });

  final double? width;
  final double? height;
  final dynamic items;

  @override
  State<DiagnosticosCategoriaChart> createState() => _DiagnosticosCategoriaChartState();
}

class _DiagnosticosCategoriaChartState extends State<DiagnosticosCategoriaChart> {
  List<_DiagnosticoPorPeriodo> _parseItems(dynamic raw) {
    if (raw == null) return [];

    List<dynamic> list;

    if (raw is List) {
      list = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['items'] is List) {
          list = decoded['items'];
        } else {
          list = [];
        }
      } catch (_) {
        list = [];
      }
    } else if (raw is Map && raw['items'] is List) {
      list = raw['items'];
    } else {
      list = [];
    }

    return list.map<_DiagnosticoPorPeriodo>((e) {
      if (e is Map<String, dynamic>) {
        return _DiagnosticoPorPeriodo.fromJson(e);
      } else if (e is Map) {
        return _DiagnosticoPorPeriodo.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)));
      }
      return _DiagnosticoPorPeriodo(
          periodo: '-', label: '-', novilha: 0, primipara: 0, multipara: 0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? 300.0;
    final data = _parseItems(widget.items);

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

    // Cores para categorias (baseado na imagem: verde escuro, verde médio, verde claro)
    const novilhaColor = Color(0xFF4D6B1F); // Verde escuro
    const primiparaColor = Color(0xFF6BCB81); // Verde médio
    const multiparaColor = Color(0xFF90D9C5); // Verde claro

    final rotate = MediaQuery.of(context).size.width < 380 ? -45 : -30;

    final maxStack = data
        .map((e) => e.novilha + e.primipara + e.multipara)
      .fold<int>(0, (prev, value) => value > prev ? value : prev);

    final int interval;
    if (maxStack < 100) {
      interval = 10;
    } else if (maxStack <= 200) {
      interval = 50;
    } else if (maxStack <= 500) {
      interval = 100;
    } else {
      interval = 200;
    }

    final int computedMax = maxStack == 0
        ? interval
        : ((maxStack + interval - 1) ~/ interval) * interval;
    final int maxY = computedMax < 100 ? 100 : computedMax;

    return SizedBox(
      width: w,
      height: h,
      child: SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.top,
          iconHeight: 12,
          iconWidth: 12,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          labelRotation: rotate,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxY.toDouble(),
          interval: interval.toDouble(),
          axisLine: const AxisLine(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        series: <CartesianSeries<_DiagnosticoPorPeriodo, String>>[
          StackedColumnSeries<_DiagnosticoPorPeriodo, String>(
            name: 'Novilha',
            color: novilhaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.novilha,
          ),
          StackedColumnSeries<_DiagnosticoPorPeriodo, String>(
            name: 'Multípara',
            color: multiparaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.multipara,
          ),
          StackedColumnSeries<_DiagnosticoPorPeriodo, String>(
            name: 'Primípara',
            color: primiparaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.primipara,
          ),
        ],
      ),
    );
  }
}

class _DiagnosticoPorPeriodo {
  final String periodo;
  final String label;
  final int novilha;
  final int primipara;
  final int multipara;

  _DiagnosticoPorPeriodo({
    required this.periodo,
    required this.label,
    required this.novilha,
    required this.primipara,
    required this.multipara,
  });

  factory _DiagnosticoPorPeriodo.fromJson(Map<String, dynamic> j) => _DiagnosticoPorPeriodo(
        periodo: j['periodo'] as String? ?? '-',
        label: j['label'] as String? ?? j['periodo'] as String? ?? '-',
        novilha: (j['Novilha'] as num?)?.toInt() ?? 0,
        primipara: (j['Primípara'] as num?)?.toInt() ?? 0,
        multipara: (j['Multípara'] as num?)?.toInt() ?? 0,
      );
}
