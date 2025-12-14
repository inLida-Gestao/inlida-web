import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pg_sanidade_add_animal_widget.dart' show PgSanidadeAddAnimalWidget;
import 'package:flutter/material.dart';

class PgSanidadeAddAnimalModel
    extends FlutterFlowModel<PgSanidadeAddAnimalWidget> {
  ///  Local state fields for this page.

  String? animalSelecionadoId;

  String? animalSelecionadoNome;

  DateTime? dataSanidade;

  List<String> tiposSelecionados = [];
  void addToTiposSelecionados(String item) => tiposSelecionados.add(item);
  void removeFromTiposSelecionados(String item) =>
      tiposSelecionados.remove(item);
  void removeAtIndexFromTiposSelecionados(int index) =>
      tiposSelecionados.removeAt(index);
  void insertAtIndexInTiposSelecionados(int index, String item) =>
      tiposSelecionados.insert(index, item);
  void updateTiposSelecionadosAtIndex(int index, Function(String) updateFn) =>
      tiposSelecionados[index] = updateFn(tiposSelecionados[index]);

  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for vacinaDropdown widget.
  String? vacinaDropdownValue;
  FormFieldController<String>? vacinaDropdownValueController;
  // State field(s) for vacinaOutros widget.
  FocusNode? vacinaOutrosFocusNode;
  TextEditingController? vacinaOutrosTextController;
  String? Function(BuildContext, String?)? vacinaOutrosTextControllerValidator;
  // State field(s) for vacinaObs widget.
  FocusNode? vacinaObsFocusNode;
  TextEditingController? vacinaObsTextController;
  String? Function(BuildContext, String?)? vacinaObsTextControllerValidator;
  // State field(s) for antiparasitarioDropdown widget.
  String? antiparasitarioDropdownValue;
  FormFieldController<String>? antiparasitarioDropdownValueController;
  // State field(s) for antiparasitarioOutros widget.
  FocusNode? antiparasitarioOutrosFocusNode;
  TextEditingController? antiparasitarioOutrosTextController;
  String? Function(BuildContext, String?)?
      antiparasitarioOutrosTextControllerValidator;
  // State field(s) for antiparasitarioObs widget.
  FocusNode? antiparasitarioObsFocusNode;
  TextEditingController? antiparasitarioObsTextController;
  String? Function(BuildContext, String?)?
      antiparasitarioObsTextControllerValidator;
  // State field(s) for tratamentoDropdown widget.
  String? tratamentoDropdownValue;
  FormFieldController<String>? tratamentoDropdownValueController;
  // State field(s) for tratamentoOutros widget.
  FocusNode? tratamentoOutrosFocusNode;
  TextEditingController? tratamentoOutrosTextController;
  String? Function(BuildContext, String?)?
      tratamentoOutrosTextControllerValidator;
  // State field(s) for tratamentoObs widget.
  FocusNode? tratamentoObsFocusNode;
  TextEditingController? tratamentoObsTextController;
  String? Function(BuildContext, String?)? tratamentoObsTextControllerValidator;
  // State field(s) for protocoloDropdown widget.
  String? protocoloDropdownValue;
  FormFieldController<String>? protocoloDropdownValueController;
  // State field(s) for protocoloOutros widget.
  FocusNode? protocoloOutrosFocusNode;
  TextEditingController? protocoloOutrosTextController;
  String? Function(BuildContext, String?)?
      protocoloOutrosTextControllerValidator;
  // State field(s) for protocoloObs widget.
  FocusNode? protocoloObsFocusNode;
  TextEditingController? protocoloObsTextController;
  String? Function(BuildContext, String?)? protocoloObsTextControllerValidator;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();

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
