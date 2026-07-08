-- Preenche a data oficial de desmama na ficha do animal a partir do histórico
-- de pesagens tipo Desmama. O gráfico "Idade desmama (Meses)" usa
-- rebanho.dataDesmama como fonte oficial.

WITH ultima_desmama AS (
  SELECT DISTINCT ON (hp."idRebanho")
    hp."idRebanho",
    hp."dataPesagem"::date AS data_desmama
  FROM public.historico_pesagens hp
  WHERE hp.deletado IS DISTINCT FROM 'SIM'
    AND lower(btrim(COALESCE(hp.tipo, ''))) = 'desmama'
    AND hp."dataPesagem" IS NOT NULL
    AND NULLIF(btrim(COALESCE(hp."idRebanho", '')), '') IS NOT NULL
  ORDER BY hp."idRebanho", hp."dataPesagem" DESC, hp.id DESC
)
UPDATE public.rebanho r
SET "dataDesmama" = ud.data_desmama
FROM ultima_desmama ud
WHERE r."idRebanho" = ud."idRebanho"
  AND r.deletado IS DISTINCT FROM 'SIM'
  AND r.tipo = 'animal'
  AND r."dataNascimento" IS NOT NULL
  AND r."dataDesmama" IS NULL;
