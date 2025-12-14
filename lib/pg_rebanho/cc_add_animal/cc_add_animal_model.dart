import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'cc_add_animal_widget.dart' show CcAddAnimalWidget;
import 'package:flutter/material.dart';

class CcAddAnimalModel extends FlutterFlowModel<CcAddAnimalWidget> {
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

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for numAnimal widget.
  FocusNode? numAnimalFocusNode;
  TextEditingController? numAnimalTextController;
  String? Function(BuildContext, String?)? numAnimalTextControllerValidator;
  // State field(s) for chip widget.
  FocusNode? chipFocusNode;
  TextEditingController? chipTextController;
  String? Function(BuildContext, String?)? chipTextControllerValidator;
  // State field(s) for codRegistro widget.
  FocusNode? codRegistroFocusNode;
  TextEditingController? codRegistroTextController;
  String? Function(BuildContext, String?)? codRegistroTextControllerValidator;
  // State field(s) for nomeAnimal widget.
  FocusNode? nomeAnimalFocusNode;
  TextEditingController? nomeAnimalTextController;
  String? Function(BuildContext, String?)? nomeAnimalTextControllerValidator;
  // State field(s) for DropDownSexo widget.
  String? dropDownSexoValue;
  FormFieldController<String>? dropDownSexoValueController;
  // State field(s) for dataNascimento widget.
  FocusNode? dataNascimentoFocusNode;
  TextEditingController? dataNascimentoTextController;
  String? Function(BuildContext, String?)?
      dataNascimentoTextControllerValidator;
  DateTime? datePicked1;
  // State field(s) for pesoNascimento widget.
  FocusNode? pesoNascimentoFocusNode;
  TextEditingController? pesoNascimentoTextController;
  String? Function(BuildContext, String?)?
      pesoNascimentoTextControllerValidator;
  // State field(s) for DropDownPorte widget.
  String? dropDownPorteValue;
  FormFieldController<String>? dropDownPorteValueController;
  // State field(s) for DDCatRebanhoFemea widget.
  String? dDCatRebanhoFemeaValue;
  FormFieldController<String>? dDCatRebanhoFemeaValueController;
  // State field(s) for DDCatRebanhoMacho widget.
  String? dDCatRebanhoMachoValue;
  FormFieldController<String>? dDCatRebanhoMachoValueController;
  // State field(s) for DropDownRaca widget.
  String? dropDownRacaValue;
  FormFieldController<String>? dropDownRacaValueController;
  // State field(s) for DropDownLotes widget.
  String? dropDownLotesValue;
  FormFieldController<String>? dropDownLotesValueController;
  // State field(s) for dataEntradaLote widget.
  FocusNode? dataEntradaLoteFocusNode;
  TextEditingController? dataEntradaLoteTextController;
  String? Function(BuildContext, String?)?
      dataEntradaLoteTextControllerValidator;
  DateTime? datePicked2;
  // State field(s) for DropDownMatriz widget.
  String? dropDownMatrizValue;
  FormFieldController<String>? dropDownMatrizValueController;
  // State field(s) for DropDownReprodutor widget.
  String? dropDownReprodutorValue;
  FormFieldController<String>? dropDownReprodutorValueController;
  // State field(s) for dataDesmama widget.
  FocusNode? dataDesmamaFocusNode;
  TextEditingController? dataDesmamaTextController;
  String? Function(BuildContext, String?)? dataDesmamaTextControllerValidator;
  DateTime? datePicked3;
  // State field(s) for pesoDesmama widget.
  FocusNode? pesoDesmamaFocusNode;
  TextEditingController? pesoDesmamaTextController;
  String? Function(BuildContext, String?)? pesoDesmamaTextControllerValidator;
  // State field(s) for dataUltimaPesagem widget.
  FocusNode? dataUltimaPesagemFocusNode;
  TextEditingController? dataUltimaPesagemTextController;
  String? Function(BuildContext, String?)?
      dataUltimaPesagemTextControllerValidator;
  DateTime? datePicked4;
  // State field(s) for pesoAtual widget.
  FocusNode? pesoAtualFocusNode;
  TextEditingController? pesoAtualTextController;
  String? Function(BuildContext, String?)? pesoAtualTextControllerValidator;
  // State field(s) for DropDownStatus widget.
  String? dropDownStatusValue;
  FormFieldController<String>? dropDownStatusValueController;
  // State field(s) for DropDownOrigem widget.
  String? dropDownOrigemValue;
  FormFieldController<String>? dropDownOrigemValueController;
  // State field(s) for dataAcao widget.
  FocusNode? dataAcaoFocusNode;
  TextEditingController? dataAcaoTextController;
  String? Function(BuildContext, String?)? dataAcaoTextControllerValidator;
  DateTime? datePicked5;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<LotesRow>? loteSelecionado;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    numAnimalFocusNode?.dispose();
    numAnimalTextController?.dispose();

    chipFocusNode?.dispose();
    chipTextController?.dispose();

    codRegistroFocusNode?.dispose();
    codRegistroTextController?.dispose();

    nomeAnimalFocusNode?.dispose();
    nomeAnimalTextController?.dispose();

    dataNascimentoFocusNode?.dispose();
    dataNascimentoTextController?.dispose();

    pesoNascimentoFocusNode?.dispose();
    pesoNascimentoTextController?.dispose();

    dataEntradaLoteFocusNode?.dispose();
    dataEntradaLoteTextController?.dispose();

    dataDesmamaFocusNode?.dispose();
    dataDesmamaTextController?.dispose();

    pesoDesmamaFocusNode?.dispose();
    pesoDesmamaTextController?.dispose();

    dataUltimaPesagemFocusNode?.dispose();
    dataUltimaPesagemTextController?.dispose();

    pesoAtualFocusNode?.dispose();
    pesoAtualTextController?.dispose();

    dataAcaoFocusNode?.dispose();
    dataAcaoTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();
  }
}
