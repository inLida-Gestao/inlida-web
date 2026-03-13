import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, x-client-info, apikey",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

function badRequest(msg: string) {
  return new Response(JSON.stringify({ error: msg }), {
    status: 400,
    headers: { "content-type": "application/json", ...CORS },
  });
}

function toDateStr(x: unknown): string | null {
  const s = String(x ?? "").trim();
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

function toMonthEnd(yyyyMmDd: string): string {
  const m = yyyyMmDd.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!m) return yyyyMmDd;

  const year = Number(m[1]);
  const month = Number(m[2]);

  const last = new Date(Date.UTC(year, month, 0));
  const mm = String(last.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(last.getUTCDate()).padStart(2, "0");
  return `${last.getUTCFullYear()}-${mm}-${dd}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  try {
    let inicio: string | null = null;
    let fim: string | null = null;
    let idPropriedade: string | null = null;
    let raca: string | null = null;
    let dias = 3;
    let agrupar = "bucket";

    if (req.method === "GET") {
      const url = new URL(req.url);
      inicio = toDateStr(url.searchParams.get("inicio"));
      fim = toDateStr(url.searchParams.get("fim"));
      idPropriedade = url.searchParams.get("idPropriedade");
      raca = url.searchParams.get("raca") ?? null;
      const d = url.searchParams.get("dias");
      if (d) dias = Math.max(1, parseInt(d, 10) || 3);
      agrupar = (url.searchParams.get("agrupar") ?? "bucket").toLowerCase();
    } else if (req.method === "POST") {
      const body = await req.json().catch(() => ({} as any));
      inicio = toDateStr((body as any)?.inicio);
      fim = toDateStr((body as any)?.fim);
      idPropriedade = (body as any)?.idPropriedade ?? null;
      raca = (body as any)?.raca ?? null;
      if ((body as any)?.dias) dias = Math.max(1, parseInt(String((body as any).dias), 10) || 3);
      agrupar = String((body as any)?.agrupar ?? "bucket").toLowerCase();
    } else {
      return new Response("Method Not Allowed", { status: 405, headers: CORS });
    }

    if (!inicio || !fim) {
      return badRequest("Parâmetros obrigatórios: 'inicio' e 'fim' (YYYY-MM-DD).");
    }

    const isMes =
      agrupar === "mes" ||
      agrupar === "mês" ||
      agrupar === "mensal" ||
      agrupar === "month";

    const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
    const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
    const authHeader = req.headers.get("Authorization") ?? "";

    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      return new Response(JSON.stringify({ error: "Missing Supabase environment variables" }), {
        status: 500,
        headers: { "content-type": "application/json", ...CORS },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    let items: any[] = [];

    if (isMes) {
      const { data, error } = await supabase.rpc("nascimentos_por_mes", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
        p_raca: raca ?? "",
      });

      if (error) {
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { "content-type": "application/json", ...CORS },
        });
      }

      items = (data ?? []).map((r: any) => {
        const start = String(r.mes).slice(0, 10);
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
      const { data, error } = await supabase.rpc("nascimentos_por_periodo_bucket", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
        p_bucket_dias: dias,
      });

      if (error) {
        return new Response(JSON.stringify({ error: error.message }), {
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
    return new Response(JSON.stringify({ error: "Internal Error" }), {
      status: 500,
      headers: { "content-type": "application/json", ...CORS },
    });
  }
});
