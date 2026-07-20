-- Cria historico_pesagens faltantes a partir dos pesos ja existentes na ficha
-- do animal (rebanho). A vinculacao correta e por idRebanho.

-- O backfill de Atual espelha o pesoAtual/dataUltimaPesagem que ja estao em
-- rebanho. Removemos temporariamente o trigger de sincronizacao para evitar uma
-- atualizacao de rebanho por linha inserida e recriamos ao final.
DROP TRIGGER IF EXISTS trg_sincronizar_peso_atual_rebanho_por_pesagem
ON public.historico_pesagens;

WITH candidatos AS (
  SELECT DISTINCT ON (
    r."idRebanho",
    tipo,
    data_pesagem,
    peso
  )
    r."idRebanho",
    r."idPropriedade" AS id_propriedade,
    tipo,
    data_pesagem,
    peso
  FROM (
    SELECT
      rb."idRebanho",
      rb."idPropriedade",
      'Nascimento'::text AS tipo,
      rb."dataNascimento"::date AS data_pesagem,
      rb."pesoNascimento"::numeric AS peso
    FROM public.rebanho rb
    WHERE COALESCE(rb.deletado, 'NAO') <> 'SIM'
      AND NULLIF(btrim(COALESCE(rb."idRebanho", '')), '') IS NOT NULL
      AND rb."dataNascimento" IS NOT NULL
      AND rb."pesoNascimento" IS NOT NULL
      AND rb."pesoNascimento" > 0

    UNION ALL

    SELECT
      rb."idRebanho",
      rb."idPropriedade",
      'Desmama'::text AS tipo,
      rb."dataDesmama"::date AS data_pesagem,
      rb."pesoDesmama"::numeric AS peso
    FROM public.rebanho rb
    WHERE COALESCE(rb.deletado, 'NAO') <> 'SIM'
      AND NULLIF(btrim(COALESCE(rb."idRebanho", '')), '') IS NOT NULL
      AND rb."dataDesmama" IS NOT NULL
      AND rb."pesoDesmama" IS NOT NULL
      AND rb."pesoDesmama" > 0

    UNION ALL

    SELECT
      rb."idRebanho",
      rb."idPropriedade",
      'Atual'::text AS tipo,
      rb."dataUltimaPesagem"::date AS data_pesagem,
      rb."pesoAtual"::numeric AS peso
    FROM public.rebanho rb
    WHERE COALESCE(rb.deletado, 'NAO') <> 'SIM'
      AND NULLIF(btrim(COALESCE(rb."idRebanho", '')), '') IS NOT NULL
      AND rb."dataUltimaPesagem" IS NOT NULL
      AND rb."pesoAtual" IS NOT NULL
      AND rb."pesoAtual" > 0
  ) r
  WHERE r.data_pesagem IS NOT NULL
    AND r.peso IS NOT NULL
    AND r.peso > 0
  ORDER BY r."idRebanho", tipo, data_pesagem, peso
)
INSERT INTO public.historico_pesagens (
  "idRebanho",
  id_propriedade,
  "dataPesagem",
  tipo,
  peso,
  deletado
)
SELECT
  c."idRebanho",
  c.id_propriedade,
  c.data_pesagem,
  c.tipo,
  c.peso,
  'NAO'
FROM candidatos c
WHERE NOT EXISTS (
  SELECT 1
  FROM public.historico_pesagens hp
  WHERE hp."idRebanho" = c."idRebanho"
    AND COALESCE(hp.deletado, 'NAO') <> 'SIM'
    AND lower(btrim(COALESCE(hp.tipo, ''))) = lower(c.tipo)
    AND hp."dataPesagem"::date = c.data_pesagem
    AND hp.peso = c.peso
);

CREATE TRIGGER trg_sincronizar_peso_atual_rebanho_por_pesagem
AFTER INSERT OR UPDATE OF "idRebanho", "dataPesagem", tipo, peso, deletado
OR DELETE
ON public.historico_pesagens
FOR EACH ROW
EXECUTE FUNCTION public.trg_sincronizar_peso_atual_rebanho_por_pesagem();
