// Edge Function `paint-export` — gera o ZIP no formato PAINT (homologação 000460).

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

import { GENERATORS, genUltimaTransmissao, type ExportContext, type PaintConfig }
  from "./lib/generators.ts";
import { PAINT_FILES, PAINT_ZIP_FILES } from "./lib/layouts.ts";
import { encodeWin1252, formatDate, formatTime } from "./lib/fixed-width.ts";
import { buildZipStore, type ZipEntry } from "./lib/zip-store.ts";
import { selectAll } from "./lib/sql.ts";
import { a12FromRebanho } from "./lib/paint_mappers.ts";
import { validatePaintExport } from "./lib/validate.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const STALE_JOB_MS = 12 * 60 * 1000;

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
  const staleBefore = new Date(now.getTime() - STALE_JOB_MS).toISOString();
  const { error } = await supa.from("paint_export_job")
    .update({
      status: "error",
      erro:
        "Exportação interrompida: tempo máximo excedido no servidor (sem ZIP gerado). Tente novamente.",
      finished_at: now.toISOString(),
    })
    .eq("id_propriedade", idPropriedade)
    .eq("status", "running")
    .lt("started_at", staleBefore);
  if (error) throw new Error(`limpar jobs antigos: ${error.message}`);
}

async function getActiveRunningJob(supa: any, idPropriedade: string) {
  const { data, error } = await supa.from("paint_export_job")
    .select("id,started_at")
    .eq("id_propriedade", idPropriedade)
    .eq("status", "running")
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

const REBANHO_EXPORT_COLUMNS =
  "id,idRebanho,numeroAnimal,chip,codRegistro,nome,sexo,categoria,dataNascimento,pesoNascimento,raca,tipo_registro,dataDesmama,pesoDesmama,status,dataVenda,data_morte,motivo_morte,rebanhoIdMatriz,rebanhoIdReprodutor,anotacoes,loteNome,loteID,created_at,updated_at,dataAcao";

/** Carrega rebanho uma vez e monta cache A12 compartilhado pelos geradores. */
async function prefetchRebanho(ctx: ExportContext): Promise<void> {
  if (ctx.rebanhoRows && ctx.rebanhoRows.length > 0) return;
  const rows = await selectAll<Record<string, unknown>>(
    ctx.supa,
    "rebanho",
    (q) => q.eq("idPropriedade", ctx.config.id_propriedade).neq("deletado", "SIM"),
    { columns: REBANHO_EXPORT_COLUMNS, orderColumn: "id" },
  );
  ctx.rebanhoRows = rows;
  for (const r of rows) {
    const a12 = a12FromRebanho(ctx.config, r);
    if (r.idRebanho) {
      ctx.a12ByRebanhoId.set(String(r.idRebanho), a12);
      ctx.numeroByRebanhoId.set(String(r.idRebanho), String(r.numeroAnimal ?? ""));
    }
  }
  console.log(
    `[paint-export] prefetch rebanho=${rows.length} a12=${ctx.a12ByRebanhoId.size}`,
  );
}

async function runExportJob(
  supa: ReturnType<typeof createClient>,
  jobId: string,
  idPropriedade: string,
  config: PaintConfig,
  faz: Record<string, unknown> | null,
) {
  try {
    const now = new Date();
    const ctx: ExportContext = {
      supa,
      config,
      faz,
      a12ByRebanhoId: new Map(),
      numeroByRebanhoId: new Map(),
      generationDate: formatDate(now),
      generationTime: formatTime(now),
      generationDateTime: now,
    };

    // Uma única carga do rebanho (evita duplicar ~10k linhas na validação).
    await prefetchRebanho(ctx);
    const skipHeavyValidation = (ctx.rebanhoRows?.length ?? 0) > 3000;
    // Só retém o rebanho para validação quando ela realmente vai rodar; caso
    // contrário a referência manteria ~10k linhas presas na memória do worker
    // durante toda a geração (contribui para WORKER_RESOURCE_LIMIT).
    const rebanhoRowsForValidation = skipHeavyValidation
      ? undefined
      : ctx.rebanhoRows;

    const zipEntries: ZipEntry[] = [];
    const zipNames = new Set<string>();
    const addZipFile = (name: string, data: Uint8Array) => {
      if (zipNames.has(name)) return;
      zipNames.add(name);
      zipEntries.push({ name, data });
    };
    const counts: Record<string, number> = {};
    const startTs = Date.now();
    let lastLogTs = startTs;
    // Grava progresso no próprio job: se o worker for morto por limite de
    // recursos, o último estágio registrado mostra exatamente onde parou.
    const stageTimings: Record<string, number> = {};
    const writeProgress = async (stage: string, done: number) => {
      try {
        await supa.from("paint_export_job").update({
          validacao: {
            progresso: {
              stage,
              done,
              total: GENERATION_ORDER.length,
              elapsedMs: Date.now() - startTs,
              timings: stageTimings,
            },
          },
        }).eq("id", jobId);
      } catch (_e) { /* progresso é best-effort */ }
    };

    await writeProgress("prefetch_done", 0);

    let idx = 0;
    for (const name of GENERATION_ORDER) {
      idx += 1;
      const gen = GENERATORS[name];
      let content = "";
      if (gen) content = await gen(ctx);
      const lineCount = countLines(content);
      counts[name.replace("_DELETE", "")] = counts[name.replace("_DELETE", "")] ??
        lineCount;
      counts[name] = lineCount;
      addZipFile(`${name}.TXT`, encodeWin1252(content));
      content = ""; // libera a string grande imediatamente
      const took = Date.now() - lastLogTs;
      stageTimings[name] = took;
      console.log(
        `[paint-export] ${name}.TXT lines=${lineCount} elapsed=${took}ms`,
      );
      lastLogTs = Date.now();

      if (name === "NASCIMENTO") ctx.rebanhoRows = undefined;
      if (name === "COBERTURA") ctx.reproducaoRows = undefined;
      if (name === "PESAGEM") ctx.pesagemRows = undefined;

      // Atualiza progresso só nos arquivos pesados (evita 30 writes).
      if (lineCount > 2000 || idx % 6 === 0) await writeProgress(name, idx);
    }
    await writeProgress("files_done", GENERATION_ORDER.length);

    const utr = await genUltimaTransmissao(ctx, counts);
    counts["ULTIMA_TRANSMISSAO"] = countLines(utr);
    addZipFile("ULTIMA_TRANSMISSAO.TXT", encodeWin1252(utr));

    const EMPTY = new Uint8Array(0);
    for (const name of PAINT_ZIP_FILES) addZipFile(`${name}.TXT`, EMPTY);
    for (const name of PAINT_FILES) addZipFile(`${name}.TXT`, EMPTY);

    await writeProgress("zipping", GENERATION_ORDER.length);
    const zipBytes = buildZipStore(zipEntries);
    zipEntries.length = 0; // libera os bytes individuais; já estão no zipBytes
    console.log(
      `[paint-export] zip pronto job=${jobId} bytes=${zipBytes.length} elapsed=${Date.now() - startTs}ms`,
    );
    await writeProgress("uploading", GENERATION_ORDER.length);

    // Pré-validação após gerar arquivos (não bloqueia o ZIP). Em volume alto,
    // omitimos por completo para economizar CPU/RAM no worker.
    let validacao: unknown = null;
    if (skipHeavyValidation) {
      validacao = {
        erros: [],
        avisos: [{
          tabela: "GERAL",
          regra: "Validação detalhada omitida (volume alto na propriedade)",
          qtd: 0,
          exemplos: [],
        }],
        geradoEm: new Date().toISOString(),
      };
      console.log(`[paint-export] validação omitida job=${jobId} (volume alto)`);
    } else {
      try {
        validacao = await validatePaintExport(supa, config, {
          rebanhoRows: rebanhoRowsForValidation,
          skipHeavyChecks: false,
        });
        const r = validacao as { erros: unknown[]; avisos: unknown[] };
        console.log(
          `[paint-export] validação job=${jobId} erros=${r.erros.length} avisos=${r.avisos.length}`,
        );
      } catch (e) {
        console.error(`[paint-export] validação falhou: ${e}`);
      }
    }

    const nomeZip = buildZipName(config.codigo_transmissao, now);
    const storagePath = `${idPropriedade}/${nomeZip}`;

    const { error: uploadErr } = await supa.storage
      .from("paint-exports")
      .upload(storagePath, zipBytes, {
        contentType: "application/zip",
        upsert: true,
      });
    if (uploadErr) throw new Error(`upload: ${uploadErr.message}`);

    await supa.from("paint_export_job").update({
      status: "success",
      nome_zip: nomeZip,
      storage_path: storagePath,
      total_animais: counts.ANIMAL ?? 0,
      validacao,
      finished_at: new Date().toISOString(),
    }).eq("id", jobId);

    await supa.from("paint_registro_excluido")
      .update({ exportado_em: new Date().toISOString() })
      .eq("id_propriedade", idPropriedade)
      .is("exportado_em", null);

    console.log(
      `[paint-export] concluído job=${jobId} zip=${nomeZip} animais=${counts.ANIMAL ?? 0}`,
    );
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error(`[paint-export] erro job=${jobId}: ${msg}`);
    await supa.from("paint_export_job").update({
      status: "error",
      erro: msg,
      finished_at: new Date().toISOString(),
    }).eq("id", jobId);
  }
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
    const activeJob = await getActiveRunningJob(supa, idPropriedade);
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

  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!serviceKey) {
    await supa.from("paint_export_job").update({
      status: "error",
      erro: "SUPABASE_SERVICE_ROLE_KEY não configurada na Edge Function.",
      finished_at: new Date().toISOString(),
    }).eq("id", jobId);
    return jsonResponse(500, {
      ok: false,
      error: "Configuração do servidor incompleta. Contate o suporte.",
    });
  }

  const supaWorker = createClient(
    Deno.env.get("SUPABASE_URL")!,
    serviceKey,
  );

  const fazRow = (faz && faz.length > 0) ? faz[0] : null;
  const exportTask = runExportJob(
    supaWorker,
    jobId,
    idPropriedade,
    config,
    fazRow,
  );

  // Responde imediatamente para não estourar timeout do cliente (invoke) nem
  // bloquear a UI; o app acompanha paint_export_job via polling.
  // @ts-ignore EdgeRuntime global no Supabase
  if (typeof EdgeRuntime !== "undefined" && EdgeRuntime.waitUntil) {
    EdgeRuntime.waitUntil(exportTask);
  } else {
    exportTask.catch((e) => console.error("[paint-export] background:", e));
  }

  return jsonResponse(202, {
    ok: true,
    async: true,
    jobId,
    message: "Exportação iniciada. Acompanhe o status na tela.",
  });
});
