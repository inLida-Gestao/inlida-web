import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import 'pg_edit_piquete_widget.dart' show PgEditPiqueteWidget;
import 'package:flutter/material.dart';

class PgEditPiqueteModel extends FlutterFlowModel<PgEditPiqueteWidget> {
  ///  Local state fields for this page.

  int pageNumAnimais = 1;

  List<RebanhoDTStruct> animaisSelecionados = [];
  void addToAnimaisSelecionados(RebanhoDTStruct item) =>
      animaisSelecionados.add(item);
  void removeFromAnimaisSelecionados(RebanhoDTStruct item) =>
      animaisSelecionados.remove(item);

  List<LotesRow> lotesSelecionados = [];
  void addToLotesSelecionados(LotesRow item) => lotesSelecionados.add(item);
  void removeFromLotesSelecionados(LotesRow item) =>
      lotesSelecionados.remove(item);

  String incluirPiquete = 'animal';

  bool loaded = false;

  ///  State fields for stateful widgets in this page.

  late HeaderModel headerModel;
  late SideBarModel sideBarModel;
  FocusNode? nomePiqueteFocusNode;
  TextEditingController? nomePiqueteTextController;
  String? Function(BuildContext, String?)? nomePiqueteTextControllerValidator;
  FocusNode? areaFocusNode;
  TextEditingController? areaTextController;
  String? Function(BuildContext, String?)? areaTextControllerValidator;
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  List<String>? dDForrageiraValue;
  FormListFieldController<String>? dDForrageiraValueController;
  FocusNode? pesquisaAnimaisFocusNode;
  TextEditingController? pesquisaAnimaisTextController;
  String? Function(BuildContext, String?)? pesquisaAnimaisTextControllerValidator;
  Completer<ApiCallResponse>? apiRequestCompleterAnimais;
  FocusNode? pesquisaLotesFocusNode;
  TextEditingController? pesquisaLotesTextController;
  String? Function(BuildContext, String?)? pesquisaLotesTextControllerValidator;
  Map<RebanhoDTStruct, bool> checkboxAnimaisMap = {};
  List<RebanhoDTStruct> get animaisChecked => checkboxAnimaisMap.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();
  Map<LotesRow, bool> checkboxLotesMap = {};
  List<LotesRow> get lotesChecked => checkboxLotesMap.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    nomePiqueteFocusNode?.dispose();
    nomePiqueteTextController?.dispose();
    areaFocusNode?.dispose();
    areaTextController?.dispose();
    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();
    pesquisaAnimaisFocusNode?.dispose();
    pesquisaAnimaisTextController?.dispose();
    pesquisaLotesFocusNode?.dispose();
    pesquisaLotesTextController?.dispose();
  }

  Future waitForApiRequestCompleterAnimais({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleterAnimais?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
