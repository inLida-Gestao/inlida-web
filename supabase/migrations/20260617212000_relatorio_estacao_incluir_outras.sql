-- Relatório da estação: inclui linha "Outras" calculada na RPC e antes oculta
-- na resposta, mantendo diagnósticos na mesma base que "matrizes" — registros
-- com serviço (COALESCE(inseminação, início)) no período.
--
-- Antes, as contagens de diagnóstico usavam CTE no_periodo (data_diag no intervalo),
-- o que zerava os valores quando data_status ficava fora do filtro do painel mas o
-- serviço estava no período (alinhado ao gráfico "Diagnósticos por categoria").

CREATE OR REPLACE FUNCTION public.get_relatorio_resumo_estacao(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text
)
RETURNS jsonb
LANGUAGE sql
STABLE
AS $function$
WITH di AS (SELECT data_inicio_param::date AS d0, data_fim_param::date AS d1),
raw AS (
  SELECT
    rep.id,
    rep.id_rebanho_matriz,
    rep.tipo_reproducao,
    rep.status_reproducao,
    rep.data_status,
    rep.data_inseminacao,
    rep.data_inicial,
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
  CROSS JOIN di
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND coalesce(rep.data_inseminacao, rep.data_inicial) IS NOT NULL
    AND coalesce(rep.data_inseminacao, rep.data_inicial)::date >= di.d0
    AND coalesce(rep.data_inseminacao, rep.data_inicial)::date <= di.d1
),
serv AS (
  SELECT
    r.*,
    (coalesce(r.data_status, r.data_inseminacao, r.data_inicial))::date AS data_diag,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%'
        OR r.cat_l LIKE 'vaca primípara%'
        OR r.cat_l IN ('primipara', 'primípara')
        THEN 'Vaca Primipara'
      WHEN r.cat_l LIKE 'vaca multipara%'
        OR r.cat_l LIKE 'vaca multípara%'
        OR r.cat_l IN ('multipara', 'multípara')
        THEN 'Vaca Multipara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw r
),
prenhez_nati_cond AS (
  SELECT s.*
  FROM serv s
  WHERE
    (
      lower(trim(coalesce(s.status_reproducao, ''))) LIKE 'prenhe%'
      OR lower(trim(coalesce(s.status_reproducao, ''))) LIKE 'prenha%'
      OR lower(trim(coalesce(s.status_reproducao, ''))) = 'natimorto'
    )
),
prenhez_dist AS (
  SELECT
    n.cat_titulo,
    count(DISTINCT n.id_rebanho_matriz)::bigint AS n
  FROM serv n
  WHERE n.id_rebanho_matriz IS NOT NULL
    AND (
      lower(trim(coalesce(n.status_reproducao, ''))) LIKE 'prenhe%'
      OR lower(trim(coalesce(n.status_reproducao, ''))) LIKE 'prenha%'
      OR lower(trim(coalesce(n.status_reproducao, ''))) = 'natimorto'
    )
  GROUP BY n.cat_titulo
),
vazio_dist AS (
  SELECT
    n.cat_titulo,
    count(DISTINCT n.id_rebanho_matriz)::bigint AS n
  FROM serv n
  WHERE n.id_rebanho_matriz IS NOT NULL
    AND lower(trim(coalesce(n.status_reproducao, ''))) = 'vazio'
  GROUP BY n.cat_titulo
),
outros_dist AS (
  SELECT
    n.cat_titulo,
    count(DISTINCT n.id_rebanho_matriz)::bigint AS n
  FROM serv n
  WHERE n.id_rebanho_matriz IS NOT NULL
    AND lower(trim(coalesce(n.status_reproducao, ''))) IN (
      'absorção',
      'absorcao',
      'aborto',
      'não diagnosticado',
      'nao diagnosticado'
    )
  GROUP BY n.cat_titulo
),
expostas AS (
  SELECT
    s.cat_titulo,
    count(DISTINCT s.id_rebanho_matriz)::bigint AS n
  FROM serv s
  WHERE s.id_rebanho_matriz IS NOT NULL
  GROUP BY s.cat_titulo
),
ia_reg AS (
  SELECT
    p.cat_titulo,
    count(*)::bigint AS n
  FROM prenhez_nati_cond p
  WHERE lower(trim(coalesce(p.tipo_reproducao, ''))) IN (
    'inseminação',
    'inseminacao'
  )
  GROUP BY p.cat_titulo
),
touro_reg AS (
  SELECT
    p.cat_titulo,
    count(*)::bigint AS n
  FROM prenhez_nati_cond p
  WHERE lower(trim(coalesce(p.tipo_reproducao, ''))) IN (
    'monta natural'
  )
  GROUP BY p.cat_titulo
),
nati_reg AS (
  SELECT
    p.cat_titulo,
    count(*)::bigint AS n
  FROM prenhez_nati_cond p
  GROUP BY p.cat_titulo
),
expostas_total AS (
  SELECT coalesce(sum(e.n), 0)::bigint AS n
  FROM expostas e
  WHERE e.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
),
prenhez_nati_reg_total AS (
  SELECT count(*)::bigint AS n
  FROM prenhez_nati_cond
),
vazio_total AS (
  SELECT coalesce(sum(v.n), 0)::bigint AS n
  FROM vazio_dist v
  WHERE v.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
),
outros_total AS (
  SELECT coalesce(sum(o.n), 0)::bigint AS n
  FROM outros_dist o
  WHERE o.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
),
ia_total AS (
  SELECT coalesce(sum(i.n), 0)::bigint AS n
  FROM ia_reg i
  WHERE i.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
),
touro_total AS (
  SELECT coalesce(sum(t.n), 0)::bigint AS n
  FROM touro_reg t
  WHERE t.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
),
prenhez_total AS (
  SELECT coalesce(sum(p.n), 0)::bigint AS n
  FROM prenhez_dist p
  WHERE p.cat_titulo IN ('Vaca Multipara', 'Vaca Primipara', 'Novilha', 'Outras')
),
ultima_dg AS (
  SELECT max(s.data_status::date) AS d
  FROM serv s
  CROSS JOIN di
  WHERE s.data_status IS NOT NULL
    AND s.data_status::date >= di.d0
    AND s.data_status::date <= di.d1
),
r_mult AS (
  SELECT
    1 AS ord,
    'Vaca Multipara'::text AS categoria,
    coalesce(e.n, 0)::bigint AS matrizes,
    coalesce(p.n, 0)::bigint AS prenhez,
    coalesce(v.n, 0)::bigint AS vazio,
    coalesce(o.n, 0)::bigint AS outros,
    coalesce(ia.n, 0)::bigint AS prenhas_ia,
    coalesce(tr.n, 0)::bigint AS prenhas_touro,
    coalesce(
      round(100.0 * coalesce(na.n, 0)::numeric / nullif(e.n, 0), 2),
      0
    )::numeric AS prenhez_pct
  FROM
    (SELECT 1) _
  LEFT JOIN prenhez_dist p ON p.cat_titulo = 'Vaca Multipara'
  LEFT JOIN vazio_dist v ON v.cat_titulo = 'Vaca Multipara'
  LEFT JOIN outros_dist o ON o.cat_titulo = 'Vaca Multipara'
  LEFT JOIN ia_reg ia ON ia.cat_titulo = 'Vaca Multipara'
  LEFT JOIN touro_reg tr ON tr.cat_titulo = 'Vaca Multipara'
  LEFT JOIN nati_reg na ON na.cat_titulo = 'Vaca Multipara'
  LEFT JOIN expostas e ON e.cat_titulo = 'Vaca Multipara'
),
r_prim AS (
  SELECT
    2 AS ord,
    'Vaca Primipara'::text AS categoria,
    coalesce(e.n, 0)::bigint AS matrizes,
    coalesce(p.n, 0)::bigint,
    coalesce(v.n, 0)::bigint,
    coalesce(o.n, 0)::bigint,
    coalesce(ia.n, 0)::bigint,
    coalesce(tr.n, 0)::bigint,
    coalesce(
      round(100.0 * coalesce(na.n, 0)::numeric / nullif(e.n, 0), 2),
      0
    )::numeric
  FROM
    (SELECT 1) _
  LEFT JOIN prenhez_dist p ON p.cat_titulo = 'Vaca Primipara'
  LEFT JOIN vazio_dist v ON v.cat_titulo = 'Vaca Primipara'
  LEFT JOIN outros_dist o ON o.cat_titulo = 'Vaca Primipara'
  LEFT JOIN ia_reg ia ON ia.cat_titulo = 'Vaca Primipara'
  LEFT JOIN touro_reg tr ON tr.cat_titulo = 'Vaca Primipara'
  LEFT JOIN nati_reg na ON na.cat_titulo = 'Vaca Primipara'
  LEFT JOIN expostas e ON e.cat_titulo = 'Vaca Primipara'
),
r_nov AS (
  SELECT
    3 AS ord,
    'Novilha'::text AS categoria,
    coalesce(e.n, 0)::bigint AS matrizes,
    coalesce(p.n, 0)::bigint,
    coalesce(v.n, 0)::bigint,
    coalesce(o.n, 0)::bigint,
    coalesce(ia.n, 0)::bigint,
    coalesce(tr.n, 0)::bigint,
    coalesce(
      round(100.0 * coalesce(na.n, 0)::numeric / nullif(e.n, 0), 2),
      0
    )::numeric
  FROM
    (SELECT 1) _
  LEFT JOIN prenhez_dist p ON p.cat_titulo = 'Novilha'
  LEFT JOIN vazio_dist v ON v.cat_titulo = 'Novilha'
  LEFT JOIN outros_dist o ON o.cat_titulo = 'Novilha'
  LEFT JOIN ia_reg ia ON ia.cat_titulo = 'Novilha'
  LEFT JOIN touro_reg tr ON tr.cat_titulo = 'Novilha'
  LEFT JOIN nati_reg na ON na.cat_titulo = 'Novilha'
  LEFT JOIN expostas e ON e.cat_titulo = 'Novilha'
),
r_outras AS (
  SELECT
    4 AS ord,
    'Outras'::text AS categoria,
    coalesce(e.n, 0)::bigint AS matrizes,
    coalesce(p.n, 0)::bigint,
    coalesce(v.n, 0)::bigint,
    coalesce(o.n, 0)::bigint,
    coalesce(ia.n, 0)::bigint,
    coalesce(tr.n, 0)::bigint,
    coalesce(
      round(100.0 * coalesce(na.n, 0)::numeric / nullif(e.n, 0), 2),
      0
    )::numeric
  FROM
    (SELECT 1) _
  LEFT JOIN prenhez_dist p ON p.cat_titulo = 'Outras'
  LEFT JOIN vazio_dist v ON v.cat_titulo = 'Outras'
  LEFT JOIN outros_dist o ON o.cat_titulo = 'Outras'
  LEFT JOIN ia_reg ia ON ia.cat_titulo = 'Outras'
  LEFT JOIN touro_reg tr ON tr.cat_titulo = 'Outras'
  LEFT JOIN nati_reg na ON na.cat_titulo = 'Outras'
  LEFT JOIN expostas e ON e.cat_titulo = 'Outras'
),
r_total AS (
  SELECT
    5 AS ord,
    'Total'::text AS categoria,
    et.n AS matrizes,
    p.n AS prenhez,
    v.n AS vazio,
    o.n AS outros,
    i.n AS prenhas_ia,
    t.n AS prenhas_touro,
    coalesce(
      round(100.0 * (SELECT pnt.n FROM prenhez_nati_reg_total pnt)::numeric / nullif(et.n, 0), 2),
      0
    )::numeric AS prenhez_pct
  FROM
    prenhez_total p
    CROSS JOIN vazio_total v
    CROSS JOIN outros_total o
    CROSS JOIN ia_total i
    CROSS JOIN touro_total t
    CROSS JOIN expostas_total et
),
linhas_union AS (
  SELECT * FROM r_mult
  UNION ALL
  SELECT * FROM r_prim
  UNION ALL
  SELECT * FROM r_nov
  UNION ALL
  SELECT * FROM r_outras
  UNION ALL
  SELECT * FROM r_total
)
SELECT jsonb_build_object(
  'linhas', coalesce(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'categoria', u.categoria,
          'matrizes', u.matrizes,
          'prenhez', u.prenhez,
          'vazio', u.vazio,
          'outros', u.outros,
          'prenhas_ia', u.prenhas_ia,
          'prenhas_touro', u.prenhas_touro,
          'prenhez_pct', u.prenhez_pct
        )
        ORDER BY u.ord
      )
      FROM linhas_union u
    ),
    '[]'::jsonb
  ),
  'data_ultimo_dg', to_char((SELECT d FROM ultima_dg), 'YYYY-MM-DD'),
  'expostas_total', (SELECT n FROM expostas_total)
) AS result
$function$;

ALTER FUNCTION public.get_relatorio_resumo_estacao(text, text, text)
  SECURITY DEFINER
  SET search_path = public;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: matrizes e diagnósticos nos mesmos registros com serviço no período (inseminação/início), incluindo linha Outras. Última DG: max(data_status) no período.';
