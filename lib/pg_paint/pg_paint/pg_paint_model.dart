import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pg_paint_widget.dart' show PgPaintWidget;
import 'package:flutter/material.dart';

class PgPaintModel extends FlutterFlowModel<PgPaintWidget> {
  late HeaderModel headerModel;
  late SideBarModel sideBarModel;

  FocusNode? codTransmissaoFocus;
  TextEditingController? codTransmissaoController;
  String? Function(BuildContext, String?)? codTransmissaoValidator;

  FocusNode? serieFazendaFocus;
  TextEditingController? serieFazendaController;
  String? Function(BuildContext, String?)? serieFazendaValidator;

  FocusNode? codFazendaFocus;
  TextEditingController? codFazendaController;
  String? Function(BuildContext, String?)? codFazendaValidator;

  bool carregandoConfig = true;
  bool salvandoConfig = false;
  bool exportando = false;
  String? mensagemConfig;
  String? mensagemExport;
  String? linkUltimoZip;

  String? configId;
  String programa = 'P';
  String estrategiaA12 = 'compacto';
  String campoOrigemAnimal = 'numeroAnimal';

  bool carregandoStatus = true;
  bool importandoAuto = false;
  String? mensagemAuto;
  Map<String, int> counts = const {};

  bool exportandoExcel = false;
  bool importandoExcel = false;
  String? mensagemExcel;
  String? tipoExcelAtivo;

  @override
  void initState(BuildContext context) {
    headerModel = createModel(context, () => HeaderModel());
    sideBarModel = createModel(context, () => SideBarModel());
  }

  @override
  void dispose() {
    headerModel.dispose();
    sideBarModel.dispose();
    codTransmissaoFocus?.dispose();
    codTransmissaoController?.dispose();
    serieFazendaFocus?.dispose();
    serieFazendaController?.dispose();
    codFazendaFocus?.dispose();
    codFazendaController?.dispose();
  }
}
