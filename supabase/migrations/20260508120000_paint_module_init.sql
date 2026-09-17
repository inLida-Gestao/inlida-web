-- Módulo PAINT — infraestrutura de dados (Fase A do plano)
-- Cria tabelas paint_* (config, lookups, cadastros, avaliações), RLS e bucket de storage.
-- Restrição: nenhum ALTER/DROP em tabelas legadas.

create extension if not exists pgcrypto;

-- =============================================================================
-- Helper: macro de RLS por propriedade (replicada em cada policy abaixo).
-- Padrão: id_propriedade do registro deve estar na lista de propriedades do
-- usuário em users_propriedades (não-deletadas).
-- =============================================================================

-- =============================================================================
-- 1) Config de exportação por propriedade
-- =============================================================================
create table if not exists public.paint_fazenda_config (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null unique,
  codigo_transmissao char(6) not null,
  serie_fazenda varchar(4) not null,
  codigo_fazenda char(4) not null default '0001',
  versao_layout text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint paint_fazenda_config_codigo_transmissao_chk
    check (codigo_transmissao ~ '^[0-9]{6}$'),
  constraint paint_fazenda_config_codigo_fazenda_chk
    check (codigo_fazenda ~ '^[0-9]{4}$')
);

alter table public.paint_fazenda_config enable row level security;

create policy paint_fazenda_config_rw on public.paint_fazenda_config
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

-- =============================================================================
-- 2) Job de exportação
-- =============================================================================
create table if not exists public.paint_export_job (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  usuario_id uuid references auth.users(id) on delete set null,
  status text not null default 'pending'
    check (status in ('pending','running','success','error')),
  nome_zip text,
  storage_path text,
  erro text,
  total_animais int,
  started_at timestamptz,
  finished_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists paint_export_job_prop_created_idx
  on public.paint_export_job (id_propriedade, created_at desc);

alter table public.paint_export_job enable row level security;

create policy paint_export_job_rw on public.paint_export_job
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

-- =============================================================================
-- 3) Lookups globais (sem id_propriedade) — manual §11
-- Leitura aberta a authenticated; escrita não exposta a clients (somente migrations).
-- =============================================================================

-- 3.1 Códigos de raça (manual §11.1) + janelas de gestação (§9)
create table if not exists public.paint_codigo_raca (
  codigo char(2) primary key,
  descricao text not null,
  gestacao_min int,
  gestacao_med int,
  gestacao_max int
);

alter table public.paint_codigo_raca enable row level security;

create policy paint_codigo_raca_ro on public.paint_codigo_raca
  for select to authenticated using (true);

insert into public.paint_codigo_raca (codigo, descricao, gestacao_min, gestacao_med, gestacao_max) values
  ('AF','AFRICANDER',null,null,null),
  ('AN','ABERDEEN',null,null,null),
  ('AR','RED ANGUS',271,281,291),
  ('BB','BELGIAN BLUE',null,null,null),
  ('BD','BLONDE D''AQUITAINE',null,null,null),
  ('BG','BELTED GALLOWAY',null,null,null),
  ('BR','BRAHMAN',null,null,null),
  ('CA','CHIANINA',null,null,null),
  ('CH','CHAROLES',null,null,null),
  ('CR','CARACU',null,null,null),
  ('DE','DEVON',null,null,null),
  ('DL','DUTCH BELTED',null,null,null),
  ('DR','DEXTER',null,null,null),
  ('DS','DEVON SOUTH',null,null,null),
  ('FA','FLAMAND',null,null,null),
  ('GA','GALLOWAY',null,null,null),
  ('GU','GUERNSEY',null,null,null),
  ('GV','GELBVIEH',null,null,null),
  ('GY','GIR',null,null,null),
  ('GZ','GUZERA',285,295,305),
  ('HH','HEREFORD',null,null,null),
  ('IB','INDU BRASIL',null,null,null),
  ('LM','LIMOUSIN',null,null,null),
  ('LR','LINCOLN RED',null,null,null),
  ('MA','MAINE-ANJOU',null,null,null),
  ('MG','MURRAY GREY',null,null,null),
  ('MR','MARCHIGIANA',null,null,null),
  ('NE','NELORE',284,294,304),
  ('NM','NORMANDO',null,null,null),
  ('NO','NELORE MOCHO',284,294,304),
  ('PI','PIEMONTESE',null,null,null),
  ('PZ','PINZGAUER',null,null,null),
  ('RN','ROMAGNOLA',null,null,null),
  ('RP','RED POLL',null,null,null),
  ('RR','BRAHMAN RED',null,null,null),
  ('SA','SALERS',null,null,null),
  ('SB','PARDO SUICO (CORTE)',null,null,null),
  ('SD','SINDI',null,null,null),
  ('SE','SENEPOL',275,285,295),
  ('SH','HIGHLAND (SCOTCH)',null,null,null),
  ('SM','SIMENTAL',276,286,296),
  ('TB','TABAPUA',285,295,305)
on conflict (codigo) do nothing;

-- 3.2 Códigos de categoria (manual §11.2)
create table if not exists public.paint_codigo_categoria (
  codigo char(2) primary key,
  descricao text not null
);

alter table public.paint_codigo_categoria enable row level security;

create policy paint_codigo_categoria_ro on public.paint_codigo_categoria
  for select to authenticated using (true);

insert into public.paint_codigo_categoria (codigo, descricao) values
  ('AD','ANIMAL DESMAMADO'),
  ('AM','ANIMAL MAMANDO'),
  ('GN','GENEALOGIA'),
  ('MT','ANIMAL MORTO'),
  ('NV','NOVILHA'),
  ('RF','RUFIAO/RUFIONA'),
  ('TM','TOURO MULTIPLO'),
  ('TS','SEMEN DO TOURO'),
  ('TT','TOURO'),
  ('VB','VACA COM BEZERRO AO PE'),
  ('VD','ANIMAL VENDIDO'),
  ('VT','VACA SOLTEIRA')
on conflict (codigo) do nothing;

-- 3.3 Tipos de cobertura (manual §11.3)
create table if not exists public.paint_tipo_cobertura (
  codigo char(1) primary key,
  descricao text not null
);

alter table public.paint_tipo_cobertura enable row level security;

create policy paint_tipo_cobertura_ro on public.paint_tipo_cobertura
  for select to authenticated using (true);

insert into public.paint_tipo_cobertura (codigo, descricao) values
  ('R','REGIME DE PASTO/REPASSE'),
  ('I','INSEMINACAO ARTIFICIAL'),
  ('C','MONTA CONTROLADA'),
  ('E','EMBRIAO'),
  ('F','IATF')
on conflict (codigo) do nothing;

-- 3.4 Tipos de registro/livro (manual §11.4)
create table if not exists public.paint_tipo_registro (
  codigo varchar(4) primary key,
  descricao text not null
);

alter table public.paint_tipo_registro enable row level security;

create policy paint_tipo_registro_ro on public.paint_tipo_registro
  for select to authenticated using (true);

insert into public.paint_tipo_registro (codigo, descricao) values
  ('POI','PURO DE ORIGEM IMPORTADA'),
  ('CEIP','CERTIFICADO ESPECIAL DE IDENTIFICACAO E PRODUCAO'),
  ('LA1','LIVRO ABERTO 1'),
  ('PO','PURO DE ORIGEM'),
  ('CL','CARA LIMPA'),
  ('LA','LIVRO ABERTO')
on conflict (codigo) do nothing;

-- 3.5 Programas de melhoramento (manual §11.5)
create table if not exists public.paint_programa_melhoramento (
  codigo char(1) primary key,
  descricao text not null
);

alter table public.paint_programa_melhoramento enable row level security;

create policy paint_programa_melhoramento_ro on public.paint_programa_melhoramento
  for select to authenticated using (true);

insert into public.paint_programa_melhoramento (codigo, descricao) values
  ('A','ALIANCA'),
  ('C','CFM'),
  ('E','EMBRAPA'),
  ('I','IZ'),
  ('P','PAINT'),
  ('U','USP/EMGRM'),
  ('Z','ABCZ/REGISTRADA'),
  ('Q','QUALITAS')
on conflict (codigo) do nothing;

-- 3.6 Regimes alimentares — começa vazia (cadastrado pela fazenda)
create table if not exists public.paint_regime_alimentar (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  codigo varchar(4) not null,
  descricao varchar(20) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, codigo)
);

alter table public.paint_regime_alimentar enable row level security;

create policy paint_regime_alimentar_rw on public.paint_regime_alimentar
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

-- 3.7 Biblioteca de touros PAINT (manual §12) — global, importada de planilha
create table if not exists public.paint_biblioteca_touros (
  a12 char(12) primary key,
  nome text,
  raca char(2) references public.paint_codigo_raca(codigo),
  tipo_registro varchar(4) references public.paint_tipo_registro(codigo),
  pai_a12 char(12),
  mae_a12 char(12),
  rgd text,
  rgn text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.paint_biblioteca_touros enable row level security;

create policy paint_biblioteca_touros_ro on public.paint_biblioteca_touros
  for select to authenticated using (true);

-- =============================================================================
-- 4) Cadastros operacionais por propriedade — campos PAINT sem origem no Inlida
-- =============================================================================

-- 4.1 Avaliador (técnico de campo)
create table if not exists public.paint_avaliador (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  codigo varchar(4) not null,
  nome varchar(25) not null,
  situacao text not null default 'ATIVO' check (situacao in ('ATIVO','INATIVO')),
  enviado_paint boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, codigo)
);

alter table public.paint_avaliador enable row level security;

create policy paint_avaliador_rw on public.paint_avaliador
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

-- 4.2 Grupo de Manejo PAINT (não confundir com lotes do Inlida; manual §8.4)
create table if not exists public.paint_grupo_manejo (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  codigo varchar(4) not null,
  descricao varchar(20) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, codigo)
);

alter table public.paint_grupo_manejo enable row level security;

create policy paint_grupo_manejo_rw on public.paint_grupo_manejo
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

-- 4.3 Localidade (pasto)
create table if not exists public.paint_localidade (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  codigo varchar(4) not null,
  descricao varchar(20) not null,
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, codigo)
);

alter table public.paint_localidade enable row level security;

create policy paint_localidade_rw on public.paint_localidade
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

-- 4.4 Inseminador
create table if not exists public.paint_inseminador (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  codigo varchar(4) not null,
  nome varchar(20) not null,
  situacao text not null default 'ATIVO' check (situacao in ('ATIVO','INATIVO')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, codigo)
);

alter table public.paint_inseminador enable row level security;

create policy paint_inseminador_rw on public.paint_inseminador
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

-- 4.5 Safra (manual §8.5)
create table if not exists public.paint_safra (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  codigo varchar(5) not null, -- ex: 2024P, 2024V, 2024O, 2024I
  descricao varchar(40) not null,
  data_inicio date not null,
  data_final date not null,
  obs text,
  concluida boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, codigo),
  check (data_final >= data_inicio)
);

alter table public.paint_safra enable row level security;

create policy paint_safra_rw on public.paint_safra
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

-- 4.6 Safra x Animal (matrizes que participam)
create table if not exists public.paint_safra_x_animal (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  safra_codigo varchar(5) not null,
  animal_a12 char(12) not null,
  local_codigo varchar(4),
  grupo_manejo_codigo varchar(4),
  concluida boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, safra_codigo, animal_a12)
);

alter table public.paint_safra_x_animal enable row level security;

create policy paint_safra_x_animal_rw on public.paint_safra_x_animal
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

-- 4.7 Touro múltiplo (manual §10) — chave composta múltiplo↔touro
create table if not exists public.paint_touro_multiplo (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  multiplo_a12 char(12) not null,
  touro_a12 char(12) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, multiplo_a12, touro_a12)
);

alter table public.paint_touro_multiplo enable row level security;

create policy paint_touro_multiplo_rw on public.paint_touro_multiplo
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

-- 4.8 Composição racial
create table if not exists public.paint_composicao_racial (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  animal_a12 char(12) not null,
  raca_codigo char(2) not null references public.paint_codigo_raca(codigo),
  indice numeric(7,6) not null check (indice > 0 and indice <= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, animal_a12, raca_codigo)
);

alter table public.paint_composicao_racial enable row level security;

create policy paint_composicao_racial_rw on public.paint_composicao_racial
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

-- 4.9 Baixa (alimentada via app em soft-delete / venda / morte)
create table if not exists public.paint_baixa (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  animal_a12 char(12) not null,
  data_morte date,
  motivo text not null check (motivo in ('MORTE','VENDA','DESCARTE','EXCLUSAO')),
  preco numeric(10,2),
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists paint_baixa_prop_animal_idx
  on public.paint_baixa (id_propriedade, animal_a12);

alter table public.paint_baixa enable row level security;

create policy paint_baixa_rw on public.paint_baixa
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

-- =============================================================================
-- 5) Avaliações PAINT
-- =============================================================================

-- 5.1 Avaliação de desmama
create table if not exists public.paint_avaliacao_desmama (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  animal_a12 char(12) not null,
  data date not null,
  peso numeric(8,2),
  nota_c numeric(4,2),
  nota_p numeric(4,2),
  nota_m numeric(4,2),
  nota_u numeric(4,2),
  situacao_desclass1 varchar(2),
  situacao_desclass2 varchar(2),
  regime_alimentar_codigo varchar(4),
  grupo_manejo_codigo varchar(4),
  avaliador_codigo varchar(4),
  local_codigo varchar(4),
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, animal_a12, data)
);

alter table public.paint_avaliacao_desmama enable row level security;

create policy paint_avaliacao_desmama_rw on public.paint_avaliacao_desmama
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

-- 5.2 Avaliação de sobreano
create table if not exists public.paint_avaliacao_sobreano (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  animal_a12 char(12) not null,
  data date not null,
  peso numeric(8,2),
  nota_c numeric(4,2),
  nota_p numeric(4,2),
  nota_m numeric(4,2),
  nota_u numeric(4,2),
  nota_t numeric(4,2),
  nota_ce numeric(4,2),
  nota_a numeric(4,2),
  situacao_desclass1 varchar(2),
  situacao_desclass2 varchar(2),
  regime_alimentar_codigo varchar(4),
  grupo_manejo_codigo varchar(4),
  avaliador_codigo varchar(4),
  local_codigo varchar(4),
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, animal_a12, data)
);

alter table public.paint_avaliacao_sobreano enable row level security;

create policy paint_avaliacao_sobreano_rw on public.paint_avaliacao_sobreano
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

-- 5.3 Avaliação RAH (raça/aprumo/harmonia — para matrizes)
create table if not exists public.paint_avaliacao_rah (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  animal_a12 char(12) not null,
  data date not null,
  peso numeric(8,2),
  racial numeric(4,2),
  aprumos numeric(4,2),
  harmonia numeric(4,2),
  situacao_desclass varchar(2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, animal_a12, data)
);

alter table public.paint_avaliacao_rah enable row level security;

create policy paint_avaliacao_rah_rw on public.paint_avaliacao_rah
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

-- 5.4 Diagnóstico de gestação
create table if not exists public.paint_diagnostico (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  safra_codigo varchar(5) not null,
  animal_a12 char(12) not null,
  data date not null,
  local_codigo varchar(4),
  grupo_manejo_codigo varchar(4),
  resultado char(1) not null check (resultado in ('P','V')),
  obs text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, safra_codigo, animal_a12, data)
);

alter table public.paint_diagnostico enable row level security;

create policy paint_diagnostico_rw on public.paint_diagnostico
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

-- =============================================================================
-- 6) Storage bucket para os ZIPs gerados
-- =============================================================================
insert into storage.buckets (id, name, public)
values ('paint-exports', 'paint-exports', false)
on conflict (id) do nothing;

-- Policy: usuário só lê/escreve objetos cuja primeira pasta seja uma propriedade dele.
-- Convenção do path: paint-exports/<idPropriedade>/<arquivo.zip>
drop policy if exists paint_exports_rw on storage.objects;
create policy paint_exports_rw on storage.objects
  for all to authenticated
  using (
    bucket_id = 'paint-exports'
    and (storage.foldername(name))[1] in (
      select up."idPropriedade" from public.users_propriedades up
      where up.user_id = auth.uid()::text
        and coalesce(up.deletado, 'NAO') = 'NAO'
    )
  )
  with check (
    bucket_id = 'paint-exports'
    and (storage.foldername(name))[1] in (
      select up."idPropriedade" from public.users_propriedades up
      where up.user_id = auth.uid()::text
        and coalesce(up.deletado, 'NAO') = 'NAO'
    )
  );

-- =============================================================================
-- 7) Triggers utilitários — manter updated_at em dia
-- =============================================================================
create or replace function public.paint_set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  for t in
    select unnest(array[
      'paint_fazenda_config','paint_regime_alimentar','paint_biblioteca_touros',
      'paint_avaliador','paint_grupo_manejo','paint_localidade','paint_inseminador',
      'paint_safra','paint_safra_x_animal','paint_touro_multiplo',
      'paint_composicao_racial','paint_baixa',
      'paint_avaliacao_desmama','paint_avaliacao_sobreano','paint_avaliacao_rah',
      'paint_diagnostico'
    ])
  loop
    execute format(
      'drop trigger if exists %I_set_updated_at on public.%I; '
      'create trigger %I_set_updated_at before update on public.%I '
      'for each row execute function public.paint_set_updated_at();',
      t, t, t, t
    );
  end loop;
end;
$$;
