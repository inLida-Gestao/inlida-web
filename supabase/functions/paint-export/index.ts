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

const RUNNING_JOB_TTL_MS = 5 * 60 * 1000;

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
  let count = 1;
  let index = 0;
  while ((index = content.indexOf("\r\n", index)) !== -1) {
    count += 1;
    index += 2;
  }
  return content.endsWith("\r\n") ? count - 1 : count;
}

async function clearStaleRunningJobs(supa: any, idPropriedade: string, now: Date) {
  const staleBefore = new Date(now.getTime() - RUNNING_JOB_TTL_MS).toISOString();
  const { error } = await supa.from("paint_export_job")
    .update({
      status: "error",
      erro: "Exportação anterior interrompida antes de finalizar.",
      finished_at: now.toISOString(),
    })
    .eq("id_propriedade", idPropriedade)
    .eq("status", "running")
    .lt("started_at", staleBefore);
  if (error) throw new Error(`limpar jobs antigos: ${error.message}`);
}

async function getActiveRunningJob(supa: any, idPropriedade: string, now: Date) {
  const activeSince = new Date(now.getTime() - RUNNING_JOB_TTL_MS).toISOString();
  const { data, error } = await supa.from("paint_export_job")
    .select("id,started_at")
    .eq("id_propriedade", idPropriedade)
    .eq("status", "running")
    .gte("started_at", activeSince)
    .order("started_at", { ascending: false })
    .limit(1);
  if (error) throw new Error(`consultar exportação em andamento: ${error.message}`);
  return data?.[0] ?? null;
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

  const requestStartedAt = new Date();
  try {
    await clearStaleRunningJobs(supa, idPropriedade, requestStartedAt);
    const activeJob = await getActiveRunningJob(supa, idPropriedade, requestStartedAt);
    if (activeJob) {
      return jsonResponse(200, {
        ok: false,
        error:
          "Já existe uma exportação PAINT em andamento para esta propriedade. Aguarde finalizar antes de gerar outra.",
        jobId: activeJob.id,
        startedAt: activeJob.started_at,
      });
    }
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return jsonResponse(500, { ok: false, error: msg });
  }

  const userId = (await supa.auth.getUser()).data.user?.id ?? null;
  const { data: jobRows, error: jobErr } = await supa
    .from("paint_export_job")
    .insert({
      id_propriedade: idPropriedade,
      usuario_id: userId,
      status: "running",
      started_at: requestStartedAt.toISOString(),
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
      const lineCount = countLines(content);
      counts[name.replace("_DELETE", "")] = counts[name.replace("_DELETE", "")] ??
        lineCount;
      counts[name] = lineCount;
      zip.addFile(`${name}.TXT`, encodeWin1252(content));
      console.log(
        `[paint-export] ${name}.TXT lines=${lineCount} elapsed=${Date.now() - lastLogTs}ms`,
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

    // A compressão padrão consome CPU suficiente para estourar limite do
    // Edge Worker em propriedades maiores. O PAINT só exige o contêiner ZIP.
    const zipBytes = await zip.generateAsync({
      type: "uint8array",
      compression: "STORE",
    });

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
      storagePath,
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
