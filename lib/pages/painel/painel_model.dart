import '/backend/api_requests/api_calls.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_widget.dart';
import '/components/loading_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'dart:async';
import 'painel_widget.dart' show PainelWidget;
import 'package:flutter/material.dart';

class PainelModel extends FlutterFlowModel<PainelWidget> {
  ///  Local state fields for this page.

  int indexExport = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Validar acesso user)] action in Painel widget.
  ApiCallResponse? acessoUser;
  Completer<ApiCallResponse>? apiRequestCompleter2;
  VoidCallback? disposeRefreshListener;
  Completer<ApiCallResponse>? apiRequestCompleter1;
  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for DDInicioAno widget.
  String? dDInicioAnoValue;
  FormFieldController<String>? dDInicioAnoValueController;
  // State field(s) for DDInicioMes widget.
  int? dDInicioMesValue;
  FormFieldController<int>? dDInicioMesValueController;
  // State field(s) for DDFimAno widget.
  String? dDFimAnoValue;
  FormFieldController<String>? dDFimAnoValueController;
  // State field(s) for DDFimMes widget.
  int? dDFimMesValue;
  FormFieldController<int>? dDFimMesValueController;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for DropDown widget.
  int? dropDownValue1;
  FormFieldController<int>? dropDownValueController1;
  // State field(s) for DropDown widget.
  int? dropDownValue2;
  FormFieldController<int>? dropDownValueController2;
  // State field(s) for DropDown widget.
  int? dropDownValue3;
  FormFieldController<int>? dropDownValueController3;
  // State field(s) for DropDown widget.
  int? dropDownValue4;
  FormFieldController<int>? dropDownValueController4;

  // Multi-select filters compartilhados: taxa de concepção e taxa de prenhez (natalidade usa só o período do painel).
  List<String> filtroLoteTaxaConcepcaoValues = [];
  List<String> filtroTouroTaxaConcepcaoValues = [];
  List<String> filtroInseminadorTaxaConcepcaoValues = [];
  // Cache: edge taxa-prenhez → calcular_taxa_prenhez.
  Future<ApiCallResponse>? taxaConcepcaoFuture;
  String? taxaConcepcaoFutureKey;
  // Cache: edge taxa-prenhez2 → calcular_taxa_prenhez2.
  Future<ApiCallResponse>? taxaPrenhez2Future;
  String? taxaPrenhez2FutureKey;
  // Cache for Taxa de natalidade API call.
  Future<ApiCallResponse>? taxaNatalidadeFuture;
  String? taxaNatalidadeFutureKey;
  // Model for empty component.
  late EmptyModel emptyModel;
  // State field(s) for ddIdade widget.
  List<String> filtroSexoIdadeDesmamaValues = [];
  // State field(s) for ddPeso widget.
  List<String> filtroSexoPesoDesmamaValues = [];
  // Multi-select filter for Raça in Nascimentos chart.
  List<String> filtroRacaNascimentoValues = [];
  // Multi-select filter for Motivo Morte in Mortalidade chart.
  List<String> filtroMotivoMorteMortalidadeValues = [];
  // Single-select filter for Categoria in Diagnósticos reprodutivos chart.
  String filtroCategoriadiagnosticoValue = 'Todos';
  // Multi-select filter for Sexo in Projeção de desmamas chart.
  List<String> filtroSexoProjDesmamaValues = [];
  // Single-select filter for Meses in Projeção de desmamas chart.
  String ddMesesValue = '6';
  // Model for loading component.
  late LoadingModel loadingModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
    emptyModel = createModel(context, () => EmptyModel());
    loadingModel = createModel(context, () => LoadingModel());
    filtroRacaNascimentoValues = [];
    filtroMotivoMorteMortalidadeValues = [];

    filtroLoteTaxaConcepcaoValues = [];
    filtroTouroTaxaConcepcaoValues = [];
    filtroInseminadorTaxaConcepcaoValues = [];
  }

  @override
  void dispose() {
    disposeRefreshListener?.call();
    headerModel.dispose();
    sideBarModel.dispose();
    tabBarController?.dispose();
    emptyModel.dispose();
    loadingModel.dispose();
    
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
