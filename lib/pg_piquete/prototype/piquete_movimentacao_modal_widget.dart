import '/flutter_flow/flutter_flow_util.dart';
import '/pg_piquete/data/piquete_backend_store.dart';
import '/pg_piquete/data/piquete_models.dart';
import '/pg_piquete/prototype/piquete_prototype_store.dart';
import '/pg_piquete/prototype/piquete_prototype_widgets.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PiqueteMovimentacaoModalWidget extends StatefulWidget {
  const PiqueteMovimentacaoModalWidget({
    super.key,
    required this.initial,
    required this.onClose,
    required this.onChanged,
  });

  final PiquetePrototype initial;
  final VoidCallback onClose;
  final ValueChanged<PiquetePrototype> onChanged;

  @override
  State<PiqueteMovimentacaoModalWidget> createState() =>
      _PiqueteMovimentacaoModalWidgetState();
}

class _PiqueteMovimentacaoModalWidgetState
    extends State<PiqueteMovimentacaoModalWidget> {
  final _store = PiqueteBackendStore.instance;
  final _searchController = TextEditingController();
  final _loteSearchController = TextEditingController();
  final Set<String> _selectedAnimalIds = {};
  final Set<String> _selectedLoteIds = {};
  final Set<String> _expandedLoteIds = {};
  final Set<String> _movingLoteIds = {};
  final Map<String, String> _loteDestinoIds = {};
  Timer? _searchDebounce;

  late PiquetePrototype _piquete;
  String _tab = 'historico';
  List<AnimalPrototype> _animalOptions = const [];
  List<LotePrototype> _loteOptions = const [];
  bool _loadingAnimals = false;
  bool _loadingLotes = false;
  bool _savingAnimals = false;
  bool _savingLotes = false;
  String? _animalError;
  String? _loteError;

  @override
  void initState() {
    super.initState();
    _piquete = widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnimals();
      _loadLotes();
    });
  }

  @override
  void didUpdateWidget(covariant PiqueteMovimentacaoModalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial.id != widget.initial.id) {
      _piquete = widget.initial;
      _selectedAnimalIds.clear();
      _selectedLoteIds.clear();
      _expandedLoteIds.clear();
      _loteDestinoIds.clear();
      _loadAnimals();
      _loadLotes();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _loteSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retiroNome = _store.retiroById(_piquete.retiroId)?.nome.trim() ?? '';
    final subtitle = [
      _piquete.nome,
      if (retiroNome.isNotEmpty) retiroNome,
    ].join(' • ');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPiqueteSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildHeader(subtitle),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetrics(),
                  const SizedBox(height: 14),
                  _buildTabs(),
                  const SizedBox(height: 18),
                  if (_tab == 'historico')
                    _buildHistorico()
                  else if (_tab == 'adicionar')
                    _buildAdicionarAnimais(),
                  if (_tab == 'lotes') _buildAdicionarLotes(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(String subtitle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: kPiqueteBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPiquetePrimarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: kPiquetePrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Movimentar animais',
                  style: GoogleFonts.poppins(
                    color: kPiqueteTextStrong,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: kPiqueteTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: kPiqueteTextMuted,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _MetricPill(
          iconAsset: kPiqueteCowIconAsset,
          value: _totalAnimaisLabel,
          label: 'animais',
        ),
        _MetricPill(
          iconAsset: kPiqueteLoteIconAsset,
          value: _piquete.totalLotes.toString(),
          label: 'lotes',
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kPiqueteFieldSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabPill(
            label: 'Histórico',
            selected: _tab == 'historico',
            onTap: () => setState(() => _tab = 'historico'),
          ),
          _TabPill(
            label: 'Adicionar animais',
            selected: _tab == 'adicionar',
            onTap: () => setState(() => _tab = 'adicionar'),
          ),
          _TabPill(
            label: 'Adicionar lotes',
            selected: _tab == 'lotes',
            onTap: () => setState(() => _tab = 'lotes'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorico() {
    final lotes = _store.lotesByIds(_piquete.lotesIds);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InfoCallout(
          icon: Icons.access_time_rounded,
          text:
              'Trajeto completo de cada lote e animal pelos piquetes, com datas de entrada e saída. Expanda um lote para ver os animais e mover o lote inteiro ou um animal individualmente.',
        ),
        const SizedBox(height: 12),
        if (lotes.isEmpty)
          const _EmptyMovementState(
            title: 'Nenhum lote no piquete',
            message:
                'Quando houver lotes vinculados, eles aparecerão aqui com o histórico de movimentação.',
          )
        else
          ...lotes.map(_buildLoteCard),
      ],
    );
  }

  Widget _buildLoteCard(LotePrototype lote) {
    final expanded = _expandedLoteIds.contains(lote.id);
    final moving = _movingLoteIds.contains(lote.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kPiqueteSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPiqueteBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              expanded
                  ? _expandedLoteIds.remove(lote.id)
                  : _expandedLoteIds.add(lote.id);
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: kPiqueteTextMuted,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const _SoftIcon(asset: kPiqueteLoteIconAsset),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lote.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: kPiqueteTextStrong,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${lote.qtdAnimais} animais · passou por ${_lotePiquetesPercorridos(lote)} piquetes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: kPiqueteTextMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _MoveLoteButton(
                    loading: moving,
                    onPressed: moving ? null : () => _toggleMovePanel(lote),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            _buildMoveLotePanel(lote),
            _buildLoteDetails(lote),
          ],
        ],
      ),
    );
  }

  Widget _buildMoveLotePanel(LotePrototype lote) {
    final destinos = _destinosDisponiveis();
    final selectedDestino = _loteDestinoIds[lote.id] ??
        (destinos.isNotEmpty ? destinos.first.id : '');
    if (destinos.isNotEmpty && _loteDestinoIds[lote.id] == null) {
      _loteDestinoIds[lote.id] = selectedDestino;
    }

    return Container(
      color: kPiquetePrimarySurface,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        children: [
          Text(
            'Mover lote para',
            style: GoogleFonts.poppins(
              color: kPiqueteTextStrong,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kPiqueteSurface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFD5E8DC)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDestino.isEmpty ? null : selectedDestino,
                  hint: const Text('Selecione o destino'),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: GoogleFonts.poppins(
                    color: kPiqueteTextStrong,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  items: destinos
                      .map(
                        (destino) => DropdownMenuItem(
                          value: destino.id,
                          child: Text(_piqueteDestinoLabel(destino)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _loteDestinoIds[lote.id] = value ?? '',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _CompactButton(
            label: 'Confirmar',
            primary: true,
            onPressed:
                selectedDestino.isEmpty || _movingLoteIds.contains(lote.id)
                    ? null
                    : () => _moveLote(lote, selectedDestino),
          ),
          const SizedBox(width: 8),
          _CompactButton(
            label: 'Cancelar',
            onPressed: () => setState(() => _expandedLoteIds.remove(lote.id)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoteDetails(LotePrototype lote) {
    final events = _eventsForLote(lote);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('TRAJETO DO LOTE'),
          const SizedBox(height: 8),
          _TrajectoryTable(
            piqueteName: _piquete.nome,
            events: events,
            currentPiqueteId: _piquete.id,
          ),
          const SizedBox(height: 14),
          const _SectionLabel('ANIMAIS DO LOTE'),
          const SizedBox(height: 8),
          const _EmptyMovementState(
            compact: true,
            title: 'Animais do lote indisponíveis',
            message:
                'O backend atual informa a quantidade do lote, mas não envia a lista de animais por lote para este modal.',
          ),
        ],
      ),
    );
  }

  Widget _buildAdicionarAnimais() {
    return Column(
      children: [
        const _InfoCallout(
          icon: Icons.add_circle_outline_rounded,
          text:
              'Selecione animais individualmente para adicionar a este piquete — útil para ir compondo um lote aos poucos (ex.: descarte).',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (_) => _scheduleAnimalSearch(),
          style: GoogleFonts.poppins(
            color: kPiqueteTextStrong,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar por brinco, categoria ou raça',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: kPiqueteTextSoft,
              size: 20,
            ),
            hintStyle: GoogleFonts.poppins(
              color: kPiqueteTextMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: kPiqueteFieldSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: kPiqueteBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: kPiquetePrimary, width: 1.3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_loadingAnimals)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: CircularProgressIndicator(color: kPiquetePrimary),
          )
        else if (_animalError != null)
          _EmptyMovementState(
            title: 'Não foi possível carregar os animais',
            message: _animalError!,
          )
        else if (_animalOptions.isEmpty)
          const _EmptyMovementState(
            title: 'Nenhum animal disponível',
            message:
                'Ajuste a busca ou confira se há animais disponíveis para este piquete.',
          )
        else
          ..._animalOptions.map(_buildAnimalRow),
      ],
    );
  }

  Widget _buildAdicionarLotes() {
    return Column(
      children: [
        const _InfoCallout(
          icon: Icons.playlist_add_rounded,
          text:
              'Selecione lotes inteiros para vincular a este piquete. Lotes já vinculados aqui ou em outro piquete ativo não aparecem na lista.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loteSearchController,
          onChanged: (_) => _scheduleLoteSearch(),
          style: GoogleFonts.poppins(
            color: kPiqueteTextStrong,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar lote por nome',
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: kPiqueteTextSoft,
              size: 20,
            ),
            hintStyle: GoogleFonts.poppins(
              color: kPiqueteTextMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: kPiqueteFieldSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: kPiqueteBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: kPiquetePrimary, width: 1.3),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_loadingLotes)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: CircularProgressIndicator(color: kPiquetePrimary),
          )
        else if (_loteError != null)
          _EmptyMovementState(
            title: 'Não foi possível carregar os lotes',
            message: _loteError!,
          )
        else if (_loteOptions.isEmpty)
          const _EmptyMovementState(
            title: 'Nenhum lote disponível',
            message:
                'Ajuste a busca ou confira se há lotes disponíveis para este piquete.',
          )
        else
          ..._loteOptions.map(_buildAddLoteRow),
      ],
    );
  }

  Widget _buildAddLoteRow(LotePrototype lote) {
    final selected = _selectedLoteIds.contains(lote.id);

    return InkWell(
      onTap: () => setState(() {
        selected
            ? _selectedLoteIds.remove(lote.id)
            : _selectedLoteIds.add(lote.id);
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: selected ? kPiquetePrimarySurface : kPiqueteSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kPiquetePrimary : kPiqueteBorder,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            const _SoftIcon(asset: kPiqueteLoteIconAsset),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lote.nome,
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextStrong,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lote.qtdAnimais} animais · ${lote.status}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? kPiquetePrimary : kPiqueteSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kPiquetePrimary : const Color(0xFFD6DDD7),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 17)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalRow(AnimalPrototype animal) {
    final selected = _selectedAnimalIds.contains(animal.id);

    return InkWell(
      onTap: () => setState(() {
        selected
            ? _selectedAnimalIds.remove(animal.id)
            : _selectedAnimalIds.add(animal.id);
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: selected ? kPiquetePrimarySurface : kPiqueteSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kPiquetePrimary : kPiqueteBorder,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          children: [
            _SoftIcon(icon: _sexoIcon(animal.sexo)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _animalTitle(animal),
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextStrong,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _animalSubtitle(animal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? kPiquetePrimary : kPiqueteSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kPiquetePrimary : const Color(0xFFD6DDD7),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 17)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final addingAnimals = _tab == 'adicionar';
    final addingLotes = _tab == 'lotes';
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        color: kPiqueteSurface,
        border: const Border(top: BorderSide(color: kPiqueteBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (addingAnimals || addingLotes)
            Expanded(
              child: Text(
                addingAnimals
                    ? (_selectedAnimalIds.length == 1
                        ? '1 animal selecionado'
                        : '${_selectedAnimalIds.length} animais selecionados')
                    : (_selectedLoteIds.length == 1
                        ? '1 lote selecionado'
                        : '${_selectedLoteIds.length} lotes selecionados'),
                style: GoogleFonts.poppins(
                  color: kPiqueteTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Spacer(),
          ElevatedButton(
            onPressed: addingAnimals
                ? (_selectedAnimalIds.isEmpty || _savingAnimals
                    ? null
                    : _addSelectedAnimals)
                : addingLotes
                    ? (_selectedLoteIds.isEmpty || _savingLotes
                        ? null
                        : _addSelectedLotes)
                    : widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPiquetePrimary,
              disabledBackgroundColor: kPiquetePrimary.withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              elevation: addingAnimals || addingLotes ? 8 : 0,
              shadowColor: kPiquetePrimary.withValues(alpha: 0.22),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            child: _savingAnimals || _savingLotes
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(addingAnimals || addingLotes
                    ? 'Adicionar ao piquete'
                    : 'Fechar'),
          ),
        ],
      ),
    );
  }

  String get _totalAnimaisLabel {
    final total = _piquete.totalAnimaisIndividuais + _piquete.animaisLotesCount;
    return total.toString();
  }

  List<PiquetePrototype> _destinosDisponiveis() {
    return _store.piquetes
        .where((piquete) => piquete.id != _piquete.id)
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  String _piqueteDestinoLabel(PiquetePrototype destino) {
    final retiroNome = _store.retiroById(destino.retiroId)?.nome.trim() ?? '';
    return retiroNome.isEmpty ? destino.nome : '${destino.nome} • $retiroNome';
  }

  int _lotePiquetesPercorridos(LotePrototype lote) {
    final eventPiquetes = _eventsForLote(lote)
        .map((event) => event.piqueteIdFromEvent(_piquete.id))
        .where((id) => id.isNotEmpty)
        .toSet();
    if (eventPiquetes.isEmpty) return 1;
    return eventPiquetes.length;
  }

  List<PiqueteHistoricoEvent> _eventsForLote(LotePrototype lote) {
    return _store
        .historicoDoPiquete(_piquete.id)
        .where((event) => event.tipo.contains('lote'))
        .where((event) {
      if (event.entidadeId == lote.id) return true;
      final metadata = event.metadata;
      return [
        'lote_id',
        'id_lote',
        'loteId',
        'id',
      ].any((key) => metadata[key]?.toString() == lote.id);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _toggleMovePanel(LotePrototype lote) {
    setState(() {
      _expandedLoteIds.contains(lote.id)
          ? _expandedLoteIds.remove(lote.id)
          : _expandedLoteIds.add(lote.id);
    });
  }

  void _scheduleAnimalSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _loadAnimals);
  }

  void _scheduleLoteSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _loadLotes);
  }

  Future<void> _loadAnimals() async {
    if (!mounted) return;
    setState(() {
      _loadingAnimals = true;
      _animalError = null;
    });

    try {
      final page = await _store.buscarAnimaisDisponiveisPage(
        piqueteId: _piquete.id,
        pesquisa: _searchController.text.trim(),
        limit: 80,
      );
      if (!mounted) return;
      final currentAnimalIds = _piquete.animaisIds.toSet();
      final availableAnimals = page.items
          .where((animal) => !currentAnimalIds.contains(animal.id))
          .toList();
      setState(() {
        _animalOptions = availableAnimals;
        _selectedAnimalIds.removeWhere(currentAnimalIds.contains);
        _loadingAnimals = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _animalOptions = const [];
        _loadingAnimals = false;
        _animalError =
            _store.errorMessage ?? 'Não foi possível carregar os animais.';
      });
    }
  }

  Future<void> _loadLotes() async {
    if (!mounted) return;
    setState(() {
      _loadingLotes = true;
      _loteError = null;
    });

    try {
      final page = await _store.buscarTodosLotesPiquetePage(
        pesquisa: _loteSearchController.text.trim(),
        limit: 80,
      );
      if (!mounted) return;
      final currentLoteIds = _piquete.lotesIds.toSet();
      final availableLotes = page.items
          .where((lote) => !currentLoteIds.contains(lote.id))
          .toList();
      setState(() {
        _loteOptions = availableLotes;
        _selectedLoteIds.removeWhere(currentLoteIds.contains);
        _loadingLotes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loteOptions = const [];
        _loadingLotes = false;
        _loteError =
            _store.errorMessage ?? 'Não foi possível carregar os lotes.';
      });
    }
  }

  Future<void> _addSelectedAnimals() async {
    setState(() => _savingAnimals = true);
    try {
      final nextAnimalIds = {
        ..._piquete.animaisIds,
        ..._selectedAnimalIds,
      }.toList();
      final updated = await _store.updatePiquete(
        _piquete.copyWith(animaisIds: nextAnimalIds),
      );
      if (!mounted) return;
      setState(() {
        _piquete = updated;
        _selectedAnimalIds.clear();
        _savingAnimals = false;
      });
      widget.onChanged(updated);
      await _loadAnimals();
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingAnimals = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível adicionar os animais ao piquete.',
          ),
          backgroundColor: kPiqueteDanger,
        ),
      );
    }
  }

  Future<void> _addSelectedLotes() async {
    setState(() => _savingLotes = true);
    try {
      final updated = await _store.moverLotesParaPiquete(
        piqueteId: _piquete.id,
        lotesIds: _selectedLoteIds.toList(),
      );
      if (!mounted) return;
      setState(() {
        _piquete = updated;
        _selectedLoteIds.clear();
        _savingLotes = false;
      });
      widget.onChanged(updated);
      await _loadLotes();
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingLotes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ??
                'Não foi possível adicionar os lotes ao piquete.',
          ),
          backgroundColor: kPiqueteDanger,
        ),
      );
    }
  }

  Future<void> _moveLote(LotePrototype lote, String destinoId) async {
    final destino = _store.piqueteById(destinoId);
    if (destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um piquete de destino válido.'),
          backgroundColor: kPiqueteDanger,
        ),
      );
      return;
    }

    setState(() => _movingLoteIds.add(lote.id));
    try {
      await _store.moverLotesParaPiquete(
        piqueteId: destino.id,
        lotesIds: [lote.id],
      );

      final updatedCurrent = await _store.loadPiqueteDetail(_piquete.id) ??
          _piquete.copyWith(
            lotesIds: _piquete.lotesIds.where((id) => id != lote.id).toList(),
          );
      if (!mounted) return;
      setState(() {
        _piquete = updatedCurrent;
        _movingLoteIds.remove(lote.id);
        _expandedLoteIds.remove(lote.id);
      });
      widget.onChanged(updatedCurrent);
    } catch (_) {
      if (!mounted) return;
      setState(() => _movingLoteIds.remove(lote.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _store.errorMessage ?? 'Não foi possível mover o lote.',
          ),
          backgroundColor: kPiqueteDanger,
        ),
      );
    }
  }

  String _animalTitle(AnimalPrototype animal) {
    if (animal.numero.trim().isNotEmpty) return animal.numero.trim();
    if (animal.nome.trim().isNotEmpty) return animal.nome.trim();
    return animal.id;
  }

  String _animalSubtitle(AnimalPrototype animal) {
    return [
      animal.categoria,
      animal.sexo,
      animal.raca,
      animal.loteNome,
    ].map((part) => part.trim()).where((part) => part.isNotEmpty).join(' · ');
  }

  IconData _sexoIcon(String sexo) {
    return sexo.trim().toLowerCase().startsWith('m')
        ? Icons.male_rounded
        : Icons.female_rounded;
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.iconAsset,
    required this.value,
    required this.label,
  });

  final String iconAsset;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: kPiqueteSurfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDECE4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconAsset.toLowerCase().endsWith('.svg')
              ? SvgPicture.asset(
                  iconAsset,
                  width: 17,
                  height: 17,
                  colorFilter: const ColorFilter.mode(
                    kPiquetePrimaryDark,
                    BlendMode.srcIn,
                  ),
                )
              : Image.asset(
                  iconAsset,
                  width: piqueteAssetIconSize(iconAsset, 18),
                  height: piqueteAssetIconSize(iconAsset, 18),
                  fit: BoxFit.contain,
                ),
          const SizedBox(width: 9),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: kPiquetePrimaryDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: kPiqueteTextStrong,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? kPiquetePrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: selected ? Colors.white : kPiqueteTextMuted,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoCallout extends StatelessWidget {
  const _InfoCallout({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: kPiqueteSurfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDECE4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPiquetePrimaryDark, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: const Color(0xFF325143),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({this.asset, this.icon});

  final String? asset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: kPiqueteSurfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: asset != null
          ? Center(
              child: SvgPicture.asset(
                asset!,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  kPiquetePrimaryDark,
                  BlendMode.srcIn,
                ),
              ),
            )
          : Icon(icon, color: kPiqueteTextMuted, size: 19),
    );
  }
}

class _MoveLoteButton extends StatelessWidget {
  const _MoveLoteButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: loading
          ? const SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.compare_arrows_rounded, size: 16),
      label: const Text('Mover lote'),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPiquetePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CompactButton extends StatelessWidget {
  const _CompactButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    final style = primary
        ? ElevatedButton.styleFrom(
            backgroundColor: kPiquetePrimary,
            disabledBackgroundColor: kPiquetePrimary.withValues(alpha: 0.45),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            textStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: kPiqueteTextMuted,
            backgroundColor: kPiqueteSurface,
            side: const BorderSide(color: Color(0xFFD8DDD8)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            textStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          );
    return primary
        ? ElevatedButton(onPressed: onPressed, style: style, child: child)
        : OutlinedButton(onPressed: onPressed, style: style, child: child);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: kPiqueteTextSoft,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _TrajectoryTable extends StatelessWidget {
  const _TrajectoryTable({
    required this.piqueteName,
    required this.events,
    required this.currentPiqueteId,
  });

  final String piqueteName;
  final List<PiqueteHistoricoEvent> events;
  final String currentPiqueteId;

  @override
  Widget build(BuildContext context) {
    final rows = events.isEmpty
        ? [
            _TrajectoryRow(
              piquete: piqueteName,
              entrada: '',
              saida: 'No piquete',
              current: true,
            ),
          ]
        : events.map((event) {
            final isCurrent =
                event.piqueteIdFromEvent(currentPiqueteId) == currentPiqueteId;
            return _TrajectoryRow(
              piquete: event.metadataText(
                ['piquete_nome', 'nome_piquete', 'piquete'],
                fallback: isCurrent ? piqueteName : 'Piquete',
              ),
              entrada: event.tipo == 'vinculou_lote'
                  ? dateTimeFormat(
                      'dd/MM/y',
                      event.createdAt,
                      locale: FFLocalizations.of(context).languageCode,
                    )
                  : '',
              saida: event.tipo == 'removeu_lote'
                  ? dateTimeFormat(
                      'dd/MM/y',
                      event.createdAt,
                      locale: FFLocalizations.of(context).languageCode,
                    )
                  : (isCurrent ? 'No piquete' : ''),
              current: isCurrent,
            );
          }).toList();

    return Container(
      decoration: BoxDecoration(
        color: kPiqueteSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPiqueteBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: kPiqueteFieldSurface,
            child: const Row(
              children: [
                Expanded(flex: 2, child: _TableHeader('PIQUETE')),
                Expanded(child: _TableHeader('ENTRADA')),
                Expanded(child: _TableHeader('SAÍDA')),
              ],
            ),
          ),
          ...rows.map((row) => row),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: kPiqueteTextSoft,
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TrajectoryRow extends StatelessWidget {
  const _TrajectoryRow({
    required this.piquete,
    required this.entrada,
    required this.saida,
    required this.current,
  });

  final String piquete;
  final String entrada;
  final String saida;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kPiqueteBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    piquete,
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextStrong,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (current) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: kPiquetePrimarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Atual',
                      style: GoogleFonts.poppins(
                        color: kPiquetePrimaryDark,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(child: _DatePill(text: entrada, up: true)),
          Expanded(child: _DatePill(text: saida, up: false)),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.text,
    required this.up,
  });

  final String text;
  final bool up;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    if (text == 'No piquete') {
      return Text(
        text,
        style: GoogleFonts.poppins(
          color: kPiqueteTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: up ? kPiquetePrimarySurface : kPiqueteDangerSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: up ? kPiquetePrimaryDark : kPiqueteDanger,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: up ? kPiquetePrimaryDark : kPiqueteDanger,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMovementState extends StatelessWidget {
  const _EmptyMovementState({
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 18),
      decoration: BoxDecoration(
        color: kPiqueteFieldSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPiqueteBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: kPiqueteTextStrong,
              fontSize: compact ? 12.5 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: kPiqueteTextMuted,
              fontSize: compact ? 11.5 : 12.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

extension on PiqueteHistoricoEvent {
  String metadataText(List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = metadata[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String piqueteIdFromEvent(String fallback) {
    return metadataText(
      ['piquete_id', 'id_piquete', 'piqueteId'],
      fallback: fallback,
    );
  }
}
