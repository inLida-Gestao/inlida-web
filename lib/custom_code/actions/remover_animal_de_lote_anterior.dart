// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Remove [idRebanho] da lista `id_animais` do lote indicado por nome ou id,
/// e limpa `loteID` / `loteNome` no rebanho (mesmo padrão de animais retirados do lote).
Future<void> removerAnimalDeLoteAnterior({
  required String idPropriedade,
  required String idRebanho,
  String? loteNomeHint,
  String? loteIdHint,
}) async {
  if (idRebanho.trim().isEmpty) return;

  LotesRow? target;

  final nome = (loteNomeHint ?? '').trim();
  if (nome.isNotEmpty && nome.toLowerCase() != 'null') {
    final rows = await LotesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('id_propriedade', idPropriedade)
          .eqOrNull('nome', nome),
    );
    if (rows.isNotEmpty) {
      target = rows.first;
    }
  }

  final lid = (loteIdHint ?? '').trim();
  if (target == null && lid.isNotEmpty && lid.toLowerCase() != 'null') {
    var rows = await LotesTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('id_propriedade', idPropriedade)
          .eqOrNull('id_lote', lid),
    );
    if (rows.isEmpty) {
      rows = await LotesTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('id_propriedade', idPropriedade)
            .eqOrNull('nome', lid),
      );
    }
    if (rows.isNotEmpty) {
      target = rows.first;
    }
  }

  if (target != null) {
    final ids = functions.converterJSONparaLista(target.idAnimais) ?? [];
    if (ids.contains(idRebanho)) {
      final novoIds = ids.where((id) => id != idRebanho).toList();
      final idLoteRow = target.idLote;
      if (idLoteRow != null && idLoteRow.isNotEmpty) {
        await LotesTable().update(
          data: {
            'id_animais': functions.converterListaParaJSON(novoIds),
            'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
          },
          matchingRows: (rows) => rows.eqOrNull('id_lote', idLoteRow),
        );
      }
    }
  }

  await RebanhoTable().update(
    data: {
      'loteID': 'null',
      'loteNome': 'null',
      'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
    },
    matchingRows: (rows) => rows.eqOrNull('idRebanho', idRebanho),
  );
}
