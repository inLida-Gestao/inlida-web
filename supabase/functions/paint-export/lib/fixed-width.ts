// Utilitários de formatação posicional para a exportação PAINT.
// Regras conforme Manual de Implementação §6 + Anexo I (Alinhamento dos campos).

export type FieldType = "C" | "N" | "D";

export interface Field {
  name: string;
  type: FieldType;
  tam: number;
  ini: number; // 1-based
  fim: number; // 1-based, inclusive
}

// Detecta surrogate (codepoint > 0xFFFF representado por 2 unidades UTF-16).
// A largura PAINT é medida em BYTES Windows-1252 e `encodeWin1252` emite 1 byte
// por codepoint; portanto a contagem/corte de `pad` precisa ser por CODEPOINT,
// não por unidade UTF-16, senão um emoji no nome encurta a linha em 1 byte.
function hasSurrogate(s: string): boolean {
  for (let i = 0; i < s.length; i++) {
    const c = s.charCodeAt(i);
    if (c >= 0xD800 && c <= 0xDBFF) return true;
  }
  return false;
}

// Tipo `C` (caracter): alinha à esquerda, espaço à direita, trunca em fim.
// Tipo `N` (numérico): alinha à direita, espaço à esquerda.
// Tipo `D` (data): sempre 10 chars `dd/mm/aaaa`. Vazio = 10 espaços.
export function pad(value: unknown, field: Field): string {
  if (value === null || value === undefined || value === "") {
    return " ".repeat(field.tam);
  }
  const s = String(value);
  if (field.type === "D") {
    // D mede por codepoint para casar com a contagem de bytes do encoder.
    return [...s].length === 10 ? s : " ".repeat(10);
  }
  // Caminho rápido: sem surrogates, `length` UTF-16 == nº de codepoints.
  if (!hasSurrogate(s)) {
    if (field.type === "C") {
      return s.length >= field.tam
        ? s.slice(0, field.tam)
        : s + " ".repeat(field.tam - s.length);
    }
    return s.length >= field.tam
      ? s.slice(-field.tam)
      : " ".repeat(field.tam - s.length) + s;
  }
  // Caminho seguro p/ surrogates: opera por codepoint para garantir largura
  // exata em bytes Windows-1252 (1 codepoint = 1 byte na saída).
  const chars = [...s];
  if (field.type === "C") {
    return chars.length >= field.tam
      ? chars.slice(0, field.tam).join("")
      : s + " ".repeat(field.tam - chars.length);
  }
  return chars.length >= field.tam
    ? chars.slice(chars.length - field.tam).join("")
    : " ".repeat(field.tam - chars.length) + s;
}

interface LayoutMeta {
  max: number;
  // Campos ordenados por posição inicial (layouts PAINT são contíguos, sem
  // sobreposição) — permite montar a linha por concatenação direta, evitando
  // alocar um array de chars por linha (chamado ~70k vezes em props grandes).
  sorted: Field[];
}

const layoutMetaCache = new WeakMap<Field[], LayoutMeta>();
const SPACES = " ".repeat(512);

function spaces(n: number): string {
  return n <= 0 ? "" : (n <= SPACES.length ? SPACES.slice(0, n) : " ".repeat(n));
}

function layoutMeta(layout: Field[]): LayoutMeta {
  let meta = layoutMetaCache.get(layout);
  if (meta === undefined) {
    let max = 0;
    for (const f of layout) if (f.fim > max) max = f.fim;
    const sorted = [...layout].sort((a, b) => a.ini - b.ini);
    meta = { max, sorted };
    layoutMetaCache.set(layout, meta);
  }
  return meta;
}

// Garante linha de tamanho exato = max(field.fim) preenchida pelo layout.
// `pad` sempre devolve exatamente field.tam chars, então basta concatenar os
// campos em ordem e preencher os intervalos com espaços.
export function buildLine(layout: Field[], row: Record<string, unknown>): string {
  const { max, sorted } = layoutMeta(layout);
  let out = "";
  let pos = 0; // próxima coluna esperada (0-based)
  for (const f of sorted) {
    const start = f.ini - 1;
    if (start > pos) out += spaces(start - pos);
    out += pad(row[f.name], f);
    pos = start + f.tam;
  }
  if (pos < max) out += spaces(max - pos);
  return out;
}

export type EstrategiaA12 = "compacto" | "espacado" | "ultimos_digitos_nome";

// A12 — Manual §7.1 + variantes observadas no sample 000460.
export function formatA12(opts: {
  programa?: string | null;
  serieFazenda: string;
  animal: string | number;
  ano: string | number;
  estrategia?: EstrategiaA12 | null;
}): string {
  const estrategia = opts.estrategia ?? "compacto";
  const p = (opts.programa ?? "P").toString().slice(0, 1) || "P";
  const serieRaw = opts.serieFazenda.toString().trim();
  const serie4 = serieRaw.length >= 4
    ? serieRaw.slice(0, 4)
    : serieRaw + " ".repeat(4 - serieRaw.length);
  const yRaw = opts.ano.toString().padStart(2, "0");
  const y = yRaw.length >= 2 ? yRaw.slice(-2) : "0".repeat(2 - yRaw.length) + yRaw;

  let animalPart = opts.animal.toString().trim();
  if (estrategia === "ultimos_digitos_nome") {
    const digits = animalPart.replace(/\D/g, "");
    animalPart = digits.length >= 6 ? digits.slice(-6) : digits;
    return `${p}${serie4}${animalPart}${y}`.slice(0, 12).padEnd(12, " ");
  }

  const aRaw = animalPart;
  // Campo Animal (5): identificação justificada à ESQUERDA, espaço sobra à
  // direita (ex.: "4705 "). Manual A12 = Programa(1)+Série(4)+Animal(5)+Ano(2).
  const a = aRaw.length > 5
    ? aRaw.slice(0, 5)
    : aRaw + " ".repeat(5 - aRaw.length);

  if (estrategia === "espacado") {
    const serieTrim = serie4.trim();
    // Reserva espaço para programa + série + 2 separadores + ano (2). O animal
    // é truncado se necessário para nunca cortar o ano no final.
    const espacoAnimal = Math.max(
      0,
      12 - (p.length + serieTrim.length + 2 + y.length),
    );
    const animalTrim = a.trim().slice(0, espacoAnimal);
    return `${p}${serieTrim} ${animalTrim} ${y}`.padEnd(12, " ").slice(0, 12);
  }

  return `${p}${serie4}${a}${y}`;
}

// Formata Date / ISO string -> dd/mm/aaaa
export function formatDate(value: unknown): string {
  if (value === null || value === undefined || value === "") return " ".repeat(10);
  const d = value instanceof Date ? value : new Date(String(value));
  if (isNaN(d.getTime())) return " ".repeat(10);
  const dd = String(d.getUTCDate()).padStart(2, "0");
  const mm = String(d.getUTCMonth() + 1).padStart(2, "0");
  const yyyy = String(d.getUTCFullYear());
  return `${dd}/${mm}/${yyyy}`;
}

// Formata hora HH:mm:ss
export function formatTime(value: unknown): string {
  if (value === null || value === undefined || value === "") return "        ";
  const d = value instanceof Date ? value : new Date(String(value));
  if (isNaN(d.getTime())) return "        ";
  const hh = String(d.getUTCHours()).padStart(2, "0");
  const mm = String(d.getUTCMinutes()).padStart(2, "0");
  const ss = String(d.getUTCSeconds()).padStart(2, "0");
  return `${hh}:${mm}:${ss}`;
}

// Numérico decimal "99999.99" alinhado à direita em campo de largura `tam`.
// Exemplo do manual: peso = '   223.00' em campo de tam 8.
export function formatNumeric(value: unknown, tam: number, decimals = 2): string {
  if (value === null || value === undefined || value === "") return " ".repeat(tam);
  const n = typeof value === "number" ? value : Number(value);
  if (!isFinite(n)) return " ".repeat(tam);
  const s = n.toFixed(decimals);
  return s.length >= tam ? s.slice(-tam) : " ".repeat(tam - s.length) + s;
}

// UTF-8 -> Windows-1252 (ISO-8859-1 estendido).
// Tabela mínima para chars latinos comuns; outros chars não-mapeáveis -> '?'.
const WIN1252_MAP: Record<string, number> = {
  "€": 0x80, "‚": 0x82, "ƒ": 0x83, "„": 0x84, "…": 0x85, "†": 0x86, "‡": 0x87,
  "ˆ": 0x88, "‰": 0x89, "Š": 0x8A, "‹": 0x8B, "Œ": 0x8C, "Ž": 0x8E, "‘": 0x91,
  "’": 0x92, "“": 0x93, "”": 0x94, "•": 0x95, "–": 0x96, "—": 0x97, "˜": 0x98,
  "™": 0x99, "š": 0x9A, "›": 0x9B, "œ": 0x9C, "ž": 0x9E, "Ÿ": 0x9F,
};

export function encodeWin1252(text: string): Uint8Array {
  // text.length conta unidades UTF-16; cada char latino vira 1 byte. Surrogates
  // (>0xFFFF) usam 2 unidades mas 1 codepoint → super-dimensiona com segurança.
  const out = new Uint8Array(text.length);
  let j = 0;
  for (const ch of text) {
    const code = ch.codePointAt(0)!;
    out[j++] = code <= 0xFF ? code : (WIN1252_MAP[ch] ?? 0x3F /* ? */);
  }
  return j === out.length ? out : out.subarray(0, j);
}

// Junta um array de linhas com CRLF + EOL final (sample 000460 usa CRLF).
export function joinLines(lines: string[]): string {
  return lines.length === 0 ? "" : lines.join("\r\n") + "\r\n";
}
