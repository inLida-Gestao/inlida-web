import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'cadastro_widget.dart' show CadastroWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroModel extends FlutterFlowModel<CadastroWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for nome widget.
  FocusNode? nomeFocusNode;
  TextEditingController? nomeTextController;
  String? Function(BuildContext, String?)? nomeTextControllerValidator;
  String? _nomeTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for telefone widget.
  FocusNode? telefoneFocusNode;
  TextEditingController? telefoneTextController;
  late MaskTextInputFormatter telefoneMask;
  String? Function(BuildContext, String?)? telefoneTextControllerValidator;
  String? _telefoneTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for funcao widget.
  String? funcaoValue;
  FormFieldController<String>? funcaoValueController;
  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  String? _emailTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for senha widget.
  FocusNode? senhaFocusNode;
  TextEditingController? senhaTextController;
  late bool senhaVisibility;
  String? Function(BuildContext, String?)? senhaTextControllerValidator;
  String? _senhaTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for confirmacaoSenha widget.
  FocusNode? confirmacaoSenhaFocusNode;
  TextEditingController? confirmacaoSenhaTextController;
  late bool confirmacaoSenhaVisibility;
  String? Function(BuildContext, String?)?
      confirmacaoSenhaTextControllerValidator;
  String? _confirmacaoSenhaTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {
    nomeTextControllerValidator = _nomeTextControllerValidator;
    telefoneTextControllerValidator = _telefoneTextControllerValidator;
    emailTextControllerValidator = _emailTextControllerValidator;
    senhaVisibility = false;
    senhaTextControllerValidator = _senhaTextControllerValidator;
    confirmacaoSenhaVisibility = false;
    confirmacaoSenhaTextControllerValidator =
        _confirmacaoSenhaTextControllerValidator;
  }

  @override
  void dispose() {
    nomeFocusNode?.dispose();
    nomeTextController?.dispose();

    telefoneFocusNode?.dispose();
    telefoneTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    senhaFocusNode?.dispose();
    senhaTextController?.dispose();

    confirmacaoSenhaFocusNode?.dispose();
    confirmacaoSenhaTextController?.dispose();
  }
}
