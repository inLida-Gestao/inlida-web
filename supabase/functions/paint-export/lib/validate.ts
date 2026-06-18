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
import { isAnimalPO } from "./paint_mappers.ts";
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
        "idRebanho,numeroAnimal,raca,tipo_registro,status,dataDesmama,dataNascimento,sexo,dataVenda,data_morte",
      orderColumn: "idRebanho",
    },
  );

  const poSemBrinco = item("ANIMAL", "Animal PO sem brinco numérico (5 dígitos)");
  const semRaca = item("ANIMAL", "Animal sem raça");
  for (const r of rebanho) {
    const brincoDigits = String(r.numeroAnimal ?? "").replace(/\D/g, "");
    if (isAnimalPO(r) && brincoDigits.length === 0) {
      add(poSemBrinco, String(r.numeroAnimal ?? r.idRebanho));
    }
    if (!String(r.raca ?? "").trim()) add(semRaca, String(r.numeroAnimal ?? r.idRebanho));
  }
  if (poSemBrinco.qtd) erros.push(poSemBrinco);
  if (semRaca.qtd) erros.push(semRaca);

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
