// Testes de regras de domínio PAINT (paint_mappers.ts).
// Executar: deno test scripts/paint-mappers-parity.test.ts
//
// Objetivo: travar as regras acordadas nas calls PAINT (03/06) — A12 PO com
// série do registro (JLK), brinco sem sigla, categorias e composição.

import { assertEquals } from "https://deno.land/std@0.177.0/testing/asserts.ts";
import {
  a12FromRebanho,
  extractAnimal5,
  extractBrinco5,
  extractSerieRegistro,
  isAnimalPO,
  mapCategoriaAnterior,
  mapCategoriaPaint,
  mapRacaPaint,
  mapTipoRegistro,
  resolveSerieA12,
  resolveSeriePoFromAnimal,
} from "../supabase/functions/paint-export/lib/paint_mappers.ts";

const configCachoeira = {
  serie_fazenda: "0001",
  serie_raca_po: "JLK",
  programa: "P",
  estrategia_a12: "compacto" as const,
  campo_origem_animal: "numeroAnimal",
};

Deno.test("brinco PO ignora sigla JLK e mantém 5 dígitos", () => {
  assertEquals(extractBrinco5("JLK4705"), "4705");
  assertEquals(extractBrinco5("JLK123456"), "12345");
  assertEquals(extractBrinco5("00890"), "00890");
});

Deno.test("animal do A12 usa apenas dígitos", () => {
  assertEquals(extractAnimal5("JLK4705"), "4705");
  assertEquals(extractAnimal5("4705"), "4705");
});

Deno.test("tipo de registro PO inferido por raça", () => {
  assertEquals(mapTipoRegistro({ raca: "NELORE PO" }), "PO");
  assertEquals(mapTipoRegistro({ tipo_registro: "CL" }), "CL");
  assertEquals(mapTipoRegistro({ raca: "NELORE" }), "");
});

Deno.test("extractSerieRegistro lê sigla antes dos dígitos", () => {
  assertEquals(extractSerieRegistro("JLK4705"), "JLK");
  assertEquals(extractSerieRegistro("JLK 4705"), "JLK");
  assertEquals(extractSerieRegistro("JLK-4705"), "JLK");
  assertEquals(extractSerieRegistro("4705"), "");
  assertEquals(extractSerieRegistro("NELORE"), "");
});

Deno.test("animal PO usa série do registro (JLK) no A12", () => {
  const po = { numeroAnimal: "JLK4705", dataNascimento: "2018-09-01", raca: "NELORE PO" };
  assertEquals(isAnimalPO(po), true);
  assertEquals(resolveSeriePoFromAnimal(po), "JLK");
  assertEquals(resolveSerieA12(po, configCachoeira), "JLK");
  // P + "JLK " (série 4) + "4705 " (animal 5, esq.) + 18
  assertEquals(a12FromRebanho(configCachoeira, po), "PJLK 4705 18");
});

Deno.test("série PO inferida do animal sem config", () => {
  const configSemSerie = { ...configCachoeira, serie_raca_po: null };
  const po = { numeroAnimal: "JLK4705", dataNascimento: "2018-09-01", raca: "NELORE PO" };
  assertEquals(resolveSerieA12(po, configSemSerie), "JLK");
  assertEquals(a12FromRebanho(configSemSerie, po), "PJLK 4705 18");
});

Deno.test("série PO inferida do codRegistro quando brinco só tem dígitos", () => {
  const configSemSerie = { ...configCachoeira, serie_raca_po: null };
  const po = {
    numeroAnimal: "4705",
    codRegistro: "JLK4705",
    dataNascimento: "2018-09-01",
    raca: "NELORE PO",
  };
  assertEquals(resolveSeriePoFromAnimal(po), "JLK");
  assertEquals(resolveSerieA12(po, configSemSerie), "JLK");
});

Deno.test("série PO usa fallback da config quando animal sem sigla", () => {
  const po = { numeroAnimal: "4705", dataNascimento: "2018-09-01", raca: "NELORE PO" };
  assertEquals(resolveSeriePoFromAnimal(po), "");
  assertEquals(resolveSerieA12(po, configCachoeira), "JLK");
});

Deno.test("animal não-PO usa série da fazenda no A12", () => {
  const cl = { numeroAnimal: "890", dataNascimento: "2020-06-10", raca: "NELORE" };
  assertEquals(resolveSerieA12(cl, configCachoeira), "0001");
  // P + 0001 + "890  " + 20
  assertEquals(a12FromRebanho(configCachoeira, cl), "P0001890  20");
});

Deno.test("raça mapeia para código de 2 letras", () => {
  assertEquals(mapRacaPaint("Nelore"), "NE");
  assertEquals(mapRacaPaint("Nelore Mocho"), "NO");
  assertEquals(mapRacaPaint("Red Angus"), "AR");
  assertEquals(mapRacaPaint(""), "NE");
});

Deno.test("categoria por evento e categoria anterior", () => {
  assertEquals(mapCategoriaPaint({ sexo: "M", status: "VENDIDO" }), "VD");
  assertEquals(mapCategoriaPaint({ sexo: "M", data_morte: "2024-01-01" }), "MT");
  assertEquals(mapCategoriaPaint({ sexo: "M", dataDesmama: "2024-01-01" }), "AD");
  assertEquals(mapCategoriaPaint({ sexo: "M" }), "AM");
  assertEquals(mapCategoriaPaint({ sexo: "F", categoria: "Novilha" }), "NV");
  assertEquals(mapCategoriaAnterior("AD"), "AM");
  assertEquals(mapCategoriaAnterior("NV"), "AD");
});

// ---------------------------------------------------------------------------
// A12 posicional: Programa(1) + Série(4, à esquerda) + Animal(5, à esquerda) +
// Ano(2). Os casos abaixo são os A12 REAIS que o PAINT tem da Cachoeira
// (paint_animal_a12) — travam o bug em que a estratégia 'espacado' montava o
// A12 por concatenação com separadores e desalinhava o ano quando o número não
// tinha exatamente 4 dígitos.
// ---------------------------------------------------------------------------
const configEspacado = {
  serie_fazenda: "460",
  serie_raca_po: "JLK",
  programa: "P",
  estrategia_a12: "espacado" as const,
  campo_origem_animal: "numeroAnimal",
};

Deno.test("A12 tem sempre 12 chars com o ano nas posições 11-12", () => {
  for (const numero of ["7", "10", "100", "1163", "12345", "JLK4705"]) {
    const a12 = a12FromRebanho(configEspacado, {
      numeroAnimal: numero,
      dataNascimento: "2020-04-06",
      raca: "NELORE",
    });
    assertEquals(a12.length, 12, `tamanho de "${a12}"`);
    assertEquals(a12.slice(10, 12), "20", `ano de "${a12}"`);
  }
});

Deno.test("A12 espaçado bate com o que o PAINT já tem (2, 3 e 4 dígitos)", () => {
  const a12 = (numero: string, nasc: string) =>
    a12FromRebanho(configEspacado, {
      numeroAnimal: numero,
      dataNascimento: nasc,
      raca: "NELORE",
    });
  assertEquals(a12("77", "2020-01-10"), "P460 77   20");
  assertEquals(a12("222", "2020-01-10"), "P460 222  20");
  assertEquals(a12("1163", "2021-01-10"), "P460 1163 21");
  // Print da cliente (06/04/2020 e 28/07/2020):
  assertEquals(a12("10", "2020-04-06"), "P460 10   20");
  assertEquals(a12("100", "2020-07-28"), "P460 100  20");
});

Deno.test("estratégia 'espacado' é apelido de 'compacto'", () => {
  for (const numero of ["7", "77", "222", "1163", "12345"]) {
    const animal = {
      numeroAnimal: numero,
      dataNascimento: "2021-05-05",
      raca: "NELORE",
    };
    assertEquals(
      a12FromRebanho(configEspacado, animal),
      a12FromRebanho({ ...configEspacado, estrategia_a12: "compacto" }, animal),
      `número ${numero}`,
    );
  }
});

Deno.test("A12 PO usa a série do registro sem perder o ano", () => {
  const po = {
    numeroAnimal: "JLK 305",
    dataNascimento: "2023-02-01",
    raca: "NELORE PO",
  };
  assertEquals(a12FromRebanho(configEspacado, po), "PJLK 305  23");
});

Deno.test("código curto alfanumérico segue só-dígitos (exceção = A12 oficial)", () => {
  // Manter/derrubar a letra NÃO é derivável: o PAINT tem 'T001' como
  // 'P460 T001 21' (letra fica) mas 'G222' como 'P460 222  20' (letra cai).
  // A regra geral fica em só-dígitos; T001 é exceção registrada em
  // paint_animal_a12 (A12 oficial), honrada com precedência pelo export.
  const cfg = { ...configEspacado, serie_fazenda: "460" };
  const a12 = (numero: string) =>
    a12FromRebanho(cfg, {
      numeroAnimal: numero,
      dataNascimento: "2021-01-01",
      raca: "NELORE",
    });
  assertEquals(a12("T001"), "P460 001  21");
  assertEquals(a12("G222"), "P460 222  21");
  assertEquals(extractAnimal5("T001"), "001");
  assertEquals(extractAnimal5("JLK4705"), "4705");
  assertEquals(extractAnimal5("0001 A"), "0001");
  assertEquals(extractAnimal5("ZEB8121"), "8121");
  assertEquals(extractAnimal5("766913 TUL"), "76691");
});
