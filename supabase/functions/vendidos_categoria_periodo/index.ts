import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, x-client-info, apikey",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

function badRequest(msg: string) {
  return new Response(JSON.stringify({ error: msg }), {
    status: 400, headers: { "content-type": "application/json", ...CORS },
  });
}
function toDateStr(x: unknown): string | null {
  if (!x) return null;
  try {
    const d = new Date(String(x));
    if (isNaN(d.getTime())) return null;
    const mm = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return `${d.getFullYear()}-${mm}-${dd}`;
  } catch { return null; }
}
function endOfMonth(ymd: string) {
  const d = new Date(`${ymd}T00:00:00Z`);
  const last = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + 1, 0));
  const mm = String(last.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(last.getUTCDate()).padStart(2, "0");
  return `${last.getUTCFullYear()}-${mm}-${dd}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  try {
    let inicio: string | null = null;
    let fim: string | null = null;
    let idPropriedade: string | null = null;
    let dias = 3;
    let agrupar = "bucket";

    if (req.method === "GET") {
      const url = new URL(req.url);
      inicio = toDateStr(url.searchParams.get("inicio"));
      fim = toDateStr(url.searchParams.get("fim"));
      idPropriedade = url.searchParams.get("idPropriedade");
      const d = url.searchParams.get("dias");
      if (d) dias = Math.max(1, parseInt(d, 10) || 3);
      agrupar = (url.searchParams.get("agrupar") ?? "bucket").toLowerCase();
    } else {
      const b = await req.json().catch(() => ({}));
      inicio = toDateStr(b?.inicio);
      fim = toDateStr(b?.fim);
      idPropriedade = b?.idPropriedade ?? null;
      if (b?.dias) dias = Math.max(1, parseInt(String(b.dias), 10) || 3);
      agrupar = String(b?.agrupar ?? "bucket").toLowerCase();
    }

    if (!inicio || !fim) return badRequest("inicio e fim (YYYY-MM-DD) são obrigatórios.");

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } }
    );

    let items: any[] = [];
    if (["mes","mês","mensal","month"].includes(agrupar)) {
      const { data, error } = await supabase.rpc("vendidos_categoria_mes", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
      });
      if (error) {
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500, headers: { "content-type": "application/json", ...CORS },
        });
      }
      items = (data ?? []).map((r: any) => ({
        bucket_ini: String(r.bucket_ini ?? "").slice(0,10),
        bucket_fim: endOfMonth(String(r.bucket_ini ?? "").slice(0,10)),
        label: r.label ?? "",
        ...r
      }));
    } else {
      const { data, error } = await supabase.rpc("vendidos_categoria_bucket", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
        p_bucket_dias: dias
      });
      if (error) {
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500, headers: { "content-type": "application/json", ...CORS },
        });
      }
      items = data ?? [];
    }

    return new Response(JSON.stringify({ ok: true, items }), {
      headers: { "content-type": "application/json", ...CORS },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: "Internal Error" }), {
      status: 500, headers: { "content-type": "application/json", ...CORS },
    });
  }
});
