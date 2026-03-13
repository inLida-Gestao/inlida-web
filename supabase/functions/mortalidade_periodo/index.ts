import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, x-client-info, apikey",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

function badRequest(msg: string) {
  return new Response(JSON.stringify({ ok: false, error: msg }), {
    status: 400,
    headers: { "content-type": "application/json", ...CORS },
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

function toMonthEnd(yyyyMmDd: string): string {
  const d = new Date(`${yyyyMmDd}T00:00:00Z`);
  if (isNaN(d.getTime())) return yyyyMmDd;
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
    let causa: string | null = null;
    let dias = 3;
    let agrupar = "bucket";

    if (req.method === "GET") {
      const url = new URL(req.url);
      inicio = toDateStr(url.searchParams.get("inicio"));
      fim = toDateStr(url.searchParams.get("fim"));
      idPropriedade = url.searchParams.get("idPropriedade");
      causa = url.searchParams.get("causa")?.trim() || null;
      const d = url.searchParams.get("dias");
      if (d) dias = Math.max(1, parseInt(d, 10) || 3);
      agrupar = (url.searchParams.get("agrupar") ?? "bucket").toLowerCase();
    } else if (req.method === "POST") {
      const body = await req.json().catch(() => ({}));
      inicio = toDateStr(body?.inicio);
      fim = toDateStr(body?.fim);
      idPropriedade = body?.idPropriedade ?? null;
      causa = body?.causa?.trim() || null;
      if (body?.dias) dias = Math.max(1, parseInt(String(body.dias), 10) || 3);
      agrupar = String(body?.agrupar ?? "bucket").toLowerCase();
    } else {
      return new Response("Method Not Allowed", { status: 405, headers: CORS });
    }

    if (!inicio || !fim || !idPropriedade) {
      return badRequest("Parâmetros obrigatórios: 'inicio', 'fim' e 'idPropriedade'.");
    }

    const isMes =
      agrupar === "mes" || agrupar === "mês" || agrupar === "mensal" || agrupar === "month";

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } }
    );

    let items: any[] = [];

    if (isMes) {
      const { data, error } = await supabase.rpc("mortalidade_por_mes", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
        p_causa: causa,
      });
      if (error) {
        return new Response(JSON.stringify({ ok: false, error: error.message }), {
          status: 500,
          headers: { "content-type": "application/json", ...CORS },
        });
      }

      items = (data ?? []).map((r: any) => {
        const start = String(r.mes ?? "").slice(0, 10);
        const end = toMonthEnd(start);
        return {
          bucket_ini: start,
          bucket_fim: end,
          label: r.label ?? "",
          total: Number(r.total ?? 0),
          machos: Number(r.machos ?? 0),
          femeas: Number(r.femeas ?? 0),
        };
      });
    } else {
      const { data, error } = await supabase.rpc("mortalidade_por_periodo_bucket", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
        p_bucket_dias: dias,
        p_causa: causa,
      });
      if (error) {
        return new Response(JSON.stringify({ ok: false, error: error.message }), {
          status: 500,
          headers: { "content-type": "application/json", ...CORS },
        });
      }
      items = data ?? [];
    }

    return new Response(JSON.stringify({ ok: true, items }), {
      headers: { "content-type": "application/json", ...CORS },
    });
  } catch {
    return new Response(JSON.stringify({ ok: false, error: "Internal Error" }), {
      status: 500,
      headers: { "content-type": "application/json", ...CORS },
    });
  }
});
