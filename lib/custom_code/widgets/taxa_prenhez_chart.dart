// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


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
  final List<dynamic>? prenhezData;

  @override
  State<TaxaPrenhezChart> createState() => _TaxaPrenhezChartState();
}

class _TaxaPrenhezChartState extends State<TaxaPrenhezChart> {
  /// Parse e valida os dados JSON recebidos
  List<PrenhezDataPoint> _parseData(List<dynamic> jsonList) {
    if (jsonList.isEmpty) return [];

    return jsonList
        .map((json) {
          // ✅ Validação de tipo
          if (json is! Map<String, dynamic>) return null;

          // ✅ Validação de campos obrigatórios
          final titulo = json['titulo'];
          final porcentagem = json['porcentagem'];

          if (titulo == null || porcentagem == null) return null;
          if (titulo is! String) return null;
          if (porcentagem is! num) return null;

          // ✅ Clamp porcentagem entre 0 e 1
          final porcentagemNormalizada =
              (porcentagem.toDouble()).clamp(0.0, 1.0);

          return PrenhezDataPoint(titulo, porcentagemNormalizada);
        })
        .whereType<PrenhezDataPoint>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<PrenhezDataPoint> chartData =
        _parseData(widget.prenhezData ?? []);
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
