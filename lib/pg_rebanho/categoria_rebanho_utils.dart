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

String _normalizarCategoriaTexto(String? value) {
  return (value ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('Ãª', 'e')
      .replaceAll('Ã£', 'a')
      .replaceAll('ãª', 'e')
      .replaceAll('ã£', 'a')
      .replaceAll('ã¡', 'a')
      .replaceAll('ã©', 'e')
      .replaceAll('ã­', 'i')
      .replaceAll('ã³', 'o')
      .replaceAll('ã´', 'o')
      .replaceAll('ãº', 'u')
      .replaceAll('ã§', 'c')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ê', 'e')
      .replaceAll('é', 'e')
      .replaceAll('è', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');
}

bool _sexoFemea(String? sexo) =>
    _normalizarCategoriaTexto(sexo).replaceAll(' ', '') == 'femea';

bool _sexoMacho(String? sexo) =>
    _normalizarCategoriaTexto(sexo).replaceAll(' ', '') == 'macho';

String? categoriaRebanhoSelecionada({
  required String? sexo,
  required String? categoriaFemea,
  required String? categoriaMacho,
}) {
  if (_sexoFemea(sexo)) {
    return categoriaFemea?.trim();
  }
  if (_sexoMacho(sexo)) {
    return categoriaMacho?.trim();
  }
  return null;
}

bool categoriaRebanhoCondizComSexo({
  required String? sexo,
  required String? categoria,
}) {
  final categoriaNormalizada = categoria?.trim();
  if (categoriaNormalizada == null || categoriaNormalizada.isEmpty) {
    return false;
  }
  final categoriaNormalizadaComparacao =
      _normalizarCategoriaTexto(categoriaNormalizada);

  if (_sexoFemea(sexo)) {
    return categoriasRebanhoFemea
        .map(_normalizarCategoriaTexto)
        .contains(categoriaNormalizadaComparacao);
  }
  if (_sexoMacho(sexo)) {
    return categoriasRebanhoMacho
        .map(_normalizarCategoriaTexto)
        .contains(categoriaNormalizadaComparacao);
  }
  return false;
}

String? categoriaRebanhoInicialParaSexo({
  required String? sexoSelecionado,
  required String? sexoOriginal,
  required String? categoriaOriginal,
}) {
  final categoriaNormalizada = categoriaOriginal?.trim();
  if (_normalizarCategoriaTexto(sexoSelecionado) !=
          _normalizarCategoriaTexto(sexoOriginal) ||
      !categoriaRebanhoCondizComSexo(
        sexo: sexoSelecionado,
        categoria: categoriaNormalizada,
      )) {
    return null;
  }

  return categoriaNormalizada;
}
