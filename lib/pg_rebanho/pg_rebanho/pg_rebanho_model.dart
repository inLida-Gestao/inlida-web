import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/pg_rebanho/cc_add_animal/cc_add_animal_widget.dart';
import '/pg_rebanho/cc_add_nascimento/cc_add_nascimento_widget.dart';
import '/pg_rebanho/cc_add_semen/cc_add_semen_widget.dart';
import '/pg_rebanho/cc_edt_animal/cc_edt_animal_widget.dart';
import 'pg_rebanho_widget.dart' show PgRebanhoWidget;
import 'package:flutter/material.dart';

class PgRebanhoModel extends FlutterFlowModel<PgRebanhoWidget> {
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

  List<RebanhoDTStruct> rebanhosPage = [];
  void addToRebanhosPage(RebanhoDTStruct item) => rebanhosPage.add(item);
  void removeFromRebanhosPage(RebanhoDTStruct item) =>
      rebanhosPage.remove(item);
  void removeAtIndexFromRebanhosPage(int index) => rebanhosPage.removeAt(index);
  void insertAtIndexInRebanhosPage(int index, RebanhoDTStruct item) =>
      rebanhosPage.insert(index, item);
  void updateRebanhosPageAtIndex(
          int index, Function(RebanhoDTStruct) updateFn) =>
      rebanhosPage[index] = updateFn(rebanhosPage[index]);

  int indexIni = 0;

  int indexFim = 20;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (Buscar Rebanho Filtros)] action in pgRebanho widget.
  ApiCallResponse? buscaRebanhosIni;
  // Stores action output result for [Backend Call - Query Rows] action in pgRebanho widget.
  List<PropriedadesRow>? propriedadesUser;
  // Stores action output result for [Backend Call - API (Rebanho Propriedade)] action in pgRebanho widget.
  ApiCallResponse? qtdtesste;
  // Stores action output result for [Backend Call - API (QTD Rebanho Propriedade )] action in pgRebanho widget.
  ApiCallResponse? qtdAnimais;
  // Stores action output result for [Backend Call - API (QTD Rebanho Propriedades)] action in pgRebanho widget.
  ApiCallResponse? qtdAnimais2;
  // Stores action output result for [Backend Call - API (Count Rebanho Filtros)] action in pgRebanho widget.
  ApiCallResponse? countRebanhos;
  InstantTimer? instantTimer;
  // Stores action output result for [Backend Call - API (Buscar Rebanho Filtros)] action in pgRebanho widget.
  ApiCallResponse? buscaRebanhos;
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
      FlutterFlowDataTableController<RebanhoDTStruct>();
  // Model for ccAddAnimal component.
  late CcAddAnimalModel ccAddAnimalModel;
  // Model for ccEdtAnimal component.
  late CcEdtAnimalModel ccEdtAnimalModel;
  // Model for ccAddNascimento component.
  late CcAddNascimentoModel ccAddNascimentoModel;
  // Model for ccAddSemen component.
  late CcAddSemenModel ccAddSemenModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
    ccAddAnimalModel = createModel(context, () => CcAddAnimalModel());
    ccEdtAnimalModel = createModel(context, () => CcEdtAnimalModel());
    ccAddNascimentoModel = createModel(context, () => CcAddNascimentoModel());
    ccAddSemenModel = createModel(context, () => CcAddSemenModel());
  }

  @override
  void dispose() {
    instantTimer?.cancel();
    headerModel.dispose();
    sideBarModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    paginatedDataTableController.dispose();
    ccAddAnimalModel.dispose();
    ccEdtAnimalModel.dispose();
    ccAddNascimentoModel.dispose();
    ccAddSemenModel.dispose();
  }
}
