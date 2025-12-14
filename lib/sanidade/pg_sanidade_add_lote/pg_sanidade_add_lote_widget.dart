import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'pg_sanidade_add_lote_model.dart';
export 'pg_sanidade_add_lote_model.dart';

class PgSanidadeAddLoteWidget extends StatefulWidget {
  const PgSanidadeAddLoteWidget({super.key});

  static const String routeName = '/pgSanidadeAddLote';

  @override
  State<PgSanidadeAddLoteWidget> createState() =>
      _PgSanidadeAddLoteWidgetState();
}

class _PgSanidadeAddLoteWidgetState extends State<PgSanidadeAddLoteWidget> {
  late PgSanidadeAddLoteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgSanidadeAddLoteModel());

    _model.porcentagemLoteTextController ??= TextEditingController();
    _model.porcentagemLoteFocusNode ??= FocusNode();

    _model.vacinaOutrosTextController ??= TextEditingController();
    _model.vacinaOutrosFocusNode ??= FocusNode();

    _model.vacinaObsTextController ??= TextEditingController();
    _model.vacinaObsFocusNode ??= FocusNode();

    _model.antiparasitarioOutrosTextController ??= TextEditingController();
    _model.antiparasitarioOutrosFocusNode ??= FocusNode();

    _model.antiparasitarioObsTextController ??= TextEditingController();
    _model.antiparasitarioObsFocusNode ??= FocusNode();

    _model.tratamentoOutrosTextController ??= TextEditingController();
    _model.tratamentoOutrosFocusNode ??= FocusNode();

    _model.tratamentoObsTextController ??= TextEditingController();
    _model.tratamentoObsFocusNode ??= FocusNode();

    _model.protocoloOutrosTextController ??= TextEditingController();
    _model.protocoloOutrosFocusNode ??= FocusNode();

    _model.protocoloObsTextController ??= TextEditingController();
    _model.protocoloObsFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            48, 48, 48, 48),
                        child: Container(
                          width: 709,
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Título
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sanidade',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Poppins',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            'Adicionar sanidade em um lote',
                                            style: FlutterFlowTheme.of(context)
                                                .headlineLarge
                                                .override(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 40,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  FlutterFlowIconButton(
                                    borderRadius: 8,
                                    buttonSize: 40,
                                    icon: Icon(
                                      Icons.close,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      context.safePop();
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Campo Lote
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lote*',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<List<LotesRow>>(
                                    future: LotesTable().queryRows(
                                      queryFn: (q) => q.eqOrNull(
                                        'id_propriedade',
                                        FFAppState()
                                            .propriedadeSelecionada
                                            .idPropriedade,
                                      ),
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container(
                                          width: double.infinity,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      final lotes = snapshot.data!;
                                      return FlutterFlowDropDown<String>(
                                        controller: _model
                                                .loteDropdownValueController ??=
                                            FormFieldController<String>(null),
                                        options: lotes
                                            .map((lote) => lote.id.toString())
                                            .toList(),
                                        optionLabels: lotes
                                            .map((lote) => lote.nome ?? '')
                                            .toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _model.loteSelecionadoId =
                                                int.tryParse(val ?? '');
                                            final lote = lotes.firstWhere(
                                              (l) => l.id.toString() == val,
                                            );
                                            _model.loteSelecionadoNome =
                                                lote.nome;
                                          });
                                        },
                                        width: double.infinity,
                                        height: 56,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        hintText: 'Selecionar',
                                        icon: Icon(
                                          Icons.expand_more,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 24,
                                        ),
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        elevation: 0,
                                        borderColor: Colors.transparent,
                                        borderWidth: 0,
                                        borderRadius: 6,
                                        margin: const EdgeInsetsDirectional
                                            .fromSTEB(16, 16, 10, 16),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Campo Porcentagem do lote
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Porcentagem do lote (%)',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller:
                                        _model.porcentagemLoteTextController,
                                    focusNode: _model.porcentagemLoteFocusNode,
                                    autofocus: false,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      hintText: '% do lote',
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Poppins',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 16,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0x00000000),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      filled: true,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16, 16, 10, 16),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Campo Data da sanidade
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data da sanidade*',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      final datePicked = await showDatePicker(
                                        context: context,
                                        initialDate: getCurrentTimestamp,
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2050),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.light(
                                                    useMaterial3: false)
                                                .copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (datePicked != null) {
                                        setState(() {
                                          _model.dataSanidade = datePicked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 16, 10, 16),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _model.dataSanidade != null
                                                  ? dateTimeFormat(
                                                      'dd/MM/yyyy',
                                                      _model.dataSanidade,
                                                      locale: 'pt_BR',
                                                    )
                                                  : 'dd/mm/aaaa',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Poppins',
                                                    color: _model
                                                                .dataSanidade !=
                                                            null
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Botão dropdown "Adicionar sanidade"
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          enableDrag: false,
                                          context: context,
                                          builder: (context) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  FocusScope.of(context)
                                                      .unfocus(),
                                              child: Padding(
                                                padding:
                                                    MediaQuery.viewInsetsOf(
                                                        context),
                                                child:
                                                    _buildTiposSanidadeModal(),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      text: 'Adicionar sanidade',
                                      icon: const Icon(
                                        Icons.expand_more,
                                        size: 24,
                                      ),
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 12, 24, 12),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 0, 0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Pills dos tipos selecionados
                              if (_model.tiposSelecionados.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _model.tiposSelecionados.map((tipo) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD6F5E5),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(16, 8, 16, 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tipo,
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Poppins',
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontSize: 16,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _model.tiposSelecionados
                                                      .remove(tipo);
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                              const SizedBox(height: 32),

                              // Seção Vacinação
                              if (_model.tiposSelecionados
                                  .contains('Vacinação'))
                                _buildVacinacaoSection(),

                              // Seção Antiparasitário
                              if (_model.tiposSelecionados
                                  .contains('Antiparasitário'))
                                _buildAntiparasitarioSection(),

                              // Seção Tratamento
                              if (_model.tiposSelecionados
                                  .contains('Tratamento'))
                                _buildTratamentoSection(),

                              // Seção Protocolo reprodutivo
                              if (_model.tiposSelecionados
                                  .contains('Protocolo reprodutivo'))
                                _buildProtocoloSection(),

                              const SizedBox(height: 32),

                              // Botões Cancelar e Salvar
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        context.safePop();
                                      },
                                      text: 'Cancelar',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 12, 24, 12),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 0, 0),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Poppins',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        elevation: 0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await _salvarSanidade();
                                      },
                                      text: 'Salvar',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 12, 24, 12),
                                        iconPadding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 0, 0),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Poppins',
                                              color: Colors.white,
                                              fontSize: 18,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTiposSanidadeModal() {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCheckboxTile('Vacinação'),
          _buildCheckboxTile('Antiparasitário'),
          _buildCheckboxTile('Tratamento'),
          _buildCheckboxTile('Protocolo reprodutivo'),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String tipo) {
    final isSelected = _model.tiposSelecionados.contains(tipo);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _model.tiposSelecionados.remove(tipo);
          } else {
            _model.tiposSelecionados.add(tipo);
          }
        });
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                tipo,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: isSelected
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 20,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVacinacaoSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Vacinação',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vacinas*',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            FlutterFlowDropDown<String>(
              controller: _model.vacinaDropdownValueController ??=
                  FormFieldController<String>(null),
              options: const [
                'Diarréia (BVD)',
                'Leptospirose',
                'Raiva',
                'Antitetânica',
              ],
              onChanged: (val) =>
                  setState(() => _model.vacinaDropdownValue = val),
              width: double.infinity,
              height: 56,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              hintText: 'Selecionar',
              icon: Icon(
                Icons.expand_more,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              elevation: 0,
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 6,
              margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vacinas (outros)',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.vacinaOutrosTextController,
              focusNode: _model.vacinaOutrosFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Vacinas',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observação',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.vacinaObsTextController,
              focusNode: _model.vacinaObsFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Observação',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAntiparasitarioSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Antiparasitário',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antiparasitário*',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            FlutterFlowDropDown<String>(
              controller: _model.antiparasitarioDropdownValueController ??=
                  FormFieldController<String>(null),
              options: const [
                'Abamectina',
                'Albendazol',
                'Deltrametrina',
                'Ivermectina',
              ],
              onChanged: (val) =>
                  setState(() => _model.antiparasitarioDropdownValue = val),
              width: double.infinity,
              height: 56,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              hintText: 'Selecionar',
              icon: Icon(
                Icons.expand_more,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              elevation: 0,
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 6,
              margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Antiparasitário (outros)',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.antiparasitarioOutrosTextController,
              focusNode: _model.antiparasitarioOutrosFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Antiparasitário',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observação',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.antiparasitarioObsTextController,
              focusNode: _model.antiparasitarioObsFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Observação',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTratamentoSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Tratamento',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tratamento*',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            FlutterFlowDropDown<String>(
              controller: _model.tratamentoDropdownValueController ??=
                  FormFieldController<String>(null),
              options: const [
                'Antibiótico',
                'Anti-inflamatório',
                'Cicatrizante',
              ],
              onChanged: (val) =>
                  setState(() => _model.tratamentoDropdownValue = val),
              width: double.infinity,
              height: 56,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              hintText: 'Selecionar',
              icon: Icon(
                Icons.expand_more,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              elevation: 0,
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 6,
              margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tratamento (outros)',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.tratamentoOutrosTextController,
              focusNode: _model.tratamentoOutrosFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Tratamento',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observação',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.tratamentoObsTextController,
              focusNode: _model.tratamentoObsFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Observação',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProtocoloSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Protocolo reprodutivo',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Protocolo reprodutivo*',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            FlutterFlowDropDown<String>(
              controller: _model.protocoloDropdownValueController ??=
                  FormFieldController<String>(null),
              options: const [
                'IATF',
                'Sincronização de cio',
                'Transferência de embrião',
              ],
              onChanged: (val) =>
                  setState(() => _model.protocoloDropdownValue = val),
              width: double.infinity,
              height: 56,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              hintText: 'Selecionar',
              icon: Icon(
                Icons.expand_more,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 24,
              ),
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              elevation: 0,
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 6,
              margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Protocolo reprodutivo (outros)',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.protocoloOutrosTextController,
              focusNode: _model.protocoloOutrosFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Protocolo reprodutivo',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observação',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _model.protocoloObsTextController,
              focusNode: _model.protocoloObsFocusNode,
              autofocus: false,
              obscureText: false,
              decoration: InputDecoration(
                hintText: 'Observação',
                hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0x00000000),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                contentPadding:
                    const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _salvarSanidade() async {
    // Validação
    if (_model.loteSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um lote'),
        ),
      );
      return;
    }

    if (_model.dataSanidade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione a data da sanidade'),
        ),
      );
      return;
    }

    if (_model.tiposSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um tipo de sanidade'),
        ),
      );
      return;
    }

    try {
      // TODO: Implementar lógica de buscar animais do lote e criar registro para cada um
      // Por enquanto apenas mostra mensagem de sucesso

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sanidade registrada com sucesso para o lote!'),
          backgroundColor: Colors.green,
        ),
      );

      context.safePop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar sanidade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
