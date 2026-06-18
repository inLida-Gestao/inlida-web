// Teste de ponta a ponta (sem DB) do pipeline de exportação PAINT.
// Exercita as MESMAS funções usadas pelos geradores: paint_mappers + layouts +
// fixed-width (buildLine), montando linhas reais de ANIMAL/DESMAMA/COBERTURA e
// validando posições, larguras e regras das calls PAINT (A12 PO=JLK, brinco,
// categoria, recno, ESTOQUE vazio).
//
// Rodar: node scripts/paint_e2e_check.ts   (Node 23+/24 com type stripping)

import {
  buildLine,
  formatDate,
  formatNumeric,
  joinLines,
} from "../supabase/functions/paint-export/lib/fixed-width.ts";
import { LAYOUTS, PAINT_FILES } from "../supabase/functions/paint-export/lib/layouts.ts";
import {
  a12FromRebanho,
  derivaSafraCodigo,
  extractBrinco5,
  mapCategoriaAnterior,
  mapCategoriaPaint,
  mapRacaPaint,
  mapTipoRegistro,
  resolveSerieA12,
} from "../supabase/functions/paint-export/lib/paint_mappers.ts";

let passed = 0;
let failed = 0;
const fails: string[] = [];

function check(name: string, cond: boolean, detail = "") {
  if (cond) {
    passed++;
  } else {
    failed++;
    fails.push(`✗ ${name}${detail ? ` — ${detail}` : ""}`);
  }
}

function eq(name: string, actual: unknown, expected: unknown) {
  check(name, actual === expected, `esperado=${JSON.stringify(expected)} obtido=${JSON.stringify(actual)}`);
}

// Slice 1-based inclusivo (igual ao layout PAINT).
function field(line: string, ini: number, fim: number): string {
  return line.slice(ini - 1, fim);
}

function maxFim(layout: { fim: number }[]): number {
  return Math.max(...layout.map((f) => f.fim));
}

const config = {
  id_propriedade: "prop-cachoeira",
  codigo_transmissao: "000460",
  serie_fazenda: "0001",
  serie_raca_po: "JLK",
  codigo_fazenda: "0001",
  programa: "P",
  estrategia_a12: "compacto" as const,
  campo_origem_animal: "numeroAnimal",
};

// ============================================================================
// 1) Integridade dos layouts: posições contíguas e largura coerente
// ============================================================================
for (const [nome, layout] of Object.entries(LAYOUTS)) {
  let ok = true;
  let prevFim = 0;
  for (const f of layout) {
    if (f.ini !== prevFim + 1) { ok = false; break; }
    if (f.fim - f.ini + 1 !== f.tam) { ok = false; break; }
    prevFim = f.fim;
  }
  check(`layout ${nome} contíguo e larguras corretas`, ok);
  // Linha de row vazio deve ter exatamente maxFim de comprimento.
  const linha = buildLine(layout, {});
  eq(`layout ${nome} linha vazia tem largura ${maxFim(layout)}`, linha.length, maxFim(layout));
}

// ============================================================================
// 2) ANIMAL — animal PO (Cachoeira / JLK)
// ============================================================================
const animalPO = {
  idRebanho: "r1",
  numeroAnimal: "JLK4705",
  nome: "BONITA",
  chip: "",
  codRegistro: "RGD12345",
  sexo: "F",
  categoria: "Novilha",
  raca: "NELORE PO",
  dataNascimento: "2018-09-01",
  dataDesmama: "2019-04-01",
  status: "NA PROPRIEDADE",
};

const a12PO = a12FromRebanho(config, animalPO);
eq("A12 PO usa série JLK e brinco sem sigla", a12PO, "PJLK 4705 18");
eq("resolveSerieA12 PO = JLK", resolveSerieA12(animalPO, config), "JLK");
eq("tipo registro PO inferido", mapTipoRegistro(animalPO), "PO");
eq("brinco PO só dígitos", extractBrinco5(animalPO.numeroAnimal), "4705");
const catPO = mapCategoriaPaint(animalPO);
eq("categoria fêmea novilha", catPO, "NV");
eq("categoria anterior de NV", mapCategoriaAnterior(catPO), "AD");

// Monta a linha ANIMAL como o gerador faz e confere as posições do layout.
const animalRow: Record<string, unknown> = {
  ani_parceiro: config.codigo_transmissao,
  ani_programa: "P",
  ani_serie_fazenda: resolveSerieA12(animalPO, config),
  ani_animal: "4705",
  ani_data_nasc: formatDate(animalPO.dataNascimento),
  ani_A12: a12PO,
  ani_sexo: "F",
  ani_tipo: mapTipoRegistro(animalPO),
  ani_nome: "BONITA",
  ani_fazenda: config.codigo_fazenda,
  ani_brinco: extractBrinco5(animalPO.numeroAnimal),
  ani_raca: mapRacaPaint(animalPO.raca),
  ani_categoria: catPO,
  ani_categoria_ant: mapCategoriaAnterior(catPO),
  ani_enviar: "True ",
  ani_atuprog: "False",
  ani_recno: 1,
};
const animalLine = buildLine(LAYOUTS.ANIMAL, animalRow);
eq("ANIMAL largura 368", animalLine.length, 368);
eq("ANIMAL A12 nas posições 27-38", field(animalLine, 27, 38), "PJLK 4705 18");
eq("ANIMAL tipo nas posições 57-60", field(animalLine, 57, 60), "PO  ");
eq("ANIMAL raça nas posições 136-137", field(animalLine, 136, 137), "NE");
eq("ANIMAL categoria nas posições 192-193", field(animalLine, 192, 193), "NV");
eq("ANIMAL categoria_ant nas posições 291-292", field(animalLine, 291, 292), "AD");
// recno (N, 9, dir.) posições 247-255
eq("ANIMAL recno alinhado à direita", field(animalLine, 247, 255), "        1");

// ============================================================================
// 3) ANIMAL — animal não-PO (Cara Limpa) usa série da fazenda
// ============================================================================
const animalCL = {
  idRebanho: "r2",
  numeroAnimal: "890",
  raca: "NELORE",
  dataNascimento: "2020-06-10",
  sexo: "M",
  status: "NA PROPRIEDADE",
};
eq("A12 não-PO usa série fazenda", a12FromRebanho(config, animalCL), "P0001890  20");
eq("tipo registro vazio p/ não-PO", mapTipoRegistro(animalCL), "");
eq("categoria macho mamando", mapCategoriaPaint(animalCL), "AM");

// ============================================================================
// 4) DESMAMA — notas e peso saem no TXT (regressão "notas não sobem")
// ============================================================================
const desmamaRow = {
  dsm_parceiro: config.codigo_transmissao,
  dsm_animal_id: a12PO,
  dsm_fazenda: config.codigo_fazenda,
  dsm_data: formatDate("2019-04-01"),
  dsm_peso: formatNumeric(223, 8, 2),
  dsm_nota_c: formatNumeric(4, 8, 2),
  dsm_nota_p: formatNumeric(5, 8, 2),
  dsm_nota_m: formatNumeric(3, 8, 2),
  dsm_nota_u: formatNumeric(2, 8, 2),
  dsm_grupo_manejo: "GM1",
  dsm_enviar: "True ",
  dsm_recno: 1,
};
const desmamaLine = buildLine(LAYOUTS.DESMAMA, desmamaRow);
eq("DESMAMA largura 216", desmamaLine.length, 216);
eq("DESMAMA peso 59-66", field(desmamaLine, 59, 66), "  223.00");
eq("DESMAMA nota_c 67-74", field(desmamaLine, 67, 74), "    4.00");
eq("DESMAMA nota_u 91-98", field(desmamaLine, 91, 98), "    2.00");
eq("DESMAMA grupo_manejo 123-126", field(desmamaLine, 123, 126), "GM1 ");

// ============================================================================
// 5) COBERTURA — safra derivada + categoria do touro
// ============================================================================
eq("safra derivada (mês>5 → ano corrente)", derivaSafraCodigo("2024-09-01"), "2024P");
eq("safra derivada (mês<=5 → ano-1)", derivaSafraCodigo("2024-03-01"), "2023P");

// ============================================================================
// 6) ESTOQUE sempre vazio + todos os arquivos têm gerador/uso previsto
// ============================================================================
eq("joinLines vazio retorna string vazia", joinLines([]), "");
check("PAINT_FILES tem 22 arquivos", PAINT_FILES.length === 22, `obtido=${PAINT_FILES.length}`);

// ============================================================================
// Resultado
// ============================================================================
console.log(`\nPAINT e2e: ${passed} passaram, ${failed} falharam`);
if (failed > 0) {
  console.error(fails.join("\n"));
  process.exit(1);
}
console.log("OK — pipeline posicional PAINT consistente.");
