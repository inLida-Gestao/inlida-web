// Historico de importacoes da propriedade.
//
// Serve a duas pessoas: o produtor, que quer saber por que a planilha dele nao
// entrou, e o suporte, que precisa investigar depois do fato sem pedir o
// arquivo de volta. Ate agora nao havia nem uma coisa nem outra -- o unico
// registro de uma importacao era print() no console do browser.
//
// O drill-down reaproveita o proprio popup de pre-confirmacao em
// somenteLeitura: um widget, duas telas, e o que o usuario ve depois e
// exatamente o que ele viu antes de confirmar.

import 'package:flutter/material.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/importacao/import_auditoria_repository.dart';
import '/importacao/pp_pre_confirmacao_importacao_widget.dart';

import 'pg_auditoria_importacao_model.dart';

class PgAuditoriaImportacaoWidget extends StatefulWidget {
  const PgAuditoriaImportacaoWidget({super.key});

  static String routeName = 'pgAuditoriaImportacao';
  static String routePath = '/auditoria-importacao';

  @override
  State<PgAuditoriaImportacaoWidget> createState() =>
      _PgAuditoriaImportacaoWidgetState();
}

class _PgAuditoriaImportacaoWidgetState
    extends State<PgAuditoriaImportacaoWidget> {
  late PgAuditoriaImportacaoModel _model;

  static const _porPagina = 25;

  List<Map<String, dynamic>> _linhas = [];
  bool _carregando = true;
  String? _erro;
  bool _temMais = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, PgAuditoriaImportacaoModel.new);
    _carregar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String get _idPropriedade =>
      FFAppState().propriedadeSelecionada.idPropriedade;

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final inicio = _model.pagina * _porPagina;
      var query = SupaFlow.client
          .from('import_auditoria')
          .select()
          .eq('id_propriedade', _idPropriedade);

      if (_model.filtroEntidade != null) {
        query = query.eq('entidade', _model.filtroEntidade!);
      }
      if (_model.filtroStatus != null) {
        query = query.eq('status', _model.filtroStatus!);
      }
      if (_model.apenasComBloqueio) {
        query = query.gt('total_bloqueantes', 0);
      }

      // Pede um a mais para saber se existe proxima pagina, sem precisar de
      // uma contagem separada.
      final res = await query
          .order('created_at', ascending: false)
          .range(inicio, inicio + _porPagina);

      final linhas = (res as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      setState(() {
        _temMais = linhas.length > _porPagina;
        _linhas = _temMais ? linhas.sublist(0, _porPagina) : linhas;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  /// Remonta o diagnostico a partir do que foi gravado e reabre o popup em
  /// modo leitura.
  Future<void> _abrirDetalhe(Map<String, dynamic> auditoria) async {
    final id = auditoria['id']?.toString();
    if (id == null) return;

    try {
      final resumos = await SupaFlow.client
          .from('import_auditoria_resumo')
          .select()
          .eq('auditoria_id', id);
      final itens = await SupaFlow.client
          .from('import_auditoria_item')
          .select()
          .eq('auditoria_id', id)
          .order('linha');

      final alteracoes = await SupaFlow.client
          .from('import_auditoria_alteracao')
          .select()
          .eq('auditoria_id', id)
          .order('linha');

      final diagnostico = remontarDiagnosticoDaAuditoria(
        auditoria: auditoria,
        resumos: (resumos as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        itens: (itens as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        alteracoes: (alteracoes as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );

      if (!mounted) return;
      await PpPreConfirmacaoImportacaoWidget.mostrar(
        context,
        diagnostico: diagnostico,
        nomeEntidade: _rotuloEntidade(auditoria['entidade']?.toString()),
        somenteLeitura: true,
        autor: _autor(auditoria),
        quando: _dataHora(auditoria['created_at']?.toString()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível abrir o detalhe: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  String _rotuloEntidade(String? v) => switch (v) {
        'rebanho' => 'Rebanho',
        'pesagem' => 'Pesagem',
        'lotes' => 'Lotes',
        'reproducao' => 'Reprodução',
        _ => v ?? '-',
      };

  String _rotuloStatus(String? v) => switch (v) {
        'sucesso' => 'Concluída',
        'parcial' => 'Com falhas',
        'cancelada' => 'Cancelada',
        'erro' => 'Erro',
        'aguardando_confirmacao' => 'Não confirmada',
        'importando' => 'Em andamento',
        'diagnosticando' => 'Em leitura',
        _ => v ?? '-',
      };

  Color _corStatus(String? v, FlutterFlowTheme tema) => switch (v) {
        'sucesso' => tema.success,
        'parcial' => tema.warning,
        'erro' => tema.error,
        'cancelada' => tema.secondaryText,
        _ => tema.secondaryText,
      };

  /// Quem fez a importacao. Usa o snapshot gravado na propria auditoria: a
  /// RLS de public.users so deixa o usuario ler o proprio registro, entao um
  /// join nao responderia "quem da equipe importou".
  String _autor(Map<String, dynamic> a) {
    final nome = a['usuario_nome']?.toString().trim();
    if (nome != null && nome.isNotEmpty) return nome;
    final email = a['usuario_email']?.toString().trim();
    if (email != null && email.isNotEmpty) return email;
    return 'usuário não identificado';
  }

  String _dataHora(String? iso) {
    final d = DateTime.tryParse(iso ?? '')?.toLocal();
    if (d == null) return '-';
    String dois(int v) => v.toString().padLeft(2, '0');
    return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: tema.primaryBackground,
      appBar: AppBar(
        backgroundColor: tema.primary,
        foregroundColor: Colors.white,
        title: const Text('Histórico de importações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregando ? null : _carregar,
          ),
        ],
      ),
      body: Column(
        children: [
          _filtros(tema),
          const Divider(height: 1),
          Expanded(child: _conteudo(tema)),
          if (_linhas.isNotEmpty) _paginacao(tema),
        ],
      ),
    );
  }

  Widget _filtros(FlutterFlowTheme tema) => Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String?>(
              value: _model.filtroEntidade,
              hint: const Text('Todas as planilhas'),
              items: const [
                DropdownMenuItem(
                    value: null, child: Text('Todas as planilhas')),
                DropdownMenuItem(value: 'rebanho', child: Text('Rebanho')),
                DropdownMenuItem(value: 'pesagem', child: Text('Pesagem')),
              ],
              onChanged: (v) {
                _model.filtroEntidade = v;
                _model.pagina = 0;
                _carregar();
              },
            ),
            DropdownButton<String?>(
              value: _model.filtroStatus,
              hint: const Text('Qualquer situação'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Qualquer situação')),
                DropdownMenuItem(value: 'sucesso', child: Text('Concluída')),
                DropdownMenuItem(value: 'parcial', child: Text('Com falhas')),
                DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                DropdownMenuItem(value: 'erro', child: Text('Erro')),
              ],
              onChanged: (v) {
                _model.filtroStatus = v;
                _model.pagina = 0;
                _carregar();
              },
            ),
            FilterChip(
              label: const Text('Só com bloqueio'),
              selected: _model.apenasComBloqueio,
              onSelected: (v) {
                _model.apenasComBloqueio = v;
                _model.pagina = 0;
                _carregar();
              },
            ),
          ],
        ),
      );

  Widget _conteudo(FlutterFlowTheme tema) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Não foi possível carregar o histórico.\n$_erro',
              textAlign: TextAlign.center, style: tema.bodyMedium),
        ),
      );
    }
    if (_linhas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Nenhuma importação registrada para esta propriedade.',
            textAlign: TextAlign.center,
            style: tema.bodyMedium.copyWith(color: tema.secondaryText),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _linhas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _cartao(tema, _linhas[i]),
    );
  }

  Widget _cartao(FlutterFlowTheme tema, Map<String, dynamic> a) {
    final status = a['status']?.toString();
    final corStatus = _corStatus(status, tema);
    final bloqueados = (a['previstos_bloquear'] as num?)?.toInt() ?? 0;

    return InkWell(
      onTap: () => _abrirDetalhe(a),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tema.secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: tema.alternate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_rotuloEntidade(a['entidade']?.toString())} · '
                    '${a['nome_arquivo'] ?? 'arquivo sem nome'}',
                    style:
                        tema.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corStatus.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(_rotuloStatus(status),
                      style: tema.bodySmall.copyWith(
                          color: corStatus, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: tema.secondaryText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_autor(a)} · ${_dataHora(a['created_at']?.toString())}',
                    style: tema.bodySmall.copyWith(color: tema.secondaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _metrica(tema, 'Linhas', a['total_linhas']),
                _metrica(tema, 'Criados', a['criados'], cor: tema.success),
                _metrica(tema, 'Atualizados', a['atualizados'],
                    cor: tema.warning),
                if (bloqueados > 0)
                  _metrica(tema, 'Bloqueados', bloqueados, cor: tema.error),
                _metrica(tema, 'Falhas', a['falhados'], cor: tema.error),
              ],
            ),
            if (a['usou_fallback_posicional'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Cabeçalho da planilha não foi reconhecido',
                    style: tema.bodySmall.copyWith(color: tema.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metrica(FlutterFlowTheme tema, String rotulo, dynamic valor,
          {Color? cor}) =>
      RichText(
        text: TextSpan(
          style: tema.bodySmall.copyWith(color: tema.secondaryText),
          children: [
            TextSpan(text: '$rotulo: '),
            TextSpan(
              text: '${(valor as num?)?.toInt() ?? 0}',
              style: tema.bodySmall.copyWith(
                  color: cor ?? tema.primaryText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget _paginacao(FlutterFlowTheme tema) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Página anterior',
              onPressed: _model.pagina > 0
                  ? () {
                      _model.pagina--;
                      _carregar();
                    }
                  : null,
            ),
            Text('Página ${_model.pagina + 1}', style: tema.bodySmall),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Próxima página',
              onPressed: _temMais
                  ? () {
                      _model.pagina++;
                      _carregar();
                    }
                  : null,
            ),
          ],
        ),
      );
}
