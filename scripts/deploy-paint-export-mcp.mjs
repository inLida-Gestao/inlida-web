#!/usr/bin/env node
/**
 * Lê supabase/functions/paint-export e grava .mcp-deploy-args.json.
 * O deploy em si é feito via MCP `deploy_edge_function` (user-supabase-inlida).
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");
const base = path.join(root, "supabase/functions/paint-export");
const names = [
  "index.ts",
  "lib/fixed-width.ts",
  "lib/generators.ts",
  "lib/layouts.ts",
  "lib/sql.ts",
];

const files = names.map((name) => ({
  name,
  content: fs.readFileSync(path.join(base, name), "utf8"),
}));

const payload = {
  name: "paint-export",
  entrypoint_path: "index.ts",
  verify_jwt: true,
  files,
};

const out = path.join(root, ".mcp-deploy-args.json");
fs.writeFileSync(out, JSON.stringify(payload));
console.log(
  JSON.stringify({
    ok: true,
    out,
    bytes: fs.statSync(out).size,
    files: files.map((f) => ({ name: f.name, chars: f.content.length })),
  }),
);
