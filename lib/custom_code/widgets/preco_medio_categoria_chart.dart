// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Importa como 'charts' para evitar conflito

import 'package:syncfusion_flutter_charts/charts.dart';

class PrecoMedioCategoriaChart extends StatelessWidget {
  const PrecoMedioCategoriaChart({
    super.key,
    this.width,
    this.height,
    this.items,
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
    // Suporta JSON com chave "items" ou lista direta
    if (v is Map && v['items'] is List) v = v['items'];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((m) => m.map((k, val) => MapEntry(k.toString(), val)))
          .toList();
    }
    return const [];
  }

  // Mapeamento de cores para as categorias
  static const Map<String, Color> _catColor = {
    'todos': Color(0xFF10B981), // Verde
    'touro': Color(0xFFFACC15), // Amarelo
    'vaca multipara': Color(0xFF78350F), // Marrom Escuro
    'bezerro': Color(0xFF2563EB), // Azul
    'bezerra': Color(0xFF14532D), // Verde Floresta
    'novilha': Color(0xFFDC2626), // Vermelho
    'vaca primipara': Color(0xFF7C3AED), // Roxo
    'garrote': Color(0xFFEA580C), // Laranja
    'boi magro': Color(0xFF65A30D), // Verde Limão
  };

  @override
  Widget build(BuildContext context) {
    final list = _parseList(items);
    final w = width ?? double.infinity;
    final h = height ?? 320.0;

    if (list.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text(
            'Sem dados de preço no período.',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ),
      );
    }

    // Campos reservados que não são categorias a serem plotadas individualmente
    const reserved = {'bucket_ini', 'bucket_fim', 'label'};

    final first = list.first;
    // Pega todas as chaves de categoria (exceto reservadas)
    final cats = <String>[
      for (final k in first.keys)
        if (!reserved.contains(k.toLowerCase())) k.toLowerCase()
    ]..sort();

    final List<CartesianSeries<Map<String, dynamic>, String>> series = [];

    // Séries de Linha Simples por categoria para PREÇO MÉDIO
    for (final c in cats) {
      final baseColor = _catColor[c] ??
          Colors.primaries[(c.hashCode & 0x7fffffff) % Colors.primaries.length];

      // Adiciona uma LineSeries (ou AreaSeries, se preferir o preenchimento) para o Preço Médio
      series.add(
        LineSeries<Map<String, dynamic>, String>(
          name: _titleCase(c),
          dataSource: list,
          xValueMapper: (p, _) => (p['label'] ?? '').toString(),
          yValueMapper: (p, _) {
            final v = p[c] ?? p[c.toLowerCase()];
            if (v == null) return 0.0;
            if (v is num) return v.toDouble();
            return double.tryParse('$v') ?? 0.0;
          },
          // Cor da linha
          color: baseColor,
          width: c == 'todos' ? 3 : 2, // Linha de 'Todos' mais grossa
          // Adiciona marcadores para facilitar a leitura nos pontos de dados
          markerSettings: MarkerSettings(
            isVisible: true,
            color: baseColor,
          ),
          legendIconType: LegendIconType.rectangle,
          enableTooltip: true,
        ),
      );
    }

    // Configurações do gráfico
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
        tooltipBehavior: TooltipBehavior(
            enable: true,
            header: 'Preço Médio:',
            activationMode: ActivationMode.singleTap),
        primaryXAxis: CategoryAxis(
          labelRotation: rotate,
          majorGridLines: const MajorGridLines(width: 0),
          interval: 1,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          majorGridLines: const MajorGridLines(dashArray: <double>[4, 4]),
          numberFormat: NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$'),
        ),
        series: series,
        // Removida a configuração isTransposed: false para Area Empilhada
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
