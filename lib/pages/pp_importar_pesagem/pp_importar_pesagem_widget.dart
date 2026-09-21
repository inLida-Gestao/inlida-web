import '/flutter_flow/flutter_flow_theme.dart';
import '/importacao/import_diagnostico_model.dart';
import '/importacao/import_diagnostico_service.dart';
import '/importacao/pp_pre_confirmacao_importacao_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pp_importar_pesagem_model.dart';
export 'pp_importar_pesagem_model.dart';

class PpImportarPesagemWidget extends StatefulWidget {
  const PpImportarPesagemWidget({super.key});

  @override
  State<PpImportarPesagemWidget> createState() =>
      _PpImportarPesagemWidgetState();
}

class _PpImportarPesagemWidgetState extends State<PpImportarPesagemWidget> {
  late PpImportarPesagemModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PpImportarPesagemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  int get _foundCount =>
      _model.previewRows.where((r) => r['_status'] == 'found').length;

  int get _notFoundCount =>
      _model.previewRows.where((r) => r['_status'] != 'found').length;

  Future<void> _selectAndParseCsv() async {
    final selectedFiles = await selectFiles(multiFile: false);
    if (selectedFiles == null) return;

    setState(() {
      _model.isDataUploading = true;
      _model.previewRows = [];
      _model.parsedJson = null;
    });

    try {
      final uploaded = selectedFiles
          .map((m) => FFUploadedFile(
                name: m.storagePath.split('/').last,
                bytes: m.bytes,
                originalFilename: m.originalFilename,
              ))
          .toList();

      if (uploaded.isEmpty ||
          uploaded.first.bytes == null ||
          uploaded.first.bytes!.isEmpty) {
        setState(() => _model.isDataUploading = false);
        return;
      }

      _model.uploadedFile = uploaded.first;

      setState(() {
        _model.isDataUploading = false;
        _model.isProcessing = true;
      });

      final parse =
          await actions.parseCsvToJsonPesagemDetalhado(_model.uploadedFile);
      _model.parseResult = parse;
      final parsed = parse.registros;
      _model.parsedJson = parsed;

      if (parsed.isEmpty) {
        setState(() => _model.isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                parse.ocorrencias.isEmpty
                    ? 'Planilha vazia ou sem dados válidos.'
                    : parse.ocorrencias.first.mensagem,
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
              duration: const Duration(milliseconds: 3000),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
        }
        return;
      }

      final idPropriedade = FFAppState().propriedadeSelecionada.idPropriedade;

      final preview = await actions.previewPesagemImport(
        parsed,
        idPropriedade,
      );

      // Uma unica leitura do banco alimenta o diagnostico e, depois, a
      // gravacao.
      ImportContexto? contexto;
      try {
        contexto = await carregarContextoPesagem(idPropriedade, parsed);
      } catch (e) {
        debugPrint('Falha ao carregar contexto da importacao de pesagem: \$e');
      }

      setState(() {
        _model.previewRows = preview;
        _model.contexto = contexto;
        _model.diagnostico = diagnosticarImportacao(
          entidade: ImportEntidade.pesagem,
          parse: parse,
          contexto: contexto,
        );
        _model.isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _model.isDataUploading = false;
        _model.isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao processar CSV: $e',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  Future<void> _importPesagens() async {
    if (_foundCount == 0) return;

    final diagnostico = _model.diagnostico;
    var aEnviar = _model.previewRows;

    if (diagnostico != null) {
      // permitirForcar: false porque o unique parcial de historico_pesagens
      // recusaria as linhas bloqueadas de qualquer forma -- oferecer "importar
      // mesmo assim" seria prometer algo que o banco nao cumpre.
      final decisao = await PpPreConfirmacaoImportacaoWidget.mostrar(
        context,
        diagnostico: diagnostico,
        nomeEntidade: 'Pesagem',
        permitirForcar: false,
      );
      if (decisao == ImportDecisao.cancelar) return;

      aEnviar = diagnostico
          .registrosValidos(_model.previewRows)
          .cast<Map<String, dynamic>>();

      if (aEnviar.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Nenhuma pesagem pôde ser importada.'),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
        }
        return;
      }
    }

    setState(() => _model.isImporting = true);

    try {
      final result = await actions.batchInsertSupabasePesagem(
        aEnviar,
        FFAppState().propriedadeSelecionada.idPropriedade,
      );

      final bool success = result['success'] == true;
      final int inserted = result['inserted'] as int? ?? 0;
      final int failed = result['failed'] as int? ?? 0;
      final List<dynamic> failedRows =
          (result['failedRows'] as List<dynamic>? ?? []).toList();

      setState(() => _model.isImporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '$inserted pesagens importadas com sucesso.'
                  : '$inserted importadas, $failed com erro.',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );

        if (failedRows.isNotEmpty && context.mounted) {
          await PpPreConfirmacaoImportacaoWidget.mostrar(
            context,
            diagnostico: diagnosticoDeFalhasDoBanco(
              entidade: ImportEntidade.pesagem,
              arquivo: _model.parseResult?.arquivo ?? const ImportArquivoInfo(),
              totalLinhas: _model.parseResult?.totalLinhas ?? 0,
              failedRows: failedRows,
            ),
            nomeEntidade: 'Pesagem',
            somenteLeitura: true,
          );
        }

        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _model.isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro na importação: $e',
              style: TextStyle(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: 900.0,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20.0),
            _buildUploadSection(context),
            if (_model.isProcessing) ...[
              const SizedBox(height: 20.0),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8.0),
              Center(
                child: Text(
                  'Identificando animais...',
                  style: FlutterFlowTheme.of(context).bodyMedium,
                ),
              ),
            ],
            if (_model.previewRows.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              _buildSummary(context),
              const SizedBox(height: 12.0),
              Flexible(child: _buildPreviewTable(context)),
            ],
            const SizedBox(height: 20.0),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Importar Pesagem',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                font: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineSmall.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.close,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    final hasFile = _model.uploadedFile.bytes != null &&
        _model.uploadedFile.bytes!.isNotEmpty;
    final fileName = _model.uploadedFile.originalFilename;

    return InkWell(
      onTap: (_model.isProcessing || _model.isImporting)
          ? null
          : _selectAndParseCsv,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: FlutterFlowTheme.of(context).alternate,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.description_outlined : Icons.upload_file,
              size: 40.0,
              color: hasFile
                  ? FlutterFlowTheme.of(context).secondary
                  : FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 8.0),
            Text(
              hasFile ? fileName : 'Clique para selecionar o arquivo CSV',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: hasFile
                        ? FlutterFlowTheme.of(context).primaryText
                        : FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (hasFile) ...[
              const SizedBox(height: 4.0),
              Text(
                'Clique para selecionar outro arquivo',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.poppins(
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_model.previewRows.length} registros encontrados no CSV',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '$_foundCount encontrados',
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).secondary,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (_notFoundCount > 0) ...[
            const SizedBox(width: 8.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                '$_notFoundCount não encontrados',
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).error,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              FlutterFlowTheme.of(context).primaryBackground,
            ),
            columnSpacing: 16.0,
            horizontalMargin: 12.0,
            headingTextStyle: FlutterFlowTheme.of(context).labelSmall.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelSmall.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
            dataTextStyle: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.poppins(
                    fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
            columns: const [
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Número')),
              DataColumn(label: Text('Chip')),
              DataColumn(label: Text('Nome')),
              DataColumn(label: Text('Sexo')),
              DataColumn(label: Text('Data Nasc.')),
              DataColumn(label: Text('Raça')),
              DataColumn(label: Text('Data Pesagem')),
              DataColumn(label: Text('Peso (kg)'), numeric: true),
              DataColumn(label: Text('Tipo')),
            ],
            rows: _model.previewRows.map((row) {
              final found = row['_status'] == 'found';
              final errorColor =
                  FlutterFlowTheme.of(context).error.withOpacity(0.08);

              return DataRow(
                color: found ? null : WidgetStateProperty.all(errorColor),
                cells: [
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: found
                            ? FlutterFlowTheme.of(context)
                                .secondary
                                .withOpacity(0.15)
                            : FlutterFlowTheme.of(context)
                                .error
                                .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        found ? 'Encontrado' : 'Não encontrado',
                        style: TextStyle(
                          color: found
                              ? FlutterFlowTheme.of(context).secondary
                              : FlutterFlowTheme.of(context).error,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text((row['numeroAnimal'] ?? '').toString())),
                  DataCell(Text((row['chip'] ?? '').toString())),
                  DataCell(Text((row['nome'] ?? '').toString())),
                  DataCell(Text((row['sexo'] ?? '').toString())),
                  DataCell(Text((row['dataNascimento'] ?? '').toString())),
                  DataCell(Text((row['raca'] ?? '').toString())),
                  DataCell(Text((row['dataPesagem'] ?? '').toString())),
                  DataCell(
                      Text(row['peso'] != null ? row['peso'].toString() : '')),
                  DataCell(Text((row['tipo'] ?? '').toString())),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _model.isImporting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 12.0),
        ElevatedButton(
          onPressed:
              (_foundCount > 0 && !_model.isImporting && !_model.isProcessing)
                  ? _importPesagens
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: FlutterFlowTheme.of(context).secondary,
            disabledBackgroundColor: FlutterFlowTheme.of(context).alternate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          ),
          child: _model.isImporting
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _foundCount > 0
                      ? 'Importar $_foundCount pesagens'
                      : 'Importar',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ],
    );
  }
}
