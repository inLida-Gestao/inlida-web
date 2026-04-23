-- Otimiza performance da listagem de lotes:
--  1. Adiciona indices para acelerar o JOIN entre lotes e rebanho usado por lotes_filtros.
--  2. Reescreve lotes_filtros em duas etapas (CTE), de modo que o LIMIT seja aplicado
--     ANTES da contagem por lote, evitando varrer rebanho varias vezes.
-- Nenhuma mudanca de contrato (mesma assinatura e colunas).

CREATE INDEX IF NOT EXISTS idx_rebanho_prop_deletado
  ON public.rebanho ("idPropriedade", deletado);

CREATE INDEX IF NOT EXISTS idx_rebanho_loteid
  ON public.rebanho ("loteID")
  WHERE "loteID" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_rebanho_lotenome
  ON public.rebanho ("loteNome")
  WHERE "loteNome" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_rebanho_idrebanho
  ON public.rebanho ("idRebanho")
  WHERE "idRebanho" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_lotes_prop_deletado
  ON public.lotes (id_propriedade, deletado);

DROP FUNCTION IF EXISTS public.lotes_filtros(text, text, text, text, text, int, int);

CREATE OR REPLACE FUNCTION public.lotes_filtros(
  p_id_propriedade text,
  p_pesquisa text DEFAULT '',
  p_status text DEFAULT '',
  p_data_criacao_de text DEFAULT '',
  p_data_criacao_ate text DEFAULT '',
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0
)
RETURNS TABLE(
  id bigint,
  created_at timestamp with time zone,
  id_propriedade text,
  id_animais text,
  nome text,
  anotacoes text,
  ativo text,
  data_entrada_piquete date,
  data_saida_piquete date,
  motivo text,
  data_motivo date,
  id_lote text,
  deletado text,
  updated_at timestamp without time zone,
  "valorVenda" numeric,
  qtd_rebanhos_no_lote bigint
)
LANGUAGE sql
STABLE
AS $function$
  WITH lote_pagina AS (
    -- Aplica filtros e pagina ANTES de contar (no maximo p_limite linhas).
    SELECT l.*
    FROM public.lotes l
    WHERE l.deletado = 'NAO'
      AND l.id_propriedade IS NOT NULL
      AND l.id_propriedade = p_id_propriedade
      AND (p_pesquisa = '' OR l.nome ILIKE '%' || p_pesquisa || '%')
      AND (p_status = '' OR l.ativo = p_status)
      AND (p_data_criacao_de = '' OR l.created_at::date >= TO_DATE(p_data_criacao_de, 'YYYY-MM-DD'))
      AND (p_data_criacao_ate = '' OR l.created_at::date <= TO_DATE(p_data_criacao_ate, 'YYYY-MM-DD'))
    ORDER BY l.id DESC
    LIMIT p_limite
    OFFSET p_offset
  ),
  rebanho_prop AS (
    -- Carrega uma unica vez todos os rebanhos ativos da propriedade,
    -- com colunas ja normalizadas (trim, lower, etc.) para o JOIN.
    SELECT
      r.id,
      NULLIF(btrim(r."loteID"), '')   AS lote_id_norm,
      NULLIF(btrim(r."loteNome"), '') AS lote_nome_norm,
      NULLIF(btrim(r."idRebanho"), '') AS id_rebanho_norm
    FROM public.rebanho r
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
  ),
  contagem AS (
    SELECT lp.id AS lote_pk, COUNT(DISTINCT r.id)::bigint AS qtd
    FROM lote_pagina lp
    LEFT JOIN rebanho_prop r ON (
      (
        r.lote_id_norm IS NOT NULL
        AND lower(r.lote_id_norm) <> 'null'
        AND NULLIF(btrim(lp.id_lote), '') IS NOT NULL
        AND lower(btrim(lp.id_lote)) <> 'null'
        AND r.lote_id_norm = lp.id_lote
      )
      OR (
        r.lote_nome_norm IS NOT NULL
        AND lower(r.lote_nome_norm) <> 'null'
        AND NULLIF(btrim(lp.nome), '') IS NOT NULL
        AND lower(btrim(lp.nome)) <> 'null'
        AND r.lote_nome_norm = lp.nome
      )
      OR (
        r.id_rebanho_norm IS NOT NULL
        AND lower(r.id_rebanho_norm) <> 'null'
        AND lp.id_animais IS NOT NULL
        AND NULLIF(btrim(lp.id_animais), '') IS NOT NULL
        AND lower(btrim(lp.id_animais)) NOT IN ('null', '[]')
        AND left(btrim(lp.id_animais), 1) = '['
        AND lp.id_animais::jsonb @> jsonb_build_array(r.id_rebanho_norm)
      )
    )
    GROUP BY lp.id
  )
  SELECT
    lp.id,
    lp.created_at,
    lp.id_propriedade,
    lp.id_animais,
    lp.nome,
    lp.anotacoes,
    lp.ativo,
    lp.data_entrada_piquete,
    lp.data_saida_piquete,
    lp.motivo,
    lp.data_motivo,
    lp.id_lote,
    lp.deletado,
    lp.updated_at,
    lp."valorVenda",
    COALESCE(c.qtd, 0)::bigint AS qtd_rebanhos_no_lote
  FROM lote_pagina lp
  LEFT JOIN contagem c ON c.lote_pk = lp.id
  ORDER BY lp.id DESC;
$function$;
