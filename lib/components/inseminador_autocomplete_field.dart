import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de inseminador com autocompletar: sugere os inseminadores já usados na
/// propriedade (valores distintos de reproducao.inseminador) e permite digitar
/// um novo nome. O primeiro uso salva o nome na reprodução, que passa a aparecer
/// na lista das próximas vezes — sem cadastro/tabela dedicada.
///
/// Usa o mesmo TextEditingController do formulário (o caminho de salvamento
/// continua lendo `.text`), então nada muda na gravação.
class InseminadorAutocompleteField extends StatefulWidget {
  const InseminadorAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.idPropriedade,
    this.validator,
    this.hintText = 'Adicionar nome',
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String idPropriedade;
  final String? Function(String?)? validator;
  final String hintText;

  @override
  State<InseminadorAutocompleteField> createState() =>
      _InseminadorAutocompleteFieldState();
}

class _InseminadorAutocompleteFieldState
    extends State<InseminadorAutocompleteField> {
  List<String> _opcoes = [];

  @override
  void initState() {
    super.initState();
    _carregarInseminadores();
  }

  Future<void> _carregarInseminadores() async {
    final id = widget.idPropriedade.trim();
    if (id.isEmpty) return;
    try {
      final rows = await ReproducaoTable().queryRows(
        queryFn: (q) =>
            q.eqOrNull('id_propriedade', id).eqOrNull('deletado', 'NAO'),
      );
      final nomes = rows
          .map((e) => (e.inseminador ?? '').trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (mounted) setState(() => _opcoes = nomes);
    } catch (_) {
      // Sem sugestões (erro de rede/permissão): ainda permite digitar livremente.
    }
  }

  InputDecoration _decoration(BuildContext context) {
    return InputDecoration(
      isDense: false,
      hintText: widget.hintText,
      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
            ),
            color: const Color(0xFFBEBEBE),
            fontSize: 16.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
            fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
          ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x00000000), width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: FlutterFlowTheme.of(context).error, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: FlutterFlowTheme.of(context).customColor2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraCampo =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 300.0;
        return RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: widget.focusNode,
          optionsBuilder: (TextEditingValue value) {
            final q = value.text.trim().toLowerCase();
            if (q.isEmpty) return _opcoes;
            return _opcoes.where((o) => o.toLowerCase().contains(q));
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              autofocus: false,
              obscureText: false,
              onFieldSubmitted: (_) => onFieldSubmitted(),
              decoration: _decoration(context),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
              cursorColor: FlutterFlowTheme.of(context).primaryText,
              validator: widget.validator,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final opts = options.toList();
            return Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    width: larguraCampo,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: opts.length,
                          itemBuilder: (context, i) {
                            final option = opts[i];
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                child: Text(
                                  option,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                        fontSize: 15.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
