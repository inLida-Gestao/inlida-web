import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'pg_rebanho_add_semen_widget.dart' show PgRebanhoAddSemenWidget;
import 'package:flutter/material.dart';

class PgRebanhoAddSemenModel extends FlutterFlowModel<PgRebanhoAddSemenWidget> {
  ///  Local state fields for this page.

  List<String> lista = ['Eduardo', 'Jorge', 'Lindinha', 'Mimosa'];
  void addToLista(String item) => lista.add(item);
  void removeFromLista(String item) => lista.remove(item);
  void removeAtIndexFromLista(int index) => lista.removeAt(index);
  void insertAtIndexInLista(int index, String item) =>
      lista.insert(index, item);
  void updateListaAtIndex(int index, Function(String) updateFn) =>
      lista[index] = updateFn(lista[index]);

  RebanhoRow? animalSelecionado;

  List<String> animaisLote = [];
  void addToAnimaisLote(String item) => animaisLote.add(item);
  void removeFromAnimaisLote(String item) => animaisLote.remove(item);
  void removeAtIndexFromAnimaisLote(int index) => animaisLote.removeAt(index);
  void insertAtIndexInAnimaisLote(int index, String item) =>
      animaisLote.insert(index, item);
  void updateAnimaisLoteAtIndex(int index, Function(String) updateFn) =>
      animaisLote[index] = updateFn(animaisLote[index]);

  String? idRebanho;

  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
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
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
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
