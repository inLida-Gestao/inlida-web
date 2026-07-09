-- Limpa duplicados ativos em historico_pesagens por animal, data e peso.
-- Regra: nunca marcar Nascimento/Desmama como deletado; preferir remover tipo vazio/null.
-- O trigger de pesoAtual fica desligado somente durante esta limpeza para preservar
-- rebanho.pesoAtual e rebanho.dataUltimaPesagem como solicitado.

ALTER TABLE public.historico_pesagens
  DISABLE TRIGGER trg_sincronizar_peso_atual_rebanho_por_pesagem;

WITH base AS (
  SELECT
    hp.id,
    hp."idRebanho",
    hp."dataPesagem"::date AS data_pesagem,
    hp.peso,
    lower(btrim(coalesce(hp.tipo, ''))) AS tipo_norm
  FROM public.historico_pesagens hp
  WHERE coalesce(hp.deletado, 'NAO') <> 'SIM'
    AND nullif(btrim(coalesce(hp."idRebanho", '')), '') IS NOT NULL
    AND hp."dataPesagem" IS NOT NULL
    AND hp.peso IS NOT NULL
),
dup_groups AS (
  SELECT "idRebanho", data_pesagem, peso
  FROM base
  GROUP BY "idRebanho", data_pesagem, peso
  HAVING count(*) > 1
),
ranked AS (
  SELECT
    b.id,
    b.tipo_norm,
    row_number() OVER (
      PARTITION BY b."idRebanho", b.data_pesagem, b.peso
      ORDER BY
        CASE
          WHEN b.tipo_norm IN ('nascimento', 'desmama') THEN 0
          WHEN b.tipo_norm = 'atual' THEN 1
          WHEN b.tipo_norm NOT IN ('', 'atual') THEN 2
          ELSE 3
        END,
        b.id
    ) AS keep_rank
  FROM base b
  JOIN dup_groups g USING ("idRebanho", data_pesagem, peso)
),
delete_candidates AS (
  SELECT id
  FROM ranked
  WHERE keep_rank > 1
    AND tipo_norm NOT IN ('nascimento', 'desmama')
)
UPDATE public.historico_pesagens hp
SET
  deletado = 'SIM',
  updated_at = now()
FROM delete_candidates dc
WHERE hp.id = dc.id;

ALTER TABLE public.historico_pesagens
  ENABLE TRIGGER trg_sincronizar_peso_atual_rebanho_por_pesagem;

NOTIFY pgrst, 'reload schema';
