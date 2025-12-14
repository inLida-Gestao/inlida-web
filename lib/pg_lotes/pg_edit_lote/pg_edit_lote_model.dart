import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import '/index.dart';
import 'pg_edit_lote_widget.dart' show PgEditLoteWidget;
import 'package:flutter/material.dart';

class PgEditLoteModel extends FlutterFlowModel<PgEditLoteWidget> {
  ///  Local state fields for this page.

  int pageNumAdd = 1;

  List<RebanhoDTStruct> animaisDentroLote = [];
  void addToAnimaisDentroLote(RebanhoDTStruct item) =>
      animaisDentroLote.add(item);
  void removeFromAnimaisDentroLote(RebanhoDTStruct item) =>
      animaisDentroLote.remove(item);
  void removeAtIndexFromAnimaisDentroLote(int index) =>
      animaisDentroLote.removeAt(index);
  void insertAtIndexInAnimaisDentroLote(int index, RebanhoDTStruct item) =>
      animaisDentroLote.insert(index, item);
  void updateAnimaisDentroLoteAtIndex(
          int index, Function(RebanhoDTStruct) updateFn) =>
      animaisDentroLote[index] = updateFn(animaisDentroLote[index]);

  List<RebanhoDTStruct> animaisSelecionados = [];
  void addToAnimaisSelecionados(RebanhoDTStruct item) =>
      animaisSelecionados.add(item);
  void removeFromAnimaisSelecionados(RebanhoDTStruct item) =>
      animaisSelecionados.remove(item);
  void removeAtIndexFromAnimaisSelecionados(int index) =>
      animaisSelecionados.removeAt(index);
  void insertAtIndexInAnimaisSelecionados(int index, RebanhoDTStruct item) =>
      animaisSelecionados.insert(index, item);
  void updateAnimaisSelecionadosAtIndex(
          int index, Function(RebanhoDTStruct) updateFn) =>
      animaisSelecionados[index] = updateFn(animaisSelecionados[index]);

  int pageNumLT = 1;

  int mostrarAdicionados = 20;

  int index = 0;

  bool ativo = true;

  List<RebanhoDTStruct> animaisRetiradosLote = [];
  void addToAnimaisRetiradosLote(RebanhoDTStruct item) =>
      animaisRetiradosLote.add(item);
  void removeFromAnimaisRetiradosLote(RebanhoDTStruct item) =>
      animaisRetiradosLote.remove(item);
  void removeAtIndexFromAnimaisRetiradosLote(int index) =>
      animaisRetiradosLote.removeAt(index);
  void insertAtIndexInAnimaisRetiradosLote(int index, RebanhoDTStruct item) =>
      animaisRetiradosLote.insert(index, item);
  void updateAnimaisRetiradosLoteAtIndex(
          int index, Function(RebanhoDTStruct) updateFn) =>
      animaisRetiradosLote[index] = updateFn(animaisRetiradosLote[index]);

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in pgEditLote widget.
  List<LotesRow>? loteEdit;
  // Stores action output result for [Backend Call - API (Buscar Rebanho Filtros)] action in pgEditLote widget.
  ApiCallResponse? rebanhosLote;
  // Stores action output result for [Backend Call - Query Rows] action in pgEditLote widget.
  List<RebanhoRow>? rebanhoSelecionado;
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

  // State field(s) for nomeLote widget.
  FocusNode? nomeLoteFocusNode;
  TextEditingController? nomeLoteTextController;
  String? Function(BuildContext, String?)? nomeLoteTextControllerValidator;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // State field(s) for Switch widget.
  bool? switchValue;
  // State field(s) for DropDownLotes widget.
  String? dropDownLotesValue;
  FormFieldController<String>? dropDownLotesValueController;
  // State field(s) for dataEntradaLote widget.
  FocusNode? dataEntradaLoteFocusNode;
  TextEditingController? dataEntradaLoteTextController;
  String? Function(BuildContext, String?)?
      dataEntradaLoteTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for pesquisa widget.
  FocusNode? pesquisaFocusNode;
  TextEditingController? pesquisaTextController;
  String? Function(BuildContext, String?)? pesquisaTextControllerValidator;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for pesquisaDentro widget.
  FocusNode? pesquisaDentroFocusNode;
  TextEditingController? pesquisaDentroTextController;
  String? Function(BuildContext, String?)?
      pesquisaDentroTextControllerValidator;

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
    nomeLoteFocusNode?.dispose();
    nomeLoteTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();

    dataEntradaLoteFocusNode?.dispose();
    dataEntradaLoteTextController?.dispose();

    pesquisaFocusNode?.dispose();
    pesquisaTextController?.dispose();

    pesquisaDentroFocusNode?.dispose();
    pesquisaDentroTextController?.dispose();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
