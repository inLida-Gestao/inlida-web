import '/flutter_flow/flutter_flow_util.dart';
import 'pg_auditoria_importacao_widget.dart' show PgAuditoriaImportacaoWidget;
import 'package:flutter/material.dart';

class PgAuditoriaImportacaoModel
    extends FlutterFlowModel<PgAuditoriaImportacaoWidget> {
  /// Pagina atual da listagem (0-based).
  int pagina = 0;

  /// Filtros da listagem. Null significa "todas".
  String? filtroEntidade;
  String? filtroStatus;
  bool apenasComBloqueio = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
