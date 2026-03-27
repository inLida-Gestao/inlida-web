-- Gráfico "Nascimentos no período" usa nascimentos_por_mes via Edge Function.
-- O app persiste animais vindos de nascimento com tipo = 'Nascimento'; a RPC só
-- aceitava tipo = 'animal', excluindo esses registros (ex.: março sem barras).

CREATE OR REPLACE FUNCTION public.nascimentos_por_mes(p_inicio date, p_fim date, p_id_propriedade text)
 RETURNS TABLE(mes date, label text, total bigint, machos bigint, femeas bigint)
 LANGUAGE sql
AS $function$
WITH meses AS (
  SELECT
    date_trunc('month', p_inicio)::date AS ini,
    date_trunc('month', p_fim)::date    AS fim
),
series AS (
  SELECT gs::date AS mes
  FROM meses m,
       generate_series(m.ini, m.fim, interval '1 month') gs
),
nasc AS (
  SELECT
    r."dataNascimento"::date AS nasc_data,
    CASE
      WHEN lower(coalesce(r.sexo,'')) IN ('m','macho','machos','male') THEN 'M'
      WHEN lower(coalesce(r.sexo,'')) IN ('f','femea','fêmea','femeas','female') THEN 'F'
      ELSE NULL
    END AS sexo_norm
  FROM public.rebanho r
  WHERE r.deletado IS DISTINCT FROM 'SIM'
    AND lower(coalesce(r.tipo, '')) IN ('animal', 'nascimento')
    AND r."dataNascimento" IS NOT NULL
    AND r."dataNascimento"::date BETWEEN p_inicio AND p_fim
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
)
SELECT
  s.mes,
  to_char(s.mes, 'MM/YYYY') AS label,
  COUNT(n.*)::bigint AS total,
  COUNT(n.*) FILTER (WHERE n.sexo_norm = 'M')::bigint AS machos,
  COUNT(n.*) FILTER (WHERE n.sexo_norm = 'F')::bigint AS femeas
FROM series s
LEFT JOIN nasc n
  ON n.nasc_data >= s.mes
 AND n.nasc_data < (s.mes + interval '1 month')
GROUP BY s.mes
ORDER BY s.mes;
$function$;

CREATE OR REPLACE FUNCTION public.nascimentos_por_mes(p_inicio date, p_fim date, p_id_propriedade text, p_raca text DEFAULT ''::text)
 RETURNS TABLE(mes date, label text, total bigint, machos bigint, femeas bigint)
 LANGUAGE sql
AS $function$
WITH meses AS (
  SELECT
    date_trunc('month', p_inicio)::date AS ini,
    date_trunc('month', p_fim)::date    AS fim
),
series AS (
  SELECT gs::date AS mes
  FROM meses m,
       generate_series(m.ini, m.fim, interval '1 month') gs
),
nasc AS (
  SELECT
    r."dataNascimento"::date AS nasc_data,
    CASE
      WHEN lower(coalesce(r.sexo,'')) IN ('m','macho','machos','male') THEN 'M'
      WHEN lower(coalesce(r.sexo,'')) IN ('f','femea','fêmea','femeas','female') THEN 'F'
      ELSE NULL
    END AS sexo_norm
  FROM public.rebanho r
  WHERE r.deletado IS DISTINCT FROM 'SIM'
    AND lower(coalesce(r.tipo, '')) IN ('animal', 'nascimento')
    AND r."dataNascimento" IS NOT NULL
    AND r."dataNascimento"::date BETWEEN p_inicio AND p_fim
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
    AND (
      p_raca = ''
      OR r.raca = ANY(string_to_array(p_raca, ','))
    )
)
SELECT
  s.mes,
  to_char(s.mes, 'MM/YYYY') AS label,
  COUNT(n.*)::bigint AS total,
  COUNT(n.*) FILTER (WHERE n.sexo_norm = 'M')::bigint AS machos,
  COUNT(n.*) FILTER (WHERE n.sexo_norm = 'F')::bigint AS femeas
FROM series s
LEFT JOIN nasc n
  ON n.nasc_data >= s.mes
 AND n.nasc_data < (s.mes + interval '1 month')
GROUP BY s.mes
ORDER BY s.mes;
$function$;
