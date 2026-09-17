// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import 'paint_helpers.dart';
import 'paint_mappers.dart';
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
      .select('serie_fazenda,serie_raca_po,programa,estrategia_a12')
      .eq('id_propriedade', idPropriedade)
      .limit(1);
  if (configRows.isEmpty) return false;
  final cfg = configRows.first;
  final serieFazenda = cfg['serie_fazenda']?.toString() ?? '';

  // A12 OFICIAL do PAINT tem precedência: em fazendas com histórico manual, a
  // chave do animal no PAINT é a legada (ex.: programa 'F'/'p'). Gravar 'P' aqui
  // criaria uma baixa que o PAINT não associa ao animal.
  String? a12Oficial;
  Map<String, dynamic>? animal;
  try {
    final rebRows = await SupaFlow.client
        .from('rebanho')
        .select(
            'idRebanho,numeroAnimal,codRegistro,raca,tipo_registro,dataNascimento,nome,chip')
        .eq('id', rebanhoId)
        .limit(1);
    if (rebRows.isNotEmpty) {
      animal = Map<String, dynamic>.from(rebRows.first);
      // Os parâmetros vencem quando a linha vier incompleta.
      if ((animal['numeroAnimal'] ?? '').toString().trim().isEmpty) {
        animal['numeroAnimal'] = numeroAnimal;
      }
      if (animal['dataNascimento'] == null) {
        animal['dataNascimento'] = dataNascimento;
      }
    }
    final idReb = (animal?['idRebanho'] ?? '').toString().trim();
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

  // Fallback: MESMA regra do export (PO-aware, só os dígitos do número). Passar
  // numeroAnimal cru colocava a sigla do registro dentro do A12 ('P460 ZEB8121')
  // e a série da fazenda em animal PO.
  final a12 = a12Oficial ??
      a12FromRebanhoPaint(
        animal ??
            {
              'numeroAnimal': numeroAnimal,
              'dataNascimento': dataNascimento,
            },
        serieFazenda: serieFazenda,
        serieRacaPo: cfg['serie_raca_po']?.toString(),
        programa: (cfg['programa']?.toString().isNotEmpty ?? false)
            ? cfg['programa'].toString()
            : 'P',
        estrategia: parseEstrategiaA12(cfg['estrategia_a12']?.toString()),
      );
  if (a12.trim().isEmpty) return false;

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
