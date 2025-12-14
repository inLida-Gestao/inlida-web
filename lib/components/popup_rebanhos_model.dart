import '/flutter_flow/flutter_flow_util.dart';
import 'popup_rebanhos_widget.dart' show PopupRebanhosWidget;
import 'package:flutter/material.dart';

class PopupRebanhosModel extends FlutterFlowModel<PopupRebanhosWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for pesquisar widget.
  FocusNode? pesquisarFocusNode;
  TextEditingController? pesquisarTextController;
  String? Function(BuildContext, String?)? pesquisarTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    pesquisarFocusNode?.dispose();
    pesquisarTextController?.dispose();
  }
}
