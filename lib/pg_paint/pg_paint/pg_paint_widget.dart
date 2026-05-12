import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/custom_code/actions/index.dart' as paint_actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:download/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'pg_paint_model.dart';
export 'pg_paint_model.dart';

class PgPaintWidget extends StatefulWidget {
  const PgPaintWidget({super.key});

  static String routeName = 'pgPaint';
  static String routePath = '/paint';

  @override
  State<PgPaintWidget> createState() => _PgPaintWidgetState();
}

class _PgPaintWidgetState extends State<PgPaintWidget> {
  late PgPaintModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _ultimaPropriedadeId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgPaintModel());

    _model.codTransmissaoFocus = FocusNode();
    _model.codTransmissaoController = TextEditingController();
    _model.serieFazendaFocus = FocusNode();
    _model.serieFazendaController = TextEditingController();
    _model.codFazendaFocus = FocusNode();
    _model.codFazendaController = TextEditingController();

    // Alinha com o primeiro build para não disparar reload duplicado.
    _ultimaPropriedadeId = FFAppState().propriedadeSelecionada.idPropriedade;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (FFAppState().navegacao != 'paint') {
        FFAppState().navegacao = 'paint';
        safeSetState(() {});
      }
      await _carregarConfig();
      await _carregarStatus();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String get _idPropriedade =>
      FFAppState().propriedadeSelecionada.idPropriedade;

  bool _aindaMesmaPropriedade(String propId) =>
      mounted && propId == FFAppState().propriedadeSelecionada.idPropriedade;

  Future<void> _carregarConfig() async {
    if (_idPropriedade.isEmpty) {
      safeSetState(() {
        _model.carregandoConfig = false;
        _model.mensagemConfig = null;
        _model.configId = null;
        _model.codTransmissaoController?.clear();
        _model.serieFazendaController?.clear();
        _model.codFazendaController?.clear();
        _model.mensagemAuto = null;
        _model.mensagemExport = null;
        _model.linkUltimoZip = null;
      });
      return;
    }
    final propId = _idPropriedade;
    safeSetState(() => _model.carregandoConfig = true);
    try {
      // Sempre limpar antes de preencher — senão os controllers mantêm a
      // propriedade anterior e status/botões ficam inconsistentes.
      _model.configId = null;
      _model.codTransmissaoController?.clear();
      _model.serieFazendaController?.clear();
      _model.codFazendaController?.clear();

      final rows = await SupaFlow.client
          .from('paint_fazenda_config')
          .select()
          .eq('id_propriedade', propId)
          .limit(1);
      if (!_aindaMesmaPropriedade(propId)) return;
      if (rows.isNotEmpty) {
        final r = rows.first;
        _model.configId = r['id']?.toString();
        _model.codTransmissaoController?.text = (r['codigo_transmissao'] ?? '').toString();
        _model.serieFazendaController?.text = (r['serie_fazenda'] ?? '').toString();
        _model.codFazendaController?.text = (r['codigo_fazenda'] ?? '').toString();
      } else {
        _model.codFazendaController?.text = '0001';
      }
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.carregandoConfig = false;
        _model.mensagemConfig = null;
      });
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.carregandoConfig = false;
        _model.mensagemConfig = 'Erro ao carregar configuração: $e';
      });
    }
  }

  Future<void> _salvarConfig() async {
    if (_idPropriedade.isEmpty) return;
    final propId = _idPropriedade;
    final codTx = _model.codTransmissaoController?.text.trim() ?? '';
    final serie = _model.serieFazendaController?.text.trim() ?? '';
    final codFz = _model.codFazendaController?.text.trim() ?? '';

    if (!RegExp(r'^[0-9]{6}$').hasMatch(codTx)) {
      safeSetState(() => _model.mensagemConfig =
          'Código de transmissão deve ter exatamente 6 dígitos.');
      return;
    }
    if (serie.isEmpty || serie.length > 4) {
      safeSetState(() => _model.mensagemConfig =
          'Série fazenda obrigatória (1 a 4 caracteres).');
      return;
    }
    if (!RegExp(r'^[0-9]{4}$').hasMatch(codFz)) {
      safeSetState(() => _model.mensagemConfig =
          'Código fazenda deve ter exatamente 4 dígitos.');
      return;
    }

    safeSetState(() {
      _model.salvandoConfig = true;
      _model.mensagemConfig = null;
    });
    try {
      final payload = {
        'id_propriedade': propId,
        'codigo_transmissao': codTx,
        'serie_fazenda': serie,
        'codigo_fazenda': codFz,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await SupaFlow.client
          .from('paint_fazenda_config')
          .upsert(payload, onConflict: 'id_propriedade');
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.salvandoConfig = false);
        return;
      }
      safeSetState(() {
        _model.salvandoConfig = false;
        _model.mensagemConfig =
            '✓ Configuração salva. Agora você pode clicar em "Importar tudo do sistema".';
      });
      await _carregarStatus();
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.salvandoConfig = false);
        return;
      }
      safeSetState(() {
        _model.salvandoConfig = false;
        _model.mensagemConfig = 'Erro ao salvar: $e';
      });
    }
  }

  Future<void> _gerarExport() async {
    if (_idPropriedade.isEmpty) return;
    final propId = _idPropriedade;
    safeSetState(() {
      _model.exportando = true;
      _model.mensagemExport = null;
      _model.linkUltimoZip = null;
    });
    try {
      final response = await SupaFlow.client.functions.invoke(
        'paint-export',
        body: {'idPropriedade': propId},
      );
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.exportando = false);
        return;
      }
      final data = response.data;
      if (data is Map && data['ok'] == true) {
        final signedUrl = data['signedUrl']?.toString() ?? '';
        final nomeZip = data['nomeZip']?.toString() ?? 'paint-export.zip';
        if (signedUrl.isNotEmpty) {
          try {
            final zipResp = await http.get(Uri.parse(signedUrl));
            if (zipResp.statusCode == 200) {
              await download(Stream.fromIterable(zipResp.bodyBytes), nomeZip);
            } else {
              throw Exception('HTTP ${zipResp.statusCode}');
            }
          } catch (e) {
            if (!_aindaMesmaPropriedade(propId)) {
              safeSetState(() => _model.exportando = false);
              return;
            }
            safeSetState(() {
              _model.exportando = false;
              _model.linkUltimoZip = signedUrl;
              _model.mensagemExport =
                  'Exportação gerada, mas falha ao baixar automaticamente: $e';
            });
            return;
          }
        }
        if (!_aindaMesmaPropriedade(propId)) {
          safeSetState(() => _model.exportando = false);
          return;
        }
        safeSetState(() {
          _model.exportando = false;
          _model.linkUltimoZip = null;
          _model.mensagemExport = 'Exportação concluída: $nomeZip';
        });
      } else {
        if (!_aindaMesmaPropriedade(propId)) {
          safeSetState(() => _model.exportando = false);
          return;
        }
        final err = (data is Map ? data['error'] : null) ?? 'Resposta inválida';
        safeSetState(() {
          _model.exportando = false;
          _model.mensagemExport = 'Falha: $err';
        });
      }
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.exportando = false);
        return;
      }
      safeSetState(() {
        _model.exportando = false;
        _model.mensagemExport = 'Erro ao gerar exportação: $e';
      });
    }
  }

  static const List<String> _tabelasStatus = [
    'paint_inseminador',
    'paint_grupo_manejo',
    'paint_localidade',
    'paint_safra',
    'paint_avaliador',
    'paint_regime_alimentar',
    'paint_touro_multiplo',
    'paint_safra_x_animal',
    'paint_composicao_racial',
    'paint_biblioteca_touros',
    'paint_baixa',
    'paint_avaliacao_desmama',
    'paint_avaliacao_sobreano',
    'paint_avaliacao_rah',
    'paint_diagnostico',
  ];

  // paint_biblioteca_touros é catálogo global (sem id_propriedade).
  static const Set<String> _tabelasGlobais = {'paint_biblioteca_touros'};

  Future<void> _carregarStatus() async {
    if (_idPropriedade.isEmpty) {
      safeSetState(() {
        _model.counts = const {};
        _model.carregandoStatus = false;
      });
      return;
    }
    final propId = _idPropriedade;
    safeSetState(() => _model.carregandoStatus = true);
    try {
      // Usar propId capturado: se o usuário trocar de fazenda durante os awaits,
      // o getter _idPropriedade mudaria e misturaria contagens entre propriedades.
      final futures = _tabelasStatus.map((t) async {
        var q = SupaFlow.client.from(t).select('*');
        if (!_tabelasGlobais.contains(t)) {
          q = q.eq('id_propriedade', propId);
        }
        final resp = await q.count(CountOption.exact);
        return MapEntry(t, resp.count);
      });
      final entries = await Future.wait(futures);
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.counts = Map.fromEntries(entries);
        _model.carregandoStatus = false;
      });
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.carregandoStatus = false;
      });
    }
  }

  Future<void> _importarAuto() async {
    if (_idPropriedade.isEmpty) return;
    final propId = _idPropriedade;
    safeSetState(() {
      _model.importandoAuto = true;
      _model.mensagemAuto = null;
    });
    try {
      final r = await paint_actions.autoPreencherPaint(propId);
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.importandoAuto = false);
        return;
      }
      final erro = (r['erro'] ?? 0) as int;
      if (erro == 1) {
        safeSetState(() {
          _model.importandoAuto = false;
          _model.mensagemAuto = '⚠ ${r['mensagem'] ?? 'Falha desconhecida'}';
        });
        return;
      }
      final novos = [
        if ((r['inseminadores'] ?? 0) > 0)
          '${r['inseminadores']} inseminadores',
        if ((r['grupos'] ?? 0) > 0) '${r['grupos']} grupos de manejo',
        if ((r['localidades'] ?? 0) > 0) '${r['localidades']} localidades',
        if ((r['safras'] ?? 0) > 0) '${r['safras']} safra',
        if ((r['composicao'] ?? 0) > 0)
          '${r['composicao']} composições raciais',
        if ((r['avaliadores'] ?? 0) > 0) '${r['avaliadores']} avaliadores',
        if ((r['regimes'] ?? 0) > 0) '${r['regimes']} regimes alimentares',
        if ((r['biblioteca'] ?? 0) > 0) '${r['biblioteca']} touros (biblioteca)',
        if ((r['desmamas'] ?? 0) > 0) '${r['desmamas']} desmamas',
        if ((r['sobreanos'] ?? 0) > 0) '${r['sobreanos']} sobreanos',
        if ((r['rahs'] ?? 0) > 0) '${r['rahs']} RAH',
        if ((r['diagnosticos'] ?? 0) > 0) '${r['diagnosticos']} diagnósticos',
      ];
      final falhas = (r['falhas'] as List?)?.cast<String>() ?? const [];
      final msgBase = novos.isEmpty
          ? '✓ Nenhum novo registro — tudo já estava preenchido.'
          : '✓ Importado: ${novos.join(', ')}.';
      final msg = falhas.isEmpty
          ? msgBase
          : '$msgBase\n⚠ ${falhas.length} etapa(s) falharam:\n• ${falhas.join('\n• ')}';
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.importandoAuto = false);
        return;
      }
      safeSetState(() {
        _model.importandoAuto = false;
        _model.mensagemAuto = msg;
      });
      await _carregarStatus();
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.importandoAuto = false);
        return;
      }
      safeSetState(() {
        _model.importandoAuto = false;
        _model.mensagemAuto = '⚠ Erro: $e';
      });
    }
  }

  int _count(String tabela) => _model.counts[tabela] ?? 0;

  static const List<String> _tabelasCadastros = [
    'paint_avaliador',
    'paint_inseminador',
    'paint_grupo_manejo',
    'paint_localidade',
    'paint_regime_alimentar',
    'paint_safra',
    'paint_safra_x_animal',
    'paint_composicao_racial',
    'paint_biblioteca_touros',
    'paint_baixa',
    'paint_touro_multiplo',
  ];

  int get _totalCadastros =>
      _tabelasCadastros.where((t) => _count(t) > 0).length;

  bool get _configCompleta {
    final tx = _model.codTransmissaoController?.text.trim() ?? '';
    final se = _model.serieFazendaController?.text.trim() ?? '';
    final fz = _model.codFazendaController?.text.trim() ?? '';
    return RegExp(r'^[0-9]{6}$').hasMatch(tx) &&
        se.isNotEmpty &&
        RegExp(r'^[0-9]{4}$').hasMatch(fz);
  }

  @override
  Widget build(BuildContext context) {
    // Depende só do id — assim qualquer troca no header reconstrói e dispara reload.
    final idAtual =
        context.select<FFAppState, String>((s) => s.propriedadeSelecionada.idPropriedade);
    if (idAtual != _ultimaPropriedadeId) {
      _ultimaPropriedadeId = idAtual;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _carregarConfig();
        await _carregarStatus();
      });
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            wrapWithModel(
              model: _model.headerModel,
              updateCallback: () => safeSetState(() {}),
              child: const HeaderWidget(),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    wrapWithModel(
                      model: _model.sideBarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: const SideBarWidget(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _tituloModulo(context),
                            const SizedBox(height: 16),
                            if (idAtual.isEmpty) ...[
                              _painelSelecionePropriedade(context),
                            ] else ...[
                              _cardStatus(context),
                              const SizedBox(height: 16),
                              _cardConfig(context),
                              const SizedBox(height: 16),
                              _cardCadastrosAuto(context),
                              const SizedBox(height: 16),
                              _cardCadastrosManuais(context),
                              const SizedBox(height: 16),
                              _cardAvaliacoes(context),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloModulo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAINT — Exportação de dados',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                useGoogleFonts: GoogleFonts.asMap().containsKey('Outfit'),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gera o ZIP no formato exigido pelo programa PAINT (manual oficial — 22 arquivos de largura fixa).',
          style: FlutterFlowTheme.of(context).bodySmall,
        ),
      ],
    );
  }

  Widget _painelSelecionePropriedade(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Color(0x14000000), offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.home_work_outlined, color: theme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione uma propriedade',
                  style: theme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use o menu "Propriedade" no topo da página. '
                  'As informações de exportação PAINT, configuração e cadastros '
                  'são sempre por fazenda — elas aparecem aqui depois da seleção.',
                  style: theme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String titulo,
    required Widget child,
    bool destacar = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: destacar
            ? Border.all(color: Colors.orange.shade400, width: 2)
            : null,
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Color(0x14000000), offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (destacar) ...[
                Icon(Icons.priority_high,
                    color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 6),
              ],
              Text(
                titulo,
                style: FlutterFlowTheme.of(context).titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _cardConfig(BuildContext context) {
    return _card(
      context,
      titulo: 'Configuração PAINT',
      destacar: !_model.carregandoConfig && !_configCompleta,
      child: _model.carregandoConfig
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_configCompleta) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.orange.shade800, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Esta propriedade ainda não tem códigos PAINT. '
                            'Preencha os 3 códigos abaixo (fornecidos pela equipe PAINT) '
                            'e clique "Salvar configuração". Sem isso, "Importar tudo do sistema" '
                            'e "Gerar EXPORTACAO DADOS" ficam desabilitados.',
                            style: FlutterFlowTheme.of(context).bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Códigos fornecidos pela equipe PAINT (contatopaint@paintmga.com.br).',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _campoTexto(
                      label: 'Código de transmissão (6 dígitos)',
                      controller: _model.codTransmissaoController,
                      focus: _model.codTransmissaoFocus,
                      width: 260,
                      maxLength: 6,
                      digitsOnly: true,
                    ),
                    _campoTexto(
                      label: 'Série fazenda (até 4 caracteres)',
                      controller: _model.serieFazendaController,
                      focus: _model.serieFazendaFocus,
                      width: 260,
                      maxLength: 4,
                    ),
                    _campoTexto(
                      label: 'Código fazenda (4 dígitos)',
                      controller: _model.codFazendaController,
                      focus: _model.codFazendaFocus,
                      width: 200,
                      maxLength: 4,
                      digitsOnly: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FFButtonWidget(
                      onPressed: _model.salvandoConfig ? null : _salvarConfig,
                      text: _model.salvandoConfig ? 'Salvando…' : 'Salvar configuração',
                      options: FFButtonOptions(
                        height: 40,
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
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
                if (_model.mensagemConfig != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _model.mensagemConfig!,
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController? controller,
    required FocusNode? focus,
    double width = 260,
    int? maxLength,
    bool digitsOnly = false,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        focusNode: focus,
        maxLength: maxLength,
        keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
        inputFormatters: digitsOnly
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _cardStatus(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final cfgOk = _configCompleta;
    return _card(
      context,
      titulo: 'Status PAINT',
      child: _model.carregandoStatus
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusLinha(
                  icone: cfgOk ? Icons.check_circle : Icons.warning_amber,
                  cor: cfgOk ? Colors.green : Colors.orange,
                  texto: cfgOk
                      ? 'Configuração PAINT preenchida.'
                      : 'Configuração PAINT incompleta para esta propriedade — '
                          'role para baixo, preencha os códigos PAINT e clique "Salvar configuração". '
                          'Os botões abaixo ficam liberados depois disso.',
                ),
                const SizedBox(height: 8),
                _statusLinha(
                  icone: Icons.dataset,
                  cor: theme.primary,
                  texto:
                      '$_totalCadastros de ${_tabelasCadastros.length} cadastros já têm dados nesta propriedade.',
                ),
                const SizedBox(height: 8),
                _statusLinha(
                  icone: Icons.info_outline,
                  cor: Colors.blueGrey,
                  texto:
                      'Notas técnicas (C/P/M/U/T/CE/A/racial/aprumos/harmonia) das avaliações '
                      'são preenchidas pelo técnico PAINT em campo — peso e data são derivados '
                      'automaticamente.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FFButtonWidget(
                      onPressed: (_model.importandoAuto || !cfgOk)
                          ? null
                          : _importarAuto,
                      text: _model.importandoAuto
                          ? 'Importando…'
                          : 'Importar tudo do sistema',
                      icon: const Icon(Icons.cloud_download, size: 18),
                      options: FFButtonOptions(
                        height: 44,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                        color: theme.secondaryBackground,
                        textStyle: theme.titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: theme.primary,
                          useGoogleFonts:
                              GoogleFonts.asMap().containsKey('Readex Pro'),
                        ),
                        elevation: 0,
                        borderSide: BorderSide(color: theme.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: (_model.exportando || !cfgOk)
                          ? null
                          : _gerarExport,
                      text: _model.exportando
                          ? 'Gerando…'
                          : 'Gerar EXPORTACAO DADOS',
                      icon: const Icon(
                        Icons.download,
                        size: 18,
                        color: Colors.white,
                      ),
                      options: FFButtonOptions(
                        height: 44,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
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
                if (_model.mensagemAuto != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _model.mensagemAuto!,
                    style: theme.bodyMedium,
                  ),
                ],
                if (_model.mensagemExport != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _model.mensagemExport!,
                    style: theme.bodyMedium,
                  ),
                ],
                if (_model.linkUltimoZip != null) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    _model.linkUltimoZip!,
                    style: theme.bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: theme.primary,
                      useGoogleFonts:
                          GoogleFonts.asMap().containsKey('Readex Pro'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _statusLinha({
    required IconData icone,
    required Color cor,
    required String texto,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: cor, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: FlutterFlowTheme.of(context).bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _cardCadastrosAuto(BuildContext context) {
    return _card(
      context,
      titulo: 'Cadastros automáticos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Derivados de dados existentes (lotes, reproduções, rebanho, usuários). '
            'Use "Importar tudo do sistema" para preencher de uma vez. Você pode editar '
            'cada cadastro depois clicando nos chips abaixo.',
            style: FlutterFlowTheme.of(context).bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CadastroChip(
                label: 'Avaliadores',
                tabela: 'paint_avaliador',
                routeName: 'pgPaintAvaliador',
                count: _count('paint_avaliador'),
              ),
              _CadastroChip(
                label: 'Inseminadores',
                tabela: 'paint_inseminador',
                routeName: 'pgPaintInseminador',
                count: _count('paint_inseminador'),
              ),
              _CadastroChip(
                label: 'Grupos de manejo',
                tabela: 'paint_grupo_manejo',
                routeName: 'pgPaintGrupoManejo',
                count: _count('paint_grupo_manejo'),
              ),
              _CadastroChip(
                label: 'Localidades / pastos',
                tabela: 'paint_localidade',
                routeName: 'pgPaintLocalidade',
                count: _count('paint_localidade'),
              ),
              _CadastroChip(
                label: 'Regimes alimentares',
                tabela: 'paint_regime_alimentar',
                routeName: 'pgPaintRegimeAlimentar',
                count: _count('paint_regime_alimentar'),
              ),
              _CadastroChip(
                label: 'Safras',
                tabela: 'paint_safra',
                routeName: 'pgPaintSafra',
                count: _count('paint_safra'),
              ),
              _CadastroChip(
                label: 'Matrizes por safra',
                tabela: 'paint_safra_x_animal',
                routeName: 'pgPaintSafraXAnimal',
                count: _count('paint_safra_x_animal'),
              ),
              _CadastroChip(
                label: 'Composição racial',
                tabela: 'paint_composicao_racial',
                routeName: 'pgPaintComposicaoRacial',
                count: _count('paint_composicao_racial'),
              ),
              _CadastroChip(
                label: 'Biblioteca de touros A12',
                tabela: 'paint_biblioteca_touros',
                routeName: 'pgPaintBibliotecaTouros',
                count: _count('paint_biblioteca_touros'),
              ),
              _CadastroChip(
                label: 'Baixas',
                tabela: 'paint_baixa',
                count: _count('paint_baixa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardCadastrosManuais(BuildContext context) {
    return _card(
      context,
      titulo: 'Cadastros manuais (raros)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sem fonte automática — preencha apenas se a equipe PAINT solicitar.',
            style: FlutterFlowTheme.of(context).bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CadastroChip(
                label: 'Touro múltiplo',
                tabela: 'paint_touro_multiplo',
                routeName: 'pgPaintTouroMultiplo',
                count: _count('paint_touro_multiplo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardAvaliacoes(BuildContext context) {
    return _card(
      context,
      titulo: 'Avaliações técnicas PAINT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Peso e data são derivados automaticamente do rebanho/pesagens. '
                  'Notas técnicas (C/P/M/U/T/CE/A/racial/aprumos/harmonia) precisam '
                  'ser revisadas pelo técnico PAINT antes da exportação.',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CadastroChip(
                label: 'Desmama',
                tabela: 'paint_avaliacao_desmama',
                routeName: 'pgPaintAvaliacaoDesmama',
                count: _count('paint_avaliacao_desmama'),
              ),
              _CadastroChip(
                label: 'Sobreano',
                tabela: 'paint_avaliacao_sobreano',
                routeName: 'pgPaintAvaliacaoSobreano',
                count: _count('paint_avaliacao_sobreano'),
              ),
              _CadastroChip(
                label: 'RAH (raça/aprumo/harmonia)',
                tabela: 'paint_avaliacao_rah',
                routeName: 'pgPaintAvaliacaoRah',
                count: _count('paint_avaliacao_rah'),
              ),
              _CadastroChip(
                label: 'Diagnóstico',
                tabela: 'paint_diagnostico',
                routeName: 'pgPaintDiagnostico',
                count: _count('paint_diagnostico'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CadastroChip extends StatelessWidget {
  final String label;
  final String tabela;
  final String? routeName;
  final int count;
  const _CadastroChip({
    required this.label,
    required this.tabela,
    this.routeName,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tem = count > 0;
    final fundo = tem ? Colors.green.shade50 : Colors.orange.shade50;
    final borda = tem ? Colors.green.shade400 : Colors.orange.shade400;
    final corTexto = tem ? Colors.green.shade900 : Colors.orange.shade900;
    return InputChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(color: corTexto, fontWeight: FontWeight.w500),
      ),
      backgroundColor: fundo,
      side: BorderSide(color: borda),
      onPressed: () {
        if (routeName != null) {
          context.pushNamed(routeName!);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tela de "$label" em construção (tabela: $tabela).',
            ),
          ),
        );
      },
    );
  }
}
