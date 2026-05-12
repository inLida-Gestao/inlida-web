import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pg_add_piquete_widget.dart' show PgAddPiqueteWidget;
import 'package:flutter/material.dart';

class PgAddPiqueteModel extends FlutterFlowModel<PgAddPiqueteWidget> {
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
