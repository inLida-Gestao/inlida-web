import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:async';
import 'pg_add_piquete_widget.dart' show PgAddPiqueteWidget;
import 'package:flutter/material.dart';

class PgAddPiqueteModel extends FlutterFlowModel<PgAddPiqueteWidget> {
  ///  Local state fields for this page.

  int pageNumAnimais = 1;
  int pageNumLotes = 1;

  /// Animais selecionados para adicionar ao piquete.
  List<RebanhoDTStruct> animaisSelecionados = [];
  void addToAnimaisSelecionados(RebanhoDTStruct item) =>
      animaisSelecionados.add(item);
  void removeFromAnimaisSelecionados(RebanhoDTStruct item) =>
      animaisSelecionados.remove(item);

  /// Lotes selecionados para adicionar ao piquete.
  List<LotesRow> lotesSelecionados = [];
  void addToLotesSelecionados(LotesRow item) => lotesSelecionados.add(item);
  void removeFromLotesSelecionados(LotesRow item) =>
      lotesSelecionados.remove(item);

  /// Tipo de inclusão: 'animal' ou 'lote'.
  String incluirPiquete = 'animal';

  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for nomePiquete widget.
  FocusNode? nomePiqueteFocusNode;
  TextEditingController? nomePiqueteTextController;
  String? Function(BuildContext, String?)? nomePiqueteTextControllerValidator;
  // State field(s) for area widget.
  FocusNode? areaFocusNode;
  TextEditingController? areaTextController;
  String? Function(BuildContext, String?)? areaTextControllerValidator;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // State field(s) for forrageira dropdown (multiselect).
  List<String>? dDForrageiraValue;
  FormListFieldController<String>? dDForrageiraValueController;
  // State field(s) for pesquisa animais widget.
  FocusNode? pesquisaAnimaisFocusNode;
  TextEditingController? pesquisaAnimaisTextController;
  String? Function(BuildContext, String?)? pesquisaAnimaisTextControllerValidator;
  Completer<ApiCallResponse>? apiRequestCompleterAnimais;
  // State field(s) for pesquisa lotes widget.
  FocusNode? pesquisaLotesFocusNode;
  TextEditingController? pesquisaLotesTextController;
  String? Function(BuildContext, String?)? pesquisaLotesTextControllerValidator;
  // Checkboxes for animais
  Map<RebanhoDTStruct, bool> checkboxAnimaisMap = {};
  List<RebanhoDTStruct> get animaisChecked => checkboxAnimaisMap.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();
  // Checkboxes for lotes
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

  /// Additional helper methods.
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
