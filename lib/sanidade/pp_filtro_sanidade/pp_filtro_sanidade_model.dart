import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_sanidade_widget.dart' show PpFiltroSanidadeWidget;
import 'package:flutter/material.dart';

class PpFiltroSanidadeModel extends FlutterFlowModel<PpFiltroSanidadeWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for dataSanidade widget.
  FocusNode? dataSanidadeFocusNode;
  TextEditingController? dataSanidadeTextController;
  String? Function(BuildContext, String?)? dataSanidadeTextControllerValidator;
  DateTime? datePicked1;
  // State field(s) for DropDownLote widget.
  String? dropDownLoteValue;
  FormFieldController<String>? dropDownLoteValueController;
  // State field(s) for DropDownStatus widget.
  String? dropDownStatusValue;
  FormFieldController<String>? dropDownStatusValueController;
  // State field(s) for DropDownSexo widget.
  String? dropDownSexoValue;
  FormFieldController<String>? dropDownSexoValueController;
  // State field(s) for dataNascimento widget.
  FocusNode? dataNascimentoFocusNode;
  TextEditingController? dataNascimentoTextController;
  String? Function(BuildContext, String?)?
      dataNascimentoTextControllerValidator;
  DateTime? datePicked2;
  // State field(s) for DropDownRaca widget.
  String? dropDownRacaValue;
  FormFieldController<String>? dropDownRacaValueController;
  // State field(s) for DDCatRebanhoFemea widget.
  String? dDCatRebanhoFemeaValue;
  FormFieldController<String>? dDCatRebanhoFemeaValueController;
  // State field(s) for DDCatRebanhoMacho widget.
  String? dDCatRebanhoMachoValue;
  FormFieldController<String>? dDCatRebanhoMachoValueController;
  // State field(s) for DropDownTratamento widget.
  String? dropDownTratamentoValue;
  FormFieldController<String>? dropDownTratamentoValueController;
  // State field(s) for DropDownOrigem widget.
  String? dropDownOrigemValue1;
  FormFieldController<String>? dropDownOrigemValueController1;
  // State field(s) for DropDownOrigem widget.
  String? dropDownOrigemValue2;
  FormFieldController<String>? dropDownOrigemValueController2;
  // State field(s) for DropDownOrigem widget.
  String? dropDownOrigemValue3;
  FormFieldController<String>? dropDownOrigemValueController3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataSanidadeFocusNode?.dispose();
    dataSanidadeTextController?.dispose();

    dataNascimentoFocusNode?.dispose();
    dataNascimentoTextController?.dispose();
  }
}
