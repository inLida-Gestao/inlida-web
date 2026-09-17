-- Impede que eventos operacionais do Inlida sejam transmitidos como avaliações
-- PAINT. DESMAMA.TXT e ANO_SOBREANO.TXT só podem usar avaliações que vieram da
-- importação explícita da planilha PAINT.

alter table public.paint_avaliacao_desmama
  add column if not exists origem text not null default 'manual';

alter table public.paint_avaliacao_sobreano
  add column if not exists origem text not null default 'manual';

alter table public.paint_avaliacao_desmama
  drop constraint if exists paint_avaliacao_desmama_origem_check;

alter table public.paint_avaliacao_desmama
  add constraint paint_avaliacao_desmama_origem_check
  check (origem in ('importacao_paint', 'manual', 'inlida_auto', 'pendente_revisao'));

alter table public.paint_avaliacao_sobreano
  drop constraint if exists paint_avaliacao_sobreano_origem_check;

alter table public.paint_avaliacao_sobreano
  add constraint paint_avaliacao_sobreano_origem_check
  check (origem in ('importacao_paint', 'manual', 'inlida_auto', 'pendente_revisao'));

-- Registros históricos não têm trilha de origem. Não é seguro inferir que uma
-- linha completa veio de uma planilha: ela pode ter sido criada manualmente ou
-- pelo fluxo automático antigo. Por isso, nenhum histórico é transmitido até
-- ser reimportado pela planilha PAINT, quando receberá `importacao_paint`.
update public.paint_avaliacao_desmama
set origem = 'pendente_revisao';

update public.paint_avaliacao_sobreano
set origem = 'pendente_revisao';

create index if not exists paint_avaliacao_desmama_export_origem_idx
  on public.paint_avaliacao_desmama (id_propriedade, origem, id);

create index if not exists paint_avaliacao_sobreano_export_origem_idx
  on public.paint_avaliacao_sobreano (id_propriedade, origem, id);
