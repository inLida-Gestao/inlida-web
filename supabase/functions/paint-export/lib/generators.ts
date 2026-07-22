// Geradores de cada um dos 22 arquivos PAINT.
// Cada função recebe o cliente Supabase (já autenticado), idPropriedade e
// config (paint_fazenda_config) e retorna a string completa do arquivo.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { LAYOUTS } from "./layouts.ts";
import {
  buildLine,
  type EstrategiaA12,
  formatDate,
  formatNumeric,
  joinLines,
} from "./fixed-width.ts";
import { selectAll } from "./sql.ts";
import {
  a12FromRebanho,
  derivaSafraCodigo,
  extractAnimal5,
  extractBrinco5,
  grupoManejoFromLote,
  mapBaixaMotivo,
  mapCategoriaAnterior,
  mapCategoriaPaint,
  mapRacaPaint,
  mapTipoCobertura,
  mapTipoRegistro,
  resolveSerieA12,
} from "./paint_mappers.ts";

export interface PaintConfig {
  id_propriedade: string;
  codigo_transmissao: string; // 6 chars
  serie_fazenda: string; // até 4 chars
  serie_raca_po?: string | null; // série do registro p/ animais PO (ex.: JLK)
  codigo_fazenda: string; // 4 chars
  programa?: string | null;
  estrategia_a12?: EstrategiaA12 | null;
  campo_origem_animal?: string | null;
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
  // Caches leves (só strings) que precisam sobreviver à liberação de
  // rebanhoRows (feita após NASCIMENTO p/ caber na memória do worker).
  // DESMAMA/ANO_SOBREANO consomem estes mapas DEPOIS dessa liberação.
  loteNomePorA12?: Map<string, string>;
  loteNomePorRebanhoId?: Map<string, string>;
  generationDate: string; // dd/mm/aaaa
  generationTime: string; // hh:mm:ss
  generationDateTime: Date;
}

// A12 e demais regras de domínio: ver ./paint_mappers.ts (espelho Dart em
// lib/custom_code/actions/paint_mappers.dart). a12FromRebanho é PO-aware.
export { a12FromRebanho };

function fazendaField(ctx: ExportContext): string {
  const cod = (ctx.config.codigo_fazenda ?? "").toString();
  return cod.padStart(30, " ").slice(0, 30);
}

// Mapa descrição-do-lote (UPPER, 20 chars) -> código do grupo de manejo PAINT.
// O grupo é criado a partir dos lotes (paint_grupo_manejo.descricao = nome do
// lote) e o animal liga-se ao lote por rebanho.loteNome (manual §8.4).
async function loadGrupoByDescricao(ctx: ExportContext): Promise<Map<string, string>> {
  const grupos = await selectAll<any>(
    ctx.supa,
    "paint_grupo_manejo",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
    { columns: "codigo,descricao", orderColumn: "codigo" },
  );
  const map = new Map<string, string>();
  for (const g of grupos) {
    const descr = String(g.descricao ?? "").trim().toUpperCase();
    const cod = String(g.codigo ?? "").trim();
    if (descr && cod) map.set(descr, cod);
  }
  return map;
}

// Mapa nome-do-inseminador (UPPER) -> código PAINT. paint_inseminador é criado
// a partir de reproducao.inseminador (nome); a tabela COBERTURA referencia o
// inseminador pelo nome, então precisamos resolver para o código cadastrado.
async function loadInseminadorByNome(ctx: ExportContext): Promise<Map<string, string>> {
  const ins = await selectAll<any>(
    ctx.supa,
    "paint_inseminador",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
    { columns: "codigo,nome", orderColumn: "codigo" },
  );
  const map = new Map<string, string>();
  for (const i of ins) {
    const nome = String(i.nome ?? "").trim().toUpperCase();
    const cod = String(i.codigo ?? "").trim();
    if (nome && cod) map.set(nome, cod);
  }
  return map;
}

// Mapa idRebanho -> loteNome (a partir do pre-fetch de rebanho em genAnimal).
function loteByRebanhoId(ctx: ExportContext): Map<string, string> {
  const map = new Map<string, string>();
  for (const r of ctx.rebanhoRows ?? []) {
    if (r.idRebanho) map.set(String(r.idRebanho), String(r.loteNome ?? ""));
  }
  return map;
}

// Mapa A12 -> loteNome, para derivar o grupo de manejo em tabelas keyed por A12
// (DESMAMA, ANO_SOBREANO). O campo grupo_manejo_codigo dessas tabelas não é
// preenchido no cadastro/importação, então caímos no grupo do lote atual do
// animal — mesma fonte usada em ANIMAL/NASCIMENTO (manual §8.4).
function loteNomeByA12(ctx: ExportContext): Map<string, string> {
  const map = new Map<string, string>();
  for (const r of ctx.rebanhoRows ?? []) {
    const a12 = ctx.a12ByRebanhoId.get(String(r.idRebanho ?? ""));
    if (a12) map.set(a12.trim().toUpperCase(), String(r.loteNome ?? ""));
  }
  return map;
}

// grupo_manejo_codigo do registro OU, se vazio, o grupo derivado do lote do
// animal (via A12). Usado por DESMAMA/ANO_SOBREANO.
function grupoManejoAvaliacao(
  r: any,
  loteA12: Map<string, string>,
  grupoByDescricao: Map<string, string>,
): string {
  const gm = String(r.grupo_manejo_codigo ?? "").trim();
  if (gm) return gm;
  const lote = loteA12.get(String(r.animal_a12 ?? "").trim().toUpperCase());
  return grupoManejoFromLote(lote, grupoByDescricao);
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

// Resolve o A12 do pai/mãe (ani_pai / ani_mae / nas_pai). O A12 posicional
// depende da data de nascimento; touros de SÊMEN (reprodutor externo) não têm
// data e a12FromRebanho retorna vazio — deixando o campo em branco. Nesses
// casos o A12 real do pai é o próprio código de registro (já é um A12 do PAINT,
// 12 chars, ex.: "pPECA 458115"). Mesmo tratamento do cob_touro na cobertura.
// `allRows` deve ser o conjunto COMPLETO do rebanho (incluindo os de sêmen, que
// não têm dataNascimento e são filtrados fora do NASCIMENTO).
function makeParentA12Resolver(
  ctx: ExportContext,
  allRows: any[],
): (idPai: unknown) => string {
  const rowByRebanhoId = new Map<string, any>();
  for (const a of allRows) {
    if (a.idRebanho != null) rowByRebanhoId.set(String(a.idRebanho), a);
  }
  return (idPai: unknown): string => {
    const key = idPai != null ? String(idPai) : "";
    if (!key) return "";
    const computed = ctx.a12ByRebanhoId.get(key) ?? "";
    const parent = rowByRebanhoId.get(key);
    const statusNorm = String(parent?.status ?? "")
      .normalize("NFD").replace(/[\u0300-\u036f]/g, "").trim().toLowerCase();
    const cr = String(parent?.codRegistro ?? "").trim();
    // Pai de sêmen, ou qualquer pai cujo A12 posicional não pôde ser calculado:
    // usa o código de registro quando já é um A12 do PAINT (12 chars).
    if ((statusNorm === "semen" || !computed) && cr.length === 12) return cr;
    return computed;
  };
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
        "id,idRebanho,numeroAnimal,chip,codRegistro,nome,sexo,categoria,dataNascimento,pesoNascimento,raca,tipo_registro,dataDesmama,pesoDesmama,status,dataVenda,data_morte,motivo_morte,rebanhoIdMatriz,rebanhoIdReprodutor,anotacoes,loteNome,loteID,created_at,updated_at,dataAcao",
      orderColumn: "id",
    },
  );
  ctx.rebanhoRows = rows;

  const grupoByDescricao = await loadGrupoByDescricao(ctx);
  // Cache para uso em outros geradores (pode já vir preenchido no prefetch).
  if (ctx.a12ByRebanhoId.size === 0) {
    for (const r of rows) {
      const a12 = a12FromRebanho(ctx.config, r);
      if (r.idRebanho) ctx.a12ByRebanhoId.set(String(r.idRebanho), a12);
      if (r.idRebanho) {
        ctx.numeroByRebanhoId.set(String(r.idRebanho), String(r.numeroAnimal ?? ""));
      }
    }
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

  // Notas R/F/A/P da avaliação de matrizes (RAH) refletidas no ANIMAL.
  // Mantém a última avaliação por A12 (maior data).
  const rahRows = await selectAll<any>(
    ctx.supa,
    "paint_avaliacao_rah",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
    { columns: "animal_a12,data,racial,aprumos,harmonia,frame,pigmentacao", orderColumn: "data" },
  );
  const rahByA12 = new Map<string, any>();
  for (const rah of rahRows) {
    const key = String(rah.animal_a12 ?? "").trim();
    if (key) rahByA12.set(key, rah); // ordenado por data asc → fica a última
  }

  const resolveParentA12 = makeParentA12Resolver(ctx, rows);

  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    const a12 = ctx.a12ByRebanhoId.get(String(r.idRebanho ?? "")) ??
      a12FromRebanho(ctx.config, r);
    const paiA12 = resolveParentA12(r.rebanhoIdReprodutor);
    const maeA12 = resolveParentA12(r.rebanhoIdMatriz);
    const categoria = mapCategoriaPaint(r);
    const rah = rahByA12.get(a12.trim());
    const row: Record<string, unknown> = {
      ani_parceiro: ctx.config.codigo_transmissao,
      ani_programa: (ctx.config.programa ?? "P").toString().slice(0, 1),
      ani_serie_fazenda: resolveSerieA12(r, ctx.config),
      ani_animal: extractAnimal5(r.numeroAnimal),
      ani_data_nasc: formatDate(r.dataNascimento),
      ani_A12: a12,
      ani_A17: "", // 17 espaços (manual: "Preencher com espaços em branco")
      ani_sexo: (r.sexo ?? "").toString().slice(0, 1).toUpperCase(),
      ani_tipo: mapTipoRegistro(r), // PO / CL / vazio (manual §11.4)
      ani_nome: (r.nome ?? "").toString().slice(0, 30),
      ani_fazenda: ctx.config.codigo_fazenda,
      ani_brinco: extractBrinco5(r.numeroAnimal), // 5 dígitos, sem sigla (JLK)
      ani_raca: mapRacaPaint(r.raca),
      ani_ceip: "",
      ani_rgd: (r.codRegistro ?? "").toString().slice(0, 15),
      ani_pai: paiA12,
      ani_mae: maeA12,
      ani_categoria: categoria,
      ani_regime_alimentar: "",
      ani_grupo_manejo: grupoManejoFromLote(r.loteNome, grupoByDescricao),
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
      ani_categoria_ant: mapCategoriaAnterior(categoria),
      ani_racial: rah ? formatNumeric(rah.racial, 8, 2) : "",
      ani_frame: rah ? formatNumeric(rah.frame, 8, 2) : "",
      ani_situacao_desclassifica: "",
      ani_situacao_desclassifica2: "",
      ani_aprumo: rah ? formatNumeric(rah.aprumos, 8, 2) : "",
      ani_observacao: (r.anotacoes ?? "").toString().slice(0, 40),
      ani_pigmentacao: rah ? formatNumeric(rah.pigmentacao, 8, 2) : "",
    };
    lines.push(buildLine(layout, row));
  }
  return joinLines(lines);
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
    {
      columns: "animal_a12,raca_codigo,indice,created_at,updated_at",
      orderColumn: "id",
    },
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
        "id,id_rebanho_matriz,id_rebanho_reprodutor,data_inseminacao,data_inicial,data_final,tipo_reproducao,partida_semen,previsao_parto,inseminador,anotacoes,created_at,updated_at",
      orderColumn: "id",
    },
  );
  ctx.reproducaoRows = rows;

  // Grupo de manejo da matriz (via lote) — não obrigatório na cobertura
  // (call PAINT), exportado quando disponível.
  const grupoByDescricao = await loadGrupoByDescricao(ctx);
  const loteByReb = loteByRebanhoId(ctx);
  // Inseminador: reproducao guarda o nome; resolvemos para o código PAINT.
  const inseminadorByNome = await loadInseminadorByNome(ctx);

  // Fallback do A12 do touro: reprodutores externos/de sêmen sem data de
  // nascimento não têm A12 calculável (o A12 posicional depende do ano de
  // nascimento). Quando o codRegistro do reprodutor JÁ é um A12 do PAINT
  // (12 caracteres, ex.: "pPECA 458115"), usamos ele direto. Registros que não
  // são A12 (ex.: "PECA4581") ou vazios ficam em branco: sem a data de
  // nascimento, não há como montar um A12 válido apenas com o cadastro.
  const codRegByReb = new Map<string, string>();
  for (const a of (ctx.rebanhoRows ?? [])) {
    if (a.idRebanho != null) {
      codRegByReb.set(String(a.idRebanho), String(a.codRegistro ?? "").trim());
    }
  }

  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    const matrizA12 = ctx.a12ByRebanhoId.get(String(r.id_rebanho_matriz)) ?? "";
    let touroA12 = ctx.a12ByRebanhoId.get(String(r.id_rebanho_reprodutor)) ?? "";
    if (!touroA12) {
      const cr = codRegByReb.get(String(r.id_rebanho_reprodutor)) ?? "";
      if (cr.length === 12) touroA12 = cr; // codRegistro já é o A12 do PAINT
    }
    const grpMatriz = grupoManejoFromLote(
      loteByReb.get(String(r.id_rebanho_matriz)),
      grupoByDescricao,
    );
    lines.push(buildLine(layout, {
      cob_parceiro: ctx.config.codigo_transmissao,
      cob_safra_id: derivaSafraCodigo(r.data_inseminacao ?? r.data_inicial),
      cob_animal_id: matrizA12,
      cob_data: formatDate(r.data_inseminacao),
      cob_fazenda: ctx.config.codigo_fazenda,
      cob_tipo: mapTipoCobertura(r.tipo_reproducao),
      cob_periodo: "M",
      cob_touro: touroA12,
      // Categoria do TOURO (não da matriz). Touro de monta/IA → TT.
      cob_cat_touro: touroA12 ? "TT" : "",
      cob_doses: "",
      cob_partida: r.partida_semen ? String(r.partida_semen).slice(0, 6) : "",
      cob_inseminador: (inseminadorByNome.get(
        String(r.inseminador ?? "").trim().toUpperCase(),
      ) ?? "").slice(0, 4),
      cob_prevparto: formatDate(r.previsao_parto),
      cob_dtinirepasse: formatDate(r.data_inicial),
      cob_dtfimrepasse: formatDate(r.data_final),
      cob_obs: (r.anotacoes ?? "").toString().slice(0, 40),
      cob_local_id: "",
      cob_grpmanejo_id: grpMatriz,
      cob_data_inclusao: formatDate(r.created_at),
      cob_data_alteracao: formatDate(r.updated_at ?? r.created_at),
      cob_hora_alteracao: ctx.generationTime,
      cob_enviar: "True ",
      cob_recno: recno,
    }));
  }
  return joinLines(lines);
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
  // Resolver de pai usa o conjunto COMPLETO (rowsAll): pais de sêmen não têm
  // dataNascimento e ficam fora de `rows`, mas precisam ser encontrados aqui.
  const resolveParentA12 = makeParentA12Resolver(ctx, rowsAll);

  const grupoByDescricao = await loadGrupoByDescricao(ctx);

  // Cobertura por matriz (data da cobertura + previsão de parto). reproducaoRows
  // é limpo após COBERTURA, então re-consultamos enxuto.
  const reproRows = await selectAll<any>(
    ctx.supa,
    "reproducao",
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade).neq("deletado", "SIM"),
    { columns: "id_rebanho_matriz,data_inseminacao,data_inicial,previsao_parto", orderColumn: "id_rebanho_matriz" },
  );
  const coberturaByMatriz = new Map<string, any>();
  for (const c of reproRows) {
    const key = String(c.id_rebanho_matriz ?? "");
    if (key) coberturaByMatriz.set(key, c); // última cobertura da matriz
  }

  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    if (!r.rebanhoIdMatriz) continue;
    recno += 1;
    const a12Cria = ctx.a12ByRebanhoId.get(String(r.idRebanho)) ?? "";
    const matrizA12 = ctx.a12ByRebanhoId.get(String(r.rebanhoIdMatriz)) ?? "";
    const paiA12 = resolveParentA12(r.rebanhoIdReprodutor);
    const cob = coberturaByMatriz.get(String(r.rebanhoIdMatriz));
    lines.push(buildLine(layout, {
      nas_parceiro: ctx.config.codigo_transmissao,
      nas_safra_id: derivaSafraCodigo(r.dataNascimento),
      nas_animal_id: matrizA12,
      nas_data_cob: cob ? formatDate(cob.data_inseminacao ?? cob.data_inicial) : "",
      nas_seq: "1",
      nas_fazenda: ctx.config.codigo_fazenda,
      nas_seriefaz: resolveSerieA12(r, ctx.config),
      nas_programa: (ctx.config.programa ?? "P").toString().slice(0, 1),
      nas_animal: extractAnimal5(r.numeroAnimal),
      nas_tpparto: "NORMAL",
      nas_animal_produto_id: a12Cria,
      nas_sexo: String(r.sexo ?? "").slice(0, 1).toUpperCase(),
      nas_tipo: mapTipoRegistro(r),
      nas_peso: formatNumeric(r.pesoNascimento, 8, 2),
      nas_tamanho: "",
      nas_descri: (r.nome ?? "").toString().slice(0, 30),
      nas_brinco: extractBrinco5(r.numeroAnimal),
      nas_raca: mapRacaPaint(r.raca),
      nas_data_nasc: formatDate(r.dataNascimento),
      nas_rgn: "",
      nas_rgd: (r.codRegistro ?? "").toString().slice(0, 15),
      nas_pai: paiA12,
      nas_categoria: mapCategoriaPaint(r),
      nas_prevparto: cob ? formatDate(cob.previsao_parto) : "",
      nas_regime_alimentar: "",
      nas_grupo_manejo: grupoManejoFromLote(r.loteNome, grupoByDescricao),
      nas_local: "",
      nas_data_inclusao: formatDate(r.created_at),
      nas_data_alteracao: formatDate(r.updated_at ?? r.created_at),
      nas_hora_alteracao: ctx.generationTime,
      nas_prematuro: "False",
      nas_roubada: paiA12 ? "False" : "True ",
      nas_enviar: "True ",
      nas_atuprog: "False",
      nas_recno: recno,
    }));
  }
  return joinLines(lines);
}

// =============================================================================
// ESTOQUE — manual + call PAINT: gerar ESTOQUE.TXT sempre VAZIO (apenas o
// arquivo, sem conteúdo). O cadastro paint_estoque permanece no app, mas não é
// exportado até o PAINT solicitar.
// =============================================================================
async function genEstoque(_ctx: ExportContext): Promise<string> {
  return "";
}

// =============================================================================
// PARAMETROS — metadados da transmissão (sample 000460).
// =============================================================================
async function genParametros(ctx: ExportContext): Promise<string> {
  const layout = LAYOUTS.PARAMETROS;
  const row: Record<string, unknown> = {
    par_parceiro: ctx.config.codigo_transmissao,
    par_id_instalacao: "paintfazenda",
    par_chave: "inlida01",
    par_sep1: "  ",
    par_ip: "0.0.0.0       ",
    par_pad1: "",
    par_porta: "21",
    par_sep2: "  ",
    par_versao: "1.0.0   ",
    par_pad2: "",
    par_data_exportacao: ctx.generationDate,
    par_pad3: "",
    par_data_instalacao: formatDate(ctx.faz?.["created_at"] ?? ctx.generationDateTime),
    par_enviar: "False",
  };
  return joinLines([buildLine(layout, row)]);
}

// =============================================================================
// *_DELETE — registros em paint_registro_excluido (payload pré-montado).
// =============================================================================
async function genDelete(
  ctx: ExportContext,
  entidade: string,
): Promise<string> {
  const layout = LAYOUTS[entidade];
  if (!layout || layout.length === 0) return "";

  const { data: rows } = await ctx.supa
    .from("paint_registro_excluido")
    .select("id,payload")
    .eq("id_propriedade", ctx.config.id_propriedade)
    .eq("entidade", entidade)
    .is("exportado_em", null);

  const lines: string[] = [];
  for (const r of rows ?? []) {
    const payload = (r.payload ?? {}) as Record<string, unknown>;
    lines.push(buildLine(layout, payload));
  }
  return joinLines(lines);
}

// =============================================================================
// Helpers de geradores baseados em paint_* tables (mapeamento direto).
// =============================================================================
async function paintTableGenerator<T extends Record<string, unknown>>(
  ctx: ExportContext,
  layoutKey: keyof typeof LAYOUTS,
  table: string,
  mapper: (row: any, recno: number) => Record<string, unknown>,
  columns?: string,
): Promise<string> {
  const layout = LAYOUTS[layoutKey];
  const rows = await selectAll<any>(
    ctx.supa,
    table,
    (q) => q.eq("id_propriedade", ctx.config.id_propriedade),
    { orderColumn: "id", columns },
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
    bai_fazenda: fazendaField(ctx),
    bai_animal: r.animal_a12 ? String(r.animal_a12).trim().slice(-5) : "",
    bai_data_morte: formatDate(r.data_morte),
    bai_motivo: (r.motivo ?? "").toString().slice(0, 15),
    bai_preco: formatNumeric(r.preco ?? 0, 10, 2),
    bai_data_inclusao: formatDate(r.created_at),
    bai_obs: (r.obs ?? "").toString().slice(0, 40),
    bai_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    bai_hora_alteracao: ctx.generationTime,
    bai_enviar: "True ",
    bai_recno: recno,
    bai_reserva: "",
  }));
}

async function genDesmama(ctx: ExportContext): Promise<string> {
  const grupoByDescricao = await loadGrupoByDescricao(ctx);
  const loteA12 = loteNomeByA12(ctx);
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
    dsm_grupo_manejo: grupoManejoAvaliacao(r, loteA12, grupoByDescricao),
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
  const grupoByDescricao = await loadGrupoByDescricao(ctx);
  const loteA12 = loteNomeByA12(ctx);
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
    sbr_grupo_manejo: grupoManejoAvaliacao(r, loteA12, grupoByDescricao),
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
    rah_fazenda: fazendaField(ctx),
    rah_data: formatDate(r.data),
    rah_peso: formatNumeric(r.peso, 8, 2),
    rah_racial: formatNumeric(r.racial, 8, 2),
    rah_aprumos: formatNumeric(r.aprumos, 8, 2),
    rah_harmonia: formatNumeric(
      r.harmonia ?? r.frame ?? r.pigmentacao,
      8,
      2,
    ),
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
    dgn_resultado: r.resultado === "P" ? "P" : "V", // manual campo 008: P ou V
    dgn_obs: (r.obs ?? "").toString().slice(0, 40),
    dgn_data_inclusao: formatDate(r.created_at),
    dgn_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    dgn_hora_alteracao: ctx.generationTime,
    dgn_enviar: "True ",
    dgn_recno: recno,
  }), "safra_codigo,animal_a12,data,local_codigo,grupo_manejo_codigo,resultado,obs,created_at,updated_at");
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
    ins_fazenda: fazendaField(ctx),
    ins_situacao: r.situacao ?? "ATIVO",
    ins_data_inclusao: formatDate(r.created_at),
    ins_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    ins_hora_alteracao: ctx.generationTime,
    ins_enviar: "True ",
    ins_recno: recno,
    ins_tipo: "I",
  }));
}

async function genLocalidade(ctx: ExportContext): Promise<string> {
  return paintTableGenerator(ctx, "LOCALIDADE", "paint_localidade", (r, recno) => ({
    lde_parceiro: ctx.config.codigo_transmissao,
    lde_id: r.codigo,
    lde_descri: (r.descricao ?? "").toString().slice(0, 20),
    lde_fazenda: ctx.config.codigo_fazenda,
    lde_tipo: "", // manual campo 005: exportar em branco
    // Coordenadas para avaliação genética (call Juliana). O layout não tem
    // campos dedicados, então gravamos lat/long em lde_obs quando informados.
    lde_obs: localidadeObs(r),
    lde_data_inclusao: formatDate(r.created_at),
    lde_data_alteracao: formatDate(r.updated_at ?? r.created_at),
    lde_hora_alteracao: ctx.generationTime,
    lde_enviar: "True ",
    lde_recno: recno,
  }));
}

function localidadeObs(r: any): string {
  const lat = r.latitude;
  const lng = r.longitude;
  if (lat != null && lng != null) {
    const geo = `LAT:${Number(lat).toFixed(6)} LNG:${Number(lng).toFixed(6)}`;
    return geo.slice(0, 40);
  }
  return (r.obs ?? "").toString().slice(0, 40);
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
        {
          columns: "id,id_rebanho,data_pesagem,peso,created_at,updated_at",
          orderColumn: "id",
        },
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
      pes_safra_id: derivaSafraCodigo(r.data_pesagem ?? r.data),
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
  const rows = await selectAll<any>(
    ctx.supa,
    "paint_codigo_raca",
    (q) => q,
    { orderColumn: "codigo" },
  );
  const lines: string[] = [];
  let recno = 0;
  for (const r of rows) {
    recno += 1;
    const enviar = recno === 1 ? "False" : "False";
    lines.push(buildLine(layout, {
      rac_parceiro: ctx.config.codigo_transmissao,
      rac_codigo: r.codigo,
      rac_descricao: (r.descricao ?? "").toString().slice(0, 62),
      rac_gestacao_max: formatNumeric(r.gestacao_max ?? 0, 8, 2),
      rac_gestacao_med: formatNumeric(r.gestacao_med ?? 0, 8, 2),
      rac_gestacao_min: formatNumeric(r.gestacao_min ?? 0, 8, 2),
      // Manual §9: os números após a gestação são peso de nascimento médio de
      // fêmea (extra1) e macho (extra2) e idade mínima da novilha para entrar
      // em reprodução (extra3). Não relevante p/ avaliação (call PAINT); valores
      // padrão até o PAINT fornecer a tabela por raça.
      rac_extra1: formatNumeric(r.peso_nasc_femea ?? 0, 8, 2),
      rac_extra2: formatNumeric(r.peso_nasc_macho ?? 0, 8, 2),
      rac_extra3: formatNumeric(r.idade_min_novilha ?? 300, 8, 2),
      rac_pad: "",
      rac_data_inclusao: formatDate(r.created_at ?? "2005-04-27"),
      rac_data_alteracao: formatDate(r.updated_at ?? "2005-04-27"),
      rac_hora_alteracao: "11:36:57",
      rac_enviar: enviar,
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
  PARAMETROS: genParametros,
  ANIMAL_DELETE: (ctx) => genDelete(ctx, "ANIMAL"),
  ANO_SOBREANO_DELETE: (ctx) => genDelete(ctx, "ANO_SOBREANO"),
  BAIXA_DELETE: (ctx) => genDelete(ctx, "BAIXA"),
  COBERTURA_DELETE: (ctx) => genDelete(ctx, "COBERTURA"),
  COMPOSICAO_RACIAL_DELETE: (ctx) => genDelete(ctx, "COMPOSICAO_RACIAL"),
  DESMAMA_DELETE: (ctx) => genDelete(ctx, "DESMAMA"),
  DIAGNOSTICO_DELETE: (ctx) => genDelete(ctx, "DIAGNOSTICO"),
  ESTOQUE_DELETE: (ctx) => genDelete(ctx, "ESTOQUE"),
  FAZENDA_DELETE: (ctx) => genDelete(ctx, "FAZENDA"),
  GRUPO_MANEJO_DELETE: (ctx) => genDelete(ctx, "GRUPO_MANEJO"),
  NASCIMENTO_DELETE: (ctx) => genDelete(ctx, "NASCIMENTO"),
  SAFRA_DELETE: (ctx) => genDelete(ctx, "SAFRA"),
};

export { genUltimaTransmissao, genDelete };
