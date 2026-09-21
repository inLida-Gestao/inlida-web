import '/flutter_flow/flutter_flow_util.dart';
import 'pp_importar_pesagem_widget.dart' show PpImportarPesagemWidget;
import 'package:flutter/material.dart';

import '/importacao/import_diagnostico_model.dart';
import '/importacao/import_diagnostico_service.dart';

class PpImportarPesagemModel extends FlutterFlowModel<PpImportarPesagemWidget> {
  bool isDataUploading = false;
  FFUploadedFile uploadedFile =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');

  List<dynamic>? parsedJson;

  /// Leitura detalhada da planilha, com os problemas que o parser observou.
  ImportParseResult? parseResult;

  /// Relatorio mostrado no popup antes de gravar.
  ImportDiagnostico? diagnostico;

  /// Leitura do banco, reaproveitada pela gravacao.
  ImportContexto? contexto;

  List<Map<String, dynamic>> previewRows = [];

  bool isProcessing = false;

  bool isImporting = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
