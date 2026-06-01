-- PAINT — realinhamento do identificador A12 já gravado.
--
-- Correção do bug de alinhamento: o campo Animal (5) do A12
-- (Programa(1)+Série(4)+Animal(5)+Ano(2)) passou a ser justificado à ESQUERDA
-- (ex.: "4705 " em vez de " 4705"), preservando programa/série (1-5) e ano
-- (11-12). A transformação abaixo reescreve posicionalmente os A12 gravados
-- para ficarem consistentes com a nova geração (ANIMAL.TXT, NASCIMENTO, etc.).
--
-- A transformação é determinística e idempotente para o layout posicional
-- (estratégia 'compacto', padrão). Por isso só é aplicada a propriedades em
-- 'compacto'. Propriedades em 'espacado' (cujo A12 podia truncar o ano) devem
-- reexecutar o auto-preenchimento PAINT após o deploy.

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

-- ---------------------------------------------------------------------------
-- Tabelas por propriedade (somente estratégia 'compacto').
-- ---------------------------------------------------------------------------
update public.paint_composicao_racial t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_baixa t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_avaliacao_desmama t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_avaliacao_sobreano t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_avaliacao_rah t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_diagnostico t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_safra_x_animal t
set animal_a12 = public._paint_fix_a12(t.animal_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.animal_a12 <> public._paint_fix_a12(t.animal_a12);

update public.paint_estoque t
set touro_a12 = public._paint_fix_a12(t.touro_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and t.touro_a12 <> public._paint_fix_a12(t.touro_a12);

update public.paint_touro_multiplo t
set multiplo_a12 = public._paint_fix_a12(t.multiplo_a12),
    touro_a12 = public._paint_fix_a12(t.touro_a12)
from public.paint_fazenda_config c
where c.id_propriedade = t.id_propriedade
  and coalesce(c.estrategia_a12, 'compacto') = 'compacto'
  and (
    t.multiplo_a12 <> public._paint_fix_a12(t.multiplo_a12)
    or t.touro_a12 <> public._paint_fix_a12(t.touro_a12)
  );

-- ---------------------------------------------------------------------------
-- Biblioteca de touros (global, chave a12). Atualiza pai/mãe sempre; a chave
-- só é reescrita quando muda e não colide com registro existente.
-- ---------------------------------------------------------------------------
update public.paint_biblioteca_touros
set pai_a12 = public._paint_fix_a12(pai_a12),
    mae_a12 = public._paint_fix_a12(mae_a12)
where pai_a12 is distinct from public._paint_fix_a12(pai_a12)
   or mae_a12 is distinct from public._paint_fix_a12(mae_a12);

update public.paint_biblioteca_touros b
set a12 = public._paint_fix_a12(b.a12)
where b.a12 <> public._paint_fix_a12(b.a12)
  and not exists (
    select 1 from public.paint_biblioteca_touros b2
    where b2.a12 = public._paint_fix_a12(b.a12)
  );

-- ---------------------------------------------------------------------------
-- Payloads de exclusão (paint_registro_excluido.payload jsonb) ainda não
-- exportados. Reescreve a chave A12 conforme a entidade.
-- ---------------------------------------------------------------------------
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
