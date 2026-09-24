// Popup exibido ao lançar um nascimento quando nenhuma inseminação foi
// encontrada na janela automática de gestação (275 a 305 dias antes do
// nascimento), mas existem reproduções (Inseminação ou Monta Natural) na
// janela estendida (306 a 350 dias). O usuário escolhe manualmente qual
// reprodução originou o nascimento — ou fecha sem vincular nada.
//
// Devolve o [CandidatoReproducao] escolhido via `Navigator.pop`, ou `null`
// tanto no "Não vincular" quanto ao fechar.
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../reproducao_parto_utils.dart';

class PopupSelecionarReproducaoWidget extends StatelessWidget {
  const PopupSelecionarReproducaoWidget({
    super.key,
    required this.candidatos,
    required this.dataNascimento,
  });

  final List<CandidatoReproducao> candidatos;
  final DateTime dataNascimento;

  /// O texto veio do banco e pode ser o literal `'null'` do legado.
  bool _preenchido(String? valor) =>
      valor != null && valor.trim().isNotEmpty && valor.trim() != 'null';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 534.0,
      constraints: const BoxConstraints(maxHeight: 560.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Selecionar reprodução do nascimento',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                          fontSize: 24.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: FlutterFlowTheme.of(context).accent3,
                    size: 24.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              'Nenhuma inseminação foi encontrada no período padrão de gestação '
              '(275 a 305 dias). Selecione abaixo a reprodução que originou este '
              'nascimento, se houver.',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.poppins(
                      fontWeight:
                          FlutterFlowTheme.of(context).bodySmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodySmall.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 16.0),
            Flexible(
              child: candidatos.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Nenhuma reprodução foi encontrada nesse período.',
                        style: FlutterFlowTheme.of(context).bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: candidatos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                      itemBuilder: (context, index) =>
                          _itemCandidato(context, candidatos[index]),
                    ),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Não vincular',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).accent3,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCandidato(BuildContext context, CandidatoReproducao candidato) {
    final diasGestacao =
        somenteData(dataNascimento).difference(candidato.dataReferencia).inDays;
    final numReprodutor = candidato.numReprodutor;
    final nomeReprodutor = candidato.nomeReprodutor;

    final descricaoReprodutor = _preenchido(numReprodutor)
        ? 'Reprodutor: $numReprodutor'
            '${_preenchido(nomeReprodutor) ? ' • $nomeReprodutor' : ''}'
        : 'Sem reprodutor vinculado';

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => Navigator.pop(context, candidato),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  candidato.tipoReproducao ?? 'Reprodução',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
                Text(
                  '$diasGestacao dias entre reprodução e parto',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Text(
              'Data: ${dateTimeFormat(
                "d/M/y",
                candidato.dataReferencia,
                locale: FFLocalizations.of(context).languageCode,
              )}',
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
            const SizedBox(height: 4.0),
            Text(
              descricaoReprodutor,
              style: FlutterFlowTheme.of(context).bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
