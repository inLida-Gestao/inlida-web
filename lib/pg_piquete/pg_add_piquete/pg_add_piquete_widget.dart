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
  late final VoidCallback _disposePiqueteRefresh;
  int _formVersion = 0;
  bool _loadingFormData = true;
  String? _formLoadError;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgAddPiqueteModel());
    FFAppState().navegacao = 'piquetes';
    _store.addListener(_onStoreChanged);
    _disposePiqueteRefresh = FFAppState().onRefresh(
      'refreshPiquete',
      _handlePiqueteRefresh,
    );
    _loadFormData();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _disposePiqueteRefresh();
    _store.removeListener(_onStoreChanged);
    _model.dispose();
    super.dispose();
  }

  void _onStoreChanged() => safeSetState(() {});

  void _handlePiqueteRefresh() {
    safeSetState(() => _formVersion++);
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    safeSetState(() {
      _loadingFormData = true;
      _formLoadError = null;
    });
    try {
      await _store.load();
    } catch (_) {
      _formLoadError = _store.errorMessage;
    } finally {
      safeSetState(() => _loadingFormData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              title: 'Adicionar piquete',
              subtitle: 'Novo piquete',
              leading: FlutterFlowIconButton(
                borderRadius: kPiqueteRadius,
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
            if (_loadingFormData)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_formLoadError != null)
              PrototypeEmptyState(
                title: 'Não foi possível carregar os retiros',
                message: _formLoadError!,
                icon: Icons.warning_amber_rounded,
                action: PrototypePrimaryButton(
                  label: 'Tentar novamente',
                  icon: Icons.refresh_rounded,
                  onPressed: _loadFormData,
                ),
              )
            else
              PiqueteFormMockWidget(
                key: ValueKey(_formVersion),
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
