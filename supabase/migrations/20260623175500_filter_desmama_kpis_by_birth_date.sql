-- Corrige os KPIs "Idade desmama (Meses)" e "Peso desmama (kg)"
-- para considerar no período somente animais nascidos entre inicio/fim.
-- A data de desmama continua sendo usada apenas para calcular a idade,
-- não para decidir se o animal entra no filtro.

CREATE OR REPLACE FUNCTION public.idade_desmama_media(
  p_inicio date,
  p_fim date,
  p_id_propriedade text,
  p_sexo text
)
RETURNS TABLE(media_meses numeric, total_animais bigint)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_total bigint;
  v_media numeric;
BEGIN
  SELECT
    COUNT(*)::bigint,
    AVG(
      (
        EXTRACT(YEAR FROM age(r."dataDesmama", r."dataNascimento")) * 12
        + EXTRACT(MONTH FROM age(r."dataDesmama", r."dataNascimento"))
        + (EXTRACT(DAY FROM age(r."dataDesmama", r."dataNascimento")) / 30.44)
      )::numeric
    )
  INTO v_total, v_media
  FROM public.rebanho r
  WHERE r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r."dataNascimento" IS NOT NULL
    AND r."dataDesmama" IS NOT NULL
    AND r."dataNascimento" BETWEEN p_inicio AND p_fim
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
    AND (p_sexo IS NULL OR r.sexo = p_sexo);

  RETURN QUERY
  SELECT
    COALESCE(ROUND(v_media, 2), 0),
    COALESCE(v_total, 0);
END;
$function$;

CREATE OR REPLACE FUNCTION public.peso_desmama_medio(
  p_inicio date,
  p_fim date,
  p_id_propriedade text,
  p_sexo text
)
RETURNS TABLE(sexo text, valor numeric, n bigint)
LANGUAGE sql
AS $function$
  WITH base AS (
    SELECT
      r.sexo,
      r."pesoDesmama"
    FROM public.rebanho r
    WHERE r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND r."pesoDesmama" IS NOT NULL
      AND r."dataNascimento" BETWEEN p_inicio AND p_fim
      AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
      AND (p_sexo IS NULL OR r.sexo = p_sexo)
  ),
  agrupado AS (
    SELECT
      CASE
        WHEN p_sexo IS NULL THEN 'T'
        ELSE sexo
      END AS sexo_final,
      AVG("pesoDesmama")::numeric(10,2) AS valor,
      COUNT(*)::bigint AS n
    FROM base
    GROUP BY
      CASE
        WHEN p_sexo IS NULL THEN 'T'
        ELSE sexo
      END
  )
  SELECT sexo_final AS sexo, valor, n
  FROM agrupado;
$function$;
