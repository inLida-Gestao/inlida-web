import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'cc_add_sanidade_animal_widget.dart' show CcAddSanidadeAnimalWidget;
import 'package:flutter/material.dart';

class CcAddSanidadeAnimalModel
    extends FlutterFlowModel<CcAddSanidadeAnimalWidget> {
  ///  Local state fields for this component.

  String? animalSelecionadoId;
  String? animalSelecionadoNome;
  DateTime? dataSanidade;
  List<String> tiposSelecionados = [];

  ///  State fields for stateful widgets in this component.

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
  List<String>? protocoloDropdownValue;
  FormListFieldController<String>? protocoloDropdownValueController;
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
