const categoriasRebanhoFemea = <String>[
  'Bezerra',
  'Novilha',
  'Vaca Multipara',
  'Vaca Primipara',
];

const categoriasRebanhoMacho = <String>[
  'Boi Gordo',
  'Boi Magro',
  'Garrote',
  'Rufião',
  'Touro',
  'Bezerro',
];

String? categoriaRebanhoSelecionada({
  required String? sexo,
  required String? categoriaFemea,
  required String? categoriaMacho,
}) {
  switch (sexo?.trim()) {
    case 'Fêmea':
      return categoriaFemea?.trim();
    case 'Macho':
      return categoriaMacho?.trim();
    default:
      return null;
  }
}

bool categoriaRebanhoCondizComSexo({
  required String? sexo,
  required String? categoria,
}) {
  final categoriaNormalizada = categoria?.trim();
  if (categoriaNormalizada == null || categoriaNormalizada.isEmpty) {
    return false;
  }

  switch (sexo?.trim()) {
    case 'Fêmea':
      return categoriasRebanhoFemea.contains(categoriaNormalizada);
    case 'Macho':
      return categoriasRebanhoMacho.contains(categoriaNormalizada);
    default:
      return false;
  }
}

String? categoriaRebanhoInicialParaSexo({
  required String? sexoSelecionado,
  required String? sexoOriginal,
  required String? categoriaOriginal,
}) {
  final categoriaNormalizada = categoriaOriginal?.trim();
  if (sexoSelecionado?.trim() != sexoOriginal?.trim() ||
      !categoriaRebanhoCondizComSexo(
        sexo: sexoSelecionado,
        categoria: categoriaNormalizada,
      )) {
    return null;
  }

  return categoriaNormalizada;
}
