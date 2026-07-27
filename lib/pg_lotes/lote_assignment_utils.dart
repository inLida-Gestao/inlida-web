import '/backend/schema/structs/rebanho_d_t_struct.dart';

List<String> normalizeLoteAnimalIds(Iterable<String?> ids) {
  final normalized = <String>{};
  for (final value in ids) {
    final id = value?.trim() ?? '';
    if (id.isNotEmpty && id.toLowerCase() != 'null') {
      normalized.add(id);
    }
  }
  return normalized.toList()..sort();
}

List<String> loteAnimalIds(Iterable<RebanhoDTStruct> animais) {
  return normalizeLoteAnimalIds(
    animais.map((animal) => animal.idRebanho),
  );
}
