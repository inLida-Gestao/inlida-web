import '/backend/schema/structs/rebanho_d_t_struct.dart';

List<String> loteAnimalIds(Iterable<RebanhoDTStruct> animais) {
  final ids = <String>{};
  for (final animal in animais) {
    final id = animal.idRebanho.trim();
    if (id.isNotEmpty && id.toLowerCase() != 'null') {
      ids.add(id);
    }
  }
  return ids.toList();
}
