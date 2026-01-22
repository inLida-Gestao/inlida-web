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

  PrenhezDataPoint(this.titulo, this.porcentagem)
      : porcentagemFormatada = '${(porcentagem * 100).toStringAsFixed(1)}%';
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

  /// Parse e valida os dados JSON recebidos
  List<PrenhezDataPoint> _parseData(List<dynamic> jsonList) {
    if (jsonList.isEmpty) return [];

    return jsonList
        .map((json) {
          // ✅ Validação de tipo
          if (json is! Map<String, dynamic>) return null;

          // ✅ Validação de campos obrigatórios
          final titulo = json['titulo'] ?? json['label'];
          final rawPct = json['porcentagem'] ?? json['percentual'];

          if (titulo == null || rawPct == null) return null;
          if (titulo is! String) return null;

          final num? porcentagem = rawPct is num
              ? rawPct
              : (rawPct is String ? num.tryParse(rawPct.replaceAll('%', '').trim()) : null);
          if (porcentagem == null) return null;

          // ✅ Clamp porcentagem entre 0 e 1
          // Se vier em % (ex.: 55 ou 55.2), normaliza para 0-1.
          final double pctDouble = porcentagem.toDouble();
          final double pct0a1 = (pctDouble > 1.0) ? (pctDouble / 100.0) : pctDouble;
          final porcentagemNormalizada = pct0a1.clamp(0.0, 1.0);

          return PrenhezDataPoint(titulo, porcentagemNormalizada);
        })
        .whereType<PrenhezDataPoint>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _extractItems(widget.prenhezData);
    final List<PrenhezDataPoint> chartData = _parseData(items);
    final orderedData = chartData.reversed.toList();

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
                      dataPoint.porcentagemFormatada,
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
