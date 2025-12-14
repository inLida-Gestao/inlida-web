import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'pg_reproducao_view_lote_widget.dart' show PgReproducaoViewLoteWidget;
import 'package:flutter/material.dart';

class PgReproducaoViewLoteModel
    extends FlutterFlowModel<PgReproducaoViewLoteWidget> {
  ///  Local state fields for this page.

  String tipoReproducao = 'Inseminação';

  double? score = 1.0;

  int? partidaSemen = 1;

  ReproducaoRow? reproducaoSelecionada;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in pgReproducaoViewLote widget.
  List<ReproducaoRow>? reproducao;
  // Stores action output result for [Backend Call - Query Rows] action in pgReproducaoViewLote widget.
  List<RebanhoRow>? reprodutorData;
  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for dataInseminacao widget.
  FocusNode? dataInseminacaoFocusNode;
  TextEditingController? dataInseminacaoTextController;
  String? Function(BuildContext, String?)?
      dataInseminacaoTextControllerValidator;
  // State field(s) for dataPartidaSemen widget.
  FocusNode? dataPartidaSemenFocusNode;
  TextEditingController? dataPartidaSemenTextController;
  String? Function(BuildContext, String?)?
      dataPartidaSemenTextControllerValidator;
  // State field(s) for dataInicial widget.
  FocusNode? dataInicialFocusNode;
  TextEditingController? dataInicialTextController;
  String? Function(BuildContext, String?)? dataInicialTextControllerValidator;
  // State field(s) for dataFinal widget.
  FocusNode? dataFinalFocusNode;
  TextEditingController? dataFinalTextController;
  String? Function(BuildContext, String?)? dataFinalTextControllerValidator;
  // State field(s) for nomeInseminador widget.
  FocusNode? nomeInseminadorFocusNode;
  TextEditingController? nomeInseminadorTextController;
  String? Function(BuildContext, String?)?
      nomeInseminadorTextControllerValidator;
  // State field(s) for dataStatus widget.
  FocusNode? dataStatusFocusNode;
  TextEditingController? dataStatusTextController;
  String? Function(BuildContext, String?)? dataStatusTextControllerValidator;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    dataInseminacaoFocusNode?.dispose();
    dataInseminacaoTextController?.dispose();

    dataPartidaSemenFocusNode?.dispose();
    dataPartidaSemenTextController?.dispose();

    dataInicialFocusNode?.dispose();
    dataInicialTextController?.dispose();

    dataFinalFocusNode?.dispose();
    dataFinalTextController?.dispose();

    nomeInseminadorFocusNode?.dispose();
    nomeInseminadorTextController?.dispose();

    dataStatusFocusNode?.dispose();
    dataStatusTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();
  }
}
