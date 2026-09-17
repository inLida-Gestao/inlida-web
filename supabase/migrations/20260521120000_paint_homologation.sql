-- PAINT homologação 000460: config A12, estoque, exclusões, RAH 4 campos.

-- Config A12 por fazenda
alter table public.paint_fazenda_config
  add column if not exists programa char(1) not null default 'P',
  add column if not exists estrategia_a12 text not null default 'compacto'
    check (estrategia_a12 in ('compacto', 'espacado', 'ultimos_digitos_nome')),
  add column if not exists campo_origem_animal text not null default 'numeroAnimal'
    check (campo_origem_animal in ('numeroAnimal', 'nome', 'chip', 'codRegistro'));

-- Av. matrizes: Frame + Pigmentação (spec cliente R/F/A/P)
alter table public.paint_avaliacao_rah
  add column if not exists frame numeric(4,2),
  add column if not exists pigmentacao numeric(4,2);

-- Estoque de sêmen/doses (ESTOQUE.TXT)
create table if not exists public.paint_estoque (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  touro_a12 char(12) not null,
  codigo_lote varchar(30),
  descricao varchar(30) not null,
  data_aquisicao date,
  tipo_operacao varchar(10) default 'COMPRA',
  quantidade_doses numeric(10,2),
  valor_unitario numeric(10,2),
  valor_total numeric(10,2),
  coeficiente numeric(8,2),
  codigo_partida varchar(10),
  status_semen char(4),
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists paint_estoque_prop_idx
  on public.paint_estoque (id_propriedade);

alter table public.paint_estoque enable row level security;

create policy paint_estoque_rw on public.paint_estoque
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

drop trigger if exists paint_estoque_set_updated_at on public.paint_estoque;
create trigger paint_estoque_set_updated_at before update on public.paint_estoque
  for each row execute function public.paint_set_updated_at();

-- Registros excluídos para arquivos *_DELETE.TXT na próxima exportação
create table if not exists public.paint_registro_excluido (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  entidade text not null,
  chave text not null,
  payload jsonb not null default '{}',
  exportado_em timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists paint_registro_excluido_prop_ent_idx
  on public.paint_registro_excluido (id_propriedade, entidade)
  where exportado_em is null;

alter table public.paint_registro_excluido enable row level security;

create policy paint_registro_excluido_rw on public.paint_registro_excluido
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
