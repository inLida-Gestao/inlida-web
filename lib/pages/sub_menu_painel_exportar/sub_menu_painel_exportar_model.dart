import '/flutter_flow/flutter_flow_util.dart';
import 'sub_menu_painel_exportar_widget.dart' show SubMenuPainelExportarWidget;
import 'package:flutter/material.dart';

class SubMenuPainelExportarModel
    extends FlutterFlowModel<SubMenuPainelExportarWidget> {
  ///  Local state fields for this component.

  int index = 0;

  List<dynamic> listaJson = [];
  void addToListaJson(dynamic item) => listaJson.add(item);
  void removeFromListaJson(dynamic item) => listaJson.remove(item);
  void removeAtIndexFromListaJson(int index) => listaJson.removeAt(index);
  void insertAtIndexInListaJson(int index, dynamic item) =>
      listaJson.insert(index, item);
  void updateListaJsonAtIndex(int index, Function(dynamic) updateFn) =>
      listaJson[index] = updateFn(listaJson[index]);

  List<String> listaLotes = [];
  void addToListaLotes(String item) => listaLotes.add(item);
  void removeFromListaLotes(String item) => listaLotes.remove(item);
  void removeAtIndexFromListaLotes(int index) => listaLotes.removeAt(index);
  void insertAtIndexInListaLotes(int index, String item) =>
      listaLotes.insert(index, item);
  void updateListaLotesAtIndex(int index, Function(String) updateFn) =>
      listaLotes[index] = updateFn(listaLotes[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
