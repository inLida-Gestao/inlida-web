-- Bug #5: Backfill dataUltimaPesagem para animais com pesagens existentes
-- que ainda não têm o campo preenchido.
-- Usa a pesagem mais recente (por dataPesagem) de cada animal.

UPDATE rebanho r
SET "dataUltimaPesagem" = sub."dataPesagem",
    "pesoAtual" = sub.peso
FROM (
  SELECT DISTINCT ON ("idRebanho")
    "idRebanho",
    "dataPesagem",
    peso
  FROM historico_pesagens
  WHERE deletado = 'NAO'
  ORDER BY "idRebanho", "dataPesagem" DESC
) sub
WHERE r."idRebanho" = sub."idRebanho"
  AND r.deletado = 'NAO'
  AND r."dataUltimaPesagem" IS NULL;
