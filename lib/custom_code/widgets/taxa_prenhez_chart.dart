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

    // Estado vazio
    if (orderedData.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: Text(
            'Sem dados de reprodução no período.',
            style: FlutterFlowTheme.of(context).labelMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ✅ Container com width E height
    return SizedBox(
      width: widget.width,
      height: widget.height,
      // ✅ SingleChildScrollView para evitar overflow
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do gráfico
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Text(
                '',
                style: FlutterFlowTheme.of(context).headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Lista de barras de progresso
            ...orderedData.map((dataPoint) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da categoria
                    Text(
                      dataPoint.titulo,
                      style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Barra de progresso
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
                        // Porcentagem
                        Text(
                          dataPoint.porcentagemFormatada,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
