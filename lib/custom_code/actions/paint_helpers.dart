// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Estratégias de cálculo do identificador A12 (paridade com paint-export).
enum PaintEstrategiaA12 { compacto, espacado, ultimosDigitosNome }

/// A12 = Programa(1) + SérieFazenda(4) + Animal(5) + Ano(2 dígitos).
String formatA12({
  required String programa,
  required String serieFazenda,
  required String animal,
  required int ano,
  PaintEstrategiaA12 estrategia = PaintEstrategiaA12.compacto,
}) {
  final p = programa.isEmpty ? 'P' : programa.substring(0, 1);
  final sRaw = serieFazenda;
  final s = sRaw.length >= 4
      ? sRaw.substring(0, 4)
      : sRaw + ' ' * (4 - sRaw.length);

  final y = (ano % 100).toString().padLeft(2, '0');

  if (estrategia == PaintEstrategiaA12.ultimosDigitosNome) {
    final digits = animal.replaceAll(RegExp(r'\D'), '');
    final part = digits.length >= 6 ? digits.substring(digits.length - 6) : digits;
    final raw = '$p$s$part$y';
    return raw.length > 12 ? raw.substring(0, 12) : raw.padRight(12, ' ');
  }

  final aRaw = animal;
  final a = aRaw.length > 5
      ? aRaw.substring(0, 5)
      : ' ' * (5 - aRaw.length) + aRaw;

  if (estrategia == PaintEstrategiaA12.espacado) {
    final serieTrim = s.trim();
    final animalTrim = a.trim();
    final raw = '$p$serieTrim $animalTrim $y';
    return raw.length > 12 ? raw.substring(0, 12) : raw.padRight(12, ' ');
  }

  return '$p$s$a$y';
}

PaintEstrategiaA12 parseEstrategiaA12(String? v) {
  switch (v) {
    case 'espacado':
      return PaintEstrategiaA12.espacado;
    case 'ultimos_digitos_nome':
      return PaintEstrategiaA12.ultimosDigitosNome;
    default:
      return PaintEstrategiaA12.compacto;
  }
}
