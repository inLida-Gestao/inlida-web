-- Considera Monta Natural pela data inicial no período mesmo quando
-- data_final está em branco. O export de reprodução usa esse formato.

CREATE OR REPLACE FUNCTION public.calcular_taxa_natalidade(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_id_rebanho_reprodutor text DEFAULT ''
)
RETURNS TABLE(
  titulo text,
  porcentagem numeric,
  total_pariram bigint,
  total_expostas bigint
)
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN
RETURN QUERY
WITH bounds AS (
  SELECT
    data_inicio_param::date AS d0,
    data_fim_param::date AS d1
),
raw_activity AS (
  SELECT
    rep.id_rebanho_matriz,
    rep.parida,
    rep.data_parto,
    rep.status_reproducao,
    lower(
      coalesce(
        nullif(btrim(rep.categoria), ''),
        nullif(btrim(rb.categoria), ''),
        ''
      )
    ) AS cat_l
  FROM public.reproducao rep
  LEFT JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
    AND rb."idPropriedade" = id_propriedade_param
    AND rb.deletado = 'NAO'
  CROSS JOIN bounds b
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.id_rebanho_matriz IS NOT NULL
    AND btrim(rep.id_rebanho_matriz) <> ''
    AND (
      (
        rep.data_inseminacao IS NOT NULL
        AND rep.data_inseminacao::date >= b.d0
        AND rep.data_inseminacao::date <= b.d1
      )
      OR (
        rep.data_inicial IS NOT NULL
        AND rep.data_inicial::date >= b.d0
        AND rep.data_inicial::date <= b.d1
      )
    )
    AND (
      nullif(trim(p_lote_id), '') IS NULL
      OR rep.id_lote = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_lote_id, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_inseminador), '') IS NULL
      OR rep.inseminador = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_inseminador, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_id_rebanho_reprodutor), '') IS NULL
      OR rep.id_rebanho_reprodutor = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_id_rebanho_reprodutor, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
),
base_activity AS (
  SELECT
    r.id_rebanho_matriz,
    (
      upper(trim(coalesce(r.parida, ''))) IN ('SIM', 'S', 'TRUE', '1')
      AND r.data_parto IS NOT NULL
      AND r.data_parto::date >= (SELECT d0 FROM bounds)
      AND r.data_parto::date <= (SELECT d1 FROM bounds)
      AND lower(trim(coalesce(r.status_reproducao, ''))) NOT LIKE '%natimorto%'
    ) AS tem_parto_confirmado,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%' THEN 'Vaca Primípara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%' THEN 'Vaca Multípara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw_activity r
),
per_matriz AS (
  SELECT
    b.id_rebanho_matriz,
    min(b.cat_titulo) AS cat_titulo,
    bool_or(b.tem_parto_confirmado) AS pariu
  FROM base_activity b
  GROUP BY b.id_rebanho_matriz
),
agg AS (
  SELECT
    p.cat_titulo AS titulo,
    count(*)::bigint AS total_expostas,
    count(*) FILTER (WHERE p.pariu)::bigint AS total_pariram
  FROM per_matriz p
  GROUP BY p.cat_titulo
)
SELECT
  a.titulo,
  CASE
    WHEN a.total_expostas > 0 THEN round(100.0 * a.total_pariram / a.total_expostas::numeric, 2)
    ELSE 0::numeric
  END AS porcentagem,
  a.total_pariram,
  a.total_expostas
FROM agg a
WHERE a.titulo IN ('Novilha', 'Vaca Primípara', 'Vaca Multípara')
ORDER BY
  CASE a.titulo
    WHEN 'Novilha' THEN 1
    WHEN 'Vaca Primípara' THEN 2
    WHEN 'Vaca Multípara' THEN 3
    ELSE 9
  END;
END
$function$;

COMMENT ON FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text) IS
  'Taxa de natalidade (%): denominador = matrizes com inseminação ou data inicial de monta natural no período; numerador = dessas matrizes, as com parida SIM e data_parto no período selecionado, excluindo natimortos.';

CREATE OR REPLACE FUNCTION public.calcular_taxa_prenhez2(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_id_rebanho_reprodutor text DEFAULT ''
)
RETURNS TABLE (
  titulo text,
  porcentagem numeric,
  total_prenhe bigint,
  total_expostas bigint
)
LANGUAGE sql
STABLE
SET search_path = public
AS $function$
WITH bounds AS (
  SELECT
    data_inicio_param::date AS d0,
    data_fim_param::date AS d1
),
raw AS (
  SELECT
    rep.id_rebanho_matriz,
    rep.status_reproducao,
    lower(
      coalesce(
        nullif(btrim(rep.categoria), ''),
        nullif(btrim(rb.categoria), ''),
        ''
      )
    ) AS cat_l
  FROM public.reproducao rep
  LEFT JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
    AND rb."idPropriedade" = id_propriedade_param
    AND rb.deletado = 'NAO'
  CROSS JOIN bounds b
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.id_rebanho_matriz IS NOT NULL
    AND btrim(rep.id_rebanho_matriz) <> ''
    AND (
      (
        rep.data_inseminacao IS NOT NULL
        AND rep.data_inseminacao::date >= b.d0
        AND rep.data_inseminacao::date <= b.d1
      )
      OR (
        rep.data_inicial IS NOT NULL
        AND rep.data_inicial::date >= b.d0
        AND rep.data_inicial::date <= b.d1
      )
    )
    AND (
      nullif(trim(p_lote_id), '') IS NULL
      OR rep.id_lote = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_lote_id, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_inseminador), '') IS NULL
      OR rep.inseminador = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_inseminador, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_id_rebanho_reprodutor), '') IS NULL
      OR rep.id_rebanho_reprodutor = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_id_rebanho_reprodutor, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
),
base AS (
  SELECT
    r.id_rebanho_matriz,
    r.status_reproducao,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%' THEN 'Vaca Primipara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%' THEN 'Vaca Multipara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw r
),
per_matriz AS (
  SELECT
    b.id_rebanho_matriz,
    min(b.cat_titulo) AS cat_titulo,
    bool_or(lower(trim(coalesce(b.status_reproducao, ''))) LIKE 'prenhe%') AS eh_prenhe
  FROM base b
  GROUP BY b.id_rebanho_matriz
),
agg AS (
  SELECT
    p.cat_titulo AS titulo,
    count(*)::bigint AS total_expostas,
    count(*) FILTER (WHERE p.eh_prenhe)::bigint AS total_prenhe
  FROM per_matriz p
  GROUP BY p.cat_titulo
)
SELECT
  a.titulo,
  CASE
    WHEN a.total_expostas > 0 THEN round(100.0 * a.total_prenhe / a.total_expostas::numeric, 2)
    ELSE 0::numeric
  END AS porcentagem,
  a.total_prenhe,
  a.total_expostas
FROM agg a
WHERE a.titulo IN ('Novilha', 'Vaca Primipara', 'Vaca Multipara')
ORDER BY
  CASE a.titulo
    WHEN 'Novilha' THEN 1
    WHEN 'Vaca Primipara' THEN 2
    WHEN 'Vaca Multipara' THEN 3
    ELSE 9
  END;
$function$;

COMMENT ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text) IS
  'Taxa de prenhez por categoria: numerador = matrizes expostas no período com status prenhe*; denominador = matrizes distintas com inseminação ou data inicial de monta natural no período.';

ALTER FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text)
  TO anon, authenticated, service_role;
