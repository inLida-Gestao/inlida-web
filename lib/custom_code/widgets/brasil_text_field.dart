// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';

class BrasilTextField extends StatefulWidget {
  const BrasilTextField({
    super.key,
    this.width,
    this.height,
    this.value,
    required this.filledColor,
    required this.fontSize,
    required this.colorText,
    required this.borderColor,
    this.hintText,
    required this.borderRadius,
    required this.borderSize,
    required this.focusBorderColor,
    required this.callback,
  });

  final double? width;
  final double? height;
  final String? value;
  final Color filledColor;
  final double fontSize;
  final Color colorText;
  final Color borderColor;
  final String? hintText;
  final int borderRadius;
  final int borderSize;
  final Color focusBorderColor;
  final Future Function() callback;

  @override
  _BrasilTextFieldState createState() => _BrasilTextFieldState();
}

class _BrasilTextFieldState extends State<BrasilTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);

    // Observa mudanças no FFAppState().valueDouble
    FFAppState().addListener(() {
      if (mounted) {
        setState(() {
          _controller.text = formatCurrency(FFAppState().valueDouble);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    FFAppState().removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            CurrencyTextInputFormatter(
              locale: 'pt_BR',
              decimalDigits: 2,
              symbol:
                  '', // Remove o símbolo padrão para personalizar manualmente
              enableNegative: true,
            ),
            LengthLimitingTextInputFormatter(16),
          ],
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: widget.colorText,
            fontSize: widget.fontSize,
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              alignment: Alignment.center,
              width:
                  8 + widget.fontSize, // Ajusta o espaçamento com base na fonte
              child: Text(
                'R\$ ',
                style: TextStyle(
                  color: const Color(0xFF28A365), // Cor personalizada do símbolo R$
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            hintText: widget.hintText?.replaceAll('R\$', ''),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(widget.borderRadius.toDouble()),
              borderSide: BorderSide(
                color: widget.borderColor,
                width: widget.borderSize.toDouble(),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(widget.borderRadius.toDouble()),
              borderSide: BorderSide(
                color: widget.focusBorderColor,
                width: widget.borderSize.toDouble(),
              ),
            ),
            filled: true,
            fillColor: widget.filledColor,
          ),
          onChanged: (text) {
            updateValues(text);
          },
        ),
        IconButton(
          icon:
              Icon(Icons.clear, color: widget.colorText, size: widget.fontSize),
          onPressed: () {
            clearValues();
          },
        ),
      ],
    );
  }

  void updateValues(String text) {
    double parsedValue = parseCurrency(text);
    FFAppState().valueFormat = text;
    FFAppState().valueDouble = parsedValue;
    rebuildCurrentComponent();
  }

  void clearValues() {
    _controller.clear();
    FFAppState().valueFormat = '';
    FFAppState().valueDouble = 0.0;
    rebuildCurrentComponent();
  }

  double parseCurrency(String text) {
    String sanitizedValue =
        text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(sanitizedValue) ?? 0.0;
  }

  String formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void rebuildCurrentComponent() {
    if (mounted) {
      setState(() {});
    }
  }
}
