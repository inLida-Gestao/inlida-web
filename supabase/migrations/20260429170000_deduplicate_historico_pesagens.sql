-- Remove duplicidade logica de pesagens e impede novas duplicatas ativas.
-- Duplicata = mesmo animal, tipo, dia da pesagem e peso.

WITH ranked AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY
        "idRebanho",
        tipo,
        ("dataPesagem")::date,
        peso
      ORDER BY
        created_at ASC NULLS LAST,
        id ASC
    ) AS rn
  FROM public.historico_pesagens
  WHERE "idRebanho" IS NOT NULL
    AND tipo IS NOT NULL
    AND "dataPesagem" IS NOT NULL
    AND peso IS NOT NULL
    AND COALESCE(NULLIF(BTRIM(deletado), ''), 'NAO') <> 'SIM'
)
UPDATE public.historico_pesagens hp
SET deletado = 'SIM'
FROM ranked r
WHERE hp.id = r.id
  AND r.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS historico_pesagens_unique_active_day_weight
ON public.historico_pesagens (
  "idRebanho",
  tipo,
  (("dataPesagem")::date),
  peso
)
WHERE "idRebanho" IS NOT NULL
  AND tipo IS NOT NULL
  AND "dataPesagem" IS NOT NULL
  AND peso IS NOT NULL
  AND COALESCE(NULLIF(BTRIM(deletado), ''), 'NAO') <> 'SIM';
