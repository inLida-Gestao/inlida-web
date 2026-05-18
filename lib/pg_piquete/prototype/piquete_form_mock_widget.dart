import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import '../data/piquete_backend_store.dart';
import 'mapa_demarcacao_real_widget.dart';
import 'piquete_prototype_store.dart';
import 'piquete_prototype_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PiqueteFormResult {
  const PiqueteFormResult({
    required this.retiroId,
    required this.nome,
    required this.areaHa,
    required this.forrageiras,
    required this.anotacoes,
    required this.pontos,
    required this.animaisIds,
    required this.lotesIds,
  });

  final String retiroId;
  final String nome;
  final double areaHa;
  final List<String> forrageiras;
  final String anotacoes;
  final List<MapPoint> pontos;
  final List<String> animaisIds;
  final List<String> lotesIds;
}

class PiqueteFormMockWidget extends StatefulWidget {
  const PiqueteFormMockWidget({
    super.key,
    this.initial,
    required this.onCancel,
    required this.onSave,
  });

  final PiquetePrototype? initial;
  final VoidCallback onCancel;
  final ValueChanged<PiqueteFormResult> onSave;

  @override
  State<PiqueteFormMockWidget> createState() => _PiqueteFormMockWidgetState();
}

class _PiqueteFormMockWidgetState extends State<PiqueteFormMockWidget> {
  final _store = PiqueteBackendStore.instance;
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _anotacoesController = TextEditingController();
  final _searchAvailableController = TextEditingController();
  final _searchSelectedController = TextEditingController();

  late String _retiroId;
  late List<String> _forrageirasSelecionadas;
  late String _mode;
  late List<MapPoint> _pontos;
  late List<String> _animaisIds;
  late List<String> _lotesIds;
  late bool _areaEditadaManualmente;

  static const _forrageiraOptions = [
    'Brachiaria ruziensis',
    'Massai (Panicum maximum)',
    'Mombaça',
    'Tifton 85',
    'Capim elefante',
  ];

  @override
  void initState() {
    super.initState();
    _applyInitial(widget.initial);
  }

  @override
  void didUpdateWidget(covariant PiqueteFormMockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_initialIdentity(widget.initial) !=
        _initialIdentity(oldWidget.initial)) {
      _applyInitial(widget.initial);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _anotacoesController.dispose();
    _searchAvailableController.dispose();
    _searchSelectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retiro = _retiroId.isEmpty ? null : _store.retiroById(_retiroId);
    final newPiqueteSemRetiro = widget.initial == null && retiro == null;
    final piqueteAreas = newPiqueteSemRetiro
        ? const <PiqueteMapArea>[]
        : _existingPiqueteAreas();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrototypeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(
                    width: 340,
                    child: _DropdownField(
                      label: 'Retiro',
                      value: _retiroId,
                      items: [
                        const DropdownMenuItem(
                          value: PiqueteBackendStore.semRetiroId,
                          child: Text('Sem retiro'),
                        ),
                        ..._store.retiros.map(
                          (r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(r.nome),
                          ),
                        ),
                      ],
                      onChanged: _selectRetiro,
                    ),
                  ),
                  SizedBox(
                    width: 340,
                    child: _TextField(
                      label: 'Nome do piquete',
                      hint: 'Ex.: Tradição Campeira',
                      controller: _nomeController,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: _TextField(
                      label: 'Área (ha)',
                      hint: '23',
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _areaEditadaManualmente = true,
                    ),
                  ),
                  SizedBox(
                    width: 340,
                    child: _MultiSelectField(
                      label: 'Forrageiras',
                      values: _forrageirasSelecionadas,
                      options: _forrageiraOptions,
                      onChanged: (values) => safeSetState(
                        () => _forrageirasSelecionadas = values,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _TextField(
                label: 'Anotações',
                hint: 'Observações sobre manejo, água, sombra ou descanso.',
                controller: _anotacoesController,
                maxLines: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        MapaDemarcacaoRealWidget(
          title: retiro == null
              ? 'Demarcação do piquete sem retiro'
              : 'Demarcação dentro de ${retiro.nome}',
          points: _pontos,
          retiroPoints: retiro?.pontos ?? const [],
          piqueteAreas: piqueteAreas,
          editable: true,
          height: 548,
          preferUserLocation: newPiqueteSemRetiro,
          onChanged: _handleMapChanged,
          onImported: _handleKmlImported,
        ),
        const SizedBox(height: 22),
        PrototypeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adicionar no piquete',
                style: GoogleFonts.poppins(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: 'Adicionar animal',
                      selected: _mode == 'animal',
                      onTap: () => safeSetState(() => _mode = 'animal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModeButton(
                      label: 'Adicionar lote',
                      selected: _mode == 'lote',
                      onTap: () => safeSetState(() => _mode = 'lote'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _mode == 'animal' ? _buildAnimalSelector() : _buildLoteSelector(),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrototypeSecondaryButton(
              label: 'Cancelar',
              onPressed: widget.onCancel,
            ),
            PrototypePrimaryButton(
              label: 'Salvar',
              icon: Icons.check_rounded,
              onPressed: _submit,
            ),
          ].divide(const SizedBox(width: 14)),
        ),
      ],
    );
  }

  Widget _buildAnimalSelector() {
    final availableQuery = _searchAvailableController.text.trim().toLowerCase();
    final selectedQuery = _searchSelectedController.text.trim().toLowerCase();
    final selectedSet = _animaisIds.toSet();
    final available = _store
        .animaisDisponiveis(exceptPiqueteId: widget.initial?.id)
        .where((a) => !selectedSet.contains(a.id))
        .where((a) => a.status.trim().toLowerCase() == 'na propriedade')
        .where((a) =>
            availableQuery.isEmpty ||
            a.nome.toLowerCase().contains(availableQuery) ||
            a.numero.toLowerCase().contains(availableQuery))
        .toList();
    final selected = _store.animaisByIds(_animaisIds).where((a) {
      return selectedQuery.isEmpty ||
          a.nome.toLowerCase().contains(selectedQuery) ||
          a.numero.toLowerCase().contains(selectedQuery);
    }).toList();

    return _DualPanel<AnimalPrototype>(
      leftTitle: 'Animais fora deste piquete (${available.length})',
      rightTitle: 'Animais neste piquete (${_animaisIds.length})',
      leftItems: available,
      rightItems: selected,
      leftSearch: _searchAvailableController,
      rightSearch: _searchSelectedController,
      emptyRightMessage:
          'Nenhum animal foi adicionado neste piquete. Selecione um animal à esquerda.',
      itemBuilder: (animal) => _AnimalTile(animal: animal),
      onAdd: (animal) => safeSetState(() => _animaisIds.add(animal.id)),
      onRemove: (animal) =>
          safeSetState(() => _animaisIds.removeWhere((id) => id == animal.id)),
      onSearchChanged: () => safeSetState(() {}),
    );
  }

  void _selectRetiro(String? value) {
    final nextValue = value ?? PiqueteBackendStore.semRetiroId;
    if (nextValue == _retiroId) {
      return;
    }

    safeSetState(() {
      _retiroId = nextValue;
      if (widget.initial == null) {
        _pontos = [];
        if (!_areaEditadaManualmente) {
          _areaController.text = '0';
        }
      }
    });
    unawaited(_loadPiquetesDoRetiro(nextValue));
  }

  Future<void> _loadPiquetesDoRetiro(String retiroId) async {
    try {
      await _store.selectRetiro(retiroId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível carregar os piquetes deste retiro.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  void _handleMapChanged(List<MapPoint> value) {
    safeSetState(() {
      _pontos = value;
      if (!_areaEditadaManualmente) {
        final area = estimateMapAreaHa(value);
        _areaController.text = area > 0 ? area.toStringAsFixed(2) : '0';
      }
    });
  }

  void _handleKmlImported(List<MapPoint> value) {
    safeSetState(() {
      _pontos = value;
      _areaEditadaManualmente = false;
      final area = estimateMapAreaHa(value);
      _areaController.text = area > 0 ? area.toStringAsFixed(2) : '0';
    });
  }

  Widget _buildLoteSelector() {
    final availableQuery = _searchAvailableController.text.trim().toLowerCase();
    final selectedQuery = _searchSelectedController.text.trim().toLowerCase();
    final selectedSet = _lotesIds.toSet();
    final available = _store
        .lotesDisponiveis(exceptPiqueteId: widget.initial?.id)
        .where((l) => !selectedSet.contains(l.id))
        .where((l) => l.status.trim().toLowerCase() == 'ativo')
        .where((l) =>
            availableQuery.isEmpty ||
            l.nome.toLowerCase().contains(availableQuery))
        .toList();
    final selected = _store.lotesByIds(_lotesIds).where((l) {
      return selectedQuery.isEmpty ||
          l.nome.toLowerCase().contains(selectedQuery);
    }).toList();

    return _DualPanel<LotePrototype>(
      leftTitle: 'Lotes fora deste piquete (${available.length})',
      rightTitle: 'Lotes neste piquete (${_lotesIds.length})',
      leftItems: available,
      rightItems: selected,
      leftSearch: _searchAvailableController,
      rightSearch: _searchSelectedController,
      emptyRightMessage:
          'Nenhum lote foi adicionado neste piquete. Selecione um lote à esquerda.',
      itemBuilder: (lote) => _LoteTile(lote: lote),
      onAdd: (lote) => safeSetState(() => _lotesIds.add(lote.id)),
      onRemove: (lote) =>
          safeSetState(() => _lotesIds.removeWhere((id) => id == lote.id)),
      onSearchChanged: () => safeSetState(() {}),
    );
  }

  void _submit() {
    final initial = widget.initial;
    final typedNome = _nomeController.text.trim();
    final parsedArea =
        double.tryParse(_areaController.text.replaceAll(',', '.'));
    final nome = typedNome.isNotEmpty ? typedNome : (initial?.nome ?? '');
    final area = (parsedArea != null && parsedArea > 0)
        ? parsedArea
        : (initial?.areaHa ?? 0);
    final retiroId = _retiroId;
    final fallbackForrageiras = initial?.forrageiras.isNotEmpty == true
        ? initial!.forrageiras
        : [_forrageiraOptions.first];
    final forrageiras = _forrageirasSelecionadas.isNotEmpty
        ? _forrageirasSelecionadas
        : fallbackForrageiras;
    final pontos = _pontos.length >= 3 ? _pontos : (initial?.pontos ?? []);

    if (nome.isEmpty || area <= 0 || forrageiras.isEmpty || pontos.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Informe nome, área, ao menos uma forrageira e 3 pontos no mapa.',
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    widget.onSave(
      PiqueteFormResult(
        retiroId: retiroId,
        nome: nome,
        areaHa: area,
        forrageiras: forrageiras,
        anotacoes: _anotacoesController.text.trim(),
        pontos: pontos,
        animaisIds: _animaisIds,
        lotesIds: _lotesIds,
      ),
    );
  }

  void _applyInitial(PiquetePrototype? initial) {
    _retiroId = initial?.retiroId ??
        _store.selectedRetiro?.id ??
        PiqueteBackendStore.semRetiroId;
    final initialForrageiras = initial?.forrageiras
            .where((forrageira) => forrageira.trim().isNotEmpty)
            .toList() ??
        const <String>[];
    _forrageirasSelecionadas = initialForrageiras.isNotEmpty
        ? initialForrageiras
        : [_forrageiraOptions.first];
    _mode = (initial?.lotesIds.isNotEmpty ?? false) ? 'lote' : 'animal';
    _pontos = initial?.pontos.toList() ?? [];
    _animaisIds = initial?.animaisIds.toList() ?? [];
    _lotesIds = initial?.lotesIds.toList() ?? [];
    _areaEditadaManualmente = initial != null;
    _nomeController.text = initial?.nome ?? '';
    _areaController.text = _formatAreaForInput(initial?.areaHa ?? 0);
    _anotacoesController.text = initial?.anotacoes ?? '';
  }

  String _formatAreaForInput(double area) {
    if (area <= 0) return '0';
    if (area < 1) return area.toStringAsFixed(2);
    if (area % 1 == 0) return area.toStringAsFixed(0);
    return area.toStringAsFixed(2);
  }

  List<PiqueteMapArea> _existingPiqueteAreas() {
    final currentPiqueteId = widget.initial?.id;
    return _store
        .piquetesDoRetiro(_retiroId)
        .where((piquete) => piquete.id != currentPiqueteId)
        .where((piquete) => piquete.pontos.length >= 3)
        .map(
          (piquete) => PiqueteMapArea(
            name: piquete.nome,
            points: piquete.pontos,
          ),
        )
        .toList();
  }

  String _initialIdentity(PiquetePrototype? piquete) => piquete?.id ?? 'novo';
}

class _DualPanel<T> extends StatelessWidget {
  const _DualPanel({
    required this.leftTitle,
    required this.rightTitle,
    required this.leftItems,
    required this.rightItems,
    required this.leftSearch,
    required this.rightSearch,
    required this.emptyRightMessage,
    required this.itemBuilder,
    required this.onAdd,
    required this.onRemove,
    required this.onSearchChanged,
  });

  final String leftTitle;
  final String rightTitle;
  final List<T> leftItems;
  final List<T> rightItems;
  final TextEditingController leftSearch;
  final TextEditingController rightSearch;
  final String emptyRightMessage;
  final Widget Function(T item) itemBuilder;
  final ValueChanged<T> onAdd;
  final ValueChanged<T> onRemove;
  final VoidCallback onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final left = _SelectionPanel<T>(
          title: leftTitle,
          items: leftItems,
          searchController: leftSearch,
          itemBuilder: itemBuilder,
          actionIcon: Icons.chevron_right_rounded,
          actionLabel: 'Adicionar',
          onAction: onAdd,
          onSearchChanged: onSearchChanged,
        );
        final right = _SelectionPanel<T>(
          title: rightTitle,
          items: rightItems,
          searchController: rightSearch,
          itemBuilder: itemBuilder,
          actionIcon: Icons.chevron_left_rounded,
          actionLabel: 'Remover',
          onAction: onRemove,
          emptyMessage: emptyRightMessage,
          onSearchChanged: onSearchChanged,
        );
        if (narrow) {
          return Column(
            children: [left, const SizedBox(height: 18), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 24),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _SelectionPanel<T> extends StatelessWidget {
  const _SelectionPanel({
    required this.title,
    required this.items,
    required this.searchController,
    required this.itemBuilder,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
    required this.onSearchChanged,
    this.emptyMessage,
  });

  final String title;
  final List<T> items;
  final TextEditingController searchController;
  final Widget Function(T item) itemBuilder;
  final IconData actionIcon;
  final String actionLabel;
  final ValueChanged<T> onAction;
  final VoidCallback onSearchChanged;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border.all(color: theme.customColor5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 5,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          PrototypeSearchField(
            controller: searchController,
            hint: 'Pesquisar',
            onChanged: (_) => onSearchChanged(),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 58),
              child: PrototypeEmptyState(
                title: 'Nada por aqui',
                message: emptyMessage ?? 'Nenhum item encontrado para seleção.',
                icon: Icons.inbox_outlined,
              ),
            )
          else
            ...items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.customColor5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: itemBuilder(item)),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => onAction(item),
                      icon: Icon(actionIcon, size: 18),
                      label: Text(actionLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.secondary,
                        side: BorderSide(color: theme.secondary),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _AnimalTile extends StatelessWidget {
  const _AnimalTile({required this.animal});

  final AnimalPrototype animal;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${animal.numero} • ${animal.nome} • ${animal.dataNascimento}',
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${animal.categoria} • ${animal.raca} • ${animal.loteNome}',
          style: GoogleFonts.poppins(
            color: theme.secondaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoteTile extends StatelessWidget {
  const _LoteTile({required this.lote});

  final LotePrototype lote;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Icon(Icons.bubble_chart_outlined, color: theme.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lote.nome,
                style: GoogleFonts.poppins(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${lote.qtdAnimais} animais',
                style: GoogleFonts.poppins(
                  color: theme.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PrototypeBadge(
          label: lote.status,
          color: lote.status == 'Ativo' ? theme.primary : theme.secondaryText,
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: theme.customColor2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? theme.secondary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? theme.secondary : theme.secondaryText,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.customColor2,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.customColor2,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.values,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final List<String> values;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: theme.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showPicker(context),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.customColor2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: values.isEmpty
                      ? Text(
                          'Selecionar forrageiras',
                          style: GoogleFonts.poppins(
                            color: theme.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: values
                              .map(
                                (value) => PrototypeBadge(
                                  label: value,
                                  icon: Icons.grass_outlined,
                                  color: theme.secondary,
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = values.toSet();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = FlutterFlowTheme.of(context);
            return AlertDialog(
              backgroundColor: theme.secondaryBackground,
              title: Text(
                'Selecionar forrageiras',
                style: GoogleFonts.poppins(
                  color: theme.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    final checked = selected.contains(option);
                    return CheckboxListTile(
                      value: checked,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: theme.primary,
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(
                          color: theme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value ?? false) {
                            selected.add(option);
                          } else {
                            selected.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    options
                        .where((option) => selected.contains(option))
                        .toList(),
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}
