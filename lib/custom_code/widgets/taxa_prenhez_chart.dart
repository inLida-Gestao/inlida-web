// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';

/// Classe de modelo interna para tipagem segura dos dados JSON
class PrenhezDataPoint {
  final String titulo;
  final double porcentagem;
  final String porcentagemFormatada;

  /// Prenhes na categoria (numerador da taxa), quando a API enviar.
  final int? totalPrenhe;

  /// Denominador da taxa (inseminações ou matrizes expostas), quando a API enviar.
  final int? totalInseminadas;

  PrenhezDataPoint(
    this.titulo,
    this.porcentagem, {
    this.totalPrenhe,
    this.totalInseminadas,
  }) : porcentagemFormatada = '${(porcentagem * 100).toStringAsFixed(1)}%';

  /// Sufixo " (a/b)" alinhado ao cálculo da taxa exibida.
  String get fracaoLabel {
    if (totalPrenhe == null || totalInseminadas == null) return '';
    if (totalInseminadas! < 0) return '';
    return ' ($totalPrenhe/$totalInseminadas)';
  }
}

class TaxaPrenhezChart extends StatefulWidget {
  const TaxaPrenhezChart({
    super.key,
    this.width,
    this.height,
    required this.prenhezData,
  });

  final double? width;
  final double? height;
  final dynamic prenhezData;

  @override
  State<TaxaPrenhezChart> createState() => _TaxaPrenhezChartState();
}

class _TaxaPrenhezChartState extends State<TaxaPrenhezChart> {
  /// Extrai a lista de items da resposta JSON
  List<dynamic> _extractItems(dynamic raw) {
    if (raw == null) return [];

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

    return listDyn;
  }

  static int? _parseOptionalInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    if (v is String) {
      final t = v.trim();
      if (t.isEmpty) return null;
      return int.tryParse(t) ?? num.tryParse(t.replaceAll(',', '.'))?.round();
    }
    return null;
  }

  static int? _countsFromJson(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final parsed = _parseOptionalInt(json[k]);
      if (parsed != null) return parsed;
    }
    return null;
  }

  /// Parse e valida os dados JSON recebidos
  List<PrenhezDataPoint> _parseData(List<dynamic> jsonList) {
    if (jsonList.isEmpty) return [];

    return jsonList
        .map((json) {
          if (json is! Map) return null;
          final m = Map<String, dynamic>.from(json);

          final tituloRaw = m['titulo'] ?? m['label'];
          final tituloStr = tituloRaw?.toString().trim();
          if (tituloStr == null || tituloStr.isEmpty) return null;

          final prenhe = _countsFromJson(m, const [
            'total_prenhe',
            'totalPrenhe',
            'total_pariram',
            'totalPariram',
            'prenhe',
            'qtd_prenhe',
            'matrizes_prenhes',
            'prenhez',
          ]);
          final insem = _countsFromJson(m, const [
            'total_expostas',
            'totalExpostas',
            'total_inseminadas',
            'totalInseminadas',
            'inseminadas',
            'qtd_inseminadas',
            'matrizes_inseminadas',
            'total_matrizes',
          ]);

          final rawPct = m['porcentagem'] ?? m['percentual'];
          num? porcentagem = rawPct is num
              ? rawPct
              : (rawPct is String
                  ? num.tryParse(rawPct.replaceAll('%', '').trim())
                  : null);
          if (porcentagem == null &&
              prenhe != null &&
              insem != null &&
              insem > 0) {
            porcentagem = prenhe / insem;
          }
          if (porcentagem == null) return null;

          final double pctDouble = porcentagem.toDouble();
          final double pct0a1 =
              (pctDouble > 1.0) ? (pctDouble / 100.0) : pctDouble;
          final porcentagemNormalizada = pct0a1.clamp(0.0, 1.0);

          return PrenhezDataPoint(
            tituloStr,
            porcentagemNormalizada,
            totalPrenhe: prenhe,
            totalInseminadas: insem,
          );
        })
        .whereType<PrenhezDataPoint>()
        .toList();
  }

  /// Linha agregada "Todos": com contagens por categoria, usa taxa global (soma/soma) e o mesmo par (a/b).
  static PrenhezDataPoint _linhaTodosAgregada(
      List<PrenhezDataPoint> categorias) {
    final comContagem = categorias
        .where(
          (p) =>
              p.totalPrenhe != null &&
              p.totalInseminadas != null &&
              p.totalInseminadas! >= 0,
        )
        .toList();
    if (comContagem.length == categorias.length && categorias.isNotEmpty) {
      final sumP = comContagem.fold<int>(0, (a, p) => a + (p.totalPrenhe ?? 0));
      final sumI =
          comContagem.fold<int>(0, (acb, p) => acb + (p.totalInseminadas ?? 0));
      final pct = sumI > 0 ? (sumP / sumI).clamp(0.0, 1.0) : 0.0;
      return PrenhezDataPoint(
        'Todos',
        pct,
        totalPrenhe: sumP,
        totalInseminadas: sumI,
      );
    }
    final sumPct = categorias.fold<double>(0, (acc, p) => acc + p.porcentagem);
    final media = categorias.isEmpty ? 0.0 : sumPct / categorias.length;
    return PrenhezDataPoint('Todos', media.clamp(0.0, 1.0));
  }

  static bool _isLinhaTodosCategoria(PrenhezDataPoint p) {
    final t = p.titulo.trim().toLowerCase();
    return t.startsWith('todos');
  }

  @override
  Widget build(BuildContext context) {
    final items = _extractItems(widget.prenhezData);
    final List<PrenhezDataPoint> chartData = _parseData(items);

    final categorias =
        chartData.where((p) => !_isLinhaTodosCategoria(p)).toList();

    final List<PrenhezDataPoint> orderedData;
    if (categorias.isEmpty) {
      orderedData = chartData.reversed.toList();
    } else {
      final todos = _linhaTodosAgregada(categorias);
      orderedData = [todos, ...categorias.reversed];
    }

    final double? w =
        (widget.width != null && widget.width!.isFinite) ? widget.width : null;
    final double? h = (widget.height != null && widget.height!.isFinite)
        ? widget.height
        : null;

    // Estado vazio
    if (orderedData.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text(
            'Sem dados de reprodução no período.',
            style: FlutterFlowTheme.of(context).labelMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        itemCount: orderedData.length,
        itemBuilder: (context, index) {
          final dataPoint = orderedData[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataPoint.titulo,
                  style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: dataPoint.porcentagem,
                          minHeight: 12,
                          backgroundColor:
                              FlutterFlowTheme.of(context).alternate,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${dataPoint.porcentagemFormatada}${dataPoint.fracaoLabel}',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
