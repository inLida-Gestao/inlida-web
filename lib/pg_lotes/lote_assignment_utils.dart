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

List<RebanhoDTStruct> mesclarAnimaisSelecionados(
  Iterable<RebanhoDTStruct> selecionados,
  Iterable<RebanhoDTStruct> novos, {
  Iterable<String?> idsExcluidos = const [],
}) {
  final resultado = selecionados.toList();
  final idsSelecionados = resultado
      .map((animal) => animal.idRebanho.trim())
      .where((id) => id.isNotEmpty && id.toLowerCase() != 'null')
      .toSet();
  final idsBloqueados = normalizeLoteAnimalIds(idsExcluidos).toSet();

  for (final animal in novos) {
    final id = animal.idRebanho.trim();
    if (id.isEmpty ||
        id.toLowerCase() == 'null' ||
        idsBloqueados.contains(id) ||
        !idsSelecionados.add(id)) {
      continue;
    }
    resultado.add(animal);
  }

  return resultado;
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
