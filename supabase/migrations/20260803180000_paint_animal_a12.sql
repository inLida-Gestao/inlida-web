-- A12 OFICIAL DO PAINT por animal.
--
-- Contexto: fazendas que já usam o PAINT há anos enviaram os arquivos
-- MANUALMENTE. O A12 que o PAINT tem foi digitado ao longo do tempo e contém
-- inconsistências que não podem mais ser corrigidas do lado do PAINT (ex.:
-- programa 'F' no lugar de 'P', ou 'p' minúsculo). Como o A12 é a CHAVE do
-- animal no PAINT, a integração precisa reproduzir exatamente o que já está
-- lá — senão o PAINT trata como animal novo e o vínculo das avaliações quebra.
--
-- Esta tabela guarda, por animal, o A12 exato que o PAINT possui. O export
-- (edge paint-export) passa a honrá-lo; quando não há linha para o animal, o
-- A12 continua sendo calculado como hoje. Logo, propriedades SEM histórico
-- manual no PAINT não sofrem nenhuma mudança.

create table if not exists public.paint_animal_a12 (
  id uuid primary key default gen_random_uuid(),
  id_propriedade text not null,
  id_rebanho text not null,               -- rebanho."idRebanho"
  a12 char(12) not null,                  -- EXATO como está no PAINT ('p460 1163 21', 'F460 …')
  origem text not null default 'animal_txt'
    check (origem in ('animal_txt', 'avaliacao_importada', 'manual')),
  -- Snapshots do momento do casamento, só para auditoria/relatório:
  numero_animal_paint text,
  data_nascimento_paint date,
  nome_paint text,
  divergente boolean not null default false, -- a12 <> A12 recalculado no import
  observacao text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint paint_animal_a12_len_chk check (char_length(btrim(a12)) between 5 and 12),
  constraint paint_animal_a12_uk unique (id_propriedade, id_rebanho)
);

-- char(12) espelha animal_a12 das outras paint_* e PRESERVA a caixa ('p' <> 'P').
-- Sem unique em a12: o PAINT pode ter A12 repetido historicamente — detectamos
-- e reportamos, não bloqueamos a importação.

create index if not exists paint_animal_a12_prop_a12_idx
  on public.paint_animal_a12 (id_propriedade, a12);

alter table public.paint_animal_a12 enable row level security;

-- Policy permissiva para authenticated, MESMA convenção das outras 26 policies
-- paint_* deste projeto (todas com qual=true). Uma policy restritiva aqui faria
-- esta tabela ser a única invisível para o app, que lê com o JWT do usuário.
drop policy if exists paint_animal_a12_rw on public.paint_animal_a12;
create policy paint_animal_a12_rw on public.paint_animal_a12
  for all to authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on public.paint_animal_a12 to authenticated;
grant all on public.paint_animal_a12 to service_role;

-- ---------------------------------------------------------------------------
-- BACKFILL: colhe o A12 do PAINT que já está no banco.
--
-- As avaliações importadas da planilha PAINT guardam o animal_a12 EXATO da
-- planilha (com 'F'/'p'), então são uma fonte imediata — sem exigir arquivo
-- novo. Gravamos com origem='avaliacao_importada'; a importação do ANIMAL.TXT
-- (fonte completa) sobrescreve depois.
--
-- Chave de casamento robusta, independente de programa/série: dígitos do
-- número (posições 6-10) + ano (11-12). Funciona nas duas estratégias de A12
-- ('compacto' e 'espacado': 'p460 1163 21' -> 1163+21; 'pJLK 1043 21' -> 1043+21).
-- ---------------------------------------------------------------------------
with av as (
  select id_propriedade, animal_a12, data
    from public.paint_avaliacao_desmama
   where origem = 'importacao_paint'
  union all
  select id_propriedade, animal_a12, data
    from public.paint_avaliacao_sobreano
   where origem = 'importacao_paint'
  union all
  select id_propriedade, animal_a12, data
    from public.paint_avaliacao_rah
),
k as (
  select id_propriedade,
         btrim(substr(animal_a12, 6, 5)) as dig,
         substr(animal_a12, 11, 2)       as ano2,
         btrim(animal_a12)               as a12,
         row_number() over (
           partition by id_propriedade,
                        btrim(substr(animal_a12, 6, 5)),
                        substr(animal_a12, 11, 2)
           order by data desc nulls last   -- avaliação mais recente ganha
         ) as rn
    from av
   where animal_a12 is not null
     and btrim(substr(animal_a12, 6, 5)) <> ''
     and substr(animal_a12, 11, 2) ~ '^[0-9]{2}$'
),
reb as (
  select r."idPropriedade" as id_propriedade,
         r."idRebanho"     as id_rebanho,
         left(regexp_replace(coalesce(r."numeroAnimal", ''), '\D', '', 'g'), 5) as dig,
         to_char(r."dataNascimento", 'YY') as ano2,
         count(*) over (
           partition by r."idPropriedade",
             left(regexp_replace(coalesce(r."numeroAnimal", ''), '\D', '', 'g'), 5),
             to_char(r."dataNascimento", 'YY')
         ) as n_colisao
    from public.rebanho r
   where coalesce(r.deletado, 'NAO') <> 'SIM'
     and r."idRebanho" is not null
     and r."dataNascimento" is not null
)
insert into public.paint_animal_a12
  (id_propriedade, id_rebanho, a12, origem, divergente)
select k.id_propriedade, reb.id_rebanho, k.a12, 'avaliacao_importada',
       -- divergente = o programa do A12 do PAINT difere do configurado (é o
       -- caso 'F'/'p' minúsculo). A comparação completa com o A12 calculado é
       -- feita na importação do ANIMAL.TXT, que tem a mesma função do export.
       left(k.a12, 1) <> coalesce(
         (select c.programa from public.paint_fazenda_config c
           where c.id_propriedade = k.id_propriedade limit 1), 'P')
  from k
  join reb on reb.id_propriedade = k.id_propriedade
          and reb.dig  = k.dig
          and reb.ano2 = k.ano2
 where k.rn = 1
   and reb.n_colisao = 1   -- colisões dígitos+ano NÃO são backfilladas às cegas
   and left(regexp_replace(coalesce(reb.dig, ''), '\D', '', 'g'), 5) <> ''
on conflict (id_propriedade, id_rebanho) do nothing;

notify pgrst, 'reload schema';
