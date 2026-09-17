// Monta payload para paint_registro_excluido (paridade com generators.ts).

import 'paint_excel_helpers.dart';

Map<String, dynamic>? buildPaintDeleteRecord({
  required String tableName,
  required Map<String, dynamic> registro,
  required PaintConfigExcel config,
}) {
  final now = DateTime.now().toIso8601String();
  final dateStr = now.substring(0, 10);
  final timeStr =
      '${DateTime.now().hour.toString().padLeft(2, '0')}:'
      '${DateTime.now().minute.toString().padLeft(2, '0')}:'
      '${DateTime.now().second.toString().padLeft(2, '0')}';

  String? entidade;
  String? chave;
  Map<String, dynamic>? payload;

  switch (tableName) {
    case 'paint_avaliador':
      entidade = 'AVALIADOR';
      chave = registro['codigo']?.toString();
      payload = {
        'ava_parceiro': config.codigoTransmissao,
        'ava_id': registro['codigo'],
        'ava_descri': (registro['nome'] ?? '').toString(),
        'ava_situacao': registro['situacao'] ?? 'ATIVO',
        'ava_fazenda': config.codigoFazenda,
        'ava_data_inclusao': dateStr,
        'ava_data_alteracao': dateStr,
        'ava_hora_alteracao': timeStr,
        'ava_enviar': 'True ',
        'ava_recno': 1,
      };
      break;
    case 'paint_inseminador':
      entidade = 'INSEMINADOR';
      chave = registro['codigo']?.toString();
      payload = {
        'ins_parceiro': config.codigoTransmissao,
        'ins_id': registro['codigo'],
        'ins_descri': (registro['nome'] ?? '').toString(),
        'ins_fazenda': config.codigoFazenda.padRight(30).substring(0, 30),
        'ins_situacao': registro['situacao'] ?? 'ATIVO',
        'ins_data_inclusao': dateStr,
        'ins_data_alteracao': dateStr,
        'ins_hora_alteracao': timeStr,
        'ins_enviar': 'True ',
        'ins_recno': 1,
        'ins_tipo': 'I',
      };
      break;
    case 'paint_grupo_manejo':
      entidade = 'GRUPO_MANEJO';
      chave = registro['codigo']?.toString();
      payload = {
        'grm_parceiro': config.codigoTransmissao,
        'grm_id': registro['codigo'],
        'grm_descri': (registro['descricao'] ?? '').toString(),
        'grm_fazenda': config.codigoFazenda,
        'grm_data_inclusao': dateStr,
        'grm_data_alteracao': dateStr,
        'grm_hora_alteracao': timeStr,
        'grm_enviar': 'True ',
        'grm_recno': 1,
      };
      break;
    case 'paint_localidade':
      entidade = 'LOCALIDADE';
      chave = registro['codigo']?.toString();
      payload = {
        'lde_parceiro': config.codigoTransmissao,
        'lde_id': registro['codigo'],
        'lde_descri': (registro['descricao'] ?? '').toString(),
        'lde_fazenda': config.codigoFazenda,
        'lde_tipo': '',
        'lde_obs': (registro['obs'] ?? '').toString(),
        'lde_data_inclusao': dateStr,
        'lde_data_alteracao': dateStr,
        'lde_hora_alteracao': timeStr,
        'lde_enviar': 'True ',
        'lde_recno': 1,
      };
      break;
    case 'paint_regime_alimentar':
      entidade = 'REGIME_ALIMENTAR';
      chave = registro['codigo']?.toString();
      payload = {
        'rga_parceiro': config.codigoTransmissao,
        'rga_id': registro['codigo'],
        'rga_descri': (registro['descricao'] ?? '').toString(),
        'rga_fazenda': config.codigoFazenda,
        'rga_data_inclusao': dateStr,
        'rga_data_alteracao': dateStr,
        'rga_hora_alteracao': timeStr,
        'rga_enviar': 'True ',
        'rga_recno': 1,
      };
      break;
    case 'paint_safra':
      entidade = 'SAFRA';
      chave = registro['codigo']?.toString();
      payload = {
        'sfr_parceiro': config.codigoTransmissao,
        'sfr_id': registro['codigo'],
        'sfr_descri': (registro['descricao'] ?? '').toString(),
        'sfr_fazenda': config.codigoFazenda,
        'sfr_data_inicio': parseDateIso(registro['data_inicio']) ?? dateStr,
        'sfr_data_final': parseDateIso(registro['data_final']) ?? dateStr,
        'sfr_data_inclusao': dateStr,
        'sfr_data_alteracao': dateStr,
        'sfr_hora_alteracao': timeStr,
        'sfr_enviar': 'True ',
        'sfr_recno': 1,
      };
      break;
    case 'paint_composicao_racial':
      entidade = 'COMPOSICAO_RACIAL';
      chave = '${registro['animal_a12']}|${registro['raca_codigo']}';
      payload = {
        'cpr_parceiro': config.codigoTransmissao,
        'cpr_animal_id': registro['animal_a12'],
        'cpr_raca_id': registro['raca_codigo'],
        'cpr_indice': registro['indice'] ?? 1,
        'cpr_fazenda': config.codigoFazenda,
        'cpr_data_inclusao': dateStr,
        'cpr_data_alteracao': dateStr,
        'cpr_hora_alteracao': timeStr,
        'cpr_enviar': 'True ',
        'cpr_recno': 1,
      };
      break;
    case 'paint_avaliacao_desmama':
      entidade = 'DESMAMA';
      chave = '${registro['animal_a12']}|${registro['data']}';
      payload = {
        'dsm_parceiro': config.codigoTransmissao,
        'dsm_animal_id': registro['animal_a12'],
        'dsm_fazenda': config.codigoFazenda,
        'dsm_data': parseDateIso(registro['data']) ?? dateStr,
        'dsm_peso': registro['peso'],
        'dsm_nota_c': registro['nota_c'],
        'dsm_nota_p': registro['nota_p'],
        'dsm_nota_m': registro['nota_m'],
        'dsm_nota_u': registro['nota_u'],
        'dsm_data_inclusao': dateStr,
        'dsm_data_alteracao': dateStr,
        'dsm_hora_alteracao': timeStr,
        'dsm_enviar': 'True ',
        'dsm_recno': 1,
      };
      break;
    case 'paint_avaliacao_sobreano':
      entidade = 'ANO_SOBREANO';
      chave = '${registro['animal_a12']}|${registro['data']}';
      payload = {
        'sbr_parceiro': config.codigoTransmissao,
        'sbr_animal_id': registro['animal_a12'],
        'sbr_fazenda': config.codigoFazenda,
        'sbr_data': parseDateIso(registro['data']) ?? dateStr,
        'sbr_peso': registro['peso'],
        'sbr_nota_c': registro['nota_c'],
        'sbr_nota_p': registro['nota_p'],
        'sbr_nota_m': registro['nota_m'],
        'sbr_nota_u': registro['nota_u'],
        'sbr_nota_t': registro['nota_t'],
        'sbr_data_inclusao': dateStr,
        'sbr_data_alteracao': dateStr,
        'sbr_hora_alteracao': timeStr,
        'sbr_enviar': 'True ',
        'sbr_recno': 1,
      };
      break;
    case 'paint_avaliacao_rah':
      entidade = 'RAH';
      chave = '${registro['animal_a12']}|${registro['data']}';
      payload = {
        'rah_parceiro': config.codigoTransmissao,
        'rah_animal_id': registro['animal_a12'],
        'rah_fazenda': config.codigoFazenda.padRight(30).substring(0, 30),
        'rah_data': parseDateIso(registro['data']) ?? dateStr,
        'rah_peso': registro['peso'],
        'rah_racial': registro['racial'],
        'rah_aprumos': registro['aprumos'],
        'rah_harmonia': registro['harmonia'] ?? registro['frame'],
        'rah_situacao_desclassifica': registro['situacao_desclass'] ?? '',
        'rah_data_inclusao': dateStr,
        'rah_data_alteracao': dateStr,
        'rah_hora_alteracao': timeStr,
        'rah_enviar': 'True ',
        'rah_recno': 1,
      };
      break;
    case 'paint_diagnostico':
      entidade = 'DIAGNOSTICO';
      chave = '${registro['animal_a12']}|${registro['data']}|${registro['safra_codigo']}';
      payload = {
        'dgn_parceiro': config.codigoTransmissao,
        'dgn_safra_id': registro['safra_codigo'],
        'dgn_animal_id': registro['animal_a12'],
        'dgn_data': parseDateIso(registro['data']) ?? dateStr,
        'dgn_fazenda': config.codigoFazenda,
        'dgn_data_inclusao': dateStr,
        'dgn_data_alteracao': dateStr,
        'dgn_hora_alteracao': timeStr,
        'dgn_enviar': 'True ',
        'dgn_recno': 1,
      };
      break;
    case 'paint_estoque':
      entidade = 'ESTOQUE';
      chave = '${registro['touro_a12']}|${registro['codigo_lote'] ?? registro['id']}';
      payload = {
        'est_parceiro': config.codigoTransmissao,
        'est_touro_a12': registro['touro_a12'],
        'est_codigo_fazenda': config.codigoFazenda.padRight(30).substring(0, 30),
        'est_descricao': (registro['descricao'] ?? '').toString(),
        'est_data_aquisicao': parseDateIso(registro['data_aquisicao']) ?? dateStr,
        'est_tipo_operacao': registro['tipo_operacao'] ?? 'COMPRA',
        'est_quantidade': registro['quantidade_doses'],
        'est_data_inclusao': dateStr,
        'est_data_alteracao': dateStr,
        'est_hora_alteracao': timeStr,
        'est_enviar': 'True ',
        'est_recno': 1,
      };
      break;
    default:
      return null;
  }

  if (entidade == null || chave == null || chave.isEmpty || payload == null) {
    return null;
  }
  return {'entidade': entidade, 'chave': chave, 'payload': payload};
}
