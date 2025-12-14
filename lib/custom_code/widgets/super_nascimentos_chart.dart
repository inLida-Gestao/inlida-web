// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SuperNascimentosChart extends StatefulWidget {
  const SuperNascimentosChart({
    super.key,
    required this.idPropriedade,
    required this.inicio,
    required this.fim,
    required this.sexo, // 'M', 'F' ou 'T'
    this.width,
    this.height,
  });

  final String idPropriedade;
  final DateTime inicio;
  final DateTime fim;
  final String sexo;
  final double? width;
  final double? height;

  @override
  State<SuperNascimentosChart> createState() => _SuperNascimentosChartState();
}

class _NascimentosPorMes {
  final String label;
  final int total;

  _NascimentosPorMes(this.label, this.total);
}

class _SuperNascimentosChartState extends State<SuperNascimentosChart> {
  late Future<List<_NascimentosPorMes>> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = _buscarDados();
  }

  @override
  void didUpdateWidget(covariant SuperNascimentosChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.inicio != oldWidget.inicio ||
        widget.fim != oldWidget.fim ||
        widget.sexo != oldWidget.sexo ||
        widget.idPropriedade != oldWidget.idPropriedade) {
      _futureData = _buscarDados();
    }
  }

  Future<List<_NascimentosPorMes>> _buscarDados() async {
    final client = Supabase.instance.client;
    final inicio = widget.inicio;
    final fim = widget.fim;

    final query = client
        .from('rebanho')
        .select('dataNascimento, sexo')
        .eq('deletado', 'NAO')
        .gte('dataNascimento', inicio.toIso8601String())
        .lte('dataNascimento', fim.toIso8601String())
        .eq('idPropriedade', widget.idPropriedade);

    if (widget.sexo != 'T') {
      query.eq('sexo', widget.sexo);
    }

    final res = await query;
    final dados = res as List<dynamic>;

    final Map<String, int> agrupado = {};

    for (final item in dados) {
      final dataStr = item['dataNascimento'];
      if (dataStr == null) continue;

      final dt = DateTime.tryParse(dataStr);
      if (dt == null) continue;

      final label = DateFormat('MM/yyyy').format(dt);
      agrupado[label] = (agrupado[label] ?? 0) + 1;
    }

    final lista = agrupado.entries
        .map((e) => _NascimentosPorMes(e.key, e.value))
        .toList()
      ..sort((a, b) => DateFormat('MM/yyyy')
          .parse(a.label)
          .compareTo(DateFormat('MM/yyyy').parse(b.label)));

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_NascimentosPorMes>>(
      future: _futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Center(child: Text('Sem dados no período.'));
        }

        return SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 300,
          child: SfCartesianChart(
            title: const ChartTitle(text: 'Nascimentos por mês'),
            primaryXAxis: const CategoryAxis(),
            primaryYAxis: const NumericAxis(),
            series: <CartesianSeries<_NascimentosPorMes, String>>[
              ColumnSeries<_NascimentosPorMes, String>(
                dataSource: data,
                xValueMapper: (item, _) => item.label,
                yValueMapper: (item, _) => item.total,
                name: 'Total',
                color: Colors.blueAccent,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        );
      },
    );
  }
}
