import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:async';
import '/index.dart';
import 'pg_rebanho_view_widget.dart' show PgRebanhoViewWidget;
import 'package:flutter/material.dart';

class PgRebanhoViewModel extends FlutterFlowModel<PgRebanhoViewWidget> {
  ///  Local state fields for this page.

  List<String> lista = ['Eduardo', 'Jorge', 'Lindinha', 'Mimosa'];
  void addToLista(String item) => lista.add(item);
  void removeFromLista(String item) => lista.remove(item);
  void removeAtIndexFromLista(int index) => lista.removeAt(index);
  void insertAtIndexInLista(int index, String item) =>
      lista.insert(index, item);
  void updateListaAtIndex(int index, Function(String) updateFn) =>
      lista[index] = updateFn(lista[index]);

  String stap = 'rebanho';

  String? id;

  String? nome;

  RebanhoRow? animalSelecionado;

  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  Completer<List<HistoricoPesagensRow>>? requestCompleter;
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

  // State field(s) for nomeAnimal widget.
  FocusNode? nomeAnimalFocusNode1;
  TextEditingController? nomeAnimalTextController1;
  String? Function(BuildContext, String?)? nomeAnimalTextController1Validator;
  // State field(s) for chip widget.
  FocusNode? chipFocusNode;
  TextEditingController? chipTextController;
  String? Function(BuildContext, String?)? chipTextControllerValidator;
  // State field(s) for codRegistro widget.
  FocusNode? codRegistroFocusNode;
  TextEditingController? codRegistroTextController;
  String? Function(BuildContext, String?)? codRegistroTextControllerValidator;
  // State field(s) for nomeAnimal widget.
  FocusNode? nomeAnimalFocusNode2;
  TextEditingController? nomeAnimalTextController2;
  String? Function(BuildContext, String?)? nomeAnimalTextController2Validator;
  // State field(s) for sexo widget.
  FocusNode? sexoFocusNode;
  TextEditingController? sexoTextController;
  String? Function(BuildContext, String?)? sexoTextControllerValidator;
  // State field(s) for pesoNascimento widget.
  FocusNode? pesoNascimentoFocusNode1;
  TextEditingController? pesoNascimentoTextController1;
  String? Function(BuildContext, String?)?
      pesoNascimentoTextController1Validator;
  // State field(s) for pesoNascimento widget.
  FocusNode? pesoNascimentoFocusNode2;
  TextEditingController? pesoNascimentoTextController2;
  String? Function(BuildContext, String?)?
      pesoNascimentoTextController2Validator;
  // State field(s) for porte widget.
  FocusNode? porteFocusNode1;
  TextEditingController? porteTextController1;
  String? Function(BuildContext, String?)? porteTextController1Validator;
  // State field(s) for categoria widget.
  FocusNode? categoriaFocusNode;
  TextEditingController? categoriaTextController;
  String? Function(BuildContext, String?)? categoriaTextControllerValidator;
  // State field(s) for raca widget.
  FocusNode? racaFocusNode;
  TextEditingController? racaTextController;
  String? Function(BuildContext, String?)? racaTextControllerValidator;
  // State field(s) for porte widget.
  FocusNode? porteFocusNode2;
  TextEditingController? porteTextController2;
  String? Function(BuildContext, String?)? porteTextController2Validator;
  // State field(s) for porte widget.
  FocusNode? porteFocusNode3;
  TextEditingController? porteTextController3;
  String? Function(BuildContext, String?)? porteTextController3Validator;
  // State field(s) for matriz widget.
  FocusNode? matrizFocusNode;
  TextEditingController? matrizTextController;
  String? Function(BuildContext, String?)? matrizTextControllerValidator;
  // State field(s) for reprodutor widget.
  FocusNode? reprodutorFocusNode;
  TextEditingController? reprodutorTextController;
  String? Function(BuildContext, String?)? reprodutorTextControllerValidator;
  // State field(s) for dataDesmama widget.
  FocusNode? dataDesmamaFocusNode1;
  TextEditingController? dataDesmamaTextController1;
  String? Function(BuildContext, String?)? dataDesmamaTextController1Validator;
  // State field(s) for pesoDesmama widget.
  FocusNode? pesoDesmamaFocusNode1;
  TextEditingController? pesoDesmamaTextController1;
  String? Function(BuildContext, String?)? pesoDesmamaTextController1Validator;
  // State field(s) for dataDesmama widget.
  FocusNode? dataDesmamaFocusNode2;
  TextEditingController? dataDesmamaTextController2;
  String? Function(BuildContext, String?)? dataDesmamaTextController2Validator;
  // State field(s) for pesoDesmama widget.
  FocusNode? pesoDesmamaFocusNode2;
  TextEditingController? pesoDesmamaTextController2;
  String? Function(BuildContext, String?)? pesoDesmamaTextController2Validator;
  // State field(s) for dataDesmama widget.
  FocusNode? dataDesmamaFocusNode3;
  TextEditingController? dataDesmamaTextController3;
  String? Function(BuildContext, String?)? dataDesmamaTextController3Validator;
  // State field(s) for pesoDesmama widget.
  FocusNode? pesoDesmamaFocusNode3;
  TextEditingController? pesoDesmamaTextController3;
  String? Function(BuildContext, String?)? pesoDesmamaTextController3Validator;
  // State field(s) for dataDesmama widget.
  FocusNode? dataDesmamaFocusNode4;
  TextEditingController? dataDesmamaTextController4;
  String? Function(BuildContext, String?)? dataDesmamaTextController4Validator;
  // State field(s) for pesoDesmama widget.
  FocusNode? pesoDesmamaFocusNode4;
  TextEditingController? pesoDesmamaTextController4;
  String? Function(BuildContext, String?)? pesoDesmamaTextController4Validator;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController1 =
      FlutterFlowDataTableController<AnimaisStruct>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController2 =
      FlutterFlowDataTableController<HistoricoPesagensRow>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController3 =
      FlutterFlowDataTableController<ReproducaoRow>();
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController4 =
      FlutterFlowDataTableController<ReproducaoRow>();
    // State field(s) for PaginatedDataTable widget.
    final paginatedDataTableController5 =
      FlutterFlowDataTableController<SanidadeRow>();
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? matriz;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? reprodutor2;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    instantTimer?.cancel();
    headerModel.dispose();
    sideBarModel.dispose();
    tabBarController?.dispose();
    nomeAnimalFocusNode1?.dispose();
    nomeAnimalTextController1?.dispose();

    chipFocusNode?.dispose();
    chipTextController?.dispose();

    codRegistroFocusNode?.dispose();
    codRegistroTextController?.dispose();

    nomeAnimalFocusNode2?.dispose();
    nomeAnimalTextController2?.dispose();

    sexoFocusNode?.dispose();
    sexoTextController?.dispose();

    pesoNascimentoFocusNode1?.dispose();
    pesoNascimentoTextController1?.dispose();

    pesoNascimentoFocusNode2?.dispose();
    pesoNascimentoTextController2?.dispose();

    porteFocusNode1?.dispose();
    porteTextController1?.dispose();

    categoriaFocusNode?.dispose();
    categoriaTextController?.dispose();

    racaFocusNode?.dispose();
    racaTextController?.dispose();

    porteFocusNode2?.dispose();
    porteTextController2?.dispose();

    porteFocusNode3?.dispose();
    porteTextController3?.dispose();

    matrizFocusNode?.dispose();
    matrizTextController?.dispose();

    reprodutorFocusNode?.dispose();
    reprodutorTextController?.dispose();

    dataDesmamaFocusNode1?.dispose();
    dataDesmamaTextController1?.dispose();

    pesoDesmamaFocusNode1?.dispose();
    pesoDesmamaTextController1?.dispose();

    dataDesmamaFocusNode2?.dispose();
    dataDesmamaTextController2?.dispose();

    pesoDesmamaFocusNode2?.dispose();
    pesoDesmamaTextController2?.dispose();

    dataDesmamaFocusNode3?.dispose();
    dataDesmamaTextController3?.dispose();

    pesoDesmamaFocusNode3?.dispose();
    pesoDesmamaTextController3?.dispose();

    dataDesmamaFocusNode4?.dispose();
    dataDesmamaTextController4?.dispose();

    pesoDesmamaFocusNode4?.dispose();
    pesoDesmamaTextController4?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();

    paginatedDataTableController1.dispose();
    paginatedDataTableController2.dispose();
    paginatedDataTableController3.dispose();
    paginatedDataTableController4.dispose();
  }

  /// Additional helper methods.
  Future waitForRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
