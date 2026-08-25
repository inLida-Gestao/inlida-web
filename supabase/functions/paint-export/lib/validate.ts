// Pré-validação da exportação PAINT (Fase 4 do plano).
//
// NÃO bloqueia a exportação — o PAINT recebe todos os dados (call 03/06). O
// relatório é gravado em paint_export_job.validacao como checklist para a
// equipe revisar antes de enviar ao Gencis.
//
// Erros = pendências que o consistência do PAINT provavelmente rejeitará.
// Avisos = fora das janelas recomendadas (manual operacional), mas aceitável.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { selectAll } from "./sql.ts";
import {
  a12DoCodRegistro,
  a12FromRebanho,
  exigeA12DoCodRegistro,
  isAnimalPO,
} from "./paint_mappers.ts";
import type { PaintConfig } from "./generators.ts";

export interface ValidacaoItem {
  tabela: string;
  regra: string;
  qtd: number;
  exemplos: string[];
}

export interface ValidacaoReport {
  erros: ValidacaoItem[];
  avisos: ValidacaoItem[];
  geradoEm: string;
}

function item(tabela: string, regra: string): ValidacaoItem {
  return { tabela, regra, qtd: 0, exemplos: [] };
}

function add(it: ValidacaoItem, exemplo: string) {
  it.qtd += 1;
  if (it.exemplos.length < 10) it.exemplos.push(exemplo);
}

export interface ValidatePaintExportOptions {
  /** Evita segunda consulta paginada ao rebanho (já carregado no export). */
  rebanhoRows?: Record<string, unknown>[];
  /** Omite checagens pesadas quando o volume é alto (ex.: composição racial). */
  skipHeavyChecks?: boolean;
}

export async function validatePaintExport(
  supa: SupabaseClient,
  config: PaintConfig,
  options?: ValidatePaintExportOptions,
): Promise<ValidacaoReport> {
  const idProp = config.id_propriedade;
  const erros: ValidacaoItem[] = [];
  const avisos: ValidacaoItem[] = [];

  // -------------------------------------------------------------------------
  // ANIMAL — PO precisa de tipo/brinco/raça; raça obrigatória para todos.
  // -------------------------------------------------------------------------
  const rebanho = options?.rebanhoRows ?? await selectAll<any>(
    supa,
    "rebanho",
    (q) => q.eq("idPropriedade", idProp).neq("deletado", "SIM"),
    {
      columns:
        "idRebanho,numeroAnimal,nome,raca,tipo_registro,status,origem,codRegistro," +
        "dataDesmama,dataNascimento,sexo,dataVenda,data_morte," +
        "rebanhoIdMatriz,rebanhoIdReprodutor",
      orderColumn: "idRebanho",
    },
  );

  // Brinco numérico é obrigatório para todos os animais (PO e não-PO): é a base
  // do segmento Animal do A12 (call PAINT). Tipo de registro é obrigatório para
  // PO; quando não há valor explícito (apenas inferido pela raça), gera aviso.
  const semBrinco = item("ANIMAL", "Animal sem brinco numérico (5 dígitos)");
  const semRaca = item("ANIMAL", "Animal sem raça");
  const poSemTipo = item(
    "ANIMAL",
    "Animal PO sem tipo de registro definido (inferido pela raça)",
  );
  for (const r of rebanho) {
    const brincoDigits = String(r.numeroAnimal ?? "").replace(/\D/g, "");
    if (brincoDigits.length === 0) {
      add(semBrinco, String(r.numeroAnimal ?? r.idRebanho));
    }
    if (!String(r.raca ?? "").trim()) add(semRaca, String(r.numeroAnimal ?? r.idRebanho));
    if (isAnimalPO(r) && !String(r.tipo_registro ?? "").trim()) {
      add(poSemTipo, String(r.numeroAnimal ?? r.idRebanho));
    }
  }
  if (semBrinco.qtd) erros.push(semBrinco);
  if (semRaca.qtd) erros.push(semRaca);
  if (poSemTipo.qtd) avisos.push(poSemTipo);

  // -------------------------------------------------------------------------
  // A12 vindo do código de registro (sêmen / origem "Compra"). Nesses casos a
  // geração automática é bloqueada de propósito: o animal já tem A12 na fazenda
  // de origem. Se o código de registro não estiver no formato A12, o animal sai
  // SEM A12 e some das referências — em silêncio, até aqui.
  // -------------------------------------------------------------------------
  const semA12Registro = item(
    "ANIMAL",
    'A12 deve vir do código de registro (sêmen ou origem "Compra"), ' +
      "mas o código cadastrado não está no formato A12 de 12 posições",
  );
  const a12PorRebanho = new Map<string, string>();
  for (const r of rebanho) {
    const id = String(r.idRebanho ?? "").trim();
    if (!exigeA12DoCodRegistro(r)) continue;
    const a12 = a12DoCodRegistro(r);
    if (id) a12PorRebanho.set(id, a12);
    if (!a12) {
      const cr = String(r.codRegistro ?? "").trim();
      add(
        semA12Registro,
        `${r.numeroAnimal ?? r.idRebanho} (${cr || "sem código de registro"})`,
      );
    }
  }
  if (semA12Registro.qtd) avisos.push(semA12Registro);

  // -------------------------------------------------------------------------
  // Pai/mãe que não resolvem para um A12: o campo sai em branco no ANIMAL.TXT e
  // no NASCIMENTO.TXT, e o PAINT perde a genealogia sem nenhum sinal. Conta por
  // PAI/MÃE distinto (não por filho) — um reprodutor errado afeta centenas.
  // -------------------------------------------------------------------------
  const paiSemA12 = item(
    "ANIMAL",
    "Pai/mãe referenciado que não resolve para um A12 (genealogia sai em branco)",
  );
  const filhosPorParente = new Map<string, number>();
  for (const r of rebanho) {
    for (const campo of ["rebanhoIdReprodutor", "rebanhoIdMatriz"]) {
      const id = String((r as Record<string, unknown>)[campo] ?? "").trim();
      if (id) filhosPorParente.set(id, (filhosPorParente.get(id) ?? 0) + 1);
    }
  }
  const rebanhoPorId = new Map<string, any>();
  for (const r of rebanho) {
    const id = String(r.idRebanho ?? "").trim();
    if (id) rebanhoPorId.set(id, r);
  }
  for (const [id, filhos] of filhosPorParente) {
    const parente = rebanhoPorId.get(id);
    // Pai fora do rebanho carregado (deletado) — não dá para avaliar aqui.
    if (!parente) continue;
    const a12 = a12PorRebanho.get(id) ?? a12FromRebanho(config, parente);
    if (a12) continue;
    const cr = String(parente.codRegistro ?? "").trim();
    const nome = String(parente.nome ?? "").trim();
    const quem = nome ? `${parente.numeroAnimal ?? id} (${nome})` : `${parente.numeroAnimal ?? id}`;
    add(
      paiSemA12,
      `${quem} — ${filhos} filho(s), código de registro "${cr || "vazio"}"`,
    );
  }
  if (paiSemA12.qtd) avisos.push(paiSemA12);

  // -------------------------------------------------------------------------
  // DESMAMA — obrigatórios A12, data, peso, C/P/M/U, grupo de manejo.
  // Aviso quando fora de 150–310 dias.
  // -------------------------------------------------------------------------
  const desmamas = await selectAll<any>(
    supa,
    "paint_avaliacao_desmama",
    (q) => q.eq("id_propriedade", idProp),
    { orderColumn: "id" },
  );
  const desmamaIncompleta = item(
    "DESMAMA",
    "Avaliação sem peso, nota (C/P/M/U) ou grupo de manejo",
  );
  const a12ComDesmama = new Set<string>();
  for (const d of desmamas) {
    a12ComDesmama.add(String(d.animal_a12 ?? "").trim());
    const falta = d.peso == null || d.nota_c == null || d.nota_p == null ||
      d.nota_m == null || d.nota_u == null ||
      !String(d.grupo_manejo_codigo ?? "").trim();
    if (falta) add(desmamaIncompleta, String(d.animal_a12 ?? ""));
  }
  if (desmamaIncompleta.qtd) erros.push(desmamaIncompleta);

  // -------------------------------------------------------------------------
  // ANO_SOBREANO — exige desmama prévia (manual §8.3).
  // -------------------------------------------------------------------------
  const sobreanos = await selectAll<any>(
    supa,
    "paint_avaliacao_sobreano",
    (q) => q.eq("id_propriedade", idProp),
    { orderColumn: "id" },
  );
  const sobreanoSemDesmama = item(
    "ANO_SOBREANO",
    "Sobreano sem avaliação de desmama prévia (manual §8.3)",
  );
  for (const s of sobreanos) {
    const a12 = String(s.animal_a12 ?? "").trim();
    if (!a12ComDesmama.has(a12)) add(sobreanoSemDesmama, a12);
  }
  if (sobreanoSemDesmama.qtd) erros.push(sobreanoSemDesmama);

  // -------------------------------------------------------------------------
  // COBERTURA — monta/repasse precisa de datas de início/fim de repasse.
  // -------------------------------------------------------------------------
  const reproducao = await selectAll<any>(
    supa,
    "reproducao",
    (q) => q.eq("id_propriedade", idProp).neq("deletado", "SIM"),
    {
      columns: "id,tipo_reproducao,data_inicial,data_final,data_inseminacao",
      orderColumn: "id",
    },
  );
  const montaSemRepasse = item(
    "COBERTURA",
    "Monta/repasse sem data de início ou fim de repasse",
  );
  for (const c of reproducao) {
    const tipo = String(c.tipo_reproducao ?? "").toUpperCase();
    const ehMonta = tipo.includes("MONTA") || tipo.includes("REPASSE") || tipo.includes("NATURAL");
    if (ehMonta && (!c.data_inicial || !c.data_final)) {
      add(montaSemRepasse, String(c.id));
    }
  }
  if (montaSemRepasse.qtd) erros.push(montaSemRepasse);

  // -------------------------------------------------------------------------
  // BAIXA — vendidos/mortos devem ter registro de baixa.
  // -------------------------------------------------------------------------
  const baixas = await selectAll<any>(
    supa,
    "paint_baixa",
    (q) => q.eq("id_propriedade", idProp),
    { columns: "animal_a12", orderColumn: "id" },
  );
  const a12ComBaixa = new Set(baixas.map((b) => String(b.animal_a12 ?? "").trim()));
  const baixaFaltando = item("BAIXA", "Vendido/morto sem registro de baixa");
  // Sem A12 calculado aqui; usamos contagem por status apenas como aviso.
  let vendidosMortos = 0;
  for (const r of rebanho) {
    const st = String(r.status ?? "").toUpperCase();
    if (st === "VENDIDO" || st === "MORTO" || r.dataVenda || r.data_morte) {
      vendidosMortos += 1;
    }
  }
  if (vendidosMortos > a12ComBaixa.size) {
    baixaFaltando.qtd = vendidosMortos - a12ComBaixa.size;
    avisos.push(baixaFaltando);
  }

  // -------------------------------------------------------------------------
  // COMPOSICAO_RACIAL — soma dos índices por animal deve ser 1.0 (manual §8.2).
  // Em propriedades grandes, omitimos a varredura completa (muito CPU/RAM).
  // -------------------------------------------------------------------------
  if (!options?.skipHeavyChecks) {
    const comps = await selectAll<any>(
      supa,
      "paint_composicao_racial",
      (q) => q.eq("id_propriedade", idProp),
      { columns: "animal_a12,indice", orderColumn: "id" },
    );
    const somaPorAnimal = new Map<string, number>();
    for (const c of comps) {
      const k = String(c.animal_a12 ?? "").trim();
      somaPorAnimal.set(k, (somaPorAnimal.get(k) ?? 0) + Number(c.indice ?? 0));
    }
    const compInvalida = item("COMPOSICAO_RACIAL", "Soma das frações ≠ 1.0");
    for (const [a12, soma] of somaPorAnimal) {
      if (Math.abs(soma - 1) > 0.0001) add(compInvalida, `${a12} (${soma.toFixed(4)})`);
    }
    if (compInvalida.qtd) erros.push(compInvalida);
  } else {
    avisos.push({
      tabela: "COMPOSICAO_RACIAL",
      regra: "Validação detalhada omitida (volume alto na propriedade)",
      qtd: 0,
      exemplos: [],
    });
  }

  return {
    erros,
    avisos,
    geradoEm: new Date().toISOString(),
  };
}
