import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/custom_code/actions/index.dart' as paint_actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class PaintBibliotecaTourosWidget extends StatefulWidget {
  const PaintBibliotecaTourosWidget({super.key});

  static String routeName = 'pgPaintBibliotecaTouros';
  static String routePath = '/paint/admin/biblioteca-touros';

  @override
  State<PaintBibliotecaTourosWidget> createState() =>
      _PaintBibliotecaTourosWidgetState();
}

class _PaintBibliotecaTourosWidgetState
    extends State<PaintBibliotecaTourosWidget> {
  late HeaderModel _headerModel;
  bool _carregandoCount = true;
  int _totalAtual = 0;
  bool _importando = false;
  String? _mensagem;
  bool _carregandoLista = true;
  List<Map<String, dynamic>> _registros = const [];
  int _pagina = 0;
  static const int _tamanhoPagina = 50;
  final TextEditingController _buscaCtrl = TextEditingController();
  String _busca = '';

  int get _totalPaginas =>
      _totalAtual == 0 ? 1 : ((_totalAtual + _tamanhoPagina - 1) ~/ _tamanhoPagina);

  @override
  void initState() {
    super.initState();
    _headerModel = createModel(context, () => HeaderModel());
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _carregarLista();
    });
  }

  @override
  void dispose() {
    _headerModel.dispose();
    _buscaCtrl.dispose();
    super.dispose();
  }

  Future<void> _carregarLista({bool resetarPagina = false}) async {
    safeSetState(() {
      _carregandoCount = true;
      _carregandoLista = true;
      if (resetarPagina) _pagina = 0;
    });
    try {
      final offset = _pagina * _tamanhoPagina;
      var q = SupaFlow.client.from('paint_biblioteca_touros').select('*');
      if (_busca.trim().isNotEmpty) {
        final b = _busca.trim();
        q = q.or('a12.ilike.%$b%,nome.ilike.%$b%');
      }
      final resp = await q
          .order('nome', ascending: true)
          .range(offset, offset + _tamanhoPagina - 1)
          .count(CountOption.exact);
      safeSetState(() {
        _registros = List<Map<String, dynamic>>.from(resp.data);
        _totalAtual = resp.count;
        _carregandoCount = false;
        _carregandoLista = false;
      });
    } catch (_) {
      safeSetState(() {
        _carregandoCount = false;
        _carregandoLista = false;
      });
    }
  }

  Future<void> _selecionarEImportar() async {
    safeSetState(() {
      _importando = true;
      _mensagem = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx', 'xls'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        safeSetState(() {
          _importando = false;
          _mensagem = 'Nenhum arquivo selecionado.';
        });
        return;
      }
      final file = result.files.first;
      if (file.bytes == null) {
        safeSetState(() {
          _importando = false;
          _mensagem = 'Não foi possível ler o arquivo.';
        });
        return;
      }
      final uploaded = FFUploadedFile(
        name: file.name,
        bytes: file.bytes!,
      );
      final qtd = await paint_actions.importBibliotecaTouros(uploaded);
      safeSetState(() {
        _importando = false;
        _mensagem = '$qtd registro(s) importado(s) com sucesso.';
      });
      await _carregarLista(resetarPagina: true);
    } catch (e) {
      safeSetState(() {
        _importando = false;
        _mensagem = 'Erro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            wrapWithModel(
              model: _headerModel,
              updateCallback: () => safeSetState(() {}),
              child: const HeaderWidget(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biblioteca de touros A12 (PAINT)',
                                style: FlutterFlowTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      fontFamily: 'Outfit',
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey('Outfit'),
                                    ),
                              ),
                              Text(
                                'Cadastro global de touros disponível no programa PAINT, '
                                'usado para preencher o A12 de pais externos ao rebanho local.',
                                style: FlutterFlowTheme.of(context).bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status atual',
                            style: FlutterFlowTheme.of(context).titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (_carregandoCount)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(),
                            )
                          else
                            Text(
                              '$_totalAtual touros cadastrados',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          const SizedBox(height: 16),
                          Text(
                            'Importar/atualizar planilha',
                            style: FlutterFlowTheme.of(context).titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aceita .xlsx com colunas A12, NOME, RACA, TIPO_REGISTRO, '
                            'PAI_A12, MAE_A12, RGD, RGN. A coluna A12 (12 caracteres) é obrigatória. '
                            'Importação faz upsert por A12 — registros existentes são atualizados.',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                          const SizedBox(height: 16),
                          FFButtonWidget(
                            onPressed:
                                _importando ? null : _selecionarEImportar,
                            text: _importando
                                ? 'Processando…'
                                : 'Selecionar planilha e importar',
                            icon: const Icon(Icons.upload_file, size: 18),
                            options: FFButtonOptions(
                              height: 44,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                    useGoogleFonts: GoogleFonts.asMap()
                                        .containsKey('Readex Pro'),
                                  ),
                              elevation: 0,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          if (_mensagem != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _mensagem!,
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _cardLista(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardLista(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final inicio = _totalAtual == 0 ? 0 : _pagina * _tamanhoPagina + 1;
    final fim =
        (_pagina * _tamanhoPagina + _registros.length).clamp(0, _totalAtual);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Touros cadastrados', style: theme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buscaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar por A12 ou nome',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (v) {
                    _busca = v;
                    _carregarLista(resetarPagina: true);
                  },
                ),
              ),
              const SizedBox(width: 8),
              FFButtonWidget(
                onPressed: () {
                  _busca = _buscaCtrl.text;
                  _carregarLista(resetarPagina: true);
                },
                text: 'Buscar',
                options: FFButtonOptions(
                  height: 48,
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  color: theme.primary,
                  textStyle: theme.titleSmall.override(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
                  elevation: 0,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_carregandoLista)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_registros.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                _busca.isEmpty
                    ? 'Nenhum touro cadastrado ainda.'
                    : 'Nenhum resultado para "$_busca".',
                style: theme.bodyMedium,
              ),
            )
          else
            SizedBox(
              height: 400,
              child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('A12')),
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('Raça')),
                        DataColumn(label: Text('Tipo reg.')),
                        DataColumn(label: Text('Pai A12')),
                        DataColumn(label: Text('Mãe A12')),
                      ],
                      rows: _registros.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text((r['a12'] ?? '').toString())),
                            DataCell(Text((r['nome'] ?? '').toString())),
                            DataCell(Text((r['raca'] ?? '').toString())),
                            DataCell(
                                Text((r['tipo_registro'] ?? '').toString())),
                            DataCell(Text((r['pai_a12'] ?? '').toString())),
                            DataCell(Text((r['mae_a12'] ?? '').toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _totalAtual == 0
                      ? 'Nenhum registro'
                      : 'Mostrando $inicio–$fim de $_totalAtual registros',
                  style: theme.bodySmall,
                ),
              ),
              IconButton(
                onPressed: _pagina > 0 && !_carregandoLista
                    ? () {
                        safeSetState(() => _pagina--);
                        _carregarLista();
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text('${_pagina + 1} / $_totalPaginas',
                  style: theme.bodyMedium),
              IconButton(
                onPressed:
                    _pagina + 1 < _totalPaginas && !_carregandoLista
                        ? () {
                            safeSetState(() => _pagina++);
                            _carregarLista();
                          }
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
