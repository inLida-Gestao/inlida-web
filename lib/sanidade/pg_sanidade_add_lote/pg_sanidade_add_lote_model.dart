import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pg_sanidade_add_lote_widget.dart' show PgSanidadeAddLoteWidget;
import 'package:flutter/material.dart';

class PgSanidadeAddLoteModel
    extends FlutterFlowModel<PgSanidadeAddLoteWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for loteSelecionado
  int? loteSelecionadoId;
  String? loteSelecionadoNome;
  FormFieldController<String>? loteDropdownValueController;

  // State field(s) for porcentagemLote widget.
  FocusNode? porcentagemLoteFocusNode;
  TextEditingController? porcentagemLoteTextController;
  String? Function(BuildContext, String?)?
      porcentagemLoteTextControllerValidator;

  // State field(s) for dataSanidade widget.
  DateTime? dataSanidade;

  // State field(s) for tiposSelecionados - lista de tipos de sanidade selecionados
  List<String> tiposSelecionados = [];

  // State field(s) for vacinaDropdown widget.
  String? vacinaDropdownValue;
  FormFieldController<String>? vacinaDropdownValueController;

  // State field(s) for vacinaOutros widget.
  FocusNode? vacinaOutrosFocusNode;
  TextEditingController? vacinaOutrosTextController;
  String? Function(BuildContext, String?)? vacinaOutrosTextControllerValidator;

  // State field(s) for vacinaObs widget.
  FocusNode? vacinaObsFocusNode;
  TextEditingController? vacinaObsTextController;
  String? Function(BuildContext, String?)? vacinaObsTextControllerValidator;

  // State field(s) for antiparasitarioDropdown widget.
  String? antiparasitarioDropdownValue;
  FormFieldController<String>? antiparasitarioDropdownValueController;

  // State field(s) for antiparasitarioOutros widget.
  FocusNode? antiparasitarioOutrosFocusNode;
  TextEditingController? antiparasitarioOutrosTextController;
  String? Function(BuildContext, String?)?
      antiparasitarioOutrosTextControllerValidator;

  // State field(s) for antiparasitarioObs widget.
  FocusNode? antiparasitarioObsFocusNode;
  TextEditingController? antiparasitarioObsTextController;
  String? Function(BuildContext, String?)?
      antiparasitarioObsTextControllerValidator;

  // State field(s) for tratamentoDropdown widget.
  String? tratamentoDropdownValue;
  FormFieldController<String>? tratamentoDropdownValueController;

  // State field(s) for tratamentoOutros widget.
  FocusNode? tratamentoOutrosFocusNode;
  TextEditingController? tratamentoOutrosTextController;
  String? Function(BuildContext, String?)?
      tratamentoOutrosTextControllerValidator;

  // State field(s) for tratamentoObs widget.
  FocusNode? tratamentoObsFocusNode;
  TextEditingController? tratamentoObsTextController;
  String? Function(BuildContext, String?)? tratamentoObsTextControllerValidator;

  // State field(s) for protocoloDropdown widget.
  String? protocoloDropdownValue;
  FormFieldController<String>? protocoloDropdownValueController;

  // State field(s) for protocoloOutros widget.
  FocusNode? protocoloOutrosFocusNode;
  TextEditingController? protocoloOutrosTextController;
  String? Function(BuildContext, String?)?
      protocoloOutrosTextControllerValidator;

  // State field(s) for protocoloObs widget.
  FocusNode? protocoloObsFocusNode;
  TextEditingController? protocoloObsTextController;
  String? Function(BuildContext, String?)? protocoloObsTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    porcentagemLoteFocusNode?.dispose();
    porcentagemLoteTextController?.dispose();

    vacinaOutrosFocusNode?.dispose();
    vacinaOutrosTextController?.dispose();

    vacinaObsFocusNode?.dispose();
    vacinaObsTextController?.dispose();

    antiparasitarioOutrosFocusNode?.dispose();
    antiparasitarioOutrosTextController?.dispose();

    antiparasitarioObsFocusNode?.dispose();
    antiparasitarioObsTextController?.dispose();

    tratamentoOutrosFocusNode?.dispose();
    tratamentoOutrosTextController?.dispose();

    tratamentoObsFocusNode?.dispose();
    tratamentoObsTextController?.dispose();

    protocoloOutrosFocusNode?.dispose();
    protocoloOutrosTextController?.dispose();

    protocoloObsFocusNode?.dispose();
    protocoloObsTextController?.dispose();
  }
}
