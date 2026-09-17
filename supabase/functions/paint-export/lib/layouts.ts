// Layouts dos 22 arquivos PAINT, transcritos do Manual de Implementação,
// Anexo I (campos: TABELA, SEQ, CAMPO, TIPO, TAM, DECI, INI, FIM, OBSERVAÇÕES).
//
// Importante: estrutura imutável (manual §6 + Anexo I). Validar byte-a-byte
// contra o sample 000460 antes de homologação (Fase C do plano).

import type { Field } from "./fixed-width.ts";

// Helper para reduzir verbosidade.
const f = (name: string, type: "C" | "N" | "D", tam: number, ini: number, fim: number): Field => ({
  name, type, tam, ini, fim,
});

export const LAYOUTS: Record<string, Field[]> = {
  // ---------------------------------------------------------------------------
  // ANIMAL — 38 campos, fim 368
  // ---------------------------------------------------------------------------
  ANIMAL: [
    f("ani_parceiro", "C", 6, 1, 6),
    f("ani_programa", "C", 1, 7, 7),
    f("ani_serie_fazenda", "C", 4, 8, 11),
    f("ani_animal", "C", 5, 12, 16),
    f("ani_data_nasc", "D", 10, 17, 26),
    f("ani_A12", "C", 12, 27, 38),
    f("ani_A17", "C", 17, 39, 55),
    f("ani_sexo", "C", 1, 56, 56),
    f("ani_tipo", "C", 4, 57, 60),
    f("ani_nome", "C", 30, 61, 90),
    f("ani_fazenda", "C", 30, 91, 120),
    f("ani_brinco", "C", 15, 121, 135),
    f("ani_raca", "C", 2, 136, 137),
    f("ani_ceip", "C", 15, 138, 152),
    f("ani_rgd", "C", 15, 153, 167),
    f("ani_pai", "C", 12, 168, 179),
    f("ani_mae", "C", 12, 180, 191),
    f("ani_categoria", "C", 2, 192, 193),
    f("ani_regime_alimentar", "C", 4, 194, 197),
    f("ani_grupo_manejo", "C", 4, 198, 201),
    f("ani_local", "C", 4, 202, 205),
    f("ani_data_inclusao", "D", 10, 206, 215),
    f("ani_data_alteracao", "D", 10, 216, 225),
    f("ani_hora_alteracao", "C", 8, 226, 233),
    f("ani_enviar", "C", 5, 234, 238),
    f("ani_baixa", "C", 3, 239, 241),
    f("ani_atuprog", "C", 5, 242, 246),
    f("ani_recno", "N", 9, 247, 255),
    f("ani_extra2", "C", 15, 256, 270),
    f("ani_id_eletronica", "C", 20, 271, 290),
    f("ani_categoria_ant", "C", 2, 291, 292),
    f("ani_racial", "N", 8, 293, 300),
    f("ani_frame", "N", 8, 301, 308),
    f("ani_situacao_desclassifica", "C", 2, 309, 310),
    f("ani_situacao_desclassifica2", "C", 2, 311, 312),
    f("ani_aprumo", "N", 8, 313, 320),
    f("ani_observacao", "C", 40, 321, 360),
    f("ani_pigmentacao", "N", 8, 361, 368),
  ],

  // ---------------------------------------------------------------------------
  // ANO_SOBREANO — 24 campos, fim 224
  // ---------------------------------------------------------------------------
  ANO_SOBREANO: [
    f("sbr_parceiro", "C", 6, 1, 6),
    f("sbr_animal_id", "C", 12, 7, 18),
    f("sbr_fazenda", "C", 30, 19, 48),
    f("sbr_data", "D", 10, 49, 58),
    f("sbr_peso", "N", 8, 59, 66),
    f("sbr_nota_c", "N", 8, 67, 74),
    f("sbr_nota_p", "N", 8, 75, 82),
    f("sbr_nota_m", "N", 8, 83, 90),
    f("sbr_nota_u", "N", 8, 91, 98),
    f("sbr_nota_t", "N", 8, 99, 106),
    f("sbr_situacao_desclassifica1", "C", 2, 107, 108),
    f("sbr_situacao_desclassifica2", "C", 2, 109, 110),
    f("sbr_nota_ce", "N", 8, 111, 118),
    f("sbr_nota_a", "N", 8, 119, 126),
    f("sbr_regime_alimentar_animal", "C", 4, 127, 130),
    f("sbr_grupo_manejo", "C", 4, 131, 134),
    f("sbr_local", "C", 4, 135, 138),
    f("sbr_avaliador", "C", 4, 139, 142),
    f("sbr_obs", "C", 40, 143, 182),
    f("sbr_data_inclusao", "D", 10, 183, 192),
    f("sbr_data_alteracao", "D", 10, 193, 202),
    f("sbr_hora_alteracao", "C", 8, 203, 210),
    f("sbr_enviar", "C", 5, 211, 215),
    f("sbr_recno", "N", 9, 216, 224),
  ],

  // ---------------------------------------------------------------------------
  // AVALIADOR — 10 campos, fim 114
  // ---------------------------------------------------------------------------
  AVALIADOR: [
    f("ava_parceiro", "C", 6, 1, 6),
    f("ava_id", "C", 4, 7, 10),
    f("ava_descri", "C", 25, 11, 35),
    f("ava_situacao", "C", 7, 36, 42),
    f("ava_fazenda", "C", 30, 43, 72),
    f("ava_data_inclusao", "D", 10, 73, 82),
    f("ava_data_alteracao", "D", 10, 83, 92),
    f("ava_hora_alteracao", "C", 8, 93, 100),
    f("ava_enviar", "C", 5, 101, 105),
    f("ava_recno", "N", 9, 106, 114),
  ],

  // ---------------------------------------------------------------------------
  // BAIXA — homologado sample 000460, fim 215 (170 + reserva 45)
  // ---------------------------------------------------------------------------
  BAIXA: [
    f("bai_parceiro", "C", 6, 1, 6),
    f("bai_animal_A12", "C", 12, 7, 18),
    f("bai_fazenda", "C", 30, 19, 48),
    f("bai_animal", "C", 5, 49, 53),
    f("bai_data_morte", "D", 10, 54, 63),
    f("bai_motivo", "C", 15, 64, 78),
    f("bai_preco", "N", 10, 79, 88),
    f("bai_data_inclusao", "D", 10, 89, 98),
    f("bai_obs", "C", 40, 99, 138),
    f("bai_data_alteracao", "D", 10, 139, 148),
    f("bai_hora_alteracao", "C", 8, 149, 156),
    f("bai_enviar", "C", 5, 157, 161),
    f("bai_recno", "N", 9, 162, 170),
    f("bai_reserva", "C", 45, 171, 215),
  ],

  // ---------------------------------------------------------------------------
  // COBERTURA — 23 campos, fim 214
  // ---------------------------------------------------------------------------
  COBERTURA: [
    f("cob_parceiro", "C", 6, 1, 6),
    f("cob_safra_id", "C", 5, 7, 11),
    f("cob_animal_id", "C", 12, 12, 23),
    f("cob_data", "D", 10, 24, 33),
    f("cob_fazenda", "C", 30, 34, 63),
    f("cob_tipo", "C", 1, 64, 64),
    f("cob_periodo", "C", 1, 65, 65),
    f("cob_touro", "C", 12, 66, 77),
    f("cob_cat_touro", "C", 2, 78, 79),
    f("cob_doses", "C", 5, 80, 84),
    f("cob_partida", "C", 6, 85, 90),
    f("cob_inseminador", "C", 4, 91, 94),
    f("cob_prevparto", "D", 10, 95, 104),
    f("cob_dtinirepasse", "D", 10, 105, 114),
    f("cob_dtfimrepasse", "D", 10, 115, 124),
    f("cob_obs", "C", 40, 125, 164),
    f("cob_local_id", "C", 4, 165, 168),
    f("cob_grpmanejo_id", "C", 4, 169, 172),
    f("cob_data_inclusao", "D", 10, 173, 182),
    f("cob_data_alteracao", "D", 10, 183, 192),
    f("cob_hora_alteracao", "C", 8, 193, 200),
    f("cob_enviar", "C", 5, 201, 205),
    f("cob_recno", "N", 9, 206, 214),
  ],

  // ---------------------------------------------------------------------------
  // COMPOSICAO_RACIAL — 10 campos, fim 100
  // ---------------------------------------------------------------------------
  COMPOSICAO_RACIAL: [
    f("cpr_parceiro", "C", 6, 1, 6),
    f("cpr_animal_id", "C", 12, 7, 18),
    f("cpr_raca_id", "C", 2, 19, 20),
    f("cpr_indice", "N", 8, 21, 28),
    f("cpr_fazenda", "C", 30, 29, 58),
    f("cpr_data_inclusao", "D", 10, 59, 68),
    f("cpr_data_alteracao", "D", 10, 69, 78),
    f("cpr_hora_alteracao", "C", 8, 79, 86),
    f("cpr_enviar", "C", 5, 87, 91),
    f("cpr_recno", "N", 9, 92, 100),
  ],

  // ---------------------------------------------------------------------------
  // DESMAMA — 23 campos, fim 216
  // ---------------------------------------------------------------------------
  DESMAMA: [
    f("dsm_parceiro", "C", 6, 1, 6),
    f("dsm_animal_id", "C", 12, 7, 18),
    f("dsm_fazenda", "C", 30, 19, 48),
    f("dsm_data", "D", 10, 49, 58),
    f("dsm_peso", "N", 8, 59, 66),
    f("dsm_nota_c", "N", 8, 67, 74),
    f("dsm_nota_p", "N", 8, 75, 82),
    f("dsm_nota_m", "N", 8, 83, 90),
    f("dsm_nota_u", "N", 8, 91, 98),
    f("dsm_situacao_desclassifica1", "C", 2, 99, 100),
    f("dsm_situacao_desclassifica2", "C", 2, 101, 102),
    f("dsm_nota_ce", "N", 8, 103, 110),
    f("dsm_nota_a", "N", 8, 111, 118),
    f("dsm_regime_alimentar_animal", "C", 4, 119, 122),
    f("dsm_grupo_manejo", "C", 4, 123, 126),
    f("dsm_avaliador", "C", 4, 127, 130),
    f("dsm_local", "C", 4, 131, 134),
    f("dsm_obs", "C", 40, 135, 174),
    f("dsm_data_inclusao", "D", 10, 175, 184),
    f("dsm_data_alteracao", "D", 10, 185, 194),
    f("dsm_hora_alteracao", "C", 8, 195, 202),
    f("dsm_enviar", "C", 5, 203, 207),
    f("dsm_recno", "N", 9, 208, 216),
  ],

  // ---------------------------------------------------------------------------
  // DIAGNOSTICO — 13 campos, fim 159
  // ---------------------------------------------------------------------------
  DIAGNOSTICO: [
    f("dgn_parceiro", "C", 6, 1, 6),
    f("dgn_safra_id", "C", 5, 7, 11),
    f("dgn_animal_id", "C", 12, 12, 23),
    f("dgn_data", "D", 10, 24, 33),
    f("dgn_fazenda", "C", 30, 34, 63),
    f("dgn_local_id", "C", 4, 64, 67),
    f("dgn_grpmanejo_id", "C", 4, 68, 71),
    f("dgn_resultado", "C", 6, 72, 77),
    f("dgn_obs", "C", 40, 78, 117),
    f("dgn_data_inclusao", "D", 10, 118, 127),
    f("dgn_data_alteracao", "D", 10, 128, 137),
    f("dgn_hora_alteracao", "C", 8, 138, 145),
    f("dgn_enviar", "C", 5, 146, 150),
    f("dgn_recno", "N", 9, 151, 159),
  ],

  // ---------------------------------------------------------------------------
  // ESTOQUE — homologado sample 000460, fim 304
  // ---------------------------------------------------------------------------
  ESTOQUE: [
    f("est_parceiro", "C", 6, 1, 6),
    f("est_touro_a12", "C", 12, 7, 18),
    f("est_codigo_fazenda", "C", 30, 19, 48),
    f("est_descricao", "C", 30, 49, 78),
    f("est_pad1", "C", 5, 79, 83),
    f("est_data_aquisicao", "D", 10, 84, 93),
    f("est_tipo_operacao", "C", 10, 94, 103),
    f("est_quantidade", "N", 8, 104, 111),
    f("est_pad2", "C", 9, 112, 120),
    f("est_valor_unitario", "N", 8, 121, 128),
    f("est_valor_total", "N", 9, 129, 137),
    f("est_coeficiente", "N", 6, 138, 143),
    f("est_data_inclusao", "D", 10, 144, 153),
    f("est_data_alteracao", "D", 10, 154, 163),
    f("est_hora_alteracao", "C", 8, 164, 171),
    f("est_enviar", "C", 5, 172, 176),
    f("est_recno", "N", 9, 177, 185),
    f("est_codigo_partida", "C", 6, 186, 191),
    f("est_obs", "C", 29, 192, 220),
    f("est_status", "C", 4, 221, 224),
    f("est_reserva", "C", 80, 225, 304),
  ],

  // ---------------------------------------------------------------------------
  // FAZENDA — 19 campos, fim 426
  // ---------------------------------------------------------------------------
  FAZENDA: [
    f("faz_parceiro", "C", 6, 1, 6),
    f("faz_id", "C", 30, 7, 36),
    f("faz_serie", "C", 4, 37, 40),
    f("faz_nomefazenda", "C", 60, 41, 100),
    f("faz_nomeproprietario", "C", 40, 101, 140),
    f("faz_cidade", "C", 20, 141, 160),
    f("faz_uf", "C", 30, 161, 190),
    f("faz_endereco", "C", 40, 191, 230),
    f("faz_cep", "C", 9, 231, 239),
    f("faz_telefone", "C", 15, 240, 254),
    f("faz_fax", "C", 15, 255, 269),
    f("faz_email", "C", 60, 270, 329),
    f("faz_site", "C", 50, 330, 379),
    f("faz_avalia", "C", 5, 380, 384),
    f("faz_data_inclusao", "D", 10, 385, 394),
    f("faz_data_alteracao", "D", 10, 395, 404),
    f("faz_hora_alteracao", "C", 8, 405, 412),
    f("faz_enviar", "C", 5, 413, 417),
    f("faz_recno", "N", 9, 418, 426),
  ],

  // ---------------------------------------------------------------------------
  // GRUPO_MANEJO — 9 campos, fim 102
  // ---------------------------------------------------------------------------
  GRUPO_MANEJO: [
    f("grm_parceiro", "C", 6, 1, 6),
    f("grm_id", "C", 4, 7, 10),
    f("grm_descri", "C", 20, 11, 30),
    f("grm_fazenda", "C", 30, 31, 60),
    f("grm_data_inclusao", "D", 10, 61, 70),
    f("grm_data_alteracao", "D", 10, 71, 80),
    f("grm_hora_alteracao", "C", 8, 81, 88),
    f("grm_enviar", "C", 5, 89, 93),
    f("grm_recno", "N", 9, 94, 102),
  ],

  // ---------------------------------------------------------------------------
  // INSEMINADOR — homologado sample 000460, fim 110
  // ---------------------------------------------------------------------------
  INSEMINADOR: [
    f("ins_parceiro", "C", 6, 1, 6),
    f("ins_id", "C", 4, 7, 10),
    f("ins_descri", "C", 20, 11, 30),
    f("ins_fazenda", "C", 30, 31, 60),
    f("ins_situacao", "C", 7, 61, 67),
    f("ins_data_inclusao", "D", 10, 68, 77),
    f("ins_data_alteracao", "D", 10, 78, 87),
    f("ins_hora_alteracao", "C", 8, 88, 95),
    f("ins_enviar", "C", 5, 96, 100),
    f("ins_recno", "N", 9, 101, 109),
    f("ins_tipo", "C", 1, 110, 110),
  ],

  // ---------------------------------------------------------------------------
  // LOCALIDADE — 11 campos, fim 146
  // ---------------------------------------------------------------------------
  LOCALIDADE: [
    f("lde_parceiro", "C", 6, 1, 6),
    f("lde_id", "C", 4, 7, 10),
    f("lde_descri", "C", 20, 11, 30),
    f("lde_fazenda", "C", 30, 31, 60),
    f("lde_tipo", "C", 4, 61, 64),
    f("lde_obs", "C", 40, 65, 104),
    f("lde_data_inclusao", "D", 10, 105, 114),
    f("lde_data_alteracao", "D", 10, 115, 124),
    f("lde_hora_alteracao", "C", 8, 125, 132),
    f("lde_enviar", "C", 5, 133, 137),
    f("lde_recno", "N", 9, 138, 146),
  ],

  // ---------------------------------------------------------------------------
  // NASCIMENTO — 35 campos, fim 288
  // ---------------------------------------------------------------------------
  NASCIMENTO: [
    f("nas_parceiro", "C", 6, 1, 6),
    f("nas_safra_id", "C", 5, 7, 11),
    f("nas_animal_id", "C", 12, 12, 23),
    f("nas_data_cob", "D", 10, 24, 33),
    f("nas_seq", "C", 1, 34, 34),
    f("nas_fazenda", "C", 30, 35, 64),
    f("nas_seriefaz", "C", 4, 65, 68),
    f("nas_programa", "C", 1, 69, 69),
    f("nas_animal", "C", 5, 70, 74),
    f("nas_tpparto", "C", 10, 75, 84),
    f("nas_animal_produto_id", "C", 12, 85, 96),
    f("nas_sexo", "C", 1, 97, 97),
    f("nas_tipo", "C", 2, 98, 99),
    f("nas_peso", "N", 8, 100, 107),
    f("nas_tamanho", "C", 1, 108, 108),
    f("nas_descri", "C", 30, 109, 138),
    f("nas_brinco", "C", 15, 139, 153),
    f("nas_raca", "C", 2, 154, 155),
    f("nas_data_nasc", "D", 10, 156, 165),
    f("nas_rgn", "C", 15, 166, 180),
    f("nas_rgd", "C", 15, 181, 195),
    f("nas_pai", "C", 12, 196, 207),
    f("nas_categoria", "C", 2, 208, 209),
    f("nas_prevparto", "D", 10, 210, 219),
    f("nas_regime_alimentar", "C", 4, 220, 223),
    f("nas_grupo_manejo", "C", 4, 224, 227),
    f("nas_local", "C", 4, 228, 231),
    f("nas_data_inclusao", "D", 10, 232, 241),
    f("nas_data_alteracao", "D", 10, 242, 251),
    f("nas_hora_alteracao", "C", 8, 252, 259),
    f("nas_prematuro", "C", 5, 260, 264),
    f("nas_roubada", "C", 5, 265, 269),
    f("nas_enviar", "C", 5, 270, 274),
    f("nas_atuprog", "C", 5, 275, 279),
    f("nas_recno", "N", 9, 280, 288),
  ],

  // ---------------------------------------------------------------------------
  // PESAGEM — 16 campos, fim 139
  // ---------------------------------------------------------------------------
  PESAGEM: [
    f("pes_parceiro", "C", 6, 1, 6),
    f("pes_animal_id", "C", 12, 7, 18),
    f("pes_fazenda", "C", 30, 19, 48),
    f("pes_data", "D", 10, 49, 58),
    f("pes_peso", "N", 8, 59, 66),
    f("pes_racial", "N", 8, 67, 74),
    f("pes_situacao_desclassifica", "C", 2, 75, 76),
    f("pes_grupo_manejo", "C", 4, 77, 80),
    f("pes_local", "C", 4, 81, 84),
    f("pes_data_inclusao", "D", 10, 85, 94),
    f("pes_data_alteracao", "D", 10, 95, 104),
    f("pes_hora_alteracao", "C", 8, 105, 112),
    f("pes_enviar", "C", 5, 113, 117),
    f("pes_recno", "N", 9, 118, 126),
    f("pes_safra_id", "C", 5, 127, 131),
    f("pes_frame", "N", 8, 132, 139),
  ],

  // ---------------------------------------------------------------------------
  // RACA — homologado sample 000460, fim 188
  // ---------------------------------------------------------------------------
  RACA: [
    f("rac_parceiro", "C", 6, 1, 6),
    f("rac_codigo", "C", 2, 7, 8),
    f("rac_descricao", "C", 62, 9, 70),
    f("rac_gestacao_max", "N", 8, 71, 78),
    f("rac_gestacao_med", "N", 8, 79, 86),
    f("rac_gestacao_min", "N", 8, 87, 94),
    f("rac_extra1", "N", 8, 95, 102),
    f("rac_extra2", "N", 8, 103, 110),
    f("rac_extra3", "N", 8, 111, 118),
    f("rac_pad", "C", 28, 119, 146),
    f("rac_data_inclusao", "D", 10, 147, 156),
    f("rac_data_alteracao", "D", 10, 157, 166),
    f("rac_hora_alteracao", "C", 8, 167, 174),
    f("rac_enviar", "C", 5, 175, 179),
    f("rac_recno", "N", 9, 180, 188),
  ],

  // ---------------------------------------------------------------------------
  // PARAMETROS — homologado sample 000460, fim 162
  // ---------------------------------------------------------------------------
  PARAMETROS: [
    f("par_parceiro", "C", 6, 1, 6),
    f("par_id_instalacao", "C", 20, 7, 26),
    f("par_chave", "C", 8, 27, 34),
    f("par_sep1", "C", 2, 35, 36),
    f("par_ip", "C", 15, 37, 51),
    f("par_pad1", "C", 25, 52, 76),
    f("par_porta", "C", 2, 77, 78),
    f("par_sep2", "C", 2, 79, 80),
    f("par_versao", "C", 8, 81, 88),
    f("par_pad2", "C", 9, 89, 97),
    f("par_data_exportacao", "D", 10, 98, 107),
    f("par_pad3", "C", 40, 108, 147),
    f("par_data_instalacao", "D", 10, 148, 157),
    f("par_enviar", "C", 5, 158, 162),
  ],

  // ---------------------------------------------------------------------------
  // RAH — 14 campos, fim 134
  // ---------------------------------------------------------------------------
  RAH: [
    f("rah_parceiro", "C", 6, 1, 6),
    f("rah_animal_id", "C", 12, 7, 18),
    f("rah_fazenda", "C", 30, 19, 48),
    f("rah_data", "D", 10, 49, 58),
    f("rah_peso", "N", 8, 59, 66),
    f("rah_racial", "N", 8, 67, 74),
    f("rah_aprumos", "N", 8, 75, 82),
    f("rah_harmonia", "N", 8, 83, 90),
    f("rah_situacao_desclassifica", "C", 2, 91, 92),
    f("rah_data_inclusao", "D", 10, 93, 102),
    f("rah_data_alteracao", "D", 10, 103, 112),
    f("rah_hora_alteracao", "C", 8, 113, 120),
    f("rah_enviar", "C", 5, 121, 125),
    f("rah_recno", "N", 9, 126, 134),
  ],

  // ---------------------------------------------------------------------------
  // REGIME_ALIMENTAR — lookup. Layout estimado: código(4) + descrição(20)
  // + recno(N 9). TODO: validar com PAINT contra sample. Linha ~33 chars.
  // ---------------------------------------------------------------------------
  REGIME_ALIMENTAR: [
    f("rga_parceiro", "C", 6, 1, 6),
    f("rga_id", "C", 4, 7, 10),
    f("rga_descri", "C", 20, 11, 30),
    f("rga_fazenda", "C", 30, 31, 60),
    f("rga_data_inclusao", "D", 10, 61, 70),
    f("rga_data_alteracao", "D", 10, 71, 80),
    f("rga_hora_alteracao", "C", 8, 81, 88),
    f("rga_enviar", "C", 5, 89, 93),
    f("rga_recno", "N", 9, 94, 102),
  ],

  // ---------------------------------------------------------------------------
  // SAFRA — 12 campos, fim 183
  // ---------------------------------------------------------------------------
  SAFRA: [
    f("sfr_parceiro", "C", 6, 1, 6),
    f("sfr_id", "C", 5, 7, 11),
    f("sfr_fazenda", "C", 30, 12, 41),
    f("sfr_descri", "C", 40, 42, 81),
    f("sfr_data_inicio", "D", 10, 82, 91),
    f("sfr_data_final", "D", 10, 92, 101),
    f("sfr_obs", "C", 40, 102, 141),
    f("sfr_data_inclusao", "D", 10, 142, 151),
    f("sfr_data_alteracao", "D", 10, 152, 161),
    f("sfr_hora_alteracao", "C", 8, 162, 169),
    f("sfr_enviar", "C", 5, 170, 174),
    f("sfr_recno", "N", 9, 175, 183),
  ],

  // ---------------------------------------------------------------------------
  // SAFRA_X_ANIMAL — 13 campos, fim 113
  // ---------------------------------------------------------------------------
  SAFRA_X_ANIMAL: [
    f("sfa_parceiro", "C", 6, 1, 6),
    f("sfa_safra_id", "C", 5, 7, 11),
    f("sfa_animal_id", "C", 12, 12, 23),
    f("sfa_fazenda", "C", 30, 24, 53),
    f("sfa_local_id", "C", 4, 54, 57),
    f("sfa_grpmanejo_id", "C", 4, 58, 61),
    f("sfa_data_inclusao", "D", 10, 62, 71),
    f("sfa_data_alteracao", "D", 10, 72, 81),
    f("sfa_hora_alteracao", "C", 8, 82, 89),
    f("sfa_concluida", "C", 5, 90, 94),
    f("sfa_incluso", "C", 5, 95, 99),
    f("sfa_enviar", "C", 5, 100, 104),
    f("sfa_recno", "N", 9, 105, 113),
  ],

  // ---------------------------------------------------------------------------
  // TOURO_MULTIPLO — 9 campos, fim 102
  // ---------------------------------------------------------------------------
  TOURO_MULTIPLO: [
    f("trm_parceiro", "C", 6, 1, 6),
    f("trm_id", "C", 12, 7, 18),
    f("trm_ani_id", "C", 12, 19, 30),
    f("trm_fazenda", "C", 30, 31, 60),
    f("trm_data_inclusao", "D", 10, 61, 70),
    f("trm_data_alteracao", "D", 10, 71, 80),
    f("trm_hora_alteracao", "C", 8, 81, 88),
    f("trm_enviar", "C", 5, 89, 93),
    f("trm_recno", "N", 9, 94, 102),
  ],

  // ---------------------------------------------------------------------------
  // ULTIMA_TRANSMISSAO — 25 campos, fim 222
  // ---------------------------------------------------------------------------
  ULTIMA_TRANSMISSAO: [
    f("utr_parceiro", "C", 6, 1, 6),
    f("utr_data", "D", 10, 7, 16),
    f("utr_hora", "C", 8, 17, 24),
    f("utr_fazenda", "C", 30, 25, 54),
    f("utr_ani", "N", 8, 55, 62),
    f("utr_sbr", "N", 8, 63, 70),
    f("utr_ava", "N", 8, 71, 78),
    f("utr_bai", "N", 8, 79, 86),
    f("utr_cob", "N", 8, 87, 94),
    f("utr_cpr", "N", 8, 95, 102),
    f("utr_dsm", "N", 8, 103, 110),
    f("utr_dgn", "N", 8, 111, 118),
    f("utr_est", "N", 8, 119, 126),
    f("utr_faz", "N", 8, 127, 134),
    f("utr_grp", "N", 8, 135, 142),
    f("utr_ins", "N", 8, 143, 150),
    f("utr_lde", "N", 8, 151, 158),
    f("utr_nas", "N", 8, 159, 166),
    f("utr_pes", "N", 8, 167, 174),
    f("utr_rac", "N", 8, 175, 182),
    f("utr_rah", "N", 8, 183, 190),
    f("utr_rga", "N", 8, 191, 198),
    f("utr_sfr", "N", 8, 199, 206),
    f("utr_sfa", "N", 8, 207, 214),
    f("utr_trm", "N", 8, 215, 222),
  ],
};

// Lista oficial de arquivos a gerar (manual §5, Tabela 1). Todos obrigatórios
// mesmo que vazios; cada arquivo usa o nome <NOME>.TXT em maiúsculas.
export const PAINT_FILES = [
  "ANIMAL",
  "ANO_SOBREANO",
  "AVALIADOR",
  "BAIXA",
  "COBERTURA",
  "COMPOSICAO_RACIAL",
  "DESMAMA",
  "DIAGNOSTICO",
  "ESTOQUE",
  "FAZENDA",
  "GRUPO_MANEJO",
  "INSEMINADOR",
  "LOCALIDADE",
  "NASCIMENTO",
  "PESAGEM",
  "RACA",
  "RAH",
  "REGIME_ALIMENTAR",
  "SAFRA",
  "SAFRA_X_ANIMAL",
  "TOURO_MULTIPLO",
  "ULTIMA_TRANSMISSAO",
] as const;

/** Entidades com arquivo *_DELETE.TXT no sample 000460. */
export const PAINT_DELETE_ENTITIES = [
  "ANIMAL",
  "ANO_SOBREANO",
  "BAIXA",
  "COBERTURA",
  "COMPOSICAO_RACIAL",
  "DESMAMA",
  "DIAGNOSTICO",
  "ESTOQUE",
  "FAZENDA",
  "GRUPO_MANEJO",
  "NASCIMENTO",
  "SAFRA",
] as const;

/** Arquivos no ZIP de transmissão (sample 000460 + extras do módulo). */
export const PAINT_ZIP_FILES = [
  ...PAINT_FILES,
  "PARAMETROS",
  ...PAINT_DELETE_ENTITIES.map((e) => `${e}_DELETE`),
] as const;

export type PaintFile = typeof PAINT_FILES[number];
