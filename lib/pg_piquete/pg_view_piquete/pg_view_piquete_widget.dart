import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../data/piquete_backend_store.dart';
import '../prototype/mapa_demarcacao_real_widget.dart';
import '../prototype/piquete_prototype_store.dart';
import '../prototype/piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pg_view_piquete_model.dart';
export 'pg_view_piquete_model.dart';

class PgViewPiqueteWidget extends StatefulWidget {
  const PgViewPiqueteWidget({
    super.key,
    required this.idPiquete,
    required this.piqueteNome,
  });

  final String? idPiquete;
  final String? piqueteNome;

  static String routeName = 'pgViewPiquete';
  static String routePath = '/viewpiquete';

  @override
  State<PgViewPiqueteWidget> createState() => _PgViewPiqueteWidgetState();
}

class _PgViewPiqueteWidgetState extends State<PgViewPiqueteWidget> {
  late PgViewPiqueteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _store = PiqueteBackendStore.instance;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PgViewPiqueteModel());
    FFAppState().navegacao = 'piquetes';
    _store.addListener(_onStoreChanged);
    _loadDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _model.dispose();
    super.dispose();
  }

  void _onStoreChanged() => safeSetState(() {});

  Future<void> _loadDetail() async {
    try {
      if (_store.retiros.isEmpty) {
        await _store.load();
      }
      final id = widget.idPiquete ?? '';
      if (id.isNotEmpty) {
        await _store.loadPiqueteDetail(id);
      }
    } catch (_) {
      // A mensagem amigável fica no store e é exibida na tela.
    }
  }

  @override
  Widget build(BuildContext context) {
    final piquete = _store.piqueteById(widget.idPiquete ?? '');
    final retiro = piquete == null ? null : _store.retiroById(piquete.retiroId);
    final animais = piquete == null
        ? <AnimalPrototype>[]
        : _store.animaisByIds(piquete.animaisIds);
    final lotes = piquete == null
        ? <LotePrototype>[]
        : _store.lotesByIds(piquete.lotesIds);

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
              title: piquete?.nome ?? widget.piqueteNome ?? 'Piquete',
              subtitle: retiro == null
                  ? 'Retiro > Piquete'
                  : '${retiro.nome} > Piquete',
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
              actions: [
                if (piquete != null)
                  PrototypePrimaryButton(
                    label: 'Editar',
                    icon: Icons.edit_rounded,
                    onPressed: () {
                      context.pushNamed(
                        PgEditPiqueteWidget.routeName,
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
                    },
                  ),
              ],
            ),
            const SizedBox(height: 26),
            if (_store.loading && piquete == null)
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
                  onPressed: _loadDetail,
                ),
              )
            else if (piquete == null)
              PrototypeEmptyState(
                title: 'Piquete não encontrado',
                message:
                    'Este piquete não existe no backend. Volte para a listagem e selecione outro item.',
                icon: Icons.warning_amber_rounded,
                action: PrototypePrimaryButton(
                  label: 'Voltar',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => context.safePop(),
                ),
              )
            else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 1060;
                  final details = _DetailsCard(
                    piquete: piquete,
                    retiroNome: retiro?.nome ?? 'Sem retiro',
                  );
                  final map = MapaDemarcacaoRealWidget(
                    title: 'Área demarcada',
                    points: piquete.pontos,
                    retiroPoints: retiro?.pontos ?? const [],
                    editable: false,
                  );
                  if (narrow) {
                    return Column(
                      children: [
                        details,
                        const SizedBox(height: 22),
                        map,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: details),
                      const SizedBox(width: 22),
                      Expanded(flex: 5, child: map),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(
                    width: 280,
                    child: PrototypeMetricCard(
                      title: 'Animais individuais',
                      value: animais.length.toString(),
                      iconAsset: kPiqueteCowIconAsset,
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: PrototypeMetricCard(
                      title: 'Lotes vinculados',
                      value: lotes.length.toString(),
                      icon: Icons.bubble_chart_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: PrototypeMetricCard(
                      title: 'Animais via lote',
                      value: lotes
                          .fold<int>(
                              0, (total, lote) => total + lote.qtdAnimais)
                          .toString(),
                      icon: Icons.groups_2_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ContentSections(animais: animais, lotes: lotes),
              const SizedBox(height: 24),
              const _HistoryCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.piquete,
    required this.retiroNome,
  });

  final PiquetePrototype piquete;
  final String retiroNome;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dados do piquete',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'Retiro', value: retiroNome),
          _InfoRow(label: 'Nome', value: piquete.nome),
          _InfoRow(
              label: 'Área', value: '${piquete.areaHa.toStringAsFixed(1)} ha'),
          _InfoRow(label: 'Forrageiras', value: piquete.forrageira),
          _InfoRow(
            label: 'Tipo de ocupação',
            value: piquete.conteudoLabel,
          ),
          const SizedBox(height: 18),
          Text(
            'Anotações',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            piquete.anotacoes.isEmpty
                ? 'Sem anotações registradas.'
                : piquete.anotacoes,
            style: GoogleFonts.poppins(
              color: theme.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: theme.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: theme.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSections extends StatelessWidget {
  const _ContentSections({
    required this.animais,
    required this.lotes,
  });

  final List<AnimalPrototype> animais;
  final List<LotePrototype> lotes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 1000;
        final animalCard = _AnimalsCard(animais: animais);
        final loteCard = _LotesCard(lotes: lotes);
        if (narrow) {
          return Column(
            children: [animalCard, const SizedBox(height: 22), loteCard],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: animalCard),
            const SizedBox(width: 22),
            Expanded(child: loteCard),
          ],
        );
      },
    );
  }
}

class _AnimalsCard extends StatelessWidget {
  const _AnimalsCard({required this.animais});

  final List<AnimalPrototype> animais;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animais neste piquete',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (animais.isEmpty)
            const PrototypeEmptyState(
              title: 'Sem animais individuais',
              message:
                  'Este piquete ainda não recebeu animais avulsos. Ele pode estar ocupado apenas por lotes.',
              iconAsset: kPiqueteCowIconAsset,
            )
          else
            ...animais.map((animal) => _SimpleRow(
                  title: '${animal.numero} • ${animal.nome}',
                  subtitle:
                      '${animal.categoria} • ${animal.raca} • ${animal.loteNome}',
                  iconAsset: kPiqueteCowIconAsset,
                )),
        ],
      ),
    );
  }
}

class _LotesCard extends StatelessWidget {
  const _LotesCard({required this.lotes});

  final List<LotePrototype> lotes;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lotes neste piquete',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (lotes.isEmpty)
            const PrototypeEmptyState(
              title: 'Sem lotes vinculados',
              message:
                  'Este piquete ainda não recebeu um lote inteiro. Você pode adicionar lotes na edição.',
              icon: Icons.bubble_chart_outlined,
            )
          else
            ...lotes.map((lote) => _SimpleRow(
                  title: lote.nome,
                  subtitle: '${lote.qtdAnimais} animais • ${lote.status}',
                  icon: Icons.bubble_chart_outlined,
                )),
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconAsset,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.customColor5)),
      ),
      child: Row(
        children: [
          if (iconAsset == null)
            Icon(icon, color: theme.primary, size: 24)
          else
            Image.asset(
              iconAsset!,
              width: piqueteAssetIconSize(iconAsset, 24),
              height: piqueteAssetIconSize(iconAsset, 24),
              fit: BoxFit.contain,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: theme.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: theme.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const events = [
      ('Hoje', 'Área conferida no mapa do protótipo.'),
      ('Última semana', 'Entrada de animais/lotes simulada para validação.'),
      ('Mês atual', 'Piquete associado ao retiro selecionado.'),
    ];

    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico mockado',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${event.$1}: ${event.$2}',
                      style: GoogleFonts.poppins(
                        color: theme.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
