import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/pg_lotes/lote_lista_abas_widget.dart';

void main() {
  testWidgets('alterna entre as listas sem overflow', (tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 330.0,
            child: StatefulBuilder(
              builder: (context, setState) {
                return LoteListaAbasWidget(
                  selectedIndex: selectedIndex,
                  disponiveisCount: 137,
                  noLoteCount: 52,
                  onChanged: (index) {
                    setState(() => selectedIndex = index);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Disponíveis (137)'), findsOneWidget);
    expect(find.text('No lote (52)'), findsOneWidget);

    await tester.tap(find.text('No lote (52)'));
    await tester.pump();

    expect(selectedIndex, 1);
    expect(tester.takeException(), isNull);
  });
}
