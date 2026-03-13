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

/**
 * Aceita:
 * - YYYY-MM-DD
 * - YYYY-M-D (e variações)
 * Normaliza para YYYY-MM-DD.
 * Não usa `new Date()` para evitar problemas de fuso.
 */
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

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  try {
    let inicio: string | null = null;
    let fim: string | null = null;
    let idPropriedade: string | null = null;
    let dias = 3;
    let agrupar = "bucket";
    let sexo: string | null = null;

    if (req.method === "GET") {
      const url = new URL(req.url);
      inicio = toDateStr(url.searchParams.get("inicio"));
      fim = toDateStr(url.searchParams.get("fim"));
      idPropriedade = url.searchParams.get("idPropriedade");
      const d = url.searchParams.get("dias");
      if (d) dias = Math.max(1, parseInt(d, 10) || 3);
      agrupar = (url.searchParams.get("agrupar") ?? "bucket").toLowerCase();
      sexo = url.searchParams.get("sexo");
    } else if (req.method === "POST") {
      const body = await req.json().catch(() => ({} as any));
      inicio = toDateStr((body as any)?.inicio);
      fim = toDateStr((body as any)?.fim);
      idPropriedade = (body as any)?.idPropriedade ?? null;
      if ((body as any)?.dias) dias = Math.max(1, parseInt(String((body as any).dias), 10) || 3);
      agrupar = String((body as any)?.agrupar ?? "bucket").toLowerCase();
      sexo = (body as any)?.sexo ?? null;
    } else {
      return new Response("Method Not Allowed", { status: 405, headers: CORS });
    }

    if (!inicio || !fim || !idPropriedade || String(idPropriedade).trim() === "") {
      return badRequest("Parâmetros obrigatórios: 'inicio', 'fim' (YYYY-MM-DD) e 'idPropriedade'.");
    }

    const isMes =
      agrupar === "mes" || agrupar === "mês" || agrupar === "mensal" || agrupar === "month";

    // Normaliza sexo: "Todos" / "T" / vazio => sem filtro
    let p_sexo: string | null = null;
    if (sexo != null) {
      const s = String(sexo).trim();
      if (s !== "" && s.toLowerCase() !== "todos" && s !== "T") {
        p_sexo = s;
      }
    }

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
      // Desmamas reais por mês
      const { data, error } = await supabase.rpc("desmamas_por_mes", {
        p_inicio: inicio,
        p_fim: fim,
        p_id_propriedade: idPropriedade,
      });

      if (error) {
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { "content-type": "application/json", ...CORS },
        });
      }

      items = data ?? [];
    } else {
      // Desmamas reais por bucket (N dias)
      const { data, error } = await supabase.rpc("desmamas_por_periodo_bucket", {
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