-- Resumo da estação: contar VACAS DISTINTAS (não serviços) e alinhar a prenhez
-- ao gráfico de taxa de prenhez (calcular_taxa_prenhez2).
--
-- Regressão (BUG-WEB-P.ALTA): a versão 20260714120000 (natimorto→outros) foi
-- baseada numa versão antiga que contava registros de reprodução (count(*)),
-- sobrescrevendo o dedup por matriz de 20260618151146. Resultado: a tabela
-- mostrava nº de serviços (ex.: 233) em vez de vacas distintas (181).
--
-- Correção: deduplica por id_rebanho_matriz (uma linha por vaca), com a MESMA
-- base do taxa_prenhez2:
--   * janela por data específica do tipo (monta natural = data_inicial;
--     inseminação = data_inseminacao) — corrige também a prenhez por monta
--     natural, que ficava fora quando data_inseminacao era nula;
--   * só registros com matriz vinculada;
--   * prenhe = bool_or(status LIKE 'prenhe%' / 'prenha%') por vaca.
-- Cada vaca cai em exatamente um desfecho: prenhez > vazio > outros
-- (outros = não diagnosticado / aborto / natimorto / absorção etc.).
-- prenhez/prenhas_ia/prenhas_touro por vaca distinta batem com o gráfico.

CREATE OR REPLACE FUNCTION public.get_relatorio_resumo_estacao(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text
)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
WITH di AS (SELECT data_inicio_param::date AS d0, data_fim_param::date AS d1),
raw AS (
  SELECT
    rep.id_rebanho_matriz,
    rep.tipo_reproducao,
    rep.status_reproducao,
    rep.data_status,
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
    AND rep.id_rebanho_matriz IS NOT NULL
    AND btrim(rep.id_rebanho_matriz) <> ''
    AND (
      CASE WHEN lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
        THEN rep.data_inicial ELSE rep.data_inseminacao END
    ) IS NOT NULL
    AND (
      CASE WHEN lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
        THEN rep.data_inicial ELSE rep.data_inseminacao END
    )::date >= di.d0
    AND (
      CASE WHEN lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
        THEN rep.data_inicial ELSE rep.data_inseminacao END
    )::date <= di.d1
),
base AS (
  SELECT
    r.id_rebanho_matriz,
    r.data_status,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%'
        OR r.cat_l IN ('primipara', 'primípara') THEN 'Vaca Primipara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%'
        OR r.cat_l IN ('multipara', 'multípara') THEN 'Vaca Multipara'
      ELSE 'Outras'
    END AS cat_titulo,
    (
      lower(trim(coalesce(r.status_reproducao, ''))) LIKE 'prenhe%'
      OR lower(trim(coalesce(r.status_reproducao, ''))) LIKE 'prenha%'
    ) AS is_prenhe,
    (lower(trim(coalesce(r.status_reproducao, ''))) = 'vazio') AS is_vazio,
    lower(btrim(coalesce(r.tipo_reproducao, ''))) AS tipo_l
  FROM raw r
),
per_matriz AS (
  SELECT
    b.id_rebanho_matriz,
    min(b.cat_titulo) AS cat_titulo,
    bool_or(b.is_prenhe) AS eh_prenhe,
    bool_or(b.is_vazio) AS tem_vazio,
    bool_or(b.is_prenhe AND b.tipo_l IN ('inseminação', 'inseminacao')) AS prenhe_ia,
    bool_or(b.is_prenhe AND b.tipo_l = 'monta natural') AS prenhe_touro
  FROM base b
  GROUP BY b.id_rebanho_matriz
),
agg AS (
  SELECT
    cat_titulo,
    count(*)::bigint AS matrizes,
    count(*) FILTER (WHERE eh_prenhe)::bigint AS prenhez,
    count(*) FILTER (WHERE NOT eh_prenhe AND tem_vazio)::bigint AS vazio,
    count(*) FILTER (WHERE NOT eh_prenhe AND NOT tem_vazio)::bigint AS outros,
    count(*) FILTER (WHERE prenhe_ia)::bigint AS prenhas_ia,
    count(*) FILTER (WHERE prenhe_touro)::bigint AS prenhas_touro
  FROM per_matriz
  GROUP BY cat_titulo
),
cats AS (
  SELECT * FROM (VALUES
    ('Vaca Multipara', 1),
    ('Vaca Primipara', 2),
    ('Novilha', 3),
    ('Outras', 4)
  ) AS c(categoria, ord)
),
linhas_cat AS (
  SELECT
    c.ord,
    c.categoria,
    coalesce(a.matrizes, 0)::bigint AS matrizes,
    coalesce(a.prenhez, 0)::bigint AS prenhez,
    coalesce(a.vazio, 0)::bigint AS vazio,
    coalesce(a.outros, 0)::bigint AS outros,
    coalesce(a.prenhas_ia, 0)::bigint AS prenhas_ia,
    coalesce(a.prenhas_touro, 0)::bigint AS prenhas_touro,
    coalesce(round(100.0 * coalesce(a.prenhez, 0)::numeric / nullif(a.matrizes, 0), 2), 0)::numeric AS prenhez_pct
  FROM cats c
  LEFT JOIN agg a ON a.cat_titulo = c.categoria
),
tot AS (
  SELECT
    5 AS ord,
    'Total'::text AS categoria,
    coalesce(sum(matrizes), 0)::bigint AS matrizes,
    coalesce(sum(prenhez), 0)::bigint AS prenhez,
    coalesce(sum(vazio), 0)::bigint AS vazio,
    coalesce(sum(outros), 0)::bigint AS outros,
    coalesce(sum(prenhas_ia), 0)::bigint AS prenhas_ia,
    coalesce(sum(prenhas_touro), 0)::bigint AS prenhas_touro,
    coalesce(round(100.0 * coalesce(sum(prenhez), 0)::numeric / nullif(sum(matrizes), 0), 2), 0)::numeric AS prenhez_pct
  FROM linhas_cat
),
linhas_union AS (
  SELECT * FROM linhas_cat
  UNION ALL
  SELECT * FROM tot
),
ultima_dg AS (
  SELECT max(r.data_status::date) AS d
  FROM raw r
  CROSS JOIN di
  WHERE r.data_status IS NOT NULL
    AND r.data_status::date >= di.d0
    AND r.data_status::date <= di.d1
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
  'expostas_total', (SELECT coalesce(sum(matrizes), 0) FROM linhas_cat)
) AS result
$function$;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: VACAS DISTINTAS por categoria (dedup por id_rebanho_matriz), mesma base do calcular_taxa_prenhez2 (janela por data do tipo; só matriz vinculada). Prenhez = bool_or(prenhe/prenha) por vaca; cada vaca em um desfecho (prenhez>vazio>outros). Natimorto/aborto/absorção/não diagnosticado caem em Outros. Última DG: max(data_status) no período.';
