// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:intl/intl.dart';

class YearMonthRangePicker extends StatefulWidget {
  const YearMonthRangePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.onChanged,
    this.width,
    this.height,
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  /// Callback que retorna start e end separados
  final void Function(DateTime startDate, DateTime endDate)? onChanged;

  /// Para avisar ao FlutterFlow o tamanho do widget
  final double? width;
  final double? height;

  @override
  _YearMonthRangePickerState createState() => _YearMonthRangePickerState();
}

class _YearMonthRangePickerState extends State<YearMonthRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();
    _endDate = widget.initialEndDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Selecionar Início' : 'Selecionar Fim',
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(picked.year, picked.month, 1);
        } else {
          _endDate = DateTime(picked.year, picked.month, 1);
        }
      });

      if (widget.onChanged != null) {
        widget.onChanged!(_startDate, _endDate);
      }
    }
  }

  String _format(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => _selectDate(context, true),
            child: Text("Início: ${_format(_startDate)}"),
          ),
          ElevatedButton(
            onPressed: () => _selectDate(context, false),
            child: Text("Fim: ${_format(_endDate)}"),
          ),
        ],
      ),
    );
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
