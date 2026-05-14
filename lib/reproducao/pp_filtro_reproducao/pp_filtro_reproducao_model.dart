import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_reproducao_widget.dart' show PpFiltroReproducaoWidget;
import 'package:flutter/material.dart';

class PpFiltroReproducaoModel
    extends FlutterFlowModel<PpFiltroReproducaoWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for dataReproducaoDe widget.
  FocusNode? dataReproducaoDeFocusNode;
  TextEditingController? dataReproducaoDeTextController;
  String? Function(BuildContext, String?)?
      dataReproducaoDeTextControllerValidator;
  DateTime? datePickedReproDe;
  // State field(s) for dataReproducaoAte widget.
  FocusNode? dataReproducaoAteFocusNode;
  TextEditingController? dataReproducaoAteTextController;
  String? Function(BuildContext, String?)?
      dataReproducaoAteTextControllerValidator;
  DateTime? datePickedReproAte;
  // State field(s) for dataPartoDe widget.
  FocusNode? dataPartoDeFocusNode;
  TextEditingController? dataPartoDeTextController;
  String? Function(BuildContext, String?)? dataPartoDeTextControllerValidator;
  DateTime? datePickedPartoDe;
  // State field(s) for dataPartoAte widget.
  FocusNode? dataPartoAteFocusNode;
  TextEditingController? dataPartoAteTextController;
  String? Function(BuildContext, String?)? dataPartoAteTextControllerValidator;
  DateTime? datePickedPartoAte;
  // State field(s) for dataDiagnosticoDe widget.
  FocusNode? dataDiagnosticoDeFocusNode;
  TextEditingController? dataDiagnosticoDeTextController;
  String? Function(BuildContext, String?)?
      dataDiagnosticoDeTextControllerValidator;
  DateTime? datePickedDiagDe;
  // State field(s) for dataDiagnosticoAte widget.
  FocusNode? dataDiagnosticoAteFocusNode;
  TextEditingController? dataDiagnosticoAteTextController;
  String? Function(BuildContext, String?)?
      dataDiagnosticoAteTextControllerValidator;
  DateTime? datePickedDiagAte;
  // State field(s) for DDCatRebanho widget.
  String? dDCatRebanhoValue;
  FormFieldController<String>? dDCatRebanhoValueController;
  // State field(s) for DDDiagnostico widget.
  List<String>? dDDiagnosticoValue;
  FormFieldController<List<String>>? dDDiagnosticoValueController;

  String? dDTipoReproducaoValue;
  FormFieldController<String>? dDTipoReproducaoValueController;
  // Lotes future for dropdown
  Future<List<LotesRow>>? lotesFuture;
  // Reprodução future for inseminador dropdown
  Future<List<ReproducaoRow>>? reproducaoFuture;
  // State field(s) for DropDownLote widget.
  String? dropDownLoteValue;
  FormFieldController<String>? dropDownLoteValueController;
  // State field(s) for DropDownInseminador widget.
  String? dropDownInseminadorValue;
  FormFieldController<String>? dropDownInseminadorValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataReproducaoDeFocusNode?.dispose();
    dataReproducaoDeTextController?.dispose();
    dataReproducaoAteFocusNode?.dispose();
    dataReproducaoAteTextController?.dispose();

    dataPartoDeFocusNode?.dispose();
    dataPartoDeTextController?.dispose();
    dataPartoAteFocusNode?.dispose();
    dataPartoAteTextController?.dispose();

    dataDiagnosticoDeFocusNode?.dispose();
    dataDiagnosticoDeTextController?.dispose();
    dataDiagnosticoAteFocusNode?.dispose();
    dataDiagnosticoAteTextController?.dispose();
  }
}
