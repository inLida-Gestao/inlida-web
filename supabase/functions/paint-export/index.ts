// Edge Function `paint-export` — gera o ZIP no formato PAINT.
// Padrão de auth/CORS espelha supabase/functions/taxa-prenhez/index.ts.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { JSZip } from "https://deno.land/x/jszip@0.11.0/mod.ts";

import { GENERATORS, genUltimaTransmissao, type ExportContext, type PaintConfig }
  from "./lib/generators.ts";
import { PAINT_FILES } from "./lib/layouts.ts";
import { encodeWin1252, formatDate, formatTime } from "./lib/fixed-width.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function buildZipName(codTransm: string, now: Date): string {
  const yyyy = String(now.getUTCFullYear());
  const mm = String(now.getUTCMonth() + 1).padStart(2, "0");
  const dd = String(now.getUTCDate()).padStart(2, "0");
  const hh = String(now.getUTCHours()).padStart(2, "0");
  const mi = String(now.getUTCMinutes()).padStart(2, "0");
  const ss = String(now.getUTCSeconds()).padStart(2, "0");
  return `${codTransm}${yyyy}${mm}${dd}${hh}${mi}${ss}.zip`;
}

function countLines(content: string): number {
  if (!content) return 0;
  // joinLines termina com CRLF; divide por CRLF e remove vazio final.
  const parts = content.split("\r\n");
  if (parts.length > 0 && parts[parts.length - 1] === "") parts.pop();
  return parts.length;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") {
    return jsonResponse(405, { ok: false, error: "Use POST." });
  }

  let body: any = {};
  try {
    body = await req.json();
  } catch (_e) {
    return jsonResponse(400, { ok: false, error: "Body JSON inválido." });
  }
  const idPropriedade = String(body?.idPropriedade ?? "").trim();
  if (!idPropriedade) {
    return jsonResponse(400, { ok: false, error: "idPropriedade é obrigatório." });
  }

  const supa = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      global: {
        headers: { Authorization: req.headers.get("Authorization") ?? "" },
      },
    },
  );

  // Valida acesso à propriedade pelo RLS de paint_fazenda_config.
  const { data: configRows, error: configError } = await supa
    .from("paint_fazenda_config")
    .select("*")
    .eq("id_propriedade", idPropriedade)
    .limit(1);
  if (configError) {
    return jsonResponse(500, { ok: false, error: `Erro ao ler config: ${configError.message}` });
  }
  if (!configRows || configRows.length === 0) {
    return jsonResponse(400, {
      ok: false,
      error: "Configure código de transmissão e série fazenda PAINT antes de exportar.",
    });
  }
  const config = configRows[0] as PaintConfig;

  const { data: faz } = await supa
    .from("propriedades")
    .select("*")
    .eq("idPropriedade", idPropriedade)
    .limit(1);

  // Cria job em status running.
  const userId = (await supa.auth.getUser()).data.user?.id ?? null;
  const { data: jobRows, error: jobErr } = await supa
    .from("paint_export_job")
    .insert({
      id_propriedade: idPropriedade,
      usuario_id: userId,
      status: "running",
      started_at: new Date().toISOString(),
    })
    .select()
    .limit(1);
  if (jobErr) {
    return jsonResponse(500, { ok: false, error: `job: ${jobErr.message}` });
  }
  const jobId = jobRows![0].id as string;

  try {
    const now = new Date();
    const ctx: ExportContext = {
      supa,
      config,
      faz: (faz && faz.length > 0) ? faz[0] : null,
      a12ByRebanhoId: new Map(),
      numeroByRebanhoId: new Map(),
      generationDate: formatDate(now),
      generationTime: formatTime(now),
      generationDateTime: now,
    };

    // Ordem: ANIMAL primeiro para popular o cache de A12 usado pelos demais.
    const order = [
      "ANIMAL",
      "BAIXA",
      "COMPOSICAO_RACIAL",
      "COBERTURA",
      "NASCIMENTO",
      "ANO_SOBREANO",
      "AVALIADOR",
      "DESMAMA",
      "DIAGNOSTICO",
      "ESTOQUE",
      "FAZENDA",
      "GRUPO_MANEJO",
      "INSEMINADOR",
      "LOCALIDADE",
      "PESAGEM",
      "RACA",
      "RAH",
      "REGIME_ALIMENTAR",
      "SAFRA",
      "SAFRA_X_ANIMAL",
      "TOURO_MULTIPLO",
    ];

    // Pré-monta ZIP incrementalmente: para cada arquivo, gera string,
    // encoda Win1252 em Uint8Array, adiciona ao zip e descarta a string.
    // Isso evita manter 22 strings grandes em memória ao mesmo tempo.
    const zip = new JSZip();
    const counts: Record<string, number> = {};
    let lastLogTs = Date.now();
    for (const name of order) {
      const gen = GENERATORS[name];
      let content = "";
      if (gen) content = await gen(ctx);
      counts[name] = countLines(content);
      zip.addFile(`${name}.TXT`, encodeWin1252(content));
      const ts = Date.now();
      console.log(
        `[paint-export] ${name}.TXT lines=${counts[name]} bytes≈${content.length} elapsed=${ts - lastLogTs}ms`,
      );
      lastLogTs = ts;
      // Libera caches grandes assim que possível.
      if (name === "NASCIMENTO") {
        ctx.rebanhoRows = undefined;
      }
      if (name === "COBERTURA") {
        ctx.reproducaoRows = undefined;
      }
      if (name === "PESAGEM") {
        ctx.pesagemRows = undefined;
      }
    }

    // ULTIMA_TRANSMISSAO depende dos counts dos demais — gera por último.
    {
      const utr = await genUltimaTransmissao(ctx, counts);
      counts["ULTIMA_TRANSMISSAO"] = countLines(utr);
      zip.addFile("ULTIMA_TRANSMISSAO.TXT", encodeWin1252(utr));
    }

    // Sanity check: garante que todos os 22 arquivos oficiais foram adicionados
    // (ESTOQUE.TXT vazio inclusive, conforme manual).
    for (const name of PAINT_FILES) {
      if (!zip.file(`${name}.TXT`)) {
        zip.addFile(`${name}.TXT`, encodeWin1252(""));
      }
    }

    const zipBytes = await zip.generateAsync({ type: "uint8array" });

    const nomeZip = buildZipName(config.codigo_transmissao, now);
    const storagePath = `${idPropriedade}/${nomeZip}`;

    const { error: uploadErr } = await supa.storage
      .from("paint-exports")
      .upload(storagePath, zipBytes, {
        contentType: "application/zip",
        upsert: true,
      });
    if (uploadErr) throw new Error(`upload: ${uploadErr.message}`);

    const { data: signed, error: signedErr } = await supa.storage
      .from("paint-exports")
      .createSignedUrl(storagePath, 3600);
    if (signedErr) throw new Error(`signed url: ${signedErr.message}`);

    await supa.from("paint_export_job").update({
      status: "success",
      nome_zip: nomeZip,
      storage_path: storagePath,
      total_animais: counts.ANIMAL ?? 0,
      finished_at: new Date().toISOString(),
    }).eq("id", jobId);

    return jsonResponse(200, {
      ok: true,
      jobId,
      nomeZip,
      signedUrl: signed?.signedUrl,
      counts,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    await supa.from("paint_export_job").update({
      status: "error",
      erro: msg,
      finished_at: new Date().toISOString(),
    }).eq("id", jobId);
    return jsonResponse(500, { ok: false, error: msg });
  }
});
