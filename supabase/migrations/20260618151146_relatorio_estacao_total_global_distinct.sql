DO $$
DECLARE
  def text;
BEGIN
  SELECT pg_get_functiondef('public.get_relatorio_resumo_estacao(text,text,text)'::regprocedure)
    INTO def;

  def := replace(def,
$old$expostas_total AS (
  SELECT coalesce(sum(e.n), 0)::bigint AS n
  FROM expostas e
  WHERE e.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
)$old$,
$new$expostas_total AS (
  SELECT count(DISTINCT nullif(btrim(s.id_rebanho_matriz), ''))::bigint AS n
  FROM serv s
  WHERE nullif(btrim(s.id_rebanho_matriz), '') IS NOT NULL
)$new$);

  def := replace(def,
$old$vazio_total AS (
  SELECT coalesce(sum(v.n), 0)::bigint AS n
  FROM vazio_dist v
  WHERE v.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
)$old$,
$new$vazio_total AS (
  SELECT count(DISTINCT nullif(btrim(n.id_rebanho_matriz), ''))::bigint AS n
  FROM serv n
  WHERE nullif(btrim(n.id_rebanho_matriz), '') IS NOT NULL
    AND lower(trim(coalesce(n.status_reproducao, ''))) = 'vazio'
)$new$);

  def := replace(def,
$old$outros_total AS (
  SELECT coalesce(sum(o.n), 0)::bigint AS n
  FROM outros_dist o
  WHERE o.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
)$old$,
$new$outros_total AS (
  SELECT count(DISTINCT nullif(btrim(n.id_rebanho_matriz), ''))::bigint AS n
  FROM serv n
  WHERE nullif(btrim(n.id_rebanho_matriz), '') IS NOT NULL
    AND lower(trim(coalesce(n.status_reproducao, ''))) IN (
      'absorção',
      'absorcao',
      'aborto',
      'não diagnosticado',
      'nao diagnosticado'
    )
)$new$);

  def := replace(def,
$old$ia_total AS (
  SELECT coalesce(sum(i.n), 0)::bigint AS n
  FROM ia_reg i
  WHERE i.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
)$old$,
$new$ia_total AS (
  SELECT count(DISTINCT nullif(btrim(p.id_rebanho_matriz), ''))::bigint AS n
  FROM prenhez_nati_cond p
  WHERE lower(trim(coalesce(p.tipo_reproducao, ''))) IN (
    'inseminação',
    'inseminacao'
  )
)$new$);

  def := replace(def,
$old$touro_total AS (
  SELECT coalesce(sum(t.n), 0)::bigint AS n
  FROM touro_reg t
  WHERE t.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
)$old$,
$new$touro_total AS (
  SELECT count(DISTINCT nullif(btrim(p.id_rebanho_matriz), ''))::bigint AS n
  FROM prenhez_nati_cond p
  WHERE lower(trim(coalesce(p.tipo_reproducao, ''))) IN (
    'monta natural'
  )
)$new$);

  def := replace(def,
$old$prenhez_total AS (
  SELECT coalesce(sum(p.n), 0)::bigint AS n
  FROM prenhez_dist p
  WHERE p.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
)$old$,
$new$prenhez_total AS (
  SELECT count(DISTINCT nullif(btrim(n.id_rebanho_matriz), ''))::bigint AS n
  FROM serv n
  WHERE nullif(btrim(n.id_rebanho_matriz), '') IS NOT NULL
    AND (
      lower(trim(coalesce(n.status_reproducao, ''))) LIKE 'prenhe%'
      OR lower(trim(coalesce(n.status_reproducao, ''))) LIKE 'prenha%'
      OR lower(trim(coalesce(n.status_reproducao, ''))) = 'natimorto'
    )
)$new$);

  EXECUTE def;
END $$;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: matrizes distintas por categoria e total global deduplicado por matriz no período, considerando somente matriz vinculada não vazia.';
