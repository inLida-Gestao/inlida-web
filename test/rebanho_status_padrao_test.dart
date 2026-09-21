import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/flutter_flow/form_field_controller.dart';
import 'package:in_lida_web/pg_rebanho/rebanho_status_utils.dart';

/// "Deixar pré-selecionado o status Na propriedade quando adiciona animal e
/// nascimento (igual no app)".
void main() {
  test('o campo já abre com o status padrão escolhido', () {
    String? statusDoFormulario;

    final controller = FormFieldController<String>(
      statusDoFormulario ??= statusRebanhoPadrao,
    );

    expect(controller.value, 'Na propriedade');
    expect(statusDoFormulario, 'Na propriedade');
  });

  test('depois de salvar, o formulário volta com o status padrão', () {
    final controller = FormFieldController<String>(statusRebanhoPadrao);

    // usuário troca o status e salva
    controller.value = 'Vendido';
    controller.reset();

    expect(controller.value, 'Na propriedade');
  });
}
