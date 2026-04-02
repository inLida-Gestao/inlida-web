-- Taxa de natalidade: mesmos filtros opcionais que calcular_taxa_prenhez2 (lote, inseminador, reprodutor).

DROP FUNCTION IF EXISTS public.calcular_taxa_natalidade(text, text, text);

CREATE OR REPLACE FUNCTION public.calcular_taxa_natalidade(
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
  total_pariram bigint,
  total_expostas bigint
)
LANGUAGE sql
STABLE
AS $function$
WITH bounds AS (
  SELECT
    data_inicio_param::date AS d0,
    data_fim_param::date    AS d1
),
raw_activity AS (
  SELECT
    rep.id_rebanho_matriz,
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
    min(b.cat_titulo) AS cat_titulo
  FROM base_activity b
  GROUP BY b.id_rebanho_matriz
),
pariram_ids AS (
  SELECT DISTINCT rep.id_rebanho_matriz
  FROM public.reproducao rep
  CROSS JOIN bounds b
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.data_parto IS NOT NULL
    AND rep.data_parto::date >= b.d0
    AND rep.data_parto::date <= b.d1
    AND lower(trim(coalesce(rep.status_reproducao, ''))) NOT LIKE '%natimorto%'
    AND rep.id_rebanho_matriz IS NOT NULL
    AND btrim(rep.id_rebanho_matriz) <> ''
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
per_matriz_full AS (
  SELECT
    p.id_rebanho_matriz,
    p.cat_titulo,
    (pi.id_rebanho_matriz IS NOT NULL) AS pariu
  FROM per_matriz p
  LEFT JOIN pariram_ids pi ON pi.id_rebanho_matriz = p.id_rebanho_matriz
),
agg AS (
  SELECT
    f.cat_titulo AS titulo,
    count(*)::bigint AS total_expostas,
    count(*) FILTER (WHERE f.pariu)::bigint AS total_pariram
  FROM per_matriz_full f
  GROUP BY f.cat_titulo
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
$function$;

COMMENT ON FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text) IS
  'Taxa de natalidade por categoria com filtros opcionais (lote, inseminador, reprodutor), alinhados à taxa de concepção.';

ALTER FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text)
  TO anon, authenticated, service_role;
