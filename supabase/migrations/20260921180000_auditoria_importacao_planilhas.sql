-- Auditoria das importacoes de planilha (rebanho e pesagem por enquanto;
-- lotes e reproducao entram quando os respectivos parsers ganharem
-- mapeamento por cabecalho).
--
-- Por que: hoje o pipeline de importacao nao deixa rastro. Linha reprovada
-- sai por print() no console do browser, o total devolvido ao usuario ja e o
-- total pos-descarte, e nao existe nenhuma tabela de log -- de modo que e
-- impossivel (a) achar defeito do pipeline e (b) entender o que os proprios
-- usuarios erram nos arquivos. O suporte so tem a palavra do cliente.
--
-- Desenho em tres tabelas, por causa do volume: uma importacao de 175 mil
-- linhas nao pode gerar 175 mil linhas de detalhe.
--   import_auditoria        -> 1 linha por tentativa, INCLUSIVE as canceladas
--                              (cancelar e o dado mais valioso: o usuario viu
--                              o problema e desistiu).
--   import_auditoria_resumo -> 1 linha por codigo de problema. NUNCA truncado;
--                              no maximo ~60 linhas por importacao. E o que
--                              alimenta a analise.
--   import_auditoria_item   -> amostras do detalhe, truncadas no cliente em
--                              50 por codigo e 1000 por auditoria.
--
-- Molde: paint_export_job (20260508120000_paint_module_init.sql), que ja e o
-- padrao de tabela de job do projeto.
-- Idempotente: pode ser reaplicada sem efeito colateral.

-- =============================================================================
-- 1) Tentativa de importacao
-- =============================================================================
create table if not exists public.import_auditoria (
  id                       uuid primary key default gen_random_uuid(),
  id_propriedade           text not null,
  usuario_id               uuid references auth.users(id) on delete set null,

  entidade                 text not null
    check (entidade in ('rebanho','lotes','reproducao','pesagem')),
  -- Preenchido quando a assinatura do cabecalho aponta para outra planilha:
  -- e o caso "escolhi Rebanho e subi a planilha de Pesagem".
  entidade_detectada       text,

  nome_arquivo             text,
  arquivo_tamanho_bytes    bigint,
  -- Identifica o reenvio do MESMO arquivo sem correcao.
  arquivo_sha1             text,
  formato                  text
    check (formato in ('csv','xlsx','xls','txt','desconhecido')),
  delimitador              text,
  encoding_usado           text,
  aba_usada                text,
  -- KPI do problema mais grave de UX: sem cabecalho reconhecido o parser
  -- mapeia as colunas por posicao e a planilha entra deslocada.
  usou_fallback_posicional boolean not null default false,

  total_linhas             integer not null default 0,
  total_bloqueantes        integer not null default 0,
  total_avisos             integer not null default 0,
  previstos_criar          integer not null default 0,
  previstos_atualizar      integer not null default 0,
  previstos_bloquear       integer not null default 0,
  criados                  integer not null default 0,
  atualizados              integer not null default 0,
  falhados                 integer not null default 0,

  status                   text not null default 'diagnosticando'
    check (status in ('diagnosticando','aguardando_confirmacao','cancelada',
                      'importando','sucesso','parcial','erro')),
  decisao                  text
    check (decisao in ('cancelou','importou_validos','forcou','nao_confirmou')),
  erro                     text,
  itens_truncados          boolean not null default false,

  duracao_parse_ms         integer,
  duracao_diagnostico_ms   integer,
  -- Mede o custo da gravacao. E por aqui que se decide se vale corrigir o
  -- on_conflict descartado pelo postgrest em upsert de lista, que hoje faz o
  -- chunk de 500 falhar inteiro e degradar para requisicoes individuais.
  duracao_escrita_ms       integer,
  app_version              text,

  started_at               timestamptz not null default now(),
  finished_at              timestamptz,
  created_at               timestamptz not null default now()
);

create index if not exists import_auditoria_prop_created_idx
  on public.import_auditoria (id_propriedade, created_at desc);
create index if not exists import_auditoria_entidade_status_idx
  on public.import_auditoria (entidade, status, created_at desc);
create index if not exists import_auditoria_arquivo_sha1_idx
  on public.import_auditoria (id_propriedade, arquivo_sha1)
  where arquivo_sha1 is not null;

-- =============================================================================
-- 2) Resumo por codigo -- sempre completo
-- =============================================================================
create table if not exists public.import_auditoria_resumo (
  id             uuid primary key default gen_random_uuid(),
  auditoria_id   uuid not null
    references public.import_auditoria(id) on delete cascade,
  codigo         text not null,
  severidade     text not null
    check (severidade in ('bloqueante','aviso','informativo')),
  -- Separa defeito de arquivo/dado (pipeline ou preenchimento) de incoerencia
  -- de negocio (manejo). E a divisao que a analise precisa.
  escopo         text not null
    check (escopo in ('arquivo','dado','consistencia','semantica')),
  coluna         text,
  quantidade     integer not null default 0,
  -- jsonb e nao integer[]: o SupabaseDataRow do FlutterFlow nao lida com
  -- arrays do Postgres.
  linhas_amostra jsonb not null default '[]'::jsonb,
  mensagem       text,
  constraint import_auditoria_resumo_unq unique (auditoria_id, codigo, coluna)
);

create index if not exists import_auditoria_resumo_auditoria_idx
  on public.import_auditoria_resumo (auditoria_id);
create index if not exists import_auditoria_resumo_codigo_idx
  on public.import_auditoria_resumo (codigo, severidade);

-- =============================================================================
-- 3) Amostra de ocorrencias -- truncada
-- =============================================================================
create table if not exists public.import_auditoria_item (
  id              bigserial primary key,
  auditoria_id    uuid not null
    references public.import_auditoria(id) on delete cascade,
  linha           integer,
  severidade      text not null
    check (severidade in ('bloqueante','aviso','informativo')),
  escopo          text not null
    check (escopo in ('arquivo','dado','consistencia','semantica')),
  codigo          text not null,
  coluna          text,
  valor           text,
  mensagem        text,
  acao_resultante text check (acao_resultante in ('criar','atualizar','bloquear')),
  created_at      timestamptz not null default now()
);

create index if not exists import_auditoria_item_auditoria_idx
  on public.import_auditoria_item (auditoria_id, codigo, linha);

-- O cliente ja trunca o valor; esta e a guarda contra payload gigante.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'import_auditoria_item_valor_len'
  ) then
    alter table public.import_auditoria_item
      add constraint import_auditoria_item_valor_len
      check (length(coalesce(valor, '')) <= 400) not valid;
  end if;
end $$;

-- =============================================================================
-- 4) RLS -- padrao das tabelas paint_*: subquery em users_propriedades
-- =============================================================================
alter table public.import_auditoria        enable row level security;
alter table public.import_auditoria_resumo enable row level security;
alter table public.import_auditoria_item   enable row level security;

drop policy if exists import_auditoria_rw on public.import_auditoria;
create policy import_auditoria_rw on public.import_auditoria
  for all to authenticated
  using (
    id_propriedade in (
      select up."idPropriedade" from public.users_propriedades up
      where up.user_id = auth.uid()::text
        and coalesce(up.deletado, 'NAO') = 'NAO'
    )
  )
  with check (
    id_propriedade in (
      select up."idPropriedade" from public.users_propriedades up
      where up.user_id = auth.uid()::text
        and coalesce(up.deletado, 'NAO') = 'NAO'
    )
  );

-- As filhas herdam o escopo pela auditoria-mae, que ja e filtrada acima.
drop policy if exists import_auditoria_resumo_rw on public.import_auditoria_resumo;
create policy import_auditoria_resumo_rw on public.import_auditoria_resumo
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

drop policy if exists import_auditoria_item_rw on public.import_auditoria_item;
create policy import_auditoria_item_rw on public.import_auditoria_item
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

-- =============================================================================
-- 5) Retencao
-- Os itens sao amostra de depuracao e envelhecem rapido; o resumo e barato
-- (~60 linhas por importacao) e e o historico analitico, entao vive mais.
-- =============================================================================
create or replace function public.import_auditoria_expurgar(
  p_dias_itens int default 180,
  p_meses_job  int default 24
)
returns table (itens_removidos bigint, jobs_removidos bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_itens bigint;
  v_jobs  bigint;
begin
  delete from public.import_auditoria_item
   where created_at < now() - make_interval(days => p_dias_itens);
  get diagnostics v_itens = row_count;

  delete from public.import_auditoria
   where created_at < now() - make_interval(months => p_meses_job);
  get diagnostics v_jobs = row_count;

  return query select v_itens, v_jobs;
end;
$$;

-- Manutencao e tarefa de servico, nao de usuario final.
revoke all on function public.import_auditoria_expurgar(int, int)
  from public, anon, authenticated;
