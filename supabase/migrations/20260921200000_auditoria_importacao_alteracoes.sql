-- O que EXATAMENTE mudou em cada registro sobrescrito por uma importacao.
--
-- Por que: a auditoria registrava o evento ("o animal 1204 foi atualizado") e
-- os problemas detectados, mas nao o conteudo. Se o peso 480 virou 48, ou se
-- uma coluna em branco na planilha apagou a data de desmama, nao havia como
-- saber o que era antes -- e a sobrescrita e justamente o que o upsert da
-- importacao faz em silencio. Nenhum dos 13 triggers de `rebanho` guarda valor
-- anterior; a unica excecao no projeto e a troca de lote, em
-- rebanho_lote_movimentacoes.
--
-- Uma linha por REGISTRO atualizado, e nao por campo: numa importacao que
-- atualiza 5 mil animais isso da 5 mil linhas, contra dezenas de milhares se
-- fosse por campo. Os campos vao num jsonb, e apenas os que de fato mudaram.
--
-- Formato de `campos`:
--   {"pesoAtual": {"de": "480", "para": "48"},
--    "dataDesmama": {"de": "2024-08-10", "para": null}}
-- `para` nulo significa que a planilha veio em branco e o valor sera apagado.
create table if not exists public.import_auditoria_alteracao (
  id             bigserial primary key,
  auditoria_id   uuid not null
    references public.import_auditoria(id) on delete cascade,
  linha          integer,
  chave_negocio  text,
  identificacao  text,
  campos         jsonb not null default '{}'::jsonb,
  total_campos   integer not null default 0,
  total_apagados integer not null default 0,
  created_at     timestamptz not null default now()
);

create index if not exists import_auditoria_alteracao_auditoria_idx
  on public.import_auditoria_alteracao (auditoria_id, linha);
create index if not exists import_auditoria_alteracao_chave_idx
  on public.import_auditoria_alteracao (chave_negocio)
  where chave_negocio is not null;

alter table public.import_auditoria_alteracao enable row level security;

drop policy if exists import_auditoria_alteracao_rw
  on public.import_auditoria_alteracao;
create policy import_auditoria_alteracao_rw on public.import_auditoria_alteracao
  for all to authenticated
  using (
    auditoria_id in (
      select a.id from public.import_auditoria a
      where a.id_propriedade in (
        select up."idPropriedade" from public.users_propriedades up
        where up.user_id = auth.uid()::text
          and coalesce(up.deletado, 'NAO') = 'NAO'
      )
    )
  )
  with check (
    auditoria_id in (
      select a.id from public.import_auditoria a
      where a.id_propriedade in (
        select up."idPropriedade" from public.users_propriedades up
        where up.user_id = auth.uid()::text
          and coalesce(up.deletado, 'NAO') = 'NAO'
      )
    )
  );

alter table public.import_auditoria
  add column if not exists alteracoes_truncadas boolean not null default false;

comment on table public.import_auditoria_alteracao is
  'Diff campo a campo dos registros sobrescritos por importacao de planilha.';
