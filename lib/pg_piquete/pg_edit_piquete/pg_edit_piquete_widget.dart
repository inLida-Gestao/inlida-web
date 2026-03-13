import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'dart:async';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pg_edit_piquete_model.dart';
export 'pg_edit_piquete_model.dart';

class PgEditPiqueteWidget extends StatefulWidget {
  const PgEditPiqueteWidget({
    super.key,
    required this.idPiquete,
    required this.piqueteNome,
  });

  final String? idPiquete;
  final String? piqueteNome;

  static String routeName = 'pgEditPiquete';
  static String routePath = '/editpiquete';

  @override
  State<PgEditPiqueteWidget> createState() => _PgEditPiqueteWidgetState();
}

class _PgEditPiqueteWidgetState extends State<PgEditPiqueteWidget> {
  late PgEditPiqueteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgEditPiqueteModel());

    _model.nomePiqueteTextController ??= TextEditingController();
    _model.nomePiqueteFocusNode ??= FocusNode();
    _model.areaTextController ??= TextEditingController();
    _model.areaFocusNode ??= FocusNode();
    _model.anotacoesTextController ??= TextEditingController();
    _model.anotacoesFocusNode ??= FocusNode();
    _model.pesquisaAnimaisTextController ??= TextEditingController();
    _model.pesquisaAnimaisFocusNode ??= FocusNode();
    _model.pesquisaLotesTextController ??= TextEditingController();
    _model.pesquisaLotesFocusNode ??= FocusNode();

    // Load existing piquete data
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final rows = await PiqueteTable().queryRows(
        queryFn: (q) => q.eqOrNull('id_piquete', widget.idPiquete),
      );
      final p = rows.firstOrNull;
      if (p == null) return;

      safeSetState(() {
        _model.nomePiqueteTextController?.text = p.nome ?? '';
        _model.areaTextController?.text =
            p.area?.toString() ?? '';
        _model.anotacoesTextController?.text = p.anotacoes ?? '';
        _model.incluirPiquete = p.incluirPiquete ?? 'animal';
        _model.dDForrageiraValue = List<String>.from(p.forrageria);
        _model.dDForrageiraValueController =
            FormListFieldController<String>(_model.dDForrageiraValue);
        _model.loaded = true;
      });

      // Load selected animals
      if (p.idRebanhos.isNotEmpty) {
        // Convert to RebanhoDTStruct for consistency
        final apiResp = await FunctionsSupabaseRebanhoGroup
            .buscarRebanhoFiltrosCall
            .call(
          pCategoria: '',
          pDataNascimento: '',
          pIdPropriedade:
              FFAppState().propriedadeSelecionada.idPropriedade,
          pLoteNome: '',
          pOrigem: '',
          pRaca: '',
          pSexo: '',
          pStatus: '',
          pLimite: 1000,
          pOffset: 0,
          pPesquisa: '',
        );
        if (apiResp.succeeded) {
          final all = (apiResp.jsonBody
                  .toList()
                  .map<RebanhoDTStruct?>(RebanhoDTStruct.maybeFromMap)
                  .toList() as Iterable<RebanhoDTStruct?>)
              .withoutNulls
              .toList();
          safeSetState(() {
            _model.animaisSelecionados = all
                .where((a) => p.idRebanhos.contains(a.idRebanho))
                .toList();
          });
        }
      }

      // Load selected lotes
      if (p.idLotes.isNotEmpty) {
        final lotes = await LotesTable().queryRows(
          queryFn: (q) => q
              .inFilterOrNull('id_lote', p.idLotes)
              .neqOrNull('deletado', 'SIM'),
        );
        safeSetState(() {
          _model.lotesSelecionados = lotes;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  TextStyle _labelStyle(BuildContext context) =>
      FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            fontSize: 16.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          );

  InputDecoration _inputDecoration(BuildContext context, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontStyle:
                    FlutterFlowTheme.of(context).labelMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).customColor5,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 1.5,
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
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
      );

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    const int pageSize = 20;

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
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              32.0, 34.0, 32.0, 34.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    FlutterFlowIconButton(
                                      borderRadius: 8.0,
                                      buttonSize: 40.0,
                                      icon: Icon(
                                        Icons.arrow_back_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        context.safePop();
                                      },
                                    ),
                                    Text(
                                      'Editar piquete',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 32.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ].divide(const SizedBox(width: 16.0)),
                                ),
                                if (!_model.loaded)
                                  Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  )
                                else ...[
                                  // Form
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4.0,
                                          color: Color(0x33000000),
                                          offset: Offset(0.0, 2.0),
                                        )
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: const Color(0xFFEDEDED),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Nome
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Nome *',
                                                  style:
                                                      _labelStyle(context)),
                                              TextFormField(
                                                controller: _model
                                                    .nomePiqueteTextController,
                                                focusNode: _model
                                                    .nomePiqueteFocusNode,
                                                decoration: _inputDecoration(
                                                    context,
                                                    'Nome do piquete'),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                    ),
                                                validator: _model
                                                    .nomePiqueteTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 8.0)),
                                          ),
                                          // Área
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Área (ha) *',
                                                  style:
                                                      _labelStyle(context)),
                                              TextFormField(
                                                controller:
                                                    _model.areaTextController,
                                                focusNode:
                                                    _model.areaFocusNode,
                                                keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                    decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(
                                                          r'[0-9.,]')),
                                                  TextInputFormatter
                                                      .withFunction(
                                                          (oldValue,
                                                              newValue) {
                                                    String text = newValue
                                                        .text
                                                        .replaceAll(
                                                            ',', '.');
                                                    if ('.'
                                                            .allMatches(
                                                                text)
                                                            .length >
                                                        1) {
                                                      return oldValue;
                                                    }
                                                    return newValue
                                                        .copyWith(
                                                            text: text);
                                                  }),
                                                ],
                                                decoration: _inputDecoration(
                                                    context, 'Ex: 5.0'),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                    ),
                                                validator: _model
                                                    .areaTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 8.0)),
                                          ),
                                          // Forrageira
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Forrageira',
                                                  style:
                                                      _labelStyle(context)),
                                              FutureBuilder<
                                                  List<ForrageirasRow>>(
                                                future: ForrageirasTable()
                                                    .queryRows(
                                                  queryFn: (q) => q.order(
                                                      'nome',
                                                      ascending: true),
                                                ),
                                                builder: (context, snapshot) {
                                                  final opts =
                                                      (snapshot.data ?? [])
                                                          .map((f) => f.nome)
                                                          .toList();
                                                  return FlutterFlowDropDown<
                                                      String>(
                                                    multiSelectController: _model
                                                            .dDForrageiraValueController ??=
                                                        FormListFieldController<
                                                            String>(null),
                                                    options: opts,
                                                    onMultiSelectChanged: (val) =>
                                                        safeSetState(() =>
                                                            _model.dDForrageiraValue =
                                                                val),
                                                    height: 56.0,
                                                    textStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .poppins(
                                                                fontWeight: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                    hintText: 'Selecionar',
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryText,
                                                      size: 24.0,
                                                    ),
                                                    fillColor: const Color(
                                                        0xFFF1F1F1),
                                                    elevation: 2.0,
                                                    borderColor:
                                                        Colors.transparent,
                                                    borderWidth: 0.0,
                                                    borderRadius: 8.0,
                                                    margin:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(12.0,
                                                                0.0, 12.0, 0.0),
                                                    hidesUnderline: true,
                                                    isOverButton: false,
                                                    isSearchable: false,
                                                    isMultiSelect: true,
                                                  );
                                                },
                                              ),
                                            ].divide(
                                                const SizedBox(height: 8.0)),
                                          ),
                                          // Anotações
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Anotações',
                                                  style:
                                                      _labelStyle(context)),
                                              TextFormField(
                                                controller: _model
                                                    .anotacoesTextController,
                                                focusNode:
                                                    _model.anotacoesFocusNode,
                                                maxLines: 4,
                                                decoration: _inputDecoration(
                                                    context, 'Anotações...'),
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodyMedium
                                                    .override(
                                                      font: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                      letterSpacing: 0.0,
                                                    ),
                                                validator: _model
                                                    .anotacoesTextControllerValidator
                                                    .asValidator(context),
                                              ),
                                            ].divide(
                                                const SizedBox(height: 8.0)),
                                          ),
                                          // Tipo de inclusão
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Incluir no piquete',
                                                  style:
                                                      _labelStyle(context)),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'animal',
                                                    groupValue:
                                                        _model.incluirPiquete,
                                                    activeColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    onChanged: (val) {
                                                      if (val != null) {
                                                        safeSetState(() {
                                                          _model.incluirPiquete =
                                                              val;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    'Animais',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium,
                                                  ),
                                                  const SizedBox(width: 24.0),
                                                  Radio<String>(
                                                    value: 'lote',
                                                    groupValue:
                                                        _model.incluirPiquete,
                                                    activeColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                    onChanged: (val) {
                                                      if (val != null) {
                                                        safeSetState(() {
                                                          _model.incluirPiquete =
                                                              val;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  Text(
                                                    'Lotes',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium,
                                                  ),
                                                ],
                                              ),
                                            ].divide(
                                                const SizedBox(height: 8.0)),
                                          ),
                                        ].divide(const SizedBox(height: 20.0)),
                                      ),
                                    ),
                                  ),
                                  // Dual-list
                                  if (_model.incluirPiquete == 'animal')
                                    _buildAnimaisDualList(context, pageSize)
                                  else
                                    _buildLotesDualList(context),
                                  // Save button
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      FFButtonWidget(
                                        onPressed: () async {
                                          if (_model.nomePiqueteTextController
                                              .text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Nome é obrigatório.',
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: const Duration(
                                                    milliseconds: 3000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                              ),
                                            );
                                            return;
                                          }
                                          await PiqueteTable().update(
                                            data: {
                                              'nome': _model
                                                  .nomePiqueteTextController
                                                  .text,
                                              'area': double.tryParse(_model
                                                  .areaTextController.text
                                                  .replaceAll(',', '.')),
                                              'forrageria': _model
                                                      .dDForrageiraValue ??
                                                  [],
                                              'anotacoes': _model
                                                  .anotacoesTextController
                                                  .text,
                                              'incluir_piquete':
                                                  _model.incluirPiquete,
                                              'id_rebanhos': _model
                                                  .animaisSelecionados
                                                  .map((a) => a.idRebanho)
                                                  .whereType<String>()
                                                  .toList(),
                                              'id_lotes': _model
                                                  .lotesSelecionados
                                                  .map((l) => l.idLote)
                                                  .whereType<String>()
                                                  .toList(),
                                            },
                                            matchingRows: (rows) => rows
                                                .eqOrNull('id_piquete',
                                                    widget.idPiquete),
                                          );
                                          FFAppState().refreshPiquete = true;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Piquete atualizado com sucesso!',
                                                style: TextStyle(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                ),
                                              ),
                                              duration: const Duration(
                                                  milliseconds: 3000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                            ),
                                          );
                                          context.safePop();
                                        },
                                        text: 'Salvar',
                                        options: FFButtonOptions(
                                          height: 56.0,
                                          padding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      32.0, 0.0, 32.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle: FlutterFlowTheme.of(
                                                  context)
                                              .titleSmall
                                              .override(
                                                font: GoogleFonts.poppins(
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
                                              ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ].divide(const SizedBox(height: 24.0)),
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
  }

  String _formatDateBR(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildAnimalItem(BuildContext context, RebanhoDTStruct animal,
      {required bool checked, required ValueChanged<bool?> onChanged}) {
    final isFemea = animal.sexo == 'Fêmea';
    final sexoColor =
        isFemea ? const Color(0xFFC429CC) : const Color(0xFF2973CC);
    final sexoIcon = isFemea ? Icons.female : Icons.male;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24.0,
            height: 24.0,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
              activeColor: const Color(0xFF28A365),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              side: const BorderSide(color: Color(0xFFBEBEBE)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pets,
                        size: 20.0, color: Color(0xFF474747)),
                    const SizedBox(width: 2.0),
                    Icon(sexoIcon, size: 20.0, color: sexoColor),
                  ],
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 4.0,
                  children: [
                    Text(
                      animal.numeroAnimal.isNotEmpty
                          ? animal.numeroAnimal
                          : '-',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF474747),
                      ),
                    ),
                    Text(' \u2022 ',
                        style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            color: const Color(0xFF474747))),
                    Text(
                      animal.nome.isNotEmpty ? animal.nome : '-',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF474747),
                      ),
                    ),
                    Text(' \u2022 ',
                        style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            color: const Color(0xFF474747))),
                    Text(
                      _formatDateBR(animal.dataNascimento),
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF474747),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    Text(
                      animal.categoria.isNotEmpty
                          ? animal.categoria
                          : '-',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5F5F5F),
                      ),
                    ),
                    Text(' \u2022 ',
                        style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF474747))),
                    Flexible(
                      child: Text(
                        animal.raca.isNotEmpty ? animal.raca : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF5F5F5F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Row(
                  children: [
                    const Icon(Icons.workspaces_outline,
                        size: 17.0, color: Color(0xFF5F5F5F)),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        animal.loteNome.isNotEmpty
                            ? animal.loteNome
                            : 'Animal sem lote',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF5F5F5F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalPanelCard({
    required BuildContext context,
    required String title,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
    required VoidCallback onSearchChanged,
    required Widget listContent,
    Widget? headerAction,
    Widget? bottomButton,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x40000000),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 8.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 4.0),
              child: TextFormField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: (_) => EasyDebounce.debounce(
                  'search_${searchController.hashCode}',
                  const Duration(milliseconds: 1500),
                  onSearchChanged,
                ),
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E8E8E),
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF8E8E8E), size: 24.0),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF474747),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFBEBEBE)),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtrar',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5F5F5F),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Icon(Icons.tune,
                      size: 16.0, color: Color(0xFF5F5F5F)),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            const Divider(height: 1.0, color: Color(0xFFEDEDED)),
            const SizedBox(height: 24.0),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFBEBEBE)),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_upward,
                      size: 16.0, color: Color(0xFF474747)),
                  const SizedBox(width: 8.0),
                  Text(
                    'Crescente',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    width: 1.0,
                    height: 20.0,
                    color: const Color(0xFFBEBEBE),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Nome do animal',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E7A4C),
                    ),
                  ),
                  const Icon(Icons.expand_more,
                      size: 24.0, color: Color(0xFF1E7A4C)),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            if (headerAction != null) ...[
              headerAction,
              const SizedBox(height: 8.0),
            ],
            listContent,
            if (bottomButton != null) ...[
              const SizedBox(height: 24.0),
              bottomButton,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimaisDualList(BuildContext context, int pageSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel: Animais fora deste piquete
        Expanded(
          child: FutureBuilder<ApiCallResponse>(
            future: (_model.apiRequestCompleterAnimais ??=
                    Completer<ApiCallResponse>()
                      ..complete(FunctionsSupabaseRebanhoGroup
                          .buscarRebanhoFiltrosCall
                          .call(
                        pCategoria: '',
                        pDataNascimento: '',
                        pIdPropriedade: FFAppState()
                            .propriedadeSelecionada
                            .idPropriedade,
                        pLoteNome: '',
                        pOrigem: '',
                        pRaca: '',
                        pSexo: '',
                        pStatus: 'Na propriedade',
                        pLimite: pageSize,
                        pOffset: functions.calcDeslocamento(
                            _model.pageNumAnimais, pageSize),
                        pPesquisa:
                            _model.pesquisaAnimaisTextController.text,
                      )))
                .future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: FlutterFlowTheme.of(context).error,
                        size: 36.0,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Erro ao carregar',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                );
              }
              final animais = snapshot.hasData
                  ? (snapshot.data!.jsonBody
                          .toList()
                          .map<RebanhoDTStruct?>(
                              RebanhoDTStruct.maybeFromMap)
                          .toList()
                      as Iterable<RebanhoDTStruct?>)
                      .withoutNulls
                      .where((a) => !_model.animaisSelecionados
                          .any((s) => s.idRebanho == a.idRebanho))
                      .toList()
                  : <RebanhoDTStruct>[];
              final totalFora = animais.length;

              return _buildAnimalPanelCard(
                context: context,
                title: 'Animais fora deste piquete ($totalFora)',
                searchController:
                    _model.pesquisaAnimaisTextController!,
                searchFocusNode:
                    _model.pesquisaAnimaisFocusNode!,
                onSearchChanged: () {
                  _model.apiRequestCompleterAnimais = null;
                  safeSetState(() {});
                },
                headerAction: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: Checkbox(
                            value: animais.isNotEmpty &&
                                animais.every((a) =>
                                    _model.checkboxAnimaisMap[
                                            a] ==
                                        true),
                            onChanged: (val) {
                              safeSetState(() {
                                for (final a in animais) {
                                  _model.checkboxAnimaisMap[a] =
                                      val ?? false;
                                }
                              });
                            },
                            activeColor:
                                const Color(0xFF28A365),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(3.0),
                            ),
                            side: const BorderSide(
                                color: Color(0xFFBEBEBE)),
                            materialTapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                            visualDensity:
                                VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Selecionar todos',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF474747),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        safeSetState(() {
                          final toAdd =
                              _model.animaisChecked;
                          for (final a in toAdd) {
                            if (!_model.animaisSelecionados
                                .any((s) =>
                                    s.idRebanho ==
                                    a.idRebanho)) {
                              _model.animaisSelecionados
                                  .add(a);
                            }
                            _model.checkboxAnimaisMap
                                .remove(a);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A365),
                          borderRadius:
                              BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Adicionar',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                listContent: !snapshot.hasData
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(
                              FlutterFlowTheme.of(context)
                                  .primary,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 400.0,
                        child: ListView.builder(
                          itemCount: animais.length,
                          itemBuilder: (context, i) {
                            final animal = animais[i];
                            return _buildAnimalItem(
                              context,
                              animal,
                              checked: _model
                                          .checkboxAnimaisMap[
                                      animal] ??
                                  false,
                              onChanged: (val) {
                                safeSetState(() {
                                  _model.checkboxAnimaisMap[
                                          animal] =
                                      val ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ),
                bottomButton: GestureDetector(
                  onTap: () {
                    safeSetState(() {
                      final toAdd = _model.animaisChecked;
                      for (final a in toAdd) {
                        if (!_model.animaisSelecionados.any(
                            (s) =>
                                s.idRebanho ==
                                a.idRebanho)) {
                          _model.animaisSelecionados.add(a);
                        }
                        _model.checkboxAnimaisMap.remove(a);
                      }
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF28A365),
                      borderRadius:
                          BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      'Contar animais (${_model.animaisChecked.length}/$totalFora)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Arrow buttons
        Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  safeSetState(() {
                    final toAdd = _model.animaisChecked;
                    for (final a in toAdd) {
                      if (!_model.animaisSelecionados.any(
                          (s) =>
                              s.idRebanho == a.idRebanho)) {
                        _model.animaisSelecionados.add(a);
                      }
                      _model.checkboxAnimaisMap.remove(a);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A365),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 24.0),
                ),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  safeSetState(() {
                    final toRemove = _model
                        .animaisSelecionados
                        .where((a) =>
                            _model.checkboxAnimaisMap[a] ==
                            true)
                        .toList();
                    for (final a in toRemove) {
                      _model.animaisSelecionados.remove(a);
                      _model.checkboxAnimaisMap.remove(a);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEBEBE),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 24.0),
                ),
              ),
            ],
          ),
        ),
        // Right panel: Animais neste piquete
        Expanded(
          child: _buildAnimalPanelCard(
            context: context,
            title:
                'Animais neste piquete (${_model.animaisSelecionados.length})',
            searchController:
                _model.pesquisaAnimaisTextController!,
            searchFocusNode:
                _model.pesquisaAnimaisFocusNode!,
            onSearchChanged: () => safeSetState(() {}),
            listContent: _model.animaisSelecionados.isEmpty
                ? SizedBox(
                    height: 300.0,
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pets,
                              size: 58.0,
                              color: Color(0xFFBEBEBE)),
                          const SizedBox(height: 16.0),
                          Text(
                            'Nenhum animal foi adicionado neste piquete.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF474747),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Selecione um animal e clique no botão',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.0,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: const Color(
                                        0xFF474747),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' à esquerda para adicionar.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.0,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: const Color(
                                        0xFF474747),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 400.0,
                    child: ListView.builder(
                      itemCount:
                          _model.animaisSelecionados.length,
                      itemBuilder: (context, i) {
                        final animal =
                            _model.animaisSelecionados[i];
                        return _buildAnimalItem(
                          context,
                          animal,
                          checked: _model
                                      .checkboxAnimaisMap[
                                  animal] ??
                              false,
                          onChanged: (val) {
                            safeSetState(() {
                              _model.checkboxAnimaisMap[
                                      animal] =
                                  val ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoteItem(
    BuildContext context,
    LotesRow lote, {
    required bool checked,
    required ValueChanged<bool?> onChanged,
  }) {
    final isAtivo = lote.ativo?.toLowerCase() != 'nao';
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        children: [
          SizedBox(
            width: 24.0,
            height: 24.0,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
              activeColor: const Color(0xFF28A365),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0),
              ),
              side: const BorderSide(color: Color(0xFFBEBEBE)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lotes icon
                Icon(Icons.hub_outlined,
                    size: 24.0, color: const Color(0xFF28A365)),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lote.nome ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF474747),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${_countAnimaisLote(lote)} animais',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 64.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: isAtivo
                            ? const Color(0xFFD6F5E5)
                            : const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        isAtivo ? 'Ativo' : 'Inativo',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: isAtivo
                              ? const Color(0xFF1E7A4C)
                              : const Color(0xFF5F5F5F),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _countAnimaisLote(LotesRow lote) {
    final ids = lote.idAnimais;
    if (ids == null || ids.isEmpty) return 0;
    return ids.split(',').where((s) => s.trim().isNotEmpty).length;
  }

  Widget _buildLotePanelCard({
    required BuildContext context,
    required String title,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
    required VoidCallback onSearchChanged,
    required Widget listContent,
    Widget? headerAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x40000000),
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF181818),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: TextFormField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: (_) => EasyDebounce.debounce(
                  'search_lote_${searchController.hashCode}',
                  const Duration(milliseconds: 1500),
                  onSearchChanged,
                ),
                decoration: InputDecoration(
                  hintText: 'Pesquisar',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E8E8E),
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF8E8E8E), size: 24.0),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF474747),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            // Filtrar button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFBEBEBE)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtrar',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5F5F5F),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const Icon(Icons.tune, size: 16.0, color: Color(0xFF5F5F5F)),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Divider
            const Divider(height: 1.0, color: Color(0xFFEDEDED)),
            const SizedBox(height: 24.0),
            // Sort control
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(color: const Color(0xFFBEBEBE)),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_upward,
                      size: 16.0, color: Color(0xFF474747)),
                  const SizedBox(width: 8.0),
                  Text(
                    'Crescente',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF474747),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    width: 1.0,
                    height: 20.0,
                    color: const Color(0xFFBEBEBE),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Nome do lote',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E7A4C),
                    ),
                  ),
                  const Icon(Icons.expand_more,
                      size: 24.0, color: Color(0xFF1E7A4C)),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Optional header action (Selecionar todos + Adicionar)
            if (headerAction != null) ...[
              headerAction,
              const SizedBox(height: 8.0),
            ],
            // List content
            listContent,
          ],
        ),
      ),
    );
  }

  Widget _buildLotesDualList(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel: Lotes fora deste piquete
        Expanded(
          child: FutureBuilder<List<LotesRow>>(
            future: LotesTable().queryRows(
              queryFn: (q) => q
                  .eqOrNull('id_propriedade',
                      FFAppState().propriedadeSelecionada.idPropriedade)
                  .neqOrNull('deletado', 'SIM')
                  .ilike('nome',
                      '%${_model.pesquisaLotesTextController?.text ?? ''}%')
                  .order('nome', ascending: true),
            ),
            builder: (context, snapshot) {
              final lotesDisponiveis = snapshot.hasData
                  ? snapshot.data!
                      .where((l) => !_model.lotesSelecionados
                          .any((s) => s.idLote == l.idLote))
                      .toList()
                  : <LotesRow>[];
              final totalFora = lotesDisponiveis.length;

              return _buildLotePanelCard(
                context: context,
                title: 'Lotes fora deste piquete ($totalFora)',
                searchController: _model.pesquisaLotesTextController!,
                searchFocusNode: _model.pesquisaLotesFocusNode!,
                onSearchChanged: () => safeSetState(() {}),
                headerAction: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: Checkbox(
                            value: lotesDisponiveis.isNotEmpty &&
                                lotesDisponiveis.every((l) =>
                                    _model.checkboxLotesMap[l] == true),
                            onChanged: (val) {
                              safeSetState(() {
                                for (final l in lotesDisponiveis) {
                                  _model.checkboxLotesMap[l] = val ?? false;
                                }
                              });
                            },
                            activeColor: const Color(0xFF28A365),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            side: const BorderSide(color: Color(0xFFBEBEBE)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Selecionar todos',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF474747),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        safeSetState(() {
                          final toAdd = _model.lotesChecked;
                          for (final l in toAdd) {
                            if (!_model.lotesSelecionados
                                .any((s) => s.idLote == l.idLote)) {
                              _model.lotesSelecionados.add(l);
                            }
                            _model.checkboxLotesMap.remove(l);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF28A365),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Adicionar',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                listContent: !snapshot.hasData
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 400.0,
                        child: ListView.builder(
                          itemCount: lotesDisponiveis.length,
                          itemBuilder: (context, i) {
                            final lote = lotesDisponiveis[i];
                            return _buildLoteItem(
                              context,
                              lote,
                              checked:
                                  _model.checkboxLotesMap[lote] ?? false,
                              onChanged: (val) {
                                safeSetState(() {
                                  _model.checkboxLotesMap[lote] =
                                      val ?? false;
                                });
                              },
                            );
                          },
                        ),
                      ),
              );
            },
          ),
        ),
        // Arrow buttons
        Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  safeSetState(() {
                    final toAdd = _model.lotesChecked;
                    for (final l in toAdd) {
                      if (!_model.lotesSelecionados
                          .any((s) => s.idLote == l.idLote)) {
                        _model.lotesSelecionados.add(l);
                      }
                      _model.checkboxLotesMap.remove(l);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28A365),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 24.0),
                ),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  safeSetState(() {
                    final toRemove = _model.lotesSelecionados
                        .where(
                            (l) => _model.checkboxLotesMap[l] == true)
                        .toList();
                    for (final l in toRemove) {
                      _model.lotesSelecionados.remove(l);
                      _model.checkboxLotesMap.remove(l);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEBEBE),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 24.0),
                ),
              ),
            ],
          ),
        ),
        // Right panel: Lotes neste piquete
        Expanded(
          child: _buildLotePanelCard(
            context: context,
            title:
                'Lotes neste piquete (${_model.lotesSelecionados.length})',
            searchController: _model.pesquisaLotesTextController!,
            searchFocusNode: _model.pesquisaLotesFocusNode!,
            onSearchChanged: () => safeSetState(() {}),
            listContent: _model.lotesSelecionados.isEmpty
                ? SizedBox(
                    height: 300.0,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hub_outlined,
                              size: 77.0,
                              color: const Color(0xFFBEBEBE)),
                          const SizedBox(height: 16.0),
                          Text(
                            'Nenhum lote foi adicionado neste piquete.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF474747),
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Selecione um lote e clique no botão',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF474747),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' à esquerda para adicionar.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF474747),
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 400.0,
                    child: ListView.builder(
                      itemCount: _model.lotesSelecionados.length,
                      itemBuilder: (context, i) {
                        final lote = _model.lotesSelecionados[i];
                        return _buildLoteItem(
                          context,
                          lote,
                          checked:
                              _model.checkboxLotesMap[lote] ?? false,
                          onChanged: (val) {
                            safeSetState(() {
                              _model.checkboxLotesMap[lote] =
                                  val ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
