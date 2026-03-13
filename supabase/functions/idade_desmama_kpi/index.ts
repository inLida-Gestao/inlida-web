import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// CORS
const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, x-client-info, apikey",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

function badRequest(msg: string) {
  return new Response(JSON.stringify({ error: msg }), {
    status: 400,
    headers: {
      "content-type": "application/json",
      ...CORS,
    },
  });
}

/**
 * Aceita:
 * - YYYY-MM-DD
 * - YYYY-M-DD
 * - YYYY-MM-D
 * - YYYY-M-D
 *
 * Normaliza para YYYY-MM-DD.
 * Não usa `new Date()` para evitar problemas de fuso horário.
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

  const mm = String(mo).padStart(2, "0");
  const dd = String(d).padStart(2, "0");
  return `${y}-${mm}-${dd}`;
}

/**
 * Converte código de sexo do frontend para valor do banco de dados
 * "M" -> "Macho"
 * "F" -> "Fêmea"
 * "T" ou null -> null (todos)
 */
function normalizarSexo(sexo: string | null): string | null {
  if (!sexo || sexo.trim() === "") return null;
  const s = sexo.trim().toUpperCase();
  if (s === "T") return null; // Todos
  if (s === "M") return "Macho";
  if (s === "F") return "Fêmea";
  // Se já estiver no formato correto, retorna como está
  return sexo;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS });
  }

  try {
    let inicio: string | null = null;
    let fim: string | null = null;
    let idPropriedade: string | null = null;
    let sexo: string | null = null;

    if (req.method === "GET") {
      const url = new URL(req.url);
      inicio = toDateStr(url.searchParams.get("inicio"));
      fim = toDateStr(url.searchParams.get("fim"));
      idPropriedade = url.searchParams.get("idPropriedade");
      sexo = url.searchParams.get("sexo");
    } else {
      const b = await req.json().catch(() => ({} as any));
      inicio = toDateStr((b as any)?.inicio);
      fim = toDateStr((b as any)?.fim);
      idPropriedade = (b as any)?.idPropriedade ?? null;
      sexo = (b as any)?.sexo ?? null;
    }

    if (!inicio || !fim) {
      return badRequest("inicio e fim são obrigatórios (YYYY-MM-DD).");
    }

    // Normaliza o sexo: "M" -> "Macho", "F" -> "Fêmea", "T" -> null
    sexo = normalizarSexo(sexo);

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");

    if (!supabaseUrl || !supabaseAnonKey) {
      return new Response(JSON.stringify({ error: "Missing Supabase environment variables" }), {
        status: 500,
        headers: { "content-type": "application/json", ...CORS },
      });
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: {
          Authorization: req.headers.get("Authorization") ?? "",
        },
      },
    });

    const { data, error } = await supabase.rpc("idade_desmama_media", {
      p_inicio: inicio,
      p_fim: fim,
      p_id_propriedade: idPropriedade,
      p_sexo: sexo,
    });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "content-type": "application/json", ...CORS },
      });
    }

    // Transforma a resposta para o formato esperado pelo widget MetricReadOnlySlider
    // A função SQL retorna: { media_meses: number, total_animais: number }
    // O widget espera: { valor: number, titulo?: string, sufixo?: string }
    const items = Array.isArray(data) && data.length > 0
      ? [{
          valor: Number(data[0].media_meses ?? 0),
          titulo: "",
          sufixo: " meses",
          total_animais: Number(data[0].total_animais ?? 0),
        }]
      : [{
          valor: 0,
          titulo: "",
          sufixo: " meses",
          total_animais: 0,
        }];

    return new Response(
      JSON.stringify({
        ok: true,
        items,
      }),
      {
        headers: { "content-type": "application/json", ...CORS },
      },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: `Internal Error: ${e}` }), {
      status: 500,
      headers: { "content-type": "application/json", ...CORS },
    });
  }
});