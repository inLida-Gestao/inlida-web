import '/auth/supabase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/perfil/menu_perfil/menu_perfil_widget.dart';
import '/actions/actions.dart' as action_blocks;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'header_model.dart';
export 'header_model.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late HeaderModel _model;
  int _propertyChangeSequence = 0;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HeaderModel());
    _model.propriedadesFuture ??=
        FunctionsSupabaseRebanhoGroup.buscarPropriedadesDoUsuarioCall.call(
      pUserId: currentUserUid,
    );

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {
        _model.dropDownValueController?.value =
            FFAppState().propriedadeSelecionada.idPropriedade;
        _model.dropDownValue =
            FFAppState().propriedadeSelecionada.idPropriedade;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      height: 120.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        border: Border.all(
          color: FlutterFlowTheme.of(context).tertiary,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(32.0, 16.0, 32.0, 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/97dce0f07389cc398f28f16e7ec6bfcc333e86ba.png',
                    width: 108.0,
                    height: 88.0,
                    fit: BoxFit.cover,
                  ),
                ),
                FutureBuilder<ApiCallResponse>(
                  future: _model.propriedadesFuture,
                  builder: (context, snapshot) {
                    // Customize what your widget looks like when it's loading.
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      );
                    }
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
                    final containerBuscarPropriedadesDoUsuarioResponse =
                        snapshot.data!;

                    // Lista de IDs que o usuário pode escolher agora.
                    final propsLista =
                        (containerBuscarPropriedadesDoUsuarioResponse
                                .jsonBody
                                .toList()
                                .map<PropriedadeStruct?>(
                                    PropriedadeStruct.maybeFromMap)
                                .toList() as Iterable<PropriedadeStruct?>)
                            .withoutNulls
                            .toList();
                    final optionIds = propsLista
                        .map((e) => e.idPropriedade)
                        .where((id) => id.isNotEmpty)
                        .toList();
                    final sidPersistido =
                        FFAppState().propriedadeSelecionada.idPropriedade;

                    // Id guardado no app não existe mais na lista → limpar (senão o PAINT
                    // e outras telas usam uma "propriedade fantasma" enquanto o dropdown
                    // mostra só o hint "Propriedade").
                    if (sidPersistido.isNotEmpty &&
                        !optionIds.contains(sidPersistido)) {
                      final sidInvalido = sidPersistido;
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (!mounted ||
                            FFAppState().propriedadeSelecionada.idPropriedade !=
                                sidInvalido) {
                          return;
                        }
                        FFAppState()
                            .onPropriedadeChanged(PropriedadesDTStruct());
                        safeSetState(() {
                          _model.dropDownValueController?.reset();
                          _model.dropDownValue = null;
                        });
                      });
                    } else if (sidPersistido.isNotEmpty &&
                        optionIds.contains(sidPersistido)) {
                      final cur = _model.dropDownValueController?.value;
                      if (cur != sidPersistido) {
                        final sidSincronizado = sidPersistido;
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          if (!mounted ||
                              FFAppState()
                                      .propriedadeSelecionada
                                      .idPropriedade !=
                                  sidSincronizado) {
                            return;
                          }
                          _model.dropDownValue = sidSincronizado;
                          _model.dropDownValueController?.value =
                              sidSincronizado;
                          safeSetState(() {});
                        });
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecione a propriedade:',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).accent3,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FlutterFlowDropDown<String>(
                                controller: _model.dropDownValueController ??=
                                    FormFieldController<String>(
                                  _model.dropDownValue ??= FFAppState()
                                      .propriedadeSelecionada
                                      .idPropriedade,
                                ),
                                options: List<String>.from(
                                    (containerBuscarPropriedadesDoUsuarioResponse
                                                .jsonBody
                                                .toList()
                                                .map<PropriedadeStruct?>(
                                                    PropriedadeStruct.maybeFromMap)
                                                .toList()
                                            as Iterable<PropriedadeStruct?>)
                                        .withoutNulls
                                        .map((e) => e.idPropriedade)
                                        .toList()),
                                optionLabels:
                                    (containerBuscarPropriedadesDoUsuarioResponse
                                                .jsonBody
                                                .toList()
                                                .map<PropriedadeStruct?>(
                                                    PropriedadeStruct.maybeFromMap)
                                                .toList()
                                            as Iterable<PropriedadeStruct?>)
                                        .withoutNulls
                                        .map((e) => e.nome)
                                        .toList(),
                                onChanged: (val) async {
                                  final selectedId = val?.trim() ?? '';
                                  final selectedProperty = propsLista
                                      .where((property) =>
                                          property.idPropriedade == selectedId)
                                      .firstOrNull;
                                  if (selectedId.isEmpty ||
                                      selectedProperty == null) {
                                    return;
                                  }

                                  final changeSequence =
                                      ++_propertyChangeSequence;
                                  safeSetState(
                                      () => _model.dropDownValue = selectedId);

                                  // Atualizar imediatamente para impedir que um
                                  // rebuild restaure a propriedade anterior.
                                  FFAppState().onPropriedadeChanged(
                                    PropriedadesDTStruct(
                                      idPropriedade: selectedId,
                                      nome: selectedProperty.nome,
                                    ),
                                  );

                                  final qtdAnimaisResponses =
                                      await Future.wait([
                                    FunctionsSupabaseRebanhoGroup
                                        .countRebanhoFiltrosCall
                                        .call(
                                      pIdPropriedade: selectedId,
                                      pStatus: 'Na Propriedade',
                                    ),
                                    FunctionsSupabaseRebanhoGroup
                                        .countRebanhoFiltrosCall
                                        .call(
                                      pIdPropriedade: selectedId,
                                      pStatus: 'Na propriedade',
                                    ),
                                  ]);
                                  if (!context.mounted ||
                                      changeSequence !=
                                          _propertyChangeSequence ||
                                      FFAppState()
                                              .propriedadeSelecionada
                                              .idPropriedade !=
                                          selectedId) {
                                    return;
                                  }

                                  _model.qtdAnimais = qtdAnimaisResponses.first;
                                  final qtdAnimaisLower =
                                      qtdAnimaisResponses.last;
                                  final qtdUpper = valueOrDefault<int>(
                                    (_model.qtdAnimais?.jsonBody ?? ''),
                                    0,
                                  );
                                  final qtdLower = valueOrDefault<int>(
                                    (qtdAnimaisLower.jsonBody ?? ''),
                                    0,
                                  );
                                  final qtdTotal = qtdUpper == qtdLower
                                      ? qtdUpper
                                      : (qtdUpper + qtdLower);
                                  FFAppState().qtdAnimaisNaPropriedade =
                                      qtdTotal;
                                  await Future.wait([
                                    action_blocks.countReproducoes(
                                      context,
                                      propriedadeId: selectedId,
                                    ),
                                    action_blocks.countLotes(
                                      context,
                                      propriedadeId: selectedId,
                                    ),
                                  ]);
                                  if (!context.mounted ||
                                      changeSequence !=
                                          _propertyChangeSequence ||
                                      FFAppState()
                                              .propriedadeSelecionada
                                              .idPropriedade !=
                                          selectedId) {
                                    return;
                                  }

                                  FFAppState().update(() {});
                                  safeSetState(() {});
                                },
                                width: 418.0,
                                height: 56.0,
                                maxHeight: 360.0,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                hintText: 'Propriedade',
                                icon: Icon(
                                  Icons.arrow_drop_down_sharp,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 24.0,
                                ),
                                fillColor:
                                    FlutterFlowTheme.of(context).customColor2,
                                elevation: 2.0,
                                borderColor: Colors.transparent,
                                borderWidth: 0.0,
                                borderRadius: 6.0,
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
                                hidesUnderline: true,
                                isOverButton: false,
                                isSearchable: true,
                                searchHintText: 'Pesquisar propriedade…',
                                searchHintTextStyle:
                                    FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 14.0,
                                        ),
                                searchTextStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.poppins(),
                                      fontSize: 14.0,
                                    ),
                                searchCursorColor:
                                    FlutterFlowTheme.of(context).primary,
                                isMultiSelect: false,
                              ),
                              if ((FFAppState()
                                          .propriedadeSelecionada
                                          .idPropriedade !=
                                      '') &&
                                  responsiveVisibility(
                                    context: context,
                                    phone: false,
                                    tablet: false,
                                    tabletLandscape: false,
                                    desktop: false,
                                  ))
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor: const Color(0x0028A365),
                                  hoverColor:
                                      FlutterFlowTheme.of(context).customColor2,
                                  icon: Icon(
                                    Icons.filter_list_off,
                                    color: FlutterFlowTheme.of(context).error,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    safeSetState(() {
                                      _model.dropDownValueController?.reset();
                                      _model.dropDownValue = null;
                                    });
                                    // Usar onPropriedadeChanged para garantir que todos os
                                    // filtros sejam resetados e todas as páginas sejam atualizadas
                                    FFAppState().onPropriedadeChanged(
                                      PropriedadesDTStruct(),
                                    );
                                    _model.updatePage(() {});
                                    safeSetState(() {});
                                  },
                                ),
                            ].divide(const SizedBox(width: 8.0)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ].divide(const SizedBox(width: 120.0)),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await launchURL(
                        'https://web.whatsapp.com/send?phone=+5519984231009');
                  },
                  child: const FaIcon(
                    FontAwesomeIcons.whatsapp,
                    color: Color(0xFF00AB3C),
                    size: 24.0,
                  ),
                ),
                Builder(
                  builder: (context) => InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showAlignedDialog(
                        barrierColor: Colors.transparent,
                        context: context,
                        isGlobal: false,
                        avoidOverflow: true,
                        targetAnchor: const AlignmentDirectional(-1.0, 1.0)
                            .resolve(Directionality.of(context)),
                        followerAnchor: const AlignmentDirectional(1.0, -1.0)
                            .resolve(Directionality.of(context)),
                        builder: (dialogContext) {
                          return const Material(
                            color: Colors.transparent,
                            child: MenuPerfilWidget(),
                          );
                        },
                      );
                    },
                    child: FaIcon(
                      FontAwesomeIcons.userCircle,
                      color: FlutterFlowTheme.of(context).customColor6,
                      size: 24.0,
                    ),
                  ),
                ),
              ].divide(const SizedBox(width: 32.0)),
            ),
          ],
        ),
      ),
    );
  }
}
