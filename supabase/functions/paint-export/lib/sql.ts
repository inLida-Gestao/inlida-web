// Helpers de consulta paginada para a Edge Function paint-export.
// PostgREST limita a 1000 linhas por request; replica padrão dos exports Excel
// existentes (lib/custom_code/actions/export_reproducao_excel.dart).

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

export const PAGE_SIZE = 1000;

// Carrega todas as linhas em memória. Aceita lista de colunas para reduzir
// payload quando a tabela tem muitas colunas pesadas.
export async function selectAll<T = Record<string, unknown>>(
  supa: SupabaseClient,
  table: string,
  filter: (q: any) => any,
  options?: { columns?: string; orderColumn?: string },
): Promise<T[]> {
  const all: T[] = [];
  let offset = 0;
  const cols = options?.columns ?? "*";
  while (true) {
    let q = supa.from(table).select(cols).range(offset, offset + PAGE_SIZE - 1);
    if (options?.orderColumn) {
      q = q.order(options.orderColumn, { ascending: true });
    }
    q = filter(q);
    const { data, error } = await q;
    if (error) throw new Error(`select ${table}: ${error.message}`);
    const rows = (data ?? []) as T[];
    all.push(...rows);
    if (rows.length < PAGE_SIZE) break;
    offset += PAGE_SIZE;
  }
  return all;
}
