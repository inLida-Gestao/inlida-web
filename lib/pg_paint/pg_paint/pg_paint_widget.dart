import 'dart:async';

import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/custom_code/actions/index.dart' as paint_actions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
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
  Timer? _exportStatusTimer;

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
      await _carregarUltimoJobExport();
    });
  }

  @override
  void dispose() {
    _pararAcompanhamentoExport();
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
        _model.programa = 'P';
        _model.estrategiaA12 = 'compacto';
        _model.campoOrigemAnimal = 'numeroAnimal';
        _model.mensagemAuto = null;
        _model.mensagemExport = null;
        _model.linkUltimoZip = null;
        _limparJobExport();
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
        _model.codTransmissaoController?.text =
            (r['codigo_transmissao'] ?? '').toString();
        _model.serieFazendaController?.text =
            (r['serie_fazenda'] ?? '').toString();
        _model.codFazendaController?.text =
            (r['codigo_fazenda'] ?? '').toString();
        _model.programa = 'P';
        _model.estrategiaA12 = (r['estrategia_a12'] ?? 'compacto').toString();
        _model.campoOrigemAnimal =
            (r['campo_origem_animal'] ?? 'numeroAnimal').toString();
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
        'programa': _model.programa,
        'estrategia_a12': _model.estrategiaA12,
        'campo_origem_animal': _model.campoOrigemAnimal,
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

  void _limparJobExport() {
    _model.exportJobId = null;
    _model.exportJobStatus = null;
    _model.exportJobErro = null;
    _model.exportNomeZip = null;
    _model.exportStoragePath = null;
    _model.exportStartedAt = null;
    _model.exportFinishedAt = null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool _jobExportTravado() {
    if (_model.exportJobStatus != 'running') return false;
    final started = _model.exportStartedAt;
    if (started == null) return false;
    return DateTime.now().toUtc().difference(started.toUtc()) >
        const Duration(minutes: 5);
  }

  void _pararAcompanhamentoExport() {
    _exportStatusTimer?.cancel();
    _exportStatusTimer = null;
  }

  void _iniciarAcompanhamentoExport(String propId) {
    _pararAcompanhamentoExport();
    _exportStatusTimer =
        Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!_aindaMesmaPropriedade(propId)) {
        _pararAcompanhamentoExport();
        return;
      }
      await _carregarUltimoJobExport(
        propId: propId,
        baixarQuandoConcluir: true,
      );
    });
  }

  Future<void> _carregarUltimoJobExport({
    String? propId,
    bool baixarQuandoConcluir = false,
  }) async {
    final idProp = propId ?? _idPropriedade;
    if (idProp.isEmpty) return;
    try {
      final rows = await SupaFlow.client
          .from('paint_export_job')
          .select(
              'id,status,erro,nome_zip,storage_path,total_animais,started_at,finished_at,created_at')
          .eq('id_propriedade', idProp)
          .order('created_at', ascending: false)
          .limit(1);
      if (!_aindaMesmaPropriedade(idProp)) return;
      if (rows.isEmpty) {
        safeSetState(() => _limparJobExport());
        return;
      }

      final job = Map<String, dynamic>.from(rows.first as Map);
      final status = job['status']?.toString();
      final storagePath = job['storage_path']?.toString() ?? '';
      final nomeZip = job['nome_zip']?.toString() ?? 'paint-export.zip';
      safeSetState(() {
        _model.exportJobId = job['id']?.toString();
        _model.exportJobStatus = status;
        _model.exportJobErro = job['erro']?.toString();
        _model.exportNomeZip = nomeZip;
        _model.exportStoragePath = storagePath;
        _model.exportStartedAt = _parseDateTime(job['started_at']);
        _model.exportFinishedAt = _parseDateTime(job['finished_at']);

        if (status == 'running') {
          _model.exportando = !_jobExportTravado();
          _model.mensagemExport = _jobExportTravado()
              ? 'A exportação anterior parece travada. Você pode tentar gerar novamente.'
              : 'Exportação em andamento. A tela vai baixar o ZIP automaticamente quando concluir.';
        } else if (status == 'error') {
          _model.exportando = false;
          _model.mensagemExport =
              'Falha na exportação: ${_model.exportJobErro ?? 'erro não informado'}';
        } else if (status == 'success' && !baixarQuandoConcluir) {
          _model.exportando = false;
          _model.mensagemExport = 'Última exportação concluída: $nomeZip';
        }
      });

      if (status == 'running' &&
          !_jobExportTravado() &&
          !baixarQuandoConcluir &&
          _exportStatusTimer == null) {
        _iniciarAcompanhamentoExport(idProp);
      } else if (status == 'running' && _jobExportTravado()) {
        _pararAcompanhamentoExport();
      } else if (status == 'error') {
        _pararAcompanhamentoExport();
      } else if (status == 'success' && baixarQuandoConcluir) {
        _pararAcompanhamentoExport();
        await _baixarZipExport(storagePath: storagePath, nomeZip: nomeZip);
      }
    } catch (e) {
      if (!_aindaMesmaPropriedade(idProp)) return;
      safeSetState(() {
        _model.exportando = false;
        _model.mensagemExport = 'Erro ao consultar status da exportação: $e';
      });
    }
  }

  Future<void> _baixarZipExport({
    required String storagePath,
    required String nomeZip,
    String? signedUrl,
  }) async {
    if (storagePath.isEmpty && (signedUrl == null || signedUrl.isEmpty)) {
      safeSetState(() {
        _model.exportando = false;
        _model.mensagemExport =
            'Exportação concluída, mas o caminho do ZIP não foi retornado.';
      });
      return;
    }

    safeSetState(() => _model.baixandoExport = true);
    try {
      final url = signedUrl?.isNotEmpty == true
          ? signedUrl!
          : await SupaFlow.client.storage
              .from('paint-exports')
              .createSignedUrl(storagePath, 3600);
      final zipResp = await http.get(Uri.parse(url));
      if (zipResp.statusCode != 200) {
        throw Exception('HTTP ${zipResp.statusCode}');
      }
      await download(Stream.fromIterable(zipResp.bodyBytes), nomeZip);
      if (!mounted) return;
      safeSetState(() {
        _model.exportando = false;
        _model.baixandoExport = false;
        _model.linkUltimoZip = null;
        _model.mensagemExport = 'Exportação concluída e baixada: $nomeZip';
      });
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _model.exportando = false;
        _model.baixandoExport = false;
        _model.linkUltimoZip = signedUrl;
        _model.mensagemExport =
            'Exportação concluída, mas falha ao baixar automaticamente: $e';
      });
    }
  }

  Future<void> _gerarExport() async {
    if (_idPropriedade.isEmpty) return;
    final propId = _idPropriedade;
    safeSetState(() {
      _model.exportando = true;
      _model.baixandoExport = false;
      _model.mensagemExport = null;
      _model.linkUltimoZip = null;
    });
    _iniciarAcompanhamentoExport(propId);
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
        final isAsync = data['async'] == true;
        final signedUrl = data['signedUrl']?.toString() ?? '';
        if (isAsync || signedUrl.isEmpty) {
          await _carregarUltimoJobExport(
            propId: propId,
            baixarQuandoConcluir: true,
          );
          return;
        }
        final nomeZip = data['nomeZip']?.toString() ?? 'paint-export.zip';
        final storagePath = data['storagePath']?.toString() ??
            _model.exportStoragePath ??
            '';
        _pararAcompanhamentoExport();
        await _carregarUltimoJobExport(propId: propId);
        await _baixarZipExport(
          storagePath: storagePath,
          nomeZip: nomeZip,
          signedUrl: signedUrl,
        );
      } else {
        if (!_aindaMesmaPropriedade(propId)) {
          safeSetState(() => _model.exportando = false);
          return;
        }
        final err = (data is Map ? data['error'] : null) ?? 'Resposta inválida';
        await _carregarUltimoJobExport(
          propId: propId,
          baixarQuandoConcluir: true,
        );
        if (_model.exportJobStatus != 'running') {
          safeSetState(() {
            _model.exportando = false;
            _model.mensagemExport = 'Falha: $err';
          });
        }
      }
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) {
        safeSetState(() => _model.exportando = false);
        return;
      }
      await _carregarUltimoJobExport(
        propId: propId,
        baixarQuandoConcluir: true,
      );
      if (_model.exportJobStatus != 'running') {
        safeSetState(() {
          _model.exportando = false;
          _model.mensagemExport = 'Erro ao gerar exportação: $e';
        });
      }
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
    'paint_estoque',
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
        if ((r['biblioteca'] ?? 0) > 0)
          '${r['biblioteca']} touros (biblioteca)',
        if ((r['desmamas'] ?? 0) > 0) '${r['desmamas']} desmamas',
        if ((r['sobreanos'] ?? 0) > 0) '${r['sobreanos']} sobreanos',
        if ((r['rahs'] ?? 0) > 0) '${r['rahs']} RAH',
        if ((r['diagnosticos'] ?? 0) > 0) '${r['diagnosticos']} diagnósticos',
      ];
      final falhas = (r['falhas'] as List?)?.cast<String>() ?? const [];
      final msg = falhas.isEmpty
          ? (novos.isEmpty
              ? '✓ Nenhum novo registro — tudo já estava preenchido.'
              : '✓ Importado: ${novos.join(', ')}.')
          : (novos.isEmpty
              ? '⚠ Importação concluída com alertas. Nenhum novo registro foi criado.\n'
                  '${falhas.length} etapa(s) precisam de atenção:\n• ${falhas.join('\n• ')}'
              : '⚠ Importação parcialmente concluída. Importado: ${novos.join(', ')}.\n'
                  '${falhas.length} etapa(s) precisam de atenção:\n• ${falhas.join('\n• ')}');
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
    'paint_estoque',
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
    final idAtual = context.select<FFAppState, String>(
        (s) => s.propriedadeSelecionada.idPropriedade);
    if (idAtual != _ultimaPropriedadeId) {
      _ultimaPropriedadeId = idAtual;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _carregarConfig();
        await _carregarStatus();
        await _carregarUltimoJobExport();
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
                              // 1º: configuração — só faz sentido ver status/import/cadastros
                              // depois dos 3 códigos PAINT válidos nesta fazenda.
                              _cardConfig(context),
                              if (!_model.carregandoConfig &&
                                  !_configCompleta) ...[
                                const SizedBox(height: 12),
                                _dicaAguardandoConfig(context),
                              ],
                              if (!_model.carregandoConfig &&
                                  _configCompleta) ...[
                                const SizedBox(height: 16),
                                _cardStatus(context),
                                const SizedBox(height: 16),
                                _cardPlanilhasExcel(context),
                                const SizedBox(height: 16),
                                _cardCadastrosAuto(context),
                                const SizedBox(height: 16),
                                _cardCadastrosManuais(context),
                                const SizedBox(height: 16),
                                _cardAvaliacoes(context),
                              ],
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

  Widget _dicaAguardandoConfig(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Text(
      'Quando os três códigos estiverem válidos (6 + série + 4 dígitos), '
      'aparecem aqui o status, a importação, os cadastros e as avaliações desta fazenda.',
      style: theme.bodySmall.override(
        color: theme.secondaryText,
        fontStyle: FontStyle.italic,
      ),
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
          BoxShadow(
              blurRadius: 8, color: Color(0x14000000), offset: Offset(0, 2)),
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
          BoxShadow(
              blurRadius: 8, color: Color(0x14000000), offset: Offset(0, 2)),
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
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        initialValue: 'P',
                        readOnly: true,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Programa A12',
                          helperText: 'Fixo: PAINT',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 280,
                      child: DropdownButtonFormField<String>(
                        value: _model.estrategiaA12,
                        decoration: InputDecoration(
                          labelText: 'Estratégia A12',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'compacto',
                            child: Text('Compacto (P+serie+animal)'),
                          ),
                          DropdownMenuItem(
                            value: 'espacado',
                            child: Text('Espaçado (sample 000460)'),
                          ),
                          DropdownMenuItem(
                            value: 'ultimos_digitos_nome',
                            child: Text('Últimos 6 dígitos do nome'),
                          ),
                        ],
                        onChanged: (v) => safeSetState(
                          () => _model.estrategiaA12 = v ?? 'compacto',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<String>(
                        value: _model.campoOrigemAnimal,
                        decoration: InputDecoration(
                          labelText: 'Campo origem animal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'numeroAnimal',
                            child: Text('Número animal'),
                          ),
                          DropdownMenuItem(
                            value: 'nome',
                            child: Text('Nome'),
                          ),
                          DropdownMenuItem(
                            value: 'chip',
                            child: Text('Chip'),
                          ),
                          DropdownMenuItem(
                            value: 'codRegistro',
                            child: Text('Registro'),
                          ),
                        ],
                        onChanged: (v) => safeSetState(
                          () => _model.campoOrigemAnimal = v ?? 'numeroAnimal',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FFButtonWidget(
                      onPressed: _model.salvandoConfig ? null : _salvarConfig,
                      text: _model.salvandoConfig
                          ? 'Salvando…'
                          : 'Salvar configuração',
                      options: FFButtonOptions(
                        height: 40,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context)
                            .titleSmall
                            .override(
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
        inputFormatters:
            digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (_) => safeSetState(() {}),
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
                      onPressed: (_model.exportando ||
                              _model.baixandoExport ||
                              !cfgOk)
                          ? null
                          : _gerarExport,
                      text: _model.baixandoExport
                          ? 'Baixando…'
                          : (_model.exportando
                              ? 'Gerando…'
                              : 'Gerar EXPORTACAO DADOS'),
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
                if (_model.exportJobStatus == 'running' &&
                    !_jobExportTravado()) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Acompanhando status automaticamente...',
                        style: theme.bodySmall,
                      ),
                    ],
                  ),
                ],
                if (_model.exportJobStatus == 'success' &&
                    (_model.exportStoragePath ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  FFButtonWidget(
                    onPressed: _model.baixandoExport
                        ? null
                        : () => _baixarZipExport(
                              storagePath: _model.exportStoragePath!,
                              nomeZip:
                                  _model.exportNomeZip ?? 'paint-export.zip',
                            ),
                    text: _model.baixandoExport
                        ? 'Baixando último ZIP...'
                        : 'Baixar último ZIP gerado',
                    icon: const Icon(Icons.download, size: 16),
                    options: FFButtonOptions(
                      height: 36,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                      color: theme.secondaryBackground,
                      textStyle: theme.bodyMedium.override(
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

  Future<void> _exportarExcel(String tipo, String modo) async {
    if (_idPropriedade.isEmpty) return;
    safeSetState(() {
      _model.exportandoExcel = true;
      _model.mensagemExcel = null;
      _model.tipoExcelAtivo = tipo;
    });
    try {
      final ok = await paint_actions.exportPaintAvaliacaoExcel(
        _idPropriedade,
        tipo,
        modo,
      );
      safeSetState(() {
        _model.exportandoExcel = false;
        _model.mensagemExcel = ok
            ? '✓ Planilha $tipo ($modo) baixada.'
            : '⚠ Nenhum animal elegível encontrado para gerar a planilha $tipo ou configuração PAINT incompleta.';
      });
    } catch (e) {
      safeSetState(() {
        _model.exportandoExcel = false;
        _model.mensagemExcel = '⚠ Erro: $e';
      });
    }
  }

  Future<void> _importarExcel(String tipo) async {
    if (_idPropriedade.isEmpty) return;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    if (f.bytes == null) return;
    safeSetState(() {
      _model.importandoExcel = true;
      _model.mensagemExcel = null;
      _model.tipoExcelAtivo = tipo;
    });
    try {
      final uploaded = FFUploadedFile(
        name: f.name,
        bytes: f.bytes,
      );
      final r = await paint_actions.importPaintAvaliacaoExcel(
        _idPropriedade,
        tipo,
        uploaded,
      );
      final erros = (r['erros'] as List?)?.cast<Map>() ?? const [];
      final detalhesErro = erros.take(5).map((e) {
        final linha = e['linha']?.toString() ?? '?';
        final motivo = e['motivo']?.toString() ?? 'Erro não informado.';
        return 'Linha $linha: $motivo';
      }).join('\n');
      final msg = '✓ Importação $tipo: ${r['inseridos']} novos, '
          '${r['atualizados']} atualizados.'
          '${erros.isEmpty ? '' : '\n⚠ ${erros.length} linha(s) com erro.\n$detalhesErro'}';
      safeSetState(() {
        _model.importandoExcel = false;
        _model.mensagemExcel = msg;
      });
      await _carregarStatus();
    } catch (e) {
      safeSetState(() {
        _model.importandoExcel = false;
        _model.mensagemExcel = '⚠ Erro na importação: $e';
      });
    }
  }

  Widget _cardPlanilhasExcel(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final busy = _model.exportandoExcel || _model.importandoExcel;
    return _card(
      context,
      titulo: 'Planilhas de avaliação',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Baixe o modelo vazio ou com dados da fazenda, preencha as notas '
            'técnicas no Excel e importe de volta antes de gerar o ZIP.',
            style: theme.bodySmall,
          ),
          const SizedBox(height: 12),
          ...['matrizes', 'desmama', 'sobreano'].map((tipo) {
            final label = tipo == 'matrizes'
                ? 'Matrizes (R/F/A/P)'
                : tipo == 'desmama'
                    ? 'Desmama'
                    : 'Sobreano';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FFButtonWidget(
                        onPressed:
                            busy ? null : () => _exportarExcel(tipo, 'vazio'),
                        text: 'Modelo vazio',
                        options: FFButtonOptions(
                          height: 36,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              12, 0, 12, 0),
                          color: theme.secondaryBackground,
                          textStyle: theme.bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: theme.primary,
                          ),
                          borderSide: BorderSide(color: theme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: busy
                            ? null
                            : () => _exportarExcel(tipo, 'preenchido'),
                        text: 'Com dados da fazenda',
                        options: FFButtonOptions(
                          height: 36,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              12, 0, 12, 0),
                          color: theme.secondaryBackground,
                          textStyle: theme.bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: theme.primary,
                          ),
                          borderSide: BorderSide(color: theme.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: busy ? null : () => _importarExcel(tipo),
                        text: _model.importandoExcel &&
                                _model.tipoExcelAtivo == tipo
                            ? 'Importando…'
                            : 'Importar .xlsx',
                        icon: const Icon(Icons.upload_file, size: 16),
                        options: FFButtonOptions(
                          height: 36,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              12, 0, 12, 0),
                          color: theme.primary,
                          textStyle: theme.bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FFButtonWidget(
                onPressed:
                    busy ? null : () => _exportarExcel('lista_touros', 'vazio'),
                text: 'Modelo LISTA TOUROS',
                options: FFButtonOptions(
                  height: 36,
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  color: theme.secondaryBackground,
                  textStyle: theme.bodySmall,
                  borderSide: BorderSide(color: theme.alternate),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FFButtonWidget(
                onPressed: busy
                    ? null
                    : () async {
                        safeSetState(() => _model.exportandoExcel = true);
                        try {
                          await paint_actions.exportPaintResultadosExcel(
                            _idPropriedade,
                          );
                          safeSetState(() {
                            _model.exportandoExcel = false;
                            _model.mensagemExcel =
                                '✓ Relatório 460_RESULTADOS baixado.';
                          });
                        } catch (e) {
                          safeSetState(() {
                            _model.exportandoExcel = false;
                            _model.mensagemExcel = '⚠ $e';
                          });
                        }
                      },
                text: 'Relatório 460 (resumo)',
                options: FFButtonOptions(
                  height: 36,
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                  color: theme.secondaryBackground,
                  textStyle: theme.bodySmall,
                  borderSide: BorderSide(color: theme.alternate),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          if (_model.mensagemExcel != null) ...[
            const SizedBox(height: 12),
            Text(_model.mensagemExcel!, style: theme.bodyMedium),
          ],
        ],
      ),
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
              _CadastroChip(
                label: 'Estoque sêmen',
                tabela: 'paint_estoque',
                routeName: 'pgPaintEstoque',
                count: _count('paint_estoque'),
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
              const Icon(Icons.info_outline, color: Colors.orange, size: 18),
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
                label: 'Matrizes (R/F/A/P)',
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
