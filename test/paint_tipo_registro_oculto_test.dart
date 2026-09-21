@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/app_features.dart';
import 'package:in_lida_web/custom_code/widgets/paint_tipo_registro_dropdown.dart';
import 'package:in_lida_web/flutter_flow/form_field_controller.dart';

/// O módulo PAINT está em teste interno e só pode aparecer na branch
/// lucas-paint. A cliente viu "Tipo registro (PAINT)" no editar animal da
/// versão que está no ar.
void main() {
  testWidgets('o campo do PAINT não aparece no cadastro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              Expanded(
                child: PaintTipoRegistroDropdown(
                  controller: FormFieldController<String>(null),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(kPaintHabilitado, isFalse,
        reason: 'fora da lucas-paint a chave fica desligada');
    expect(find.text('Tipo registro (PAINT)'), findsNothing);
    expect(find.byType(DropdownButton<String>), findsNothing);
  });
}
