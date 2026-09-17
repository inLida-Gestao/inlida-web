import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/custom_code/widgets/currency_input_b_r.dart';

void main() {
  testWidgets('informa o valor digitado para a tela manter entre abas',
      (tester) async {
    double? valorEditado;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrencyInputBR(
            initialValue: 10,
            onChanged: (value) {
              valorEditado = value;
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();

    expect(valorEditado, 123.45);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrencyInputBR(initialValue: valorEditado),
        ),
      ),
    );

    expect(find.text(r'R$ 123,45'), findsOneWidget);
  });
}
