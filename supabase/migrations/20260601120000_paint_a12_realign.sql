-- PAINT — realinhamento do identificador A12 já gravado.
--
-- Correção do bug de alinhamento: o campo Animal (5) do A12
-- (Programa(1)+Série(4)+Animal(5)+Ano(2)) passou a ser justificado à ESQUERDA
-- (ex.: "4705 " em vez de " 4705"), preservando programa/série (1-5) e ano
-- (11-12). A transformação abaixo reescreve posicionalmente os A12 gravados
-- para ficarem consistentes com a nova geração (ANIMAL.TXT, NASCIMENTO, etc.).
--
-- Só é aplicada a propriedades em estratégia 'compacto' (padrão). Propriedades
-- em 'espacado' (cujo A12 podia truncar o ano) devem reexecutar o
-- auto-preenchimento PAINT após o deploy.
--
-- Dedup: como o app já corrigido pode ter inserido a versão nova ao lado da
-- antiga (auto-preenchimento usa upsert ignore por chave = A12), as linhas no
-- formato antigo que colidiriam com a versão canônica são removidas antes do
-- UPDATE nas tabelas com chave única. A dedup usa window function (uma única
-- passada) em vez de subconsulta correlacionada para evitar statement timeout.
--
-- A migration é idempotente: reexecuções não encontram linhas a corrigir nem
-- duplicatas e tornam-se no-ops.

-- Helper temporário: trim do segmento do animal (posições 6-10) + justificar
-- à esquerda, mantendo programa/série e ano.
create or replace function public._paint_fix_a12(a12 text)
returns text
language sql
immutable
as $func$
  select case
    when a12 is null or btrim(a12) = '' then a12
    else substr(rpad(a12, 12, ' '), 1, 5)
      || rpad(btrim(substr(rpad(a12, 12, ' '), 6, 5)), 5, ' ')
      || substr(rpad(a12, 12, ' '), 11, 2)
  end;
$func$;

-- COMPOSICAO_RACIAL — unique (id_propriedade, animal_a12, raca_codigo)
delete from public.paint_composicao_racial t
using (
  select ctid, row_number() over (
    partition by id_propriedade, raca_codigo, public._paint_fix_a12(animal_a12)
    order by (animal_a12 = public._paint_fix_a12(animal_a12)) desc, ctid
  ) rn
  from public.paint_composicao_racial
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_composicao_racial t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- BAIXA — índice não único: UPDATE direto.
update public.paint_baixa t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- DESMAMA — unique (id_propriedade, animal_a12, data)
delete from public.paint_avaliacao_desmama t
using (
  select ctid, row_number() over (
    partition by id_propriedade, data, public._paint_fix_a12(animal_a12)
    order by (animal_a12 = public._paint_fix_a12(animal_a12)) desc, ctid
  ) rn
  from public.paint_avaliacao_desmama
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_avaliacao_desmama t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- ANO_SOBREANO — unique (id_propriedade, animal_a12, data)
delete from public.paint_avaliacao_sobreano t
using (
  select ctid, row_number() over (
    partition by id_propriedade, data, public._paint_fix_a12(animal_a12)
    order by (animal_a12 = public._paint_fix_a12(animal_a12)) desc, ctid
  ) rn
  from public.paint_avaliacao_sobreano
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_avaliacao_sobreano t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- RAH — unique (id_propriedade, animal_a12, data)
delete from public.paint_avaliacao_rah t
using (
  select ctid, row_number() over (
    partition by id_propriedade, data, public._paint_fix_a12(animal_a12)
    order by (animal_a12 = public._paint_fix_a12(animal_a12)) desc, ctid
  ) rn
  from public.paint_avaliacao_rah
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_avaliacao_rah t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- DIAGNOSTICO — unique (id_propriedade, safra_codigo, animal_a12, data)
delete from public.paint_diagnostico t
using (
  select ctid, row_number() over (
    partition by id_propriedade, safra_codigo, data, public._paint_fix_a12(animal_a12)
    order by (animal_a12 = public._paint_fix_a12(animal_a12)) desc, ctid
  ) rn
  from public.paint_diagnostico
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_diagnostico t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- SAFRA_X_ANIMAL — unique (id_propriedade, safra_codigo, animal_a12)
delete from public.paint_safra_x_animal t
using (
  select ctid, row_number() over (
    partition by id_propriedade, safra_codigo, public._paint_fix_a12(animal_a12)
    order by (animal_a12 = public._paint_fix_a12(animal_a12)) desc, ctid
  ) rn
  from public.paint_safra_x_animal
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_safra_x_animal t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

-- ESTOQUE — touro_a12 sem chave única: UPDATE direto.
update public.paint_estoque t
set touro_a12 = public._paint_fix_a12(t.touro_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and t.touro_a12 <> public._paint_fix_a12(t.touro_a12);

-- TOURO_MULTIPLO — unique (id_propriedade, multiplo_a12, touro_a12)
delete from public.paint_touro_multiplo t
using (
  select ctid, row_number() over (
    partition by id_propriedade, public._paint_fix_a12(multiplo_a12), public._paint_fix_a12(touro_a12)
    order by ((multiplo_a12 = public._paint_fix_a12(multiplo_a12)) and (touro_a12 = public._paint_fix_a12(touro_a12))) desc, ctid
  ) rn
  from public.paint_touro_multiplo
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_touro_multiplo t
set multiplo_a12 = public._paint_fix_a12(t.multiplo_a12),
    touro_a12 = public._paint_fix_a12(t.touro_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'compacto'
  )
  and (
    t.multiplo_a12 <> public._paint_fix_a12(t.multiplo_a12)
    or t.touro_a12 <> public._paint_fix_a12(t.touro_a12)
  );

-- Biblioteca de touros (global, chave a12, sem FKs). Atualiza pai/mãe sempre;
-- a chave é deduplicada (remove formato antigo quando o canônico já existe) e
-- depois reescrita.
update public.paint_biblioteca_touros
set pai_a12 = public._paint_fix_a12(pai_a12),
    mae_a12 = public._paint_fix_a12(mae_a12)
where pai_a12 is distinct from public._paint_fix_a12(pai_a12)
   or mae_a12 is distinct from public._paint_fix_a12(mae_a12);

delete from public.paint_biblioteca_touros b
using (
  select ctid, row_number() over (
    partition by public._paint_fix_a12(a12)
    order by (a12 = public._paint_fix_a12(a12)) desc, ctid
  ) rn
  from public.paint_biblioteca_touros
) r
where b.ctid = r.ctid and r.rn > 1;
update public.paint_biblioteca_touros b
set a12 = public._paint_fix_a12(b.a12)
where b.a12 <> public._paint_fix_a12(b.a12);

-- Payloads de exclusão (paint_registro_excluido.payload jsonb) ainda não
-- exportados. Reescreve a chave A12 conforme a entidade.
update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'cpr_animal_id', public._paint_fix_a12(t.payload->>'cpr_animal_id'))
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.entidade = 'COMPOSICAO_RACIAL'
  and t.payload ? 'cpr_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'dsm_animal_id', public._paint_fix_a12(t.payload->>'dsm_animal_id'))
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.entidade = 'DESMAMA'
  and t.payload ? 'dsm_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'sbr_animal_id', public._paint_fix_a12(t.payload->>'sbr_animal_id'))
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.entidade = 'ANO_SOBREANO'
  and t.payload ? 'sbr_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'rah_animal_id', public._paint_fix_a12(t.payload->>'rah_animal_id'))
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.entidade = 'RAH'
  and t.payload ? 'rah_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'dgn_animal_id', public._paint_fix_a12(t.payload->>'dgn_animal_id'))
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.entidade = 'DIAGNOSTICO'
  and t.payload ? 'dgn_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'est_touro_a12', public._paint_fix_a12(t.payload->>'est_touro_a12'))
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.entidade = 'ESTOQUE'
  and t.payload ? 'est_touro_a12';

drop function if exists public._paint_fix_a12(text);
