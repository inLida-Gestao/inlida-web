// Geradores de cada um dos 22 arquivos PAINT.
// Cada função recebe o cliente Supabase (já autenticado), idPropriedade e
// config (paint_fazenda_config) e retorna a string completa do arquivo.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { LAYOUTS } from "./layouts.ts";
import {
  buildLine,
  formatA12,
  formatDate,
  formatTime,
  formatNumeric,
  joinLines,
} from "./fixed-width.ts";
import { selectAll } from "./sql.ts";

export interface PaintConfig {
  id_propriedade: string;
  codigo_transmissao: string; // 6 chars
  serie_fazenda: string; // até 4 chars
  codigo_fazenda: string; // 4 chars
}

export interface ExportContext {
  supa: SupabaseClient;
  config: PaintConfig;
  faz: Record<string, unknown> | null;
  // a12Cache mapeia rebanho.idRebanho -> A12 calculado
  a12ByRebanhoId: Map<string, string>;
  numeroByRebanhoId: Map<string, string>;
  // Pre-fetch compartilhado entre generators para evitar duas viagens à mesma
  // tabela (rebanho tem 84k+ linhas globais; uma propriedade pode ter ~10k).
  rebanhoRows?: any[];
  reproducaoRows?: any[];
  pesagemRows?: any[];
  generationDate: string; // dd/mm/aaaa
  generationTime: string; // hh:mm:ss
  generationDateTime: Date;
}

// Calcula A12 de um animal Inlida usando: programa=P (default), serie=config,
// animal=numeroAnimal (>5 chars trunca aos primeiros 5), ano=2 dígitos do
// ano de nascimento.
export function a12FromRebanho(
  config: PaintConfig,
  numero: string | null | undefined,
  dataNasc: string | null | undefined,
): string {
  const ano = dataNasc ? new Date(dataNasc).getUTCFullYear().toString() : "00";
  return formatA12({
    programa: "P",
    serieFazenda: config.serie_fazenda,
    animal: numero ?? "",
    ano,
  });
}

// =============================================================================
// FAZENDA — 1 linha derivada de propriedades + paint_fazenda_config
// =============================================================================
async function genFazenda(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.FAZENDA;
  if (!ctx.faz) return "";

  const row: Record<string, unknown> = {
    faz_parceiro: ctx.config.codigo_transmissao,
    faz_id: ctx.config.codigo_fazenda,
    faz_serie: ctx.config.serie_fazenda,
    faz_nomefazenda: ctx.faz["nome"] ?? "",
    faz_nomeproprietario: "",
    faz_cidade: ctx.faz["cidade"] ?? "",
    faz_uf: ctx.faz["estado"] ?? "",
    faz_endereco: "",
    faz_cep: "",
    faz_telefone: "",
    faz_fax: "",
    faz_email: "",
    faz_site: "",
    faz_avalia: "True ",
    faz_data_inclusao: formatDate(ctx.faz["created_at"]),
    faz_data_alteracao: formatDate(ctx.faz["updated_at"] ?? ctx.faz["created_at"]),
    faz_hora_alteracao: ctx.generationTime,
    faz_enviar: "True ",
    faz_recno: 1,
  };
  return joinLines([buildLine(layout, row)]);
}

// =============================================================================
// ANIMAL — populado a partir de rebanho. Compõe A12, A17 (= A12 sem alguns
// chars + complemento, manual exige 17 chars; preencher com espaços), e busca
// motivo de baixa em paint_baixa.
// =============================================================================
async function genAnimal(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.ANIMAL;
  const rows = ctx.rebanhoRows ?? await selectAll<any>(
    ctx.supa,
    "rebanho",
    (q) => q.eq("idPropriedade", ctx.config.id_propriedade)
      .neq("deletado", "SIM"),
    {
      columns:
        "id,idRebanho,numeroAnimal,chip,codRegistro,nome,sexo,categoria,dataNascimento,pesoNascimento,raca,dataDesmama,pesoDesmama,status,dataVenda,data_morte,motivo_morte,rebanhoIdMatriz,rebanhoIdReprodutor,anotacoes,created_at,updated_at,dataAcao",
    },
  );
  ctx.rebanhoRows = rows;

  // Cache para uso em outros geradores.
  for (const r of rows) {
    const a12 = a12FromRebanho(ctx.config, r.numeroAnimal, r.dataNascimento);
    if (r.idRebanho) ctx.a12ByRebanhoId.set(String(r.idRebanho), a12);
    if (r.idRebanho) ctx.numeroByRebanhoId.set(String(r.idRebanho), String(r.numeroAnimal ?? ""));
  }

  // Carrega últimas baixas para mapear sigla DC/VD/DE/MT.
  const baixas = await selectAll<any>(
    ctx.supa,
    "paint_baixa",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
  );
  const baixaByA12 = new Map<string, string>();
  for (const b of baixas) {
    const sigla = mapBaixaMotivo(String(b.motivo ?? ""));
    if (b.animal_a12 && sigla) baixaByA12.set(String(b.animal_a12).trim(), sigla);
  }

  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    const ano = r.dataNascimento
      ? new Date(r.dataNascimento).getUTCFullYear().toString().slice(-2)
      : "00";
    const a12 = a12FromRebanho(ctx.config, r.numeroAnimal, r.dataNascimento);
    const paiA12 = r.rebanhoIdReprodutor && ctx.a12ByRebanhoId.has(String(r.rebanhoIdReprodutor))
      ? ctx.a12ByRebanhoId.get(String(r.rebanhoIdReprodutor))!
      : "";
    const maeA12 = r.rebanhoIdMatriz && ctx.a12ByRebanhoId.has(String(r.rebanhoIdMatriz))
      ? ctx.a12ByRebanhoId.get(String(r.rebanhoIdMatriz))!
      : "";
    const row: Record<string, unknown> = {
      ani_parceiro: ctx.config.codigo_transmissao,
      ani_programa: "P",
      ani_serie_fazenda: ctx.config.serie_fazenda,
      ani_animal: truncToFive(r.numeroAnimal),
      ani_data_nasc: formatDate(r.dataNascimento),
      ani_A12: a12,
      ani_A17: "", // 17 espaços (manual: "Preencher com espaços em branco")
      ani_sexo: (r.sexo ?? "").toString().slice(0, 1).toUpperCase(),
      ani_tipo: "", // tipo de livro (POI/PO/CL/LA/LA1/CEIP) — não há origem direta
      ani_nome: (r.nome ?? "").toString().slice(0, 30),
      ani_fazenda: ctx.config.codigo_fazenda,
      ani_brinco: (r.numeroAnimal ?? "").toString().slice(0, 15),
      ani_raca: mapRaca(r.raca),
      ani_ceip: "",
      ani_rgd: (r.codRegistro ?? "").toString().slice(0, 15),
      ani_pai: paiA12,
      ani_mae: maeA12,
      ani_categoria: mapCategoria(r),
      ani_regime_alimentar: "",
      ani_grupo_manejo: "",
      ani_local: "",
      ani_data_inclusao: formatDate(r.created_at ?? r.dataAcao ?? ctx.generationDateTime),
      ani_data_alteracao: formatDate(r.updated_at ?? r.dataAcao ?? ctx.generationDateTime),
      ani_hora_alteracao: ctx.generationTime,
      ani_enviar: "True ",
      ani_baixa: baixaByA12.get(a12.trim()) ?? "",
      ani_atuprog: "False",
      ani_recno: recno,
      ani_extra2: "",
      ani_id_eletronica: (r.chip ?? "").toString().slice(0, 20),
      ani_categoria_ant: "",
      ani_racial: "",
      ani_frame: "",
      ani_situacao_desclassifica: "",
      ani_situacao_desclassifica2: "",
      ani_aprumo: "",
      ani_observacao: (r.anotacoes ?? "").toString().slice(0, 40),
      ani_pigmentacao: "",
    };
    lines.push(buildLine(layout, row));
  }
  return joinLines(lines);
}

function truncToFive(num: unknown): string {
  const s = String(num ?? "");
  // Manual: "use os 5 dígitos iniciais e descarte o restante" se >5;
  // se <=5, alinha à direita -> handled by pad C? campo C alinha à esquerda.
  // Para ANIMAL.txt o campo ani_animal é C (alinha à esquerda).
  return s.length > 5 ? s.slice(0, 5) : s;
}

function mapBaixaMotivo(motivo: string): string {
  const m = motivo.toUpperCase();
  if (m === "MORTE") return "MT";
  if (m === "VENDA") return "VD";
  if (m === "DESCARTE") return "DC";
  if (m === "EXCLUSAO") return "DE";
  return "";
}

function mapRaca(raca: unknown): string {
  if (!raca) return "NE"; // assume Nelore por padrão (rebanho do PAINT é Nelore)
  const r = String(raca).toUpperCase();
  if (r.includes("NELORE MOCHO")) return "NO";
  if (r.includes("NELORE")) return "NE";
  if (r.includes("ANGUS")) return "AR";
  if (r.includes("BRAHMAN")) return "BR";
  if (r.includes("GUZER")) return "GZ";
  if (r.includes("SENEPOL")) return "SE";
  if (r.includes("SIMENTAL")) return "SM";
  if (r.includes("TABAPU")) return "TB";
  return r.length >= 2 ? r.slice(0, 2) : "NE";
}

function mapCategoria(r: any): string {
  // Categoria PAINT: AD/AM/GN/MT/NV/RF/TM/TS/TT/VB/VD/VT
  const status = String(r.status ?? "").toUpperCase();
  if (status === "VENDIDO" || r.dataVenda) return "VD";
  if (status === "MORTO" || r.data_morte) return "MT";
  const sexo = String(r.sexo ?? "").toUpperCase();
  if (sexo === "M") return r.dataDesmama ? "AD" : "AM";
  // fêmea
  if (r.dataDesmama) return "VT";
  return "AM";
}

// =============================================================================
// COMPOSICAO_RACIAL — uma linha por (animal, raça). Default 1.0 NE p/ animais
// sem registro próprio (manual §8.2).
// =============================================================================
async function genComposicaoRacial(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.COMPOSICAO_RACIAL;
  const rows = await selectAll<any>(
    ctx.supa,
    "paint_composicao_racial",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
  );

  const lines: string[] = [];
  let recno = 0;
  if (rows.length > 0) {
    for (const r of rows) {
      recno += 1;
      lines.push(buildLine(layout, {
        cpr_parceiro: ctx.config.codigo_transmissao,
        cpr_animal_id: r.animal_a12,
        cpr_raca_id: r.raca_codigo,
        cpr_indice: formatNumeric(r.indice, 8, 6),
        cpr_fazenda: ctx.config.codigo_fazenda,
        cpr_data_inclusao: formatDate(r.created_at),
        cpr_data_alteracao: formatDate(r.updated_at ?? r.created_at),
        cpr_hora_alteracao: ctx.generationTime,
        cpr_enviar: "True ",
        cpr_recno: recno,
      }));
    }
  } else {
    // Fallback: gera 1 linha por animal cadastrado em rebanho com 100% NE.
    for (const a12 of ctx.a12ByRebanhoId.values()) {
      recno += 1;
      lines.push(buildLine(layout, {
        cpr_parceiro: ctx.config.codigo_transmissao,
        cpr_animal_id: a12,
        cpr_raca_id: "NE",
        cpr_indice: formatNumeric(1, 8, 6),
        cpr_fazenda: ctx.config.codigo_fazenda,
        cpr_data_inclusao: ctx.generationDate,
        cpr_data_alteracao: ctx.generationDate,
        cpr_hora_alteracao: ctx.generationTime,
        cpr_enviar: "True ",
        cpr_recno: recno,
      }));
    }
  }
  return joinLines(lines);
}

// =============================================================================
// COBERTURA — de `reproducao`.
// =============================================================================
async function genCobertura(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.COBERTURA;
  const rows = ctx.reproducaoRows ?? await selectAll<any>(
    ctx.supa,
    "reproducao",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade)
      .neq("deletado", "SIM"),
    {
      columns:
        "id,id_rebanho_matriz,id_rebanho_reprodutor,data_inseminacao,data_inicial,data_final,tipo_reproducao,partida_semen,previsao_parto,anotacoes,created_at,updated_at",
    },
  );
  ctx.reproducaoRows = rows;
  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    const matrizA12 = ctx.a12ByRebanhoId.get(String(r.id_rebanho_matriz)) ?? "";
    const touroA12 = ctx.a12ByRebanhoId.get(String(r.id_rebanho_reprodutor)) ?? "";
    lines.push(buildLine(layout, {
      cob_parceiro: ctx.config.codigo_transmissao,
      cob_safra_id: derivaSafra(r.data_inseminacao),
      cob_animal_id: matrizA12,
      cob_data: formatDate(r.data_inseminacao),
      cob_fazenda: ctx.config.codigo_fazenda,
      cob_tipo: mapTipoCobertura(r.tipo_reproducao),
      cob_periodo: "M",
      cob_touro: touroA12,
      cob_cat_touro: matrizA12 ? "TT" : "",
      cob_doses: "",
      cob_partida: r.partida_semen ? String(r.partida_semen).slice(0, 6) : "",
      cob_inseminador: "",
      cob_prevparto: formatDate(r.previsao_parto),
      cob_dtinirepasse: formatDate(r.data_inicial),
      cob_dtfimrepasse: formatDate(r.data_final),
      cob_obs: (r.anotacoes ?? "").toString().slice(0, 40),
      cob_local_id: "",
      cob_grpmanejo_id: "",
      cob_data_inclusao: formatDate(r.created_at),
      cob_data_alteracao: formatDate(r.updated_at ?? r.created_at),
      cob_hora_alteracao: ctx.generationTime,
      cob_enviar: "True ",
      cob_recno: recno,
    }));
  }
  return joinLines(lines);
}

function mapTipoCobertura(tipo: unknown): string {
  const t = String(tipo ?? "").toUpperCase();
  if (t.includes("IATF")) return "F";
  if (t.includes("INSEMINA")) return "I";
  if (t.includes("MONTA CONTROL")) return "C";
  if (t.includes("EMBRI")) return "E";
  return "R";
}

function derivaSafra(data: unknown): string {
  if (!data) return "";
  const d = new Date(String(data));
  if (isNaN(d.getTime())) return "";
  // Manual §8.5: safra = animais nascidos entre 01/06 e 31/05 do ano seguinte.
  // Para a estação de monta de ano X (que gera nascimentos em X+1), usa-se
  // ano da estação. Estimamos: se mês <= 5, ano-1, senão ano corrente. Tag = 'P'.
  const m = d.getUTCMonth() + 1;
  const y = d.getUTCFullYear();
  const safraAno = m <= 5 ? y - 1 : y;
  return `${safraAno}P`;
}

// =============================================================================
// NASCIMENTO — filhos com matriz definida.
// =============================================================================
async function genNascimento(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.NASCIMENTO;
  // Reusa pre-fetch de rebanho (genAnimal popula).
  const rowsAll = ctx.rebanhoRows ?? await selectAll<any>(
    ctx.supa,
    "rebanho",
    (q) => q.eq("idPropriedade", ctx.config.id_propriedade)
      .neq("deletado", "SIM"),
  );
  const rows = rowsAll.filter((r) => r.dataNascimento != null);
  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    if (!r.rebanhoIdMatriz) continue;
    recno += 1;
    const a12Cria = ctx.a12ByRebanhoId.get(String(r.idRebanho)) ?? "";
    const matrizA12 = ctx.a12ByRebanhoId.get(String(r.rebanhoIdMatriz)) ?? "";
    const paiA12 = r.rebanhoIdReprodutor
      ? ctx.a12ByRebanhoId.get(String(r.rebanhoIdReprodutor)) ?? ""
      : "";
    const ano = r.dataNascimento
      ? new Date(r.dataNascimento).getUTCFullYear().toString().slice(-2)
      : "00";
    lines.push(buildLine(layout, {
      nas_parceiro: ctx.config.codigo_transmissao,
      nas_safra_id: derivaSafra(r.dataNascimento),
      nas_animal_id: matrizA12,
      nas_data_cob: "",
      nas_seq: "1",
      nas_fazenda: ctx.config.codigo_fazenda,
      nas_seriefaz: ctx.config.serie_fazenda,
      nas_programa: "P",
      nas_animal: truncToFive(r.numeroAnimal),
      nas_tpparto: "NORMAL",
      nas_animal_produto_id: a12Cria,
      nas_sexo: String(r.sexo ?? "").slice(0, 1).toUpperCase(),
      nas_tipo: "",
      nas_peso: formatNumeric(r.pesoNascimento, 8, 2),
      nas_tamanho: "",
      nas_descri: (r.nome ?? "").toString().slice(0, 30),
      nas_brinco: (r.numeroAnimal ?? "").toString().slice(0, 15),
      nas_raca: mapRaca(r.raca),
      nas_data_nasc: formatDate(r.dataNascimento),
      nas_rgn: "",
      nas_rgd: (r.codRegistro ?? "").toString().slice(0, 15),
      nas_pai: paiA12,
      nas_categoria: mapCategoria(r),
      nas_prevparto: "",
      nas_regime_alimentar: "",
      nas_grupo_manejo: "",
      nas_local: "",
      nas_data_inclusao: formatDate(r.created_at),
      nas_data_alteracao: formatDate(r.updated_at ?? r.created_at),
      nas_hora_alteracao: ctx.generationTime,
      nas_prematuro: "False",
      nas_roubada: r.rebanhoIdMatriz ? "False" : "True ",
      nas_enviar: "True ",
      nas_atuprog: "False",
      nas_recno: recno,
    }));
  }
  return joinLines(lines);
}

// =============================================================================
// ESTOQUE — arquivo vazio (manual).
// =============================================================================
async function genEstoque(): Promise<string> {
  return "";
}

// =============================================================================
// Helpers de geradores baseados em paint_* tables (mapeamento direto).
// =============================================================================
async function paintTableGenerator<T extends Record<string, unknown>>(
  ctx: ExportContext,
  layoutKey: keyof typeof LAYOUTS,
  table: string,
  mapper: (row: any, recno: number) => Record<string, unknown>,
): Promise<string> {
  const layout = LAYOUTS[layoutKey];
  const rows = await selectAll<any>(
    ctx.supa,
    table,
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
  );
  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    lines.push(buildLine(layout, mapper(r, recno)));
  }
  return joinLines(lines);
}

async function genAvaliador(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "AVALIADOR", "paint_avaliador", (r, recno) => ({
    ava_parceiro: ctx.config.codigo_transmissao,
    ava_id: r.codigo,
    ava_descri: (r.nome ?? "").toString().slice(0, 25),
    ava_situacao: r.situacao ?? "ATIVO",
    ava_fazenda: ctx.config.codigo_fazenda,
    ava_data_inclusao: formatDate(r.created_at),
    ava_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    ava_hora_alteracao: ctx.generationTime,
    ava_enviar: "True ",
    ava_recno: recno,
  }));
}

async function genBaixa(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "BAIXA", "paint_baixa", (r, recno) => ({
    bai_parceiro: ctx.config.codigo_transmissao,
    bai_animal_A12: r.animal_a12,
    bai_fazenda: ctx.config.codigo_fazenda,
    bai_animal: r.animal_a12 ? String(r.animal_a12).slice(7, 12).trim() : "",
    bai_data_morte: formatDate(r.data_morte),
    bai_motivo: r.motivo,
    bai_preco: formatNumeric(r.preco ?? 0, 10, 2),
    bai_data_inclusao: formatDate(r.created_at),
    bai_obs: (r.obs ?? "").toString().slice(0, 40),
    bai_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    bai_hora_alteracao: ctx.generationTime,
    bai_enviar: "True ",
    bai_recno: recno,
  }));
}

async function genDesmama(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "DESMAMA", "paint_avaliacao_desmama", (r, recno) => ({
    dsm_parceiro: ctx.config.codigo_transmissao,
    dsm_animal_id: r.animal_a12,
    dsm_fazenda: ctx.config.codigo_fazenda,
    dsm_data: formatDate(r.data),
    dsm_peso: formatNumeric(r.peso, 8, 2),
    dsm_nota_c: formatNumeric(r.nota_c, 8, 2),
    dsm_nota_p: formatNumeric(r.nota_p, 8, 2),
    dsm_nota_m: formatNumeric(r.nota_m, 8, 2),
    dsm_nota_u: formatNumeric(r.nota_u, 8, 2),
    dsm_situacao_desclassifica1: r.situacao_desclass1 ?? "",
    dsm_situacao_desclassifica2: r.situacao_desclass2 ?? "",
    dsm_nota_ce: "", // só sobreano
    dsm_nota_a: "",
    dsm_regime_alimentar_animal: r.regime_alimentar_codigo ?? "",
    dsm_grupo_manejo: r.grupo_manejo_codigo ?? "",
    dsm_avaliador: r.avaliador_codigo ?? "",
    dsm_local: r.local_codigo ?? "",
    dsm_obs: (r.obs ?? "").toString().slice(0, 40),
    dsm_data_inclusao: formatDate(r.created_at),
    dsm_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    dsm_hora_alteracao: ctx.generationTime,
    dsm_enviar: "True ",
    dsm_recno: recno,
  }));
}

async function genAnoSobreano(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "ANO_SOBREANO", "paint_avaliacao_sobreano", (r, recno) => ({
    sbr_parceiro: ctx.config.codigo_transmissao,
    sbr_animal_id: r.animal_a12,
    sbr_fazenda: ctx.config.codigo_fazenda,
    sbr_data: formatDate(r.data),
    sbr_peso: formatNumeric(r.peso, 8, 2),
    sbr_nota_c: formatNumeric(r.nota_c, 8, 2),
    sbr_nota_p: formatNumeric(r.nota_p, 8, 2),
    sbr_nota_m: formatNumeric(r.nota_m, 8, 2),
    sbr_nota_u: formatNumeric(r.nota_u, 8, 2),
    sbr_nota_t: formatNumeric(r.nota_t, 8, 2),
    sbr_situacao_desclassifica1: r.situacao_desclass1 ?? "",
    sbr_situacao_desclassifica2: r.situacao_desclass2 ?? "",
    sbr_nota_ce: formatNumeric(r.nota_ce, 8, 2),
    sbr_nota_a: formatNumeric(r.nota_a, 8, 2),
    sbr_regime_alimentar_animal: r.regime_alimentar_codigo ?? "",
    sbr_grupo_manejo: r.grupo_manejo_codigo ?? "",
    sbr_local: r.local_codigo ?? "",
    sbr_avaliador: r.avaliador_codigo ?? "",
    sbr_obs: (r.obs ?? "").toString().slice(0, 40),
    sbr_data_inclusao: formatDate(r.created_at),
    sbr_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    sbr_hora_alteracao: ctx.generationTime,
    sbr_enviar: "True ",
    sbr_recno: recno,
  }));
}

async function genRah(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "RAH", "paint_avaliacao_rah", (r, recno) => ({
    rah_parceiro: ctx.config.codigo_transmissao,
    rah_animal_id: r.animal_a12,
    rah_fazenda: ctx.config.codigo_fazenda,
    rah_data: formatDate(r.data),
    rah_peso: formatNumeric(r.peso, 8, 2),
    rah_racial: formatNumeric(r.racial, 8, 2),
    rah_aprumos: formatNumeric(r.aprumos, 8, 2),
    rah_harmonia: formatNumeric(r.harmonia, 8, 2),
    rah_situacao_desclassifica: r.situacao_desclass ?? "",
    rah_data_inclusao: formatDate(r.created_at),
    rah_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    rah_hora_alteracao: ctx.generationTime,
    rah_enviar: "True ",
    rah_recno: recno,
  }));
}

async function genDiagnostico(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "DIAGNOSTICO", "paint_diagnostico", (r, recno) => ({
    dgn_parceiro: ctx.config.codigo_transmissao,
    dgn_safra_id: r.safra_codigo,
    dgn_animal_id: r.animal_a12,
    dgn_data: formatDate(r.data),
    dgn_fazenda: ctx.config.codigo_fazenda,
    dgn_local_id: r.local_codigo ?? "",
    dgn_grpmanejo_id: r.grupo_manejo_codigo ?? "",
    dgn_resultado: r.resultado === "P" ? "PRENHA" : "VAZIA",
    dgn_obs: (r.obs ?? "").toString().slice(0, 40),
    dgn_data_inclusao: formatDate(r.created_at),
    dgn_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    dgn_hora_alteracao: ctx.generationTime,
    dgn_enviar: "True ",
    dgn_recno: recno,
  }));
}

async function genGrupoManejo(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "GRUPO_MANEJO", "paint_grupo_manejo", (r, recno) => ({
    grm_parceiro: ctx.config.codigo_transmissao,
    grm_id: r.codigo,
    grm_descri: (r.descricao ?? "").toString().slice(0, 20),
    grm_fazenda: ctx.config.codigo_fazenda,
    grm_data_inclusao: formatDate(r.created_at),
    grm_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    grm_hora_alteracao: ctx.generationTime,
    grm_enviar: "True ",
    grm_recno: recno,
  }));
}

async function genInseminador(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "INSEMINADOR", "paint_inseminador", (r, recno) => ({
    ins_parceiro: ctx.config.codigo_transmissao,
    ins_id: r.codigo,
    ins_descri: (r.nome ?? "").toString().slice(0, 20),
    ins_fazenda: ctx.config.codigo_fazenda,
    ins_situacao: r.situacao ?? "ATIVO",
    ins_data_inclusao: formatDate(r.created_at),
    ins_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    ins_hora_alteracao: ctx.generationTime,
    ins_enviar: "True ",
    ins_recno: recno,
  }));
}

async function genLocalidade(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "LOCALIDADE", "paint_localidade", (r, recno) => ({
    lde_parceiro: ctx.config.codigo_transmissao,
    lde_id: r.codigo,
    lde_descri: (r.descricao ?? "").toString().slice(0, 20),
    lde_fazenda: ctx.config.codigo_fazenda,
    lde_tipo: "",
    lde_obs: (r.obs ?? "").toString().slice(0, 40),
    lde_data_inclusao: formatDate(r.created_at),
    lde_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    lde_hora_alteracao: ctx.generationTime,
    lde_enviar: "True ",
    lde_recno: recno,
  }));
}

async function genRegimeAlimentar(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "REGIME_ALIMENTAR", "paint_regime_alimentar", (r, recno) => ({
    rga_parceiro: ctx.config.codigo_transmissao,
    rga_id: r.codigo,
    rga_descri: (r.descricao ?? "").toString().slice(0, 20),
    rga_fazenda: ctx.config.codigo_fazenda,
    rga_data_inclusao: formatDate(r.created_at),
    rga_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    rga_hora_alteracao: ctx.generationTime,
    rga_enviar: "True ",
    rga_recno: recno,
  }));
}

async function genSafra(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "SAFRA", "paint_safra", (r, recno) => ({
    sfr_parceiro: ctx.config.codigo_transmissao,
    sfr_id: r.codigo,
    sfr_fazenda: ctx.config.codigo_fazenda,
    sfr_descri: (r.descricao ?? "").toString().slice(0, 40),
    sfr_data_inicio: formatDate(r.data_inicio),
    sfr_data_final: formatDate(r.data_final),
    sfr_obs: (r.obs ?? "").toString().slice(0, 40),
    sfr_data_inclusao: formatDate(r.created_at),
    sfr_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    sfr_hora_alteracao: ctx.generationTime,
    sfr_enviar: "True ",
    sfr_recno: recno,
  }));
}

async function genSafraXAnimal(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "SAFRA_X_ANIMAL", "paint_safra_x_animal", (r, recno) => ({
    sfa_parceiro: ctx.config.codigo_transmissao,
    sfa_safra_id: r.safra_codigo,
    sfa_animal_id: r.animal_a12,
    sfa_fazenda: ctx.config.codigo_fazenda,
    sfa_local_id: r.local_codigo ?? "",
    sfa_grpmanejo_id: r.grupo_manejo_codigo ?? "",
    sfa_data_inclusao: formatDate(r.created_at),
    sfa_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    sfa_hora_alteracao: ctx.generationTime,
    sfa_concluida: r.concluida ? "True " : "False",
    sfa_incluso: "False",
    sfa_enviar: "True ",
    sfa_recno: recno,
  }));
}

async function genTouroMultiplo(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "TOURO_MULTIPLO", "paint_touro_multiplo", (r, recno) => ({
    trm_parceiro: ctx.config.codigo_transmissao,
    trm_id: r.multiplo_a12,
    trm_ani_id: r.touro_a12,
    trm_fazenda: ctx.config.codigo_fazenda,
    trm_data_inclusao: formatDate(r.created_at),
    trm_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    trm_hora_alteracao: ctx.generationTime,
    trm_enviar: "True ",
    trm_recno: recno,
  }));
}

// =============================================================================
// PESAGEM — derivada de historico_pesagens (ou rebanho.pesoAtual em fallback).
// =============================================================================
async function genPesagem(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.PESAGEM;
  const lines: string[] = [];
  let recno = 0;

  // Tenta historico_pesagens (existe no projeto, ver migrations
  // 20260413143000_backfill_data_ultima_pesagem.sql).
  let rows: any[] = ctx.pesagemRows ?? [];
  if (rows.length === 0 && !ctx.pesagemRows) {
    try {
      rows = await selectAll<any>(
        ctx.supa,
        "historico_pesagens",
        (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
        { columns: "id,id_rebanho,data_pesagem,peso,created_at,updated_at" },
      );
    } catch (_e) {
      rows = [];
    }
    ctx.pesagemRows = rows;
  }
  for (const r of rows) {
    recno += 1;
    const a12 = ctx.a12ByRebanhoId.get(String(r.id_rebanho)) ?? "";
    if (!a12) continue;
    lines.push(buildLine(layout, {
      pes_parceiro: ctx.config.codigo_transmissao,
      pes_animal_id: a12,
      pes_fazenda: ctx.config.codigo_fazenda,
      pes_data: formatDate(r.data_pesagem ?? r.data),
      pes_peso: formatNumeric(r.peso, 8, 2),
      pes_racial: "",
      pes_situacao_desclassifica: "",
      pes_grupo_manejo: "",
      pes_local: "",
      pes_data_inclusao: formatDate(r.created_at ?? r.data_pesagem),
      pes_data_alteracao: formatDate(r.updated_at ?? r.created_at),
      pes_hora_alteracao: ctx.generationTime,
      pes_enviar: "True ",
      pes_recno: recno,
      pes_safra_id: derivaSafra(r.data_pesagem ?? r.data),
      pes_frame: "",
    }));
  }
  return joinLines(lines);
}

// =============================================================================
// RACA — emite todas as linhas do lookup paint_codigo_raca.
// =============================================================================
async function genRaca(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.RACA;
  const rows = await selectAll<any>(ctx.supa, "paint_codigo_raca", (q) => q);
  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    lines.push(buildLine(layout, {
      rac_codigo: r.codigo,
      rac_descricao: (r.descricao ?? "").toString().slice(0, 20),
      rac_gestacao_med: formatNumeric(r.gestacao_med ?? 0, 8, 0),
      rac_gestacao_min: formatNumeric(r.gestacao_min ?? 0, 8, 0),
      rac_gestacao_max: formatNumeric(r.gestacao_max ?? 0, 8, 0),
      rac_recno: recno,
    }));
  }
  return joinLines(lines);
}

// =============================================================================
// ULTIMA_TRANSMISSAO — counts dos arquivos gerados nesta execução.
// =============================================================================
async function genUltimaTransmissao(
  ctx: ExportContext,
  counts: Record<string, number>,
): Promise<string> {
  const layout = LAYOUTS.ULTIMA_TRANSMISSAO;
  const row: Record<string, unknown> = {
    utr_parceiro: ctx.config.codigo_transmissao,
    utr_data: ctx.generationDate,
    utr_hora: ctx.generationTime,
    utr_fazenda: ctx.config.codigo_fazenda,
    utr_ani: counts.ANIMAL ?? 0,
    utr_sbr: counts.ANO_SOBREANO ?? 0,
    utr_ava: counts.AVALIADOR ?? 0,
    utr_bai: counts.BAIXA ?? 0,
    utr_cob: counts.COBERTURA ?? 0,
    utr_cpr: counts.COMPOSICAO_RACIAL ?? 0,
    utr_dsm: counts.DESMAMA ?? 0,
    utr_dgn: counts.DIAGNOSTICO ?? 0,
    utr_est: counts.ESTOQUE ?? 0,
    utr_faz: counts.FAZENDA ?? 0,
    utr_grp: counts.GRUPO_MANEJO ?? 0,
    utr_ins: counts.INSEMINADOR ?? 0,
    utr_lde: counts.LOCALIDADE ?? 0,
    utr_nas: counts.NASCIMENTO ?? 0,
    utr_pes: counts.PESAGEM ?? 0,
    utr_rac: counts.RACA ?? 0,
    utr_rah: counts.RAH ?? 0,
    utr_rga: counts.REGIME_ALIMENTAR ?? 0,
    utr_sfr: counts.SAFRA ?? 0,
    utr_sfa: counts.SAFRA_X_ANIMAL ?? 0,
    utr_trm: counts.TOURO_MULTIPLO ?? 0,
  };
  return joinLines([buildLine(layout, row)]);
}

// =============================================================================
// Dispatcher
// =============================================================================
export type Generator = (ctx: ExportContext) => Promise<string>;

export const GENERATORS: Record<string, Generator> = {
  ANIMAL: genAnimal,
  ANO_SOBREANO: genAnoSobreano,
  AVALIADOR: genAvaliador,
  BAIXA: genBaixa,
  COBERTURA: genCobertura,
  COMPOSICAO_RACIAL: genComposicaoRacial,
  DESMAMA: genDesmama,
  DIAGNOSTICO: genDiagnostico,
  ESTOQUE: genEstoque,
  FAZENDA: genFazenda,
  GRUPO_MANEJO: genGrupoManejo,
  INSEMINADOR: genInseminador,
  LOCALIDADE: genLocalidade,
  NASCIMENTO: genNascimento,
  PESAGEM: genPesagem,
  RACA: genRaca,
  RAH: genRah,
  REGIME_ALIMENTAR: genRegimeAlimentar,
  SAFRA: genSafra,
  SAFRA_X_ANIMAL: genSafraXAnimal,
  TOURO_MULTIPLO: genTouroMultiplo,
};

export { genUltimaTransmissao };
