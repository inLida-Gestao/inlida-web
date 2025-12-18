import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'cc_add_sanidade_lote_widget.dart' show CcAddSanidadeLoteWidget;
import 'package:flutter/material.dart';

class CcAddSanidadeLoteModel extends FlutterFlowModel<CcAddSanidadeLoteWidget> {
  ///  Local state fields for this component.

  DateTime? dataSanidade;
  List<String> tiposSelecionados = [];

  ///  State fields for stateful widgets in this component.

  // State field(s) for loteDropdown widget.
  String? loteDropdownValue;
  FormFieldController<String>? loteDropdownValueController;
  // State field(s) for porcentagem widget.
  FocusNode? porcentagemFocusNode;
  TextEditingController? porcentagemTextController;
  // State field(s) for vacinaDropdown widget.
  List<String>? vacinaDropdownValue;
  FormListFieldController<String>? vacinaDropdownValueController;
  // State field(s) for vacinaOutros widget.
  FocusNode? vacinaOutrosFocusNode;
  TextEditingController? vacinaOutrosTextController;
  // State field(s) for vacinaObs widget.
  FocusNode? vacinaObsFocusNode;
  TextEditingController? vacinaObsTextController;
  // State field(s) for antiparasitarioDropdown widget.
  List<String>? antiparasitarioDropdownValue;
  FormListFieldController<String>? antiparasitarioDropdownValueController;
  // State field(s) for antiparasitarioOutros widget.
  FocusNode? antiparasitarioOutrosFocusNode;
  TextEditingController? antiparasitarioOutrosTextController;
  // State field(s) for antiparasitarioObs widget.
  FocusNode? antiparasitarioObsFocusNode;
  TextEditingController? antiparasitarioObsTextController;
  // State field(s) for tratamentoDropdown widget.
  List<String>? tratamentoDropdownValue;
  FormListFieldController<String>? tratamentoDropdownValueController;
  // State field(s) for tratamentoOutros widget.
  FocusNode? tratamentoOutrosFocusNode;
  TextEditingController? tratamentoOutrosTextController;
  // State field(s) for tratamentoObs widget.
  FocusNode? tratamentoObsFocusNode;
  TextEditingController? tratamentoObsTextController;
  // State field(s) for protocoloDropdown widget.
  String? protocoloDropdownValue;
  FormFieldController<String>? protocoloDropdownValueController;
  // State field(s) for protocoloD0Dropdown widget.
  String? protocoloD0DropdownValue;
  FormFieldController<String>? protocoloD0DropdownValueController;
  // State field(s) for protocoloRetiradaDropdown widget.
  String? protocoloRetiradaDropdownValue;
  FormFieldController<String>? protocoloRetiradaDropdownValueController;
  // State field(s) for protocoloIatfDropdown widget.
  String? protocoloIatfDropdownValue;
  FormFieldController<String>? protocoloIatfDropdownValueController;
  // State field(s) for protocoloOutros widget.
  FocusNode? protocoloOutrosFocusNode;
  TextEditingController? protocoloOutrosTextController;
  // State field(s) for protocoloObs widget.
  FocusNode? protocoloObsFocusNode;
  TextEditingController? protocoloObsTextController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    porcentagemFocusNode?.dispose();
    porcentagemTextController?.dispose();
    vacinaOutrosFocusNode?.dispose();
    vacinaOutrosTextController?.dispose();
    vacinaObsFocusNode?.dispose();
    vacinaObsTextController?.dispose();
    antiparasitarioOutrosFocusNode?.dispose();
    antiparasitarioOutrosTextController?.dispose();
    antiparasitarioObsFocusNode?.dispose();
    antiparasitarioObsTextController?.dispose();
    tratamentoOutrosFocusNode?.dispose();
    tratamentoOutrosTextController?.dispose();
    tratamentoObsFocusNode?.dispose();
    tratamentoObsTextController?.dispose();
    protocoloOutrosFocusNode?.dispose();
    protocoloOutrosTextController?.dispose();
    protocoloObsFocusNode?.dispose();
    protocoloObsTextController?.dispose();
  }
}
