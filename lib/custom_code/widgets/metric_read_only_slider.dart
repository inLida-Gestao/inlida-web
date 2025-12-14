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
import 'dart:math' as math;
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class MetricReadOnlySlider extends StatelessWidget {
  const MetricReadOnlySlider({
    super.key,
    this.width,
    this.height,
    this.items, // JSON | {"items":[{...}]} | [{...}]
  });

  final double? width;
  final double? height;
  final dynamic items;

  // ---------- helpers ----------
  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF3B82F6);
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    if (h.length == 8) return Color(int.parse(h, radix: 16));
    return const Color(0xFF3B82F6);
  }

  Map<String, dynamic>? _firstItem(dynamic raw) {
    if (raw == null) return null;
    dynamic v = raw;
    if (v is String) {
      try {
        v = jsonDecode(v);
      } catch (_) {
        return null;
      }
    }
    if (v is Map && v['items'] != null) v = v['items'];
    if (v is List) {
      if (v.isEmpty) return null;
      final e = v.first;
      return (e is Map) ? e.map((k, val) => MapEntry(k.toString(), val)) : null;
    }
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    return null;
  }

  double _niceStep(double rawStep) {
    if (rawStep <= 0 || rawStep.isNaN || rawStep.isInfinite) return 1.0;
    final mag =
        math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final norm = rawStep / mag;
    if (norm < 1.5) return 1 * mag;
    if (norm < 3) return 2 * mag;
    if (norm < 7) return 5 * mag;
    return 10 * mag;
  }

  // Parser numérico robusto (aceita vírgula, remove lixo/invisíveis)
  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    try {
      final cleaned = v
          .toString()
          .replaceAll(RegExp(r'[^\d\-\.,]'), '')
          .trim()
          .replaceAll(',', '.');
      if (cleaned.isEmpty) return null;
      final d = double.parse(cleaned);
      if (d.isNaN || d.isInfinite) return null;
      return d;
    } catch (_) {
      return null;
    }
  }

  // Ajusta min/max para sempre haver faixa válida
  ({double min, double max}) safeRange(
      double? minIn, double? maxIn, double value) {
    double min0 = minIn ?? (value >= 0 ? 0.0 : value);
    double max0 = maxIn ?? value;

    if (!(min0.isFinite)) min0 = 0.0;
    if (!(max0.isFinite)) max0 = min0 + 1.0;

    if (max0 <= min0) {
      final bump = value.abs() > 1 ? value.abs() * .5 : 1.0;
      max0 = min0 + bump;
    }

    final spanInit = (max0 - min0).abs();
    final pad = spanInit * 0.15;
    if (minIn == null) min0 -= pad;
    if (maxIn == null) max0 += pad;

    if (minIn == null && value >= 0) {
      min0 = math.max(0.0, min0);
    }

    if (max0 <= min0) {
      max0 = min0 + 1.0;
    }

    return (min: min0, max: max0);
  }

  // Garante intervalo válido e limita número de labels
  double safeInterval({
    required double min,
    required double max,
    double? intervalHint,
    int maxLabels = 8,
  }) {
    final span = (max - min).abs();
    if (span <= 0 || !span.isFinite) return 1.0;

    double step =
        intervalHint ?? _niceStep(span / (maxLabels - 1).clamp(2, 50));
    if (step <= 0 || step.isNaN || step.isInfinite) {
      step = _niceStep(span / (maxLabels - 1).clamp(2, 50));
    }

    // se ainda estiver gerando muitos labels, aumenta o passo
    int labels = (((max - min) / step).floor()) + 1;
    int guard = 0;
    while (labels > maxLabels && guard < 20) {
      step = _niceStep(step * 1.2);
      labels = (((max - min) / step).floor()) + 1;
      guard++;
    }

    // fallback final
    if (step <= 0 || step.isNaN || step.isInfinite) {
      step = _niceStep(span / 7);
    }
    return step;
  }

  ({double min, double max, double step}) _autoScale({
    double? minIn,
    double? maxIn,
    double? stepHint,
    required double value,
  }) {
    final r = safeRange(minIn, maxIn, value);
    final min = r.min;
    final max = r.max;
    final step =
        safeInterval(min: min, max: max, intervalHint: stepHint, maxLabels: 8);
    // Ajusta limites para múltiplos do passo
    final niceMin = (min / step).floorToDouble() * step;
    final niceMax = (max / step).ceilToDouble() * step;
    return (min: niceMin, max: niceMax, step: step);
  }

  @override
  Widget build(BuildContext context) {
    final w = width ?? double.infinity;
    final h = height ?? 130;

    final obj = _firstItem(items);
    if (obj == null) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text('Sem dados.',
              style: FlutterFlowTheme.of(context).labelMedium),
        ),
      );
    }

    final titulo = (obj['titulo'] ?? '').toString();

    // valor robusto
    final rawValor = obj['valor'];
    double valor = 0.0;
    if (rawValor is num) {
      valor = rawValor.toDouble();
    } else if (rawValor != null) {
      valor = _toDouble(rawValor) ?? 0.0;
    }

    // min/max/intervalo com parse seguro
    final double? minIn = _toDouble(obj['min']);
    final double? maxIn = _toDouble(obj['max']);
    final double? intervaloIn = _toDouble(obj['intervalo']);

    final sc = _autoScale(
      minIn: minIn,
      maxIn: maxIn,
      stepHint: intervaloIn,
      value: valor,
    );

    final min = sc.min;
    final max = sc.max;

    // intervalo sempre válido
    double intervalo = safeInterval(
        min: min, max: max, intervalHint: intervaloIn, maxLabels: 8);

    final String sufixo = (obj['sufixo'] ?? '').toString().trim();
    final Color cor = _parseColor((obj['corHex'] ?? '#3B82F6').toString());

    // posição da bolha + valor clamped
    final span = math.max(1.0, (max - min));
    final valorClamped = valor.clamp(min, max).toDouble();
    final pos = ((valorClamped - min) / span).clamp(0.0, 1.0);

    // Construção com try/catch para nunca travar UI
    try {
      return SizedBox(
        width: w,
        height: h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                final dx = trackWidth * pos;
                const chipW = 72.0;
                final left =
                    math.max(0.0, math.min(trackWidth - chipW, dx - chipW / 2));

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    SfSliderTheme(
                      data: const SfSliderThemeData(
                        activeTrackHeight: 4,
                        inactiveTrackHeight: 4,
                        thumbRadius: 8,
                        overlayRadius: 0,
                        inactiveTrackColor: Color(0xFFE5E7EB),
                      ),
                      child: SfSlider(
                        min: min,
                        max: max,
                        value: valorClamped,
                        onChanged: null, // read-only
                        showLabels: true,
                        showTicks: true,
                        interval: intervalo,
                        enableTooltip: false,
                        activeColor: cor.withOpacity(0.85),
                        inactiveColor: const Color(0xFFE5E7EB),
                      ),
                    ),
                    Positioned(
                      left: left,
                      top: 0,
                      child: Container(
                        width: chipW,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${valorClamped.toStringAsFixed(sufixo == "kg" ? 1 : 2)}$sufixo',
                          overflow: TextOverflow.ellipsis,
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: FlutterFlowTheme.of(context)
                                        .labelMediumFamily,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('MetricReadOnlySlider error: $e\n$st');
      return SizedBox(
        width: w,
        height: h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Falha ao renderizar slider.\n'
                'min=$min max=$max intervalo=$intervalo valor=$valorClamped',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily:
                          FlutterFlowTheme.of(context).labelMediumFamily,
                      color: const Color(0xFFB91C1C),
                    ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
