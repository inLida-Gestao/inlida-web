// Edge Function `paint-export` — gera o ZIP no formato PAINT (homologação 000460).

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { JSZip } from "https://deno.land/x/jszip@0.11.0/mod.ts";

import { GENERATORS, genUltimaTransmissao, type ExportContext, type PaintConfig }
  from "./lib/generators.ts";
import { PAINT_FILES, PAINT_ZIP_FILES } from "./lib/layouts.ts";
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
  const parts = content.split("\r\n");
  if (parts.length > 0 && parts[parts.length - 1] === "") parts.pop();
  return parts.length;
}

const GENERATION_ORDER = [
  "PARAMETROS",
  "FAZENDA",
  "RACA",
  "REGIME_ALIMENTAR",
  "INSEMINADOR",
  "GRUPO_MANEJO",
  "LOCALIDADE",
  "AVALIADOR",
  "SAFRA",
  "ANIMAL",
  "BAIXA",
  "COMPOSICAO_RACIAL",
  "COBERTURA",
  "NASCIMENTO",
  "ANO_SOBREANO",
  "DESMAMA",
  "DIAGNOSTICO",
  "ESTOQUE",
  "PESAGEM",
  "RAH",
  "SAFRA_X_ANIMAL",
  "TOURO_MULTIPLO",
  "ANIMAL_DELETE",
  "ANO_SOBREANO_DELETE",
  "BAIXA_DELETE",
  "COBERTURA_DELETE",
  "COMPOSICAO_RACIAL_DELETE",
  "DESMAMA_DELETE",
  "DIAGNOSTICO_DELETE",
  "ESTOQUE_DELETE",
  "FAZENDA_DELETE",
  "GRUPO_MANEJO_DELETE",
  "NASCIMENTO_DELETE",
  "SAFRA_DELETE",
];

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

    const zip = new JSZip();
    const counts: Record<string, number> = {};
    let lastLogTs = Date.now();

    for (const name of GENERATION_ORDER) {
      const gen = GENERATORS[name];
      let content = "";
      if (gen) content = await gen(ctx);
      counts[name.replace("_DELETE", "")] = counts[name.replace("_DELETE", "")] ??
        countLines(content);
      if (!name.endsWith("_DELETE")) {
        counts[name] = countLines(content);
      } else {
        counts[name] = countLines(content);
      }
      zip.addFile(`${name}.TXT`, encodeWin1252(content));
      console.log(
        `[paint-export] ${name}.TXT lines=${countLines(content)} elapsed=${Date.now() - lastLogTs}ms`,
      );
      lastLogTs = Date.now();

      if (name === "NASCIMENTO") ctx.rebanhoRows = undefined;
      if (name === "COBERTURA") ctx.reproducaoRows = undefined;
      if (name === "PESAGEM") ctx.pesagemRows = undefined;
    }

    const utr = await genUltimaTransmissao(ctx, counts);
    counts["ULTIMA_TRANSMISSAO"] = countLines(utr);
    zip.addFile("ULTIMA_TRANSMISSAO.TXT", encodeWin1252(utr));

    for (const name of PAINT_ZIP_FILES) {
      if (!zip.file(`${name}.TXT`)) {
        zip.addFile(`${name}.TXT`, encodeWin1252(""));
      }
    }
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

    await supa.from("paint_registro_excluido")
      .update({ exportado_em: new Date().toISOString() })
      .eq("id_propriedade", idPropriedade)
      .is("exportado_em", null);

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
