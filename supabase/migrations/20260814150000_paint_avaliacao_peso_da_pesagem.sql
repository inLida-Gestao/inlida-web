-- PAINT — materializa o peso das avaliações DESMAMA/SOBREANO que estão sem peso.
--
-- O export (edge paint-export) preenche dsm_peso/sbr_peso "ao vivo": quando a
-- linha de paint_avaliacao_* não tem peso, ele busca a pesagem do inLida
-- (historico_pesagens) do animal na data EXATA da avaliação. Resultado: o TXT
-- sai completo, mas quem consulta a TABELA vê peso NULL (bug reportado pela
-- cliente no animal P460 3971 24 — sbr_peso 477.00 no TXT, peso NULL no banco).
--
-- Esta migration copia esse mesmo peso para a tabela, com a mesma regra do
-- export (pesagem na data exata; havendo mais de uma, a de menor id):
--  - casamento avaliação -> animal pela chave dígitos-do-número + ano de
--    nascimento (posições 6-10 e 11-12 do A12), com colisões excluídas —
--    idêntico ao backfill de 20260803180000_paint_animal_a12.sql;
--  - só preenche onde peso IS NULL ou <= 0 (o export ignora peso <= 0);
--  - nunca sobrescreve peso já informado. Idempotente.
--
-- A importação da planilha de avaliação também passou a materializar esse peso
-- (import_paint_avaliacao_excel.dart), então linhas novas não voltam a ficar
-- NULL. Linhas sem pesagem na data exata permanecem NULL — nesses casos o TXT
-- também sai em branco (comportamento combinado com a cliente).

with reb as (
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
   where r."idRebanho" is not null
     and r."dataNascimento" is not null
),
peso_dia as (
  select distinct on (hp.id_propriedade, hp."idRebanho", hp."dataPesagem")
         hp.id_propriedade, hp."idRebanho" as id_rebanho,
         hp."dataPesagem" as data, hp.peso
    from public.historico_pesagens hp
   where coalesce(hp.deletado, 'NAO') <> 'SIM'
     and hp.peso is not null and hp.peso > 0
   order by hp.id_propriedade, hp."idRebanho", hp."dataPesagem", hp.id
)
update public.paint_avaliacao_sobreano t
   set peso = pd.peso,
       updated_at = now()
  from reb, peso_dia pd
 where (t.peso is null or t.peso <= 0)
   and reb.id_propriedade = t.id_propriedade
   and reb.n_colisao = 1
   and reb.dig <> ''
   and reb.dig  = btrim(substr(t.animal_a12, 6, 5))
   and reb.ano2 = substr(t.animal_a12, 11, 2)
   and pd.id_propriedade = t.id_propriedade
   and pd.id_rebanho = reb.id_rebanho
   and pd.data = t.data;

with reb as (
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
   where r."idRebanho" is not null
     and r."dataNascimento" is not null
),
peso_dia as (
  select distinct on (hp.id_propriedade, hp."idRebanho", hp."dataPesagem")
         hp.id_propriedade, hp."idRebanho" as id_rebanho,
         hp."dataPesagem" as data, hp.peso
    from public.historico_pesagens hp
   where coalesce(hp.deletado, 'NAO') <> 'SIM'
     and hp.peso is not null and hp.peso > 0
   order by hp.id_propriedade, hp."idRebanho", hp."dataPesagem", hp.id
)
update public.paint_avaliacao_desmama t
   set peso = pd.peso,
       updated_at = now()
  from reb, peso_dia pd
 where (t.peso is null or t.peso <= 0)
   and reb.id_propriedade = t.id_propriedade
   and reb.n_colisao = 1
   and reb.dig <> ''
   and reb.dig  = btrim(substr(t.animal_a12, 6, 5))
   and reb.ano2 = substr(t.animal_a12, 11, 2)
   and pd.id_propriedade = t.id_propriedade
   and pd.id_rebanho = reb.id_rebanho
   and pd.data = t.data;
