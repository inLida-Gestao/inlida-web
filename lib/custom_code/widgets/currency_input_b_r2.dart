// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';

class CurrencyInputBR2 extends StatefulWidget {
  const CurrencyInputBR2(
      {super.key,
      this.width,
      this.height,
      this.initialValue,
      this.hintText,
      this.labelText,
      this.fillColor,
      this.borderColor,
      this.focusedBorderColor,
      this.textColor,
      this.fontSize,
      this.borderRadius,
      this.contentPadding});

  final double? width;
  final double? height;
  final double? initialValue;
  final String? hintText;
  final String? labelText;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<CurrencyInputBR2> createState() => _CurrencyInputBRState();
}

class _CurrencyInputBRState extends State<CurrencyInputBR2> {
  late TextEditingController _controller;
  double _value = 0.0;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? 0.0;
    _controller = TextEditingController(
      text: _formatCurrency(_value),
    );

    // Inicializa o App State com o valor inicial (somente se for positivo)
    if (_value > 0) {
      _updateAppState(_value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final formatter = _CurrencyFormatter();
    return formatter.format(value);
  }

  double _parseValue(String text) {
    // Remove todos os caracteres não numéricos
    String numbers = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.isEmpty) return 0.0;

    // Converte para double considerando os centavos
    return double.parse(numbers) / 100;
  }

  void _updateAppState(double value) {
    // Atualiza o App State apenas com valores positivos
    if (value > 0) {
      FFAppState().valueDouble = value;
      FFAppState().update(() {});
    } else {
      // Se valor for zero ou negativo, limpa o App State
      FFAppState().valueDouble = 0.0;
      FFAppState().update(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _CurrencyInputFormatter(),
        ],
        style: TextStyle(
          color: widget.textColor ?? Colors.black,
          fontSize: widget.fontSize ?? 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'R\$ 0,00',
          labelText: widget.labelText,
          filled: widget.fillColor != null,
          fillColor: widget.fillColor,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.grey,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
            borderSide: BorderSide(
              color:
                  widget.focusedBorderColor ?? Theme.of(context).primaryColor,
              width: 1,
            ),
          ),
        ),
        onChanged: (text) {
          _value = _parseValue(text);
          // Atualiza o App State automaticamente
          _updateAppState(_value);
        },
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: 'R\$ 0,00',
        selection: TextSelection.collapsed(offset: 8),
      );
    }

    // Remove todos os caracteres não numéricos
    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.isEmpty) {
      return const TextEditingValue(
        text: 'R\$ 0,00',
        selection: TextSelection.collapsed(offset: 8),
      );
    }

    // Converte para inteiro
    final value = int.parse(numbers);

    // Formata o valor
    final formatter = _CurrencyFormatter();
    final formatted = formatter.format(value / 100);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CurrencyFormatter {
  String format(double value) {
    // Separa parte inteira e decimal
    final integerPart = value.truncate();
    final decimalPart = ((value - integerPart) * 100).round();

    // Formata a parte inteira com separadores de milhar
    String integerStr = integerPart.toString();
    String formatted = '';

    for (int i = 0; i < integerStr.length; i++) {
      if (i > 0 && (integerStr.length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += integerStr[i];
    }

    // Adiciona a parte decimal
    final decimalStr = decimalPart.toString().padLeft(2, '0');

    return 'R\$ $formatted,$decimalStr';
  }
}

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
