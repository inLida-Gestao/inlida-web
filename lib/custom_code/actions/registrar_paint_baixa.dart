// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import 'paint_helpers.dart';
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Registra uma baixa em paint_baixa quando um animal é marcado como
/// vendido/morto/descartado/excluído no fluxo de rebanho do app.
/// Sem efeito se a propriedade não tem paint_fazenda_config (módulo PAINT
/// não configurado para essa fazenda).
///
/// motivo: 'MORTE' | 'VENDA' | 'DESCARTE' | 'EXCLUSAO'
Future<bool> registrarPaintBaixa(
  String? idPropriedade,
  int? rebanhoId,
  String? numeroAnimal,
  DateTime? dataNascimento,
  String motivo, {
  DateTime? dataMorte,
  double? preco,
  String? obs,
}) async {
  if (idPropriedade == null || idPropriedade.trim().isEmpty) return false;
  if (rebanhoId == null) return false;
  if (numeroAnimal == null || numeroAnimal.trim().isEmpty) return false;
  if (dataNascimento == null) return false;
  if (!_motivosValidos.contains(motivo)) return false;

  // Lê config PAINT da propriedade. Se não existe, ignora silenciosamente.
  final configRows = await SupaFlow.client
      .from('paint_fazenda_config')
      .select('serie_fazenda')
      .eq('id_propriedade', idPropriedade)
      .limit(1);
  if (configRows.isEmpty) return false;
  final serieFazenda = configRows.first['serie_fazenda']?.toString() ?? '';

  // A12 OFICIAL do PAINT tem precedência: em fazendas com histórico manual, a
  // chave do animal no PAINT é a legada (ex.: programa 'F'/'p'). Gravar 'P' aqui
  // criaria uma baixa que o PAINT não associa ao animal.
  String? a12Oficial;
  try {
    final rebRows = await SupaFlow.client
        .from('rebanho')
        .select('idRebanho')
        .eq('id', rebanhoId)
        .limit(1);
    final idReb = rebRows.isEmpty
        ? ''
        : (rebRows.first['idRebanho'] ?? '').toString().trim();
    if (idReb.isNotEmpty) {
      final ofRows = await SupaFlow.client
          .from('paint_animal_a12')
          .select('a12')
          .eq('id_propriedade', idPropriedade)
          .eq('id_rebanho', idReb)
          .limit(1);
      if (ofRows.isNotEmpty) {
        final v = (ofRows.first['a12'] ?? '').toString().trimRight();
        if (v.isNotEmpty) a12Oficial = v;
      }
    }
  } catch (_) {
    // Sem A12 oficial disponível: segue com o cálculo padrão.
  }

  final a12 = a12Oficial ??
      formatA12(
        programa: 'P',
        serieFazenda: serieFazenda,
        animal: numeroAnimal.trim(),
        ano: dataNascimento.year,
      );

  try {
    final payload = {
      'id_propriedade': idPropriedade,
      'animal_a12': a12,
      'data_morte': dataMorte == null
          ? null
          : dataMorte.toIso8601String().substring(0, 10),
      'motivo': motivo,
      'preco': preco,
      'obs': obs,
    };

    // paint_baixa não tem unique constraint em (id_propriedade, animal_a12);
    // só índice. Faço select para decidir update vs insert.
    final existentes = await SupaFlow.client
        .from('paint_baixa')
        .select('id')
        .eq('id_propriedade', idPropriedade)
        .eq('animal_a12', a12)
        .limit(1);

    if (existentes.isNotEmpty) {
      payload['updated_at'] = DateTime.now().toIso8601String();
      await SupaFlow.client
          .from('paint_baixa')
          .update(payload)
          .eq('id', existentes.first['id']);
    } else {
      await SupaFlow.client.from('paint_baixa').insert(payload);
    }
    return true;
  } catch (_) {
    return false;
  }
}

const Set<String> _motivosValidos = {
  'MORTE',
  'VENDA',
  'DESCARTE',
  'EXCLUSAO',
};
