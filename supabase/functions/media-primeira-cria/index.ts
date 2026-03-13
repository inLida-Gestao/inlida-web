import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

function toDateStr(x: unknown): string | null {
  const s = String(x ?? "").trim();
  if (!s) return null;

  const m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (!m) return null;

  const y = Number(m[1]);
  const mo = Number(m[2]);
  const d = Number(m[3]);

  if (!Number.isInteger(y) || !Number.isInteger(mo) || !Number.isInteger(d)) return null;
  if (mo < 1 || mo > 12) return null;
  if (d < 1 || d > 31) return null;

  return `${y}-${String(mo).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
}

serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return new Response(
      JSON.stringify({ ok: false, error: "Método não permitido. Use GET." }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 405 },
    );
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
      },
    );

    const url = new URL(req.url);
    const id_propriedade = url.searchParams.get("id_propriedade");

    // opcional, mas normalizado
    const data_inicio_raw = url.searchParams.get("data_inicio");
    const data_fim_raw = url.searchParams.get("data_fim");
    const data_inicio = data_inicio_raw ? toDateStr(data_inicio_raw) : null;
    const data_fim = data_fim_raw ? toDateStr(data_fim_raw) : null;

    if (!id_propriedade || id_propriedade.trim() === "") {
      return new Response(
        JSON.stringify({ ok: false, error: "O parâmetro id_propriedade é obrigatório na URL." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 },
      );
    }

    // Se o usuário enviou data_inicio/data_fim, valida formato
    if (data_inicio_raw && !data_inicio) {
      return new Response(
        JSON.stringify({ ok: false, error: "data_inicio inválida. Use YYYY-MM-DD." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 },
      );
    }
    if (data_fim_raw && !data_fim) {
      return new Response(
        JSON.stringify({ ok: false, error: "data_fim inválida. Use YYYY-MM-DD." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 },
      );
    }

    const { data, error } = await supabaseClient.rpc("calculate_media_primeira_cria", {
      p_id_propriedade: id_propriedade,
      p_data_inicio: data_inicio,
      p_data_fim: data_fim,
    });

    if (error) {
      return new Response(JSON.stringify({ ok: false, error: error.message }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      });
    }

    const result = (data ?? [])[0];
    return new Response(
      JSON.stringify({
        ok: true,
        items: [
          {
            valor: Number(result?.valor_medio ?? 0),
            n: Number(result?.total_matrizes ?? 0),
          },
        ],
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 },
    );
  } catch (error: any) {
    return new Response(JSON.stringify({ ok: false, error: error?.message ?? "Internal Error" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
