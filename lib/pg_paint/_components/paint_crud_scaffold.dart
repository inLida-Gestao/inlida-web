import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/custom_code/actions/index.dart' as paint_actions;
import '/custom_code/actions/paint_delete_payload.dart';
import '/custom_code/actions/paint_excel_helpers.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipo de campo para o form genérico do PAINT CRUD.
enum PaintFieldType { text, integer, decimal, date, dropdown, boolean }

class PaintDropdownOption {
  final String value;
  final String label;
  const PaintDropdownOption(this.value, this.label);
}

class PaintField {
  final String key;
  final String label;
  final PaintFieldType type;
  final bool required;
  final int? maxLength;
  final bool digitsOnly;
  final String? hint;
  final List<PaintDropdownOption> options;
  final Future<List<PaintDropdownOption>> Function()? optionsLoader;

  const PaintField({
    required this.key,
    required this.label,
    this.type = PaintFieldType.text,
    this.required = false,
    this.maxLength,
    this.digitsOnly = false,
    this.hint,
    this.options = const [],
    this.optionsLoader,
  });
}

class PaintColumn {
  final String key;
  final String label;
  final String Function(dynamic value)? formatter;

  const PaintColumn(this.key, this.label, {this.formatter});
}

/// Widget reutilizável de CRUD para tabelas paint_*.
/// Lista paginada + form modal (insert/update) + delete com confirmação.
/// Filtra automaticamente por id_propriedade da propriedade selecionada.
class PaintCrudScaffold extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final String tableName;
  final List<PaintColumn> columns;
  final List<PaintField> fields;
  final String orderBy;
  final bool ascending;
  final String? insertButtonLabel;

  const PaintCrudScaffold({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.tableName,
    required this.columns,
    required this.fields,
    this.orderBy = 'created_at',
    this.ascending = false,
    this.insertButtonLabel,
  });

  @override
  State<PaintCrudScaffold> createState() => _PaintCrudScaffoldState();
}

class _PaintCrudScaffoldState extends State<PaintCrudScaffold> {
  late HeaderModel _headerModel;
  bool _carregando = true;
  String? _erro;
  List<Map<String, dynamic>> _registros = [];
  int _pagina = 0;
  static const int _tamanhoPagina = 50;
  int _total = 0;

  String get _idPropriedade =>
      FFAppState().propriedadeSelecionada.idPropriedade;

  int get _totalPaginas =>
      _total == 0 ? 1 : ((_total + _tamanhoPagina - 1) ~/ _tamanhoPagina);

  @override
  void initState() {
    super.initState();
    _headerModel = createModel(context, () => HeaderModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  @override
  void dispose() {
    _headerModel.dispose();
    super.dispose();
  }

  Future<void> _carregar({bool resetarPagina = false}) async {
    if (_idPropriedade.isEmpty) {
      safeSetState(() {
        _carregando = false;
        _erro = 'Selecione uma propriedade.';
      });
      return;
    }
    safeSetState(() {
      _carregando = true;
      _erro = null;
      if (resetarPagina) _pagina = 0;
    });
    try {
      final offset = _pagina * _tamanhoPagina;
      final resp = await SupaFlow.client
          .from(widget.tableName)
          .select('*')
          .eq('id_propriedade', _idPropriedade)
          .order(widget.orderBy, ascending: widget.ascending)
          .range(offset, offset + _tamanhoPagina - 1)
          .count(CountOption.exact);
      safeSetState(() {
        _registros = List<Map<String, dynamic>>.from(resp.data);
        _total = resp.count;
        _carregando = false;
      });
    } catch (e) {
      safeSetState(() {
        _carregando = false;
        _erro = 'Erro ao carregar: $e';
      });
    }
  }

  void _proximaPagina() {
    if (_pagina + 1 >= _totalPaginas) return;
    safeSetState(() => _pagina++);
    _carregar();
  }

  void _paginaAnterior() {
    if (_pagina <= 0) return;
    safeSetState(() => _pagina--);
    _carregar();
  }

  Future<void> _abrirForm({Map<String, dynamic>? registro}) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => _PaintCrudFormDialog(
        titulo: registro == null
            ? 'Adicionar ${widget.titulo}'
            : 'Editar ${widget.titulo}',
        tableName: widget.tableName,
        idPropriedade: _idPropriedade,
        fields: widget.fields,
        registroExistente: registro,
      ),
    );
    if (salvou == true) await _carregar();
  }

  Future<void> _confirmarDelete(Map<String, dynamic> registro) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      final cfg = await loadPaintConfig(_idPropriedade);
      if (cfg != null) {
        final del = buildPaintDeleteRecord(
          tableName: widget.tableName,
          registro: registro,
          config: cfg,
        );
        if (del != null) {
          await paint_actions.registrarPaintExcluido(
            _idPropriedade,
            del['entidade'] as String?,
            del['chave'] as String?,
            Map<String, dynamic>.from(del['payload'] as Map),
          );
        }
      }
      await SupaFlow.client
          .from(widget.tableName)
          .delete()
          .eq('id', registro['id']);
      await _carregar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cabecalho(context),
                    const SizedBox(height: 12),
                    Expanded(child: _conteudo(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Voltar',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titulo,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Outfit',
                      useGoogleFonts:
                          GoogleFonts.asMap().containsKey('Outfit'),
                    ),
              ),
              if (widget.subtitulo.isNotEmpty)
                Text(
                  widget.subtitulo,
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
            ],
          ),
        ),
        FFButtonWidget(
          onPressed:
              _idPropriedade.isEmpty ? null : () => _abrirForm(registro: null),
          text: widget.insertButtonLabel ?? 'Adicionar',
          icon: const Icon(Icons.add, size: 18),
          options: FFButtonOptions(
            height: 40,
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            color: FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
    );
  }

  Widget _conteudo(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Text(
          _erro!,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }
    if (_registros.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum registro cadastrado.',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 12),
            FFButtonWidget(
              onPressed: _idPropriedade.isEmpty ? null : () => _abrirForm(),
              text: widget.insertButtonLabel ?? 'Adicionar primeiro registro',
              options: FFButtonOptions(
                height: 40,
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width - 32),
                    child: DataTable(
                      columns: [
                        ...widget.columns.map(
                          (c) => DataColumn(label: Text(c.label)),
                        ),
                        const DataColumn(label: Text('')),
                      ],
                      rows: _registros.map((r) {
                        return DataRow(
                          cells: [
                            ...widget.columns.map(
                              (c) => DataCell(
                                Text(
                                  c.formatter != null
                                      ? c.formatter!(r[c.key])
                                      : (r[c.key]?.toString() ?? ''),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () => _abrirForm(registro: r),
                                    tooltip: 'Editar',
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.delete_outline, size: 18),
                                    onPressed: () => _confirmarDelete(r),
                                    tooltip: 'Excluir',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _rodapePaginacao(context),
      ],
    );
  }

  Widget _rodapePaginacao(BuildContext context) {
    final inicio = _total == 0 ? 0 : _pagina * _tamanhoPagina + 1;
    final fim = (_pagina * _tamanhoPagina + _registros.length).clamp(0, _total);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _total == 0
                  ? 'Nenhum registro'
                  : 'Mostrando $inicio–$fim de $_total registros',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ),
          IconButton(
            onPressed: _pagina > 0 && !_carregando ? _paginaAnterior : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),
          Text('${_pagina + 1} / $_totalPaginas',
              style: FlutterFlowTheme.of(context).bodyMedium),
          IconButton(
            onPressed:
                _pagina + 1 < _totalPaginas && !_carregando ? _proximaPagina : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próxima página',
          ),
        ],
      ),
    );
  }
}

class _PaintCrudFormDialog extends StatefulWidget {
  final String titulo;
  final String tableName;
  final String idPropriedade;
  final List<PaintField> fields;
  final Map<String, dynamic>? registroExistente;

  const _PaintCrudFormDialog({
    required this.titulo,
    required this.tableName,
    required this.idPropriedade,
    required this.fields,
    this.registroExistente,
  });

  @override
  State<_PaintCrudFormDialog> createState() => _PaintCrudFormDialogState();
}

class _PaintCrudFormDialogState extends State<_PaintCrudFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {};
  final Map<String, List<PaintDropdownOption>> _loadedOptions = {};
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final r = widget.registroExistente ?? {};
    for (final f in widget.fields) {
      final raw = r[f.key];
      if (f.type == PaintFieldType.text ||
          f.type == PaintFieldType.integer ||
          f.type == PaintFieldType.decimal ||
          f.type == PaintFieldType.date) {
        _controllers[f.key] = TextEditingController(
          text: raw == null ? '' : raw.toString(),
        );
      } else {
        _values[f.key] = raw;
      }
      if (f.optionsLoader != null) {
        f.optionsLoader!().then((opts) {
          if (mounted) {
            safeSetState(() => _loadedOptions[f.key] = opts);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic> _coletarPayload() {
    final payload = <String, dynamic>{
      'id_propriedade': widget.idPropriedade,
    };
    for (final f in widget.fields) {
      switch (f.type) {
        case PaintFieldType.text:
        case PaintFieldType.date:
          final v = _controllers[f.key]?.text.trim() ?? '';
          payload[f.key] = v.isEmpty ? null : v;
          break;
        case PaintFieldType.integer:
          final v = _controllers[f.key]?.text.trim() ?? '';
          payload[f.key] = v.isEmpty ? null : int.tryParse(v);
          break;
        case PaintFieldType.decimal:
          final v = _controllers[f.key]?.text.trim().replaceAll(',', '.') ?? '';
          payload[f.key] = v.isEmpty ? null : double.tryParse(v);
          break;
        case PaintFieldType.dropdown:
        case PaintFieldType.boolean:
          payload[f.key] = _values[f.key];
          break;
      }
    }
    return payload;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    safeSetState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final payload = _coletarPayload();
      final r = widget.registroExistente;
      if (r == null) {
        await SupaFlow.client.from(widget.tableName).insert(payload);
      } else {
        payload['updated_at'] = DateTime.now().toIso8601String();
        await SupaFlow.client
            .from(widget.tableName)
            .update(payload)
            .eq('id', r['id']);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      safeSetState(() {
        _salvando = false;
        _erro = 'Erro ao salvar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...widget.fields.map(_buildField),
                if (_erro != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _erro!,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.red,
                          useGoogleFonts:
                              GoogleFonts.asMap().containsKey('Readex Pro'),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: Text(_salvando ? 'Salvando…' : 'Salvar'),
        ),
      ],
    );
  }

  Widget _buildField(PaintField f) {
    switch (f.type) {
      case PaintFieldType.text:
      case PaintFieldType.integer:
      case PaintFieldType.decimal:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _controllers[f.key],
            maxLength: f.maxLength,
            keyboardType: f.type == PaintFieldType.integer
                ? TextInputType.number
                : f.type == PaintFieldType.decimal
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
            inputFormatters: f.digitsOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              labelText: f.label + (f.required ? ' *' : ''),
              hintText: f.hint,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (v) {
              if (f.required && (v == null || v.trim().isEmpty)) {
                return 'Obrigatório';
              }
              return null;
            },
          ),
        );
      case PaintFieldType.date:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _controllers[f.key],
            readOnly: true,
            decoration: InputDecoration(
              labelText: f.label + (f.required ? ' *' : ''),
              hintText: f.hint ?? 'AAAA-MM-DD',
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onTap: () async {
              final atual = _controllers[f.key]?.text;
              DateTime? inicial;
              if (atual != null && atual.isNotEmpty) {
                inicial = DateTime.tryParse(atual);
              }
              final picked = await showDatePicker(
                context: context,
                initialDate: inicial ?? DateTime.now(),
                firstDate: DateTime(1990),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                _controllers[f.key]?.text =
                    picked.toIso8601String().substring(0, 10);
              }
            },
            validator: (v) {
              if (f.required && (v == null || v.trim().isEmpty)) {
                return 'Obrigatório';
              }
              return null;
            },
          ),
        );
      case PaintFieldType.dropdown:
        final opcoes =
            f.optionsLoader != null ? (_loadedOptions[f.key] ?? []) : f.options;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<String>(
            initialValue: _values[f.key]?.toString(),
            items: opcoes
                .map((o) =>
                    DropdownMenuItem(value: o.value, child: Text(o.label)))
                .toList(),
            decoration: InputDecoration(
              labelText: f.label + (f.required ? ' *' : ''),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) => safeSetState(() => _values[f.key] = v),
            validator: (v) {
              if (f.required && (v == null || v.isEmpty)) {
                return 'Obrigatório';
              }
              return null;
            },
          ),
        );
      case PaintFieldType.boolean:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SwitchListTile(
            title: Text(f.label),
            value: _values[f.key] == true,
            onChanged: (v) => safeSetState(() => _values[f.key] = v),
          ),
        );
    }
  }
}
