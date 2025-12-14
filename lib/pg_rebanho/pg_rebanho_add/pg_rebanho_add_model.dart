import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'pg_rebanho_add_widget.dart' show PgRebanhoAddWidget;
import 'package:flutter/material.dart';

class PgRebanhoAddModel extends FlutterFlowModel<PgRebanhoAddWidget> {
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
  // State field(s) for dataMovimentacao widget.
  FocusNode? dataMovimentacaoFocusNode1;
  TextEditingController? dataMovimentacaoTextController1;
  String? Function(BuildContext, String?)?
      dataMovimentacaoTextController1Validator;
  DateTime? datePicked5;
  // State field(s) for dataMovimentacao widget.
  FocusNode? dataMovimentacaoFocusNode2;
  TextEditingController? dataMovimentacaoTextController2;
  String? Function(BuildContext, String?)?
      dataMovimentacaoTextController2Validator;
  DateTime? datePicked6;
  // State field(s) for dataMovimentacao widget.
  FocusNode? dataMovimentacaoFocusNode3;
  TextEditingController? dataMovimentacaoTextController3;
  String? Function(BuildContext, String?)?
      dataMovimentacaoTextController3Validator;
  DateTime? datePicked7;
  // State field(s) for DropDownMotivoMorte widget.
  String? dropDownMotivoMorteValue;
  FormFieldController<String>? dropDownMotivoMorteValueController;
  // State field(s) for dataAcao widget.
  FocusNode? dataAcaoFocusNode;
  TextEditingController? dataAcaoTextController;
  String? Function(BuildContext, String?)? dataAcaoTextControllerValidator;
  DateTime? datePicked8;
  // State field(s) for dataVenda widget.
  FocusNode? dataVendaFocusNode;
  TextEditingController? dataVendaTextController;
  String? Function(BuildContext, String?)? dataVendaTextControllerValidator;
  DateTime? datePicked9;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<LotesRow>? loteSelecionado;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
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

    dataMovimentacaoFocusNode1?.dispose();
    dataMovimentacaoTextController1?.dispose();

    dataMovimentacaoFocusNode2?.dispose();
    dataMovimentacaoTextController2?.dispose();

    dataMovimentacaoFocusNode3?.dispose();
    dataMovimentacaoTextController3?.dispose();

    dataAcaoFocusNode?.dispose();
    dataAcaoTextController?.dispose();

    dataVendaFocusNode?.dispose();
    dataVendaTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();
  }
}
