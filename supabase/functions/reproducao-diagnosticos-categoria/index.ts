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

// Aceita YYYY-M-D e YYYY-MM-DD -> normaliza para YYYY-MM-DD
function toDateStr(x: unknown): string | null {
  const s = String(x ?? "").trim();
  const m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
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
    const idPropriedade = url.searchParams.get("idPropriedade");
    const inicioRaw = url.searchParams.get("inicio");
    const fimRaw = url.searchParams.get("fim");
    const categoria = url.searchParams.get("categoria");

    if (!idPropriedade || idPropriedade.trim() === "") {
      return badRequest("Parâmetro obrigatório: 'idPropriedade'.");
    }
    if (!inicioRaw || !fimRaw) {
      return badRequest("Parâmetros obrigatórios: 'inicio' e 'fim' (YYYY-MM-DD).");
    }

    const inicio = toDateStr(inicioRaw);
    const fim = toDateStr(fimRaw);

    if (!inicio) return badRequest("inicio inválida. Use YYYY-MM-DD.");
    if (!fim) return badRequest("fim inválida. Use YYYY-MM-DD.");

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization") ?? "" },
        },
      },
    );

    // Prepara os parâmetros para a função SQL
    const rpcParams: any = {
      id_propriedade_param: idPropriedade,
      data_inicio_param: inicio,
      data_fim_param: fim,
      categoria_param: (categoria && categoria.trim() !== "" && categoria.trim() !== "Todos") 
        ? categoria.trim() 
        : null,
    };

    // Usa a nova função que agrupa mensalmente
    const { data, error } = await supabaseClient.rpc("get_diagnosticos_por_categoria_mensal", rpcParams);

    if (error) {
      console.error("Erro RPC:", error);
      return new Response(JSON.stringify({ ok: false, error: `Erro no cálculo do banco: ${error.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const items = (data ?? []).map((r: any) => ({
      periodo: String(r.mes ?? ""),
      label: String(r.label ?? ""),
      Novilha: Number(r.Novilha ?? 0),
      "Primípara": Number(r["Primípara"] ?? 0),
      "Multípara": Number(r["Multípara"] ?? 0),
    }));

    return new Response(JSON.stringify({ ok: true, items }), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (e: any) {
    console.error("Erro geral:", e);
    return new Response(JSON.stringify({ ok: false, error: `Erro interno: ${e?.message ?? String(e)}` }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});