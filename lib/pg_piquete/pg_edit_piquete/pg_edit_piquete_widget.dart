import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../data/piquete_backend_store.dart';
import '../prototype/piquete_form_mock_widget.dart';
import '../prototype/piquete_prototype_store.dart';
import '../prototype/piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
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
  final _store = PiqueteBackendStore.instance;
  bool _loadingFormData = true;
  PiquetePrototype? _loadedPiquete;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgEditPiqueteModel());
    FFAppState().navegacao = 'piquetes';
    _store.addListener(_onStoreChanged);
    _loadFormData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _model.dispose();
    super.dispose();
  }

  void _onStoreChanged() => safeSetState(() {});

  Future<void> _loadFormData() async {
    safeSetState(() => _loadingFormData = true);
    try {
      if (_store.retiros.isEmpty) {
        await _store.load();
      }
      final id = widget.idPiquete ?? '';
      if (id.isNotEmpty) {
        _loadedPiquete = await _store.loadPiqueteDetail(id);
      }
    } catch (_) {
      // A mensagem amigável fica no store e é exibida na tela.
    } finally {
      if (mounted) safeSetState(() => _loadingFormData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final piquete =
        _loadedPiquete ?? _store.piqueteById(widget.idPiquete ?? '');

    return PiquetePrototypeScaffold(
      scaffoldKey: scaffoldKey,
      headerModel: _model.headerModel,
      sideBarModel: _model.sideBarModel,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrototypePageHeader(
              title:
                  piquete == null ? 'Piquete não encontrado' : 'Editar piquete',
              subtitle: piquete?.retiroId.isEmpty == true
                  ? 'Sem retiro > ${piquete?.nome ?? widget.piqueteNome ?? ''}'
                  : 'Retiro > ${piquete?.nome ?? widget.piqueteNome ?? ''}',
              leading: FlutterFlowIconButton(
                borderRadius: 8,
                buttonSize: 44,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 24,
                ),
                onPressed: () => context.safePop(),
              ),
            ),
            const SizedBox(height: 20),
            if (_loadingFormData || (_store.loading && piquete == null))
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_store.errorMessage != null && piquete == null)
              PrototypeEmptyState(
                title: 'Não foi possível carregar este piquete',
                message: _store.errorMessage!,
                icon: Icons.warning_amber_rounded,
                action: PrototypePrimaryButton(
                  label: 'Tentar novamente',
                  icon: Icons.refresh_rounded,
                  onPressed: _loadFormData,
                ),
              )
            else if (piquete == null)
              PrototypeEmptyState(
                title: 'Não foi possível editar este piquete',
                message:
                    'Este item não existe no protótipo local. Volte para a listagem e selecione outro piquete.',
                icon: Icons.warning_amber_rounded,
                action: PrototypePrimaryButton(
                  label: 'Voltar',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => context.safePop(),
                ),
              )
            else
              PiqueteFormMockWidget(
                initial: piquete,
                onCancel: () => context.safePop(),
                onSave: (result) async {
                  try {
                    final updated = await _store.updatePiquete(
                      piquete.copyWith(
                        retiroId: result.retiroId,
                        nome: result.nome.trim().isNotEmpty
                            ? result.nome
                            : piquete.nome,
                        areaHa:
                            result.areaHa > 0 ? result.areaHa : piquete.areaHa,
                        forrageiras: result.forrageiras.isNotEmpty
                            ? result.forrageiras
                            : piquete.forrageiras,
                        anotacoes: result.anotacoes,
                        pontos: result.pontos.length >= 3
                            ? result.pontos
                            : piquete.pontos,
                        animaisIds: result.animaisIds,
                        lotesIds: result.lotesIds,
                      ),
                    );
                    _loadedPiquete = updated;
                    if (!context.mounted) return;
                    context.pushNamed(
                      PgViewPiqueteWidget.routeName,
                      queryParameters: {
                        'idPiquete': serializeParam(
                          updated.id,
                          ParamType.String,
                        ),
                        'piqueteNome': serializeParam(
                          updated.nome,
                          ParamType.String,
                        ),
                      }.withoutNulls,
                    );
                  } catch (_) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _store.errorMessage ??
                              'Não foi possível atualizar o piquete.',
                        ),
                        backgroundColor: FlutterFlowTheme.of(context).error,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
