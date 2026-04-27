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

/** Aceita YYYY-M-D e YYYY-MM-DD -> normaliza para YYYY-MM-DD */
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

/** Primeiro/último dia do mês (compatibilidade: mes+ano) */
function mesAnoToIntervalo(mes: number, ano: number): { inicio: string; fim: string } {
  const inicio = `${ano}-${String(mes).padStart(2, "0")}-01`;
  const ult = new Date(ano, mes, 0);
  const fim = `${ano}-${String(mes).padStart(2, "0")}-${String(ult.getDate()).padStart(2, "0")}`;
  return { inicio, fim };
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
    const mesParam = url.searchParams.get("mes");
    const anoParam = url.searchParams.get("ano");

    if (!idPropriedade || idPropriedade.trim() === "") {
      return badRequest("Parâmetro obrigatório: 'idPropriedade'.");
    }

    let inicio: string | null;
    let fim: string | null;

    if (inicioRaw && fimRaw) {
      inicio = toDateStr(inicioRaw);
      fim = toDateStr(fimRaw);
      if (!inicio) return badRequest("inicio inválida. Use YYYY-MM-DD.");
      if (!fim) return badRequest("fim inválida. Use YYYY-MM-DD.");
    } else if (mesParam && anoParam) {
      const mes = Number(mesParam);
      const ano = Number(anoParam);
      if (isNaN(mes) || mes < 1 || mes > 12) {
        return badRequest("mes deve ser um número entre 1 e 12 (modo legado) ou use inicio e fim.");
      }
      if (isNaN(ano) || ano < 1900 || ano > 2100) {
        return badRequest("ano inválido (modo legado).");
      }
      const iv = mesAnoToIntervalo(mes, ano);
      inicio = iv.inicio;
      fim = iv.fim;
    } else {
      return badRequest("Envie 'inicio' e 'fim' (YYYY-MM-DD) ou o par legado 'mes' (1-12) e 'ano'.");
    }

    if (inicio! > fim!) {
      return badRequest("A data inicio não pode ser posterior à fim.");
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

    const { data, error } = await supabaseClient.rpc("get_relatorio_resumo_estacao", {
      id_propriedade_param: idPropriedade,
      data_inicio_param: inicio!,
      data_fim_param: fim!,
    });

    if (error) {
      return new Response(JSON.stringify({ ok: false, error: `Erro no cálculo do banco: ${error.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    }

    const payload = data as Record<string, unknown> | null;
    if (!payload || typeof payload !== "object") {
      return new Response(
        JSON.stringify({ ok: false, error: "Resposta inesperada do relatório de estação." }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const linhas = Array.isArray(payload.linhas) ? payload.linhas : [];
    const dataUltimo = payload.data_ultimo_dg == null
      ? null
      : String(payload.data_ultimo_dg);
    const expostasTotal = Number(payload.expostas_total ?? 0);

    return new Response(
      JSON.stringify({
        ok: true,
        linhas,
        data_ultimo_dg: dataUltimo,
        expostas_total: expostasTotal,
        /** @deprecated resposta antiga; mantido vazio se algum consumidor ainda lê "items" */
        items: [],
      }),
      {
        status: 200,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  } catch (e) {
    console.error(e);
    return new Response(
      JSON.stringify({ ok: false, error: "Erro interno do servidor." }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
