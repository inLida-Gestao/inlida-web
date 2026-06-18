// Gerador de ZIP mínimo no modo STORE (sem compressão).
//
// Substitui a dependência JSZip, cujo `generateAsync` estourava o limite de
// memória/CPU do worker da Edge Function ao montar arquivos grandes (~18MB) em
// contexto background. Aqui o tamanho final é calculado antes, alocamos um
// único Uint8Array e escrevemos cabeçalhos + dados de forma linear (O(n)).

export interface ZipEntry {
  name: string;
  data: Uint8Array;
}

const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
    t[n] = c >>> 0;
  }
  return t;
})();

function crc32(bytes: Uint8Array): number {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < bytes.length; i++) {
    c = CRC_TABLE[(c ^ bytes[i]) & 0xFF] ^ (c >>> 8);
  }
  return (c ^ 0xFFFFFFFF) >>> 0;
}

const LOCAL_HEADER = 30;
const CD_HEADER = 46;
const EOCD = 22;
const DOS_DATE = 0x21; // 1980-01-01

export function buildZipStore(files: ZipEntry[]): Uint8Array {
  const enc = new TextEncoder();
  const entries = files.map((f) => {
    const name = enc.encode(f.name);
    return { name, data: f.data, crc: crc32(f.data) };
  });

  let localSize = 0;
  let cdSize = 0;
  for (const e of entries) {
    localSize += LOCAL_HEADER + e.name.length + e.data.length;
    cdSize += CD_HEADER + e.name.length;
  }
  const out = new Uint8Array(localSize + cdSize + EOCD);
  const dv = new DataView(out.buffer);
  let off = 0;
  const offsets: number[] = [];

  for (const e of entries) {
    offsets.push(off);
    dv.setUint32(off, 0x04034b50, true); off += 4; // local file header sig
    dv.setUint16(off, 20, true); off += 2; // version needed
    dv.setUint16(off, 0, true); off += 2; // flags
    dv.setUint16(off, 0, true); off += 2; // compression = STORE
    dv.setUint16(off, 0, true); off += 2; // mod time
    dv.setUint16(off, DOS_DATE, true); off += 2; // mod date
    dv.setUint32(off, e.crc, true); off += 4;
    dv.setUint32(off, e.data.length, true); off += 4; // compressed size
    dv.setUint32(off, e.data.length, true); off += 4; // uncompressed size
    dv.setUint16(off, e.name.length, true); off += 2;
    dv.setUint16(off, 0, true); off += 2; // extra length
    out.set(e.name, off); off += e.name.length;
    out.set(e.data, off); off += e.data.length;
  }

  const cdStart = off;
  for (let i = 0; i < entries.length; i++) {
    const e = entries[i];
    dv.setUint32(off, 0x02014b50, true); off += 4; // central dir sig
    dv.setUint16(off, 20, true); off += 2; // version made by
    dv.setUint16(off, 20, true); off += 2; // version needed
    dv.setUint16(off, 0, true); off += 2; // flags
    dv.setUint16(off, 0, true); off += 2; // compression
    dv.setUint16(off, 0, true); off += 2; // mod time
    dv.setUint16(off, DOS_DATE, true); off += 2; // mod date
    dv.setUint32(off, e.crc, true); off += 4;
    dv.setUint32(off, e.data.length, true); off += 4;
    dv.setUint32(off, e.data.length, true); off += 4;
    dv.setUint16(off, e.name.length, true); off += 2;
    dv.setUint16(off, 0, true); off += 2; // extra length
    dv.setUint16(off, 0, true); off += 2; // comment length
    dv.setUint16(off, 0, true); off += 2; // disk number start
    dv.setUint16(off, 0, true); off += 2; // internal attrs
    dv.setUint32(off, 0, true); off += 4; // external attrs
    dv.setUint32(off, offsets[i], true); off += 4; // local header offset
    out.set(e.name, off); off += e.name.length;
  }

  const cdSizeActual = off - cdStart;
  dv.setUint32(off, 0x06054b50, true); off += 4; // EOCD sig
  dv.setUint16(off, 0, true); off += 2; // disk number
  dv.setUint16(off, 0, true); off += 2; // cd start disk
  dv.setUint16(off, entries.length, true); off += 2; // entries this disk
  dv.setUint16(off, entries.length, true); off += 2; // total entries
  dv.setUint32(off, cdSizeActual, true); off += 4; // cd size
  dv.setUint32(off, cdStart, true); off += 4; // cd offset
  dv.setUint16(off, 0, true); off += 2; // comment length

  return out;
}
