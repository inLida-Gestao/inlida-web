-- Corrige a importação de Matrizes (RAH): o import grava `origem` nas TRÊS
-- tabelas de avaliação, mas a migração 20260723120000 só adicionou a coluna em
-- desmama e sobreano. Sem ela, importar Matrizes falhava com PGRST204
-- ("Could not find the 'origem' column of 'paint_avaliacao_rah'").
--
-- RAH não é filtrado por origem na exportação (genRah não usa
-- onlyImportedPaintEvaluation), então os registros existentes continuam sendo
-- transmitidos normalmente — a coluna aqui só padroniza o esquema e permite o
-- insert do import.

alter table public.paint_avaliacao_rah
  add column if not exists origem text not null default 'manual';

alter table public.paint_avaliacao_rah
  drop constraint if exists paint_avaliacao_rah_origem_check;

alter table public.paint_avaliacao_rah
  add constraint paint_avaliacao_rah_origem_check
  check (origem in ('importacao_paint', 'manual', 'inlida_auto', 'pendente_revisao'));

-- Recarrega o schema cache do PostgREST para que a nova coluna (e as de
-- desmama/sobreano da migração anterior) sejam reconhecidas imediatamente.
notify pgrst, 'reload schema';
