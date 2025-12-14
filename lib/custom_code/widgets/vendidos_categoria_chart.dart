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

class VendidosCategoriaChart extends StatelessWidget {
  const VendidosCategoriaChart({
    super.key,
    this.width,
    this.height,
    this.items, // List<Map> | {"items":[...]} | String JSON
  });

  final double? width;
  final double? height;
  final dynamic items;

  List<Map<String, dynamic>> _parseList(dynamic raw) {
    if (raw == null) return const [];
    dynamic v = raw;
    if (v is String) {
      try {
        v = jsonDecode(v);
      } catch (_) {
        return const [];
      }
    }
    if (v is Map && v['items'] is List) v = v['items'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((m) => m.map((k, val) => MapEntry(k.toString(), val)))
          .toList();
    }
    return const [];
  }

  // paleta fixa por categoria (ajuste as cores se quiser ficar 1:1 com o print)
  static const Map<String, Color> _catColor = {
    'touro': Color(0xFFB45309),
    'vaca multipara': Color(0xFFA3A300),
    'bezerro': Color(0xFF22C55E),
    'bezerra': Color(0xFF065F46),
    'novilha': Color(0xFFEF4444),
    'vaca primipara': Color(0xFF8B5CF6),
    'garrote': Color(0xFF92400E),
    'boi magro': Color(0xFF3B82F6),
  };

  @override
  Widget build(BuildContext context) {
    final data = _parseList(items);
    final w = width ?? double.infinity;
    final h = height ?? 300.0;

    if (data.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text('Sem vendas no período.',
              style: FlutterFlowTheme.of(context).labelMedium),
        ),
      );
    }

    // chaves conhecidas
    const reserved = {'bucket_ini', 'bucket_fim', 'label', 'total', 'todos'};
    // coleta categorias dinamicamente
    final first = data.first;
    final cats = <String>[
      for (final k in first.keys)
        if (!reserved.contains(k.toString().toLowerCase()))
          k.toString().toLowerCase()
    ];

    // ordena por nome para estabilidade
    cats.sort();

    // calcula total se não vier
    final hasTodos = first.keys.map((e) => e.toLowerCase()).contains('todos');
    final totals = hasTodos
        ? null
        : data.map((row) {
            int sum = 0;
            for (final c in cats) {
              final v = row[c] ?? row[c.toLowerCase()] ?? 0;
              sum += (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
            }
            return sum;
          }).toList();

    // série de colunas empilhadas
    final List<CartesianSeries<Map<String, dynamic>, String>> series = [];
    for (final c in cats) {
      series.add(
        StackedColumnSeries<Map<String, dynamic>, String>(
          name: _titleCase(c),
          color: _catColor[c] ??
              Colors.primaries[
                  (c.hashCode & 0x7fffffff) % Colors.primaries.length],
          dataSource: data,
          xValueMapper: (p, _) => (p['label'] ?? '').toString(),
          yValueMapper: (p, _) {
            final v = p[c] ?? p[c.toLowerCase()];
            if (v is num) return v.toDouble();
            return double.tryParse('$v') ?? 0.0;
          },
          legendIconType: LegendIconType.rectangle,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      );
    }

    final rotate = MediaQuery.of(context).size.width < 380 ? -45 : -25;

    return SizedBox(
      width: w,
      height: h,
      child: SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.top,
          alignment: ChartAlignment.center,
          overflowMode: LegendItemOverflowMode.wrap,
          iconWidth: 12,
          iconHeight: 12,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          labelRotation: rotate,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: const NumericAxis(
          minimum: 0,
          majorGridLines: MajorGridLines(width: 0),
        ),
        series: series,
      ),
    );
  }

  String _titleCase(String s) => s.isEmpty
      ? s
      : s
          .split(RegExp(r'\s+'))
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
}
