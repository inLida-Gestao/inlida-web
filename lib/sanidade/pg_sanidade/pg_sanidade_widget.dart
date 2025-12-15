import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_rebanho_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import '/sanidade/pp_filtro_sanidade/pp_filtro_sanidade_widget.dart';
import '/sanidade/modal_add_sanidade/modal_add_sanidade_widget.dart';
import '/sanidade/cc_edit_sanidade_animal/cc_edit_sanidade_animal_widget.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/custom_functions.dart' as functions;
import 'dart:async';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_sanidade_model.dart';
export 'pg_sanidade_model.dart';

class PgSanidadeWidget extends StatefulWidget {
  const PgSanidadeWidget({super.key});

  static String routeName = 'pgSanidade';
  static String routePath = '/sanidade';

  @override
  State<PgSanidadeWidget> createState() => _PgSanidadeWidgetState();
}

class _PgSanidadeWidgetState extends State<PgSanidadeWidget>
    with TickerProviderStateMixin {
  late PgSanidadeModel _model;

  bool _sanidadeRefreshScheduled = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgSanidadeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await action_blocks.countReproducoes(context);

      // Contar vacinas aplicadas
      final vacinasCount = await SanidadeTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('id_propriedade',
                FFAppState().propriedadeSelecionada.idPropriedade)
            .eq('deletado', 'NAO')
            .not('vacinacao', 'is', null),
      );
      _model.countVacinas = vacinasCount.length;

      // Contar antiparasitários aplicados
      final antiparasitariosCount = await SanidadeTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('id_propriedade',
                FFAppState().propriedadeSelecionada.idPropriedade)
            .eq('deletado', 'NAO')
            .not('antiparasitario', 'is', null),
      );
      _model.countAntiparasitarios = antiparasitariosCount.length;

      // Contar tratamentos aplicados
      final tratamentosCount = await SanidadeTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('id_propriedade',
                FFAppState().propriedadeSelecionada.idPropriedade)
            .eq('deletado', 'NAO')
            .not('tratamento', 'is', null),
      );
      _model.countTratamentos = tratamentosCount.length;

      // Contar protocolos reprodutivos
      final protocolosCount = await SanidadeTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('id_propriedade',
                FFAppState().propriedadeSelecionada.idPropriedade)
            .eq('deletado', 'NAO')
            .not('protocolo_reprodutivo', 'is', null),
      );
      _model.countProtocolos = protocolosCount.length;

      safeSetState(() {});

      _model.instantTimer = InstantTimer.periodic(
        duration: const Duration(milliseconds: 250),
        callback: (timer) async {
          if (FFAppState().refreshSanidade == true ||
              FFAppState().refreshReproducao == true) {
            safeSetState(() => _model.apiRequestCompleter2 = null);
            safeSetState(() => _model.apiRequestCompleter1 = null);
            FFAppState().refreshSanidade = false;
            FFAppState().refreshReproducao = false;
            safeSetState(() {});
          }
        },
        startImmediately: true,
      );
    });

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _model.tabBarController = TabController(
      vsync: this,
      length: 5,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _openEditSanidadeDialog(SanidadeStruct sanidade) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: CcEditSanidadeAnimalWidget(
            sanidade: sanidade,
            action: (page) async {
              safeSetState(() {
                _model.apiRequestCompleter2 = null;
                _model.apiRequestCompleter1 = null;
              });
            },
          ),
        );
      },
    );
  }

  bool _hasValue(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return false;
    if (v.toLowerCase() == 'null') return false;
    return true;
  }

  List<String> _parseCsvFilter(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return <String>[];
    return v
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList();
  }

  Set<String> _toNormSet(Iterable<String> values) => values
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty && e != 'null' && e != '[]')
      .toSet();

  Set<String> _extractJsonListValues(String? raw) {
    final parsed = functions.converterJSONparaLista(raw);
    if (parsed != null) {
      return _toNormSet(parsed.cast<String>());
    }
    if (_hasValue(raw) && raw!.trim() != '[]') {
      return _toNormSet([raw]);
    }
    return <String>{};
  }

  bool _matchesMulti(String selectedCsv, Set<String> candidateValues) {
    final selected = _toNormSet(_parseCsvFilter(selectedCsv));
    if (selected.isEmpty) return true;
    return candidateValues.intersection(selected).isNotEmpty;
  }

  bool _passesMultiSelectFilters(SanidadeStruct s) {
    final vacValues = <String>{}
      ..addAll(_extractJsonListValues(s.vacinacao))
      ..addAll(_extractJsonListValues(s.vacinacaoOutros));
    if (!_matchesMulti(FFAppState().filtroVacinacao, vacValues)) return false;

    final tratValues = <String>{}
      ..addAll(_extractJsonListValues(s.tratamento))
      ..addAll(_extractJsonListValues(s.tratamentoOutros));
    if (!_matchesMulti(FFAppState().filtroTratamentoSanidade, tratValues))
      return false;

    final antiValues = <String>{}
      ..addAll(_extractJsonListValues(s.antiparasitario))
      ..addAll(_extractJsonListValues(s.antiparasitarioOutros));
    if (!_matchesMulti(FFAppState().filtroAntiparasitario, antiValues))
      return false;

    final protoValues = <String>{}
      ..addAll(_extractJsonListValues(s.protocoloReprodutivo))
      ..addAll(_extractJsonListValues(s.protocoloReprodutivoOutros));
    if (!_matchesMulti(FFAppState().filtroProtocolo, protoValues)) return false;

    return true;
  }

  String _displayOrNA(String? value) {
    return _hasValue(value) ? value!.trim() : 'N/A';
  }

  Future<void> _openViewSanidadeDialog(SanidadeStruct sanidade) async {
    final rawDate = _hasValue(sanidade.dataSanidade)
        ? sanidade.dataSanidade
        : sanidade.createdAt;
    final parsedDate = functions.converterParaData(rawDate);
    final dateText = parsedDate != null
        ? dateTimeFormat(
            'dd/MM/yyyy',
            parsedDate,
            locale: 'pt_BR',
          )
        : _displayOrNA(rawDate);

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x99000000),
      builder: (context) {
        final theme = FlutterFlowTheme.of(context);

        Widget section(
            {required String title, required List<Widget> children}) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.bodyMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                  color: theme.secondaryText,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          );
        }

        Widget kv(String k, String v) {
          return Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    k,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontStyle: theme.bodyMedium.fontStyle,
                      ),
                      color: theme.primaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    v,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontStyle: theme.bodyMedium.fontStyle,
                      ),
                      color: theme.primaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        Widget sanidadeTipo(
            String label, String? value, String? outros, String? obs) {
          if (!_hasValue(value) && !_hasValue(outros) && !_hasValue(obs)) {
            return const SizedBox.shrink();
          }

          final main = _displayOrNA(value);
          final out = _hasValue(outros) ? outros!.trim() : null;
          final ob = _hasValue(obs) ? obs!.trim() : null;
          final details = [
            if (main != 'N/A') main,
            if (out != null) 'Outros: $out',
            if (ob != null) 'Obs: $ob',
          ].join(' • ');

          return kv(label, details.isEmpty ? 'N/A' : details);
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 640.0,
            constraints: const BoxConstraints(maxHeight: 760.0),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalhes da sanidade',
                        style: theme.bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: theme.bodyMedium.fontStyle,
                          ),
                          color: theme.primaryText,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close,
                            color: theme.primaryText,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          section(
                            title: 'Informações',
                            children: [
                              kv(
                                'Animal',
                                '${_displayOrNA(sanidade.numeroAnimal)} - ${_displayOrNA(sanidade.nome)}',
                              ),
                              kv('Lote', _displayOrNA(sanidade.loteNome)),
                              kv('Data', dateText),
                              kv('Chip', _displayOrNA(sanidade.chip)),
                              kv('Categoria', _displayOrNA(sanidade.categoria)),
                              kv('Raça', _displayOrNA(sanidade.raca)),
                              kv('Sexo', _displayOrNA(sanidade.sexo)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          section(
                            title: 'Tipos',
                            children: [
                              sanidadeTipo(
                                'Vacinação',
                                sanidade.vacinacao,
                                sanidade.vacinacaoOutros,
                                sanidade.vacinacaoObs,
                              ),
                              sanidadeTipo(
                                'Antiparasitário',
                                sanidade.antiparasitario,
                                sanidade.antiparasitarioOutros,
                                sanidade.antiparasitarioObs,
                              ),
                              sanidadeTipo(
                                'Tratamento',
                                sanidade.tratamento,
                                sanidade.tratamentoOutros,
                                sanidade.tratamentoObs,
                              ),
                              sanidadeTipo(
                                'Protocolo reprodutivo',
                                sanidade.protocoloReprodutivo,
                                sanidade.protocoloReprodutivoOutros,
                                sanidade.protocoloReprodutivoObs,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndDeleteSanidade(SanidadeStruct sanidade) async {
    final theme = FlutterFlowTheme.of(context);

    final rawDate = _hasValue(sanidade.dataSanidade)
        ? sanidade.dataSanidade
        : sanidade.createdAt;
    final parsedDate = functions.converterParaData(rawDate);
    final dateText = parsedDate != null
        ? dateTimeFormat(
            'dd/MM/yyyy',
            parsedDate,
            locale: 'pt_BR',
          )
        : 'N/A';
    final animalName = _hasValue(sanidade.nome) ? sanidade.nome.trim() : 'N/A';
    final confirmText =
        'Tem certeza que deseja excluir a sanidade de $animalName aplicada em $dateText? Essa ação é irreversível.';

    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x99000000),
      builder: (context) {
        final t = FlutterFlowTheme.of(context);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 534.0,
            decoration: BoxDecoration(
              color: t.secondaryBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: t.customColor5,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4.0,
                  color: t.secondaryText.withOpacity(0.25),
                  offset: const Offset(2.0, 2.0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart
                        .resolve(Directionality.of(context)),
                    child: SizedBox(
                      width: 438.0,
                      child: Text(
                        'Excluir sanidade',
                        style: t.bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle: t.bodyMedium.fontStyle,
                          ),
                          color: t.secondaryText,
                          fontSize: 24.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: t.bodyMedium.fontStyle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: AlignmentDirectional.centerStart
                        .resolve(Directionality.of(context)),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48.0,
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: t.error,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.white,
                              size: 28.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            confirmText,
                            style: t.bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontStyle: t.bodyMedium.fontStyle,
                              ),
                              color: t.primaryText,
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: t.bodyMedium.fontStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FFButtonWidget(
                        onPressed: () => Navigator.pop(context, false),
                        text: 'Cancelar',
                        options: FFButtonOptions(
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24, 12, 24, 12),
                          color: t.secondaryBackground,
                          textStyle: t.titleSmall.override(
                            fontFamily: 'Poppins',
                            color: t.error,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: t.error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FFButtonWidget(
                        onPressed: () => Navigator.pop(context, true),
                        text: 'Excluir',
                        options: FFButtonOptions(
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              24, 12, 24, 12),
                          color: t.error,
                          textStyle: t.titleSmall.override(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldDelete != true) return;

    final sanidadeId = sanidade.id;
    final idSanidade = sanidade.idSanidade.trim();
    if (sanidadeId == 0 && idSanidade.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não foi possível identificar o registro'),
          backgroundColor: theme.warning,
        ),
      );
      return;
    }

    try {
      await SanidadeTable().update(
        data: {
          'deletado': 'SIM',
          'updated_at': supaSerialize<DateTime>(DateTime.now()),
        },
        matchingRows: (rows) {
          if (sanidadeId != 0) {
            return rows.eq('id', sanidadeId);
          }
          return rows.eq('id_sanidade', idSanidade);
        },
      );

      safeSetState(() {
        _model.apiRequestCompleter2 = null;
        _model.apiRequestCompleter1 = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sanidade excluída com sucesso!'),
          backgroundColor: theme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir sanidade: $e'),
          backgroundColor: theme.error,
        ),
      );
    }
  }

  Future<void> _openSanidadeRowMenu({
    required BuildContext anchorContext,
    required SanidadeStruct sanidade,
  }) async {
    await showAlignedDialog(
      barrierColor: Colors.transparent,
      context: anchorContext,
      isGlobal: false,
      avoidOverflow: true,
      targetAnchor: const AlignmentDirectional(1.0, 1.0)
          .resolve(Directionality.of(anchorContext)),
      followerAnchor: const AlignmentDirectional(1.0, -1.0)
          .resolve(Directionality.of(anchorContext)),
      builder: (dialogContext) {
        final theme = FlutterFlowTheme.of(dialogContext);

        Widget buildItem({
          required IconData icon,
          required String label,
          required Future<void> Function() onTap,
          Color? color,
        }) {
          final itemColor = color ?? theme.primaryText;
          return InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              await onTap();
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: itemColor,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontStyle: theme.bodyMedium.fontStyle,
                      ),
                      color: itemColor,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: theme.secondaryText.withOpacity(0.25),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildItem(
                  icon: Icons.visibility_outlined,
                  label: 'Visualizar',
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _openViewSanidadeDialog(sanidade);
                  },
                ),
                buildItem(
                  icon: Icons.edit_outlined,
                  label: 'Editar',
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _openEditSanidadeDialog(sanidade);
                  },
                ),
                buildItem(
                  icon: Icons.delete_outline,
                  label: 'Excluir',
                  color: theme.error,
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    await _confirmAndDeleteSanidade(sanidade);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    if (FFAppState().refreshSanidade && !_sanidadeRefreshScheduled) {
      _sanidadeRefreshScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!FFAppState().refreshSanidade) {
          _sanidadeRefreshScheduled = false;
          return;
        }
        FFAppState().refreshSanidade = false;
        safeSetState(() {
          _model.apiRequestCompleter2 = null;
          _model.apiRequestCompleter1 = null;
        });
        _sanidadeRefreshScheduled = false;
      });
    }

    final bool isCompact = MediaQuery.sizeOf(context).width < 1200.0;
    final double pagePadH = isCompact ? 16.0 : 32.0;
    final double pagePadV = isCompact ? 24.0 : 34.0;
    final double titleFontSize = isCompact ? 32.0 : 40.0;
    final double headerControlHeight = isCompact ? 48.0 : 56.0;
    final double headerButtonFontSize = isCompact ? 16.0 : 18.0;
    final double headerButtonPadH = isCompact ? 16.0 : 24.0;
    final double searchWidth = isCompact ? 240.0 : 327.0;

    final double kpiCardPadding = isCompact ? 16.0 : 24.0;
    final double kpiTitleSize = isCompact ? 14.0 : 16.0;
    final double kpiValueSize = isCompact ? 20.0 : 24.0;
    final double kpiIconSize = isCompact ? 32.0 : 36.0;
    final double kpiInnerGapH = isCompact ? 10.0 : 12.0;
    final double kpiInnerGapV = isCompact ? 12.0 : 16.0;
    final double kpiCardsGap = isCompact ? 16.0 : 24.0;

    return FutureBuilder<ApiCallResponse>(
      future: (_model.apiRequestCompleter2 ??= Completer<ApiCallResponse>()
            ..complete(
                FunctionsSupabaseRebanhoGroup.buscarSanidadeFiltrosCall.call(
              pIdPropriedade: FFAppState().propriedadeSelecionada.idPropriedade,
              pPesquisa: _model.textController.text,
              pDataSanidade: dateTimeFormat(
                "yyyy-MM-dd",
                FFAppState().filtroDataSanidade,
                locale: FFLocalizations.of(context).languageCode,
              ),
              pLoteId: FFAppState().filtroLoteSanidade,
              pRebanhoId: FFAppState().filtroAnimalSanidade,
              pSexo: FFAppState().filtroSexoSanidade,
              pDataNascimento: dateTimeFormat(
                "yyyy-MM-dd",
                FFAppState().filtroNascimentoSanidade,
                locale: FFLocalizations.of(context).languageCode,
              ),
              pRaca: FFAppState().filtroRacaSanidade,
              pTratamento: FFAppState().filtroTratamentoSanidade,
              pProtocolo: FFAppState().filtroProtocolo,
              pAntiparasitarios: FFAppState().filtroAntiparasitario,
              pVacinacao: FFAppState().filtroVacinacao,
              pLimite: FFAppConstants.limit,
              pOffset: functions.calcDeslocamento(
                  _model.pageNum, FFAppConstants.limit),
            )))
          .future,
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        final pgSanidadeBuscarSanidadeFiltrosResponse = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.headerModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const HeaderWidget(),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          wrapWithModel(
                            model: _model.sideBarModel,
                            updateCallback: () => safeSetState(() {}),
                            child: const SideBarWidget(),
                          ),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    pagePadH, pagePadV, pagePadH, pagePadV),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sanidade',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: titleFontSize,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Builder(
                                              builder: (context) =>
                                                  FFButtonWidget(
                                                onPressed: () async {
                                                  await showAlignedDialog(
                                                    barrierColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    isGlobal: false,
                                                    avoidOverflow: true,
                                                    targetAnchor:
                                                        const AlignmentDirectional(
                                                                -1.0, 1.0)
                                                            .resolve(
                                                                Directionality.of(
                                                                    context)),
                                                    followerAnchor:
                                                        const AlignmentDirectional(
                                                                -1.0, -1.0)
                                                            .resolve(
                                                                Directionality.of(
                                                                    context)),
                                                    builder: (dialogContext) {
                                                      return Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    dialogContext)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child:
                                                              ModalAddSanidadeWidget(
                                                            action:
                                                                (page) async {
                                                              // Recarrega tabelas/cards após adicionar sanidade
                                                              safeSetState(() {
                                                                _model.apiRequestCompleter2 =
                                                                    null;
                                                                _model.apiRequestCompleter1 =
                                                                    null;
                                                              });

                                                              final idPropriedade =
                                                                  FFAppState()
                                                                      .propriedadeSelecionada
                                                                      .idPropriedade;

                                                              final vacinasCount =
                                                                  await SanidadeTable()
                                                                      .queryRows(
                                                                queryFn: (q) => q
                                                                    .eqOrNull(
                                                                        'id_propriedade',
                                                                        idPropriedade)
                                                                    .eq('deletado',
                                                                        'NAO')
                                                                    .not(
                                                                        'vacinacao',
                                                                        'is',
                                                                        null),
                                                              );

                                                              final antiparasitariosCount =
                                                                  await SanidadeTable()
                                                                      .queryRows(
                                                                queryFn: (q) => q
                                                                    .eqOrNull(
                                                                        'id_propriedade',
                                                                        idPropriedade)
                                                                    .eq('deletado',
                                                                        'NAO')
                                                                    .not(
                                                                        'antiparasitario',
                                                                        'is',
                                                                        null),
                                                              );

                                                              final tratamentosCount =
                                                                  await SanidadeTable()
                                                                      .queryRows(
                                                                queryFn: (q) => q
                                                                    .eqOrNull(
                                                                        'id_propriedade',
                                                                        idPropriedade)
                                                                    .eq('deletado',
                                                                        'NAO')
                                                                    .not(
                                                                        'tratamento',
                                                                        'is',
                                                                        null),
                                                              );

                                                              final protocolosCount =
                                                                  await SanidadeTable()
                                                                      .queryRows(
                                                                queryFn: (q) => q
                                                                    .eqOrNull(
                                                                        'id_propriedade',
                                                                        idPropriedade)
                                                                    .eq('deletado',
                                                                        'NAO')
                                                                    .not(
                                                                        'protocolo_reprodutivo',
                                                                        'is',
                                                                        null),
                                                              );

                                                              safeSetState(() {
                                                                _model.countVacinas =
                                                                    vacinasCount
                                                                        .length;
                                                                _model.countAntiparasitarios =
                                                                    antiparasitariosCount
                                                                        .length;
                                                                _model.countTratamentos =
                                                                    tratamentosCount
                                                                        .length;
                                                                _model.countProtocolos =
                                                                    protocolosCount
                                                                        .length;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                text: 'Adicionar sanidade',
                                                icon: const Icon(
                                                  Icons
                                                      .keyboard_arrow_down_sharp,
                                                  size: 24.0,
                                                ),
                                                options: FFButtonOptions(
                                                  height: headerControlHeight,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          headerButtonPadH,
                                                          0.0,
                                                          headerButtonPadH,
                                                          0.0),
                                                  iconAlignment:
                                                      IconAlignment.end,
                                                  iconPadding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primary,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        fontSize:
                                                            headerButtonFontSize,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  elevation: 0.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                  hoverColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: headerControlHeight,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .customColor2,
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                              child: Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0.0, 0.0),
                                                child: SizedBox(
                                                  width: searchWidth,
                                                  child: TextFormField(
                                                    controller:
                                                        _model.textController,
                                                    focusNode: _model
                                                        .textFieldFocusNode,
                                                    onChanged: (_) =>
                                                        EasyDebounce.debounce(
                                                      '_model.textController',
                                                      const Duration(
                                                          milliseconds: 250),
                                                      () async {
                                                        safeSetState(() => _model
                                                                .apiRequestCompleter2 =
                                                            null);
                                                        safeSetState(() => _model
                                                                .apiRequestCompleter1 =
                                                            null);
                                                      },
                                                    ),
                                                    autofocus: false,
                                                    obscureText: false,
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      labelStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent3,
                                                                fontSize:
                                                                    isCompact
                                                                        ? 14.0
                                                                        : 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      hintText: 'Pesquisar',
                                                      hintStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .accent3,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .labelMedium
                                                                    .fontStyle,
                                                              ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                          color:
                                                              Color(0x00000000),
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .error,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .customColor2,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      prefixIcon: Icon(
                                                        Icons.search_sharp,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .accent3,
                                                        size: 24.0,
                                                      ),
                                                      suffixIcon: _model
                                                              .textController!
                                                              .text
                                                              .isNotEmpty
                                                          ? InkWell(
                                                              onTap: () async {
                                                                _model
                                                                    .textController
                                                                    ?.clear();
                                                                safeSetState(() =>
                                                                    _model.apiRequestCompleter2 =
                                                                        null);
                                                                safeSetState(() =>
                                                                    _model.apiRequestCompleter1 =
                                                                        null);
                                                                safeSetState(
                                                                    () {});
                                                              },
                                                              child: const Icon(
                                                                Icons.clear,
                                                                size: 22,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                    cursorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    validator: _model
                                                        .textControllerValidator
                                                        .asValidator(context),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Builder(
                                              builder: (context) =>
                                                  FFButtonWidget(
                                                onPressed: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (dialogContext) {
                                                      return Dialog(
                                                        elevation: 0,
                                                        insetPadding:
                                                            EdgeInsets.zero,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        alignment:
                                                            const AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    dialogContext)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child:
                                                              const PpFiltroSanidadeWidget(),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                text: 'Filtrar',
                                                icon: const Icon(
                                                  Icons.filter_list,
                                                  size: 24.0,
                                                ),
                                                options: FFButtonOptions(
                                                  height: 56.0,
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          16.0, 0.0, 16.0, 0.0),
                                                  iconPadding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 0.0, 0.0, 0.0),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        fontSize: 18.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleSmall
                                                                .fontStyle,
                                                      ),
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(
                                              width: isCompact ? 16.0 : 24.0)),
                                        ),
                                      ].divide(SizedBox(
                                          width: isCompact ? 16.0 : 24.0)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              boxShadow: const [
                                                BoxShadow(
                                                  blurRadius: 4.0,
                                                  color: Color(0x40000000),
                                                  offset: Offset(
                                                    2.0,
                                                    2.0,
                                                  ),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: const Color(0xFFEDEDED),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  kpiCardPadding),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Vacinas aplicadas',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize:
                                                              kpiTitleSize,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: SvgPicture.asset(
                                                          'assets/images/Group_196.svg',
                                                          width: kpiIconSize,
                                                          height: kpiIconSize,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      Text(
                                                        _model.countVacinas
                                                            .toString(),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      kpiValueSize,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        width: kpiInnerGapH)),
                                                  ),
                                                ].divide(SizedBox(
                                                    height: kpiInnerGapV)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              boxShadow: const [
                                                BoxShadow(
                                                  blurRadius: 4.0,
                                                  color: Color(0x40000000),
                                                  offset: Offset(
                                                    2.0,
                                                    2.0,
                                                  ),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: const Color(0xFFEDEDED),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  kpiCardPadding),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Antiparasitários aplicados',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize:
                                                              kpiTitleSize,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: SvgPicture.asset(
                                                          'assets/images/Group_196.svg',
                                                          width: kpiIconSize,
                                                          height: kpiIconSize,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      Text(
                                                        _model
                                                            .countAntiparasitarios
                                                            .toString(),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      kpiValueSize,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        width: kpiInnerGapH)),
                                                  ),
                                                ].divide(SizedBox(
                                                    height: kpiInnerGapV)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              boxShadow: const [
                                                BoxShadow(
                                                  blurRadius: 4.0,
                                                  color: Color(0x40000000),
                                                  offset: Offset(
                                                    2.0,
                                                    2.0,
                                                  ),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: const Color(0xFFEDEDED),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  kpiCardPadding),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Tratamentos aplicados',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize:
                                                              kpiTitleSize,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: SvgPicture.asset(
                                                          'assets/images/Group_196.svg',
                                                          width: kpiIconSize,
                                                          height: kpiIconSize,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      Text(
                                                        _model.countTratamentos
                                                            .toString(),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      kpiValueSize,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        width: kpiInnerGapH)),
                                                  ),
                                                ].divide(SizedBox(
                                                    height: kpiInnerGapV)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              boxShadow: const [
                                                BoxShadow(
                                                  blurRadius: 4.0,
                                                  color: Color(0x40000000),
                                                  offset: Offset(
                                                    2.0,
                                                    2.0,
                                                  ),
                                                )
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: const Color(0xFFEDEDED),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  kpiCardPadding),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Protocolos reprodutivos',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize:
                                                              kpiTitleSize,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: SvgPicture.asset(
                                                          'assets/images/Group_196.svg',
                                                          width: kpiIconSize,
                                                          height: kpiIconSize,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      Text(
                                                        _model.countProtocolos
                                                            .toString(),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  fontSize:
                                                                      kpiValueSize,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        width: kpiInnerGapH)),
                                                  ),
                                                ].divide(SizedBox(
                                                    height: kpiInnerGapV)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ].divide(SizedBox(width: kpiCardsGap)),
                                    ),
                                    Divider(
                                      height: 24.0,
                                      thickness: 2.0,
                                      color: FlutterFlowTheme.of(context)
                                          .customColor5,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: const Alignment(-1.0, 0),
                                            child: TabBar(
                                              isScrollable: true,
                                              labelColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              unselectedLabelColor:
                                                  FlutterFlowTheme.of(context)
                                                      .accent3,
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                              unselectedLabelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleMedium
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .fontStyle,
                                                      ),
                                              indicatorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                              indicatorWeight: 3.0,
                                              tabs: const [
                                                Tab(
                                                  text: 'Tudo',
                                                ),
                                                Tab(
                                                  text: 'Vacinação',
                                                ),
                                                Tab(
                                                  text: 'Antiparasitários',
                                                ),
                                                Tab(
                                                  text: 'Tratamentos',
                                                ),
                                                Tab(
                                                  text:
                                                      'Protocolos reprodutivos',
                                                ),
                                              ],
                                              controller:
                                                  _model.tabBarController,
                                              onTap: (i) async {
                                                [
                                                  () async {},
                                                  () async {},
                                                  () async {},
                                                  () async {},
                                                  () async {}
                                                ][i]();
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: TabBarView(
                                              controller:
                                                  _model.tabBarController,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Flexible(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final sanidade = (pgSanidadeBuscarSanidadeFiltrosResponse
                                                                        .jsonBody
                                                                        .toList()
                                                                        .map<SanidadeStruct?>(SanidadeStruct
                                                                            .maybeFromMap)
                                                                        .toList()
                                                                    as Iterable<
                                                                        SanidadeStruct?>)
                                                                .withoutNulls
                                                                .where(
                                                                    _passesMultiSelectFilters)
                                                                .sortedList(
                                                                    keyOf: (e) =>
                                                                        e.createdAt,
                                                                    desc: true)
                                                                .toList();
                                                            if (sanidade
                                                                .isEmpty) {
                                                              return const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              );
                                                            }

                                                            return FlutterFlowDataTable<
                                                                SanidadeStruct>(
                                                              controller: _model
                                                                  .paginatedDataTableController1,
                                                              data: sanidade,
                                                              columnsBuilder:
                                                                  (onSortChanged) =>
                                                                      [
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Data',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Sanidade',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Número do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Nome do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Lote',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      ' ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  fixedWidth:
                                                                      70.0,
                                                                ),
                                                              ],
                                                              dataRowBuilder:
                                                                  (sanidadeItem,
                                                                          sanidadeIndex,
                                                                          selected,
                                                                          onSelectChanged) =>
                                                                      DataRow(
                                                                color:
                                                                    WidgetStateProperty
                                                                        .all(
                                                                  sanidadeIndex %
                                                                              2 ==
                                                                          0
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor11,
                                                                ),
                                                                cells: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        () {
                                                                          final rawDate = sanidadeItem.dataSanidade.trim().isNotEmpty
                                                                              ? sanidadeItem.dataSanidade
                                                                              : sanidadeItem.createdAt;
                                                                          final parsed =
                                                                              functions.converterParaData(rawDate);
                                                                          if (parsed ==
                                                                              null) {
                                                                            return '—';
                                                                          }
                                                                          return dateTimeFormat(
                                                                            "d/M/y",
                                                                            parsed,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          );
                                                                        }(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        if (sanidadeItem.vacinacao.trim().isNotEmpty &&
                                                                            sanidadeItem.vacinacao !=
                                                                                'null' &&
                                                                            sanidadeItem.vacinacao !=
                                                                                '[]')
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).accent2,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                              child: Text(
                                                                                'Vacina',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (sanidadeItem.antiparasitario.trim().isNotEmpty &&
                                                                            sanidadeItem.antiparasitario !=
                                                                                'null' &&
                                                                            sanidadeItem.antiparasitario !=
                                                                                '[]')
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).accent2,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                              child: Text(
                                                                                'Antiparasitário',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (sanidadeItem.protocoloReprodutivo.trim().isNotEmpty &&
                                                                            sanidadeItem.protocoloReprodutivo !=
                                                                                'null' &&
                                                                            sanidadeItem.protocoloReprodutivo !=
                                                                                '[]')
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).accent2,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                              child: Text(
                                                                                'Protocolo reprodutivo',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        if (sanidadeItem.tratamento.trim().isNotEmpty &&
                                                                            sanidadeItem.tratamento !=
                                                                                'null' &&
                                                                            sanidadeItem.tratamento !=
                                                                                '[]')
                                                                          Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).accent2,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                              child: Text(
                                                                                'Tratamento',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                      fontSize: 10.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ].divide(const SizedBox(
                                                                              width: 4.0)),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .numeroAnimal,
                                                                          'Não se aplica',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .nome,
                                                                          'Não se aplica',
                                                                        ).maybeHandleOverflow(
                                                                          maxChars:
                                                                              27,
                                                                          replacement:
                                                                              '…',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        sanidadeItem.loteNome.trim().isEmpty ||
                                                                                (sanidadeItem.loteNome.trim().toLowerCase() == 'null')
                                                                            ? 'N/A'
                                                                            : sanidadeItem.loteNome.trim(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (iconButtonContext) =>
                                                                                FlutterFlowIconButton(
                                                                          borderRadius:
                                                                              8.0,
                                                                          buttonSize:
                                                                              32.0,
                                                                          fillColor:
                                                                              const Color(0x0028A365),
                                                                          icon:
                                                                              Icon(
                                                                            Icons.keyboard_control,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            size:
                                                                                18.0,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await _openSanidadeRowMenu(
                                                                              anchorContext: iconButtonContext,
                                                                              sanidade: sanidadeItem,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]
                                                                    .map((c) =>
                                                                        DataCell(
                                                                            c))
                                                                    .toList(),
                                                              ),
                                                              emptyBuilder: () =>
                                                                  const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              ),
                                                              paginated: false,
                                                              selectable: false,
                                                              headingRowHeight:
                                                                  40.0,
                                                              dataRowHeight:
                                                                  32.0,
                                                              columnSpacing:
                                                                  20.0,
                                                              headingRowColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor11,
                                                              sortIconColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              addHorizontalDivider:
                                                                  true,
                                                              addTopAndBottomDivider:
                                                                  false,
                                                              hideDefaultHorizontalDivider:
                                                                  true,
                                                              horizontalDividerColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                              horizontalDividerThickness:
                                                                  1.0,
                                                              addVerticalDivider:
                                                                  false,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FutureBuilder<
                                                                ApiCallResponse>(
                                                              future: (_model.apiRequestCompleter1 ??= Completer<
                                                                      ApiCallResponse>()
                                                                    ..complete(
                                                                        FunctionsSupabaseRebanhoGroup
                                                                            .countSanidadeFiltrosCall
                                                                            .call(
                                                                      pIdPropriedade: FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
                                                                      pPesquisa: _model
                                                                          .textController
                                                                          .text,
                                                                      pDataSanidade:
                                                                          dateTimeFormat(
                                                                        "yyyy-MM-dd",
                                                                        FFAppState()
                                                                            .filtroDataSanidade,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      ),
                                                                      pLoteId:
                                                                          FFAppState()
                                                                              .filtroLoteSanidade,
                                                                      pRebanhoId:
                                                                          FFAppState()
                                                                              .filtroAnimalSanidade,
                                                                      pSexo: FFAppState()
                                                                          .filtroSexoSanidade,
                                                                      pDataNascimento:
                                                                          dateTimeFormat(
                                                                        "yyyy-MM-dd",
                                                                        FFAppState()
                                                                            .filtroNascimentoSanidade,
                                                                        locale:
                                                                            FFLocalizations.of(context).languageCode,
                                                                      ),
                                                                      pRaca: FFAppState()
                                                                          .filtroRacaSanidade,
                                                                      pTratamento:
                                                                          FFAppState()
                                                                              .filtroTratamentoSanidade,
                                                                      pProtocolo:
                                                                          FFAppState()
                                                                              .filtroProtocolo,
                                                                      pAntiparasitarios:
                                                                          FFAppState()
                                                                              .filtroAntiparasitario,
                                                                      pVacinacao:
                                                                          FFAppState()
                                                                              .filtroVacinacao,
                                                                    )))
                                                                  .future,
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final containerCountSanidadeFiltrosResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return Container(
                                                                  height: 56.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor5,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              1;
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(6.0),
                                                                              bottomRight: Radius.circular(0.0),
                                                                              topLeft: Radius.circular(6.0),
                                                                              topRight: Radius.circular(0.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_left,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum >
                                                                              1) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + -1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_left_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                        child:
                                                                            RichText(
                                                                          textScaler:
                                                                              MediaQuery.of(context).textScaler,
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  _model.pageNum.toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              const TextSpan(
                                                                                text: ' de ',
                                                                                style: TextStyle(
                                                                                  fontSize: 16.0,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  ((containerCountSanidadeFiltrosResponse.jsonBody / FFAppConstants.limit).ceil()).toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).accent3,
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              )
                                                                            ],
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum <
                                                                              valueOrDefault<int>(
                                                                                (containerCountSanidadeFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                1,
                                                                              )) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + 1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_right_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum <
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).primaryText
                                                                                    : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              valueOrDefault<int>(
                                                                            (containerCountSanidadeFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                            1,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(0.0),
                                                                              bottomRight: Radius.circular(6.0),
                                                                              topLeft: Radius.circular(0.0),
                                                                              topRight: Radius.circular(6.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_right_outlined,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum ==
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeFiltrosResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).accent3
                                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        height: isCompact
                                                            ? 16.0
                                                            : 32.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Flexible(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final sanidade = (pgSanidadeBuscarSanidadeFiltrosResponse.jsonBody
                                                                        .toList()
                                                                        .map<SanidadeStruct?>(SanidadeStruct
                                                                            .maybeFromMap)
                                                                        .toList()
                                                                    as Iterable<
                                                                        SanidadeStruct?>)
                                                                .withoutNulls
                                                                .where(
                                                                    _passesMultiSelectFilters)
                                                                .where((e) =>
                                                                    (e.vacinacao.trim().isNotEmpty &&
                                                                        e.vacinacao !=
                                                                            'null' &&
                                                                        e.vacinacao !=
                                                                            '[]') ||
                                                                    (e.vacinacaoOutros.trim().isNotEmpty &&
                                                                        e.vacinacaoOutros !=
                                                                            'null' &&
                                                                        e.vacinacaoOutros !=
                                                                            '[]'))
                                                                .toList()
                                                                .sortedList(
                                                                    keyOf: (e) => e.createdAt,
                                                                    desc: true)
                                                                .toList();
                                                            if (sanidade
                                                                .isEmpty) {
                                                              return const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              );
                                                            }

                                                            return FlutterFlowDataTable<
                                                                SanidadeStruct>(
                                                              controller: _model
                                                                  .paginatedDataTableController2,
                                                              data: sanidade,
                                                              columnsBuilder:
                                                                  (onSortChanged) =>
                                                                      [
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Data',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Vacinas',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Número do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Nome do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Lote',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      ' ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  fixedWidth:
                                                                      70.0,
                                                                ),
                                                              ],
                                                              dataRowBuilder:
                                                                  (sanidadeItem,
                                                                          sanidadeIndex,
                                                                          selected,
                                                                          onSelectChanged) =>
                                                                      DataRow(
                                                                color:
                                                                    WidgetStateProperty
                                                                        .all(
                                                                  sanidadeIndex %
                                                                              2 ==
                                                                          0
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor11,
                                                                ),
                                                                cells: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        () {
                                                                          final rawDate = sanidadeItem.dataSanidade.trim().isNotEmpty
                                                                              ? sanidadeItem.dataSanidade
                                                                              : sanidadeItem.createdAt;
                                                                          final parsed =
                                                                              functions.converterParaData(rawDate);
                                                                          if (parsed ==
                                                                              null) {
                                                                            return '—';
                                                                          }
                                                                          return dateTimeFormat(
                                                                            "d/M/y",
                                                                            parsed,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          );
                                                                        }(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      final vacinas =
                                                                          functions.converterJSONparaLista(sanidadeItem.vacinacao)?.toList() ??
                                                                              [];

                                                                      return SingleChildScrollView(
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: List.generate(
                                                                              vacinas.length,
                                                                              (vacinasIndex) {
                                                                            final vacinasItem =
                                                                                vacinas[vacinasIndex];
                                                                            return Container(
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).accent2,
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                child: Text(
                                                                                  vacinasItem,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).divide(
                                                                              const SizedBox(width: 4.0)),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .numeroAnimal,
                                                                          'Não se aplica',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .nome,
                                                                          'Não se aplica',
                                                                        ).maybeHandleOverflow(
                                                                          maxChars:
                                                                              27,
                                                                          replacement:
                                                                              '…',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        sanidadeItem.loteNome.trim().isEmpty ||
                                                                                (sanidadeItem.loteNome.trim().toLowerCase() == 'null')
                                                                            ? 'N/A'
                                                                            : sanidadeItem.loteNome.trim(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (iconButtonContext) =>
                                                                                FlutterFlowIconButton(
                                                                          borderRadius:
                                                                              8.0,
                                                                          buttonSize:
                                                                              32.0,
                                                                          fillColor:
                                                                              const Color(0x0028A365),
                                                                          icon:
                                                                              Icon(
                                                                            Icons.keyboard_control,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            size:
                                                                                18.0,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await _openSanidadeRowMenu(
                                                                              anchorContext: iconButtonContext,
                                                                              sanidade: sanidadeItem,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]
                                                                    .map((c) =>
                                                                        DataCell(
                                                                            c))
                                                                    .toList(),
                                                              ),
                                                              emptyBuilder: () =>
                                                                  const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              ),
                                                              paginated: true,
                                                              selectable: false,
                                                              hidePaginator:
                                                                  true,
                                                              showFirstLastButtons:
                                                                  true,
                                                              headingRowHeight:
                                                                  40.0,
                                                              dataRowHeight:
                                                                  32.0,
                                                              columnSpacing:
                                                                  20.0,
                                                              headingRowColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor11,
                                                              sortIconColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              addHorizontalDivider:
                                                                  true,
                                                              addTopAndBottomDivider:
                                                                  false,
                                                              hideDefaultHorizontalDivider:
                                                                  true,
                                                              horizontalDividerColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                              horizontalDividerThickness:
                                                                  1.0,
                                                              addVerticalDivider:
                                                                  false,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FutureBuilder<
                                                                ApiCallResponse>(
                                                              future: FunctionsSupabaseRebanhoGroup
                                                                  .countSanidadeVacinacaoCall
                                                                  .call(
                                                                pIdPropriedade:
                                                                    FFAppState()
                                                                        .propriedadeSelecionada
                                                                        .idPropriedade,
                                                                pPesquisa: _model
                                                                    .textController
                                                                    .text,
                                                                pDataSanidade:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroDataSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pLoteId:
                                                                    FFAppState()
                                                                        .filtroLoteSanidade,
                                                                pRebanhoId:
                                                                    FFAppState()
                                                                        .filtroAnimalSanidade,
                                                                pSexo: FFAppState()
                                                                    .filtroSexoSanidade,
                                                                pDataNascimento:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroNascimentoSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pRaca: FFAppState()
                                                                    .filtroRacaSanidade,
                                                                pTratamento:
                                                                    FFAppState()
                                                                        .filtroTratamentoSanidade,
                                                                pProtocolo:
                                                                    FFAppState()
                                                                        .filtroProtocolo,
                                                                pAntiparasitarios:
                                                                    FFAppState()
                                                                        .filtroAntiparasitario,
                                                                pVacinacao:
                                                                    FFAppState()
                                                                        .filtroVacinacao,
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final containerCountSanidadeVacinacaoResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return Container(
                                                                  height: 56.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor5,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              1;
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(6.0),
                                                                              bottomRight: Radius.circular(0.0),
                                                                              topLeft: Radius.circular(6.0),
                                                                              topRight: Radius.circular(0.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_left,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum >
                                                                              1) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + -1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_left_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                        child:
                                                                            RichText(
                                                                          textScaler:
                                                                              MediaQuery.of(context).textScaler,
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  _model.pageNum.toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              const TextSpan(
                                                                                text: ' de ',
                                                                                style: TextStyle(
                                                                                  fontSize: 16.0,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  ((containerCountSanidadeVacinacaoResponse.jsonBody / FFAppConstants.limit).ceil()).toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).accent3,
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              )
                                                                            ],
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum <
                                                                              valueOrDefault<int>(
                                                                                (containerCountSanidadeVacinacaoResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                1,
                                                                              )) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + 1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_right_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum <
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeVacinacaoResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).primaryText
                                                                                    : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              valueOrDefault<int>(
                                                                            (containerCountSanidadeVacinacaoResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                            1,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(0.0),
                                                                              bottomRight: Radius.circular(6.0),
                                                                              topLeft: Radius.circular(0.0),
                                                                              topRight: Radius.circular(6.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_right_outlined,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum ==
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeVacinacaoResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).accent3
                                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        height: isCompact
                                                            ? 16.0
                                                            : 32.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Flexible(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final sanidade = (pgSanidadeBuscarSanidadeFiltrosResponse.jsonBody
                                                                        .toList()
                                                                        .map<SanidadeStruct?>(SanidadeStruct
                                                                            .maybeFromMap)
                                                                        .toList()
                                                                    as Iterable<
                                                                        SanidadeStruct?>)
                                                                .withoutNulls
                                                                .where(
                                                                    _passesMultiSelectFilters)
                                                                .where((e) =>
                                                                    (e.antiparasitario.trim().isNotEmpty &&
                                                                        e.antiparasitario !=
                                                                            'null' &&
                                                                        e.antiparasitario !=
                                                                            '[]') ||
                                                                    (e.antiparasitarioOutros.trim().isNotEmpty &&
                                                                        e.antiparasitarioOutros !=
                                                                            'null' &&
                                                                        e.antiparasitarioOutros !=
                                                                            '[]'))
                                                                .toList()
                                                                .sortedList(
                                                                    keyOf: (e) => e.createdAt,
                                                                    desc: true)
                                                                .toList();
                                                            if (sanidade
                                                                .isEmpty) {
                                                              return const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              );
                                                            }

                                                            return FlutterFlowDataTable<
                                                                SanidadeStruct>(
                                                              controller: _model
                                                                  .paginatedDataTableController3,
                                                              data: sanidade,
                                                              columnsBuilder:
                                                                  (onSortChanged) =>
                                                                      [
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Data',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Antiparasitários',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Número do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Nome do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Lote',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      ' ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  fixedWidth:
                                                                      70.0,
                                                                ),
                                                              ],
                                                              dataRowBuilder:
                                                                  (sanidadeItem,
                                                                          sanidadeIndex,
                                                                          selected,
                                                                          onSelectChanged) =>
                                                                      DataRow(
                                                                color:
                                                                    WidgetStateProperty
                                                                        .all(
                                                                  sanidadeIndex %
                                                                              2 ==
                                                                          0
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor11,
                                                                ),
                                                                cells: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        () {
                                                                          final rawDate = sanidadeItem.dataSanidade.trim().isNotEmpty
                                                                              ? sanidadeItem.dataSanidade
                                                                              : sanidadeItem.createdAt;
                                                                          final parsed =
                                                                              functions.converterParaData(rawDate);
                                                                          if (parsed ==
                                                                              null) {
                                                                            return '—';
                                                                          }
                                                                          return dateTimeFormat(
                                                                            "d/M/y",
                                                                            parsed,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          );
                                                                        }(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      final antiparasitarios =
                                                                          functions.converterJSONparaLista(sanidadeItem.antiparasitario)?.toList() ??
                                                                              [];

                                                                      return SingleChildScrollView(
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: List.generate(
                                                                              antiparasitarios.length,
                                                                              (antiparasitariosIndex) {
                                                                            final antiparasitariosItem =
                                                                                antiparasitarios[antiparasitariosIndex];
                                                                            return Container(
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).accent2,
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                child: Text(
                                                                                  antiparasitariosItem,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).divide(
                                                                              const SizedBox(width: 4.0)),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .numeroAnimal,
                                                                          'Não se aplica',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .nome,
                                                                          'Não se aplica',
                                                                        ).maybeHandleOverflow(
                                                                          maxChars:
                                                                              27,
                                                                          replacement:
                                                                              '…',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        sanidadeItem.loteNome.trim().isEmpty ||
                                                                                (sanidadeItem.loteNome.trim().toLowerCase() == 'null')
                                                                            ? 'N/A'
                                                                            : sanidadeItem.loteNome.trim(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (iconButtonContext) =>
                                                                                FlutterFlowIconButton(
                                                                          borderRadius:
                                                                              8.0,
                                                                          buttonSize:
                                                                              32.0,
                                                                          fillColor:
                                                                              const Color(0x0028A365),
                                                                          icon:
                                                                              Icon(
                                                                            Icons.keyboard_control,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            size:
                                                                                18.0,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await _openSanidadeRowMenu(
                                                                              anchorContext: iconButtonContext,
                                                                              sanidade: sanidadeItem,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]
                                                                    .map((c) =>
                                                                        DataCell(
                                                                            c))
                                                                    .toList(),
                                                              ),
                                                              emptyBuilder: () =>
                                                                  const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              ),
                                                              paginated: true,
                                                              selectable: false,
                                                              hidePaginator:
                                                                  true,
                                                              showFirstLastButtons:
                                                                  true,
                                                              headingRowHeight:
                                                                  40.0,
                                                              dataRowHeight:
                                                                  32.0,
                                                              columnSpacing:
                                                                  20.0,
                                                              headingRowColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor11,
                                                              sortIconColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              addHorizontalDivider:
                                                                  true,
                                                              addTopAndBottomDivider:
                                                                  false,
                                                              hideDefaultHorizontalDivider:
                                                                  true,
                                                              horizontalDividerColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                              horizontalDividerThickness:
                                                                  1.0,
                                                              addVerticalDivider:
                                                                  false,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FutureBuilder<
                                                                ApiCallResponse>(
                                                              future: FunctionsSupabaseRebanhoGroup
                                                                  .countSanidadeAntiparasitarioCall
                                                                  .call(
                                                                pIdPropriedade:
                                                                    FFAppState()
                                                                        .propriedadeSelecionada
                                                                        .idPropriedade,
                                                                pPesquisa: _model
                                                                    .textController
                                                                    .text,
                                                                pDataSanidade:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroDataSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pLoteId:
                                                                    FFAppState()
                                                                        .filtroLoteSanidade,
                                                                pRebanhoId:
                                                                    FFAppState()
                                                                        .filtroAnimalSanidade,
                                                                pSexo: FFAppState()
                                                                    .filtroSexoSanidade,
                                                                pDataNascimento:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroNascimentoSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pRaca: FFAppState()
                                                                    .filtroRacaSanidade,
                                                                pTratamento:
                                                                    FFAppState()
                                                                        .filtroTratamentoSanidade,
                                                                pProtocolo:
                                                                    FFAppState()
                                                                        .filtroProtocolo,
                                                                pAntiparasitarios:
                                                                    FFAppState()
                                                                        .filtroAntiparasitario,
                                                                pVacinacao:
                                                                    FFAppState()
                                                                        .filtroVacinacao,
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final containerCountSanidadeAntiparasitarioResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return Container(
                                                                  height: 56.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor5,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              1;
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(6.0),
                                                                              bottomRight: Radius.circular(0.0),
                                                                              topLeft: Radius.circular(6.0),
                                                                              topRight: Radius.circular(0.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_left,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum >
                                                                              1) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + -1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_left_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                        child:
                                                                            RichText(
                                                                          textScaler:
                                                                              MediaQuery.of(context).textScaler,
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  _model.pageNum.toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              const TextSpan(
                                                                                text: ' de ',
                                                                                style: TextStyle(
                                                                                  fontSize: 16.0,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  ((containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil()).toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).accent3,
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              )
                                                                            ],
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum <
                                                                              valueOrDefault<int>(
                                                                                (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                1,
                                                                              )) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + 1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_right_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum <
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).primaryText
                                                                                    : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              valueOrDefault<int>(
                                                                            (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                            1,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(0.0),
                                                                              bottomRight: Radius.circular(6.0),
                                                                              topLeft: Radius.circular(0.0),
                                                                              topRight: Radius.circular(6.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_right_outlined,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum ==
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).accent3
                                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        height: isCompact
                                                            ? 16.0
                                                            : 32.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Flexible(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final sanidade = (pgSanidadeBuscarSanidadeFiltrosResponse.jsonBody
                                                                        .toList()
                                                                        .map<SanidadeStruct?>(SanidadeStruct
                                                                            .maybeFromMap)
                                                                        .toList()
                                                                    as Iterable<
                                                                        SanidadeStruct?>)
                                                                .withoutNulls
                                                                .where(
                                                                    _passesMultiSelectFilters)
                                                                .where((e) =>
                                                                    (e.tratamento.trim().isNotEmpty &&
                                                                        e.tratamento !=
                                                                            'null' &&
                                                                        e.tratamento !=
                                                                            '[]') ||
                                                                    (e.tratamentoOutros.trim().isNotEmpty &&
                                                                        e.tratamentoOutros !=
                                                                            'null' &&
                                                                        e.tratamentoOutros !=
                                                                            '[]'))
                                                                .toList()
                                                                .sortedList(
                                                                    keyOf: (e) => e.createdAt,
                                                                    desc: true)
                                                                .toList();
                                                            if (sanidade
                                                                .isEmpty) {
                                                              return const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              );
                                                            }

                                                            return FlutterFlowDataTable<
                                                                SanidadeStruct>(
                                                              controller: _model
                                                                  .paginatedDataTableController4,
                                                              data: sanidade,
                                                              columnsBuilder:
                                                                  (onSortChanged) =>
                                                                      [
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Data',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Tratamentos',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Número do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Nome do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Lote',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      ' ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  fixedWidth:
                                                                      70.0,
                                                                ),
                                                              ],
                                                              dataRowBuilder:
                                                                  (sanidadeItem,
                                                                          sanidadeIndex,
                                                                          selected,
                                                                          onSelectChanged) =>
                                                                      DataRow(
                                                                color:
                                                                    WidgetStateProperty
                                                                        .all(
                                                                  sanidadeIndex %
                                                                              2 ==
                                                                          0
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor11,
                                                                ),
                                                                cells: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        () {
                                                                          final rawDate = sanidadeItem.dataSanidade.trim().isNotEmpty
                                                                              ? sanidadeItem.dataSanidade
                                                                              : sanidadeItem.createdAt;
                                                                          final parsed =
                                                                              functions.converterParaData(rawDate);
                                                                          if (parsed ==
                                                                              null) {
                                                                            return '—';
                                                                          }
                                                                          return dateTimeFormat(
                                                                            "d/M/y",
                                                                            parsed,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          );
                                                                        }(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      final tratamentos =
                                                                          functions.converterJSONparaLista(sanidadeItem.tratamento)?.toList() ??
                                                                              [];

                                                                      return SingleChildScrollView(
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: List.generate(
                                                                              tratamentos.length,
                                                                              (tratamentosIndex) {
                                                                            final tratamentosItem =
                                                                                tratamentos[tratamentosIndex];
                                                                            return Container(
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).accent2,
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                child: Text(
                                                                                  tratamentosItem,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).divide(
                                                                              const SizedBox(width: 4.0)),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .numeroAnimal,
                                                                          'Não se aplica',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .nome,
                                                                          'Não se aplica',
                                                                        ).maybeHandleOverflow(
                                                                          maxChars:
                                                                              27,
                                                                          replacement:
                                                                              '…',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        sanidadeItem.loteNome.trim().isEmpty ||
                                                                                (sanidadeItem.loteNome.trim().toLowerCase() == 'null')
                                                                            ? 'N/A'
                                                                            : sanidadeItem.loteNome.trim(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (iconButtonContext) =>
                                                                                FlutterFlowIconButton(
                                                                          borderRadius:
                                                                              8.0,
                                                                          buttonSize:
                                                                              32.0,
                                                                          fillColor:
                                                                              const Color(0x0028A365),
                                                                          icon:
                                                                              Icon(
                                                                            Icons.keyboard_control,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            size:
                                                                                18.0,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await _openSanidadeRowMenu(
                                                                              anchorContext: iconButtonContext,
                                                                              sanidade: sanidadeItem,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]
                                                                    .map((c) =>
                                                                        DataCell(
                                                                            c))
                                                                    .toList(),
                                                              ),
                                                              emptyBuilder: () =>
                                                                  const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              ),
                                                              paginated: true,
                                                              selectable: false,
                                                              hidePaginator:
                                                                  true,
                                                              showFirstLastButtons:
                                                                  true,
                                                              headingRowHeight:
                                                                  40.0,
                                                              dataRowHeight:
                                                                  32.0,
                                                              columnSpacing:
                                                                  20.0,
                                                              headingRowColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor11,
                                                              sortIconColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              addHorizontalDivider:
                                                                  true,
                                                              addTopAndBottomDivider:
                                                                  false,
                                                              hideDefaultHorizontalDivider:
                                                                  true,
                                                              horizontalDividerColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                              horizontalDividerThickness:
                                                                  1.0,
                                                              addVerticalDivider:
                                                                  false,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FutureBuilder<
                                                                ApiCallResponse>(
                                                              future: FunctionsSupabaseRebanhoGroup
                                                                  .countSanidadeTratamentoCall
                                                                  .call(
                                                                pIdPropriedade:
                                                                    FFAppState()
                                                                        .propriedadeSelecionada
                                                                        .idPropriedade,
                                                                pPesquisa: _model
                                                                    .textController
                                                                    .text,
                                                                pDataSanidade:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroDataSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pLoteId:
                                                                    FFAppState()
                                                                        .filtroLoteSanidade,
                                                                pRebanhoId:
                                                                    FFAppState()
                                                                        .filtroAnimalSanidade,
                                                                pSexo: FFAppState()
                                                                    .filtroSexoSanidade,
                                                                pDataNascimento:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroNascimentoSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pRaca: FFAppState()
                                                                    .filtroRacaSanidade,
                                                                pTratamento:
                                                                    FFAppState()
                                                                        .filtroTratamentoSanidade,
                                                                pProtocolo:
                                                                    FFAppState()
                                                                        .filtroProtocolo,
                                                                pAntiparasitarios:
                                                                    FFAppState()
                                                                        .filtroAntiparasitario,
                                                                pVacinacao:
                                                                    FFAppState()
                                                                        .filtroVacinacao,
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final containerCountSanidadeAntiparasitarioResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return Container(
                                                                  height: 56.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor5,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              1;
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(6.0),
                                                                              bottomRight: Radius.circular(0.0),
                                                                              topLeft: Radius.circular(6.0),
                                                                              topRight: Radius.circular(0.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_left,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum >
                                                                              1) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + -1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_left_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                        child:
                                                                            RichText(
                                                                          textScaler:
                                                                              MediaQuery.of(context).textScaler,
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  _model.pageNum.toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              const TextSpan(
                                                                                text: ' de ',
                                                                                style: TextStyle(
                                                                                  fontSize: 16.0,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  ((containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil()).toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).accent3,
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              )
                                                                            ],
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum <
                                                                              valueOrDefault<int>(
                                                                                (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                1,
                                                                              )) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + 1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_right_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum <
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).primaryText
                                                                                    : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              valueOrDefault<int>(
                                                                            (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                            1,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(0.0),
                                                                              bottomRight: Radius.circular(6.0),
                                                                              topLeft: Radius.circular(0.0),
                                                                              topRight: Radius.circular(6.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_right_outlined,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum ==
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).accent3
                                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        height: isCompact
                                                            ? 16.0
                                                            : 32.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Flexible(
                                                        child: Builder(
                                                          builder: (context) {
                                                            final sanidade = (pgSanidadeBuscarSanidadeFiltrosResponse.jsonBody
                                                                        .toList()
                                                                        .map<SanidadeStruct?>(SanidadeStruct
                                                                            .maybeFromMap)
                                                                        .toList()
                                                                    as Iterable<
                                                                        SanidadeStruct?>)
                                                                .withoutNulls
                                                                .where(
                                                                    _passesMultiSelectFilters)
                                                                .where((e) =>
                                                                    (e.protocoloReprodutivo.trim().isNotEmpty &&
                                                                        e.protocoloReprodutivo !=
                                                                            'null' &&
                                                                        e.protocoloReprodutivo !=
                                                                            '[]') ||
                                                                    (e.protocoloReprodutivoOutros.trim().isNotEmpty &&
                                                                        e.protocoloReprodutivoOutros !=
                                                                            'null' &&
                                                                        e.protocoloReprodutivoOutros !=
                                                                            '[]'))
                                                                .toList()
                                                                .sortedList(
                                                                    keyOf: (e) => e.createdAt,
                                                                    desc: true)
                                                                .toList();
                                                            if (sanidade
                                                                .isEmpty) {
                                                              return const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              );
                                                            }

                                                            return FlutterFlowDataTable<
                                                                SanidadeStruct>(
                                                              controller: _model
                                                                  .paginatedDataTableController5,
                                                              data: sanidade,
                                                              columnsBuilder:
                                                                  (onSortChanged) =>
                                                                      [
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Data',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Protocolos reprodutivos',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Número do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Nome do animal',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      'Lote',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            fontSize:
                                                                                12.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  onSort:
                                                                      onSortChanged,
                                                                ),
                                                                DataColumn2(
                                                                  label:
                                                                      DefaultTextStyle
                                                                          .merge(
                                                                    softWrap:
                                                                        true,
                                                                    child: Text(
                                                                      ' ',
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  fixedWidth:
                                                                      70.0,
                                                                ),
                                                              ],
                                                              dataRowBuilder:
                                                                  (sanidadeItem,
                                                                          sanidadeIndex,
                                                                          selected,
                                                                          onSelectChanged) =>
                                                                      DataRow(
                                                                color:
                                                                    WidgetStateProperty
                                                                        .all(
                                                                  sanidadeIndex %
                                                                              2 ==
                                                                          0
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor11,
                                                                ),
                                                                cells: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        () {
                                                                          final rawDate = sanidadeItem.dataSanidade.trim().isNotEmpty
                                                                              ? sanidadeItem.dataSanidade
                                                                              : sanidadeItem.createdAt;
                                                                          final parsed =
                                                                              functions.converterParaData(rawDate);
                                                                          if (parsed ==
                                                                              null) {
                                                                            return '—';
                                                                          }
                                                                          return dateTimeFormat(
                                                                            "d/M/y",
                                                                            parsed,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          );
                                                                        }(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Builder(
                                                                    builder:
                                                                        (context) {
                                                                      final protocolos =
                                                                          functions.converterJSONparaLista(sanidadeItem.protocoloReprodutivo)?.toList() ??
                                                                              [];

                                                                      return SingleChildScrollView(
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        child:
                                                                            Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          children: List.generate(
                                                                              protocolos.length,
                                                                              (protocolosIndex) {
                                                                            final protocolosItem =
                                                                                protocolos[protocolosIndex];
                                                                            return Container(
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).accent2,
                                                                                borderRadius: BorderRadius.circular(4.0),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                                child: Text(
                                                                                  protocolosItem,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                        fontSize: 10.0,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }).divide(
                                                                              const SizedBox(width: 4.0)),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .numeroAnimal,
                                                                          'Não se aplica',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        width:
                                                                            8.0)),
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          sanidadeItem
                                                                              .nome,
                                                                          'Não se aplica',
                                                                        ).maybeHandleOverflow(
                                                                          maxChars:
                                                                              27,
                                                                          replacement:
                                                                              '…',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        sanidadeItem.loteNome.trim().isEmpty ||
                                                                                (sanidadeItem.loteNome.trim().toLowerCase() == 'null')
                                                                            ? 'N/A'
                                                                            : sanidadeItem.loteNome.trim(),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 14.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w500,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Builder(
                                                                        builder:
                                                                            (iconButtonContext) =>
                                                                                FlutterFlowIconButton(
                                                                          borderRadius:
                                                                              8.0,
                                                                          buttonSize:
                                                                              32.0,
                                                                          fillColor:
                                                                              const Color(0x0028A365),
                                                                          icon:
                                                                              Icon(
                                                                            Icons.keyboard_control,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            size:
                                                                                18.0,
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            await _openSanidadeRowMenu(
                                                                              anchorContext: iconButtonContext,
                                                                              sanidade: sanidadeItem,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]
                                                                    .map((c) =>
                                                                        DataCell(
                                                                            c))
                                                                    .toList(),
                                                              ),
                                                              emptyBuilder: () =>
                                                                  const Center(
                                                                child:
                                                                    EmptyRebanhoWidget(),
                                                              ),
                                                              paginated: true,
                                                              selectable: false,
                                                              hidePaginator:
                                                                  true,
                                                              showFirstLastButtons:
                                                                  true,
                                                              headingRowHeight:
                                                                  40.0,
                                                              dataRowHeight:
                                                                  32.0,
                                                              columnSpacing:
                                                                  20.0,
                                                              headingRowColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .customColor11,
                                                              sortIconColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                              addHorizontalDivider:
                                                                  true,
                                                              addTopAndBottomDivider:
                                                                  false,
                                                              hideDefaultHorizontalDivider:
                                                                  true,
                                                              horizontalDividerColor:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryBackground,
                                                              horizontalDividerThickness:
                                                                  1.0,
                                                              addVerticalDivider:
                                                                  false,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            FutureBuilder<
                                                                ApiCallResponse>(
                                                              future: FunctionsSupabaseRebanhoGroup
                                                                  .countSanidadeProtocoloReprodutivoCall
                                                                  .call(
                                                                pIdPropriedade:
                                                                    FFAppState()
                                                                        .propriedadeSelecionada
                                                                        .idPropriedade,
                                                                pPesquisa: _model
                                                                    .textController
                                                                    .text,
                                                                pDataSanidade:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroDataSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pLoteId:
                                                                    FFAppState()
                                                                        .filtroLoteSanidade,
                                                                pRebanhoId:
                                                                    FFAppState()
                                                                        .filtroAnimalSanidade,
                                                                pSexo: FFAppState()
                                                                    .filtroSexoSanidade,
                                                                pDataNascimento:
                                                                    dateTimeFormat(
                                                                  "yyyy-MM-dd",
                                                                  FFAppState()
                                                                      .filtroNascimentoSanidade,
                                                                  locale: FFLocalizations.of(
                                                                          context)
                                                                      .languageCode,
                                                                ),
                                                                pRaca: FFAppState()
                                                                    .filtroRacaSanidade,
                                                                pTratamento:
                                                                    FFAppState()
                                                                        .filtroTratamentoSanidade,
                                                                pProtocolo:
                                                                    FFAppState()
                                                                        .filtroProtocolo,
                                                                pAntiparasitarios:
                                                                    FFAppState()
                                                                        .filtroAntiparasitario,
                                                                pVacinacao:
                                                                    FFAppState()
                                                                        .filtroVacinacao,
                                                              ),
                                                              builder: (context,
                                                                  snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(
                                                                          FlutterFlowTheme.of(context)
                                                                              .primary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                                final containerCountSanidadeAntiparasitarioResponse =
                                                                    snapshot
                                                                        .data!;

                                                                return Container(
                                                                  height: 56.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .customColor5,
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              1;
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(6.0),
                                                                              bottomRight: Radius.circular(0.0),
                                                                              topLeft: Radius.circular(6.0),
                                                                              topRight: Radius.circular(0.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_left,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum >
                                                                              1) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + -1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_left_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum > 1 ? FlutterFlowTheme.of(context).primaryText : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            24.0,
                                                                            0.0,
                                                                            24.0,
                                                                            0.0),
                                                                        child:
                                                                            RichText(
                                                                          textScaler:
                                                                              MediaQuery.of(context).textScaler,
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  _model.pageNum.toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              ),
                                                                              const TextSpan(
                                                                                text: ' de ',
                                                                                style: TextStyle(
                                                                                  fontSize: 16.0,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: valueOrDefault<String>(
                                                                                  ((containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil()).toString(),
                                                                                  '1',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                      ),
                                                                                      color: FlutterFlowTheme.of(context).accent3,
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                              )
                                                                            ],
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          if (_model.pageNum <
                                                                              valueOrDefault<int>(
                                                                                (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                1,
                                                                              )) {
                                                                            _model.pageNum =
                                                                                _model.pageNum + 1;
                                                                            safeSetState(() {});
                                                                            safeSetState(() =>
                                                                                _model.apiRequestCompleter2 = null);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_arrow_right_sharp,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum <
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).primaryText
                                                                                    : FlutterFlowTheme.of(context).accent3,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap:
                                                                            () async {
                                                                          _model.pageNum =
                                                                              valueOrDefault<int>(
                                                                            (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                            1,
                                                                          );
                                                                          safeSetState(
                                                                              () {});
                                                                          safeSetState(() =>
                                                                              _model.apiRequestCompleter2 = null);
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              double.infinity,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryBackground,
                                                                            borderRadius:
                                                                                const BorderRadius.only(
                                                                              bottomLeft: Radius.circular(0.0),
                                                                              bottomRight: Radius.circular(6.0),
                                                                              topLeft: Radius.circular(0.0),
                                                                              topRight: Radius.circular(6.0),
                                                                            ),
                                                                            border:
                                                                                Border.all(
                                                                              color: FlutterFlowTheme.of(context).customColor5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                                                24.0,
                                                                                12.0,
                                                                                24.0,
                                                                                12.0),
                                                                            child:
                                                                                Icon(
                                                                              Icons.keyboard_double_arrow_right_outlined,
                                                                              color: valueOrDefault<Color>(
                                                                                _model.pageNum ==
                                                                                        valueOrDefault<int>(
                                                                                          (containerCountSanidadeAntiparasitarioResponse.jsonBody / FFAppConstants.limit).ceil(),
                                                                                          1,
                                                                                        )
                                                                                    ? FlutterFlowTheme.of(context).accent3
                                                                                    : FlutterFlowTheme.of(context).primaryText,
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                              ),
                                                                              size: 24.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ].divide(SizedBox(
                                                        height: isCompact
                                                            ? 16.0
                                                            : 32.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ].divide(SizedBox(
                                      height: isCompact ? 16.0 : 24.0)),
                                ),
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
          ),
        );
      },
    );
  }
}
