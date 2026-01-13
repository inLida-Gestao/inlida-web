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
import 'package:data_table_2/data_table_2.dart';

class DiagnosticosPeriodoTable extends StatefulWidget {
  const DiagnosticosPeriodoTable({
    super.key,
    this.width,
    this.height,
    required this.items,
  });

  final double? width;
  final double? height;
  final dynamic items;

  @override
  State<DiagnosticosPeriodoTable> createState() => _DiagnosticosPeriodoTableState();
}

class _DiagnosticosPeriodoTableState extends State<DiagnosticosPeriodoTable> {
  List<_DiagnosticoSituacao> _parseItems(dynamic raw) {
    if (raw == null) return [];

    List<dynamic> list;

    if (raw is List) {
      list = raw;
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['items'] is List) {
          list = decoded['items'];
        } else {
          list = [];
        }
      } catch (_) {
        list = [];
      }
    } else if (raw is Map && raw['items'] is List) {
      list = raw['items'];
    } else {
      list = [];
    }

    return list.map<_DiagnosticoSituacao>((e) {
      if (e is Map<String, dynamic>) {
        return _DiagnosticoSituacao.fromJson(e);
      } else if (e is Map) {
        return _DiagnosticoSituacao.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)));
      }
      return _DiagnosticoSituacao(situacao: '-', total: 0, porcentagem: 0.0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? double.infinity;
    final h = widget.height ?? 300.0;
    final data = _parseItems(widget.items);

    if (data.isEmpty) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Text(
            'Sem dados no período.',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
        ),
      );
    }

    return SizedBox(
      width: w,
      height: h,
      child: DataTable2(
        columnSpacing: 20,
        horizontalMargin: 20,
        headingRowHeight: 64.0,
        dataRowHeight: 56.0,
        minWidth: 400,
        columns: [
          DataColumn2(
            label: Text(
              'Situação',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Text(
              'Total',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            size: ColumnSize.S,
            numeric: true,
          ),
          DataColumn2(
            label: Text(
              'Porcentagem',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
            ),
            size: ColumnSize.S,
            numeric: true,
          ),
        ],
        rows: data.map((item) {
          final isTotal = item.situacao == 'Total';
          return DataRow2(
            cells: [
              DataCell(
                Text(
                  item.situacao,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
              DataCell(
                Text(
                  item.total.toString(),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
              DataCell(
                Text(
                  '${item.porcentagem.toStringAsFixed(2)}%',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
              ),
            ],
            color: isTotal
                ? WidgetStateProperty.all(
                    FlutterFlowTheme.of(context).alternate.withValues(alpha: 0.1))
                : null,
          );
        }).toList(),
      ),
    );
  }
}

class _DiagnosticoSituacao {
  final String situacao;
  final int total;
  final double porcentagem;

  _DiagnosticoSituacao({
    required this.situacao,
    required this.total,
    required this.porcentagem,
  });

  factory _DiagnosticoSituacao.fromJson(Map<String, dynamic> j) =>
      _DiagnosticoSituacao(
        situacao: j['situacao'] as String? ?? '-',
        total: (j['total'] as num?)?.toInt() ?? 0,
        porcentagem: (j['porcentagem'] as num?)?.toDouble() ?? 0.0,
      );
}
