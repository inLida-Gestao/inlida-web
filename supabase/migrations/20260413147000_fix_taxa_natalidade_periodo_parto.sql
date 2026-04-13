-- Fix: Taxa de natalidade deve filtrar pelo período do PARTO, não da inseminação.
-- Vacas inseminadas em 2024 com parto em 2025 devem contar na taxa de 2025.
--
-- Lógica corrigida:
-- Denominador (total_expostas): vacas com atividade reprodutiva que poderiam ter
--   parido no período (inseminação ~285 dias antes do fim do período, ou monta natural
--   com data_final ~285 dias antes do fim do período).
-- Numerador (total_pariram): dessas vacas, as que efetivamente pariram (data_parto
--   dentro do período).

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
    data_fim_param::date    AS d1
),
-- Registros reprodutivos que podem ter resultado em parto no período:
-- A gestação bovina dura ~285 dias, então buscamos inseminações/montas
-- de até 300 dias antes do fim do período até o fim do período.
-- Também inclui qualquer registro que tenha data_parto no período.
raw_activity AS (
  SELECT
    rep.id_rebanho_matriz,
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
    -- Critério: inseminação/monta que pode ter gerado parto no período,
    -- OU registro com data_parto no período
    AND (
      -- Inseminação dentro de uma janela de gestação que resulta em parto no período
      (
        rep.data_inseminacao IS NOT NULL
        AND rep.data_inseminacao::date >= (b.d0 - interval '300 days')::date
        AND rep.data_inseminacao::date <= b.d1
      )
      -- Monta natural dentro da janela
      OR (
        rep.data_inicial IS NOT NULL
        AND rep.data_inicial::date >= (b.d0 - interval '300 days')::date
        AND rep.data_inicial::date <= b.d1
      )
      -- Registro com parto no período (caso não tenha data de inseminação/monta)
      OR (
        rep.data_parto IS NOT NULL
        AND rep.data_parto::date >= b.d0
        AND rep.data_parto::date <= b.d1
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
base_activity AS (
  SELECT
    r.id_rebanho_matriz,
    -- Parto conta somente se data_parto está dentro do período selecionado
    (
      r.data_parto IS NOT NULL
      AND r.data_parto::date >= (SELECT d0 FROM bounds)
      AND r.data_parto::date <= (SELECT d1 FROM bounds)
      AND lower(trim(coalesce(r.status_reproducao, ''))) NOT LIKE '%natimorto%'
    ) AS tem_parto,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%' THEN 'Vaca Primípara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%' THEN 'Vaca Multípara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw_activity r
),
-- Uma linha por vaca: ela pariu se QUALQUER registro dela tem parto no período
per_matriz AS (
  SELECT
    b.id_rebanho_matriz,
    min(b.cat_titulo) AS cat_titulo,
    bool_or(b.tem_parto) AS pariu
  FROM base_activity b
  GROUP BY b.id_rebanho_matriz
),
agg AS (
  SELECT
    f.cat_titulo AS titulo,
    count(*)::bigint AS total_expostas,
    count(*) FILTER (WHERE f.pariu)::bigint AS total_pariram
  FROM per_matriz f
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
END
$function$;
