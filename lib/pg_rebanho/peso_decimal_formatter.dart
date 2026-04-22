import 'package:flutter/services.dart';

/// Formata o peso à medida que o usuário digita.
///
/// O usuário digita apenas dígitos; o formatter trata os dígitos como
/// centésimos e exibe o valor com vírgula e duas casas decimais.
/// Ex.: digitando "1505" → exibe "15,05"; "15050" → "150,50".
class PesoDecimalInputFormatter extends TextInputFormatter {
  const PesoDecimalInputFormatter();

  /// Converte um valor numérico em string formatada "X,YY" para exibição
  /// inicial em controllers que usam este formatter.
  static String formatDouble(num? value) {
    if (value == null) return '';
    final cents = (value * 100).round();
    final integerPart = (cents ~/ 100).toString();
    final decimalPart = (cents.abs() % 100).toString().padLeft(2, '0');
    return '$integerPart,$decimalPart';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final intValue = int.parse(digits);
    final integerPart = (intValue ~/ 100).toString();
    final decimalPart = (intValue % 100).toString().padLeft(2, '0');
    final formatted = '$integerPart,$decimalPart';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
