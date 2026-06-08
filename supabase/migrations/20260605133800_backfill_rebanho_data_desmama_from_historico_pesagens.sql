-- Backfill missing weaning dates from historical weaning weighing records.
WITH desmama_por_animal AS (
  SELECT
    h."idRebanho",
    MAX(h."dataPesagem") AS data_desmama
  FROM public.historico_pesagens h
  WHERE h."dataPesagem" IS NOT NULL
    AND LOWER(COALESCE(h.deletado, '')) <> 'sim'
    AND LOWER(BTRIM(COALESCE(h.tipo, ''))) = 'desmama'
  GROUP BY h."idRebanho"
)
UPDATE public.rebanho r
SET
  "dataDesmama" = d.data_desmama,
  updated_at = NOW()
FROM desmama_por_animal d
WHERE r."dataDesmama" IS NULL
  AND LOWER(COALESCE(r.deletado, '')) <> 'sim'
  AND d."idRebanho" = r."idRebanho";
