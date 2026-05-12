// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// A12 = Programa(1) + SérieFazenda(4 esquerda) + Animal(5 direita,
// trunca 5 primeiros se >5) + Ano(2 dígitos do ano de nascimento).
// Replica a lógica de supabase/functions/paint-export/lib/fixed-width.ts.
String formatA12({
  required String programa,
  required String serieFazenda,
  required String animal,
  required int ano,
}) {
  final p = programa.isEmpty ? 'P' : programa.substring(0, 1);
  final sRaw = serieFazenda;
  final s = sRaw.length >= 4
      ? sRaw.substring(0, 4)
      : sRaw + ' ' * (4 - sRaw.length);
  final aRaw = animal;
  final a = aRaw.length > 5
      ? aRaw.substring(0, 5)
      : ' ' * (5 - aRaw.length) + aRaw;
  final y = (ano % 100).toString().padLeft(2, '0');
  return '$p$s$a$y';
}
