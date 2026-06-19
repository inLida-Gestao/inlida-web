-- Normaliza id_rebanho_reprodutor removendo espacos/quebras de linha nas pontas.
-- Havia registros com o mesmo touro gravado como "<id>" e "<id>\r\n" (dado sujo de
-- importacao), gerando touro duplicado no filtro e fazendo o grafico
-- (calcular_taxa_prenhez, que compara o id cru) perder esses registros.

UPDATE public.reproducao
SET id_rebanho_reprodutor = btrim(id_rebanho_reprodutor, E' \t\r\n')
WHERE id_rebanho_reprodutor IS NOT NULL
  AND id_rebanho_reprodutor <> btrim(id_rebanho_reprodutor, E' \t\r\n');
