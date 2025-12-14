// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class PartosCategoriaChart extends StatefulWidget {
  const PartosCategoriaChart({
    super.key,
    this.width,
    this.height,
    required this.items,
  });

  final double? width;
  final double? height;
  final dynamic items;

  @override
  State<PartosCategoriaChart> createState() => _PartosCategoriaChartState();
}

class _PartosCategoriaChartState extends State<PartosCategoriaChart> {
  List<_PartosPorMes> _parseItems(dynamic raw) {
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

    return list.map<_PartosPorMes>((e) {
      if (e is Map<String, dynamic>) {
        return _PartosPorMes.fromJson(e);
      } else if (e is Map) {
        return _PartosPorMes.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)));
      }
      return _PartosPorMes(
          mes: '-', label: '-', novilha: 0, primipara: 0, multipara: 0);
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
        child: const Center(child: Text('Sem dados disponíveis')),
      );
    }

    // Cores para categorias
    const novilhaColor = Color(0xFF4D6B1F);
    const primiparaColor = Color(0xFF6BCB81);
    const multiparaColor = Color(0xFF90D9C5);
    const totalColor = Color(0xFF6B4DAF); // Roxo para Total

    final rotate = MediaQuery.of(context).size.width < 380 ? -45 : -30;

    return SizedBox(
      width: w,
      height: h,
      child: SfCartesianChart(
        title: const ChartTitle(
          text: 'Partos por categoria no período',
          alignment: ChartAlignment.center,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        primaryYAxis: const NumericAxis(
          minimum: 0,
          axisLine: AxisLine(width: 0),
          majorGridLines: MajorGridLines(width: 0),
        ),
        series: <CartesianSeries<_PartosPorMes, String>>[
          ColumnSeries<_PartosPorMes, String>(
            name: 'Novilha',
            color: novilhaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.novilha,
          ),
          ColumnSeries<_PartosPorMes, String>(
            name: 'Primípara',
            color: primiparaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.primipara,
          ),
          ColumnSeries<_PartosPorMes, String>(
            name: 'Multípara',
            color: multiparaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.multipara,
          ),
          ColumnSeries<_PartosPorMes, String>(
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

class _PartosPorMes {
  final String mes;
  final String label;
  final int novilha;
  final int primipara;
  final int multipara;

  _PartosPorMes({
    required this.mes,
    required this.label,
    required this.novilha,
    required this.primipara,
    required this.multipara,
  });

  int get total => novilha + primipara + multipara;

  factory _PartosPorMes.fromJson(Map<String, dynamic> j) => _PartosPorMes(
        mes: j['mes'] as String? ?? '-',
        label: j['label'] as String? ?? '-',
        novilha: (j['Novilha'] as num?)?.toInt() ?? 0,
        primipara: (j['Primípara'] as num?)?.toInt() ?? 0,
        multipara: (j['Multípara'] as num?)?.toInt() ?? 0,
      );
}
