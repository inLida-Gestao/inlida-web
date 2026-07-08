-- Painel: gráficos de desmama devem filtrar pelo período de nascimento.
--
-- Regra:
--   * O período selecionado no painel filtra rebanho."dataNascimento".
--   * "Desmamas no período" agrupa pela data real de desmama dos animais
--     nascidos no período, mesmo que a desmama ocorra no ano seguinte.
--   * "Projeção de desmamas" agrupa pela data projetada de desmama
--     (nascimento + 6/7/8 meses) dos animais nascidos no período, mesmo que a
--     projeção caia no ano seguinte.

CREATE OR REPLACE FUNCTION public.desmamas_por_mes(
  p_inicio date,
  p_fim date,
  p_id_propriedade text DEFAULT NULL::text
)
RETURNS TABLE(
  mes date,
  label text,
  total integer,
  machos integer,
  femeas integer
)
LANGUAGE sql
AS $function$
WITH des AS (
  SELECT
    r."dataDesmama"::date AS des_data,
    lower(trim(coalesce(r.sexo, ''))) AS sexo_norm
  FROM public.rebanho r
  WHERE r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r."dataNascimento" IS NOT NULL
    AND r."dataNascimento"::date BETWEEN p_inicio AND p_fim
    AND r."dataDesmama" IS NOT NULL
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
)
SELECT
  date_trunc('month', des.des_data)::date AS mes,
  to_char(date_trunc('month', des.des_data), 'MM/YYYY') AS label,
  count(*)::integer AS total,
  count(*) FILTER (
    WHERE des.sexo_norm IN ('macho', 'm', 'masculino')
  )::integer AS machos,
  count(*) FILTER (
    WHERE des.sexo_norm IN ('fêmea', 'femea', 'f', 'feminino')
  )::integer AS femeas
FROM des
GROUP BY 1, 2
ORDER BY 1;
$function$;

CREATE OR REPLACE FUNCTION public.projecao_desmamas(
  p_inicio date,
  p_fim date,
  p_id_propriedade text,
  p_sexo text
)
RETURNS TABLE(
  mes date,
  label text,
  proj_6m_machos bigint,
  proj_6m_femeas bigint,
  proj_7m_machos bigint,
  proj_7m_femeas bigint,
  proj_8m_machos bigint,
  proj_8m_femeas bigint
)
LANGUAGE sql
AS $function$
WITH base AS (
  SELECT
    r."dataNascimento"::date AS data_nasc,
    lower(trim(coalesce(r.sexo, ''))) AS sexo_norm
  FROM public.rebanho r
  WHERE r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r."dataNascimento" IS NOT NULL
    AND r."dataNascimento"::date BETWEEN p_inicio AND p_fim
    AND r."idPropriedade" = p_id_propriedade
    -- Desconsidera animais mortos: não serão desmamados.
    AND lower(trim(coalesce(r.status, ''))) <> 'morto'
    AND (
      p_sexo IS NULL
      OR lower(trim(coalesce(r.sexo, ''))) = lower(trim(p_sexo))
    )
),
t AS (
  SELECT
    (b.data_nasc + interval '6 months')::date AS p_mes,
    b.sexo_norm AS sexo,
    6 AS proj_mes
  FROM base b

  UNION ALL

  SELECT
    (b.data_nasc + interval '7 months')::date AS p_mes,
    b.sexo_norm AS sexo,
    7 AS proj_mes
  FROM base b

  UNION ALL

  SELECT
    (b.data_nasc + interval '8 months')::date AS p_mes,
    b.sexo_norm AS sexo,
    8 AS proj_mes
  FROM base b
)
SELECT
  date_trunc('month', t.p_mes)::date AS mes,
  to_char(date_trunc('month', t.p_mes), 'MM/YYYY') AS label,

  SUM(CASE WHEN t.proj_mes = 6 AND t.sexo IN ('macho', 'm', 'masculino') THEN 1 ELSE 0 END)::bigint AS proj_6m_machos,
  SUM(CASE WHEN t.proj_mes = 6 AND t.sexo IN ('fêmea', 'femea', 'f', 'feminino') THEN 1 ELSE 0 END)::bigint AS proj_6m_femeas,

  SUM(CASE WHEN t.proj_mes = 7 AND t.sexo IN ('macho', 'm', 'masculino') THEN 1 ELSE 0 END)::bigint AS proj_7m_machos,
  SUM(CASE WHEN t.proj_mes = 7 AND t.sexo IN ('fêmea', 'femea', 'f', 'feminino') THEN 1 ELSE 0 END)::bigint AS proj_7m_femeas,

  SUM(CASE WHEN t.proj_mes = 8 AND t.sexo IN ('macho', 'm', 'masculino') THEN 1 ELSE 0 END)::bigint AS proj_8m_machos,
  SUM(CASE WHEN t.proj_mes = 8 AND t.sexo IN ('fêmea', 'femea', 'f', 'feminino') THEN 1 ELSE 0 END)::bigint AS proj_8m_femeas
FROM t
GROUP BY 1, 2
ORDER BY mes;
$function$;

GRANT EXECUTE ON FUNCTION public.desmamas_por_mes(date, date, text) TO anon;
GRANT EXECUTE ON FUNCTION public.desmamas_por_mes(date, date, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.desmamas_por_mes(date, date, text) TO service_role;

GRANT EXECUTE ON FUNCTION public.projecao_desmamas(date, date, text, text) TO anon;
GRANT EXECUTE ON FUNCTION public.projecao_desmamas(date, date, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.projecao_desmamas(date, date, text, text) TO service_role;
