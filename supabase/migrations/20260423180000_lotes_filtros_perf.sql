-- Otimiza performance da listagem de lotes (~100x mais rapido em propriedades grandes).
--
-- Mudancas:
--  1. Indices em rebanho/lotes para acelerar os JOINs.
--  2. Reescreve lotes_filtros usando equi-joins (UNION ALL de 3 sub-queries),
--     em vez do nested loop com 3 OR pesados que forcava sequencial scan
--     da tabela rebanho para cada lote.
--
-- Mesmo contrato (assinatura e colunas).

-- =========================
-- 1. Indices
-- =========================
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

-- =========================
-- 2. Funcao otimizada
-- =========================
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
  -- Match A: rebanho.loteID = lote.id_lote (caminho mais comum, usa indice).
  match_lote_id AS (
    SELECT lp.id AS lote_pk, r.id AS reb_id
    FROM lote_pagina lp
    JOIN public.rebanho r ON r."loteID" = lp.id_lote
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
      AND lp.id_lote IS NOT NULL AND btrim(lp.id_lote) <> ''
      AND lower(btrim(lp.id_lote)) <> 'null'
  ),
  -- Match B: rebanho.loteNome = lote.nome (usa indice).
  match_lote_nome AS (
    SELECT lp.id AS lote_pk, r.id AS reb_id
    FROM lote_pagina lp
    JOIN public.rebanho r ON r."loteNome" = lp.nome
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
      AND lp.nome IS NOT NULL AND btrim(lp.nome) <> ''
      AND lower(btrim(lp.nome)) <> 'null'
  ),
  -- Match C: id_animais (jsonb array) contem rebanho.idRebanho.
  -- Expande o JSON em ids e faz equi-join (usa indice em rebanho.idRebanho).
  ids_no_array AS (
    SELECT lp.id AS lote_pk, jsonb_array_elements_text(lp.id_animais::jsonb) AS reb_id_str
    FROM lote_pagina lp
    WHERE lp.id_animais IS NOT NULL
      AND btrim(lp.id_animais) <> ''
      AND lower(btrim(lp.id_animais)) NOT IN ('null', '[]')
      AND left(btrim(lp.id_animais), 1) = '['
  ),
  match_id_animais AS (
    SELECT ina.lote_pk, r.id AS reb_id
    FROM ids_no_array ina
    JOIN public.rebanho r ON r."idRebanho" = ina.reb_id_str
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
  ),
  contagem AS (
    SELECT lote_pk, COUNT(DISTINCT reb_id)::bigint AS qtd
    FROM (
      SELECT lote_pk, reb_id FROM match_lote_id
      UNION ALL
      SELECT lote_pk, reb_id FROM match_lote_nome
      UNION ALL
      SELECT lote_pk, reb_id FROM match_id_animais
    ) m
    GROUP BY lote_pk
  )
  SELECT
    lp.id, lp.created_at, lp.id_propriedade, lp.id_animais, lp.nome,
    lp.anotacoes, lp.ativo, lp.data_entrada_piquete, lp.data_saida_piquete,
    lp.motivo, lp.data_motivo, lp.id_lote, lp.deletado, lp.updated_at,
    NULL::numeric AS "valorVenda",
    COALESCE(c.qtd, 0)::bigint AS qtd_rebanhos_no_lote
  FROM lote_pagina lp
  LEFT JOIN contagem c ON c.lote_pk = lp.id
  ORDER BY lp.id DESC;
$function$;
