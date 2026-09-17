// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Estratégias de cálculo do identificador A12 (paridade com paint-export).
enum PaintEstrategiaA12 { compacto, espacado, ultimosDigitosNome }

/// A12 = Programa(1) + SérieFazenda(4) + Animal(5) + Ano(2 dígitos).
///
/// Campo POSICIONAL de 12 chars, sem separadores: série e animal são
/// justificados à ESQUERDA e a sobra vira espaço. Os "espaços" de
/// 'P460 1163 21' são essa sobra, não separadores — confirmado nos A12 que o
/// PAINT já tem ('P460 77   20', 'P460 222  20', 'F460 1163 21').
/// Por isso `espacado` é só um apelido legado de `compacto`: concatenar com
/// separadores desalinha o ano quando o número não tem exatamente 4 dígitos.
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

  var aRaw = animal.trim();
  if (estrategia == PaintEstrategiaA12.ultimosDigitosNome) {
    // O campo Animal tem 5 chars: pegar 6 dígitos empurrava o ano fora do A12.
    final digits = aRaw.replaceAll(RegExp(r'\D'), '');
    aRaw = digits.length > 5 ? digits.substring(digits.length - 5) : digits;
  }

  // Campo Animal (5): justificado à ESQUERDA, sobra de espaço à direita.
  final a = aRaw.length > 5
      ? aRaw.substring(0, 5)
      : aRaw + ' ' * (5 - aRaw.length);

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
