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
    const mesParam = url.searchParams.get("mes");
    const anoParam = url.searchParams.get("ano");

    if (!idPropriedade || idPropriedade.trim() === "") {
      return badRequest("Parâmetro obrigatório: 'idPropriedade'.");
    }
    if (!mesParam || !anoParam) {
      return badRequest("Parâmetros obrigatórios: 'mes' (1-12) e 'ano'.");
    }

    const mes = Number(mesParam);
    const ano = Number(anoParam);

    if (isNaN(mes) || mes < 1 || mes > 12) {
      return badRequest("mes deve ser um número entre 1 e 12.");
    }
    if (isNaN(ano) || ano < 1900 || ano > 2100) {
      return badRequest("ano inválido.");
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization") ?? "" },
        },
      },
    );

    const { data, error } = await supabaseClient.rpc("get_diagnosticos_periodo", {
      id_propriedade_param: idPropriedade,
      mes_param: mes,
      ano_param: ano,
    });

    if (error) {
      return new Response(JSON.stringify({ ok: false, error: `Erro no cálculo do banco: ${error.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const items = (data ?? []).map((r: any) => ({
      situacao: String(r.situacao ?? ""),
      total: Number(r.total ?? 0),
      porcentagem: Number(r.porcentagem ?? 0),
    }));

    return new Response(JSON.stringify({ ok: true, items }), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch {
    return new Response(JSON.stringify({ ok: false, error: "Erro interno do servidor." }), {
      status: 500,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  }
});
