import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'redefinicaosenha_widget.dart' show RedefinicaosenhaWidget;
import 'package:flutter/material.dart';

class RedefinicaosenhaModel extends FlutterFlowModel<RedefinicaosenhaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for senha widget.
  FocusNode? senhaFocusNode;
  TextEditingController? senhaTextController;
  late bool senhaVisibility;
  String? Function(BuildContext, String?)? senhaTextControllerValidator;
  // State field(s) for confirmacaoSenha widget.
  FocusNode? confirmacaoSenhaFocusNode;
  TextEditingController? confirmacaoSenhaTextController;
  late bool confirmacaoSenhaVisibility;
  String? Function(BuildContext, String?)?
      confirmacaoSenhaTextControllerValidator;

  @override
  void initState(BuildContext context) {
    senhaVisibility = false;
    confirmacaoSenhaVisibility = false;
  }

  @override
  void dispose() {
    senhaFocusNode?.dispose();
    senhaTextController?.dispose();

    confirmacaoSenhaFocusNode?.dispose();
    confirmacaoSenhaTextController?.dispose();
  }
}
