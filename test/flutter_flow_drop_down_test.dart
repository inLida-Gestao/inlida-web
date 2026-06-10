import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/flutter_flow/flutter_flow_drop_down.dart';
import 'package:in_lida_web/flutter_flow/form_field_controller.dart';

void main() {
  testWidgets('single-select dropdown rebinds listener when controller changes',
      (tester) async {
    final firstController = FormFieldController<String>(null);
    final secondController = FormFieldController<String>(null);
    final selectedValues = <String?>[];

    Widget buildDropdown(FormFieldController<String> controller) {
      return MaterialApp(
        home: Scaffold(
          body: FlutterFlowDropDown<String>(
            controller: controller,
            options: const ['Bezerra', 'Bezerro'],
            onChanged: selectedValues.add,
            textStyle: const TextStyle(fontSize: 14),
            elevation: 2.0,
            borderWidth: 0.0,
            borderRadius: 8.0,
            borderColor: Colors.transparent,
            margin: EdgeInsets.zero,
          ),
        ),
      );
    }

    await tester.pumpWidget(buildDropdown(firstController));
    firstController.value = 'Bezerra';
    await tester.pump();

    await tester.pumpWidget(buildDropdown(secondController));
    secondController.value = 'Bezerro';
    await tester.pump();

    firstController.value = null;
    await tester.pump();

    expect(selectedValues, const ['Bezerra', 'Bezerro']);
  });
}
