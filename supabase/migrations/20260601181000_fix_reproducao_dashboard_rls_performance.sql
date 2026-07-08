-- Corrige timeouts/HTTP 500 nos cards e graficos de reproducao apos ativar RLS.
-- Os RPCs agregadores precisam validar acesso uma vez e executar como SECURITY DEFINER,
-- evitando avaliar policies linha-a-linha em consultas analiticas.

CREATE INDEX IF NOT EXISTS idx_reproducao_prop_inseminacao_active
  ON public.reproducao (id_propriedade, data_inseminacao)
  WHERE (deletado IS NULL OR deletado = 'NAO')
    AND (ressinc IS NULL OR ressinc <> 'SIM');

CREATE INDEX IF NOT EXISTS idx_reproducao_prop_inicial_active
  ON public.reproducao (id_propriedade, data_inicial)
  WHERE (deletado IS NULL OR deletado = 'NAO')
    AND (ressinc IS NULL OR ressinc <> 'SIM');

CREATE INDEX IF NOT EXISTS idx_reproducao_prop_lote_active
  ON public.reproducao (id_propriedade, id_lote)
  WHERE (deletado IS NULL OR deletado = 'NAO')
    AND (ressinc IS NULL OR ressinc <> 'SIM');

CREATE INDEX IF NOT EXISTS idx_reproducao_prop_matriz_active
  ON public.reproducao (id_propriedade, id_rebanho_matriz)
  WHERE (deletado IS NULL OR deletado = 'NAO')
    AND (ressinc IS NULL OR ressinc <> 'SIM');

CREATE INDEX IF NOT EXISTS idx_rebanho_prop_matriz_nascimento_active
  ON public.rebanho ("idPropriedade", "rebanhoIdMatriz", "dataNascimento")
  WHERE deletado IS DISTINCT FROM 'SIM'
    AND tipo = 'animal';

CREATE OR REPLACE FUNCTION public.calcular_taxa_prenhez(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT ''::text,
  p_inseminador text DEFAULT ''::text,
  p_id_rebanho_reprodutor text DEFAULT ''::text
)
RETURNS TABLE(titulo text, porcentagem numeric, total_prenhe bigint, total_inseminadas bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
WITH access_check AS (
  SELECT public.usuario_tem_acesso_propriedade(id_propriedade_param) AS ok
),
raw AS (
  SELECT
    rep.status_reproducao,
    lower(
      coalesce(
        nullif(btrim(rep.categoria), ''),
        nullif(btrim(rb.categoria), ''),
        ''
      )
    ) AS cat_l
  FROM public.reproducao rep
  CROSS JOIN access_check ac
  LEFT JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
    AND rb."idPropriedade" = id_propriedade_param
    AND rb.deletado = 'NAO'
  WHERE ac.ok
    AND rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.data_inseminacao IS NOT NULL
    AND rep.data_inseminacao::date >= data_inicio_param::date
    AND rep.data_inseminacao::date <= data_fim_param::date
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
    r.status_reproducao,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%' THEN 'Vaca Primipara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%' THEN 'Vaca Multipara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw r
),
agg AS (
  SELECT
    b.cat_titulo AS titulo,
    count(*)::bigint AS total_inseminadas,
    count(*) FILTER (
      WHERE lower(trim(coalesce(b.status_reproducao, ''))) LIKE 'prenhe%'
    )::bigint AS total_prenhe
  FROM base b
  GROUP BY b.cat_titulo
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
$function$;

CREATE OR REPLACE FUNCTION public.calcular_taxa_natalidade(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT ''::text,
  p_inseminador text DEFAULT ''::text,
  p_id_rebanho_reprodutor text DEFAULT ''::text
)
RETURNS TABLE(titulo text, porcentagem numeric, total_pariram bigint, total_expostas bigint)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
IF NOT public.usuario_tem_acesso_propriedade(id_propriedade_param) THEN
  RETURN;
END IF;

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

CREATE OR REPLACE FUNCTION public.calculate_media_primeira_cria(
  p_id_propriedade text,
  p_data_inicio date DEFAULT NULL::date,
  p_data_fim date DEFAULT NULL::date
)
RETURNS TABLE(valor_medio numeric, total_matrizes bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
WITH access_check AS (
  SELECT public.usuario_tem_acesso_propriedade(p_id_propriedade) AS ok
),
IdadePrimeiraCria AS (
  SELECT
    m."idRebanho",
    m."dataNascimento"::date AS data_nascimento_matriz,
    MIN(c."dataNascimento"::date) AS data_primeira_cria,
    (
      (MIN(c."dataNascimento"::date) - m."dataNascimento"::date)::numeric
      / 30.4375
    ) AS idade_primeira_cria_meses
  FROM public.rebanho m
  CROSS JOIN access_check ac
  JOIN public.rebanho c
    ON m."idRebanho" = c."rebanhoIdMatriz"
  WHERE ac.ok
    AND m."idPropriedade" = p_id_propriedade
    AND c."idPropriedade" = p_id_propriedade
    AND m.deletado IS DISTINCT FROM 'SIM'
    AND c.deletado IS DISTINCT FROM 'SIM'
    AND m.tipo = 'animal'
    AND c.tipo = 'animal'
    AND m."dataNascimento" IS NOT NULL
    AND c."dataNascimento" IS NOT NULL
    AND lower(trim(coalesce(m.sexo,''))) IN ('f', 'femea', 'fêmea', 'feminino')
    AND (p_data_inicio IS NULL OR c."dataNascimento"::date >= p_data_inicio)
    AND (p_data_fim IS NULL OR c."dataNascimento"::date <= p_data_fim)
    AND c."dataNascimento"::date >= m."dataNascimento"::date
  GROUP BY
    m."idRebanho", m."dataNascimento"
)
SELECT
  ROUND(COALESCE(AVG(ipc.idade_primeira_cria_meses), 0), 2) AS valor_medio,
  COUNT(ipc."idRebanho") AS total_matrizes
FROM IdadePrimeiraCria ipc
WHERE ipc.idade_primeira_cria_meses <= 36;
$function$;

ALTER FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text) OWNER TO postgres;
ALTER FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text) OWNER TO postgres;
ALTER FUNCTION public.calculate_media_primeira_cria(text, date, date) OWNER TO postgres;

REVOKE EXECUTE ON FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.calculate_media_primeira_cria(text, date, date) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calcular_taxa_natalidade(text, text, text, text, text, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_media_primeira_cria(text, date, date) TO authenticated, service_role;
