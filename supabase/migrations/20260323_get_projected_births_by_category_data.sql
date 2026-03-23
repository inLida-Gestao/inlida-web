-- Painel: gráfico "Projeção de partos por categoria no período".
-- A edge function reproducao-projecao-partos chama esta RPC; se não existir ou
-- estiver vazia, o gráfico fica com Total 0 enquanto "Partos por categoria"
-- (get_births_by_category_data / data_parto) continua com dados.

CREATE OR REPLACE FUNCTION public.get_projected_births_by_category_data(
  id_propriedade_param text,
  inicio_param text,
  fim_param text
)
RETURNS TABLE (
  mes date,
  label text,
  "Novilha" bigint,
  "Primípara" bigint,
  "Multípara" bigint
)
LANGUAGE sql
STABLE
AS $function$
WITH bounds AS (
  SELECT
    inicio_param::date AS d0,
    fim_param::date    AS d1
),
months AS (
  SELECT gs::date AS bucket_mes
  FROM bounds b,
  generate_series(
    date_trunc('month', b.d0)::date,
    date_trunc('month', b.d1)::date,
    interval '1 month'
  ) AS gs
),
base AS (
  SELECT
    date_trunc('month', rep.previsao_parto::date)::date AS bucket_mes,
    lower(btrim(rb.categoria)) AS cat_lower
  FROM public.reproducao rep
  INNER JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
  CROSS JOIN bounds b
  WHERE id_propriedade_param IS NOT NULL
    AND btrim(id_propriedade_param) <> ''
    AND rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado <> 'SIM')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.previsao_parto IS NOT NULL
    AND rep.previsao_parto::date >= b.d0
    AND rep.previsao_parto::date <= b.d1
    AND rb.deletado = 'NAO'
    AND rb."idPropriedade" = id_propriedade_param
)
SELECT
  m.bucket_mes AS mes,
  to_char(m.bucket_mes, 'MM/YYYY') AS label,
  COALESCE(
    count(*) FILTER (
      WHERE b.cat_lower LIKE 'novilha%'
    ),
    0
  )::bigint AS "Novilha",
  COALESCE(
    count(*) FILTER (
      WHERE b.cat_lower LIKE 'vaca primipara%'
         OR b.cat_lower LIKE 'vaca primípara%'
    ),
    0
  )::bigint AS "Primípara",
  COALESCE(
    count(*) FILTER (
      WHERE b.cat_lower LIKE 'vaca multipara%'
         OR b.cat_lower LIKE 'vaca multípara%'
    ),
    0
  )::bigint AS "Multípara"
FROM months m
LEFT JOIN base b ON b.bucket_mes = m.bucket_mes
GROUP BY m.bucket_mes
ORDER BY m.bucket_mes;
$function$;

COMMENT ON FUNCTION public.get_projected_births_by_category_data(text, text, text) IS
  'Agrega registros de reproducao por mês de previsao_parto e categoria da matriz (rebanho.categoria), para o painel.';

GRANT EXECUTE ON FUNCTION public.get_projected_births_by_category_data(text, text, text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_projected_births_by_category_data(text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_projected_births_by_category_data(text, text, text) TO service_role;
