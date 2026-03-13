import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_piquete_widget.dart' show PpFiltroPiqueteWidget;
import 'package:flutter/material.dart';

class PpFiltroPiqueteModel extends FlutterFlowModel<PpFiltroPiqueteWidget> {
  /// State fields for filter dropdowns.
  String? dDForrageiraValue;
  FormFieldController<String>? dDForrageiraValueController;

  double areaMin = 0;
  double areaMax = 9999;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dDForrageiraValueController?.dispose();
  }
}
