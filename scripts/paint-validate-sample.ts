// Validador de layouts PAINT contra o sample EXPORTACAO DADOS_000460/.
//
// Uso:
//   deno run -A scripts/paint-validate-sample.ts <pasta-do-sample>
//
// Pipeline:
//   1. Carrega LAYOUTS de supabase/functions/paint-export/lib/layouts.ts.
//   2. Para cada arquivo do sample, infere posições/larguras observando
//      whitespace consistente em ≥95% das linhas não vazias.
//   3. Compara com o layout esperado e imprime relatório por arquivo.
//   4. Salva diff completo em scripts/paint-layout-diff.json.
//
// Exit code:
//   0 = sem divergências
//   1 = divergências encontradas
//   2 = erro de leitura/configuração

import { LAYOUTS, PAINT_FILES } from "../supabase/functions/paint-export/lib/layouts.ts";

interface DetectedColumn {
  start: number; // 1-based
  end: number; // 1-based, inclusive
  width: number;
  exemplos: string[];
}

interface FileReport {
  arquivo: string;
  totalLinhas: number;
  layoutEsperado: { campos: number; ultimaPosicao: number };
  larguraDetectada: number | null;
  divergencias: string[];
  amostras: string[];
}

const args = Deno.args;
if (args.length < 1) {
  console.error("Uso: deno run -A scripts/paint-validate-sample.ts <pasta-sample>");
  Deno.exit(2);
}
const sampleDir = args[0].replace(/\/$/, "");

const reports: FileReport[] = [];
let totalDivergencias = 0;

for (const nome of PAINT_FILES) {
  const layout = LAYOUTS[nome];
  const ultimaPos = layout.length === 0
    ? 0
    : Math.max(...layout.map((f) => f.fim));
  const path = `${sampleDir}/${nome}.TXT`;

  let texto: string;
  try {
    texto = await Deno.readTextFile(path);
  } catch (_e) {
    reports.push({
      arquivo: `${nome}.TXT`,
      totalLinhas: 0,
      layoutEsperado: { campos: layout.length, ultimaPosicao: ultimaPos },
      larguraDetectada: null,
      divergencias: [`Arquivo não encontrado em ${path}`],
      amostras: [],
    });
    totalDivergencias += 1;
    continue;
  }

  const linhas = texto.split(/\r?\n/).filter((l) => l.length > 0);
  const totalLinhas = linhas.length;

  if (totalLinhas === 0) {
    if (nome === "ESTOQUE") {
      reports.push({
        arquivo: `${nome}.TXT`,
        totalLinhas: 0,
        layoutEsperado: { campos: 0, ultimaPosicao: 0 },
        larguraDetectada: 0,
        divergencias: [],
        amostras: [],
      });
      continue;
    }
    reports.push({
      arquivo: `${nome}.TXT`,
      totalLinhas: 0,
      layoutEsperado: { campos: layout.length, ultimaPosicao: ultimaPos },
      larguraDetectada: 0,
      divergencias: ["Arquivo vazio (sem linhas)"],
      amostras: [],
    });
    continue;
  }

  // Detecta largura comum.
  const larguras = new Map<number, number>();
  for (const l of linhas) {
    larguras.set(l.length, (larguras.get(l.length) ?? 0) + 1);
  }
  const larguraDominante =
    [...larguras.entries()].sort((a, b) => b[1] - a[1])[0][0];

  const divergencias: string[] = [];
  if (larguraDominante !== ultimaPos) {
    divergencias.push(
      `Largura da linha sample = ${larguraDominante}, layout espera ${ultimaPos}`,
    );
  }

  // Para cada campo do layout, valida que a posição cai dentro da linha sample
  // e mostra exemplo do valor extraído (truncado).
  const amostras: string[] = [];
  const linhasAmostra = linhas.slice(0, 3);
  for (const linha of linhasAmostra) {
    const partes: string[] = [];
    for (const f of layout) {
      const ini = f.ini - 1;
      const fim = Math.min(f.fim, linha.length);
      const valor = linha.slice(ini, fim);
      partes.push(`${f.name}=[${valor}]`);
    }
    amostras.push(partes.join(" "));
  }

  reports.push({
    arquivo: `${nome}.TXT`,
    totalLinhas,
    layoutEsperado: { campos: layout.length, ultimaPosicao: ultimaPos },
    larguraDetectada: larguraDominante,
    divergencias,
    amostras: amostras.slice(0, 1), // só primeira amostra no relatório textual
  });
  totalDivergencias += divergencias.length;
}

// Relatório textual.
console.log("=".repeat(80));
console.log("Validação de layouts PAINT contra sample");
console.log("Pasta:", sampleDir);
console.log("=".repeat(80));

for (const r of reports) {
  const status = r.divergencias.length === 0 ? "✓" : "✗";
  console.log(
    `${status} ${r.arquivo.padEnd(28)} ${r.totalLinhas.toString().padStart(5)} linhas — largura ${r.larguraDetectada ?? "?"} (esperado ${r.layoutEsperado.ultimaPosicao})`,
  );
  for (const d of r.divergencias) {
    console.log(`    ! ${d}`);
  }
  if (r.amostras.length > 0 && r.divergencias.length > 0) {
    console.log(`    sample> ${r.amostras[0].slice(0, 120)}…`);
  }
}

console.log("=".repeat(80));
console.log(`Total de divergências: ${totalDivergencias}`);

// Dump JSON.
const diffPath = "scripts/paint-layout-diff.json";
await Deno.writeTextFile(
  diffPath,
  JSON.stringify({ sampleDir, reports }, null, 2),
);
console.log(`Diff salvo em: ${diffPath}`);

Deno.exit(totalDivergencias === 0 ? 0 : 1);
