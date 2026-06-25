import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '../data/piquete_backend_store.dart';
import '../data/piquete_models.dart';
import '../prototype/mapa_demarcacao_real_widget.dart';
import '../prototype/piquete_prototype_store.dart';
import '../prototype/piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final historico = piquete == null
        ? <PiqueteHistoricoEvent>[]
        : _store.historicoDoPiquete(piquete.id);
    final historicoAnimalIds = historico
        .where((event) => event.tipo.contains('animal'))
        .map(_animalIdFromHistoryEvent)
        .where((id) => id.isNotEmpty)
        .toSet();
    final historicoAnimais = {
      for (final animal in _store.animaisByIds(historicoAnimalIds))
        animal.id: animal,
    };

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
              title: piquete?.nome ?? widget.piqueteNome ?? 'Piquete',
              subtitle: retiro == null
                  ? 'Sem retiro > Piquete'
                  : '${retiro.nome} > Piquete',
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
            const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 232,
                    child: PrototypeMetricCard(
                      title: 'Animais individuais',
                      value: animais.length.toString(),
                      iconAsset: kPiqueteCowIconAsset,
                    ),
                  ),
                  SizedBox(
                    width: 232,
                    child: PrototypeMetricCard(
                      title: 'Lotes vinculados',
                      value: lotes.length.toString(),
                      iconAsset: kPiqueteLoteIconAsset,
                    ),
                  ),
                  SizedBox(
                    width: 232,
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
              const SizedBox(height: 20),
              _ContentSections(animais: animais, lotes: lotes),
              const SizedBox(height: 20),
              _HistoryCard(
                events: historico,
                loading: _store.loading,
                animaisById: historicoAnimais,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _animalIdFromHistoryEvent(PiqueteHistoricoEvent event) {
    for (final key in ['id_rebanho', 'idRebanho', 'animal_id', 'id']) {
      final value = event.metadata[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return event.entidadeId.trim();
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
              iconAsset: kPiqueteLoteIconAsset,
            )
          else
            ...lotes.map((lote) => _SimpleRow(
                  title: lote.nome,
                  subtitle: '${lote.qtdAnimais} animais • ${lote.status}',
                  iconAsset: kPiqueteLoteIconAsset,
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
    required this.iconAsset,
  });

  final String title;
  final String subtitle;
  final String iconAsset;

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
          iconAsset.toLowerCase().endsWith('.svg')
              ? SvgPicture.asset(
                  iconAsset,
                  width: piqueteAssetIconSize(iconAsset, 24),
                  height: piqueteAssetIconSize(iconAsset, 24),
                  fit: BoxFit.contain,
                )
              : Image.asset(
                  iconAsset,
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
  const _HistoryCard({
    required this.events,
    required this.loading,
    required this.animaisById,
  });

  final List<PiqueteHistoricoEvent> events;
  final bool loading;
  final Map<String, AnimalPrototype> animaisById;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return PrototypeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico do piquete',
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (loading && events.isEmpty)
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Carregando histórico...',
                  style: GoogleFonts.poppins(
                    color: theme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (events.isEmpty)
            const PrototypeEmptyState(
              title: 'Sem histórico registrado',
              message:
                  'As próximas alterações, vínculos de animais e vínculos de lotes aparecerão aqui com data e hora.',
              icon: Icons.history_rounded,
            )
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _HistoryEventRow(
                  event: event,
                  animal: _animalForEvent(event),
                ),
              ),
            ),
        ],
      ),
    );
  }

  AnimalPrototype? _animalForEvent(PiqueteHistoricoEvent event) {
    if (!event.tipo.contains('animal')) return null;
    for (final key in ['id_rebanho', 'idRebanho', 'animal_id', 'id']) {
      final value = event.metadata[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && animaisById.containsKey(value)) {
        return animaisById[value];
      }
    }
    return animaisById[event.entidadeId.trim()];
  }
}

class _HistoryEventRow extends StatelessWidget {
  const _HistoryEventRow({
    required this.event,
    required this.animal,
  });

  final PiqueteHistoricoEvent event;
  final AnimalPrototype? animal;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = _eventColor(theme, event.tipo);
    final date = dateTimeFormat(
      'd/M/y HH:mm',
      event.createdAt,
      locale: FFLocalizations.of(context).languageCode,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(kPiqueteRadius),
          ),
          child: _eventIcon(event.tipo, color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _eventTitle(event),
                style: GoogleFonts.poppins(
                  color: theme.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              _eventBody(context, event),
              const SizedBox(height: 4),
              Text(
                date,
                style: GoogleFonts.poppins(
                  color: theme.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eventBody(BuildContext context, PiqueteHistoricoEvent event) {
    final theme = FlutterFlowTheme.of(context);
    if (event.tipo.contains('animal')) {
      final title = _animalHistoryTitle(event);
      final subtitle = _animalHistorySubtitle(event);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: theme.secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ],
      );
    }

    return Text(
      _eventDescription(event),
      style: GoogleFonts.poppins(
        color: theme.secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }

  String _eventTitle(PiqueteHistoricoEvent event) {
    switch (event.tipo) {
      case 'criou_piquete':
        return 'Piquete criado';
      case 'atualizou_piquete':
        return 'Piquete atualizado';
      case 'alterou_nome':
        return 'Nome alterado';
      case 'alterou_area':
        return 'Área alterada';
      case 'alterou_forrageiras':
        return 'Forrageiras alteradas';
      case 'alterou_anotacoes':
        return 'Anotações alteradas';
      case 'alterou_demarcacao':
        return 'Demarcação alterada';
      case 'vinculou_animal':
        return 'Animal vinculado';
      case 'removeu_animal':
        return 'Animal removido';
      case 'vinculou_lote':
        return 'Lote vinculado';
      case 'removeu_lote':
        return 'Lote removido';
      case 'removeu_piquete':
        return 'Piquete excluído';
      default:
        return event.tipo.replaceAll('_', ' ');
    }
  }

  Widget _eventIcon(String tipo, Color color) {
    if (tipo.contains('animal')) {
      return Center(
        child: Image.asset(
          kPiqueteCowIconAsset,
          width: piqueteAssetIconSize(kPiqueteCowIconAsset, 20),
          height: piqueteAssetIconSize(kPiqueteCowIconAsset, 20),
          fit: BoxFit.contain,
        ),
      );
    }
    if (tipo.contains('lote')) {
      return Center(
        child: SvgPicture.asset(
          kPiqueteLoteIconAsset,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
        ),
      );
    }
    if (tipo.contains('demarcacao')) {
      return Icon(Icons.polyline_rounded, color: color, size: 18);
    }
    if (tipo.contains('removeu')) {
      return Icon(Icons.remove_circle_outline_rounded, color: color, size: 18);
    }
    if (tipo.contains('criou') || tipo.contains('vinculou')) {
      return Icon(Icons.add_circle_outline_rounded, color: color, size: 18);
    }
    return Icon(Icons.edit_note_rounded, color: color, size: 18);
  }

  String _eventDescription(PiqueteHistoricoEvent event) {
    final descricao = event.descricao.trim();
    if (event.tipo.contains('animal')) {
      final animal = _animalLabel(event);
      if (animal.isNotEmpty) {
        return event.tipo == 'removeu_animal'
            ? 'Animal $animal removido do piquete.'
            : 'Animal $animal vinculado ao piquete.';
      }
    }
    if (event.tipo.contains('lote')) {
      final lote = _metadataText(event, ['lote_nome', 'nome_lote', 'nome']);
      if (lote.isNotEmpty) {
        return event.tipo == 'removeu_lote'
            ? 'Lote $lote removido do piquete.'
            : 'Lote $lote vinculado ao piquete.';
      }
    }
    return descricao.isEmpty ? 'Evento registrado no piquete.' : descricao;
  }

  String _animalHistoryTitle(PiqueteHistoricoEvent event) {
    final currentAnimal = animal;
    final numero = _metadataText(event, [
      'numero_animal',
      'numeroAnimal',
      'animal_numero',
      'numero',
    ]);
    final numeroLabel = _firstNonEmpty(
      numero,
      currentAnimal?.numero.trim() ?? '',
    );
    final nome = _metadataText(event, [
      'animal_nome',
      'nome_animal',
      'nome',
    ]);
    final nomeLabel = _firstNonEmpty(
      nome,
      currentAnimal?.nome.trim() ?? '',
    );
    final dataNascimento = _formatAnimalDate(_metadataText(event, [
      'data_nascimento',
      'dataNascimento',
      'animal_data_nascimento',
    ]));
    final dataNascimentoLabel = _firstNonEmpty(
      dataNascimento,
      _formatAnimalDate(currentAnimal?.dataNascimento.trim() ?? ''),
    );
    final sexo = _metadataText(event, [
      'sexo',
      'animal_sexo',
    ]);
    final sexoLabel = _firstNonEmpty(
      sexo,
      currentAnimal?.sexo.trim() ?? '',
    );
    final sexoSymbol = _sexoSymbol(sexoLabel);
    final parts = [
      if (numeroLabel.isNotEmpty) numeroLabel,
      if (nomeLabel.isNotEmpty) nomeLabel,
      if (dataNascimentoLabel.isNotEmpty) dataNascimentoLabel,
    ];
    final label = parts.isEmpty ? event.entidadeId : parts.join(' - ');
    return sexoSymbol.isEmpty ? label : '$label $sexoSymbol';
  }

  String _animalHistorySubtitle(PiqueteHistoricoEvent event) {
    final currentAnimal = animal;
    final categoria = _metadataText(event, [
      'categoria',
      'animal_categoria',
    ]);
    final categoriaLabel = _firstNonEmpty(
      categoria,
      currentAnimal?.categoria.trim() ?? '',
    );
    final raca = _metadataText(event, [
      'raca',
      'animal_raca',
    ]);
    final racaLabel = _firstNonEmpty(
      raca,
      currentAnimal?.raca.trim() ?? '',
    );
    return [
      if (categoriaLabel.isNotEmpty) categoriaLabel,
      if (racaLabel.isNotEmpty) racaLabel,
    ].join(' • ');
  }

  String _animalLabel(PiqueteHistoricoEvent event) {
    final numero = _metadataText(event, [
      'numero_animal',
      'numeroAnimal',
      'animal_numero',
      'numero',
    ]);
    final nome = _metadataText(event, [
      'animal_nome',
      'nome_animal',
      'nome',
    ]);
    if (numero.isNotEmpty && nome.isNotEmpty) return '$numero - $nome';
    if (numero.isNotEmpty) return numero;
    if (nome.isNotEmpty) return nome;
    return event.entidadeId;
  }

  String _sexoSymbol(String sexo) {
    final normalized = sexo.trim().toLowerCase();
    if (normalized.startsWith('m')) return '♂';
    if (normalized.startsWith('f')) return '♀';
    return '';
  }

  String _formatAnimalDate(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    }
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(raw)) return raw;
    if (raw.length >= 10 && RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(raw)) {
      return '${raw.substring(8, 10)}/${raw.substring(5, 7)}/${raw.substring(0, 4)}';
    }
    return raw;
  }

  String _metadataText(PiqueteHistoricoEvent event, List<String> keys) {
    for (final key in keys) {
      final value = event.metadata[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _firstNonEmpty(String preferred, String fallback) {
    final cleanPreferred = preferred.trim();
    if (cleanPreferred.isNotEmpty) return cleanPreferred;
    return fallback.trim();
  }

  Color _eventColor(FlutterFlowTheme theme, String tipo) {
    if (tipo.contains('removeu')) return theme.error;
    if (tipo.contains('criou') || tipo.contains('vinculou')) {
      return theme.success;
    }
    if (tipo.contains('demarcacao')) return theme.warning;
    return theme.primary;
  }
}
