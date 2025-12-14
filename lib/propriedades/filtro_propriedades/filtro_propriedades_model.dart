import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'filtro_propriedades_widget.dart' show FiltroPropriedadesWidget;
import 'package:flutter/material.dart';

class FiltroPropriedadesModel
    extends FlutterFlowModel<FiltroPropriedadesWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for DropDownCidade widget.
  String? dropDownCidadeValue;
  FormFieldController<String>? dropDownCidadeValueController;
  // State field(s) for DropDownUF widget.
  String? dropDownUFValue;
  FormFieldController<String>? dropDownUFValueController;
  // State field(s) for DropDownAtividades widget.
  List<String>? dropDownAtividadesValue;
  FormFieldController<List<String>>? dropDownAtividadesValueController;
  // State field(s) for Slider widget.
  double? sliderValue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
