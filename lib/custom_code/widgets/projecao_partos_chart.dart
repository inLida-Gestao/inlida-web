// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:syncfusion_flutter_charts/charts.dart';

/// Modelo de cada item
class _PartosPorMes {
  final String mes; // "YYYY-MM-DD"
  final String label; // "MM/YYYY"
  final int novilha;
  final int primipara;
  final int multipara;
  final int total;

  _PartosPorMes({
    required this.mes,
    required this.label,
    required this.novilha,
    required this.primipara,
    required this.multipara,
  }) : total = novilha + primipara + multipara;

  factory _PartosPorMes.fromJson(Map<String, dynamic> j) => _PartosPorMes(
        mes: (j['mes'] ?? '1970-01-01').toString(),
        label: (j['label'] ?? '-').toString(),
        novilha: (j['Novilha'] as num?)?.toInt() ?? 0,
        primipara: (j['Primípara'] as num?)?.toInt() ?? 0,
        multipara: (j['Multípara'] as num?)?.toInt() ?? 0,
      );
}

/// WIDGET: ProjecaoPartosChart
/// - Mantém o padrão de uso via LEGENDA (clicar na legenda para mostrar/esconder séries)
/// - Adiciona a série "Total" (Todos) = Novilha + Primípara + Multípara
/// - Aplica cores distintas por série
/// - Observação: não inclui título interno (você já coloca fora)
class ProjecaoPartosChart extends StatelessWidget {
  const ProjecaoPartosChart({
    super.key,
    this.width,
    this.height,
    this.items, // API Response → JSON Body → items
  });

  final double? width;
  final double? height;
  final dynamic items;

  DateTime _safeParse(String s) =>
      DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<_PartosPorMes> _parseItems(dynamic raw) {
    if (raw == null) return const <_PartosPorMes>[];

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

    final parsed = listDyn.map<_PartosPorMes>((e) {
      if (e is Map<String, dynamic>) return _PartosPorMes.fromJson(e);
      if (e is Map) {
        return _PartosPorMes.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)));
      }
      if (e is String) {
        try {
          final m = jsonDecode(e) as Map<String, dynamic>;
          return _PartosPorMes.fromJson(m);
        } catch (_) {
          return _PartosPorMes(
            mes: '1970-01-01',
            label: '-',
            novilha: 0,
            primipara: 0,
            multipara: 0,
          );
        }
      }
      return _PartosPorMes(
        mes: '1970-01-01',
        label: '-',
        novilha: 0,
        primipara: 0,
        multipara: 0,
      );
    }).toList()
      ..sort((a, b) => _safeParse(a.mes).compareTo(_safeParse(b.mes)));

    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final data = _parseItems(items);
    final w = width ?? double.infinity;
    final h = height ?? 280.0;

    if (data.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text(
            'Sem projeção de partos no período.',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ),
      );
    }

    // Cores (inspiradas nas que você já usou/mandou)
    const novilhaColor = Color(0xFF4D6B1F); // verde escuro
    const primiparaColor = Color(0xFF6BCB81); // verde médio
    const multiparaColor = Color(0xFF90D9C5); // verde-lima (ajuste se quiser)
    const totalColor =
        Color(0xFF6B4DAF); // roxo p/ Total (como "Total" do outro gráfico)

    final rotate = MediaQuery.of(context).size.width < 380 ? -55 : -30;

    return SizedBox(
      width: w,
      height: h,
      child: SfCartesianChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.top,
          overflowMode: LegendItemOverflowMode.wrap,
          alignment: ChartAlignment.center,
          // deixe true para o usuário "filtrar" clicando na legenda (UX original)
          toggleSeriesVisibility: true,
          iconHeight: 12,
          iconWidth: 12,
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
          labelRotation: rotate,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          numberFormat: NumberFormat.compact(),
          majorGridLines: const MajorGridLines(width: 0),
          minorGridLines: const MinorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
        ),
        series: <CartesianSeries<_PartosPorMes, String>>[
          // Série: Novilha
          ColumnSeries<_PartosPorMes, String>(
            name: 'Novilha',
            color: novilhaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.novilha,
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          ),

          // Série: Primípara
          ColumnSeries<_PartosPorMes, String>(
            name: 'Primípara',
            color: primiparaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.primipara,
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          ),

          // Série: Multípara
          ColumnSeries<_PartosPorMes, String>(
            name: 'Multípara',
            color: multiparaColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.multipara,
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          ),

          // Série: Total (Todos) = soma por mês
          ColumnSeries<_PartosPorMes, String>(
            name: 'Total',
            color: totalColor,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => p.total,
            borderRadius: const BorderRadius.all(Radius.circular(1)),
          ),
        ],
      ),
    );
  }
}
