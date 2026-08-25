// Regras de domínio PAINT compartilhadas pelos geradores de exportação.
// Fonte única de verdade (espelhada em lib/custom_code/actions/paint_mappers.dart).
//
// Prioridade das regras: calls PAINT 03/06 > manuais oficiais > sample 000460.
// Ver plano "Plano executável PAINT".

import { formatA12 as formatA12Posicional, type EstrategiaA12 } from "./fixed-width.ts";

export interface PaintA12Config {
  serie_fazenda: string;
  serie_raca_po?: string | null;
  programa?: string | null;
  estrategia_a12?: EstrategiaA12 | null;
  campo_origem_animal?: string | null;
}

function asText(value: unknown): string {
  return value === null || value === undefined ? "" : String(value).trim();
}

// ---------------------------------------------------------------------------
// Tipo de registro (livro) — manual §11.4. Call PAINT: PO obrigatório; demais
// CL ou vazio.
// ---------------------------------------------------------------------------
const TIPOS_REGISTRO_VALIDOS = new Set(["PO", "POI", "CEIP", "CL", "LA", "LA1"]);

export function mapTipoRegistro(animal: Record<string, unknown>): string {
  const explicito = asText(animal.tipo_registro).toUpperCase();
  if (TIPOS_REGISTRO_VALIDOS.has(explicito)) return explicito;
  // Inferência: "Nelore PO" no nome da raça → PO.
  const raca = asText(animal.raca).toUpperCase();
  if (/\bPO\b/.test(raca) || raca.includes("PURO DE ORIGEM")) return "PO";
  return "";
}

export function isAnimalPO(animal: Record<string, unknown>): boolean {
  const tipo = mapTipoRegistro(animal);
  return tipo === "PO" || tipo === "POI" || tipo === "CEIP";
}

// ---------------------------------------------------------------------------
// Série usada no A12. PO: animal → config (serie_raca_po) → série fazenda;
// demais → série da fazenda.
// ---------------------------------------------------------------------------
export function extractSerieRegistro(numero: unknown): string {
  const raw = asText(numero).toUpperCase();
  if (!raw) return "";
  const match = /^([A-Z]{2,4})(?=[\s\-_/]?\d)/.exec(raw);
  return match ? match[1] : "";
}

export function resolveSeriePoFromAnimal(animal: Record<string, unknown>): string {
  for (const key of ["numeroAnimal", "codRegistro"] as const) {
    const serie = extractSerieRegistro(animal[key]);
    if (serie) return serie;
  }
  return "";
}

export function resolveSerieA12(
  animal: Record<string, unknown>,
  config: PaintA12Config,
): string {
  if (!isAnimalPO(animal)) return asText(config.serie_fazenda);
  const fromAnimal = resolveSeriePoFromAnimal(animal);
  if (fromAnimal) return fromAnimal;
  const seriePO = asText(config.serie_raca_po);
  if (seriePO) return seriePO;
  return asText(config.serie_fazenda);
}

// ---------------------------------------------------------------------------
// Identificação do animal para o A12 (campo Animal, 5 chars). A sigla do
// registro (ex.: JLK) NÃO entra na numeração — usamos apenas os dígitos.
// ---------------------------------------------------------------------------
// ATENÇÃO: manter/derrubar a letra de códigos curtos (T001, G222) NÃO é
// derivável — é decisão de cadastro do PAINT. Dados reais da Cachoeira provam
// os dois padrões: o PAINT tem o touro T001 como 'P460 T001 21' (letra fica)
// e o touro G222 como 'P460 222  20' (letra cai). A regra geral fica em "só
// dígitos"; exceções (T001) são registradas por animal em paint_animal_a12
// (A12 oficial), que o export honra com precedência.
export function extractAnimal5(numero: unknown): string {
  const raw = asText(numero);
  const digits = raw.replace(/\D/g, "");
  const base = digits.length > 0 ? digits : raw;
  return base.length > 5 ? base.slice(0, 5) : base;
}

// Brinco de manejo (ani_brinco): 5 dígitos numéricos, sem sigla de registro.
export function extractBrinco5(numero: unknown): string {
  const digits = asText(numero).replace(/\D/g, "");
  return digits.length > 5 ? digits.slice(0, 5) : digits;
}

// ---------------------------------------------------------------------------
// A12 — Programa(1) + Série(4) + Animal(5) + Ano(2). PO-aware.
// ---------------------------------------------------------------------------
function normalizaTexto(v: unknown): string {
  return String(v ?? "")
    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .trim().toUpperCase().replace(/\s+/g, " ");
}

// O A12 deve vir do código de registro, e NÃO ser gerado, quando:
//  - status "Sêmen": reprodutor externo/dose, não tem origem e o A12 dele é o
//    do rebanho de origem — sempre obrigatório;
//  - origem "Compra": o animal veio de outra fazenda com A12 já formado lá.
// Origem "Nascimento" (ou vazia) segue gerando o A12 da fazenda normalmente.
export function exigeA12DoCodRegistro(animal: Record<string, unknown>): boolean {
  if (normalizaTexto(animal.status) === "SEMEN") return true;
  return normalizaTexto(animal.origem) === "COMPRA";
}

// Código de registro usado como A12, quando ele de fato tem a forma de um A12
// (12 chars posicionais terminando em 2 dígitos de ano). Cadastros que guardam
// o registro mesmo — "CEIP 01893/23", "RGD SABB367", "OK3652 (*) F" — não são
// A12 e devolvem vazio: a geração automática fica bloqueada, e a validação da
// exportação lista quem precisa de cadastro.
export function a12DoCodRegistro(animal: Record<string, unknown>): string {
  const cr = asText(animal.codRegistro);
  return partesDoA12(cr) ? cr : "";
}

export function a12FromRebanho(
  config: PaintA12Config,
  animal: Record<string, unknown>,
): string {
  // CONDIÇÃO ANTERIOR À FORMAÇÃO (regra da cliente 25/08/2026): animal que não
  // nasceu aqui já tem A12 de outra fazenda, gravado no código de registro.
  // Gerar um A12 da nossa série criaria um animal NOVO no PAINT em vez de
  // referenciar o que já existe. Vale independente do status.
  if (exigeA12DoCodRegistro(animal)) return a12DoCodRegistro(animal);

  const campo = config.campo_origem_animal ?? "numeroAnimal";
  let origem = asText(animal.numeroAnimal);
  if (campo === "nome") origem = asText(animal.nome) || origem;
  else if (campo === "chip") origem = asText(animal.chip) || origem;
  else if (campo === "codRegistro") origem = asText(animal.codRegistro) || origem;

  const dataNasc = asText(animal.dataNascimento);
  if (!origem || !dataNasc) return "";
  const nasc = new Date(dataNasc);
  if (isNaN(nasc.getTime())) return "";

  return formatA12Posicional({
    programa: config.programa ?? "P",
    serieFazenda: resolveSerieA12(animal, config),
    animal: extractAnimal5(origem),
    ano: nasc.getUTCFullYear().toString(),
    estrategia: (config.estrategia_a12 ?? "compacto") as EstrategiaA12,
  });
}

// ---------------------------------------------------------------------------
// Decomposição de um A12 já formado (usado quando o A12 vem do PAINT, não do
// nosso cálculo — ver paint_animal_a12). O A12 é posicional:
// Programa(1) + Série(4) + Animal(5) + Ano(2). Com a estratégia 'espacado' os
// separadores caem DENTRO dos campos de série/animal, então o `trim` de cada
// segmento devolve o valor certo nas duas estratégias:
//   "P460 1163 21" -> P / 460 / 1163 / 21
//   "pJLK 1043 21" -> p / JLK / 1043 / 21
// ---------------------------------------------------------------------------
export interface A12Partes {
  programa: string;
  serie: string;
  animal: string;
  ano: string;
}

export function partesDoA12(a12: unknown): A12Partes | null {
  const raw = a12 === null || a12 === undefined ? "" : String(a12);
  if (raw.trim() === "" || raw.length > 12) return null;
  const p = raw.padEnd(12, " ");
  const ano = p.slice(10, 12);
  if (!/^\d{2}$/.test(ano)) return null;
  return {
    programa: p.slice(0, 1),
    serie: p.slice(1, 5).trim(),
    animal: p.slice(5, 10).trim(),
    ano,
  };
}

// Chaves "dig5|ano2" candidatas para casar um A12 (de qualquer origem) com o
// animal do rebanho, ignorando programa e série. Tenta a leitura posicional e,
// como rede, a tokenizada (A12 legado/espaçado com número deslocado).
export function digAnoCandidates(a12: unknown): string[] {
  const raw = a12 === null || a12 === undefined ? "" : String(a12);
  if (raw.trim() === "") return [];
  const out: string[] = [];
  const push = (dig: string, ano: string) => {
    const d = dig.replace(/\D/g, "").slice(0, 5);
    if (d && /^\d{2}$/.test(ano)) {
      const k = `${d}|${ano}`;
      if (!out.includes(k)) out.push(k);
    }
  };
  const partes = partesDoA12(raw);
  if (partes) push(partes.animal, partes.ano);
  // Fallback tokenizado: "<prog><serie> <numero> <ano>"
  const toks = raw.trim().split(/\s+/).filter((t) => t !== "");
  if (toks.length >= 2) {
    push(toks[toks.length - 2], toks[toks.length - 1].replace(/\D/g, "").slice(-2));
  }
  return out;
}

// ---------------------------------------------------------------------------
// Raça — tabela §11.1. Mapeamento unificado (espelho de mapRacaCodigo Dart).
// ---------------------------------------------------------------------------
const RACA_ALIASES: Array<[RegExp, string]> = [
  [/NELORE\s*MOCHO/, "NO"],
  [/NELORE/, "NE"],
  [/RED\s*ANGUS/, "AR"],
  [/ANGUS/, "AR"],
  [/BRAHMAN\s*RED/, "RR"],
  [/BRAHMAN/, "BR"],
  [/GUZER/, "GZ"],
  [/SENEPOL/, "SE"],
  [/SIMENTAL/, "SM"],
  [/TABAPU/, "TB"],
  [/INDU\s*BRASIL/, "IB"],
  [/CHAROLES/, "CH"],
  [/CHIANINA/, "CA"],
  [/CARACU/, "CR"],
  [/LIMOUSIN/, "LM"],
  [/PARDO\s*SUI/, "SB"],
  [/RED\s*POLL/, "RP"],
  [/HEREFORD/, "HH"],
  [/\bGIR\b/, "GY"],
  [/\bSINDI\b/, "SD"],
];

export function mapRacaPaint(raca: unknown): string {
  const r = asText(raca)
    .toUpperCase()
    .replace(/[ÁÀÂÃ]/g, "A")
    .replace(/[ÉÊ]/g, "E")
    .replace(/Í/g, "I")
    .replace(/[ÓÔÕ]/g, "O")
    .replace(/[ÚÜ]/g, "U")
    .replace(/Ç/g, "C");
  if (!r || r === "NULL") return "NE";
  for (const [re, code] of RACA_ALIASES) {
    if (re.test(r)) return code;
  }
  // Já é um código de 2 letras conhecido?
  if (r.length >= 2) return r.slice(0, 2);
  return "NE";
}

// ---------------------------------------------------------------------------
// Categoria PAINT — tabela §11.2 (AD/AM/GN/MT/NV/RF/TM/TS/TT/VB/VD/VT).
// Atribuição automática por eventos; call PAINT: muda conforme evento, sem
// histórico. Suporta override manual via animal.categoria_paint.
// ---------------------------------------------------------------------------
export function mapCategoriaPaint(animal: Record<string, unknown>): string {
  const override = asText(animal.categoria_paint).toUpperCase();
  if (override) return override;

  const status = asText(animal.status).toUpperCase();
  if (status === "VENDIDO" || animal.dataVenda) return "VD";
  if (status === "MORTO" || animal.data_morte) return "MT";

  const sexo = asText(animal.sexo).toUpperCase().slice(0, 1);
  const cat = asText(animal.categoria).toUpperCase();
  const temDesmama = !!animal.dataDesmama;

  if (cat.includes("TOURO MULTIPLO") || cat.includes("MÚLTIPLO")) return "TM";
  if (cat.includes("TOURO") || cat.includes("REPRODUTOR")) return "TT";
  if (cat.includes("RUFI")) return "RF";

  if (sexo === "M") return temDesmama ? "AD" : "AM";
  // Fêmeas
  if (cat.includes("VACA")) return "VB";
  if (cat.includes("NOVILHA")) return "NV";
  if (temDesmama) return "VT";
  return "AM";
}

// Categoria anterior — manual ANIMAL campo 031. Derivação simples por evento,
// sem manter histórico (call PAINT). Ex.: animal AD veio de AM.
export function mapCategoriaAnterior(categoriaAtual: string): string {
  switch (categoriaAtual) {
    case "AD":
      return "AM";
    case "NV":
    case "VT":
      return "AD";
    case "VB":
      return "NV";
    default:
      return "";
  }
}

// ---------------------------------------------------------------------------
// Baixa (ANIMAL.ani_baixa) — manual campo 026.
// ---------------------------------------------------------------------------
export function mapBaixaMotivo(motivo: unknown): string {
  const m = asText(motivo).toUpperCase();
  if (m === "MORTE") return "MT";
  if (m === "VENDA") return "VD";
  if (m === "DESCARTE") return "DC";
  if (m === "EXCLUSAO") return "DE";
  return "";
}

// ---------------------------------------------------------------------------
// Tipo de cobertura — tabela §11.3 (R/I/C/E/F).
// ---------------------------------------------------------------------------
export function mapTipoCobertura(tipo: unknown): string {
  const t = asText(tipo).toUpperCase();
  if (t.includes("IATF")) return "F";
  if (t.includes("INSEMINA")) return "I";
  if (t.includes("MONTA CONTROL")) return "C";
  if (t.includes("EMBRI")) return "E";
  return "R";
}

// ---------------------------------------------------------------------------
// Código de safra — manual §8.5: ano + sigla estação (P/V/O/I), janela
// 01/06–31/05. Heurística: mês <= 5 → ano-1 (estação anterior).
// ---------------------------------------------------------------------------
export function derivaSafraCodigo(data: unknown, tag = "P"): string {
  if (!data) return "";
  const d = new Date(String(data));
  if (isNaN(d.getTime())) return "";
  const m = d.getUTCMonth() + 1;
  const y = d.getUTCFullYear();
  const safraAno = m <= 5 ? y - 1 : y;
  return `${safraAno}${tag}`;
}

// Largura dos campos de descrição C(20) do PAINT: `grm_descri`, `ins_descri`,
// `lde_descri`, `rga_descri`. É o ÚNICO ponto onde esses textos precisam caber
// em 20 chars — o cadastro e a coluna guardam o texto completo, e o corte
// acontece só ao gerar o arquivo.
export const DESCRI_LEN = 20;

// Índice texto -> código tolerante a truncamento. Registra o texto completo e,
// como fallback, o prefixo de 20 chars: cadastros criados antes do alargamento
// das colunas foram gravados truncados, e é só isso que o PAINT enxerga.
// O match exato tem prioridade — o prefixo só entra se ninguém o reivindicou.
export function indexarPorDescricao(
  linhas: Array<Record<string, unknown>>,
  campoTexto: string,
  campoCodigo = "codigo",
): Map<string, string> {
  const map = new Map<string, string>();
  for (const r of linhas) {
    const texto = asText(r[campoTexto]).toUpperCase();
    const cod = asText(r[campoCodigo]);
    if (!texto || !cod) continue;
    map.set(texto, cod);
    const prefixo = texto.slice(0, DESCRI_LEN);
    if (!map.has(prefixo)) map.set(prefixo, cod);
  }
  return map;
}

// Resolve um texto contra um índice de `indexarPorDescricao`.
export function resolverPorDescricao(
  map: Map<string, string>,
  valor: unknown,
): string {
  const texto = asText(valor).toUpperCase();
  if (!texto) return "";
  return map.get(texto) ?? map.get(texto.slice(0, DESCRI_LEN)) ?? "";
}

// Grupo de manejo a partir do nome do lote — manual §8.4 (lote = grupo).
export function grupoManejoFromLote(
  loteNome: unknown,
  grupoByDescricao: Map<string, string>,
): string {
  return resolverPorDescricao(grupoByDescricao, loteNome);
}
