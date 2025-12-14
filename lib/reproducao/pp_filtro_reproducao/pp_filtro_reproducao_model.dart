import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_reproducao_widget.dart' show PpFiltroReproducaoWidget;
import 'package:flutter/material.dart';

class PpFiltroReproducaoModel
    extends FlutterFlowModel<PpFiltroReproducaoWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for dataNascimento widget.
  FocusNode? dataNascimentoFocusNode1;
  TextEditingController? dataNascimentoTextController1;
  String? Function(BuildContext, String?)?
      dataNascimentoTextController1Validator;
  DateTime? datePicked1;
  // State field(s) for dataNascimento widget.
  FocusNode? dataNascimentoFocusNode2;
  TextEditingController? dataNascimentoTextController2;
  String? Function(BuildContext, String?)?
      dataNascimentoTextController2Validator;
  DateTime? datePicked2;
  // State field(s) for DDCatRebanho widget.
  String? dDCatRebanhoValue;
  FormFieldController<String>? dDCatRebanhoValueController;
  // State field(s) for DropDownLote widget.
  String? dropDownLoteValue;
  FormFieldController<String>? dropDownLoteValueController;
  // State field(s) for DropDownInseminador widget.
  String? dropDownInseminadorValue;
  FormFieldController<String>? dropDownInseminadorValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataNascimentoFocusNode1?.dispose();
    dataNascimentoTextController1?.dispose();

    dataNascimentoFocusNode2?.dispose();
    dataNascimentoTextController2?.dispose();
  }
}
