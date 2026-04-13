-- Bug #2: Taxa de prenhez incluindo monta natural.
-- Denominador: vacas DISTINTAS com inseminação OU monta natural no período.
--   Cada vaca conta uma vez, mesmo com múltiplos registros.
-- Numerador: dessas vacas, as que têm status "prenhe..." em qualquer registro
--   do período.

CREATE OR REPLACE FUNCTION public.calcular_taxa_prenhez(
    id_propriedade_param text,
    data_inicio_param text,
    data_fim_param text,
    p_lote_id text DEFAULT ''::text,
    p_inseminador text DEFAULT ''::text,
    p_id_rebanho_reprodutor text DEFAULT ''::text
)
RETURNS TABLE(titulo text, porcentagem numeric, total_prenhe bigint, total_inseminadas bigint)
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN
RETURN QUERY
WITH raw AS (
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
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.id_rebanho_matriz IS NOT NULL
    AND btrim(rep.id_rebanho_matriz) <> ''
    -- Inseminação OU monta natural no período
    AND (
      (
        rep.data_inseminacao IS NOT NULL
        AND rep.data_inseminacao::date >= data_inicio_param::date
        AND rep.data_inseminacao::date <= data_fim_param::date
      )
      OR (
        rep.data_inicial IS NOT NULL
        AND rep.data_final IS NOT NULL
        AND rep.data_inicial::date >= data_inicio_param::date
        AND rep.data_final::date <= data_fim_param::date
      )
    )
    -- Filtros opcionais
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
-- Uma linha por vaca: conta uma vez no denominador, prenhe se qualquer registro = prenhe
per_matriz AS (
  SELECT
    b.id_rebanho_matriz,
    min(b.cat_titulo) AS cat_titulo,
    bool_or(
      lower(trim(coalesce(b.status_reproducao, ''))) LIKE 'prenhe%'
    ) AS eh_prenhe
  FROM base b
  GROUP BY b.id_rebanho_matriz
),
agg AS (
  SELECT
    f.cat_titulo AS titulo,
    count(*)::bigint AS total_inseminadas,
    count(*) FILTER (WHERE f.eh_prenhe)::bigint AS total_prenhe
  FROM per_matriz f
  GROUP BY f.cat_titulo
)
SELECT
  a.titulo,
  CASE
    WHEN a.total_inseminadas > 0 THEN round(100.0 * a.total_prenhe / a.total_inseminadas::numeric, 2)
    ELSE 0::numeric
  END AS porcentagem,
  a.total_prenhe,
  a.total_inseminadas
FROM agg a
WHERE a.titulo IN ('Novilha', 'Vaca Primipara', 'Vaca Multipara')
ORDER BY
  CASE a.titulo
    WHEN 'Novilha' THEN 1
    WHEN 'Vaca Primipara' THEN 2
    WHEN 'Vaca Multipara' THEN 3
    ELSE 9
  END;
END
$function$;

COMMENT ON FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text) IS
  'Taxa de prenhez (%): denominador = vacas DISTINTAS com inseminação OU monta natural no período; numerador = dessas, as com status prenhe. Cada vaca conta uma vez no denominador.';
