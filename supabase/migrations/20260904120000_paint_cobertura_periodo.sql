-- PAINT — período da cobertura (manhã / tarde).
--
-- `cob_periodo` é C(1) na posição 65 do COBERTURA.TXT e sempre foi enviado como
-- "M" fixo, um chute. A cliente precisa registrar se a inseminação foi de manhã
-- ou de tarde, e preferiu resolver por planilha no módulo PAINT em vez de um
-- campo novo na tela de reprodução — assim o app mobile e o web não mudam.
--
-- A chave é `id_reproducao`, e NÃO (animal_a12, data) como nas outras tabelas
-- paint_*. Duas razões: a mesma vaca pode ter duas coberturas na mesma data, e
-- dois animais diferentes podem compartilhar o mesmo A12 (26 pares hoje na
-- Cachoeira). O id da reprodução é exato e imune aos dois casos; a planilha
-- carrega essa coluna para o import casar de volta.
create table if not exists public.paint_cobertura_periodo (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  id_reproducao text not null,
  periodo text not null check (periodo in ('MANHA', 'TARDE')),
  origem text not null default 'importacao_paint',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id_propriedade, id_reproducao)
);

comment on table public.paint_cobertura_periodo is
  'Turno da cobertura (MANHA/TARDE) por reprodução. Preenchido pela planilha de '
  'cobertura do módulo PAINT e exportado em COBERTURA.cob_periodo. Sem registro '
  'aqui, o campo sai em branco no TXT.';

create index if not exists paint_cobertura_periodo_prop_idx
  on public.paint_cobertura_periodo (id_propriedade, id_reproducao);

alter table public.paint_cobertura_periodo enable row level security;

create policy paint_cobertura_periodo_rw on public.paint_cobertura_periodo
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

-- Trigger de updated_at. O loop do módulo PAINT (migration inicial) tem a lista
-- de tabelas fixa, então a tabela nova precisa do trigger declarado aqui —
-- senão updated_at nunca se atualiza sozinho.
drop trigger if exists paint_cobertura_periodo_set_updated_at
  on public.paint_cobertura_periodo;
create trigger paint_cobertura_periodo_set_updated_at
  before update on public.paint_cobertura_periodo
  for each row execute function public.paint_set_updated_at();
