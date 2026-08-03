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
import 'package:url_launcher/url_launcher.dart';
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
  Timer? _exportUiTimer;

  static const Duration _exportPollInterval = Duration(seconds: 8);
  static const Duration _exportStuckAfter = Duration(minutes: 12);

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
    _model.serieRacaPoFocus = FocusNode();
    _model.serieRacaPoController = TextEditingController();

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

  int _elapsedExportSeconds() {
    final started = _model.exportStartedAt;
    if (started == null) return 0;
    return DateTime.now()
        .toUtc()
        .difference(started.toUtc())
        .inSeconds
        .clamp(0, 35999);
  }

  String _formatDurationClock(int totalSeconds) {
    final seconds = totalSeconds.clamp(0, 35999);
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatElapsedExport() => _formatDurationClock(_elapsedExportSeconds());

  /// Heurística calibrada para propriedades grandes (~10k animais ≈ 5 min).
  int _estimarSegundosExportHeuristica() {
    final comp = _count('paint_composicao_racial');
    final desm = _count('paint_avaliacao_desmama');
    final diag = _count('paint_diagnostico');
    final sob = _count('paint_avaliacao_sobreano');
    final seconds =
        60 + comp ~/ 200 + desm ~/ 40 + diag ~/ 50 + sob ~/ 50;
    return seconds.clamp(120, 600);
  }

  int _exportEstimatedSecondsEffective() {
    final base =
        _model.exportEstimatedSeconds ?? _estimarSegundosExportHeuristica();
    final elapsed = _elapsedExportSeconds();
    if (elapsed > base) return (elapsed * 1.2).round().clamp(base, 900);
    return base;
  }

  String _formatEstimatedExport() =>
      '~${_formatDurationClock(_exportEstimatedSecondsEffective())}';

  String _formatProgressExportLabel() =>
      '${_formatElapsedExport()} / ${_formatEstimatedExport()}';

  double _progressExportFraction() {
    final est = _exportEstimatedSecondsEffective();
    if (est <= 0) return 0;
    return (_elapsedExportSeconds() / est).clamp(0.0, 0.98);
  }

  bool _exportPassouDoEstimado() {
    final base =
        _model.exportEstimatedSeconds ?? _estimarSegundosExportHeuristica();
    return _elapsedExportSeconds() > base;
  }

  Future<void> _carregarEstimativaExport(String propId) async {
    try {
      final rows = await SupaFlow.client
          .from('paint_export_job')
          .select('started_at,finished_at')
          .eq('id_propriedade', propId)
          .eq('status', 'success')
          .order('finished_at', ascending: false)
          .limit(3);
      for (final raw in rows) {
        final r = Map<String, dynamic>.from(raw as Map);
        final started = _parseDateTime(r['started_at']);
        final finished = _parseDateTime(r['finished_at']);
        if (started == null || finished == null) continue;
        final dur = finished.difference(started).inSeconds;
        if (dur >= 45 && dur <= 900) {
          _model.exportEstimatedSeconds = dur;
          return;
        }
      }
    } catch (_) {
      // Mantém heurística abaixo.
    }
    _model.exportEstimatedSeconds = _estimarSegundosExportHeuristica();
  }

  void _iniciarTimerExportUi() {
    _exportUiTimer?.cancel();
    _exportUiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _model.exportJobStatus != 'running' || _jobExportTravado()) {
        _pararTimerExportUi();
        return;
      }
      safeSetState(() {});
    });
  }

  void _pararTimerExportUi() {
    _exportUiTimer?.cancel();
    _exportUiTimer = null;
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
        _model.serieRacaPoController?.clear();
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
      _model.serieRacaPoController?.clear();

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
        _model.serieRacaPoController?.text =
            (r['serie_raca_po'] ?? '').toString();
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
    final serieRacaPo = _model.serieRacaPoController?.text.trim() ?? '';

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
        'serie_raca_po': serieRacaPo.isEmpty ? null : serieRacaPo,
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
    _model.exportEstimatedSeconds = null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool _jobExportTravado() {
    if (_model.exportJobStatus != 'running') return false;
    final started = _model.exportStartedAt;
    if (started == null) return false;
    return DateTime.now().toUtc().difference(started.toUtc()) > _exportStuckAfter;
  }

  Future<void> _marcarExportacaoTravadaComoErro() async {
    final jobId = _model.exportJobId;
    if (jobId == null || _model.exportJobStatus != 'running') return;
    try {
      await SupaFlow.client
          .from('paint_export_job')
          .update({
            'status': 'error',
            'erro':
                'Exportação cancelada: tempo máximo excedido sem conclusão no servidor.',
            'finished_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', jobId)
          .eq('status', 'running');
    } catch (_) {
      // Ignora — o backend pode já ter marcado como erro.
    }
  }

  Future<void> _cancelarExportacaoTravadaERecarregar() async {
    await _marcarExportacaoTravadaComoErro();
    _pararAcompanhamentoExport();
    await _carregarUltimoJobExport();
  }

  void _pararAcompanhamentoExport() {
    _exportStatusTimer?.cancel();
    _exportStatusTimer = null;
    _pararTimerExportUi();
  }

  void _iniciarAcompanhamentoExport(String propId) {
    _pararAcompanhamentoExport();
    _iniciarTimerExportUi();
    _exportStatusTimer =
        Timer.periodic(_exportPollInterval, (_) async {
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
      _model.exportJobId = job['id']?.toString();
      _model.exportJobStatus = status;
      _model.exportStartedAt = _parseDateTime(job['started_at']);
      if (status == 'running' && _jobExportTravado()) {
        await _marcarExportacaoTravadaComoErro();
        return _carregarUltimoJobExport(
          propId: idProp,
          baixarQuandoConcluir: baixarQuandoConcluir,
        );
      }
      if (status == 'running' && _model.exportEstimatedSeconds == null) {
        await _carregarEstimativaExport(idProp);
      }
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
              ? 'A exportação excedeu o tempo esperado no servidor. Use "Cancelar e tentar novamente" abaixo.'
              : 'Gerando ZIP no servidor (${_formatProgressExportLabel()}). '
                  'Pode levar alguns minutos em propriedades grandes.';
          if (!_jobExportTravado() && _exportUiTimer == null) {
            _iniciarTimerExportUi();
          }
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
      // O ZIP tem ~15MB. Gerar a URL assinada com retry (o gateway do storage
      // às vezes responde 504 transitório) e baixar direto pelo navegador,
      // sem puxar o arquivo inteiro pela memória do app.
      final baseUrl = signedUrl?.isNotEmpty == true
          ? signedUrl!
          : await _criarUrlAssinadaComRetry(storagePath);
      // Força Content-Disposition: attachment com o nome correto.
      final sep = baseUrl.contains('?') ? '&' : '?';
      final urlDownload = '$baseUrl${sep}download=${Uri.encodeComponent(nomeZip)}';

      final aberto = await _baixarPorNavegador(urlDownload);
      if (!aberto) {
        // Fallback: baixa os bytes e usa o helper de download do app.
        final zipResp = await http.get(Uri.parse(urlDownload));
        if (zipResp.statusCode != 200) {
          throw Exception('HTTP ${zipResp.statusCode}');
        }
        await download(Stream.fromIterable(zipResp.bodyBytes), nomeZip);
      }
      if (!mounted) return;
      safeSetState(() {
        _model.exportando = false;
        _model.baixandoExport = false;
        _model.linkUltimoZip = baseUrl;
        _model.mensagemExport = 'Exportação concluída e baixada: $nomeZip';
      });
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _model.exportando = false;
        _model.baixandoExport = false;
        _model.linkUltimoZip = signedUrl;
        _model.mensagemExport =
            'Exportação concluída. Se o download não iniciar, toque em '
            '"Baixar último ZIP gerado". (detalhe: $e)';
      });
    }
  }

  Future<String> _criarUrlAssinadaComRetry(String storagePath) async {
    Object? ultimoErro;
    for (var tentativa = 1; tentativa <= 3; tentativa++) {
      try {
        return await SupaFlow.client.storage
            .from('paint-exports')
            .createSignedUrl(storagePath, 3600);
      } catch (e) {
        ultimoErro = e;
        if (tentativa < 3) {
          await Future.delayed(Duration(milliseconds: 600 * tentativa));
        }
      }
    }
    throw Exception('Não foi possível gerar o link do ZIP: $ultimoErro');
  }

  Future<bool> _baixarPorNavegador(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) return false;
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<void> _gerarExport() async {
    if (_idPropriedade.isEmpty) return;
    final propId = _idPropriedade;
    _model.exportEstimatedSeconds = null;
    await _carregarEstimativaExport(propId);
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
      // A12 oficial do PAINT: total e quantos divergem do cálculo automático.
      var a12Total = 0;
      var a12Div = 0;
      try {
        final t = await SupaFlow.client
            .from('paint_animal_a12')
            .select('id')
            .eq('id_propriedade', propId)
            .count(CountOption.exact);
        a12Total = t.count;
        final d = await SupaFlow.client
            .from('paint_animal_a12')
            .select('id')
            .eq('id_propriedade', propId)
            .eq('divergente', true)
            .count(CountOption.exact);
        a12Div = d.count;
      } catch (_) {
        // tabela pode não existir em ambientes antigos — ignora
      }
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.counts = Map.fromEntries(entries);
        _model.a12OficialTotal = a12Total;
        _model.a12OficialDivergentes = a12Div;
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
      final r = await paint_actions.autoPreencherPaint(
        propId,
        dataNascimentoDe: _model.importNascDe,
        dataNascimentoAte: _model.importNascAte,
        dataAvaliacaoDe: _model.importAvDe,
        dataAvaliacaoAte: _model.importAvAte,
        status: _model.importStatus,
      );
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
      final prefixoFiltro = _descricaoFiltroImport();
      final msg = prefixoFiltro +
          (falhas.isEmpty
              ? (novos.isEmpty
                  ? '✓ Nenhum novo registro — tudo já estava preenchido.'
                  : '✓ Importado: ${novos.join(', ')}.')
              : (novos.isEmpty
                  ? '⚠ Importação concluída com alertas. Nenhum novo registro foi criado.\n'
                      '${falhas.length} etapa(s) precisam de atenção:\n• ${falhas.join('\n• ')}'
                  : '⚠ Importação parcialmente concluída. Importado: ${novos.join(', ')}.\n'
                      '${falhas.length} etapa(s) precisam de atenção:\n• ${falhas.join('\n• ')}'));
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

  /// Prefixo de mensagem indicando os filtros de data ativos na importação.
  String _descricaoFiltroImport() {
    String? intervalo(DateTime? de, DateTime? ate) {
      if (de == null && ate == null) return null;
      final ini = de != null ? dateTimeFormat('dd/MM/yyyy', de) : '…';
      final fim = ate != null ? dateTimeFormat('dd/MM/yyyy', ate) : '…';
      return '$ini a $fim';
    }

    final nasc = intervalo(_model.importNascDe, _model.importNascAte);
    final aval = intervalo(_model.importAvDe, _model.importAvAte);
    final st = _model.importStatus;
    if (nasc == null && aval == null && (st == null || st.isEmpty)) return '';
    final partes = [
      if (nasc != null) 'nasc.: $nasc',
      if (aval != null) 'aval.: $aval',
      if (st != null && st.isNotEmpty) 'status: $st',
    ];
    return 'Filtros aplicados (${partes.join(' / ')}).\n';
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
                                _cardA12Oficial(context),
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
                    _campoTexto(
                      label: 'Série registro PO (ex.: JLK)',
                      controller: _model.serieRacaPoController,
                      focus: _model.serieRacaPoFocus,
                      width: 320,
                      maxLength: 4,
                      helperText:
                          'Opcional se o brinco/registro já traz a sigla (ex.: JLK4705). '
                          'Usado como fallback quando o animal PO não tem sigla no cadastro.',
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
    String? helperText,
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
          helperText: helperText,
          helperMaxLines: 3,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (_) => safeSetState(() {}),
      ),
    );
  }

  Widget _campoData({
    required String label,
    required DateTime? valor,
    required ValueChanged<DateTime?> onChanged,
    double width = 180,
  }) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: valor ?? DateTime.now(),
            firstDate: DateTime(1990),
            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            suffixIcon: valor != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    splashRadius: 16,
                    onPressed: () => onChanged(null),
                  )
                : const Icon(Icons.calendar_today, size: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            valor != null
                ? dateTimeFormat('dd/MM/yyyy', valor)
                : 'dd/mm/aaaa',
            style: valor != null
                ? theme.bodyMedium
                : theme.bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: theme.secondaryText,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
          ),
        ),
      ),
    );
  }

  int _contaFiltros(
    DateTime? a,
    DateTime? b,
    DateTime? c,
    DateTime? d, [
    String? status,
  ]) {
    var n = 0;
    if (a != null) n++;
    if (b != null) n++;
    if (c != null) n++;
    if (d != null) n++;
    if (status != null && status.isNotEmpty) n++;
    return n;
  }

  /// Botão que abre o modal de filtros, destacado quando há filtros ativos.
  Widget _botaoFiltro({
    required int ativos,
    required VoidCallback? onPressed,
    String textoBase = 'Filtros',
  }) {
    final theme = FlutterFlowTheme.of(context);
    final ativo = ativos > 0;
    return FFButtonWidget(
      onPressed: onPressed,
      text: ativo ? '$textoBase ($ativos)' : textoBase,
      icon: Icon(
        ativo ? Icons.filter_alt : Icons.filter_alt_outlined,
        size: 16,
        color: ativo ? Colors.white : theme.primary,
      ),
      options: FFButtonOptions(
        height: 36,
        padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
        color: ativo ? theme.primary : theme.secondaryBackground,
        textStyle: theme.bodySmall.override(
          fontFamily: 'Readex Pro',
          color: ativo ? Colors.white : theme.primary,
          useGoogleFonts: GoogleFonts.asMap().containsKey('Readex Pro'),
        ),
        elevation: 0,
        borderSide: BorderSide(color: theme.primary),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Abre um modal com filtros opcionais (status, datas de nascimento e
  /// avaliação). Mantém estado temporário e só aplica ao confirmar.
  Future<void> _abrirFiltros({
    required String titulo,
    required String? status,
    required DateTime? nascDe,
    required DateTime? nascAte,
    required DateTime? avDe,
    required DateTime? avAte,
    required void Function(
      String? status,
      DateTime? nascDe,
      DateTime? nascAte,
      DateTime? avDe,
      DateTime? avAte,
    ) onAplicar,
    bool incluiAvaliacao = true,
  }) async {
    final theme = FlutterFlowTheme.of(context);
    String? tStatus = status;
    DateTime? tNascDe = nascDe;
    DateTime? tNascAte = nascAte;
    DateTime? tAvDe = avDe;
    DateTime? tAvAte = avAte;
    final opcoesStatus = FFAppState().statusRebanho;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocal) {
            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 460,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_alt, color: theme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(titulo, style: theme.titleMedium),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          splashRadius: 18,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Em branco considera todos os registros.',
                      style: theme.bodySmall.override(
                        fontFamily: 'Readex Pro',
                        color: theme.secondaryText,
                        useGoogleFonts:
                            GoogleFonts.asMap().containsKey('Readex Pro'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Status',
                      style: theme.bodySmall.override(
                        fontFamily: 'Readex Pro',
                        fontWeight: FontWeight.w600,
                        useGoogleFonts:
                            GoogleFonts.asMap().containsKey('Readex Pro'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      value: tStatus,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: theme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.alternate),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      hint: const Text('Todos os status'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos os status'),
                        ),
                        ...opcoesStatus.map(
                          (s) => DropdownMenuItem<String?>(
                            value: s,
                            child: Text(s),
                          ),
                        ),
                      ],
                      onChanged: (v) => setLocal(() => tStatus = v),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _campoData(
                          label: 'Nascimento de',
                          valor: tNascDe,
                          onChanged: (d) => setLocal(() => tNascDe = d),
                        ),
                        _campoData(
                          label: 'Nascimento até',
                          valor: tNascAte,
                          onChanged: (d) => setLocal(() => tNascAte = d),
                        ),
                        if (incluiAvaliacao) ...[
                          _campoData(
                            label: 'Avaliação de',
                            valor: tAvDe,
                            onChanged: (d) => setLocal(() => tAvDe = d),
                          ),
                          _campoData(
                            label: 'Avaliação até',
                            valor: tAvAte,
                            onChanged: (d) => setLocal(() => tAvAte = d),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => setLocal(() {
                            tStatus = null;
                            tNascDe = null;
                            tNascAte = null;
                            tAvDe = null;
                            tAvAte = null;
                          }),
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Limpar'),
                          style: TextButton.styleFrom(
                              foregroundColor: theme.primary),
                        ),
                        FFButtonWidget(
                          onPressed: () {
                            onAplicar(
                                tStatus, tNascDe, tNascAte, tAvDe, tAvAte);
                            Navigator.of(dialogContext).pop();
                          },
                          text: 'Aplicar',
                          options: FFButtonOptions(
                            width: 120,
                            height: 40,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                20, 0, 20, 0),
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
                  ],
                ),
              ),
            );
          },
        );
      },
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
                Text(
                  'Importar do sistema',
                  style: theme.labelMedium.override(
                    fontFamily: 'Readex Pro',
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deriva cadastros e avaliações a partir do rebanho, reprodução '
                  'e pesagens. Os filtros por data limitam só as avaliações '
                  '(desmama, sobreano, RAH etc.); cadastros de apoio entram '
                  'sempre.',
                  style: theme.bodySmall.override(
                    fontFamily: 'Readex Pro',
                    color: theme.secondaryText,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _botaoFiltro(
                      textoBase: 'Filtros importação',
                      ativos: _contaFiltros(
                        _model.importNascDe,
                        _model.importNascAte,
                        _model.importAvDe,
                        _model.importAvAte,
                        _model.importStatus,
                      ),
                      onPressed: !cfgOk
                          ? null
                          : () => _abrirFiltros(
                                titulo: 'Filtros — Importar tudo do sistema',
                                status: _model.importStatus,
                                nascDe: _model.importNascDe,
                                nascAte: _model.importNascAte,
                                avDe: _model.importAvDe,
                                avAte: _model.importAvAte,
                                onAplicar: (st, nd, na, ad, aa) =>
                                    safeSetState(() {
                                  _model.importStatus = st;
                                  _model.importNascDe = nd;
                                  _model.importNascAte = na;
                                  _model.importAvDe = ad;
                                  _model.importAvAte = aa;
                                }),
                              ),
                    ),
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
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Exportar para PAINT',
                  style: theme.labelMedium.override(
                    fontFamily: 'Readex Pro',
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gera o ZIP com todos os dados já cadastrados nesta propriedade '
                  '(sem filtros de data).',
                  style: theme.bodySmall.override(
                    fontFamily: 'Readex Pro',
                    color: theme.secondaryText,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
                ),
                const SizedBox(height: 10),
                FFButtonWidget(
                  onPressed: (_model.exportando ||
                          _model.baixandoExport ||
                          !cfgOk)
                      ? null
                      : _gerarExport,
                  text: _model.baixandoExport
                      ? 'Baixando…'
                      : (_model.exportando
                          ? 'Gerando… ${_formatProgressExportLabel()}'
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
                    _jobExportTravado()) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.error.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.error.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exportação sem resposta do servidor',
                          style: theme.bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontWeight: FontWeight.w600,
                            color: theme.error,
                            useGoogleFonts:
                                GoogleFonts.asMap().containsKey('Readex Pro'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Decorridos ${_formatElapsedExport()} sem conclusão. '
                          'O worker do servidor pode ter sido interrompido — '
                          'isso não gera o ZIP automaticamente.',
                          style: theme.bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: theme.secondaryText,
                            useGoogleFonts:
                                GoogleFonts.asMap().containsKey('Readex Pro'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FFButtonWidget(
                          onPressed: _cancelarExportacaoTravadaERecarregar,
                          text: 'Cancelar e tentar novamente',
                          icon: const Icon(Icons.refresh, size: 16),
                          options: FFButtonOptions(
                            height: 36,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                14, 0, 14, 0),
                            color: theme.error,
                            textStyle: theme.bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              useGoogleFonts: GoogleFonts.asMap()
                                  .containsKey('Readex Pro'),
                            ),
                            elevation: 0,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_model.exportJobStatus == 'running' &&
                    !_jobExportTravado()) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: theme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Exportação em andamento',
                                    style: theme.bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontWeight: FontWeight.w600,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey('Readex Pro'),
                                    ),
                                  ),
                                  Text(
                                    'Tempo: ${_formatProgressExportLabel()}'
                                    '${_exportPassouDoEstimado() ? ' (estimativa em revisão)' : ''}',
                                    style: theme.bodySmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: theme.secondaryText,
                                      useGoogleFonts: GoogleFonts.asMap()
                                          .containsKey('Readex Pro'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: _progressExportFraction(),
                            backgroundColor:
                                theme.primary.withValues(alpha: 0.12),
                            color: theme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'A geração continua no servidor mesmo se você sair desta '
                          'tela. Ao voltar ao módulo PAINT, o status é atualizado '
                          'e o ZIP baixa automaticamente quando concluir.',
                          style: theme.bodySmall.override(
                            fontFamily: 'Readex Pro',
                            color: theme.secondaryText,
                            useGoogleFonts:
                                GoogleFonts.asMap().containsKey('Readex Pro'),
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 20),
                Divider(color: theme.alternate),
                const SizedBox(height: 4),
                Text(
                  'Zona de risco',
                  style: theme.bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: theme.error,
                    fontWeight: FontWeight.w600,
                    useGoogleFonts:
                        GoogleFonts.asMap().containsKey('Readex Pro'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Apaga todos os dados PAINT desta propriedade (avaliações, '
                  'diagnósticos, cadastros derivados e histórico de '
                  'exportações) para recomeçar do zero. A configuração '
                  '(códigos PAINT) e a Biblioteca de Touros não são afetadas.',
                  style: theme.bodySmall,
                ),
                const SizedBox(height: 8),
                FFButtonWidget(
                  onPressed: (_model.resetandoPaint || _idPropriedade.isEmpty)
                      ? null
                      : _confirmarResetPaint,
                  text: _model.resetandoPaint
                      ? 'Resetando dados PAINT...'
                      : 'Resetar dados PAINT',
                  icon: const Icon(Icons.delete_forever, size: 16),
                  options: FFButtonOptions(
                    height: 36,
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                    color: theme.secondaryBackground,
                    textStyle: theme.bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: theme.error,
                      useGoogleFonts:
                          GoogleFonts.asMap().containsKey('Readex Pro'),
                    ),
                    elevation: 0,
                    borderSide: BorderSide(color: theme.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                if (_model.mensagemReset != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _model.mensagemReset!,
                    style: theme.bodySmall,
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _confirmarResetPaint() async {
    if (_idPropriedade.isEmpty) return;
    final nomeFazenda = FFAppState().propriedadeSelecionada.nome;
    final confirmController = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = FlutterFlowTheme.of(dialogContext);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final habilitado =
                confirmController.text.trim().toUpperCase() == 'RESETAR';
            return AlertDialog(
              title: Text(
                nomeFazenda.isEmpty
                    ? 'Resetar dados PAINT'
                    : 'Resetar dados PAINT — $nomeFazenda',
              ),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Isso apaga TODOS os dados PAINT desta propriedade:\n'
                      '• avaliações (desmama, sobreano, matrizes) e diagnósticos;\n'
                      '• cadastros derivados (grupos de manejo, inseminadores, '
                      'safras, matrizes por safra, localidades, regimes, '
                      'avaliadores, baixas, estoque, touro múltiplo, '
                      'composição racial);\n'
                      '• histórico de exportações.\n\n'
                      'NÃO apaga a configuração PAINT (códigos) nem a '
                      'Biblioteca de Touros. O rebanho, lotes e reproduções do '
                      'inLida não são tocados.\n\n'
                      'Esta ação não pode ser desfeita. Digite RESETAR para '
                      'confirmar:',
                      style: theme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      autofocus: true,
                      onChanged: (_) => setStateDialog(() {}),
                      decoration: const InputDecoration(
                        hintText: 'RESETAR',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: habilitado
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  child: Text(
                    'Apagar tudo',
                    style: TextStyle(
                      color: habilitado ? theme.error : theme.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    // Defesa em profundidade: além do gate do botão, revalida o texto digitado
    // após o diálogo fechar (protege contra confirmação acidental/sintética).
    final textoDigitado = confirmController.text.trim().toUpperCase();
    confirmController.dispose();
    if (confirmado != true || textoDigitado != 'RESETAR') return;
    await _resetarDadosPaint();
  }

  Future<void> _resetarDadosPaint() async {
    final propId = _idPropriedade;
    safeSetState(() {
      _model.resetandoPaint = true;
      _model.mensagemReset = null;
    });
    try {
      final r = await paint_actions.resetarDadosPaint(propId);
      if (!_aindaMesmaPropriedade(propId)) return;
      final total = (r['total'] as int?) ?? 0;
      safeSetState(() {
        _model.resetandoPaint = false;
        if ((r['erro'] as int?) == 1) {
          _model.mensagemReset =
              '⚠ ${r['mensagem']} ($total registros removidos até a falha — '
              'clique novamente para concluir.)';
        } else {
          _model.mensagemReset =
              '✓ Dados PAINT resetados: $total registros removidos.';
        }
        // Estado de exportação da sessão fica obsoleto após o reset.
        _model.exportJobStatus = null;
        _model.exportStoragePath = null;
        _model.exportNomeZip = null;
        _model.linkUltimoZip = null;
        _model.mensagemExport = null;
      });
      await _carregarStatus();
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.resetandoPaint = false;
        _model.mensagemReset = '⚠ Erro ao resetar: $e';
      });
    }
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
    final preenchido = modo == 'preenchido';
    try {
      final status = await paint_actions.exportPaintAvaliacaoExcel(
        _idPropriedade,
        tipo,
        modo,
        dataNascimentoDe: _model.excelNascDe[tipo],
        dataNascimentoAte: _model.excelNascAte[tipo],
        dataAvaliacaoDe: preenchido ? _model.excelAvDe[tipo] : null,
        dataAvaliacaoAte: preenchido ? _model.excelAvAte[tipo] : null,
        status: _model.excelStatus[tipo],
      );
      safeSetState(() {
        _model.exportandoExcel = false;
        _model.mensagemExcel = _mensagemExportExcel(status, tipo, modo);
      });
    } catch (e) {
      safeSetState(() {
        _model.exportandoExcel = false;
        _model.mensagemExcel = '⚠ Erro: $e';
      });
    }
  }

  String _mensagemExportExcel(
    paint_actions.PaintExportStatus status,
    String tipo,
    String modo,
  ) {
    switch (status) {
      case paint_actions.PaintExportStatus.ok:
        return '✓ Planilha $tipo ($modo) baixada.';
      case paint_actions.PaintExportStatus.configIncompleta:
        return '⚠ Configuração PAINT incompleta para gerar a planilha $tipo.';
      case paint_actions.PaintExportStatus.semElegiveis:
        return '⚠ Nenhum animal elegível (status/categoria) para a planilha $tipo.';
      case paint_actions.PaintExportStatus.semNascimento:
        return '⚠ Nenhum animal no intervalo de data de nascimento para a planilha $tipo.';
      case paint_actions.PaintExportStatus.semAvaliacao:
        return '⚠ Nenhum animal no intervalo de data de avaliação para a planilha $tipo.';
      case paint_actions.PaintExportStatus.vazio:
        return '⚠ Nenhum animal a exportar para a planilha $tipo.';
    }
  }

  /// Importa o ANIMAL.TXT que a fazenda já envia manualmente ao PAINT e grava
  /// o A12 oficial de cada animal (paint_animal_a12). O export passa a usar
  /// esses A12 — é assim que reproduzimos o histórico do PAINT (ex.: programa
  /// 'F' ou 'p' minúsculo que não pode mais ser corrigido lá).
  Future<void> _importarA12Oficial() async {
    if (_idPropriedade.isEmpty) return;
    final propId = _idPropriedade;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final f = picked.files.first;
    if (f.bytes == null) return;
    safeSetState(() {
      _model.importandoA12Oficial = true;
      _model.mensagemA12Oficial = null;
    });
    try {
      final r = await paint_actions.importPaintAnimalTxt(
        propId,
        FFUploadedFile(name: f.name, bytes: f.bytes),
        false,
      );
      if (!_aindaMesmaPropriedade(propId)) return;
      final erros = (r['erros'] as List?)?.cast<Map>() ?? const [];
      final naoEnc = (r['nao_encontrados'] as List?) ?? const [];
      final ambiguos = (r['ambiguos'] as List?) ?? const [];
      final partes = <String>[
        '✓ A12 oficial: ${r['casados']} animais casados '
            '(${r['inseridos']} novos, ${r['atualizados']} atualizados) de '
            '${r['total_linhas']} linhas.',
        '• ${r['divergentes']} divergem do cálculo automático (é o que o PAINT '
            'já tem e passaremos a enviar).',
      ];
      if (((r['manual_preservados'] as int?) ?? 0) > 0) {
        partes.add(
            '• ${r['manual_preservados']} edições manuais preservadas.');
      }
      if (naoEnc.isNotEmpty) {
        final ex = naoEnc.take(5).map((e) {
          final m = e as Map;
          return 'linha ${m['linha']}: A12 ${m['a12']} (nº ${m['numero']})';
        }).join('\n');
        partes.add('⚠ ${naoEnc.length} sem animal correspondente no inLida:\n$ex');
      }
      if (ambiguos.isNotEmpty) {
        partes.add('⚠ ${ambiguos.length} ambíguos (mais de um animal casa) — '
            'corrija o número/registro desses animais.');
      }
      if (erros.isNotEmpty) {
        final ex = erros.take(3).map((e) => '${e['motivo']}').join('\n');
        partes.add('⚠ ${erros.length} aviso(s):\n$ex');
      }
      safeSetState(() {
        _model.importandoA12Oficial = false;
        _model.mensagemA12Oficial = partes.join('\n');
      });
      await _carregarStatus();
    } catch (e) {
      if (!_aindaMesmaPropriedade(propId)) return;
      safeSetState(() {
        _model.importandoA12Oficial = false;
        _model.mensagemA12Oficial = '⚠ Erro ao importar: $e';
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
      final pesagensNovas = (r['pesagens_inseridas'] as int?) ?? 0;
      final pesagensAtualizadas = (r['pesagens_atualizadas'] as int?) ?? 0;
      final resumoPesagens = pesagensNovas + pesagensAtualizadas > 0
          ? '\n✓ Pesagens no rebanho: $pesagensNovas novas, '
              '$pesagensAtualizadas atualizadas.'
          : '';
      final msg = '✓ Importação $tipo: ${r['inseridos']} novos, '
          '${r['atualizados']} atualizados.$resumoPesagens'
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

  /// Card "A12 oficial do PAINT": importa o ANIMAL.TXT que a fazenda já envia
  /// manualmente e mostra a cobertura. Sem linhas aqui, o A12 segue calculado.
  Widget _cardA12Oficial(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final total = _model.a12OficialTotal;
    final div = _model.a12OficialDivergentes;
    return _card(
      context,
      titulo: 'A12 oficial do PAINT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fazendas que já enviavam ao PAINT manualmente têm o A12 (código do '
            'animal) gravado lá do jeito antigo — às vezes com programa "F" ou '
            '"p" minúsculo, que não dá mais para corrigir no PAINT. Importe o '
            'ANIMAL.TXT do PAINT para que a exportação use exatamente esses '
            'códigos; sem isso, o PAINT não reconhece o vínculo dos animais.',
            style: theme.bodySmall,
          ),
          const SizedBox(height: 10),
          Text(
            total == 0
                ? 'Nenhum A12 oficial cadastrado — a exportação calcula o A12 '
                    '(comportamento padrão, correto para fazendas novas no PAINT).'
                : 'A12 oficial cadastrado para $total animal(is); '
                    '$div divergem do cálculo automático.',
            style: theme.bodyMedium.override(
              fontFamily: 'Readex Pro',
              fontWeight: FontWeight.w600,
              useGoogleFonts: GoogleFonts.asMap().containsKey('Readex Pro'),
            ),
          ),
          const SizedBox(height: 10),
          FFButtonWidget(
            onPressed: (_model.importandoA12Oficial || _idPropriedade.isEmpty)
                ? null
                : _importarA12Oficial,
            text: _model.importandoA12Oficial
                ? 'Importando ANIMAL.TXT...'
                : 'Importar ANIMAL.TXT do PAINT',
            icon: const Icon(Icons.upload_file, size: 16),
            options: FFButtonOptions(
              height: 40,
              padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
              color: theme.secondaryBackground,
              textStyle: theme.bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: theme.primary,
                useGoogleFonts: GoogleFonts.asMap().containsKey('Readex Pro'),
              ),
              elevation: 0,
              borderSide: BorderSide(color: theme.primary),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (_model.mensagemA12Oficial != null) ...[
            const SizedBox(height: 8),
            SelectionArea(
              child: Text(
                _model.mensagemA12Oficial!,
                style: theme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
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
                      _botaoFiltro(
                        ativos: _contaFiltros(
                          _model.excelNascDe[tipo],
                          _model.excelNascAte[tipo],
                          _model.excelAvDe[tipo],
                          _model.excelAvAte[tipo],
                          _model.excelStatus[tipo],
                        ),
                        onPressed: busy
                            ? null
                            : () => _abrirFiltros(
                                  titulo: 'Filtros — $label',
                                  status: _model.excelStatus[tipo],
                                  nascDe: _model.excelNascDe[tipo],
                                  nascAte: _model.excelNascAte[tipo],
                                  avDe: _model.excelAvDe[tipo],
                                  avAte: _model.excelAvAte[tipo],
                                  onAplicar: (st, nd, na, ad, aa) =>
                                      safeSetState(() {
                                    _model.excelStatus[tipo] = st;
                                    _model.excelNascDe[tipo] = nd;
                                    _model.excelNascAte[tipo] = na;
                                    _model.excelAvDe[tipo] = ad;
                                    _model.excelAvAte[tipo] = aa;
                                  }),
                                ),
                      ),
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
