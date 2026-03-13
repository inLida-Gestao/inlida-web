import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'pp_filtro_lote_widget.dart' show PpFiltroLoteWidget;
import 'package:flutter/material.dart';

class PpFiltroLoteModel extends FlutterFlowModel<PpFiltroLoteWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for DDStatusLote widget.
  String? dDStatusLoteValue;
  FormFieldController<String>? dDStatusLoteValueController;
  // State field(s) for dataCriacaoDe widget.
  FocusNode? dataCriacaoDeFocusNode;
  TextEditingController? dataCriacaoDeTextController;
  String? Function(BuildContext, String?)?
      dataCriacaoDeTextControllerValidator;
  DateTime? datePickedDe;
  // State field(s) for dataCriacaoAte widget.
  FocusNode? dataCriacaoAteFocusNode;
  TextEditingController? dataCriacaoAteTextController;
  String? Function(BuildContext, String?)?
      dataCriacaoAteTextControllerValidator;
  DateTime? datePickedAte;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    dataCriacaoDeFocusNode?.dispose();
    dataCriacaoDeTextController?.dispose();
    dataCriacaoAteFocusNode?.dispose();
    dataCriacaoAteTextController?.dispose();
  }
}
