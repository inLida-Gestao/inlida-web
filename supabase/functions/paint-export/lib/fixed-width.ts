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

// Tipo `C` (caracter): alinha à esquerda, espaço à direita, trunca em fim.
// Tipo `N` (numérico): alinha à direita, espaço à esquerda.
// Tipo `D` (data): sempre 10 chars `dd/mm/aaaa`. Vazio = 10 espaços.
export function pad(value: unknown, field: Field): string {
  if (value === null || value === undefined || value === "") {
    return " ".repeat(field.tam);
  }
  const s = String(value);
  if (field.type === "C") {
    return s.length >= field.tam
      ? s.slice(0, field.tam)
      : s + " ".repeat(field.tam - s.length);
  }
  if (field.type === "N") {
    return s.length >= field.tam
      ? s.slice(-field.tam)
      : " ".repeat(field.tam - s.length) + s;
  }
  // D
  if (s.length === 10) return s;
  return " ".repeat(10);
}

// Garante linha de tamanho exato = max(field.fim) preenchida pelo layout.
export function buildLine(layout: Field[], row: Record<string, unknown>): string {
  const max = Math.max(...layout.map((f) => f.fim));
  const buf = new Array<string>(max).fill(" ");
  for (const f of layout) {
    const padded = pad(row[f.name], f);
    for (let i = 0; i < f.tam; i++) buf[f.ini - 1 + i] = padded[i] ?? " ";
  }
  return buf.join("");
}

// A12 — Manual §7.1 (12 caracteres = Programa(1) + SérieFazenda(4 esquerda)
// + Animal(5 direita, trunca >5 pegando os 5 primeiros) + Ano(2 dígitos)).
export function formatA12(opts: {
  programa?: string | null;
  serieFazenda: string;
  animal: string | number;
  ano: string | number;
}): string {
  const p = (opts.programa ?? "P").toString().slice(0, 1) || "P";
  const serie = opts.serieFazenda.toString();
  const s = (serie.length >= 4 ? serie.slice(0, 4) : serie + " ".repeat(4 - serie.length));
  const aRaw = opts.animal.toString();
  // Manual: "Caso a identificação possua mais de 5 caracteres, então deverá utilizar
  // apenas os 5 dígitos iniciais e descartar o restante."
  // Se <= 5: alinha à direita com espaços à esquerda.
  const a = aRaw.length > 5
    ? aRaw.slice(0, 5)
    : " ".repeat(5 - aRaw.length) + aRaw;
  const yRaw = opts.ano.toString().padStart(2, "0");
  const y = yRaw.length >= 2 ? yRaw.slice(-2) : "0".repeat(2 - yRaw.length) + yRaw;
  return `${p}${s}${a}${y}`;
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
  const out: number[] = [];
  for (const ch of text) {
    const code = ch.codePointAt(0)!;
    if (code <= 0x7F) {
      out.push(code);
    } else if (code <= 0xFF) {
      out.push(code);
    } else {
      const mapped = WIN1252_MAP[ch];
      out.push(mapped ?? 0x3F /* ? */);
    }
  }
  return new Uint8Array(out);
}

// Junta um array de linhas com CRLF + EOL final (sample 000460 usa CRLF).
export function joinLines(lines: string[]): string {
  return lines.length === 0 ? "" : lines.join("\r\n") + "\r\n";
}
