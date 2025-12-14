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

/// Modelo interno (um ponto da projeção)
class _Ponto {
  final String label;
  final int proj_6m_machos;
  final int proj_6m_femeas;
  final int proj_7m_machos;
  final int proj_7m_femeas;
  final int proj_8m_machos;
  final int proj_8m_femeas;

  _Ponto({
    required this.label,
    required this.proj_6m_machos,
    required this.proj_6m_femeas,
    required this.proj_7m_machos,
    required this.proj_7m_femeas,
    required this.proj_8m_machos,
    required this.proj_8m_femeas,
  });

  factory _Ponto.fromJson(Map<String, dynamic> j) => _Ponto(
        label: (j['label'] ?? '').toString(),
        proj_6m_machos: (j['proj_6m_machos'] as num?)?.toInt() ?? 0,
        proj_6m_femeas: (j['proj_6m_femeas'] as num?)?.toInt() ?? 0,
        proj_7m_machos: (j['proj_7m_machos'] as num?)?.toInt() ?? 0,
        proj_7m_femeas: (j['proj_7m_femeas'] as num?)?.toInt() ?? 0,
        proj_8m_machos: (j['proj_8m_machos'] as num?)?.toInt() ?? 0,
        proj_8m_femeas: (j['proj_8m_femeas'] as num?)?.toInt() ?? 0,
      );
}

class ProjecaoDesmamasChart extends StatefulWidget {
  const ProjecaoDesmamasChart({
    super.key,
    this.width,
    this.height,
    this.items,
    required this.filtroSexo,
    required this.filtroIdadeMeses,
  });

  final double? width;
  final double? height;
  final dynamic items;
  final String filtroSexo;
  final String filtroIdadeMeses; // '6', '7' ou '8'

  @override
  State<ProjecaoDesmamasChart> createState() => _ProjecaoDesmamasChartState();
}

class _ProjecaoDesmamasChartState extends State<ProjecaoDesmamasChart> {
  List<_Ponto> _parse(dynamic raw) {
    if (raw == null) return const <_Ponto>[];

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

    return listDyn.map<_Ponto>((e) {
      if (e is Map<String, dynamic>) return _Ponto.fromJson(e);
      if (e is Map) {
        return _Ponto.fromJson(e.map((k, v) => MapEntry(k.toString(), v)));
      }
      if (e is String) {
        try {
          final m = jsonDecode(e) as Map<String, dynamic>;
          return _Ponto.fromJson(m);
        } catch (_) {
          return _Ponto(
            label: '-',
            proj_6m_machos: 0,
            proj_6m_femeas: 0,
            proj_7m_machos: 0,
            proj_7m_femeas: 0,
            proj_8m_machos: 0,
            proj_8m_femeas: 0,
          );
        }
      }
      return _Ponto(
        label: '-',
        proj_6m_machos: 0,
        proj_6m_femeas: 0,
        proj_7m_machos: 0,
        proj_7m_femeas: 0,
        proj_8m_machos: 0,
        proj_8m_femeas: 0,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _parse(widget.items);
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? 300.0;

    final filtroSexo = widget.filtroSexo.toLowerCase().trim();
    final isTodos = filtroSexo == 'todos';
    final isMacho = filtroSexo == 'macho';
    final isFemea = filtroSexo == 'femea' || filtroSexo == 'fêmea';

    if (data.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text('Sem dados de projeção.',
              style: FlutterFlowTheme.of(context).labelMedium),
        ),
      );
    }

    Color corDaSerie = Colors.blue;
    String seriesName = 'Projeção';
    int Function(_Ponto) yValueMapper = (p) => 0;

    final idade = widget.filtroIdadeMeses.trim();

    if (idade == '6') {
      seriesName = 'Projeção 6 Meses';
      corDaSerie = const Color(0xFF60A5FA);
      yValueMapper = isTodos
          ? (p) => p.proj_6m_machos + p.proj_6m_femeas
          : isMacho
              ? (p) => p.proj_6m_machos
              : (p) => p.proj_6m_femeas;
    } else if (idade == '7') {
      seriesName = 'Projeção 7 Meses';
      corDaSerie = const Color(0xFF34D399);
      yValueMapper = isTodos
          ? (p) => p.proj_7m_machos + p.proj_7m_femeas
          : isMacho
              ? (p) => p.proj_7m_machos
              : (p) => p.proj_7m_femeas;
    } else if (idade == '8') {
      seriesName = 'Projeção 8 Meses';
      corDaSerie = const Color(0xFF6366F1);
      yValueMapper = isTodos
          ? (p) => p.proj_8m_machos + p.proj_8m_femeas
          : isMacho
              ? (p) => p.proj_8m_machos
              : (p) => p.proj_8m_femeas;
    }

    final rotate = MediaQuery.of(context).size.width < 380 ? -45 : -25;

    return SizedBox(
      width: w,
      height: h,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        legend: const Legend(
          isVisible: false,
        ),
        tooltipBehavior:
            TooltipBehavior(enable: true, header: 'Projeção Desmama'),
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
        series: <CartesianSeries<_Ponto, String>>[
          ColumnSeries<_Ponto, String>(
            name: seriesName,
            color: corDaSerie,
            dataSource: data,
            xValueMapper: (p, _) => p.label,
            yValueMapper: (p, _) => yValueMapper(p),
            spacing: 0.3,
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ],
      ),
    );
  }
}
