import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:async';
import 'pg_reproducao_widget.dart' show PgReproducaoWidget;
import 'package:flutter/material.dart';

class PgReproducaoModel extends FlutterFlowModel<PgReproducaoWidget> {
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

  int pageNum = 1;

  int pageTotal = 1;

  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  Completer<ApiCallResponse>? apiRequestCompleter2;
  Completer<ApiCallResponse>? apiRequestCompleter1;
  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<ReproducaoDTStruct>();

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
    textFieldFocusNode?.dispose();
    textController?.dispose();

    paginatedDataTableController.dispose();
  }

  /// Additional helper methods.
  Future waitForApiRequestCompleted2({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter2?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }

  Future waitForApiRequestCompleted1({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleter1?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
