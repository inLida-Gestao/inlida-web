import '/flutter_flow/flutter_flow_util.dart';
import 'sub_menu_painel_importar_widget.dart' show SubMenuPainelImportarWidget;
import 'package:flutter/material.dart';

class SubMenuPainelImportarModel
    extends FlutterFlowModel<SubMenuPainelImportarWidget> {
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

  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataP89 = false;
  FFUploadedFile uploadedLocalFile_uploadDataP89 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Stores action output result for [Custom Action - parseCsvToJsonRebanho2] action in Container widget.
  List<dynamic>? json;
  bool isDataUploading_uploadDataP8979 = false;
  FFUploadedFile uploadedLocalFile_uploadDataP8979 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Stores action output result for [Custom Action - parseCsvToJsonLotes] action in Container widget.
  List<dynamic>? jsonLotes;
  bool isDataUploading_uploadDataP897 = false;
  FFUploadedFile uploadedLocalFile_uploadDataP897 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  // Stores action output result for [Custom Action - parseCsvToJsonReproducao] action in Container widget.
  List<dynamic>? jsonReproducao;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
