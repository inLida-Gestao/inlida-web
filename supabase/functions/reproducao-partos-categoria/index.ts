import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.44.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

function toDateStr(x: string | null): string | null {
  if (!x) return null;
  const m = x.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (!m) return null;
  return `${m[1]}-${m[2].padStart(2, "0")}-${m[3].padStart(2, "0")}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "GET") {
    return new Response(
      JSON.stringify({ ok: false, error: "Método não permitido. Use GET." }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    const url = new URL(req.url);
    const inicioRaw = url.searchParams.get("inicio");
    const fimRaw = url.searchParams.get("fim");
    const idPropriedade = url.searchParams.get("idPropriedade");

    const inicio = toDateStr(inicioRaw);
    const fim = toDateStr(fimRaw);

    if (!inicio || !fim || !idPropriedade) {
      return new Response(
        JSON.stringify({
          ok: false,
          error: 'Parâmetros obrigatórios: "inicio", "fim" (YYYY-MM-DD) e "idPropriedade".'
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization") ?? "" },
        },
      }
    );

    const { data, error } = await supabaseClient.rpc(
      "get_births_by_category_data",
      {
        id_propriedade_param: idPropriedade,
        inicio_param: inicio,
        fim_param: fim,
      }
    );

    if (error) {
      return new Response(
        JSON.stringify({ ok: false, error: error.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const items = (data ?? []).map((item: any) => ({
      mes: item.mes,
      label: item.label,
      Novilha: Number(item.Novilha ?? 0),
      Primípara: Number(item["Primípara"] ?? 0),
      Multípara: Number(item["Multípara"] ?? 0),
    }));

    return new Response(
      JSON.stringify({ ok: true, items }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ ok: false, error: "Erro interno do servidor." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
