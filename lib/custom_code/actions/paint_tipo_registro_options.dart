// Opções de tipo de registro/livro PAINT (tabela paint_tipo_registro, manual §11.4).

const kPaintTipoRegistroCodigos = <String>[
  'PO',
  'POI',
  'CEIP',
  'CL',
  'LA',
  'LA1',
];

const kPaintTipoRegistroLabels = <String>[
  'PO — Puro de Origem',
  'POI — Puro de Origem Importada',
  'CEIP — Certificado Especial',
  'CL — Cara Limpa',
  'LA — Livro Aberto',
  'LA1 — Livro Aberto 1',
];

String? paintTipoRegistroParaSalvar(String? value) {
  final v = (value ?? '').trim();
  return v.isEmpty ? null : v;
}

/// Raça indica Puro de Origem (mesma regra de paint_mappers.mapTipoRegistro).
bool isRacaPoPaint(String? raca) {
  final r = (raca ?? '').trim().toUpperCase();
  if (r.isEmpty) return false;
  return RegExp(r'\bPO\b').hasMatch(r) || r.contains('PURO DE ORIGEM');
}

/// Sugere `PO` quando a raça indica PO e o tipo ainda não foi informado.
/// Não sobrescreve seleção manual do usuário.
String? sugerirTipoRegistroPorRaca(String? raca, String? tipoAtual) {
  final atual = (tipoAtual ?? '').trim();
  if (atual.isNotEmpty) return tipoAtual;
  return isRacaPoPaint(raca) ? 'PO' : tipoAtual;
}
