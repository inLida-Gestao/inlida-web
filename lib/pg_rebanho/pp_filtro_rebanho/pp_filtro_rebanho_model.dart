import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_rebanho_widget.dart' show PpFiltroRebanhoWidget;
import 'package:flutter/material.dart';

class PpFiltroRebanhoModel extends FlutterFlowModel<PpFiltroRebanhoWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for DropDownSexo widget.
  String? dropDownSexoValue;
  FormFieldController<String>? dropDownSexoValueController;
  // State field(s) for DropDownStatus widget.
  String? dropDownStatusValue;
  FormFieldController<String>? dropDownStatusValueController;
  // State field(s) for dataNascimentoDe widget.
  FocusNode? dataNascimentoDeFocusNode;
  TextEditingController? dataNascimentoDeTextController;
  String? Function(BuildContext, String?)?
      dataNascimentoDeTextControllerValidator;
  DateTime? datePickedDe;
  // State field(s) for dataNascimentoAte widget.
  FocusNode? dataNascimentoAteFocusNode;
  TextEditingController? dataNascimentoAteTextController;
  String? Function(BuildContext, String?)?
      dataNascimentoAteTextControllerValidator;
  DateTime? datePickedAte;
  // State field(s) for DropDownLote widget.
  List<String>? dropDownLoteValues;
  FormFieldController<List<String>>? dropDownLoteValueController;
  // State field(s) for DDCatRebanhoFemea widget.
  String? dDCatRebanhoFemeaValue;
  FormFieldController<String>? dDCatRebanhoFemeaValueController;
  // State field(s) for DDCatRebanhoMacho widget.
  String? dDCatRebanhoMachoValue;
  FormFieldController<String>? dDCatRebanhoMachoValueController;
  // State field(s) for DropDownRaca widget.
  String? dropDownRacaValue;
  FormFieldController<String>? dropDownRacaValueController;
  // State field(s) for DropDownOrigem widget.
  String? dropDownOrigemValue;
  FormFieldController<String>? dropDownOrigemValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataNascimentoDeFocusNode?.dispose();
    dataNascimentoDeTextController?.dispose();
    dataNascimentoAteFocusNode?.dispose();
    dataNascimentoAteTextController?.dispose();
  }
}
