import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../data/piquete_backend_store.dart';
import '../prototype/piquete_form_mock_widget.dart';
import '../prototype/piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
import 'pg_add_piquete_model.dart';
export 'pg_add_piquete_model.dart';

class PgAddPiqueteWidget extends StatefulWidget {
  const PgAddPiqueteWidget({super.key});

  static String routeName = 'pgAddPiquete';
  static String routePath = '/addpiquete';

  @override
  State<PgAddPiqueteWidget> createState() => _PgAddPiqueteWidgetState();
}

class _PgAddPiqueteWidgetState extends State<PgAddPiqueteWidget> {
  late PgAddPiqueteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _store = PiqueteBackendStore.instance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgAddPiqueteModel());
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
    try {
      if (_store.retiros.isEmpty) {
        await _store.load();
      }
      await _store.loadOptions();
    } catch (_) {
      // A mensagem amigável fica no store e é exibida na tela.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PiquetePrototypeScaffold(
      scaffoldKey: scaffoldKey,
      headerModel: _model.headerModel,
      sideBarModel: _model.sideBarModel,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrototypePageHeader(
              title: 'Adicionar piquete',
              subtitle: 'Novo piquete',
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
            const SizedBox(height: 26),
            if (_store.loading && _store.retiros.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_store.errorMessage != null && _store.retiros.isEmpty)
              PrototypeEmptyState(
                title: 'Não foi possível carregar os retiros',
                message: _store.errorMessage!,
                icon: Icons.warning_amber_rounded,
                action: PrototypePrimaryButton(
                  label: 'Tentar novamente',
                  icon: Icons.refresh_rounded,
                  onPressed: _loadFormData,
                ),
              )
            else
              PiqueteFormMockWidget(
                onCancel: () => context.safePop(),
                onSave: (result) async {
                  try {
                    final piquete = await _store.addPiquete(
                      retiroId: result.retiroId,
                      nome: result.nome,
                      areaHa: result.areaHa,
                      forrageiras: result.forrageiras,
                      anotacoes: result.anotacoes,
                      pontos: result.pontos,
                      animaisIds: result.animaisIds,
                      lotesIds: result.lotesIds,
                    );
                    if (!context.mounted) return;
                    context.pushNamed(
                      PgViewPiqueteWidget.routeName,
                      queryParameters: {
                        'idPiquete': serializeParam(
                          piquete.id,
                          ParamType.String,
                        ),
                        'piqueteNome': serializeParam(
                          piquete.nome,
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
                              'Não foi possível salvar o piquete.',
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
