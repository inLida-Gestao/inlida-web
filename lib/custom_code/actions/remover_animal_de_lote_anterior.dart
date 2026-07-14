// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Limpa `loteID` / `loteNome` no rebanho ao mover/remover o animal de lote.
Future<void> removerAnimalDeLoteAnterior({
  required String idPropriedade,
  required String idRebanho,
  String? loteNomeHint,
  String? loteIdHint,
}) async {
  if (idRebanho.trim().isEmpty) return;

  await RebanhoTable().update(
    data: {
      'loteID': 'null',
      'loteNome': 'null',
      'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
    },
    matchingRows: (rows) => rows
        .eqOrNull('idRebanho', idRebanho)
        .eqOrNull('idPropriedade', idPropriedade),
  );
}
