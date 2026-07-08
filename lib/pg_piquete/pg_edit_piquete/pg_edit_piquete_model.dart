import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pg_edit_piquete_widget.dart' show PgEditPiqueteWidget;
import 'package:flutter/material.dart';

class PgEditPiqueteModel extends FlutterFlowModel<PgEditPiqueteWidget> {
  late HeaderModel headerModel;
  late SideBarModel sideBarModel;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
  }
}
