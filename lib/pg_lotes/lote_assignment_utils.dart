import '/backend/schema/structs/rebanho_d_t_struct.dart';

List<RebanhoDTStruct> filtrarAnimaisSelecionaveisParaLote(
  Iterable<RebanhoDTStruct> animais, {
  String statusFiltro = '',
}) {
  final filtroNormalizado = statusFiltro.trim().toLowerCase();

  return animais.where((animal) {
    final status = animal.status.trim().toLowerCase();
    if (status == 'sêmen') {
      return false;
    }
    return status != 'fora da propriedade' ||
        filtroNormalizado == 'fora da propriedade';
  }).toList();
}

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
