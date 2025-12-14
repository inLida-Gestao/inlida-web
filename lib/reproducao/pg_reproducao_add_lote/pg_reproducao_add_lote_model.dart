import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'pg_reproducao_add_lote_widget.dart' show PgReproducaoAddLoteWidget;
import 'package:flutter/material.dart';

class PgReproducaoAddLoteModel
    extends FlutterFlowModel<PgReproducaoAddLoteWidget> {
  ///  Local state fields for this page.

  String tipoReproducao = 'Inseminação';

  double? score = 1.0;

  int? partidaSemen = 1;

  int index = 0;

  int indexRebanhosLote = 0;

  bool parida = false;

  ///  State fields for stateful widgets in this page.

  // Model for header component.
  late HeaderModel headerModel;
  // Model for sideBar component.
  late SideBarModel sideBarModel;
  // State field(s) for DropDownLote widget.
  String? dropDownLoteValue;
  FormFieldController<String>? dropDownLoteValueController;
  // State field(s) for dataInseminacao widget.
  FocusNode? dataInseminacaoFocusNode;
  TextEditingController? dataInseminacaoTextController;
  String? Function(BuildContext, String?)?
      dataInseminacaoTextControllerValidator;
  DateTime? datePicked1;
  // State field(s) for dataPartidaSemen widget.
  FocusNode? dataPartidaSemenFocusNode;
  TextEditingController? dataPartidaSemenTextController;
  String? Function(BuildContext, String?)?
      dataPartidaSemenTextControllerValidator;
  DateTime? datePicked2;
  // State field(s) for dataInicial widget.
  FocusNode? dataInicialFocusNode;
  TextEditingController? dataInicialTextController;
  String? Function(BuildContext, String?)? dataInicialTextControllerValidator;
  DateTime? datePicked3;
  // State field(s) for dataFinal widget.
  FocusNode? dataFinalFocusNode;
  TextEditingController? dataFinalTextController;
  String? Function(BuildContext, String?)? dataFinalTextControllerValidator;
  DateTime? datePicked4;
  // State field(s) for nomeInseminador widget.
  FocusNode? nomeInseminadorFocusNode;
  TextEditingController? nomeInseminadorTextController;
  String? Function(BuildContext, String?)?
      nomeInseminadorTextControllerValidator;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for dataParida widget.
  FocusNode? dataParidaFocusNode;
  TextEditingController? dataParidaTextController;
  String? Function(BuildContext, String?)? dataParidaTextControllerValidator;
  DateTime? datePicked5;
  // State field(s) for DropDownStatus widget.
  String? dropDownStatusValue;
  FormFieldController<String>? dropDownStatusValueController;
  // State field(s) for dataStatus widget.
  FocusNode? dataStatusFocusNode;
  TextEditingController? dataStatusTextController;
  String? Function(BuildContext, String?)? dataStatusTextControllerValidator;
  DateTime? datePicked6;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? rebanhoLote;

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

    dataParidaFocusNode?.dispose();
    dataParidaTextController?.dispose();

    dataStatusFocusNode?.dispose();
    dataStatusTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();
  }
}
