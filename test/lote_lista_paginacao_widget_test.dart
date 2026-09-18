import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/pg_lotes/lote_lista_paginacao_widget.dart';

void main() {
  testWidgets('não gera overflow na largura útil dos cartões', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 330.0,
              child: LoteListaPaginacaoWidget(
                page: 1,
                pageSize: 50,
                totalItems: 137,
                onPageChanged: (_) {},
                onPageSizeChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('1–50 de 137'), findsOneWidget);
    expect(find.text('1 de 3'), findsOneWidget);
    expect(find.text('50 por página'), findsOneWidget);
  });
}
