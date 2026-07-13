import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/components/empty_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pg_rebanho/modal_more/modal_more_widget.dart';
import '/pg_rebanho/pesagem_rebanho_sync.dart';
import '/pg_rebanho/pp_add_pessagem/pp_add_pessagem_widget.dart';
import '/reproducao/modal_more_reproducao/modal_more_reproducao_widget.dart';
import '/reproducao/reproducao_status_utils.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pg_rebanho_view_model.dart';
export 'pg_rebanho_view_model.dart';

/// Data de referência para ordenação e cálculos: IA usa [ReproducaoRow.dataInseminacao];
/// monta natural usa [ReproducaoRow.dataInicial] (com fallback à IA).
DateTime? _dataReferenciaReproducao(ReproducaoRow r) {
  if (r.tipoReproducao == 'Inseminação') {
    return r.dataInseminacao;
  }
  return r.dataInicial ?? r.dataInseminacao;
}

/// Mesma regra da lista global de Reprodução: data única para IA; intervalo inicial–final para monta.
String _textoDataReproducaoFichaAnimal(BuildContext context, ReproducaoRow r) {
  final locale = FFLocalizations.of(context).languageCode;
  if (r.tipoReproducao == 'Inseminação') {
    return valueOrDefault<String>(
      dateTimeFormat(
        'd/M/y',
        r.dataInseminacao,
        locale: locale,
      ),
      'S/D',
    );
  }
  return valueOrDefault<String>(
    '${valueOrDefault<String>(
      dateTimeFormat(
        'd/M/y',
        r.dataInicial,
        locale: locale,
      ),
      'S/D',
    )} - ${valueOrDefault<String>(
      dateTimeFormat(
        'd/M/y',
        r.dataFinal,
        locale: locale,
      ),
      'S/D',
    )}',
    'S/D',
  );
}

/// Índices alinhados às [DataColumn2] da tabela de reproduções na ficha do animal.
List<ReproducaoRow> _sortReproducoesFichaAnimal(
  List<ReproducaoRow> source,
  int columnIndex,
  bool ascending,
) {
  final copy = List<ReproducaoRow>.from(source);
  int dir(int c) => ascending ? c : -c;

  int compare(ReproducaoRow a, ReproducaoRow b) {
    switch (columnIndex) {
      case 0:
        return dir(
          (a.tipoReproducao ?? '')
              .toLowerCase()
              .compareTo((b.tipoReproducao ?? '').toLowerCase()),
        );
      case 1:
        final da = _dataReferenciaReproducao(a);
        final db = _dataReferenciaReproducao(b);
        if (da == null && db == null) {
          return dir(a.createdAt.compareTo(b.createdAt));
        }
        if (da == null) return dir(1);
        if (db == null) return dir(-1);
        return dir(da.compareTo(db));
      case 2:
        return dir(
          (a.statusReproducao ?? '').compareTo(b.statusReproducao ?? ''),
        );
      case 5:
        final refA = _dataReferenciaReproducao(a);
        final refB = _dataReferenciaReproducao(b);
        final hasA = refA != null && a.dataParto != null;
        final hasB = refB != null && b.dataParto != null;
        if (!hasA && !hasB) return 0;
        if (!hasA) return dir(1);
        if (!hasB) return dir(-1);
        final ia = functions.diasEntreDatas(refA, a.dataParto!);
        final ib = functions.diasEntreDatas(refB, b.dataParto!);
        return dir(ia.compareTo(ib));
      default:
        return 0;
    }
  }

  copy.sort(compare);
  return copy;
}

class _GmdEvolutionPoint {
  const _GmdEvolutionPoint({
    required this.current,
    required this.previous,
    required this.diasAvaliados,
    required this.gmd,
  });

  final HistoricoPesagensRow current;
  final HistoricoPesagensRow previous;
  final int diasAvaliados;
  final double? gmd;

  bool get calculavel => gmd != null;
}

/// Custom dot painter for GMD line: draws a colored circle with the GMD value
/// label rendered in white text centered inside.
class _GmdLabelDotPainter extends FlDotPainter {
  const _GmdLabelDotPainter({
    required this.value,
    required this.color,
    this.radius = 13.0,
  });

  final double value;
  final Color color;
  final double radius;

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    canvas.drawCircle(
      offsetInCanvas,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      offsetInCanvas,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final text = value.toStringAsFixed(2).replaceAll('.', ',');
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      offsetInCanvas - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  Size getSize(FlSpot spot) => Size(radius * 2, radius * 2);

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is! _GmdLabelDotPainter || b is! _GmdLabelDotPainter) return b;
    return _GmdLabelDotPainter(
      value: ui.lerpDouble(a.value, b.value, t)!,
      color: Color.lerp(a.color, b.color, t)!,
      radius: ui.lerpDouble(a.radius, b.radius, t)!,
    );
  }

  @override
  Color get mainColor => color;

  @override
  List<Object?> get props => [value, color, radius];
}

class PgRebanhoViewWidget extends StatefulWidget {
  const PgRebanhoViewWidget({
    super.key,
    required this.idRebanho,
  });

  final String? idRebanho;

  static String routeName = 'pgRebanhoView';
  static String routePath = '/viewrebanho';

  @override
  State<PgRebanhoViewWidget> createState() => _PgRebanhoViewWidgetState();
}

class _PgRebanhoViewWidgetState extends State<PgRebanhoViewWidget>
    with TickerProviderStateMixin {
  late PgRebanhoViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<RebanhoRow>>? _rebanhoFuture;
  String? _rebanhoFutureKey;
  Future<HistoricoPesagensRow?>? _desmamaPesagemFuture;
  String? _desmamaPesagemFutureKey;
  Future<List<ReproducaoRow>>? _reproducoesMatrizFuture;
  String? _reproducoesMatrizFutureKey;
  Future<List<ReproducaoRow>>? _reproducoesReprodutorFuture;
  String? _reproducoesReprodutorFutureKey;
  Future<List<SanidadeRow>>? _sanidadesFuture;
  String? _sanidadesFutureKey;
  VoidCallback? _disposeReproducaoRefreshListener;
  VoidCallback? _disposeSanidadeRefreshListener;

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _pesagemAtiva(HistoricoPesagensRow pesagem) =>
      pesagem.deletado?.trim().toUpperCase() != 'SIM';

  Future<List<HistoricoPesagensRow>> _loadPesagensAtivas(
    String? idRebanho,
  ) {
    final idRebanhoNormalizado = idRebanho?.trim();
    if (idRebanhoNormalizado == null || idRebanhoNormalizado.isEmpty) {
      return Future.value([]);
    }

    return HistoricoPesagensTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('idRebanho', idRebanhoNormalizado)
          .or('deletado.is.null,deletado.neq.SIM')
          .order('dataPesagem')
          .order('id'),
    );
  }

  Future<void> _marcarPesagemComoDeletada(
    HistoricoPesagensRow pesagem,
  ) async {
    await HistoricoPesagensTable().update(
      data: {
        'deletado': 'SIM',
      },
      matchingRows: (rows) => rows.eqOrNull('id', pesagem.id),
    );
  }

  Future<HistoricoPesagensRow?> _syncPesoAtualAposPesagem({
    required int? rebanhoId,
    required String? idRebanho,
  }) async {
    return sincronizarUltimaPesagemRebanho(
      rebanhoId: rebanhoId,
      idRebanho: idRebanho,
      sincronizarPesoAtual: true,
    );
  }

  Future<HistoricoPesagensRow?> _loadDesmamaPesagem(String? idRebanho) async {
    if (idRebanho == null || idRebanho.trim().isEmpty) {
      return null;
    }

    final pesagens = await HistoricoPesagensTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('idRebanho', idRebanho)
          .eqOrNull('tipo', 'Desmama')
          .order('dataPesagem', ascending: false)
          .order('id', ascending: false),
      limit: 20,
    );

    return pesagens.where(_pesagemAtiva).firstOrNull;
  }

  String _futureKey(List<String?> values) =>
      values.map((value) => value?.trim() ?? '').join('|');

  Future<List<RebanhoRow>> _getRebanhoFuture() {
    final key = widget.idRebanho?.trim() ?? '';
    if (_rebanhoFuture == null || _rebanhoFutureKey != key) {
      _rebanhoFutureKey = key;
      _rebanhoFuture = _createRebanhoFuture();
    }
    return _rebanhoFuture!;
  }

  Future<HistoricoPesagensRow?> _getDesmamaPesagemFuture(String? idRebanho) {
    final key = idRebanho?.trim() ?? '';
    if (_desmamaPesagemFuture == null || _desmamaPesagemFutureKey != key) {
      _desmamaPesagemFutureKey = key;
      _desmamaPesagemFuture = _loadDesmamaPesagem(idRebanho);
    }
    return _desmamaPesagemFuture!;
  }

  Future<List<ReproducaoRow>> _loadReproducoesMatriz(
    String? idRebanho,
    String? idPropriedade,
  ) {
    final rebanho = idRebanho?.trim();
    final propriedade = idPropriedade?.trim();
    if (rebanho == null ||
        rebanho.isEmpty ||
        propriedade == null ||
        propriedade.isEmpty) {
      return Future.value([]);
    }

    return ReproducaoTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
            'id_rebanho_matriz',
            rebanho,
          )
          .eqOrNull(
            'id_propriedade',
            propriedade,
          ),
    );
  }

  Future<List<ReproducaoRow>> _getReproducoesMatrizFuture({
    required String? idRebanho,
    required String? idPropriedade,
  }) {
    final key = _futureKey([idRebanho, idPropriedade]);
    if (_reproducoesMatrizFuture == null ||
        _reproducoesMatrizFutureKey != key) {
      _reproducoesMatrizFutureKey = key;
      _reproducoesMatrizFuture = _loadReproducoesMatriz(
        idRebanho,
        idPropriedade,
      );
    }
    return _reproducoesMatrizFuture!;
  }

  Future<List<ReproducaoRow>> _loadReproducoesReprodutor(
    String? idRebanho,
    String? idPropriedade,
  ) {
    final rebanho = idRebanho?.trim();
    final propriedade = idPropriedade?.trim();
    if (rebanho == null ||
        rebanho.isEmpty ||
        propriedade == null ||
        propriedade.isEmpty) {
      return Future.value([]);
    }

    return ReproducaoTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
            'id_rebanho_reprodutor',
            rebanho,
          )
          .eqOrNull(
            'id_propriedade',
            propriedade,
          ),
    );
  }

  Future<List<ReproducaoRow>> _getReproducoesReprodutorFuture({
    required String? idRebanho,
    required String? idPropriedade,
  }) {
    final key = _futureKey([idRebanho, idPropriedade]);
    if (_reproducoesReprodutorFuture == null ||
        _reproducoesReprodutorFutureKey != key) {
      _reproducoesReprodutorFutureKey = key;
      _reproducoesReprodutorFuture = _loadReproducoesReprodutor(
        idRebanho,
        idPropriedade,
      );
    }
    return _reproducoesReprodutorFuture!;
  }

  Future<List<SanidadeRow>> _loadSanidades(
    String? idRebanho,
    String? idPropriedade,
  ) {
    final rebanho = idRebanho?.trim();
    final propriedade = idPropriedade?.trim();
    if (rebanho == null ||
        rebanho.isEmpty ||
        propriedade == null ||
        propriedade.isEmpty) {
      return Future.value([]);
    }

    return SanidadeTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
            'id_rebanho',
            rebanho,
          )
          .eqOrNull(
            'id_propriedade',
            propriedade,
          )
          .eqOrNull(
            'deletado',
            'NAO',
          ),
    );
  }

  Future<List<SanidadeRow>> _getSanidadesFuture({
    required String? idRebanho,
    required String? idPropriedade,
  }) {
    final key = _futureKey([idRebanho, idPropriedade]);
    if (_sanidadesFuture == null || _sanidadesFutureKey != key) {
      _sanidadesFutureKey = key;
      _sanidadesFuture = _loadSanidades(
        idRebanho,
        idPropriedade,
      );
    }
    return _sanidadesFuture!;
  }

  void _resetRebanhoCache() {
    _rebanhoFuture = null;
    _rebanhoFutureKey = null;
    _desmamaPesagemFuture = null;
    _desmamaPesagemFutureKey = null;
  }

  void _resetReproducoesCache() {
    _reproducoesMatrizFuture = null;
    _reproducoesMatrizFutureKey = null;
    _reproducoesReprodutorFuture = null;
    _reproducoesReprodutorFutureKey = null;
  }

  void _resetSanidadesCache() {
    _sanidadesFuture = null;
    _sanidadesFutureKey = null;
  }

  String _formatKg(double? value) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} kg';
  }

  String _formatSignedKgDia(double? value) {
    if (value == null) return '-';
    final prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(3).replaceAll('.', ',')} kg/d';
  }

  String _formatGmdDate(DateTime? value) {
    if (value == null) return 'Selecionar';
    return dateTimeFormat(
      'd/M/y',
      value,
      locale: FFLocalizations.of(context).languageCode,
    );
  }

  String _formatPesagemDate(DateTime? value) {
    if (value == null) return '-';
    return dateTimeFormat(
      'd/M/y',
      value,
      locale: FFLocalizations.of(context).languageCode,
    );
  }

  List<_GmdEvolutionPoint> _buildGmdEvolution(
      List<HistoricoPesagensRow> pesagens) {
    final validas = pesagens
        .where((p) => p.dataPesagem != null && p.peso != null)
        .toList()
      ..sort((a, b) => a.dataPesagem!.compareTo(b.dataPesagem!));

    final pontos = <_GmdEvolutionPoint>[];
    for (var index = 1; index < validas.length; index++) {
      final previous = validas[index - 1];
      final current = validas[index];
      final diasAvaliados = _dateOnly(current.dataPesagem!)
          .difference(_dateOnly(previous.dataPesagem!))
          .inDays;
      final gmd = diasAvaliados > 0
          ? (current.peso! - previous.peso!) / diasAvaliados
          : null;
      pontos.add(
        _GmdEvolutionPoint(
          current: current,
          previous: previous,
          diasAvaliados: diasAvaliados,
          gmd: gmd,
        ),
      );
    }

    return pontos;
  }

  Map<int, _GmdEvolutionPoint> _buildGmdByPesagemId(
    List<_GmdEvolutionPoint> pontos,
  ) =>
      {
        for (final ponto in pontos) ponto.current.id: ponto,
      };

  List<_GmdEvolutionPoint> _filterGmdChartPoints(
    List<_GmdEvolutionPoint> pontos,
  ) {
    if (pontos.isEmpty) return const [];

    final dataInicial = _dateOnly(
      _model.gmdDataInicial ?? pontos.first.current.dataPesagem!,
    );
    final dataFinal = _dateOnly(
      _model.gmdDataFinal ?? pontos.last.current.dataPesagem!,
    );

    if (dataFinal.isBefore(dataInicial)) return const [];

    return pontos.where((ponto) {
      final data = _dateOnly(ponto.current.dataPesagem!);
      return !data.isBefore(dataInicial) && !data.isAfter(dataFinal);
    }).toList();
  }

  Color _gmdColor(double? value) {
    if (value == null || value == 0) {
      return FlutterFlowTheme.of(context).secondaryText;
    }
    return value > 0
        ? FlutterFlowTheme.of(context).success
        : FlutterFlowTheme.of(context).error;
  }

  Future<void> _pickGmdDate({
    required bool isStart,
    required List<HistoricoPesagensRow> pesagens,
  }) async {
    final datas = pesagens
        .where((p) => p.dataPesagem != null)
        .map((p) => _dateOnly(p.dataPesagem!))
        .toList()
      ..sort();

    final fallback = datas.isNotEmpty ? datas.first : getCurrentTimestamp;
    final current = isStart ? _model.gmdDataInicial : _model.gmdDataFinal;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current ?? (isStart ? fallback : (datas.lastOrNull ?? fallback)),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return wrapInMaterialDatePickerTheme(
          context,
          child!,
          headerBackgroundColor: FlutterFlowTheme.of(context).primary,
          headerForegroundColor: FlutterFlowTheme.of(context).info,
          headerTextStyle: FlutterFlowTheme.of(context).headlineLarge.override(
                font: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineLarge.fontStyle,
                ),
                fontSize: 32.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).headlineLarge.fontStyle,
              ),
          pickerBackgroundColor:
              FlutterFlowTheme.of(context).secondaryBackground,
          pickerForegroundColor: FlutterFlowTheme.of(context).primaryText,
          selectedDateTimeBackgroundColor: FlutterFlowTheme.of(context).primary,
          selectedDateTimeForegroundColor: FlutterFlowTheme.of(context).info,
          actionButtonForegroundColor: FlutterFlowTheme.of(context).primaryText,
          iconSize: 24.0,
        );
      },
    );

    if (picked == null) return;
    safeSetState(() {
      if (isStart) {
        _model.gmdDataInicial = _dateOnly(picked);
      } else {
        _model.gmdDataFinal = _dateOnly(picked);
      }
    });
  }

  Widget _buildGmdDateFilter({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180.0, maxWidth: 260.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).customColor2,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).labelSmall,
                    ),
                    Text(
                      _formatGmdDate(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
            ].divide(const SizedBox(width: 8.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildGmdTableValue(_GmdEvolutionPoint? ponto) {
    if (ponto?.gmd == null) {
      return Text(
        '-',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
      );
    }

    final color = _gmdColor(ponto!.gmd);
    return Tooltip(
      message:
          '${_formatKg(ponto.previous.peso)} → ${_formatKg(ponto.current.peso)} em ${ponto.diasAvaliados} dias',
      child: Text(
        _formatSignedKgDia(ponto.gmd),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: color,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
      ),
    );
  }

  Widget _buildGmdInfoMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).customColor2,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).customColor5,
        ),
      ),
      child: Text(
        message,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).primaryText,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
      ),
    );
  }

  Widget _buildGmdLegendItem({
    required Color color,
    required String label,
    bool isLine = false,
  }) {
    Widget indicator;
    if (isLine) {
      indicator = SizedBox(
        width: 28.0,
        height: 14.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(height: 2.0, color: color),
            CircleAvatar(radius: 5.0, backgroundColor: color),
          ],
        ),
      );
    } else {
      indicator = Container(
        width: 12.0,
        height: 12.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3.0),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        Text(
          label,
          style: FlutterFlowTheme.of(context).labelMedium,
        ),
      ].divide(const SizedBox(width: 6.0)),
    );
  }

  // ── Combo chart: bars (peso) + line (GMD) ─────────────────────────────────
  // Both charts share the same SizedBox with identical axis reserved sizes so
  // their chart areas are perfectly aligned. BarChart handles the right axis
  // (peso in kg) and bottom axis (dates). LineChart handles the left axis (GMD)
  // and is rendered transparent on top.
  Widget _buildGmdComboChart(List<_GmdEvolutionPoint> pontos) {
    // All pesagens: first "previous" + each "current"
    final allPesagens = <HistoricoPesagensRow>[
      pontos.first.previous,
      ...pontos.map((p) => p.current),
    ];
    final n = allPesagens.length;

    // Peso scale (bar chart, right axis)
    final maxPesoRaw =
        allPesagens.map((p) => p.peso!).reduce((a, b) => a > b ? a : b);
    final maxPesoBar = maxPesoRaw * 1.3; // extra room for "XXX kg" labels

    // GMD scale (line chart, left axis)
    final gmdValues = pontos.map((p) => p.gmd!).toList();
    final minGmd = gmdValues.reduce((a, b) => a < b ? a : b);
    final maxGmd = gmdValues.reduce((a, b) => a > b ? a : b);
    var minY = minGmd < 0 ? minGmd * 1.5 : -0.15;
    var maxY = maxGmd > 0 ? maxGmd * 1.4 : 0.5;
    if (minY >= maxY) {
      minY = -0.5;
      maxY = 1.0;
    }

    // These MUST be identical in both charts so their chart areas align.
    const leftReserved = 52.0;
    const rightReserved = 54.0;
    const bottomReserved = 62.0;

    final labelStyle = FlutterFlowTheme.of(context).labelSmall.override(
          font: GoogleFonts.poppins(
            fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
          ),
          color: FlutterFlowTheme.of(context).secondaryText,
          letterSpacing: 0.0,
          fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
        );
    final primaryColor = FlutterFlowTheme.of(context).primary;
    final barColor = primaryColor.withValues(alpha: 0.8);
    final locale = FFLocalizations.of(context).languageCode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth =
            ((constraints.maxWidth - leftReserved - rightReserved) / n * 0.5)
                .clamp(14.0, 48.0);
        final minChartWidth = n * 90.0 + leftReserved + rightReserved;
        final chartWidth = minChartWidth > constraints.maxWidth
            ? minChartWidth
            : constraints.maxWidth;

        // Bar groups — showingTooltipIndicators: [0] makes the "XXX kg" label
        // always visible above each bar (rendered with transparent background).
        final barGroups = allPesagens.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.peso!.toDouble(),
                color: barColor,
                width: barWidth,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4.0)),
              ),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList();

        // GMD spots start at x=1 so they align with allPesagens[1..n-1]
        // (allPesagens[0] is the first "previous" which has no GMD value).
        final gmdSpots = pontos
            .asMap()
            .entries
            .map((e) => FlSpot((e.key + 1).toDouble(), e.value.gmd!))
            .toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 340.0,
            child: Stack(
              children: [
                // ── Bar chart (peso, right axis) ──────────────────────────
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    minY: 0,
                    maxY: maxPesoBar,
                    barGroups: barGroups,
                    barTouchData: BarTouchData(
                      enabled: false,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 6.0,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} kg',
                            GoogleFonts.poppins(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: leftReserved,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: rightReserved,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: 6.0),
                              child: Text(
                                '${value.toInt()}',
                                style: labelStyle.copyWith(color: primaryColor),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: bottomReserved,
                          getTitlesWidget: (value, meta) {
                            final idx = value.round();
                            if (idx < 0 || idx >= n) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Transform.rotate(
                                angle: -0.55,
                                child: Text(
                                  dateTimeFormat(
                                    'd/M/y',
                                    allPesagens[idx].dataPesagem,
                                    locale: locale,
                                  ),
                                  style: labelStyle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: FlutterFlowTheme.of(context).customColor5,
                        strokeWidth: 1.0,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(
                          color: FlutterFlowTheme.of(context).customColor5,
                        ),
                        bottom: BorderSide(
                          color: FlutterFlowTheme.of(context).customColor5,
                        ),
                        right: BorderSide(
                          color: FlutterFlowTheme.of(context).customColor5,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Line chart (GMD, left axis) ────────────────────────────
                // Transparent background + no border so only the line/axis show.
                // minX/maxX match BarChartAlignment.spaceAround positioning:
                //   bar i center = (2i+1)/(2n) * width  ↔  LineChart x=i
                //   with minX=-0.5, maxX=n-0.5.
                LineChart(
                  LineChartData(
                    minX: -0.5,
                    maxX: n - 0.5,
                    minY: minY,
                    maxY: maxY,
                    backgroundColor: Colors.transparent,
                    lineBarsData: [
                      LineChartBarData(
                        spots: gmdSpots,
                        isCurved: true,
                        curveSmoothness: 0.2,
                        color: FlutterFlowTheme.of(context).success,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        preventCurveOverShooting: true,
                        belowBarData: BarAreaData(show: false),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final gmd = gmdSpots[index].y;
                            return _GmdLabelDotPainter(
                              value: gmd,
                              color: _gmdColor(gmd),
                            );
                          },
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        maxContentWidth: 160.0,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        getTooltipColor: (_) => FlutterFlowTheme.of(context)
                            .primaryText
                            .withValues(alpha: 0.92),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            // gmdSpots[i] is at x = i + 1 → ponto index = x - 1
                            final index = spot.x.toInt() - 1;
                            if (index < 0 || index >= pontos.length) {
                              return null;
                            }
                            final ponto = pontos[index];
                            final data = dateTimeFormat(
                              'd/M/y',
                              ponto.current.dataPesagem,
                              locale: locale,
                            );
                            return LineTooltipItem(
                              '$data\nGMD: ${_formatSignedKgDia(ponto.gmd)}\nPeso: ${_formatKg(ponto.current.peso)}\n${ponto.diasAvaliados} dias',
                              GoogleFonts.poppins(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: leftReserved,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: Text(
                                value.toStringAsFixed(2).replaceAll('.', ','),
                                style: labelStyle,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: rightReserved,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: bottomReserved,
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 0.0,
                          color: FlutterFlowTheme.of(context)
                              .secondaryText
                              .withValues(alpha: 0.5),
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                        ),
                      ],
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGmdStatCard({
    required Widget icon,
    required String label,
    required String value,
    required Color valueColor,
    String? subValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).customColor2,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).customColor5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: FlutterFlowTheme.of(context).labelSmall,
              ),
              Text(
                value,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: valueColor,
                      fontSize: 15.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subValue != null)
                Text(subValue, style: FlutterFlowTheme.of(context).labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGmdSummary(List<_GmdEvolutionPoint> pontos) {
    final gmdVals =
        pontos.where((p) => p.gmd != null).map((p) => p.gmd!).toList();
    final gmdMedio = gmdVals.isEmpty
        ? null
        : gmdVals.reduce((a, b) => a + b) / gmdVals.length;

    final firstPesagem = pontos.first.previous;
    final lastPesagem = pontos.last.current;
    final pesoInicial = firstPesagem.peso;
    final pesoAtual = lastPesagem.peso;
    final variacaoPeso = (pesoAtual != null && pesoInicial != null)
        ? pesoAtual - pesoInicial
        : null;

    final locale = FFLocalizations.of(context).languageCode;
    String fmtDate(DateTime? d) =>
        d == null ? '-' : dateTimeFormat('d/M/y', d, locale: locale);
    String fmtPeso(double? v) => v == null ? '-' : '${v.toStringAsFixed(0)} kg';
    String fmtGmd(double? v) {
      if (v == null) return '-';
      final prefix = v > 0 ? '+' : '';
      return '$prefix${v.toStringAsFixed(2).replaceAll('.', ',')} kg/d';
    }

    final primaryColor = FlutterFlowTheme.of(context).primary;
    final successColor = FlutterFlowTheme.of(context).success;
    final errorColor = FlutterFlowTheme.of(context).error;
    final secondaryText = FlutterFlowTheme.of(context).secondaryText;

    Color colorFor(double? v) {
      if (v == null) return secondaryText;
      if (v > 0) return successColor;
      if (v < 0) return errorColor;
      return secondaryText;
    }

    final gmdColor = colorFor(gmdMedio);
    final varColor = colorFor(variacaoPeso);

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        _buildGmdStatCard(
          icon: Icon(Icons.show_chart, color: gmdColor, size: 26.0),
          label: 'GMD médio geral',
          value: fmtGmd(gmdMedio),
          valueColor: gmdColor,
        ),
        _buildGmdStatCard(
          icon: Icon(Icons.monitor_weight_outlined,
              color: primaryColor, size: 26.0),
          label: 'Peso inicial',
          value: fmtPeso(pesoInicial),
          valueColor: primaryColor,
          subValue: fmtDate(firstPesagem.dataPesagem),
        ),
        _buildGmdStatCard(
          icon: Icon(Icons.monitor_weight, color: primaryColor, size: 26.0),
          label: 'Peso atual',
          value: fmtPeso(pesoAtual),
          valueColor: primaryColor,
          subValue: fmtDate(lastPesagem.dataPesagem),
        ),
        _buildGmdStatCard(
          icon: Icon(
            variacaoPeso != null && variacaoPeso < 0
                ? Icons.trending_down
                : Icons.trending_up,
            color: varColor,
            size: 26.0,
          ),
          label: 'Variação de peso',
          value: variacaoPeso != null
              ? '${variacaoPeso > 0 ? '+' : ''}${variacaoPeso.toStringAsFixed(0)} kg'
              : '-',
          valueColor: varColor,
          subValue:
              '(${fmtDate(firstPesagem.dataPesagem)} a ${fmtDate(lastPesagem.dataPesagem)})',
        ),
      ],
    );
  }

  Widget _buildGmdCard(List<HistoricoPesagensRow> pesagens) {
    final pontos = _buildGmdEvolution(pesagens);
    final dataInicial = pontos.isNotEmpty
        ? _dateOnly(_model.gmdDataInicial ?? pontos.first.current.dataPesagem!)
        : null;
    final dataFinal = pontos.isNotEmpty
        ? _dateOnly(_model.gmdDataFinal ?? pontos.last.current.dataPesagem!)
        : null;
    final periodoInvalido = dataInicial != null &&
        dataFinal != null &&
        dataFinal.isBefore(dataInicial);
    final pontosFiltrados = periodoInvalido
        ? <_GmdEvolutionPoint>[]
        : _filterGmdChartPoints(pontos)
            .where((ponto) => ponto.calculavel)
            .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).customColor5,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evolução do GMD e do peso',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  fontSize: 18.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Acompanhe o ganho médio diário (GMD) e a evolução do peso nas pesagens realizadas.',
            style: FlutterFlowTheme.of(context).labelMedium,
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildGmdDateFilter(
                label: 'Data inicial',
                value: dataInicial,
                onTap: () => _pickGmdDate(isStart: true, pesagens: pesagens),
              ),
              _buildGmdDateFilter(
                label: 'Data final',
                value: dataFinal,
                onTap: () => _pickGmdDate(isStart: false, pesagens: pesagens),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _buildGmdLegendItem(
                color: FlutterFlowTheme.of(context).success,
                label: 'GMD (kg/d)',
                isLine: true,
              ),
              _buildGmdLegendItem(
                color: FlutterFlowTheme.of(context).primary,
                label: 'Peso (kg)',
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (pontos.isEmpty)
            _buildGmdInfoMessage(
              'É necessário ter pelo menos duas pesagens com data e peso para montar a evolução do GMD.',
            )
          else if (periodoInvalido)
            _buildGmdInfoMessage(
              'A data final deve ser igual ou posterior à data inicial.',
            )
          else if (pontosFiltrados.isEmpty)
            _buildGmdInfoMessage(
              'Não há pontos de GMD calculáveis no período selecionado.',
            )
          else ...[
            _buildGmdComboChart(pontosFiltrados),
            const SizedBox(height: 16.0),
            _buildGmdSummary(pontosFiltrados),
          ],
        ],
      ),
    );
  }

  void _resetPesagensCache() {
    _model.requestCompleter = null;
    _resetRebanhoCache();
    _model.dataDesmamaTextController2?.dispose();
    _model.dataDesmamaTextController2 = null;
    _model.pesoDesmamaTextController2?.dispose();
    _model.pesoDesmamaTextController2 = null;
  }

  Future<void> _recarregarPesagens({
    String? idRebanho,
  }) async {
    safeSetState(_resetPesagensCache);
    final idRebanhoNormalizado = idRebanho?.trim();
    if (idRebanhoNormalizado != null && idRebanhoNormalizado.isNotEmpty) {
      final rebanhoAtualizado = await RebanhoTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('idRebanho', idRebanhoNormalizado),
      );
      final row = rebanhoAtualizado.firstOrNull;
      if (row != null && mounted) {
        _model.dataDesmamaTextController2 ??= TextEditingController();
        _model.dataDesmamaTextController2!.text = valueOrDefault<String>(
          dateTimeFormat(
            "d/M/y",
            row.dataUltimaPesagem,
            locale: FFLocalizations.of(context).languageCode,
          ),
          'N/A',
        );
        _model.pesoDesmamaTextController2 ??= TextEditingController();
        _model.pesoDesmamaTextController2!.text = valueOrDefault<String>(
          row.pesoAtual?.toString(),
          'N/A',
        );
      }
    }
    await _model.waitForRequestCompleted();
    if (mounted) {
      safeSetState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgRebanhoViewModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.disposeRefreshListener =
          FFAppState().onRefresh('refreshPesagem', () {
        FFAppState().refreshPesagem = false;
        safeSetState(_resetPesagensCache);
      });
      _disposeReproducaoRefreshListener =
          FFAppState().onRefresh('refreshReproducao', () {
        FFAppState().refreshReproducao = false;
        safeSetState(_resetReproducoesCache);
      });
      _disposeSanidadeRefreshListener =
          FFAppState().onRefresh('refreshSanidade', () {
        FFAppState().refreshSanidade = false;
        safeSetState(_resetSanidadesCache);
      });
    });

    _model.tabBarController = TabController(
      vsync: this,
      length: 5,
      initialIndex: 0,
    );

    _model.nomeAnimalFocusNode1 ??= FocusNode();

    _model.chipFocusNode ??= FocusNode();

    _model.codRegistroFocusNode ??= FocusNode();

    _model.nomeAnimalFocusNode2 ??= FocusNode();

    _model.sexoFocusNode ??= FocusNode();

    _model.pesoNascimentoFocusNode1 ??= FocusNode();

    _model.pesoNascimentoFocusNode2 ??= FocusNode();

    _model.porteFocusNode1 ??= FocusNode();

    _model.categoriaFocusNode ??= FocusNode();

    _model.racaFocusNode ??= FocusNode();

    _model.porteFocusNode2 ??= FocusNode();

    _model.porteFocusNode3 ??= FocusNode();

    _model.matrizFocusNode ??= FocusNode();

    _model.reprodutorFocusNode ??= FocusNode();

    _model.dataDesmamaFocusNode1 ??= FocusNode();

    _model.pesoDesmamaFocusNode1 ??= FocusNode();

    _model.dataDesmamaFocusNode2 ??= FocusNode();

    _model.pesoDesmamaFocusNode2 ??= FocusNode();

    _model.dataDesmamaFocusNode3 ??= FocusNode();

    _model.pesoDesmamaFocusNode3 ??= FocusNode();

    _model.dataDesmamaFocusNode4 ??= FocusNode();

    _model.pesoDesmamaFocusNode4 ??= FocusNode();

    _model.anotacoesFocusNode ??= FocusNode();

    _model.dataCompraViewFocusNode ??= FocusNode();

    _model.valorCompraViewFocusNode ??= FocusNode();

    _model.dataVendaViewFocusNode ??= FocusNode();

    _model.valorVendaViewFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _disposeReproducaoRefreshListener?.call();
    _disposeSanidadeRefreshListener?.call();
    _model.dispose();

    super.dispose();
  }

  Future<List<RebanhoRow>> _createRebanhoFuture() async {
    final rows = await RebanhoTable().querySingleRow(
      queryFn: (q) => q.eqOrNull(
        'idRebanho',
        widget.idRebanho,
      ),
    );
    final row = rows.firstOrNull;
    if (row == null) {
      return rows;
    }

    await sincronizarUltimaPesagemRebanho(
      rebanhoId: row.id,
      idRebanho: row.idRebanho,
    );

    return RebanhoTable().querySingleRow(
      queryFn: (q) => q.eqOrNull(
        'idRebanho',
        widget.idRebanho,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RebanhoRow>>(
      future: _getRebanhoFuture(),
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
        List<RebanhoRow> pgRebanhoViewRebanhoRowList = snapshot.data!;

        final pgRebanhoViewRebanhoRow = pgRebanhoViewRebanhoRowList.isNotEmpty
            ? pgRebanhoViewRebanhoRowList.first
            : null;

        return FutureBuilder<HistoricoPesagensRow?>(
          future: _getDesmamaPesagemFuture(pgRebanhoViewRebanhoRow?.idRebanho),
          builder: (context, desmamaSnapshot) {
            if (desmamaSnapshot.connectionState == ConnectionState.waiting) {
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

            final effectiveDataDesmamaView =
                pgRebanhoViewRebanhoRow?.dataDesmama;
            final effectivePesoDesmamaView =
                pgRebanhoViewRebanhoRow?.pesoDesmama;

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
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
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
                                child: Align(
                                  alignment:
                                      const AlignmentDirectional(0.0, -1.0),
                                  child: Container(
                                    width: 1100.0,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Animal',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      color: const Color(
                                                          0xFF8E8E8E),
                                                      fontSize: 18.0,
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
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Text(
                                                        '${valueOrDefault<String>(
                                                          pgRebanhoViewRebanhoRow
                                                              ?.numeroAnimal,
                                                          'N/A',
                                                        )} • ${valueOrDefault<String>(
                                                              pgRebanhoViewRebanhoRow
                                                                  ?.nome,
                                                              'Sem nome',
                                                            ) == 'null' ? 'Sem nome' : valueOrDefault<String>(
                                                            pgRebanhoViewRebanhoRow
                                                                ?.nome,
                                                            'Sem nome',
                                                          )}',
                                                        style: FlutterFlowTheme
                                                                .of(context)
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
                                                              fontSize: 40.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                      ),
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          pgRebanhoViewRebanhoRow
                                                                      ?.sexo ==
                                                                  'Macho'
                                                              ? 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/4cg1mjibvkyf/Sexomacho.png'
                                                              : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/25fnoszaf5de/Sexofemea.png',
                                                          width: 32.0,
                                                          height: 32.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ].divide(const SizedBox(
                                                        width: 8.0)),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        const AlignmentDirectional(
                                                            1.0, 0.0),
                                                    child: Builder(
                                                      builder: (context) =>
                                                          FFButtonWidget(
                                                        onPressed: () async {
                                                          final pesagemAdicionada =
                                                              await showDialog<
                                                                  bool>(
                                                            context: context,
                                                            builder:
                                                                (dialogContext) {
                                                              return Dialog(
                                                                elevation: 0,
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                alignment: const AlignmentDirectional(
                                                                        0.0,
                                                                        0.0)
                                                                    .resolve(
                                                                        Directionality.of(
                                                                            context)),
                                                                child:
                                                                    GestureDetector(
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
                                                                      PpAddPessagemWidget(
                                                                    rebanhoId:
                                                                        pgRebanhoViewRebanhoRow!
                                                                            .id,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                          if (pesagemAdicionada ==
                                                              true) {
                                                            await _syncPesoAtualAposPesagem(
                                                              rebanhoId:
                                                                  pgRebanhoViewRebanhoRow
                                                                      ?.id,
                                                              idRebanho:
                                                                  pgRebanhoViewRebanhoRow
                                                                      ?.idRebanho,
                                                            );
                                                            await _recarregarPesagens(
                                                              idRebanho:
                                                                  pgRebanhoViewRebanhoRow
                                                                      ?.idRebanho,
                                                            );
                                                          }
                                                        },
                                                        text:
                                                            'Adicionar pesagem',
                                                        icon: const Icon(
                                                          Icons.add,
                                                          size: 24.0,
                                                        ),
                                                        options:
                                                            FFButtonOptions(
                                                          height: 56.0,
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  16.0,
                                                                  0.0,
                                                                  16.0,
                                                                  0.0),
                                                          iconPadding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          textStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .poppins(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleSmall
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .titleSmall
                                                                        .fontStyle,
                                                                  ),
                                                          elevation: 0.0,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ].divide(
                                                    const SizedBox(width: 8.0)),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      const Alignment(0.0, 0),
                                                  child: TabBar(
                                                    labelColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                    unselectedLabelColor:
                                                        const Color(0xFF8E8E8E),
                                                    labelStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                          ),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleMedium
                                                                  .fontStyle,
                                                        ),
                                                    unselectedLabelStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleMedium
                                                                    .fontStyle,
                                                              ),
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleMedium
                                                                      .fontStyle,
                                                            ),
                                                    indicatorColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    tabs: const [
                                                      Tab(
                                                        text: 'Informações',
                                                      ),
                                                      Tab(
                                                        text: 'Crias',
                                                      ),
                                                      Tab(
                                                        text: 'Pesagens',
                                                      ),
                                                      Tab(
                                                        text: 'Reproduções',
                                                      ),
                                                      Tab(
                                                        text: 'Sanidade',
                                                      ),
                                                    ],
                                                    controller:
                                                        _model.tabBarController,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: TabBarView(
                                                    controller:
                                                        _model.tabBarController,
                                                    children: [
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Número',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.nomeAnimalTextController1 ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.numeroAnimal,
                                                                            'N/A',
                                                                          ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.nomeAnimalFocusNode1,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.numeroAnimal,
                                                                            'N/A',
                                                                          ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .nomeAnimalTextController1Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Chip',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.chipTextController ??=
                                                                                TextEditingController(
                                                                          text: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.chip,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.chip,
                                                                                  'N/A',
                                                                                ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.chipFocusNode,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.chip,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.chip,
                                                                                  'N/A',
                                                                                ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .chipTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Código registro',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.codRegistroTextController ??=
                                                                                TextEditingController(
                                                                          text: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.codRegistro,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.codRegistro,
                                                                                  'N/A',
                                                                                ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.codRegistroFocusNode,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.codRegistro,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.codRegistro,
                                                                                  'N/A',
                                                                                ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .codRegistroTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Nome do animal',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.nomeAnimalTextController2 ??=
                                                                                TextEditingController(
                                                                          text: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.nome,
                                                                                    'Sem nome',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'Sem nome'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.nome,
                                                                                  'Sem nome',
                                                                                ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.nomeAnimalFocusNode2,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.nome,
                                                                                    'Sem nome',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'Sem nome'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.nome,
                                                                                  'Sem nome',
                                                                                ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .nomeAnimalTextController2Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Sexo',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.sexoTextController ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              pgRebanhoViewRebanhoRow?.sexo,
                                                                        ),
                                                                        focusNode:
                                                                            _model.sexoFocusNode,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.nome,
                                                                                    'Sem nome',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'Sem nome'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.nome,
                                                                                  'Sem nome',
                                                                                ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .sexoTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Peso nascimento (kg)',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.pesoNascimentoTextController1 ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.pesoNascimento?.toString(),
                                                                            'N/A',
                                                                          ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.pesoNascimentoFocusNode1,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.pesoNascimento?.toString(),
                                                                            'N/A',
                                                                          ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .pesoNascimentoTextController1Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Data Nascimento',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.pesoNascimentoTextController2 ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              valueOrDefault<String>(
                                                                            dateTimeFormat(
                                                                              "d/M/y",
                                                                              pgRebanhoViewRebanhoRow?.dataNascimento,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            'N/A',
                                                                          ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.pesoNascimentoFocusNode2,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              valueOrDefault<String>(
                                                                            dateTimeFormat(
                                                                              "d/M/y",
                                                                              pgRebanhoViewRebanhoRow?.dataNascimento,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            'N/A',
                                                                          ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .pesoNascimentoTextController2Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Porte',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.porteTextController1 ??=
                                                                                TextEditingController(
                                                                          text: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.porte,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.porte,
                                                                                  'N/A',
                                                                                ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.porteFocusNode1,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.porte,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.porte,
                                                                                  'N/A',
                                                                                ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .porteTextController1Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Categoria',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.categoriaTextController ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.categoria,
                                                                            'N/A',
                                                                          ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.categoriaFocusNode,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.categoria,
                                                                            'N/A',
                                                                          ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .categoriaTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Raça',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.racaTextController ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.raca,
                                                                            'N/A',
                                                                          ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.racaFocusNode,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              valueOrDefault<String>(
                                                                            pgRebanhoViewRebanhoRow?.raca,
                                                                            'N/A',
                                                                          ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .racaTextControllerValidator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Lote',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.porteTextController2 ??=
                                                                                TextEditingController(
                                                                          text: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.loteNome,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.loteNome,
                                                                                  'N/A',
                                                                                ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.porteFocusNode2,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText: valueOrDefault<String>(
                                                                                    pgRebanhoViewRebanhoRow?.loteNome,
                                                                                    'N/A',
                                                                                  ) ==
                                                                                  'null'
                                                                              ? 'N/A'
                                                                              : valueOrDefault<String>(
                                                                                  pgRebanhoViewRebanhoRow?.loteNome,
                                                                                  'N/A',
                                                                                ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .porteTextController2Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        'Data de entrada no lote',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
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
                                                                      TextFormField(
                                                                        controller:
                                                                            _model.porteTextController3 ??=
                                                                                TextEditingController(
                                                                          text:
                                                                              valueOrDefault<String>(
                                                                            dateTimeFormat(
                                                                              "d/M/y",
                                                                              pgRebanhoViewRebanhoRow?.dataEntradaLote,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            'N/A',
                                                                          ),
                                                                        ),
                                                                        focusNode:
                                                                            _model.porteFocusNode3,
                                                                        autofocus:
                                                                            false,
                                                                        readOnly:
                                                                            true,
                                                                        obscureText:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          isDense:
                                                                              false,
                                                                          labelStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          hintText:
                                                                              valueOrDefault<String>(
                                                                            dateTimeFormat(
                                                                              "d/M/y",
                                                                              pgRebanhoViewRebanhoRow?.dataEntradaLote,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            ),
                                                                            'N/A',
                                                                          ),
                                                                          hintStyle: FlutterFlowTheme.of(context)
                                                                              .labelMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                                color: const Color(0xFFBEBEBE),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                              ),
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                const BorderSide(
                                                                              color: Color(0x00000000),
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          errorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: FlutterFlowTheme.of(context).error,
                                                                              width: 1.0,
                                                                            ),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              FlutterFlowTheme.of(context).customColor2,
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              fontSize: 16.0,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        cursorColor:
                                                                            FlutterFlowTheme.of(context).primaryText,
                                                                        validator: _model
                                                                            .porteTextController3Validator
                                                                            .asValidator(context),
                                                                      ),
                                                                    ].divide(const SizedBox(
                                                                        height:
                                                                            8.0)),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Matriz',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.matrizTextController ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                '${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.numeroMatriz,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.nomeMatriz,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                pgRebanhoViewRebanhoRow?.dataNascMatriz,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            )}',
                                                                          ),
                                                                          focusNode:
                                                                              _model.matrizFocusNode,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                '${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.numeroMatriz,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.nomeMatriz,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                pgRebanhoViewRebanhoRow?.dataNascMatriz,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            )}',
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .matrizTextControllerValidator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Reprodutor',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.reprodutorTextController ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                '${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.numeroReprodutor,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.nomeReprodutor,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                pgRebanhoViewRebanhoRow?.dataNascReprodutor,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            )}',
                                                                          ),
                                                                          focusNode:
                                                                              _model.reprodutorFocusNode,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                '${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.numeroReprodutor,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.nomeReprodutor,
                                                                              'S/N',
                                                                            )} • ${valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                pgRebanhoViewRebanhoRow?.dataNascReprodutor,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            )}',
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .reprodutorTextControllerValidator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Desmama',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.dataDesmamaTextController1 ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                effectiveDataDesmamaView,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.dataDesmamaFocusNode1,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                effectiveDataDesmamaView,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            ),
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.datetime,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .dataDesmamaTextController1Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Peso desmama',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.pesoDesmamaTextController1 ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              effectivePesoDesmamaView?.toString(),
                                                                              'N/A',
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.pesoDesmamaFocusNode1,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                valueOrDefault<String>(
                                                                              effectivePesoDesmamaView?.toString(),
                                                                              'N/A',
                                                                            ),
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .pesoDesmamaTextController1Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Última pesagem',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.dataDesmamaTextController2 ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                pgRebanhoViewRebanhoRow?.dataUltimaPesagem,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.dataDesmamaFocusNode2,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                valueOrDefault<String>(
                                                                              dateTimeFormat(
                                                                                "d/M/y",
                                                                                pgRebanhoViewRebanhoRow?.dataUltimaPesagem,
                                                                                locale: FFLocalizations.of(context).languageCode,
                                                                              ),
                                                                              'N/A',
                                                                            ),
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.datetime,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .dataDesmamaTextController2Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Peso atual',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.pesoDesmamaTextController2 ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.pesoAtual?.toString(),
                                                                              'N/A',
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.pesoDesmamaFocusNode2,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.pesoAtual?.toString(),
                                                                              'N/A',
                                                                            ),
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .pesoDesmamaTextController2Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Status',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.dataDesmamaTextController3 ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.status,
                                                                              'N/A',
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.dataDesmamaFocusNode3,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                valueOrDefault<String>(
                                                                              pgRebanhoViewRebanhoRow?.status,
                                                                              'N/A',
                                                                            ),
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.text,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .dataDesmamaTextController3Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children:
                                                                          [
                                                                        Text(
                                                                          'Origem',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
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
                                                                        TextFormField(
                                                                          controller: _model.pesoDesmamaTextController3 ??=
                                                                              TextEditingController(
                                                                            text:
                                                                                fichaOrigemLabel(
                                                                              pgRebanhoViewRebanhoRow?.origem,
                                                                            ),
                                                                          ),
                                                                          focusNode:
                                                                              _model.pesoDesmamaFocusNode3,
                                                                          autofocus:
                                                                              false,
                                                                          readOnly:
                                                                              true,
                                                                          obscureText:
                                                                              false,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            isDense:
                                                                                false,
                                                                            labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            hintText:
                                                                                fichaOrigemLabel(
                                                                              pgRebanhoViewRebanhoRow?.origem,
                                                                            ),
                                                                            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                                  color: const Color(0xFFBEBEBE),
                                                                                  fontSize: 16.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                ),
                                                                            enabledBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: const BorderSide(
                                                                                color: Color(0x00000000),
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            errorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            focusedErrorBorder:
                                                                                OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                color: FlutterFlowTheme.of(context).error,
                                                                                width: 1.0,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                            ),
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                                fontSize: 16.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                          keyboardType:
                                                                              TextInputType.text,
                                                                          cursorColor:
                                                                              FlutterFlowTheme.of(context).primaryText,
                                                                          validator: _model
                                                                              .pesoDesmamaTextController3Validator
                                                                              .asValidator(context),
                                                                        ),
                                                                      ].divide(const SizedBox(
                                                                              height: 8.0)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      width:
                                                                          24.0)),
                                                            ),
                                                            if (() {
                                                              final row =
                                                                  pgRebanhoViewRebanhoRow;
                                                              return fichaOrigemLabel(
                                                                        row?.origem,
                                                                      ) ==
                                                                      'Compra' ||
                                                                  row?.dataAcao !=
                                                                      null ||
                                                                  row?.valorCompra !=
                                                                      null;
                                                            }())
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .only(
                                                                        top:
                                                                            16.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Data da compra',
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
                                                                            TextFormField(
                                                                              controller: _model.dataCompraViewTextController ??= TextEditingController(
                                                                                text: valueOrDefault<String>(
                                                                                  dateTimeFormat(
                                                                                    'd/M/y',
                                                                                    pgRebanhoViewRebanhoRow?.dataAcao,
                                                                                    locale: FFLocalizations.of(context).languageCode,
                                                                                  ),
                                                                                  'N/A',
                                                                                ),
                                                                              ),
                                                                              focusNode: _model.dataCompraViewFocusNode,
                                                                              autofocus: false,
                                                                              readOnly: true,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                isDense: false,
                                                                                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                hintText: valueOrDefault<String>(
                                                                                  dateTimeFormat(
                                                                                    'd/M/y',
                                                                                    pgRebanhoViewRebanhoRow?.dataAcao,
                                                                                    locale: FFLocalizations.of(context).languageCode,
                                                                                  ),
                                                                                  'N/A',
                                                                                ),
                                                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      color: const Color(0xFFBEBEBE),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                errorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: FlutterFlowTheme.of(context).customColor2,
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
                                                                              keyboardType: TextInputType.datetime,
                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                              validator: _model.dataCompraViewTextControllerValidator.asValidator(context),
                                                                            ),
                                                                          ].divide(const SizedBox(height: 8.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Valor da compra (R\$)',
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
                                                                            TextFormField(
                                                                              controller: _model.valorCompraViewTextController ??= TextEditingController(
                                                                                text: pgRebanhoViewRebanhoRow?.valorCompra != null
                                                                                    ? formatNumber(
                                                                                        pgRebanhoViewRebanhoRow!.valorCompra,
                                                                                        formatType: FormatType.decimal,
                                                                                        decimalType: DecimalType.commaDecimal,
                                                                                        currency: 'R\$ ',
                                                                                      )
                                                                                    : 'N/A',
                                                                              ),
                                                                              focusNode: _model.valorCompraViewFocusNode,
                                                                              autofocus: false,
                                                                              readOnly: true,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                isDense: false,
                                                                                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                hintText: pgRebanhoViewRebanhoRow?.valorCompra != null
                                                                                    ? formatNumber(
                                                                                        pgRebanhoViewRebanhoRow!.valorCompra,
                                                                                        formatType: FormatType.decimal,
                                                                                        decimalType: DecimalType.commaDecimal,
                                                                                        currency: 'R\$ ',
                                                                                      )
                                                                                    : 'N/A',
                                                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      color: const Color(0xFFBEBEBE),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                errorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: FlutterFlowTheme.of(context).customColor2,
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
                                                                              keyboardType: TextInputType.number,
                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                              validator: _model.valorCompraViewTextControllerValidator.asValidator(context),
                                                                            ),
                                                                          ].divide(const SizedBox(height: 8.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ].divide(
                                                                      const SizedBox(
                                                                          width:
                                                                              24.0)),
                                                                ),
                                                              ),
                                                            if (valueOrDefault<
                                                                    String>(
                                                                  pgRebanhoViewRebanhoRow
                                                                      ?.status,
                                                                  'N/A',
                                                                ) ==
                                                                'Morto')
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children:
                                                                            [
                                                                          Text(
                                                                            'Data da morte',
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
                                                                          TextFormField(
                                                                            controller: _model.dataDesmamaTextController4 ??=
                                                                                TextEditingController(
                                                                              text: valueOrDefault<String>(
                                                                                dateTimeFormat(
                                                                                  "d/M/y",
                                                                                  pgRebanhoViewRebanhoRow?.dataMorte,
                                                                                  locale: FFLocalizations.of(context).languageCode,
                                                                                ),
                                                                                'N/A',
                                                                              ),
                                                                            ),
                                                                            focusNode:
                                                                                _model.dataDesmamaFocusNode4,
                                                                            autofocus:
                                                                                false,
                                                                            readOnly:
                                                                                true,
                                                                            obscureText:
                                                                                false,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: false,
                                                                              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                              hintText: valueOrDefault<String>(
                                                                                dateTimeFormat(
                                                                                  "d/M/y",
                                                                                  pgRebanhoViewRebanhoRow?.dataMorte,
                                                                                  locale: FFLocalizations.of(context).languageCode,
                                                                                ),
                                                                                'N/A',
                                                                              ),
                                                                              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                    color: const Color(0xFFBEBEBE),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: const BorderSide(
                                                                                  color: Color(0x00000000),
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: const BorderSide(
                                                                                  color: Color(0x00000000),
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              errorBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).error,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              focusedErrorBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).error,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              filled: true,
                                                                              fillColor: FlutterFlowTheme.of(context).customColor2,
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
                                                                            keyboardType:
                                                                                TextInputType.datetime,
                                                                            cursorColor:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                            validator:
                                                                                _model.dataDesmamaTextController4Validator.asValidator(context),
                                                                          ),
                                                                        ].divide(const SizedBox(height: 8.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(),
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children:
                                                                            [
                                                                          Text(
                                                                            'Motivo da morte',
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
                                                                          TextFormField(
                                                                            controller: _model.pesoDesmamaTextController4 ??=
                                                                                TextEditingController(
                                                                              text: valueOrDefault<String>(
                                                                                pgRebanhoViewRebanhoRow?.motivoMorte,
                                                                                'N/A',
                                                                              ),
                                                                            ),
                                                                            focusNode:
                                                                                _model.pesoDesmamaFocusNode4,
                                                                            autofocus:
                                                                                false,
                                                                            readOnly:
                                                                                true,
                                                                            obscureText:
                                                                                false,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              isDense: false,
                                                                              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                              hintText: valueOrDefault<String>(
                                                                                pgRebanhoViewRebanhoRow?.motivoMorte,
                                                                                'N/A',
                                                                              ),
                                                                              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                    color: const Color(0xFFBEBEBE),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                  ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: const BorderSide(
                                                                                  color: Color(0x00000000),
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              focusedBorder: OutlineInputBorder(
                                                                                borderSide: const BorderSide(
                                                                                  color: Color(0x00000000),
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              errorBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).error,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              focusedErrorBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                  color: FlutterFlowTheme.of(context).error,
                                                                                  width: 1.0,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                              filled: true,
                                                                              fillColor: FlutterFlowTheme.of(context).customColor2,
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
                                                                            keyboardType:
                                                                                TextInputType.text,
                                                                            cursorColor:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                            validator:
                                                                                _model.pesoDesmamaTextController4Validator.asValidator(context),
                                                                          ),
                                                                        ].divide(const SizedBox(height: 8.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(
                                                                    const SizedBox(
                                                                        width:
                                                                            24.0)),
                                                              ),
                                                            if (valueOrDefault<
                                                                    String>(
                                                                  pgRebanhoViewRebanhoRow
                                                                      ?.status,
                                                                  'N/A',
                                                                ) ==
                                                                'Vendido')
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .only(
                                                                        top:
                                                                            16.0),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Data da venda',
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
                                                                            TextFormField(
                                                                              controller: _model.dataVendaViewTextController ??= TextEditingController(
                                                                                text: valueOrDefault<String>(
                                                                                  dateTimeFormat(
                                                                                    'd/M/y',
                                                                                    pgRebanhoViewRebanhoRow?.dataVenda,
                                                                                    locale: FFLocalizations.of(context).languageCode,
                                                                                  ),
                                                                                  'N/A',
                                                                                ),
                                                                              ),
                                                                              focusNode: _model.dataVendaViewFocusNode,
                                                                              autofocus: false,
                                                                              readOnly: true,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                isDense: false,
                                                                                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                hintText: valueOrDefault<String>(
                                                                                  dateTimeFormat(
                                                                                    'd/M/y',
                                                                                    pgRebanhoViewRebanhoRow?.dataVenda,
                                                                                    locale: FFLocalizations.of(context).languageCode,
                                                                                  ),
                                                                                  'N/A',
                                                                                ),
                                                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      color: const Color(0xFFBEBEBE),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                errorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: FlutterFlowTheme.of(context).customColor2,
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
                                                                              keyboardType: TextInputType.datetime,
                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                              validator: _model.dataVendaViewTextControllerValidator.asValidator(context),
                                                                            ),
                                                                          ].divide(const SizedBox(height: 8.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.max,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Valor da venda (R\$)',
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
                                                                            TextFormField(
                                                                              controller: _model.valorVendaViewTextController ??= TextEditingController(
                                                                                text: pgRebanhoViewRebanhoRow?.valorVenda != null
                                                                                    ? formatNumber(
                                                                                        pgRebanhoViewRebanhoRow!.valorVenda,
                                                                                        formatType: FormatType.decimal,
                                                                                        decimalType: DecimalType.commaDecimal,
                                                                                        currency: 'R\$ ',
                                                                                      )
                                                                                    : 'N/A',
                                                                              ),
                                                                              focusNode: _model.valorVendaViewFocusNode,
                                                                              autofocus: false,
                                                                              readOnly: true,
                                                                              obscureText: false,
                                                                              decoration: InputDecoration(
                                                                                isDense: false,
                                                                                labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                hintText: pgRebanhoViewRebanhoRow?.valorVenda != null
                                                                                    ? formatNumber(
                                                                                        pgRebanhoViewRebanhoRow!.valorVenda,
                                                                                        formatType: FormatType.decimal,
                                                                                        decimalType: DecimalType.commaDecimal,
                                                                                        currency: 'R\$ ',
                                                                                      )
                                                                                    : 'N/A',
                                                                                hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                      font: GoogleFonts.poppins(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                      ),
                                                                                      color: const Color(0xFFBEBEBE),
                                                                                      fontSize: 16.0,
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                                    ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: const BorderSide(
                                                                                    color: Color(0x00000000),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                errorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                focusedErrorBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    color: FlutterFlowTheme.of(context).error,
                                                                                    width: 1.0,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(8.0),
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: FlutterFlowTheme.of(context).customColor2,
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
                                                                              keyboardType: TextInputType.number,
                                                                              cursorColor: FlutterFlowTheme.of(context).primaryText,
                                                                              validator: _model.valorVendaViewTextControllerValidator.asValidator(context),
                                                                            ),
                                                                          ].divide(const SizedBox(height: 8.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ].divide(
                                                                      const SizedBox(
                                                                          width:
                                                                              24.0)),
                                                                ),
                                                              ),
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Anotações',
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .poppins(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            16.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                                Container(
                                                                  height: 100.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFF1F1F1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _model.anotacoesTextController ??=
                                                                            TextEditingController(
                                                                      text: pgRebanhoViewRebanhoRow
                                                                          ?.anotacoes,
                                                                    ),
                                                                    focusNode:
                                                                        _model
                                                                            .anotacoesFocusNode,
                                                                    autofocus:
                                                                        false,
                                                                    readOnly:
                                                                        true,
                                                                    obscureText:
                                                                        false,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      isDense:
                                                                          false,
                                                                      labelStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                FlutterFlowTheme.of(context).accent3,
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      hintText:
                                                                          pgRebanhoViewRebanhoRow
                                                                              ?.anotacoes,
                                                                      hintStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w600,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            color:
                                                                                const Color(0xFFBEBEBE),
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                      enabledBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            const BorderSide(
                                                                          color:
                                                                              Color(0x00000000),
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      errorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      focusedErrorBorder:
                                                                          OutlineInputBorder(
                                                                        borderSide:
                                                                            BorderSide(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font:
                                                                              GoogleFonts.poppins(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                          ),
                                                                          fontSize:
                                                                              16.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                    cursorColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    validator: _model
                                                                        .anotacoesTextControllerValidator
                                                                        .asValidator(
                                                                            context),
                                                                  ),
                                                                ),
                                                              ].divide(
                                                                  const SizedBox(
                                                                      height:
                                                                          8.0)),
                                                            ),
                                                          ]
                                                              .divide(
                                                                  const SizedBox(
                                                                      height:
                                                                          24.0))
                                                              .addToStart(
                                                                  const SizedBox(
                                                                      height:
                                                                          24.0)),
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Expanded(
                                                            child: Builder(
                                                              builder:
                                                                  (context) {
                                                                final selectedIdRebanho =
                                                                    pgRebanhoViewRebanhoRow
                                                                            ?.idRebanho ??
                                                                        '';
                                                                final selectedRowId =
                                                                    pgRebanhoViewRebanhoRow
                                                                        ?.id;
                                                                final selectedNumeroAnimal =
                                                                    pgRebanhoViewRebanhoRow
                                                                        ?.numeroAnimal;

                                                                final crias =
                                                                    FFAppState()
                                                                        .crias
                                                                        .where(
                                                                            (e) {
                                                                  if (selectedIdRebanho
                                                                      .isEmpty) {
                                                                    return false;
                                                                  }

                                                                  final isSelf = (selectedRowId !=
                                                                              null &&
                                                                          e.id ==
                                                                              selectedRowId) ||
                                                                      (e.idRebanho ==
                                                                          selectedIdRebanho) ||
                                                                      (selectedNumeroAnimal !=
                                                                              null &&
                                                                          e.numeroAnimal ==
                                                                              selectedNumeroAnimal);
                                                                  if (isSelf) {
                                                                    return false;
                                                                  }

                                                                  if (pgRebanhoViewRebanhoRow
                                                                          ?.sexo ==
                                                                      'Macho') {
                                                                    return e.rebanhoIdReprodutor ==
                                                                        selectedIdRebanho;
                                                                  }
                                                                  return e.rebanhoIdMatriz ==
                                                                      selectedIdRebanho;
                                                                }).toList();
                                                                if (crias
                                                                    .isEmpty) {
                                                                  return const Center(
                                                                    child:
                                                                        EmptyWidget(),
                                                                  );
                                                                }

                                                                return FlutterFlowDataTable<
                                                                    AnimaisStruct>(
                                                                  controller: _model
                                                                      .paginatedDataTableController1,
                                                                  data: crias,
                                                                  columnsBuilder:
                                                                      (onSortChanged) =>
                                                                          [
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Número',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      onSort:
                                                                          onSortChanged,
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Nome',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      onSort:
                                                                          onSortChanged,
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Sexo',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      onSort:
                                                                          onSortChanged,
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Nascimento',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Status',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      onSort:
                                                                          onSortChanged,
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Categoria',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          'Raça',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                fontSize: 12.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DataColumn2(
                                                                      label: DefaultTextStyle
                                                                          .merge(
                                                                        softWrap:
                                                                            true,
                                                                        child:
                                                                            Text(
                                                                          ' ',
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .labelLarge
                                                                              .override(
                                                                                font: GoogleFonts.poppins(
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                      fixedWidth:
                                                                          60.0,
                                                                    ),
                                                                  ],
                                                                  dataRowBuilder: (criasItem,
                                                                          criasIndex,
                                                                          selected,
                                                                          onSelectChanged) =>
                                                                      DataRow(
                                                                    color:
                                                                        WidgetStateProperty
                                                                            .all(
                                                                      criasIndex %
                                                                                  2 ==
                                                                              0
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondaryBackground
                                                                          : FlutterFlowTheme.of(context)
                                                                              .customColor11,
                                                                    ),
                                                                    cells: [
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          criasItem
                                                                              .numeroAnimal,
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          criasItem.nome == 'null'
                                                                              ? 'Sem nome'
                                                                              : valueOrDefault<String>(
                                                                                  criasItem.nome,
                                                                                  'N/A',
                                                                                ),
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            child:
                                                                                Image.network(
                                                                              criasItem.sexo == 'Macho' ? 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/4cg1mjibvkyf/Sexomacho.png' : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/in-lida-web-ebl6tn/assets/25fnoszaf5de/Sexofemea.png',
                                                                              width: 24.0,
                                                                              height: 24.0,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            valueOrDefault<String>(
                                                                              criasItem.sexo,
                                                                              'N/A',
                                                                            ),
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
                                                                        ].divide(const SizedBox(width: 8.0)),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          dateTimeFormat(
                                                                            "d/M/y",
                                                                            functions.converterParaData(valueOrDefault<String>(
                                                                              criasItem.dataNascimento,
                                                                              'N/A',
                                                                            )),
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
                                                                          ),
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              valueOrDefault<Color>(
                                                                            () {
                                                                              if (criasItem.status == 'Vendido') {
                                                                                return const Color(0xFFF5D7D4);
                                                                              } else if (criasItem.status == 'Na propriedade') {
                                                                                return FlutterFlowTheme.of(context).customColor7;
                                                                              } else {
                                                                                return FlutterFlowTheme.of(context).customColor2;
                                                                              }
                                                                            }(),
                                                                            FlutterFlowTheme.of(context).customColor2,
                                                                          ),
                                                                          borderRadius:
                                                                              BorderRadius.circular(100.0),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsetsDirectional
                                                                              .fromSTEB(
                                                                              8.0,
                                                                              2.0,
                                                                              8.0,
                                                                              2.0),
                                                                          child:
                                                                              Text(
                                                                            valueOrDefault<String>(
                                                                              criasItem.status,
                                                                              'N/A',
                                                                            ),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                                  color: valueOrDefault<Color>(
                                                                                    () {
                                                                                      if (criasItem.status == 'Vendido') {
                                                                                        return FlutterFlowTheme.of(context).error;
                                                                                      } else if (criasItem.status == 'Na propriedade') {
                                                                                        return FlutterFlowTheme.of(context).secondary;
                                                                                      } else {
                                                                                        return FlutterFlowTheme.of(context).icon;
                                                                                      }
                                                                                    }(),
                                                                                    FlutterFlowTheme.of(context).icon,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          criasItem
                                                                              .categoria,
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Text(
                                                                        valueOrDefault<
                                                                            String>(
                                                                          criasItem
                                                                              .raca,
                                                                          'N/A',
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                            ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Builder(
                                                                            builder: (context) =>
                                                                                FlutterFlowIconButton(
                                                                              borderRadius: 8.0,
                                                                              buttonSize: 40.0,
                                                                              fillColor: const Color(0x0028A365),
                                                                              icon: Icon(
                                                                                Icons.keyboard_control,
                                                                                color: FlutterFlowTheme.of(context).accent3,
                                                                                size: 24.0,
                                                                              ),
                                                                              onPressed: () async {
                                                                                await showAlignedDialog(
                                                                                  barrierColor: Colors.transparent,
                                                                                  context: context,
                                                                                  isGlobal: false,
                                                                                  avoidOverflow: true,
                                                                                  targetAnchor: const AlignmentDirectional(1.0, 1.0).resolve(Directionality.of(context)),
                                                                                  followerAnchor: const AlignmentDirectional(1.0, -1.0).resolve(Directionality.of(context)),
                                                                                  builder: (dialogContext) {
                                                                                    return Material(
                                                                                      color: Colors.transparent,
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          FocusScope.of(dialogContext).unfocus();
                                                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                                                        },
                                                                                        child: ModalMoreWidget(
                                                                                          rebanhoId: criasItem.id,
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ]
                                                                        .map((c) =>
                                                                            DataCell(c))
                                                                        .toList(),
                                                                  ),
                                                                  emptyBuilder:
                                                                      () =>
                                                                          const Center(
                                                                    child:
                                                                        EmptyWidget(),
                                                                  ),
                                                                  paginated:
                                                                      true,
                                                                  selectable:
                                                                      false,
                                                                  hidePaginator:
                                                                      false,
                                                                  showFirstLastButtons:
                                                                      true,
                                                                  headingRowHeight:
                                                                      56.0,
                                                                  dataRowHeight:
                                                                      48.0,
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
                                                        ]
                                                            .divide(
                                                                const SizedBox(
                                                                    height:
                                                                        24.0))
                                                            .addToStart(
                                                                const SizedBox(
                                                                    height:
                                                                        24.0)),
                                                      ),
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Histórico de pesagens',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
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
                                                                        24.0,
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
                                                            FutureBuilder<
                                                                List<
                                                                    HistoricoPesagensRow>>(
                                                              future: (_model.requestCompleter ??= Completer<
                                                                      List<
                                                                          HistoricoPesagensRow>>()
                                                                    ..complete(_loadPesagensAtivas(
                                                                        pgRebanhoViewRebanhoRow
                                                                            ?.idRebanho)))
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
                                                                List<HistoricoPesagensRow>
                                                                    containerPesagemHistoricoPesagensRowList =
                                                                    snapshot
                                                                        .data!;
                                                                final pesagens =
                                                                    containerPesagemHistoricoPesagensRowList;

                                                                return Container(
                                                                  child:
                                                                      Builder(
                                                                    builder:
                                                                        (context) {
                                                                      if (pesagens
                                                                          .isEmpty) {
                                                                        return const Center(
                                                                          child:
                                                                              EmptyWidget(),
                                                                        );
                                                                      }

                                                                      final gmdPontos =
                                                                          _buildGmdEvolution(
                                                                              pesagens);
                                                                      final gmdPorPesagemId =
                                                                          _buildGmdByPesagemId(
                                                                              gmdPontos);
                                                                      final visiblePesagensRows = pesagens.length <
                                                                              5
                                                                          ? pesagens
                                                                              .length
                                                                          : 5;
                                                                      final pesagensTableHeight =
                                                                          170.0 +
                                                                              (visiblePesagensRows * 58.0);

                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                pesagensTableHeight,
                                                                            child:
                                                                                FlutterFlowDataTable<HistoricoPesagensRow>(
                                                                              controller: _model.paginatedDataTableController2,
                                                                              data: pesagens,
                                                                              columnsBuilder: (onSortChanged) => [
                                                                                DataColumn2(
                                                                                  label: DefaultTextStyle.merge(
                                                                                    softWrap: true,
                                                                                    child: Text(
                                                                                      'Peso (kg)',
                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                  onSort: onSortChanged,
                                                                                ),
                                                                                DataColumn2(
                                                                                  label: DefaultTextStyle.merge(
                                                                                    softWrap: true,
                                                                                    child: Text(
                                                                                      'Data da pesagem',
                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                  onSort: onSortChanged,
                                                                                ),
                                                                                DataColumn2(
                                                                                  label: DefaultTextStyle.merge(
                                                                                    softWrap: true,
                                                                                    child: Text(
                                                                                      'GMD (kg/d)',
                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                  fixedWidth: 130.0,
                                                                                  onSort: onSortChanged,
                                                                                ),
                                                                                DataColumn2(
                                                                                  label: DefaultTextStyle.merge(
                                                                                    softWrap: true,
                                                                                    child: Text(
                                                                                      ' ',
                                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                            font: GoogleFonts.poppins(
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                            fontSize: 12.0,
                                                                                            letterSpacing: 0.0,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                          ),
                                                                                    ),
                                                                                  ),
                                                                                  fixedWidth: 60.0,
                                                                                  onSort: onSortChanged,
                                                                                ),
                                                                              ],
                                                                              dataRowBuilder: (pesagensItem, pesagensIndex, selected, onSelectChanged) => DataRow(
                                                                                color: WidgetStateProperty.all(
                                                                                  pesagensIndex % 2 == 0 ? FlutterFlowTheme.of(context).secondaryBackground : FlutterFlowTheme.of(context).customColor11,
                                                                                ),
                                                                                cells: [
                                                                                  Text(
                                                                                    pesagensItem.peso != null ? '${pesagensItem.peso?.toString()} kg' : '-',
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
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    children: [
                                                                                      Text(
                                                                                        _formatPesagemDate(pesagensItem.dataPesagem),
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
                                                                                      if ((pesagensItem.tipo == 'Nascimento') || (pesagensItem.tipo == 'Desmama'))
                                                                                        Container(
                                                                                          height: 32.0,
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).accent2,
                                                                                            borderRadius: BorderRadius.circular(4.0),
                                                                                          ),
                                                                                          child: Align(
                                                                                            alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                                                              child: Text(
                                                                                                valueOrDefault<String>(
                                                                                                  pesagensItem.tipo,
                                                                                                  '...',
                                                                                                ),
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.poppins(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                      fontSize: 16.0,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                    ].divide(const SizedBox(width: 16.0)),
                                                                                  ),
                                                                                  _buildGmdTableValue(
                                                                                    gmdPorPesagemId[pesagensItem.id],
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      FlutterFlowIconButton(
                                                                                        borderRadius: 8.0,
                                                                                        buttonSize: 40.0,
                                                                                        fillColor: const Color(0x0028A365),
                                                                                        icon: FaIcon(
                                                                                          FontAwesomeIcons.trashAlt,
                                                                                          color: FlutterFlowTheme.of(context).error,
                                                                                          size: 20.0,
                                                                                        ),
                                                                                        onPressed: () async {
                                                                                          var confirmDialogResponse = await showDialog<bool>(
                                                                                                context: context,
                                                                                                builder: (alertDialogContext) {
                                                                                                  return AlertDialog(
                                                                                                    title: const Text('Deletar pesagem'),
                                                                                                    content: const Text('Deseja realmente deletar esta pesagem ?'),
                                                                                                    actions: [
                                                                                                      TextButton(
                                                                                                        onPressed: () => Navigator.pop(alertDialogContext, false),
                                                                                                        child: const Text('Não'),
                                                                                                      ),
                                                                                                      TextButton(
                                                                                                        onPressed: () => Navigator.pop(alertDialogContext, true),
                                                                                                        child: const Text('Sim'),
                                                                                                      ),
                                                                                                    ],
                                                                                                  );
                                                                                                },
                                                                                              ) ??
                                                                                              false;
                                                                                          if (confirmDialogResponse) {
                                                                                            await _marcarPesagemComoDeletada(
                                                                                              pesagensItem,
                                                                                            );
                                                                                            await _syncPesoAtualAposPesagem(
                                                                                              rebanhoId: pgRebanhoViewRebanhoRow?.id,
                                                                                              idRebanho: pgRebanhoViewRebanhoRow?.idRebanho,
                                                                                            );
                                                                                            await _recarregarPesagens(
                                                                                              idRebanho: pgRebanhoViewRebanhoRow?.idRebanho,
                                                                                            );
                                                                                          }
                                                                                        },
                                                                                      ),
                                                                                    ].divide(const SizedBox(width: 8.0)),
                                                                                  ),
                                                                                ].map((c) => DataCell(c)).toList(),
                                                                              ),
                                                                              emptyBuilder: () => const Center(
                                                                                child: EmptyWidget(),
                                                                              ),
                                                                              paginated: true,
                                                                              selectable: false,
                                                                              hidePaginator: false,
                                                                              showFirstLastButtons: true,
                                                                              headingRowHeight: 56.0,
                                                                              dataRowHeight: 48.0,
                                                                              columnSpacing: 20.0,
                                                                              headingRowColor: FlutterFlowTheme.of(context).customColor11,
                                                                              sortIconColor: FlutterFlowTheme.of(context).primaryText,
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              addHorizontalDivider: true,
                                                                              addTopAndBottomDivider: false,
                                                                              hideDefaultHorizontalDivider: true,
                                                                              horizontalDividerColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              horizontalDividerThickness: 1.0,
                                                                              addVerticalDivider: false,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 16.0),
                                                                          _buildGmdCard(
                                                                              pesagens),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ]
                                                              .divide(
                                                                  const SizedBox(
                                                                      height:
                                                                          24.0))
                                                              .addToStart(
                                                                  const SizedBox(
                                                                      height:
                                                                          24.0)),
                                                        ),
                                                      ),
                                                      Stack(
                                                        children: [
                                                          if (pgRebanhoViewRebanhoRow
                                                                  ?.sexo ==
                                                              'Fêmea')
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      32.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: FutureBuilder<
                                                                  List<
                                                                      ReproducaoRow>>(
                                                                future:
                                                                    _getReproducoesMatrizFuture(
                                                                  idRebanho:
                                                                      pgRebanhoViewRebanhoRow
                                                                          ?.idRebanho,
                                                                  idPropriedade:
                                                                      FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
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
                                                                            FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  List<ReproducaoRow>
                                                                      containerReproducaoRowList =
                                                                      snapshot
                                                                          .data!;

                                                                  return Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Builder(
                                                                            builder:
                                                                                (context) {
                                                                              final reproducao = containerReproducaoRowList.where((e) => e.deletado == 'NAO').toList().sortedList(keyOf: (e) => e.createdAt, desc: true).toList();
                                                                              if (reproducao.isEmpty) {
                                                                                return const Center(
                                                                                  child: EmptyWidget(),
                                                                                );
                                                                              }

                                                                              return FlutterFlowDataTable<ReproducaoRow>(
                                                                                controller: _model.paginatedDataTableController3,
                                                                                data: reproducao,
                                                                                columnsBuilder: (onSortChanged) => [
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Categoria',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 150.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Data da reproduçao',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 120.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Status',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 200.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Reprodutor',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 170.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Previsão de parto',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 120.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Dias entre inseminaçaõ e parto',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 170.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        ' ',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                                dataRowBuilder: (reproducaoItem, reproducaoIndex, selected, onSelectChanged) => DataRow(
                                                                                  color: WidgetStateProperty.all(
                                                                                    reproducaoIndex % 2 == 0 ? FlutterFlowTheme.of(context).secondaryBackground : FlutterFlowTheme.of(context).customColor11,
                                                                                  ),
                                                                                  cells: [
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Container(
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).customColor2,
                                                                                            borderRadius: BorderRadius.circular(8.0),
                                                                                          ),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                reproducaoItem.tipoReproducao,
                                                                                                '...',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.poppins(
                                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).customColor6,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        if (ReproducaoDTStruct.ressincIndicaMarcacao(reproducaoItem.ressinc))
                                                                                          Container(
                                                                                            width: 20.0,
                                                                                            height: 20.0,
                                                                                            decoration: BoxDecoration(
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              borderRadius: BorderRadius.circular(100.0),
                                                                                            ),
                                                                                            child: Align(
                                                                                              alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                              child: Text(
                                                                                                'R',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.poppins(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                      ].divide(const SizedBox(width: 8.0)),
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          _textoDataReproducaoFichaAnimal(context, reproducaoItem),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Flexible(
                                                                                              child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  color: valueOrDefault<Color>(
                                                                                                    () {
                                                                                                      if (reproducaoItem.statusReproducao == 'Prenhez') {
                                                                                                        return FlutterFlowTheme.of(context).customColor7;
                                                                                                      } else if (reproducaoItem.statusReproducao == 'Não diagnosticado') {
                                                                                                        return FlutterFlowTheme.of(context).customColor2;
                                                                                                      } else {
                                                                                                        return const Color(0xFFF5D7D4);
                                                                                                      }
                                                                                                    }(),
                                                                                                    const Color(0xFFF5D7D4),
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                                                                                                  child: Row(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Flexible(
                                                                                                        child: Text(
                                                                                                          valueOrDefault<String>(
                                                                                                            reproducaoItem.statusReproducao,
                                                                                                            'Não diagnosticado',
                                                                                                          ),
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.poppins(
                                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                color: valueOrDefault<Color>(
                                                                                                                  () {
                                                                                                                    if (reproducaoItem.statusReproducao == 'Prenhez') {
                                                                                                                      return FlutterFlowTheme.of(context).secondary;
                                                                                                                    } else if (reproducaoItem.statusReproducao == 'Não diagnosticado') {
                                                                                                                      return FlutterFlowTheme.of(context).primaryText;
                                                                                                                    } else {
                                                                                                                      return FlutterFlowTheme.of(context).error;
                                                                                                                    }
                                                                                                                  }(),
                                                                                                                  FlutterFlowTheme.of(context).error,
                                                                                                                ),
                                                                                                                fontSize: 12.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      if (reproducaoItem.statusReproducao != 'Não diagnosticado')
                                                                                                        Text(
                                                                                                          valueOrDefault<String>(
                                                                                                            dateTimeFormat(
                                                                                                              "d/M/y",
                                                                                                              functions.converterParaData(reproducaoItem.dataStatus?.toString()),
                                                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                                                            ),
                                                                                                            'S/D',
                                                                                                          ),
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.poppins(
                                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                color: valueOrDefault<Color>(
                                                                                                                  reproducaoItem.statusReproducao == 'Prenhez' ? FlutterFlowTheme.of(context).secondary : FlutterFlowTheme.of(context).error,
                                                                                                                  FlutterFlowTheme.of(context).error,
                                                                                                                ),
                                                                                                                fontSize: 12.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                        ),
                                                                                                    ].divide(const SizedBox(width: 4.0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ].divide(const SizedBox(width: 8.0)),
                                                                                        ),
                                                                                        if (reproducaoItem.parida == 'SIM')
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  color: FlutterFlowTheme.of(context).customColor7,
                                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                                                                                                  child: Row(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        'Parida em ${valueOrDefault<String>(
                                                                                                          dateTimeFormat(
                                                                                                            "d/M/y",
                                                                                                            reproducaoItem.dataParto,
                                                                                                            locale: FFLocalizations.of(context).languageCode,
                                                                                                          ),
                                                                                                          'S/D',
                                                                                                        )}',
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.poppins(
                                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              color: FlutterFlowTheme.of(context).secondary,
                                                                                                              fontSize: 12.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ].divide(const SizedBox(width: 4.0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ].divide(const SizedBox(width: 8.0)),
                                                                                          ),
                                                                                      ].divide(const SizedBox(height: 4.0)),
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          valueOrDefault<String>(
                                                                                            '${valueOrDefault<String>(
                                                                                              reproducaoItem.numReprodutor,
                                                                                              'S/N',
                                                                                            )} • ${valueOrDefault<String>(
                                                                                              reproducaoItem.nomeReprodutor,
                                                                                              'S/N',
                                                                                            )}',
                                                                                            'N/A',
                                                                                          ).maybeHandleOverflow(
                                                                                            maxChars: 27,
                                                                                            replacement: '…',
                                                                                          ),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                fontSize: 16.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                        Text(
                                                                                          'Nascido em: ${valueOrDefault<String>(
                                                                                            dateTimeFormat(
                                                                                              "d/M/y",
                                                                                              functions.converterParaData(reproducaoItem.nascimentoReprodutor?.toString()),
                                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                                            ),
                                                                                            'S/D',
                                                                                          )}',
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).icon,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (statusReproducaoPermitePrevisaoParto(reproducaoItem.statusReproducao) && ((_dataReferenciaReproducao(reproducaoItem) != null) || (reproducaoItem.previsaoParto != null))) {
                                                                                          return Text(
                                                                                            valueOrDefault<String>(
                                                                                              reproducaoItem.previsaoParto == null
                                                                                                  ? valueOrDefault<String>(
                                                                                                      dateTimeFormat(
                                                                                                        "d/M/y",
                                                                                                        functions.dataMais295(_dataReferenciaReproducao(reproducaoItem)!),
                                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                                      ),
                                                                                                      'S/D',
                                                                                                    )
                                                                                                  : valueOrDefault<String>(
                                                                                                      dateTimeFormat(
                                                                                                        "d/M/y",
                                                                                                        reproducaoItem.previsaoParto,
                                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                                      ),
                                                                                                      'S/D',
                                                                                                    ),
                                                                                              'S/D',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          );
                                                                                        } else {
                                                                                          return Text(
                                                                                            'Sem previsão',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        if ((_dataReferenciaReproducao(reproducaoItem) != null) && (reproducaoItem.dataParto != null))
                                                                                          Text(
                                                                                            valueOrDefault<String>(
                                                                                              functions.diasEntreDatas(_dataReferenciaReproducao(reproducaoItem)!, reproducaoItem.dataParto!).toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          ),
                                                                                        if (!((_dataReferenciaReproducao(reproducaoItem) != null) && (reproducaoItem.dataParto != null)))
                                                                                          Text(
                                                                                            'Sem informação.',
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
                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        Builder(
                                                                                          builder: (context) => FlutterFlowIconButton(
                                                                                            borderRadius: 8.0,
                                                                                            buttonSize: 40.0,
                                                                                            fillColor: const Color(0x0028A365),
                                                                                            icon: Icon(
                                                                                              Icons.keyboard_control,
                                                                                              color: FlutterFlowTheme.of(context).accent3,
                                                                                              size: 24.0,
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              await showAlignedDialog(
                                                                                                barrierColor: Colors.transparent,
                                                                                                context: context,
                                                                                                isGlobal: false,
                                                                                                avoidOverflow: true,
                                                                                                targetAnchor: const AlignmentDirectional(1.0, 1.0).resolve(Directionality.of(context)),
                                                                                                followerAnchor: const AlignmentDirectional(1.0, -1.0).resolve(Directionality.of(context)),
                                                                                                builder: (dialogContext) {
                                                                                                  return Material(
                                                                                                    color: Colors.transparent,
                                                                                                    child: GestureDetector(
                                                                                                      onTap: () {
                                                                                                        FocusScope.of(dialogContext).unfocus();
                                                                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                                                                      },
                                                                                                      child: ModalMoreReproducaoWidget(
                                                                                                        reproducaoDbId: reproducaoItem.id,
                                                                                                        reproducaoID: reproducaoItem.idReproducao!,
                                                                                                      ),
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ].map((c) => DataCell(c)).toList(),
                                                                                ),
                                                                                onSortChanged: (columnIndex, ascending) {
                                                                                  final sorted = _sortReproducoesFichaAnimal(
                                                                                    reproducao,
                                                                                    columnIndex,
                                                                                    ascending,
                                                                                  );
                                                                                  _model.paginatedDataTableController3.updateData(
                                                                                    data: sorted,
                                                                                    notify: true,
                                                                                  );
                                                                                },
                                                                                emptyBuilder: () => const Center(
                                                                                  child: EmptyWidget(),
                                                                                ),
                                                                                paginated: false,
                                                                                selectable: false,
                                                                                headingRowHeight: 56.0,
                                                                                dataRowHeight: 76.0,
                                                                                columnSpacing: 20.0,
                                                                                headingRowColor: FlutterFlowTheme.of(context).customColor11,
                                                                                sortIconColor: FlutterFlowTheme.of(context).primaryText,
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                addHorizontalDivider: true,
                                                                                addTopAndBottomDivider: false,
                                                                                hideDefaultHorizontalDivider: true,
                                                                                horizontalDividerColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                horizontalDividerThickness: 1.0,
                                                                                addVerticalDivider: false,
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          if (pgRebanhoViewRebanhoRow
                                                                  ?.sexo ==
                                                              'Macho')
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      32.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: FutureBuilder<
                                                                  List<
                                                                      ReproducaoRow>>(
                                                                future:
                                                                    _getReproducoesReprodutorFuture(
                                                                  idRebanho:
                                                                      pgRebanhoViewRebanhoRow
                                                                          ?.idRebanho,
                                                                  idPropriedade:
                                                                      FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
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
                                                                            FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                  List<ReproducaoRow>
                                                                      containerReproducaoRowList =
                                                                      snapshot
                                                                          .data!;

                                                                  return Container(
                                                                    decoration:
                                                                        const BoxDecoration(),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Builder(
                                                                            builder:
                                                                                (context) {
                                                                              final reproducao = containerReproducaoRowList.where((e) => e.deletado == 'NAO').toList().sortedList(keyOf: (e) => e.createdAt, desc: true).toList();
                                                                              if (reproducao.isEmpty) {
                                                                                return const Center(
                                                                                  child: EmptyWidget(),
                                                                                );
                                                                              }

                                                                              return FlutterFlowDataTable<ReproducaoRow>(
                                                                                controller: _model.paginatedDataTableController4,
                                                                                data: reproducao,
                                                                                columnsBuilder: (onSortChanged) => [
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Categoria',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 150.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Data da reproduçao',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 120.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Status',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 200.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Reprodutor',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 170.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Previsão de parto',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 120.0,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        'Dias entre inseminaçaõ e parto',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                    fixedWidth: 170.0,
                                                                                    onSort: onSortChanged,
                                                                                  ),
                                                                                  DataColumn2(
                                                                                    label: DefaultTextStyle.merge(
                                                                                      softWrap: true,
                                                                                      child: Text(
                                                                                        ' ',
                                                                                        style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                              font: GoogleFonts.poppins(
                                                                                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                              ),
                                                                                              fontSize: 12.0,
                                                                                              letterSpacing: 0.0,
                                                                                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                            ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                                dataRowBuilder: (reproducaoItem, reproducaoIndex, selected, onSelectChanged) => DataRow(
                                                                                  color: WidgetStateProperty.all(
                                                                                    reproducaoIndex % 2 == 0 ? FlutterFlowTheme.of(context).secondaryBackground : FlutterFlowTheme.of(context).customColor11,
                                                                                  ),
                                                                                  cells: [
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
                                                                                        Container(
                                                                                          decoration: BoxDecoration(
                                                                                            color: FlutterFlowTheme.of(context).customColor2,
                                                                                            borderRadius: BorderRadius.circular(8.0),
                                                                                          ),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                                                            child: Text(
                                                                                              valueOrDefault<String>(
                                                                                                reproducaoItem.tipoReproducao,
                                                                                                '...',
                                                                                              ),
                                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                    font: GoogleFonts.poppins(
                                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                                    color: FlutterFlowTheme.of(context).customColor6,
                                                                                                    letterSpacing: 0.0,
                                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        if (ReproducaoDTStruct.ressincIndicaMarcacao(reproducaoItem.ressinc))
                                                                                          Container(
                                                                                            width: 20.0,
                                                                                            height: 20.0,
                                                                                            decoration: BoxDecoration(
                                                                                              color: FlutterFlowTheme.of(context).primary,
                                                                                              borderRadius: BorderRadius.circular(100.0),
                                                                                            ),
                                                                                            child: Align(
                                                                                              alignment: const AlignmentDirectional(0.0, 0.0),
                                                                                              child: Text(
                                                                                                'R',
                                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                      font: GoogleFonts.poppins(
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                      ),
                                                                                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                                      letterSpacing: 0.0,
                                                                                                      fontWeight: FontWeight.w600,
                                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                    ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                      ].divide(const SizedBox(width: 8.0)),
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          _textoDataReproducaoFichaAnimal(context, reproducaoItem),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.max,
                                                                                          children: [
                                                                                            Flexible(
                                                                                              child: Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  color: valueOrDefault<Color>(
                                                                                                    () {
                                                                                                      if (reproducaoItem.statusReproducao == 'Prenhez') {
                                                                                                        return FlutterFlowTheme.of(context).customColor7;
                                                                                                      } else if (reproducaoItem.statusReproducao == 'Não diagnosticado') {
                                                                                                        return FlutterFlowTheme.of(context).customColor2;
                                                                                                      } else {
                                                                                                        return const Color(0xFFF5D7D4);
                                                                                                      }
                                                                                                    }(),
                                                                                                    const Color(0xFFF5D7D4),
                                                                                                  ),
                                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                                                                                                  child: Row(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Flexible(
                                                                                                        child: Text(
                                                                                                          valueOrDefault<String>(
                                                                                                            reproducaoItem.statusReproducao,
                                                                                                            'Não diagnosticado',
                                                                                                          ),
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.poppins(
                                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                color: valueOrDefault<Color>(
                                                                                                                  () {
                                                                                                                    if (reproducaoItem.statusReproducao == 'Prenhez') {
                                                                                                                      return FlutterFlowTheme.of(context).secondary;
                                                                                                                    } else if (reproducaoItem.statusReproducao == 'Não diagnosticado') {
                                                                                                                      return FlutterFlowTheme.of(context).primaryText;
                                                                                                                    } else {
                                                                                                                      return FlutterFlowTheme.of(context).error;
                                                                                                                    }
                                                                                                                  }(),
                                                                                                                  FlutterFlowTheme.of(context).error,
                                                                                                                ),
                                                                                                                fontSize: 12.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      if (reproducaoItem.statusReproducao != 'Não diagnosticado')
                                                                                                        Text(
                                                                                                          valueOrDefault<String>(
                                                                                                            dateTimeFormat(
                                                                                                              "d/M/y",
                                                                                                              functions.converterParaData(reproducaoItem.dataStatus?.toString()),
                                                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                                                            ),
                                                                                                            'S/D',
                                                                                                          ),
                                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                                font: GoogleFonts.poppins(
                                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                                ),
                                                                                                                color: valueOrDefault<Color>(
                                                                                                                  reproducaoItem.statusReproducao == 'Prenhez' ? FlutterFlowTheme.of(context).secondary : FlutterFlowTheme.of(context).error,
                                                                                                                  FlutterFlowTheme.of(context).error,
                                                                                                                ),
                                                                                                                fontSize: 12.0,
                                                                                                                letterSpacing: 0.0,
                                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                        ),
                                                                                                    ].divide(const SizedBox(width: 4.0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ].divide(const SizedBox(width: 8.0)),
                                                                                        ),
                                                                                        if (reproducaoItem.parida == 'SIM')
                                                                                          Row(
                                                                                            mainAxisSize: MainAxisSize.max,
                                                                                            children: [
                                                                                              Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  color: FlutterFlowTheme.of(context).customColor7,
                                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                                                                                                  child: Row(
                                                                                                    mainAxisSize: MainAxisSize.max,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        'Parida em ${valueOrDefault<String>(
                                                                                                          dateTimeFormat(
                                                                                                            "d/M/y",
                                                                                                            reproducaoItem.dataParto,
                                                                                                            locale: FFLocalizations.of(context).languageCode,
                                                                                                          ),
                                                                                                          'S/D',
                                                                                                        )}',
                                                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                              font: GoogleFonts.poppins(
                                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                              ),
                                                                                                              color: FlutterFlowTheme.of(context).secondary,
                                                                                                              fontSize: 12.0,
                                                                                                              letterSpacing: 0.0,
                                                                                                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                            ),
                                                                                                      ),
                                                                                                    ].divide(const SizedBox(width: 4.0)),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ].divide(const SizedBox(width: 8.0)),
                                                                                          ),
                                                                                      ].divide(const SizedBox(height: 4.0)),
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          valueOrDefault<String>(
                                                                                            '${valueOrDefault<String>(
                                                                                              reproducaoItem.numReprodutor,
                                                                                              'S/N',
                                                                                            )} • ${valueOrDefault<String>(
                                                                                              reproducaoItem.nomeReprodutor,
                                                                                              'S/N',
                                                                                            )}',
                                                                                            'N/A',
                                                                                          ).maybeHandleOverflow(
                                                                                            maxChars: 27,
                                                                                            replacement: '…',
                                                                                          ),
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                fontSize: 16.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                        Text(
                                                                                          'Nascido em: ${valueOrDefault<String>(
                                                                                            dateTimeFormat(
                                                                                              "d/M/y",
                                                                                              functions.converterParaData(reproducaoItem.nascimentoReprodutor?.toString()),
                                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                                            ),
                                                                                            'S/D',
                                                                                          )}',
                                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(context).icon,
                                                                                                fontSize: 12.0,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                              ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Builder(
                                                                                      builder: (context) {
                                                                                        if (statusReproducaoPermitePrevisaoParto(reproducaoItem.statusReproducao) && ((_dataReferenciaReproducao(reproducaoItem) != null) || (reproducaoItem.previsaoParto != null))) {
                                                                                          return Text(
                                                                                            valueOrDefault<String>(
                                                                                              reproducaoItem.previsaoParto == null
                                                                                                  ? valueOrDefault<String>(
                                                                                                      dateTimeFormat(
                                                                                                        "d/M/y",
                                                                                                        functions.dataMais295(_dataReferenciaReproducao(reproducaoItem)!),
                                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                                      ),
                                                                                                      'S/D',
                                                                                                    )
                                                                                                  : valueOrDefault<String>(
                                                                                                      dateTimeFormat(
                                                                                                        "d/M/y",
                                                                                                        reproducaoItem.previsaoParto,
                                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                                      ),
                                                                                                      'S/D',
                                                                                                    ),
                                                                                              'S/D',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          );
                                                                                        } else {
                                                                                          return Text(
                                                                                            'Sem previsão',
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        if ((_dataReferenciaReproducao(reproducaoItem) != null) && (reproducaoItem.dataParto != null))
                                                                                          Text(
                                                                                            valueOrDefault<String>(
                                                                                              functions.diasEntreDatas(_dataReferenciaReproducao(reproducaoItem)!, reproducaoItem.dataParto!).toString(),
                                                                                              '0',
                                                                                            ),
                                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                                  font: GoogleFonts.poppins(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                  ),
                                                                                                  fontSize: 16.0,
                                                                                                  letterSpacing: 0.0,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                                ),
                                                                                          ),
                                                                                        if (!((_dataReferenciaReproducao(reproducaoItem) != null) && (reproducaoItem.dataParto != null)))
                                                                                          Text(
                                                                                            'Sem informação.',
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
                                                                                      ],
                                                                                    ),
                                                                                    Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        Builder(
                                                                                          builder: (context) => FlutterFlowIconButton(
                                                                                            borderRadius: 8.0,
                                                                                            buttonSize: 40.0,
                                                                                            fillColor: const Color(0x0028A365),
                                                                                            icon: Icon(
                                                                                              Icons.keyboard_control,
                                                                                              color: FlutterFlowTheme.of(context).accent3,
                                                                                              size: 24.0,
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              await showAlignedDialog(
                                                                                                barrierColor: Colors.transparent,
                                                                                                context: context,
                                                                                                isGlobal: false,
                                                                                                avoidOverflow: true,
                                                                                                targetAnchor: const AlignmentDirectional(1.0, 1.0).resolve(Directionality.of(context)),
                                                                                                followerAnchor: const AlignmentDirectional(1.0, -1.0).resolve(Directionality.of(context)),
                                                                                                builder: (dialogContext) {
                                                                                                  return Material(
                                                                                                    color: Colors.transparent,
                                                                                                    child: GestureDetector(
                                                                                                      onTap: () {
                                                                                                        FocusScope.of(dialogContext).unfocus();
                                                                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                                                                      },
                                                                                                      child: ModalMoreReproducaoWidget(
                                                                                                        reproducaoDbId: reproducaoItem.id,
                                                                                                        reproducaoID: reproducaoItem.idReproducao!,
                                                                                                      ),
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ].map((c) => DataCell(c)).toList(),
                                                                                ),
                                                                                onSortChanged: (columnIndex, ascending) {
                                                                                  final sorted = _sortReproducoesFichaAnimal(
                                                                                    reproducao,
                                                                                    columnIndex,
                                                                                    ascending,
                                                                                  );
                                                                                  _model.paginatedDataTableController4.updateData(
                                                                                    data: sorted,
                                                                                    notify: true,
                                                                                  );
                                                                                },
                                                                                emptyBuilder: () => const Center(
                                                                                  child: EmptyWidget(),
                                                                                ),
                                                                                paginated: false,
                                                                                selectable: false,
                                                                                headingRowHeight: 56.0,
                                                                                dataRowHeight: 76.0,
                                                                                columnSpacing: 20.0,
                                                                                headingRowColor: FlutterFlowTheme.of(context).customColor11,
                                                                                sortIconColor: FlutterFlowTheme.of(context).primaryText,
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                addHorizontalDivider: true,
                                                                                addTopAndBottomDivider: false,
                                                                                hideDefaultHorizontalDivider: true,
                                                                                horizontalDividerColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                horizontalDividerThickness: 1.0,
                                                                                addVerticalDivider: false,
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      32.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: FutureBuilder<
                                                                  List<
                                                                      SanidadeRow>>(
                                                                future:
                                                                    _getSanidadesFuture(
                                                                  idRebanho:
                                                                      pgRebanhoViewRebanhoRow
                                                                          ?.idRebanho,
                                                                  idPropriedade:
                                                                      FFAppState()
                                                                          .propriedadeSelecionada
                                                                          .idPropriedade,
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
                                                                            FlutterFlowTheme.of(context).primary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }

                                                                  final sanidade = snapshot
                                                                      .data!
                                                                      .where((e) =>
                                                                          e.deletado ==
                                                                          'NAO')
                                                                      .toList()
                                                                      .sortedList(
                                                                        keyOf: (e) =>
                                                                            e.dataSanidade ??
                                                                            e.createdAt,
                                                                        desc:
                                                                            true,
                                                                      )
                                                                      .toList();
                                                                  if (sanidade
                                                                      .isEmpty) {
                                                                    return const Center(
                                                                      child:
                                                                          EmptyWidget(),
                                                                    );
                                                                  }

                                                                  Widget buildChips(
                                                                      List<String>
                                                                          values) {
                                                                    if (values
                                                                        .isEmpty) {
                                                                      return Text(
                                                                        '—',
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
                                                                      );
                                                                    }

                                                                    return SingleChildScrollView(
                                                                      scrollDirection:
                                                                          Axis.horizontal,
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children: List.generate(
                                                                            values.length,
                                                                            (index) {
                                                                          final item =
                                                                              values[index];
                                                                          return Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).accent2,
                                                                              borderRadius: BorderRadius.circular(4.0),
                                                                            ),
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                                              child: Text(
                                                                                item,
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
                                                                        }).divide(const SizedBox(
                                                                            width:
                                                                                4.0)),
                                                                      ),
                                                                    );
                                                                  }

                                                                  List<String>
                                                                      mergeJsonAndText(
                                                                    String?
                                                                        jsonList,
                                                                    String?
                                                                        outros, {
                                                                    String? obs,
                                                                  }) {
                                                                    final values = functions
                                                                            .converterJSONparaLista(jsonList)
                                                                            ?.toList() ??
                                                                        <String>[];

                                                                    final outrosTrim =
                                                                        (outros ??
                                                                                '')
                                                                            .trim();
                                                                    if (outrosTrim
                                                                            .isNotEmpty &&
                                                                        outrosTrim.toLowerCase() !=
                                                                            'null' &&
                                                                        outrosTrim !=
                                                                            '[]') {
                                                                      values.add(
                                                                          outrosTrim);
                                                                    }
                                                                    final obsTrim =
                                                                        (obs ?? '')
                                                                            .trim();
                                                                    if (obsTrim
                                                                            .isNotEmpty &&
                                                                        obsTrim.toLowerCase() !=
                                                                            'null') {
                                                                      values.add(
                                                                          'Obs.: $obsTrim');
                                                                    }
                                                                    return values;
                                                                  }

                                                                  List<String>
                                                                      mergeTextOnly(
                                                                    String?
                                                                        value,
                                                                    String?
                                                                        outros,
                                                                  ) {
                                                                    final values =
                                                                        <String>[];
                                                                    final valueTrim =
                                                                        (value ??
                                                                                '')
                                                                            .trim();
                                                                    if (valueTrim
                                                                            .isNotEmpty &&
                                                                        valueTrim.toLowerCase() !=
                                                                            'null' &&
                                                                        valueTrim !=
                                                                            '[]') {
                                                                      values.add(
                                                                          valueTrim);
                                                                    }

                                                                    final outrosTrim =
                                                                        (outros ??
                                                                                '')
                                                                            .trim();
                                                                    if (outrosTrim
                                                                            .isNotEmpty &&
                                                                        outrosTrim.toLowerCase() !=
                                                                            'null' &&
                                                                        outrosTrim !=
                                                                            '[]') {
                                                                      values.add(
                                                                          outrosTrim);
                                                                    }
                                                                    return values;
                                                                  }

                                                                  String
                                                                      safeStringField(
                                                                    SanidadeRow
                                                                        row,
                                                                    String
                                                                        fieldName,
                                                                  ) {
                                                                    try {
                                                                      final value =
                                                                          row.getField<String>(
                                                                              fieldName);
                                                                      final trimmed =
                                                                          (value ?? '')
                                                                              .trim();
                                                                      if (trimmed
                                                                          .isEmpty) {
                                                                        return '—';
                                                                      }
                                                                      if (trimmed
                                                                              .toLowerCase() ==
                                                                          'null') {
                                                                        return '—';
                                                                      }
                                                                      return trimmed;
                                                                    } catch (_) {
                                                                      return '—';
                                                                    }
                                                                  }

                                                                  return FlutterFlowDataTable<
                                                                      SanidadeRow>(
                                                                    controller:
                                                                        _model
                                                                            .paginatedDataTableController5,
                                                                    data:
                                                                        sanidade,
                                                                    columnsBuilder:
                                                                        (onSortChanged) =>
                                                                            [
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Data',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            110.0,
                                                                        onSort:
                                                                            onSortChanged,
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Vacinação',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Antiparasitário',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Tratamento',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Protocolo reprodutivo',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Protocolo D0',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            120.0,
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'Retirada',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            120.0,
                                                                      ),
                                                                      DataColumn2(
                                                                        label: DefaultTextStyle
                                                                            .merge(
                                                                          softWrap:
                                                                              true,
                                                                          child:
                                                                              Text(
                                                                            'IATF',
                                                                            style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                  ),
                                                                                  fontSize: 12.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        fixedWidth:
                                                                            120.0,
                                                                      ),
                                                                    ],
                                                                    dataRowBuilder: (sanidadeItem,
                                                                            sanidadeIndex,
                                                                            selected,
                                                                            onSelectChanged) =>
                                                                        DataRow(
                                                                      color: WidgetStateProperty
                                                                          .all(
                                                                        sanidadeIndex % 2 ==
                                                                                0
                                                                            ? FlutterFlowTheme.of(context).secondaryBackground
                                                                            : FlutterFlowTheme.of(context).customColor11,
                                                                      ),
                                                                      cells: [
                                                                        Text(
                                                                          dateTimeFormat(
                                                                            'd/M/y',
                                                                            sanidadeItem.dataSanidade ??
                                                                                sanidadeItem.createdAt,
                                                                            locale:
                                                                                FFLocalizations.of(context).languageCode,
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
                                                                        buildChips(
                                                                          mergeJsonAndText(
                                                                            sanidadeItem.vacinacao,
                                                                            sanidadeItem.vacinacaoOutros,
                                                                            obs:
                                                                                sanidadeItem.vacinacaoObs,
                                                                          ),
                                                                        ),
                                                                        buildChips(
                                                                          mergeJsonAndText(
                                                                            sanidadeItem.antiparasitario,
                                                                            sanidadeItem.antiparasitarioOutros,
                                                                            obs:
                                                                                sanidadeItem.antiparasitarioObs,
                                                                          ),
                                                                        ),
                                                                        buildChips(
                                                                          mergeJsonAndText(
                                                                            sanidadeItem.tratamento,
                                                                            sanidadeItem.tratamentoOutros,
                                                                            obs:
                                                                                sanidadeItem.tratamentoObs,
                                                                          ),
                                                                        ),
                                                                        buildChips(
                                                                          mergeTextOnly(
                                                                            sanidadeItem.protocoloReprodutivo,
                                                                            sanidadeItem.protocoloReprodutivoOutros,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          safeStringField(
                                                                            sanidadeItem,
                                                                            'protocolo_d0',
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
                                                                        Text(
                                                                          safeStringField(
                                                                            sanidadeItem,
                                                                            'protocolo_retirada',
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
                                                                        Text(
                                                                          safeStringField(
                                                                            sanidadeItem,
                                                                            'protocolo_iatf',
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
                                                                      ]
                                                                          .map((c) =>
                                                                              DataCell(c))
                                                                          .toList(),
                                                                    ),
                                                                    emptyBuilder:
                                                                        () =>
                                                                            const Center(
                                                                      child:
                                                                          EmptyWidget(),
                                                                    ),
                                                                    paginated:
                                                                        false,
                                                                    selectable:
                                                                        false,
                                                                    headingRowHeight:
                                                                        56.0,
                                                                    dataRowHeight:
                                                                        48.0,
                                                                    columnSpacing:
                                                                        20.0,
                                                                    headingRowColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .customColor11,
                                                                    sortIconColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    addHorizontalDivider:
                                                                        true,
                                                                    addTopAndBottomDivider:
                                                                        false,
                                                                    hideDefaultHorizontalDivider:
                                                                        true,
                                                                    horizontalDividerColor:
                                                                        FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                    horizontalDividerThickness:
                                                                        1.0,
                                                                    addVerticalDivider:
                                                                        false,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ]
                                                        .map((child) =>
                                                            _KeepAliveTab(
                                                                child: child))
                                                        .toList(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    context.safePop();
                                                  },
                                                  text: 'Voltar',
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 56.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                            16.0, 0.0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                    color: Colors.white,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .titleSmall
                                                            .override(
                                                              font: GoogleFonts
                                                                  .poppins(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                              ),
                                                              color: const Color(
                                                                  0xFF28A365),
                                                              letterSpacing:
                                                                  0.0,
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
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    _model.matriz =
                                                        await RebanhoTable()
                                                            .queryRows(
                                                      queryFn: (q) => q
                                                          .eqOrNull(
                                                            'numeroAnimal',
                                                            pgRebanhoViewRebanhoRow
                                                                ?.numeroMatriz,
                                                          )
                                                          .eqOrNull(
                                                            'dataNascimento',
                                                            supaSerialize<
                                                                    DateTime>(
                                                                pgRebanhoViewRebanhoRow
                                                                    ?.dataNascMatriz),
                                                          )
                                                          .eqOrNull(
                                                            'raca',
                                                            pgRebanhoViewRebanhoRow
                                                                ?.racaMatriz,
                                                          ),
                                                    );
                                                    FFAppState()
                                                            .matrizSelecionada =
                                                        AnimalSelecionadoStruct(
                                                      numAnimal: _model
                                                          .matriz
                                                          ?.firstOrNull
                                                          ?.numeroAnimal,
                                                      nomeAnimal: _model.matriz
                                                          ?.firstOrNull?.nome,
                                                      dataNascAnimal: _model
                                                          .matriz
                                                          ?.firstOrNull
                                                          ?.dataNascimento
                                                          ?.toString(),
                                                      racaAnimal: _model.matriz
                                                          ?.firstOrNull?.raca,
                                                    );
                                                    safeSetState(() {});
                                                    _model.reprodutor2 =
                                                        await RebanhoTable()
                                                            .queryRows(
                                                      queryFn: (q) =>
                                                          q.eqOrNull(
                                                        'numeroAnimal',
                                                        pgRebanhoViewRebanhoRow
                                                            ?.numeroReprodutor,
                                                      ),
                                                    );
                                                    FFAppState()
                                                            .reprodutorSelecionado =
                                                        AnimalSelecionadoStruct(
                                                      numAnimal: _model
                                                          .reprodutor2
                                                          ?.firstOrNull
                                                          ?.numeroAnimal,
                                                      nomeAnimal: _model
                                                          .reprodutor2
                                                          ?.firstOrNull
                                                          ?.nome,
                                                      dataNascAnimal: _model
                                                          .reprodutor2
                                                          ?.firstOrNull
                                                          ?.dataNascimento
                                                          ?.toString(),
                                                      racaAnimal: _model
                                                          .reprodutor2
                                                          ?.firstOrNull
                                                          ?.raca,
                                                    );
                                                    safeSetState(() {});
                                                    unawaited(
                                                      () async {
                                                        await RebanhoTable()
                                                            .update(
                                                          data: {
                                                            'rebanhoIdMatriz':
                                                                _model
                                                                    .matriz
                                                                    ?.firstOrNull
                                                                    ?.idRebanho,
                                                          },
                                                          matchingRows:
                                                              (rows) =>
                                                                  rows.eqOrNull(
                                                            'idRebanho',
                                                            pgRebanhoViewRebanhoRow
                                                                ?.idRebanho,
                                                          ),
                                                        );
                                                      }(),
                                                    );

                                                    context.pushNamed(
                                                      PgRebanhoEditWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'rebanhoId':
                                                            serializeParam(
                                                          pgRebanhoViewRebanhoRow
                                                              ?.id,
                                                          ParamType.int,
                                                        ),
                                                      }.withoutNulls,
                                                      extra: <String, dynamic>{
                                                        kTransitionInfoKey:
                                                            const TransitionInfo(
                                                          hasTransition: true,
                                                          transitionType:
                                                              PageTransitionType
                                                                  .fade,
                                                          duration: Duration(
                                                              milliseconds: 0),
                                                        ),
                                                      },
                                                    );

                                                    safeSetState(() {});
                                                  },
                                                  text: 'Editar',
                                                  icon: const Icon(
                                                    Icons.mode_edit_outlined,
                                                    size: 24.0,
                                                  ),
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 56.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(16.0, 0.0,
                                                            16.0, 0.0),
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
                                                          font: GoogleFonts
                                                              .poppins(
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
                                                            8.0),
                                                  ),
                                                ),
                                              ),
                                            ].divide(
                                                const SizedBox(width: 24.0)),
                                          ),
                                        ].divide(const SizedBox(height: 24.0)),
                                      ),
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
      },
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Exibe a origem na ficha do animal, alinhado ao que é salvo no rebanho.
String fichaOrigemLabel(String? origem) {
  final raw = valueOrDefault<String>(origem, 'N/A');
  return raw == 'null' ? 'N/A' : raw;
}
