import '/backend/supabase/supabase.dart';
import '/components/popup_rebanhos_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:flutter/material.dart';
import 'cc_add_sanidade_animal_model.dart';
export 'cc_add_sanidade_animal_model.dart';

class CcAddSanidadeAnimalWidget extends StatefulWidget {
  const CcAddSanidadeAnimalWidget({
    super.key,
    required this.action,
  });

  final Future Function(String? page)? action;

  @override
  State<CcAddSanidadeAnimalWidget> createState() =>
      _CcAddSanidadeAnimalWidgetState();
}

class _CcAddSanidadeAnimalWidgetState extends State<CcAddSanidadeAnimalWidget> {
  late CcAddSanidadeAnimalModel _model;

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

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CcAddSanidadeAnimalModel());

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
                          'Adicionar sanidade em um animal',
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
                    // Campo Animal
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Animal*',
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
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) {
                                return GestureDetector(
                                  onTap: () => FocusScope.of(context).unfocus(),
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: const PopupRebanhosWidget(
                                      sexo: null,
                                      sanidade: true,
                                    ),
                                  ),
                                );
                              },
                            ).then((_) {
                              // Captura o animal selecionado do FFAppState
                              // Verifica se é matriz (fêmea) ou reprodutor (macho)
                              if (FFAppState()
                                  .matrizSelecionada
                                  .idAnimal
                                  .isNotEmpty) {
                                final matriz = FFAppState().matrizSelecionada;
                                final num = (matriz.numAnimal).trim();
                                final nome = (matriz.nomeAnimal).trim();
                                final numSafe =
                                    (num.isEmpty || num.toLowerCase() == 'null')
                                        ? 'S/N'
                                        : num;
                                final nomeSafe = (nome.isEmpty ||
                                        nome.toLowerCase() == 'null')
                                    ? 'S/N'
                                    : nome;
                                setState(() {
                                  _model.animalSelecionadoId = matriz.idAnimal;
                                  _model.animalSelecionadoNome =
                                      '$numSafe • $nomeSafe';
                                });
                              } else if (FFAppState()
                                  .reprodutorSelecionado
                                  .idAnimal
                                  .isNotEmpty) {
                                final reprodutor =
                                    FFAppState().reprodutorSelecionado;
                                final num = (reprodutor.numAnimal).trim();
                                final nome = (reprodutor.nomeAnimal).trim();
                                final numSafe =
                                    (num.isEmpty || num.toLowerCase() == 'null')
                                        ? 'S/N'
                                        : num;
                                final nomeSafe = (nome.isEmpty ||
                                        nome.toLowerCase() == 'null')
                                    ? 'S/N'
                                    : nome;
                                setState(() {
                                  _model.animalSelecionadoId =
                                      reprodutor.idAnimal;
                                  _model.animalSelecionadoNome =
                                      '$numSafe • $nomeSafe';
                                });
                              }
                            });
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
                                    (_model.animalSelecionadoNome ?? '')
                                            .trim()
                                            .isNotEmpty
                                        ? _model.animalSelecionadoNome!
                                        : 'Selecionar',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
                                          color:
                                              ((_model.animalSelecionadoNome ??
                                                          '')
                                                      .trim()
                                                      .isNotEmpty)
                                                  ? FlutterFlowTheme.of(context)
                                                      .primaryText
                                                  : FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                          fontSize: 16,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Icon(
                                    Icons.expand_more,
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
        const SizedBox(height: 16),
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
    if (_model.animalSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um animal'),
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
      final vacinaOutros = _model.vacinaOutrosTextController.text.trim();
      final vacinaObs = _model.vacinaObsTextController.text.trim();
      final antiparasitarioOutros =
          _model.antiparasitarioOutrosTextController.text.trim();
      final antiparasitarioObs =
          _model.antiparasitarioObsTextController.text.trim();
      final tratamentoOutros =
          _model.tratamentoOutrosTextController.text.trim();
      final tratamentoObs = _model.tratamentoObsTextController.text.trim();
      final protocoloOutros = _model.protocoloOutrosTextController.text.trim();
      final protocoloObs = _model.protocoloObsTextController.text.trim();

      final d0 = (_model.protocoloD0DropdownValue ?? '').trim();
      final retirada = (_model.protocoloRetiradaDropdownValue ?? '').trim();
      final iatf = (_model.protocoloIatfDropdownValue ?? '').trim();

      // Inserir no banco de dados
      final dadosBase = <String, dynamic>{
        'id_sanidade': random_data.randomString(20, 20, true, false, true),
        'id_propriedade': FFAppState().propriedadeSelecionada.idPropriedade,
        'id_rebanho': _model.animalSelecionadoId,
        'data_sanidade': supaSerialize<DateTime>(_model.dataSanidade),
        'updated_at': supaSerialize<DateTime>(DateTime.now()),
        'deletado': 'NAO',
        'vacinacao': _model.tiposSelecionados.contains('Vacinação')
            ? (_model.vacinaDropdownValue?.isNotEmpty ?? false)
            ? jsonEncode(_model.vacinaDropdownValue)
                : null
            : null,
        'vacinacao_outros': _model.tiposSelecionados.contains('Vacinação')
            ? (vacinaOutros.isNotEmpty ? vacinaOutros : null)
            : null,
        'vacinacao_obs': _model.tiposSelecionados.contains('Vacinação')
            ? (vacinaObs.isNotEmpty ? vacinaObs : null)
            : null,
        'antiparasitario': _model.tiposSelecionados.contains('Antiparasitário')
            ? (_model.antiparasitarioDropdownValue?.isNotEmpty ?? false)
            ? jsonEncode(_model.antiparasitarioDropdownValue)
                : null
            : null,
        'antiparasitario_outros': _model.tiposSelecionados
                .contains('Antiparasitário')
            ? (antiparasitarioOutros.isNotEmpty ? antiparasitarioOutros : null)
            : null,
        'antiparasitario_obs':
            _model.tiposSelecionados.contains('Antiparasitário')
                ? (antiparasitarioObs.isNotEmpty ? antiparasitarioObs : null)
                : null,
        'tratamento': _model.tiposSelecionados.contains('Tratamento')
            ? (_model.tratamentoDropdownValue?.isNotEmpty ?? false)
            ? jsonEncode(_model.tratamentoDropdownValue)
                : null
            : null,
        'tratamento_outros': _model.tiposSelecionados.contains('Tratamento')
            ? (tratamentoOutros.isNotEmpty ? tratamentoOutros : null)
            : null,
        'tratamento_obs': _model.tiposSelecionados.contains('Tratamento')
            ? (tratamentoObs.isNotEmpty ? tratamentoObs : null)
            : null,
        'protocolo_reprodutivo':
            _model.tiposSelecionados.contains('Protocolo reprodutivo')
                ? ((_model.protocoloDropdownValue ?? '').trim().isNotEmpty
                    ? _model.protocoloDropdownValue
                    : null)
                : null,
        'protocolo_reprodutivo_outros':
            _model.tiposSelecionados.contains('Protocolo reprodutivo')
                ? (protocoloOutros.isNotEmpty ? protocoloOutros : null)
                : null,
        'protocolo_reprodutivo_obs':
            _model.tiposSelecionados.contains('Protocolo reprodutivo')
                ? (protocoloObs.isNotEmpty ? protocoloObs : null)
                : null,
      };

      final dadosComProtocolos = <String, dynamic>{
        ...dadosBase,
        if (_model.tiposSelecionados.contains('Protocolo reprodutivo')) ...{
          'protocolo_d0': d0.isNotEmpty ? d0 : null,
          'protocolo_retirada': retirada.isNotEmpty ? retirada : null,
          'protocolo_iatf': iatf.isNotEmpty ? iatf : null,
        },
      };

      try {
        await SanidadeTable().insert(dadosComProtocolos);
      } catch (e) {
        final msg = e.toString();
        final isPossivelMismatchDeSchema = msg.contains('protocolo_d0') ||
            msg.contains('protocolo_retirada') ||
            msg.contains('protocolo_iatf') ||
            msg.toLowerCase().contains('column') ||
            msg.toUpperCase().contains('PGRST');

        if (!isPossivelMismatchDeSchema) {
          rethrow;
        }

        await SanidadeTable().insert(dadosBase);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sanidade registrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      if (widget.action != null) {
        await widget.action!('pgSanidade');
      }
      if (mounted) {
        Navigator.pop(context);
      }
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
