import '/flutter_flow/flutter_flow_util.dart';
import 'pp_importar_pesagem_widget.dart' show PpImportarPesagemWidget;
import 'package:flutter/material.dart';

class PpImportarPesagemModel
    extends FlutterFlowModel<PpImportarPesagemWidget> {
  bool isDataUploading = false;
  FFUploadedFile uploadedFile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  List<dynamic>? parsedJson;

  List<Map<String, dynamic>> previewRows = [];

  bool isProcessing = false;

  bool isImporting = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
