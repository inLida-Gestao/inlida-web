import '/flutter_flow/flutter_flow_util.dart';
import 'pp_add_pessagem_widget.dart' show PpAddPessagemWidget;
import 'package:flutter/material.dart';

class PpAddPessagemModel extends FlutterFlowModel<PpAddPessagemWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for dataPesagem widget.
  FocusNode? dataPesagemFocusNode;
  TextEditingController? dataPesagemTextController;
  String? Function(BuildContext, String?)? dataPesagemTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for pesoAdd widget.
  FocusNode? pesoAddFocusNode;
  TextEditingController? pesoAddTextController;
  String? Function(BuildContext, String?)? pesoAddTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataPesagemFocusNode?.dispose();
    dataPesagemTextController?.dispose();

    pesoAddFocusNode?.dispose();
    pesoAddTextController?.dispose();
  }
}
