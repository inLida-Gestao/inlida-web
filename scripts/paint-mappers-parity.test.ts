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
