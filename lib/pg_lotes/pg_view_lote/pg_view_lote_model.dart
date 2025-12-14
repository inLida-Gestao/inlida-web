import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'dart:async';
import 'pg_view_lote_widget.dart' show PgViewLoteWidget;
import 'package:flutter/material.dart';

class PgViewLoteModel extends FlutterFlowModel<PgViewLoteWidget> {
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

  int mostrarAdicionados = 5;

  String? idLote;

  int index = 0;

  double unAnimal = 0.0;

  bool ativo = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in pgViewLote widget.
  List<LotesRow>? lote;
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
  // State field(s) for pesquisa widget.
  FocusNode? pesquisaFocusNode;
  TextEditingController? pesquisaTextController;
  String? Function(BuildContext, String?)? pesquisaTextControllerValidator;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<RebanhoDTStruct>();

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

    paginatedDataTableController.dispose();
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
