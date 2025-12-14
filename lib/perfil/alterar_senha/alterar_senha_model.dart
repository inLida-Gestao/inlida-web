import '/backend/api_requests/api_calls.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'alterar_senha_widget.dart' show AlterarSenhaWidget;
import 'package:flutter/material.dart';

class AlterarSenhaModel extends FlutterFlowModel<AlterarSenhaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for senha widget.
  FocusNode? senhaFocusNode;
  TextEditingController? senhaTextController;
  late bool senhaVisibility;
  String? Function(BuildContext, String?)? senhaTextControllerValidator;
  // State field(s) for senha2 widget.
  FocusNode? senha2FocusNode;
  TextEditingController? senha2TextController;
  late bool senha2Visibility;
  String? Function(BuildContext, String?)? senha2TextControllerValidator;
  // Stores action output result for [Backend Call - API (Atualizar senha)] action in Button widget.
  ApiCallResponse? apiResultqd3;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
    senhaVisibility = false;
    senha2Visibility = false;
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    senhaFocusNode?.dispose();
    senhaTextController?.dispose();

    senha2FocusNode?.dispose();
    senha2TextController?.dispose();
  }
}
