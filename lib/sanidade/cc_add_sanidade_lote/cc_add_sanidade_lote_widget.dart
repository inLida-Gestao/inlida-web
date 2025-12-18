import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:flutter/material.dart';
import 'cc_add_sanidade_lote_model.dart';
export 'cc_add_sanidade_lote_model.dart';

class CcAddSanidadeLoteWidget extends StatefulWidget {
  const CcAddSanidadeLoteWidget({
    super.key,
    required this.action,
  });

  final Future Function(String? page)? action;

  @override
  State<CcAddSanidadeLoteWidget> createState() =>
      _CcAddSanidadeLoteWidgetState();
}

class _CcAddSanidadeLoteWidgetState extends State<CcAddSanidadeLoteWidget> {
  late CcAddSanidadeLoteModel _model;

  static const List<String> _kProtocoloD0Options = <String>[
    'BE + Implante novo',
    'BE + Implante novo + PGF',
    'BE + Implante reuso',
    'BE + Implante reuso + PGF',
  ];

  static const List<String> _kProtocoloRetiradaOptions = <String>[
    'eCG + PGF + CE',
    'PGF + eCG',
    'CE + eCG',
    'PGF + CE',
  ];

  static const List<String> _kProtocoloIatfOptions = <String>[
    'Com GnRH',
    'Sem GnRH',
  ];

  String? _loteSelecionadoId;
  String? _loteSelecionadoDbId;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CcAddSanidadeLoteModel());

    _model.porcentagemTextController ??= TextEditingController();
    _model.porcentagemFocusNode ??= FocusNode();

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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 709,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(48, 48, 48, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Título
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sanidade',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Poppins',
                            color: FlutterFlowTheme.of(context).secondaryText,
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
                                fontSize: 20,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Conteúdo com scroll
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<LotesRow>>(
                          future: LotesTable().queryRows(
                            queryFn: (q) => q
                                .eqOrNull(
                                  'id_propriedade',
                                  FFAppState()
                                      .propriedadeSelecionada
                                      .idPropriedade,
                                )
                                .eqOrNull('deletado', 'NAO'),
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final lotes = snapshot.data!;
                            return FlutterFlowDropDown<String>(
                              controller: _model.loteDropdownValueController ??=
                                  FormFieldController<String>(null),
                              options: lotes
                                  .map((lote) =>
                                      lote.idLote ?? lote.id.toString())
                                  .toList(),
                              optionLabels:
                                  lotes.map((lote) => lote.nome ?? '').toList(),
                              hidesUnderline: true,
                              onChanged: (val) {
                                setState(() {
                                  final selected = lotes.where((lote) {
                                    final value =
                                        lote.idLote ?? lote.id.toString();
                                    return value == (val ?? '');
                                  }).toList();

                                  if ((val ?? '').isEmpty) {
                                    _loteSelecionadoId = null;
                                    _loteSelecionadoDbId = null;
                                  } else if (selected.isNotEmpty) {
                                    _loteSelecionadoId =
                                        selected.first.idLote ??
                                            selected.first.id.toString();
                                    _loteSelecionadoDbId =
                                        selected.first.id.toString();
                                  } else {
                                    _loteSelecionadoId = val;
                                    _loteSelecionadoDbId = null;
                                  }
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24,
                              ),
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              elevation: 0,
                              borderColor: Colors.transparent,
                              borderWidth: 0,
                              borderRadius: 6,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  16, 16, 10, 16),
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 16,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _model.porcentagemTextController,
                          focusNode: _model.porcentagemFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: '% do lote',
                            hintStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Poppins',
                                  color: const Color(0xFFBEBEBE),
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
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
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
                                  data: ThemeData.light(useMaterial3: false)
                                      .copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary:
                                          FlutterFlowTheme.of(context).primary,
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
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 16, 10, 16),
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
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: _model.dataSanidade != null
                                              ? FlutterFlowTheme.of(context)
                                                  .primaryText
                                              : const Color(0xFFBEBEBE),
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: FlutterFlowTheme.of(context)
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
                              await showDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierColor: const Color(0x99000000),
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, modalSetState) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(24),
                                        child: GestureDetector(
                                          onTap: () =>
                                              FocusScope.of(context).unfocus(),
                                          child: _buildTiposSanidadeModal(
                                            modalSetState,
                                          ),
                                        ),
                                      );
                                    },
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
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  24, 12, 24, 12),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              color: FlutterFlowTheme.of(context).primary,
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
                        children: _model.tiposSelecionados.map((tipo) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6F5E5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16, 8, 16, 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tipo,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: FlutterFlowTheme.of(context)
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
                                        _model.tiposSelecionados.remove(tipo);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
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
                    if (_model.tiposSelecionados.contains('Vacinação'))
                      _buildVacinacaoSection(),

                    // Seção Antiparasitário
                    if (_model.tiposSelecionados.contains('Antiparasitário'))
                      _buildAntiparasitarioSection(),

                    // Seção Tratamento
                    if (_model.tiposSelecionados.contains('Tratamento'))
                      _buildTratamentoSection(),

                    // Seção Protocolo reprodutivo
                    if (_model.tiposSelecionados
                        .contains('Protocolo reprodutivo'))
                      _buildProtocoloSection(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botões Cancelar e Salvar
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    text: 'Cancelar',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Poppins',
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 18,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                      elevation: 0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).primary,
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
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
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
    );
  }

  Widget _buildTiposSanidadeModal(void Function(VoidCallback) modalSetState) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 250,
        minWidth: 250,
      ),
      child: Container(
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
            _buildCheckboxTile('Vacinação', modalSetState),
            _buildCheckboxTile('Antiparasitário', modalSetState),
            _buildCheckboxTile('Tratamento', modalSetState),
            _buildCheckboxTile('Protocolo reprodutivo', modalSetState),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
      String tipo, void Function(VoidCallback) modalSetState) {
    final isSelected = _model.tiposSelecionados.contains(tipo);

    return InkWell(
      onTap: () {
        modalSetState(() {});
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
              multiSelectController: _model.vacinaDropdownValueController ??=
                  FormListFieldController<String>(null),
              options: FFAppState().vacinacao,
              isMultiSelect: true,
              onMultiSelectChanged: (val) =>
                  setState(() => _model.vacinaDropdownValue = val),
              hidesUnderline: true,
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
              multiSelectController:
                  _model.antiparasitarioDropdownValueController ??=
                      FormListFieldController<String>(null),
              options: FFAppState().antiparasitario,
              isMultiSelect: true,
              onMultiSelectChanged: (val) =>
                  setState(() => _model.antiparasitarioDropdownValue = val),
              hidesUnderline: true,
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
              multiSelectController:
                  _model.tratamentoDropdownValueController ??=
                      FormListFieldController<String>(null),
              options: FFAppState().tratamento,
              isMultiSelect: true,
              onMultiSelectChanged: (val) =>
                  setState(() => _model.tratamentoDropdownValue = val),
              hidesUnderline: true,
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
            Row(
              children: [
                Expanded(
                  child: FlutterFlowDropDown<String>(
                    controller: _model.protocoloDropdownValueController ??=
                        FormFieldController<String>(null),
                    options: FFAppState().protocoloReprodutivo,
                    onChanged: (val) =>
                        setState(() => _model.protocoloDropdownValue = val),
                    hidesUnderline: true,
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
                    margin:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
                  ),
                ),
                if ((_model.protocoloDropdownValue ?? '')
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(width: 8),
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 6,
                    buttonSize: 44,
                    icon: Icon(
                      Icons.close,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 24,
                    ),
                    onPressed: () {
                      _model.protocoloDropdownValueController?.reset();
                      setState(() => _model.protocoloDropdownValue = null);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'D0',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FlutterFlowDropDown<String>(
                    controller: _model.protocoloD0DropdownValueController ??=
                        FormFieldController<String>(null),
                    options: _kProtocoloD0Options,
                    onChanged: (val) =>
                        setState(() => _model.protocoloD0DropdownValue = val),
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
                    margin:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
                    hidesUnderline: true,
                  ),
                ),
                if ((_model.protocoloD0DropdownValue ?? '')
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(width: 8),
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 6,
                    buttonSize: 44,
                    icon: Icon(
                      Icons.close,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 24,
                    ),
                    onPressed: () {
                      _model.protocoloD0DropdownValueController?.reset();
                      setState(() => _model.protocoloD0DropdownValue = null);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Retirada',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FlutterFlowDropDown<String>(
                    controller:
                        _model.protocoloRetiradaDropdownValueController ??=
                            FormFieldController<String>(null),
                    options: _kProtocoloRetiradaOptions,
                    onChanged: (val) => setState(
                        () => _model.protocoloRetiradaDropdownValue = val),
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
                    margin:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
                    hidesUnderline: true,
                  ),
                ),
                if ((_model.protocoloRetiradaDropdownValue ?? '')
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(width: 8),
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 6,
                    buttonSize: 44,
                    icon: Icon(
                      Icons.close,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 24,
                    ),
                    onPressed: () {
                      _model.protocoloRetiradaDropdownValueController?.reset();
                      setState(
                          () => _model.protocoloRetiradaDropdownValue = null);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IATF',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FlutterFlowDropDown<String>(
                    controller: _model.protocoloIatfDropdownValueController ??=
                        FormFieldController<String>(null),
                    options: _kProtocoloIatfOptions,
                    onChanged: (val) =>
                        setState(() => _model.protocoloIatfDropdownValue = val),
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
                    margin:
                        const EdgeInsetsDirectional.fromSTEB(16, 16, 10, 16),
                    hidesUnderline: true,
                  ),
                ),
                if ((_model.protocoloIatfDropdownValue ?? '')
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(width: 8),
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 6,
                    buttonSize: 44,
                    icon: Icon(
                      Icons.close,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      size: 24,
                    ),
                    onPressed: () {
                      _model.protocoloIatfDropdownValueController?.reset();
                      setState(() => _model.protocoloIatfDropdownValue = null);
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Legenda',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 18,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'BE - Benzoato de estradiol',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                'Implante - Implante de progesterona',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                'PGF - Prostaglandina',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                'eCG - Gonadotrofina coriônica',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                'CE - Cipionato de estradiol',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                'GnRH - Gonadotrofina',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Poppins',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
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
    if (_loteSelecionadoId == null || _loteSelecionadoId!.trim().isEmpty) {
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
      final loteIdStr = _loteSelecionadoId!.trim();
      final loteDbIdStr = _loteSelecionadoDbId?.trim();

      // Buscar animais do lote
      final animaisDoLote = await RebanhoTable().queryRows(
        queryFn: (q) {
          // Alguns fluxos salvam `rebanho.loteID` como `lotes.id_lote` (String),
          // outros como `lotes.id` (int -> String). Tentamos os dois.
          if (loteDbIdStr != null &&
              loteDbIdStr.isNotEmpty &&
              loteDbIdStr != loteIdStr) {
            return q
                .or('loteID.eq.$loteIdStr,loteID.eq.$loteDbIdStr')
                .eqOrNull('deletado', 'NAO');
          }
          return q.eqOrNull('loteID', loteIdStr).eqOrNull('deletado', 'NAO');
        },
      );

      if (animaisDoLote.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum animal encontrado no lote selecionado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // (Opcional) armazenar a porcentagem informada (não filtra animais)
      final porcentagemText = _model.porcentagemTextController.text.trim();
      double? porcentagemSelecionada;
      if (porcentagemText.isNotEmpty) {
        final porcentagem = double.tryParse(porcentagemText);
        if (porcentagem == null || porcentagem <= 0 || porcentagem > 100) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Porcentagem inválida. Informe um valor entre 1 e 100'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        porcentagemSelecionada = porcentagem;
      }

      final animaisSelecionados = animaisDoLote;
      final qtdAnimais = animaisSelecionados.length;

      // Criar registro de sanidade para cada animal
      for (final animal in animaisSelecionados) {
        final idRebanhoValue = (animal.idRebanho ?? '').trim();
        if (idRebanhoValue.isEmpty) {
          throw Exception(
              'Animal sem idRebanho (rebanho.idRebanho) para gerar sanidade.');
        }

        final vacinaOutros = _model.vacinaOutrosTextController.text.trim();
        final vacinaObs = _model.vacinaObsTextController.text.trim();
        final antiparasitarioOutros =
            _model.antiparasitarioOutrosTextController.text.trim();
        final antiparasitarioObs =
            _model.antiparasitarioObsTextController.text.trim();
        final tratamentoOutros =
            _model.tratamentoOutrosTextController.text.trim();
        final tratamentoObs = _model.tratamentoObsTextController.text.trim();
        final protocoloOutros =
            _model.protocoloOutrosTextController.text.trim();
        final protocoloObs = _model.protocoloObsTextController.text.trim();
        final d0 = (_model.protocoloD0DropdownValue ?? '').trim();
        final retirada = (_model.protocoloRetiradaDropdownValue ?? '').trim();
        final iatf = (_model.protocoloIatfDropdownValue ?? '').trim();

        // Preparar dados do registro
        final dados = <String, dynamic>{
          'id_sanidade': random_data.randomString(20, 20, true, false, true),
          'id_rebanho': idRebanhoValue,
          'id_propriedade': FFAppState().propriedadeSelecionada.idPropriedade,
          'data_sanidade': supaSerialize<DateTime>(_model.dataSanidade),
          'updated_at': supaSerialize<DateTime>(DateTime.now()),
          'deletado': 'NAO',
          'id_lote': loteIdStr,
          'porcentagem_lote': porcentagemSelecionada,
        };

        // Adicionar campos específicos conforme tipo selecionado
        if (_model.tiposSelecionados.contains('Vacinação')) {
          dados['vacinacao'] = (_model.vacinaDropdownValue?.isNotEmpty ?? false)
              ? _model.vacinaDropdownValue!.join(', ')
              : null;
          dados['vacinacao_outros'] =
              vacinaOutros.isNotEmpty ? vacinaOutros : null;
          dados['vacinacao_obs'] = vacinaObs.isNotEmpty ? vacinaObs : null;
        }

        if (_model.tiposSelecionados.contains('Antiparasitário')) {
          dados['antiparasitario'] =
              (_model.antiparasitarioDropdownValue?.isNotEmpty ?? false)
                  ? _model.antiparasitarioDropdownValue!.join(', ')
                  : null;
          dados['antiparasitario_outros'] =
              antiparasitarioOutros.isNotEmpty ? antiparasitarioOutros : null;
          dados['antiparasitario_obs'] =
              antiparasitarioObs.isNotEmpty ? antiparasitarioObs : null;
        }

        if (_model.tiposSelecionados.contains('Tratamento')) {
          dados['tratamento'] =
              (_model.tratamentoDropdownValue?.isNotEmpty ?? false)
                  ? _model.tratamentoDropdownValue!.join(', ')
                  : null;
          dados['tratamento_outros'] =
              tratamentoOutros.isNotEmpty ? tratamentoOutros : null;
          dados['tratamento_obs'] =
              tratamentoObs.isNotEmpty ? tratamentoObs : null;
        }

        if (_model.tiposSelecionados.contains('Protocolo reprodutivo')) {
          dados['protocolo_reprodutivo'] =
              ((_model.protocoloDropdownValue ?? '').trim().isNotEmpty)
                  ? _model.protocoloDropdownValue
                  : null;
          dados['protocolo_reprodutivo_outros'] =
              protocoloOutros.isNotEmpty ? protocoloOutros : null;
          dados['protocolo_reprodutivo_obs'] =
              protocoloObs.isNotEmpty ? protocoloObs : null;

          dados['protocolo_d0'] = d0.isNotEmpty ? d0 : null;
          dados['protocolo_retirada'] = retirada.isNotEmpty ? retirada : null;
          dados['protocolo_iatf'] = iatf.isNotEmpty ? iatf : null;
        }

        // Inserir na tabela de sanidade
        await SanidadeTable().insert(dados);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Sanidade registrada com sucesso para $qtdAnimais animais do lote!'),
            backgroundColor: Colors.green,
          ),
        );

        // Chamar o callback action e fechar o popup
        await widget.action!('pgSanidade');
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar sanidade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
