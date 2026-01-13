import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/popup_rebanhos_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'cc_edit_sanidade_animal_model.dart';
export 'cc_edit_sanidade_animal_model.dart';

class CcEditSanidadeAnimalWidget extends StatefulWidget {
  const CcEditSanidadeAnimalWidget({
    super.key,
    required this.sanidade,
    required this.action,
    this.readOnly = false,
    this.onEdit,
  });

  final SanidadeStruct sanidade;
  final Future Function(String? page)? action;
  final bool readOnly;
  final Future<void> Function()? onEdit;

  @override
  State<CcEditSanidadeAnimalWidget> createState() =>
      _CcEditSanidadeAnimalWidgetState();
}

class _CcEditSanidadeAnimalWidgetState
    extends State<CcEditSanidadeAnimalWidget> {
  late CcEditSanidadeAnimalModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CcEditSanidadeAnimalModel());

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFromSanidade();
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  bool _hasValue(String? value) {
    final v = (value ?? '').trim();
    return v.isNotEmpty && v.toLowerCase() != 'null' && v != '[]';
  }

  void _prefillFromSanidade() {
    // Animal
    final idRebanho = widget.sanidade.idRebanho.trim();
    if (idRebanho.isNotEmpty) {
      _model.animalSelecionadoId = idRebanho;
    }

    final nome = widget.sanidade.nome.trim();
    final numero = widget.sanidade.numeroAnimal.trim();
    if (nome.isNotEmpty && numero.isNotEmpty) {
      _model.animalSelecionadoNome = '$numero - $nome';
    } else if (nome.isNotEmpty) {
      _model.animalSelecionadoNome = nome;
    } else if (numero.isNotEmpty) {
      _model.animalSelecionadoNome = numero;
    }

    // Data (prioriza data_sanidade)
    final rawDate = widget.sanidade.dataSanidade.trim().isNotEmpty
        ? widget.sanidade.dataSanidade
        : widget.sanidade.createdAt;
    _model.dataSanidade = functions.converterParaData(rawDate);

    // Tipos
    _model.tiposSelecionados = [];
    if (_hasValue(widget.sanidade.vacinacao)) {
      _model.tiposSelecionados.add('Vacinação');
    }
    if (_hasValue(widget.sanidade.antiparasitario)) {
      _model.tiposSelecionados.add('Antiparasitário');
    }
    if (_hasValue(widget.sanidade.tratamento)) {
      _model.tiposSelecionados.add('Tratamento');
    }
    if (_hasValue(widget.sanidade.protocoloReprodutivo)) {
      _model.tiposSelecionados.add('Protocolo reprodutivo');
    }

    // Valores dos multiselects
    _model.vacinaDropdownValue =
        functions.converterJSONparaLista(widget.sanidade.vacinacao);
    _model.vacinaDropdownValueController =
        FormListFieldController<String>(_model.vacinaDropdownValue);

    _model.antiparasitarioDropdownValue =
        functions.converterJSONparaLista(widget.sanidade.antiparasitario);
    _model.antiparasitarioDropdownValueController =
        FormListFieldController<String>(_model.antiparasitarioDropdownValue);

    _model.tratamentoDropdownValue =
        functions.converterJSONparaLista(widget.sanidade.tratamento);
    _model.tratamentoDropdownValueController =
        FormListFieldController<String>(_model.tratamentoDropdownValue);

    _model.protocoloDropdownValue =
        functions.converterJSONparaLista(widget.sanidade.protocoloReprodutivo);
    _model.protocoloDropdownValueController =
        FormListFieldController<String>(_model.protocoloDropdownValue);

    // Textos
    _model.vacinaOutrosTextController?.text = widget.sanidade.vacinacaoOutros;
    _model.vacinaObsTextController?.text = widget.sanidade.vacinacaoObs;
    _model.antiparasitarioOutrosTextController?.text =
        widget.sanidade.antiparasitarioOutros;
    _model.antiparasitarioObsTextController?.text =
        widget.sanidade.antiparasitarioObs;
    _model.tratamentoOutrosTextController?.text =
        widget.sanidade.tratamentoOutros;
    _model.tratamentoObsTextController?.text = widget.sanidade.tratamentoObs;
    _model.protocoloOutrosTextController?.text =
        widget.sanidade.protocoloReprodutivoOutros;
    _model.protocoloObsTextController?.text =
        widget.sanidade.protocoloReprodutivoObs;
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
        padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          widget.readOnly
                              ? 'Visualizar sanidade'
                              : 'Editar sanidade em um animal',
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
                          onTap: widget.readOnly
                              ? null
                              : () async {
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
                              if (FFAppState()
                                  .matrizSelecionada
                                  .idAnimal
                                  .isNotEmpty) {
                                setState(() {
                                  _model.animalSelecionadoId =
                                      FFAppState().matrizSelecionada.idAnimal;
                                  _model.animalSelecionadoNome =
                                      FFAppState().matrizSelecionada.nomeAnimal;
                                });
                              } else if (FFAppState()
                                  .reprodutorSelecionado
                                  .idAnimal
                                  .isNotEmpty) {
                                setState(() {
                                  _model.animalSelecionadoId = FFAppState()
                                      .reprodutorSelecionado
                                      .idAnimal;
                                  _model.animalSelecionadoNome = FFAppState()
                                      .reprodutorSelecionado
                                      .nomeAnimal;
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
                                    _model.animalSelecionadoNome ??
                                        'Selecionar',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Poppins',
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

                    // Data
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data*',
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
                          onTap: widget.readOnly
                              ? null
                              : () async {
                            final datePickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  _model.dataSanidade ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light(useMaterial3: false),
                                  child: child!,
                                );
                              },
                            );
                            if (datePickedDate != null) {
                              setState(() {
                                _model.dataSanidade = datePickedDate;
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
                                            'd/M/y',
                                            _model.dataSanidade,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
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
                            onPressed: widget.readOnly
                                ? null
                                : () async {
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
                                  if (!widget.readOnly)
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

                    if (_model.tiposSelecionados.contains('Vacinação'))
                      _buildVacinacaoSection(),

                    if (_model.tiposSelecionados.contains('Antiparasitário'))
                      _buildAntiparasitarioSection(),

                    if (_model.tiposSelecionados.contains('Tratamento'))
                      _buildTratamentoSection(),

                    if (_model.tiposSelecionados
                        .contains('Protocolo reprodutivo'))
                      _buildProtocoloSection(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botões
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
                      if (widget.readOnly) {
                        await widget.onEdit?.call();
                        return;
                      }
                      await _atualizarSanidade();
                    },
                    text: widget.readOnly ? 'Editar' : 'Salvar',
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
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
                  FormListFieldController<String>(_model.vacinaDropdownValue),
              options: FFAppState().vacinacao,
              isMultiSelect: true,
              onMultiSelectChanged: (val) {
                if (widget.readOnly) return;
                setState(() => _model.vacinaDropdownValue = val);
              },
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
              disabled: widget.readOnly,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Vacinas (outros)',
          hint: 'Vacinas',
          controller: _model.vacinaOutrosTextController,
          focusNode: _model.vacinaOutrosFocusNode,
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Observação',
          hint: 'Observação',
          controller: _model.vacinaObsTextController,
          focusNode: _model.vacinaObsFocusNode,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAntiparasitarioSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
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
              'Antiparasitários*',
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
                      FormListFieldController<String>(
                          _model.antiparasitarioDropdownValue),
              options: FFAppState().antiparasitario,
              isMultiSelect: true,
              onMultiSelectChanged: (val) {
                if (widget.readOnly) return;
                setState(() => _model.antiparasitarioDropdownValue = val);
              },
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
              disabled: widget.readOnly,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Antiparasitários (outros)',
          hint: 'Antiparasitários',
          controller: _model.antiparasitarioOutrosTextController,
          focusNode: _model.antiparasitarioOutrosFocusNode,
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Observação',
          hint: 'Observação',
          controller: _model.antiparasitarioObsTextController,
          focusNode: _model.antiparasitarioObsFocusNode,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTratamentoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
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
              'Tratamentos*',
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
                      FormListFieldController<String>(
                          _model.tratamentoDropdownValue),
              options: FFAppState().tratamento,
              isMultiSelect: true,
              onMultiSelectChanged: (val) {
                if (widget.readOnly) return;
                setState(() => _model.tratamentoDropdownValue = val);
              },
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
              disabled: widget.readOnly,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Tratamentos (outros)',
          hint: 'Tratamentos',
          controller: _model.tratamentoOutrosTextController,
          focusNode: _model.tratamentoOutrosFocusNode,
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Observação',
          hint: 'Observação',
          controller: _model.tratamentoObsTextController,
          focusNode: _model.tratamentoObsFocusNode,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProtocoloSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
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
              'Protocolos*',
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
              multiSelectController: _model.protocoloDropdownValueController ??=
                  FormListFieldController<String>(
                      _model.protocoloDropdownValue),
              options: FFAppState().protocoloReprodutivo,
              isMultiSelect: true,
              onMultiSelectChanged: (val) {
                if (widget.readOnly) return;
                setState(() => _model.protocoloDropdownValue = val);
              },
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
              disabled: widget.readOnly,
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Protocolos (outros)',
          hint: 'Protocolos',
          controller: _model.protocoloOutrosTextController,
          focusNode: _model.protocoloOutrosFocusNode,
        ),
        const SizedBox(height: 32),
        _buildTextField(
          label: 'Observação',
          hint: 'Observação',
          controller: _model.protocoloObsTextController,
          focusNode: _model.protocoloObsFocusNode,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    required FocusNode? focusNode,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          obscureText: false,
          readOnly: widget.readOnly,
          enabled: !widget.readOnly,
          decoration: InputDecoration(
            hintText: hint,
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
    );
  }

  Future<void> _atualizarSanidade() async {
    if (_model.animalSelecionadoId == null ||
        (_model.animalSelecionadoId ?? '').trim().isEmpty) {
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

    final sanidadeId = widget.sanidade.id;
    final idSanidade = widget.sanidade.idSanidade.trim();
    if (sanidadeId == 0 && idSanidade.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível identificar o registro de sanidade'),
          backgroundColor: Colors.orange,
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

      final data = <String, dynamic>{
        'id_rebanho': _model.animalSelecionadoId,
        'data_sanidade': supaSerialize<DateTime>(_model.dataSanidade),
        'updated_at': supaSerialize<DateTime>(DateTime.now()),
        'deletado': 'NAO',

        // Vacinação
        'vacinacao': _model.tiposSelecionados.contains('Vacinação')
            ? (_model.vacinaDropdownValue?.isNotEmpty ?? false)
                ? _model.vacinaDropdownValue!.join(', ')
                : null
            : null,
        'vacinacao_outros': _model.tiposSelecionados.contains('Vacinação')
            ? (vacinaOutros.isNotEmpty ? vacinaOutros : null)
            : null,
        'vacinacao_obs': _model.tiposSelecionados.contains('Vacinação')
            ? (vacinaObs.isNotEmpty ? vacinaObs : null)
            : null,

        // Antiparasitário
        'antiparasitario': _model.tiposSelecionados.contains('Antiparasitário')
            ? (_model.antiparasitarioDropdownValue?.isNotEmpty ?? false)
                ? _model.antiparasitarioDropdownValue!.join(', ')
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

        // Tratamento
        'tratamento': _model.tiposSelecionados.contains('Tratamento')
            ? (_model.tratamentoDropdownValue?.isNotEmpty ?? false)
                ? _model.tratamentoDropdownValue!.join(', ')
                : null
            : null,
        'tratamento_outros': _model.tiposSelecionados.contains('Tratamento')
            ? (tratamentoOutros.isNotEmpty ? tratamentoOutros : null)
            : null,
        'tratamento_obs': _model.tiposSelecionados.contains('Tratamento')
            ? (tratamentoObs.isNotEmpty ? tratamentoObs : null)
            : null,

        // Protocolo reprodutivo
        'protocolo_reprodutivo':
            _model.tiposSelecionados.contains('Protocolo reprodutivo')
                ? (_model.protocoloDropdownValue?.isNotEmpty ?? false)
                    ? _model.protocoloDropdownValue!.join(', ')
                    : null
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

      await SanidadeTable().update(
        data: data,
        matchingRows: (rows) {
          if (sanidadeId != 0) {
            return rows.eq('id', sanidadeId);
          }
          return rows.eq('id_sanidade', idSanidade);
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sanidade atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (widget.action != null) {
        await widget.action!('pgSanidade');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar sanidade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
