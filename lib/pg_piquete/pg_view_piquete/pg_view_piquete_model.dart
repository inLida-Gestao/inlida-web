import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pg_view_piquete_widget.dart' show PgViewPiqueteWidget;
import 'package:flutter/material.dart';

class PgViewPiqueteModel extends FlutterFlowModel<PgViewPiqueteWidget> {
  ///  Local state fields for this page.

  List<PiqueteRow> piqueteRows = [];

  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;

  // Search controller for lotes table.
  TextEditingController? pesquisaController;
  FocusNode? pesquisaFocusNode;

  // Pagination state (lotes).
  int pageNum = 1;
  static const int pageSize = 10;

  // Search controller for animal table.
  TextEditingController? animalPesquisaController;
  FocusNode? animalPesquisaFocusNode;

  // Pagination state (animais).
  int animalPageNum = 1;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    pesquisaController?.dispose();
    pesquisaFocusNode?.dispose();
    animalPesquisaController?.dispose();
    animalPesquisaFocusNode?.dispose();
  }
}
