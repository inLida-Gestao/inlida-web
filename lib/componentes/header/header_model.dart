import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'header_widget.dart' show HeaderWidget;
import 'package:flutter/material.dart';

class HeaderModel extends FlutterFlowModel<HeaderWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Backend Call - Query Rows] action in DropDown widget.
  List<PropriedadesRow>? propriedade;
  // Stores action output result for [Backend Call - API (QTD Rebanho Propriedades)] action in DropDown widget.
  ApiCallResponse? qtdAnimais;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
