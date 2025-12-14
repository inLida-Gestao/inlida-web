import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'cc_add_semen_widget.dart' show CcAddSemenWidget;
import 'package:flutter/material.dart';

class CcAddSemenModel extends FlutterFlowModel<CcAddSemenWidget> {
  ///  Local state fields for this component.

  String? idRebanho;

  List<String> animaisLote = [];
  void addToAnimaisLote(String item) => animaisLote.add(item);
  void removeFromAnimaisLote(String item) => animaisLote.remove(item);
  void removeAtIndexFromAnimaisLote(int index) => animaisLote.removeAt(index);
  void insertAtIndexInAnimaisLote(int index, String item) =>
      animaisLote.insert(index, item);
  void updateAnimaisLoteAtIndex(int index, Function(String) updateFn) =>
      animaisLote[index] = updateFn(animaisLote[index]);

  ///  State fields for stateful widgets in this component.

  // State field(s) for numAnimal widget.
  FocusNode? numAnimalFocusNode;
  TextEditingController? numAnimalTextController;
  String? Function(BuildContext, String?)? numAnimalTextControllerValidator;
  // State field(s) for codRegistro widget.
  FocusNode? codRegistroFocusNode;
  TextEditingController? codRegistroTextController;
  String? Function(BuildContext, String?)? codRegistroTextControllerValidator;
  // State field(s) for nomeAnimal widget.
  FocusNode? nomeAnimalFocusNode;
  TextEditingController? nomeAnimalTextController;
  String? Function(BuildContext, String?)? nomeAnimalTextControllerValidator;
  // State field(s) for DropDownRaca widget.
  String? dropDownRacaValue;
  FormFieldController<String>? dropDownRacaValueController;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    numAnimalFocusNode?.dispose();
    numAnimalTextController?.dispose();

    codRegistroFocusNode?.dispose();
    codRegistroTextController?.dispose();

    nomeAnimalFocusNode?.dispose();
    nomeAnimalTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();
  }
}
