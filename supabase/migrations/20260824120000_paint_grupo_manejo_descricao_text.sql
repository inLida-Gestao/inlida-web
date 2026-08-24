-- PAINT — cadastros de apoio: descrição deixa de ser varchar(20).
--
-- O limite de 20 chars veio dos campos C(20) do layout: `grm_descri`
-- (GRUPO_MANEJO), `ins_descri` (INSEMINADOR), `lde_descri` (LOCALIDADE) e
-- `rga_descri` (REGIME_ALIMENTAR). Mas esse corte só precisa existir na hora
-- de gerar o arquivo — e a exportação já o faz duas vezes (generators.ts,
-- `slice(0, DESCRI_LEN)`, e o `pad` do layout em fixed-width.ts).
--
-- Guardar truncado no banco só servia para estragar o cadastro:
-- "(G106) SOBREANO FÊMEAS" virava "(G106) SOBREANO FÊME", tanto na importação
-- a partir de `lotes.nome` quanto na edição manual.
alter table public.paint_grupo_manejo    alter column descricao type text;
alter table public.paint_inseminador     alter column nome      type text;
alter table public.paint_localidade      alter column descricao type text;
alter table public.paint_regime_alimentar alter column descricao type text;

-- Restaura o nome completo do lote nas descrições de grupo que ficaram
-- cortadas. Só toca em linhas com exatamente 20 chars que são prefixo de UM
-- único nome de lote da mesma propriedade — quando dois lotes compartilham os
-- 20 primeiros caracteres não há como saber qual deles gerou o grupo (e o
-- PAINT também não os distingue), então esses ficam como estão.
--
-- Só o grupo de manejo precisa de backfill: inseminador, localidade e regime
-- alimentar não têm nenhuma linha gravada em 20 chars.
with candidato as (
  select g.id,
         min(l.nome) as nome,
         count(distinct l.nome) as n_nomes
    from public.paint_grupo_manejo g
    join public.lotes l
      on l.id_propriedade = g.id_propriedade
     and coalesce(l.deletado, 'NAO') = 'NAO'
     and upper(left(l.nome, 20)) = upper(g.descricao)
   where length(g.descricao) = 20
     and length(l.nome) > 20
   group by g.id
)
update public.paint_grupo_manejo g
   set descricao = c.nome
  from candidato c
 where g.id = c.id
   and c.n_nomes = 1;
