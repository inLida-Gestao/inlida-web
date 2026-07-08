import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pg_piquete_widget.dart' show PgPiqueteWidget;
import 'package:flutter/material.dart';

class PgPiqueteModel extends FlutterFlowModel<PgPiqueteWidget> {
  late HeaderModel headerModel;
  late SideBarModel sideBarModel;

  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
