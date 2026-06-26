import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function badRequest(msg: string) {
  return new Response(JSON.stringify({ ok: false, error: msg }), {
    status: 400,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function toDateStr(x: unknown): string | null {
  let s = String(x ?? "").trim();
  if (!s) return null;
  if (s.includes("T")) s = s.split("T")[0] ?? s;
  else if (s.includes(" ")) s = s.split(" ")[0] ?? s;
  const m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})/);
  if (!m) return null;

  const y = Number(m[1]);
  const mo = Number(m[2]);
  const d = Number(m[3]);

  if (mo < 1 || mo > 12) return null;
  if (d < 1 || d > 31) return null;

  return `${y}-${String(mo).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });

  if (req.method !== "GET") {
    return new Response(JSON.stringify({ ok: false, error: "Método não permitido. Use GET." }), {
      status: 405,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }

  try {
    const url = new URL(req.url);

    const id_propriedade = url.searchParams.get("id_propriedade");
    const data_inicio_raw = url.searchParams.get("data_inicio");
    const data_fim_raw = url.searchParams.get("data_fim");

    const p_lote_id = url.searchParams.get("p_lote_id") ?? "";
    const p_inseminador = url.searchParams.get("p_inseminador") ?? "";
    const p_id_rebanho_reprodutor = url.searchParams.get("p_id_rebanho_reprodutor") ?? "";
    const p_tipo_reproducao = url.searchParams.get("p_tipo_reproducao") ?? "";

    if (!id_propriedade || id_propriedade.trim() === "") {
      return badRequest("Parâmetro obrigatório: 'id_propriedade'.");
    }
    if (!data_inicio_raw || !data_fim_raw) {
      return badRequest("Parâmetros obrigatórios: 'data_inicio' e 'data_fim' (YYYY-MM-DD).");
    }

    const data_inicio = toDateStr(data_inicio_raw);
    const data_fim = toDateStr(data_fim_raw);

    if (!data_inicio) return badRequest("data_inicio inválida. Use YYYY-MM-DD.");
    if (!data_fim) return badRequest("data_fim inválida. Use YYYY-MM-DD.");

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization") ?? "" },
        },
      },
    );

    const { data, error } = await supabaseClient.rpc("calcular_taxa_prenhez2", {
      id_propriedade_param: id_propriedade,
      data_inicio_param: data_inicio,
      data_fim_param: data_fim,
      p_lote_id: p_lote_id.trim() || "",
      p_inseminador: p_inseminador.trim() || "",
      p_id_rebanho_reprodutor: p_id_rebanho_reprodutor.trim() || "",
      p_tipo_reproducao: p_tipo_reproducao.trim() || "",
    });

    if (error) {
      return new Response(JSON.stringify({ ok: false, error: `Erro no cálculo do banco: ${error.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const pickInt = (row: any, keys: string[]): number | undefined => {
      for (const k of keys) {
        const v = row[k];
        if (v == null || v === "") continue;
        const n = Number(v);
        if (!Number.isNaN(n)) return Math.trunc(n);
      }
      return undefined;
    };

    const items = (data ?? []).map((r: any) => {
      const porcentagemNum = Number(r.porcentagem ?? 0);
      const total_prenhe = pickInt(r, [
        "total_prenhe",
        "totalPrenhe",
        "prenhe",
        "qtd_prenhe",
        "matrizes_prenhes",
        "prenhez",
      ]);
      const total_expostas = pickInt(r, [
        "total_expostas",
        "totalExpostas",
        "total_inseminadas",
        "totalInseminadas",
        "inseminadas",
        "qtd_inseminadas",
        "matrizes_inseminadas",
        "total_matrizes",
      ]);
      const out: Record<string, unknown> = {
        titulo: String(r.titulo ?? ""),
        porcentagem: porcentagemNum / 100.0,
      };
      if (total_prenhe !== undefined) out.total_prenhe = total_prenhe;
      if (total_expostas !== undefined) {
        out.total_expostas = total_expostas;
        out.total_inseminadas = total_expostas;
      }
      return out;
    });

    return new Response(JSON.stringify({ ok: true, items }), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: `Erro interno do servidor: ${e}` }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});
