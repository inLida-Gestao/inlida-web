// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Begin custom action code

/// Reseta TODOS os dados PAINT da propriedade selecionada: avaliações,
/// diagnósticos, cadastros derivados e histórico de exportações.
///
/// NÃO apaga:
///  - paint_fazenda_config (códigos fornecidos pela equipe PAINT);
///  - tabelas globais compartilhadas (paint_biblioteca_touros e tabelas de
///    código: raça, categoria, tipo de cobertura/registro, programa).
///
/// Retorna { total, removidos: {tabela: n}, erro, mensagem }.
Future<Map<String, dynamic>> resetarDadosPaint(String? idPropriedade) async {
  final result = <String, dynamic>{
    'total': 0,
    'removidos': <String, int>{},
    'erro': 0,
    'mensagem': '',
  };
  final id = (idPropriedade ?? '').trim();
  if (id.isEmpty) {
    result['erro'] = 1;
    result['mensagem'] = 'Selecione uma propriedade.';
    return result;
  }

  // Ordem: avaliações/vínculos antes dos cadastros que eles referenciam.
  const tabelas = <String>[
    'paint_avaliacao_desmama',
    'paint_avaliacao_sobreano',
    'paint_avaliacao_rah',
    'paint_diagnostico',
    'paint_safra_x_animal',
    'paint_composicao_racial',
    'paint_baixa',
    'paint_estoque',
    'paint_touro_multiplo',
    'paint_registro_excluido',
    'paint_grupo_manejo',
    'paint_inseminador',
    'paint_localidade',
    'paint_safra',
    'paint_regime_alimentar',
    'paint_avaliador',
    'paint_export_job',
  ];

  final removidos = <String, int>{};
  var total = 0;
  try {
    for (final t in tabelas) {
      final resp = await SupaFlow.client
          .from(t)
          .select('id')
          .eq('id_propriedade', id)
          .count(CountOption.exact);
      final n = resp.count;
      if (n > 0) {
        await SupaFlow.client.from(t).delete().eq('id_propriedade', id);
      }
      removidos[t] = n;
      total += n;
    }
    result['total'] = total;
    result['removidos'] = removidos;
    return result;
  } catch (e) {
    result['erro'] = 1;
    result['mensagem'] = 'Falha ao resetar: $e';
    result['total'] = total;
    result['removidos'] = removidos;
    return result;
  }
}
