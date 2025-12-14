import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'modal_more_widget.dart' show ModalMoreWidget;
import 'package:flutter/material.dart';

class ModalMoreModel extends FlutterFlowModel<ModalMoreWidget> {
  ///  Local state fields for this component.

  int indexCrias = 0;

  int indexPesagens = 0;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? rebanho;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? criasMatriz;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? criasReprodutor;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<HistoricoPesagensRow>? histPesagens;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? rebanhoPrincipal;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? matriz;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<RebanhoRow>? reprodutor;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
