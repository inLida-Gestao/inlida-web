import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_sanidade_widget.dart' show PpFiltroSanidadeWidget;
import 'package:flutter/material.dart';

class PpFiltroSanidadeModel extends FlutterFlowModel<PpFiltroSanidadeWidget> {
  ///  State fields for stateful widgets in this component.

  // Cached future for lotes query to avoid refetching on every rebuild.
  Future<List<LotesRow>>? lotesFuture;

  // State field(s) for dataSanidadeDe widget.
  FocusNode? dataSanidadeDeFocusNode;
  TextEditingController? dataSanidadeDeTextController;
  String? Function(BuildContext, String?)? dataSanidadeDeTextControllerValidator;
  DateTime? datePickedSanidadeDe;
  // State field(s) for dataSanidadeAte widget.
  FocusNode? dataSanidadeAteFocusNode;
  TextEditingController? dataSanidadeAteTextController;
  String? Function(BuildContext, String?)? dataSanidadeAteTextControllerValidator;
  DateTime? datePickedSanidadeAte;
  // State field(s) for DropDownLote widget.
  String? dropDownLoteValue;
  FormFieldController<String>? dropDownLoteValueController;
  // State field(s) for DropDownStatus widget.
  String? dropDownStatusValue;
  FormFieldController<String>? dropDownStatusValueController;
  // State field(s) for DropDownSexo widget.
  String? dropDownSexoValue;
  FormFieldController<String>? dropDownSexoValueController;
  // State field(s) for dataNascimentoDe widget.
  FocusNode? dataNascimentoDeFocusNode;
  TextEditingController? dataNascimentoDeTextController;
  String? Function(BuildContext, String?)?
      dataNascimentoDeTextControllerValidator;
  DateTime? datePickedNascDe;
  // State field(s) for dataNascimentoAte widget.
  FocusNode? dataNascimentoAteFocusNode;
  TextEditingController? dataNascimentoAteTextController;
  String? Function(BuildContext, String?)?
      dataNascimentoAteTextControllerValidator;
  DateTime? datePickedNascAte;
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
  List<String>? dropDownTratamentoValue;
  FormFieldController<List<String>>? dropDownTratamentoValueController;
  // State field(s) for DropDownProtocolo widget.
  List<String>? dropDownOrigemValue1;
  FormFieldController<List<String>>? dropDownOrigemValueController1;
  // State field(s) for DropDownAntiparasitario widget.
  List<String>? dropDownOrigemValue2;
  FormFieldController<List<String>>? dropDownOrigemValueController2;
  // State field(s) for DropDownVacinacao widget.
  List<String>? dropDownOrigemValue3;
  FormFieldController<List<String>>? dropDownOrigemValueController3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataSanidadeDeFocusNode?.dispose();
    dataSanidadeDeTextController?.dispose();
    dataSanidadeAteFocusNode?.dispose();
    dataSanidadeAteTextController?.dispose();

    dataNascimentoDeFocusNode?.dispose();
    dataNascimentoDeTextController?.dispose();
    dataNascimentoAteFocusNode?.dispose();
    dataNascimentoAteTextController?.dispose();
  }
}
