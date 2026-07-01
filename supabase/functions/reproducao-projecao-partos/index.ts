// Edge: projeção de partos por categoria (painel).
// Agrega no Deno — não depende da RPC get_projected_births_by_category_data no Postgres.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.44.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function toDateStr(x: string | null): string | null {
  if (!x) return null;
  const m = x.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (!m) return null;
  return `${m[1]}-${m[2].padStart(2, "0")}-${m[3].padStart(2, "0")}`;
}

function bucketMonthFromPrevisao(s: unknown): string | null {
  if (s == null) return null;
  const d = String(s).slice(0, 10);
  const m = d.match(/^(\d{4})-(\d{2})/);
  if (!m) return null;
  return `${m[1]}-${m[2]}-01`;
}

function dateStrFromValue(s: unknown): string | null {
  if (s == null) return null;
  const d = String(s).slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(d) ? d : null;
}

function dataReproducaoFromRow(r: Record<string, unknown>): string | null {
  return dateStrFromValue(r.data_inseminacao) ?? dateStrFromValue(r.data_inicial);
}

function classify(
  cat: string | null | undefined,
): "novilha" | "prim" | "multi" | "none" {
  const c = (cat ?? "").toLowerCase().trim();
  if (c.startsWith("novilha")) return "novilha";
  if (c.startsWith("vaca primipara") || c.startsWith("vaca primípara")) {
    return "prim";
  }
  if (c.startsWith("vaca multipara") || c.startsWith("vaca multípara")) {
    return "multi";
  }
  return "none";
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

type Agg = { Novilha: number; "Primípara": number; "Multípara": number };

async function buildProjecaoItems(
  supabase: SupabaseClient,
  idPropriedade: string,
  inicio: string,
  fim: string,
  tipoReproducao: string | null,
): Promise<
  { mes: string; label: string; Novilha: number; Primípara: number; Multípara: number }[]
> {
  const PAGE = 1000;
  let from = 0;
  const reproAll: Record<string, unknown>[] = [];

  for (;;) {
    let query = supabase
      .from("reproducao")
      .select(
        "previsao_parto, data_inseminacao, data_inicial, id_rebanho_matriz, deletado, ressinc, tipo_reproducao",
      )
      .eq("id_propriedade", idPropriedade)
      .or(
        [
          `and(data_inseminacao.gte.${inicio}T00:00:00.000Z,data_inseminacao.lte.${fim}T23:59:59.999Z)`,
          `and(data_inseminacao.is.null,data_inicial.gte.${inicio}T00:00:00.000Z,data_inicial.lte.${fim}T23:59:59.999Z)`,
        ].join(","),
      );

    // Filtro opcional por tipo de reprodução (ex.: "Monta Natural").
    if (tipoReproducao) {
      query = query.eq("tipo_reproducao", tipoReproducao);
    }

    const { data, error } = await query.range(from, from + PAGE - 1);

    if (error) throw error;
    const rows = data ?? [];
    reproAll.push(...rows);
    if (rows.length < PAGE) break;
    from += PAGE;
  }

  const filtered = reproAll.filter((r) => {
    const del = r.deletado as string | null | undefined;
    const rs = r.ressinc as string | null | undefined;
    if (del === "SIM") return false;
    if (rs === "SIM") return false;
    if (r.previsao_parto == null) return false;

    const dataReproducao = dataReproducaoFromRow(r);
    return dataReproducao != null && dataReproducao >= inicio && dataReproducao <= fim;
  });

  const monthKeys = [
    ...new Set(
      filtered
        .map((r) => bucketMonthFromPrevisao(r.previsao_parto))
        .filter((x): x is string => x != null),
    ),
  ].sort();

  const agg = new Map<string, Agg>();
  for (const mk of monthKeys) {
    agg.set(mk, { Novilha: 0, "Primípara": 0, "Multípara": 0 });
  }

  const rawIds = filtered
    .map((r) => r.id_rebanho_matriz as string | null | undefined)
    .filter((x): x is string => x != null && String(x).trim() !== "");

  const ids = [...new Set(rawIds.map((x) => String(x).trim()))];

  const catByMatriz = new Map<string, string>();

  for (const part of chunk(ids, 120)) {
    const { data: rows1, error: e1 } = await supabase
      .from("rebanho")
      .select("idRebanho, id, categoria, deletado, idPropriedade")
      .in("idRebanho", part)
      .eq("deletado", "NAO")
      .eq("idPropriedade", idPropriedade);

    if (!e1 && rows1) {
      for (const row of rows1 as Record<string, unknown>[]) {
        const idR = row.idRebanho != null ? String(row.idRebanho) : "";
        if (idR) catByMatriz.set(idR, String(row.categoria ?? ""));
      }
    }

    const numericOnly = part.filter((x) => /^\d+$/.test(x));
    if (numericOnly.length === 0) continue;

    const { data: rows2, error: e2 } = await supabase
      .from("rebanho")
      .select("idRebanho, id, categoria, deletado, idPropriedade")
      .in(
        "id",
        numericOnly.map((x) => parseInt(x, 10)),
      )
      .eq("deletado", "NAO")
      .eq("idPropriedade", idPropriedade);

    if (!e2 && rows2) {
      for (const row of rows2 as Record<string, unknown>[]) {
        const idR = row.idRebanho != null ? String(row.idRebanho) : "";
        const idNum = row.id != null ? String(row.id) : "";
        const cat = String(row.categoria ?? "");
        if (idR && !catByMatriz.has(idR)) catByMatriz.set(idR, cat);
        if (idNum) catByMatriz.set(idNum, cat);
      }
    }
  }

  for (const r of filtered) {
    const mk = bucketMonthFromPrevisao(r.previsao_parto);
    if (!mk || !agg.has(mk)) continue;

    const mid = r.id_rebanho_matriz != null
      ? String(r.id_rebanho_matriz).trim()
      : "";
    let categoria = mid ? (catByMatriz.get(mid) ?? "") : "";
    if (!categoria && mid && /^\d+$/.test(mid)) {
      categoria = catByMatriz.get(mid) ?? "";
    }

    const slot = agg.get(mk)!;
    const kind = classify(categoria);
    if (kind === "novilha") slot.Novilha++;
    else if (kind === "prim") slot["Primípara"]++;
    else if (kind === "multi") slot["Multípara"]++;
    else {
      // Matriz sem categoria reconhecida: contar como multípara (vaca em lactação típica)
      slot["Multípara"]++;
    }
  }

  return monthKeys.map((mk) => {
    const s = agg.get(mk)!;
    const y = parseInt(mk.slice(0, 4), 10);
    const mo = parseInt(mk.slice(5, 7), 10);
    const label = `${String(mo).padStart(2, "0")}/${y}`;
    return {
      mes: mk,
      label,
      Novilha: s.Novilha,
      "Primípara": s["Primípara"],
      "Multípara": s["Multípara"],
    };
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return new Response(
      JSON.stringify({ ok: false, error: "Método não permitido. Use GET." }),
      {
        status: 405,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      },
    );
  }

  try {
    const auth = req.headers.get("Authorization") ?? "";
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: auth } } },
    );

    const url = new URL(req.url);
    const inicio = toDateStr(url.searchParams.get("inicio"));
    const fim = toDateStr(url.searchParams.get("fim"));
    const idPropriedade = url.searchParams.get("idPropriedade");
    const tipoReproducaoRaw = url.searchParams.get("tipoReproducao");
    const tipoReproducao = tipoReproducaoRaw && tipoReproducaoRaw.trim() !== ""
      ? tipoReproducaoRaw.trim()
      : null;

    if (!inicio || !fim || !idPropriedade) {
      return new Response(
        JSON.stringify({
          ok: false,
          error:
            'Parâmetros obrigatórios: "inicio", "fim" (YYYY-MM-DD) e "idPropriedade".',
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json", ...corsHeaders },
        },
      );
    }

    const items = await buildProjecaoItems(
      supabaseClient,
      idPropriedade,
      inicio,
      fim,
      tipoReproducao,
    );

    return new Response(JSON.stringify({ ok: true, items }), {
      status: 200,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    console.error("reproducao-projecao-partos:", msg);
    return new Response(
      JSON.stringify({ ok: false, error: msg }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      },
    );
  }
});
