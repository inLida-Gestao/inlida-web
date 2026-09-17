-- PAINT — realinhamento do A12 gravado por propriedades em estratégia 'espacado'.
--
-- O A12 é POSICIONAL (Manual §7.1): Programa(1) + Série(4, à esquerda) +
-- Animal(5, à esquerda) + Ano(2). Os "espaços" de 'P460 1163 21' são a sobra da
-- série ("460 ") e do animal ("1163 "), não separadores.
--
-- A estratégia 'espacado' montava o A12 por CONCATENAÇÃO com separadores
-- (programa+série+' '+animal+' '+ano, depois padEnd(12)). Isso só coincide com o
-- layout posicional quando a série tem 3 chars E o número tem 4 dígitos. Fora
-- disso o ANO sai das posições 11-12:
--     número 10   -> 'P460 10 20  '   (correto: 'P460 10   20')
--     número 100  -> 'P460 100 20 '   (correto: 'P460 100  20')
-- Confirmado contra os A12 que o próprio PAINT tem (paint_animal_a12):
-- 'P460 77   20' (2 dígitos), 'P460 222  20' (3), 'F460 1163 21' (4).
--
-- Complemento de 20260601120000_paint_a12_realign.sql, que tratou apenas as
-- propriedades em 'compacto' e deixou registrado que as 'espacado' precisariam
-- deste passo.
--
-- Reconstrução: tokeniza o A12 quebrado (3 tokens: programa+série, animal, ano)
-- e reescreve posicionalmente. Só age quando o ano NÃO está em 11-12 — A12 já
-- posicional, A12 vindo do PAINT e A12 com nome no lugar do número voltam
-- inalterados. Idempotente: reexecutar é no-op.
--
-- Fora de alcance (não é recuperável por string): número com 5+ dígitos, cujo
-- 5º dígito o formato antigo truncava. Na Cachoeira são 34 animais, todos com
-- status 'Sêmen'/'Fora da propriedade' (fora do ANIMAL.TXT) e sem data de
-- nascimento — portanto sem A12 gerado.

create or replace function public._paint_a12_espacado_fix(a12 text)
returns text
language plpgsql
immutable
as $func$
declare
  k text[];
begin
  if a12 is null or btrim(a12) = '' then
    return a12;
  end if;
  -- Ano já nas posições 11-12: A12 posicional, nada a fazer.
  if substr(rpad(a12, 12, ' '), 11, 2) ~ '^[0-9]{2}$' then
    return a12;
  end if;
  k := regexp_split_to_array(btrim(a12), '\s+');
  if array_length(k, 1) <> 3 then
    return a12;                      -- forma inesperada: preserva
  end if;
  if k[3] !~ '^[0-9]{2}$' then
    return a12;                      -- último token não é o ano
  end if;
  if length(k[1]) < 2 or length(k[1]) > 5 then
    return a12;                      -- programa+série fora do esperado
  end if;
  -- k[1] = programa (1) + série (1-4); k[2] = número; k[3] = ano.
  return left(k[1], 1) || rpad(substr(k[1], 2), 4) || rpad(k[2], 5) || k[3];
end;
$func$;

-- Escopo: só propriedades em 'espacado' — as em 'compacto' já foram tratadas
-- pela migration 20260601120000 (subquery inline, mesmo molde dela).

-- COMPOSICAO_RACIAL — unique (id_propriedade, animal_a12, raca_codigo)
delete from public.paint_composicao_racial t
using (
  select ctid, row_number() over (
    partition by id_propriedade, raca_codigo, public._paint_a12_espacado_fix(animal_a12)
    order by (animal_a12 = public._paint_a12_espacado_fix(animal_a12)) desc, ctid
  ) rn
  from public.paint_composicao_racial
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_composicao_racial t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- BAIXA — índice não único: UPDATE direto.
update public.paint_baixa t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- DESMAMA — unique (id_propriedade, animal_a12, data)
delete from public.paint_avaliacao_desmama t
using (
  select ctid, row_number() over (
    partition by id_propriedade, data, public._paint_a12_espacado_fix(animal_a12)
    order by (animal_a12 = public._paint_a12_espacado_fix(animal_a12)) desc, ctid
  ) rn
  from public.paint_avaliacao_desmama
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_avaliacao_desmama t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- ANO_SOBREANO — unique (id_propriedade, animal_a12, data)
delete from public.paint_avaliacao_sobreano t
using (
  select ctid, row_number() over (
    partition by id_propriedade, data, public._paint_a12_espacado_fix(animal_a12)
    order by (animal_a12 = public._paint_a12_espacado_fix(animal_a12)) desc, ctid
  ) rn
  from public.paint_avaliacao_sobreano
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_avaliacao_sobreano t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- RAH — unique (id_propriedade, animal_a12, data)
delete from public.paint_avaliacao_rah t
using (
  select ctid, row_number() over (
    partition by id_propriedade, data, public._paint_a12_espacado_fix(animal_a12)
    order by (animal_a12 = public._paint_a12_espacado_fix(animal_a12)) desc, ctid
  ) rn
  from public.paint_avaliacao_rah
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_avaliacao_rah t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- DIAGNOSTICO — unique (id_propriedade, safra_codigo, animal_a12, data)
delete from public.paint_diagnostico t
using (
  select ctid, row_number() over (
    partition by id_propriedade, safra_codigo, data, public._paint_a12_espacado_fix(animal_a12)
    order by (animal_a12 = public._paint_a12_espacado_fix(animal_a12)) desc, ctid
  ) rn
  from public.paint_diagnostico
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_diagnostico t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- SAFRA_X_ANIMAL — unique (id_propriedade, safra_codigo, animal_a12)
delete from public.paint_safra_x_animal t
using (
  select ctid, row_number() over (
    partition by id_propriedade, safra_codigo, public._paint_a12_espacado_fix(animal_a12)
    order by (animal_a12 = public._paint_a12_espacado_fix(animal_a12)) desc, ctid
  ) rn
  from public.paint_safra_x_animal
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_safra_x_animal t
set animal_a12 = public._paint_a12_espacado_fix(t.animal_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.animal_a12 <> public._paint_a12_espacado_fix(t.animal_a12);

-- ESTOQUE — touro_a12 sem chave única: UPDATE direto.
update public.paint_estoque t
set touro_a12 = public._paint_a12_espacado_fix(t.touro_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.touro_a12 <> public._paint_a12_espacado_fix(t.touro_a12);

-- TOURO_MULTIPLO — unique (id_propriedade, multiplo_a12, touro_a12)
delete from public.paint_touro_multiplo t
using (
  select ctid, row_number() over (
    partition by id_propriedade,
                 public._paint_a12_espacado_fix(multiplo_a12),
                 public._paint_a12_espacado_fix(touro_a12)
    order by ((multiplo_a12 = public._paint_a12_espacado_fix(multiplo_a12))
          and (touro_a12 = public._paint_a12_espacado_fix(touro_a12))) desc, ctid
  ) rn
  from public.paint_touro_multiplo
  where id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
) r
where t.ctid = r.ctid and r.rn > 1;
update public.paint_touro_multiplo t
set multiplo_a12 = public._paint_a12_espacado_fix(t.multiplo_a12),
    touro_a12 = public._paint_a12_espacado_fix(t.touro_a12)
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and (
    t.multiplo_a12 <> public._paint_a12_espacado_fix(t.multiplo_a12)
    or t.touro_a12 <> public._paint_a12_espacado_fix(t.touro_a12)
  );

-- Biblioteca de touros: tabela GLOBAL (sem id_propriedade). O A12 do touro é
-- derivado pelo mesmo formatA12, então também tem registros desalinhados.
update public.paint_biblioteca_touros
set pai_a12 = public._paint_a12_espacado_fix(pai_a12),
    mae_a12 = public._paint_a12_espacado_fix(mae_a12)
where pai_a12 is distinct from public._paint_a12_espacado_fix(pai_a12)
   or mae_a12 is distinct from public._paint_a12_espacado_fix(mae_a12);

delete from public.paint_biblioteca_touros b
using (
  select ctid, row_number() over (
    partition by public._paint_a12_espacado_fix(a12)
    order by (a12 = public._paint_a12_espacado_fix(a12)) desc, ctid
  ) rn
  from public.paint_biblioteca_touros
) r
where b.ctid = r.ctid and r.rn > 1;
update public.paint_biblioteca_touros b
set a12 = public._paint_a12_espacado_fix(b.a12)
where b.a12 <> public._paint_a12_espacado_fix(b.a12);

-- Payloads de exclusão ainda não exportados (paint_registro_excluido.payload).
update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'cpr_animal_id', public._paint_a12_espacado_fix(t.payload->>'cpr_animal_id'))
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.entidade = 'COMPOSICAO_RACIAL'
  and t.payload ? 'cpr_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'dsm_animal_id', public._paint_a12_espacado_fix(t.payload->>'dsm_animal_id'))
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.entidade = 'DESMAMA'
  and t.payload ? 'dsm_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'sbr_animal_id', public._paint_a12_espacado_fix(t.payload->>'sbr_animal_id'))
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.entidade = 'ANO_SOBREANO'
  and t.payload ? 'sbr_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'rah_animal_id', public._paint_a12_espacado_fix(t.payload->>'rah_animal_id'))
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.entidade = 'RAH'
  and t.payload ? 'rah_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'dgn_animal_id', public._paint_a12_espacado_fix(t.payload->>'dgn_animal_id'))
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.entidade = 'DIAGNOSTICO'
  and t.payload ? 'dgn_animal_id';

update public.paint_registro_excluido t
set payload = t.payload || jsonb_build_object(
    'est_touro_a12', public._paint_a12_espacado_fix(t.payload->>'est_touro_a12'))
where t.id_propriedade in (
    select id_propriedade from public.paint_fazenda_config
    where coalesce(estrategia_a12, 'compacto') = 'espacado'
  )
  and t.entidade = 'ESTOQUE'
  and t.payload ? 'est_touro_a12';

drop function if exists public._paint_a12_espacado_fix(text);
