import '/backend/supabase/supabase.dart';

String? nonEmptyString(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool loteMatrizCompativelComData(
  RebanhoRow? matriz,
  DateTime? dataReferencia,
) {
  final dataEntradaLote = matriz?.dataEntradaLote;
  if (dataEntradaLote == null || dataReferencia == null) {
    return true;
  }
  return !_dateOnly(dataEntradaLote).isAfter(_dateOnly(dataReferencia));
}

Future<RebanhoRow?> buscarMatrizComLote({
  required String idPropriedade,
  required String idRebanho,
}) async {
  final propriedade = nonEmptyString(idPropriedade);
  final rebanho = nonEmptyString(idRebanho);
  if (propriedade == null || rebanho == null) {
    return null;
  }

  final rows = await RebanhoTable().queryRows(
    queryFn: (q) => q
        .eqOrNull(
          'idPropriedade',
          propriedade,
        )
        .eqOrNull(
          'idRebanho',
          rebanho,
        )
        .limit(1),
  );
  return rows.firstOrNull;
}

List<RebanhoRow> filtrarMatrizesDoLoteParaReproducao({
  required Iterable<RebanhoRow> rebanho,
  required String idPropriedade,
  required String idLote,
}) {
  final propriedade = nonEmptyString(idPropriedade);
  final lote = nonEmptyString(idLote);
  if (propriedade == null || lote == null) {
    return [];
  }

  final idsAdicionados = <String>{};
  return rebanho.where((animal) {
    final idAnimal = nonEmptyString(animal.idRebanho);
    return idAnimal != null &&
        idsAdicionados.add(idAnimal) &&
        nonEmptyString(animal.idPropriedade) == propriedade &&
        nonEmptyString(animal.loteID) == lote &&
        animal.sexo?.trim().toLowerCase() == 'fêmea' &&
        animal.deletado?.trim().toUpperCase() != 'SIM';
  }).toList();
}
