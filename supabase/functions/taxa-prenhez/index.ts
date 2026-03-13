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

    // ✅ nomes exatamente como FlutterFlow envia
    const id_propriedade = url.searchParams.get("id_propriedade");
    const data_inicio_raw = url.searchParams.get("data_inicio");
    const data_fim_raw = url.searchParams.get("data_fim");
    
    // ✅ Filtros opcionais
    const p_lote_id = url.searchParams.get("p_lote_id") ?? "";
    const p_inseminador = url.searchParams.get("p_inseminador") ?? "";
    const p_id_rebanho_reprodutor = url.searchParams.get("p_id_rebanho_reprodutor") ?? "";

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

    // ✅ Passar todos os parâmetros para a função SQL, incluindo os filtros opcionais
    const { data, error } = await supabaseClient.rpc("calcular_taxa_prenhez", {
      id_propriedade_param: id_propriedade,
      data_inicio_param: data_inicio,
      data_fim_param: data_fim,
      p_lote_id: p_lote_id.trim() || "",
      p_inseminador: p_inseminador.trim() || "",
      p_id_rebanho_reprodutor: p_id_rebanho_reprodutor.trim() || "",
    });

    if (error) {
      return new Response(JSON.stringify({ ok: false, error: `Erro no cálculo do banco: ${error.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    // ✅ Converter porcentagem de 0-100 para 0-1 (decimal) conforme esperado pelo widget
    // A função SQL retorna porcentagem como 15.79 (15.79%)
    // O widget TaxaPrenhezChart espera 0.1579 (decimal entre 0 e 1)
    const items = (data ?? []).map((r: any) => {
      const porcentagemNum = Number(r.porcentagem ?? 0);
      return {
        titulo: String(r.titulo ?? ""),
        porcentagem: porcentagemNum / 100.0, // Converte de percentual para decimal
      };
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