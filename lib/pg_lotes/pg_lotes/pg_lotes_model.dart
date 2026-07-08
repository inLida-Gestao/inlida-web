import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pg_lotes/cc_add_lote/cc_add_lote_widget.dart';
import '/index.dart';
import 'dart:async';
import 'pg_lotes_widget.dart' show PgLotesWidget;
import 'package:flutter/material.dart';

class PgLotesModel extends FlutterFlowModel<PgLotesWidget> {
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

  int pageNum = 1;

  String sortColumn = 'id';

  bool sortAscending = false;

  void updateLotesSort(int columnIndex, bool ascending) {
    sortColumn = switch (columnIndex) {
      0 => 'nome',
      1 => 'qtd_rebanhos_no_lote',
      2 => 'status',
      _ => 'id',
    };
    sortAscending = ascending;
  }

  int _statusSortValue(LotesStruct lote) {
    final statusRaw = lote.ativo.trim().toLowerCase();
    final hasExitInfo = lote.dataSaidaPiquete.trim().isNotEmpty ||
        lote.dataMotivo.trim().isNotEmpty ||
        lote.motivo.trim().isNotEmpty;
    return statusRaw == 'ativo' && !hasExitInfo ? 0 : 1;
  }

  List<LotesStruct> sortedLotes(List<LotesStruct> lotes) {
    if (sortColumn == 'id') {
      return lotes;
    }

    final sorted = lotes.toList();
    sorted.sort((a, b) {
      final comparison = switch (sortColumn) {
        'nome' => a.nome.trim().toLowerCase().compareTo(
              b.nome.trim().toLowerCase(),
            ),
        'qtd_rebanhos_no_lote' =>
          a.qtdRebanhosNoLote.compareTo(b.qtdRebanhosNoLote),
        'status' => _statusSortValue(a).compareTo(_statusSortValue(b)),
        _ => 0,
      };
      final stableComparison = comparison != 0
          ? comparison
          : a.nome.trim().toLowerCase().compareTo(
                b.nome.trim().toLowerCase(),
              );
      return sortAscending ? stableComparison : -stableComparison;
    });
    return sorted;
  }

  ///  State fields for stateful widgets in this page.

  VoidCallback? disposeRefreshListener;
  Completer<ApiCallResponse>? apiRequestCompleter;
  // Cache do ultimo resultado bem-sucedido para evitar tela cinza ao paginar.
  ApiCallResponse? lastLotesResponse;
  bool isPaginating = false;
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
      FlutterFlowDataTableController<LotesStruct>();
  // Model for ccAddLote component.
  late CcAddLoteModel ccAddLoteModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
    ccAddLoteModel = createModel(context, () => CcAddLoteModel());
  }

  @override
  void dispose() {
    disposeRefreshListener?.call();
    headerModel.dispose();
    sideBarModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    paginatedDataTableController.dispose();
    ccAddLoteModel.dispose();
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
