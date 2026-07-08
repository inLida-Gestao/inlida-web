-- Usa rebanho.loteID como fonte do vínculo animal/lote.
-- lotes.id_animais permanece no retorno por compatibilidade de schema, mas não
-- participa mais da contagem/listagem de animais do lote.
-- rebanho.loteNome só é fallback para registros legados sem loteID válido.

DROP FUNCTION IF EXISTS public.lotes_filtros(text, text, text, text, text, int, int);
DROP FUNCTION IF EXISTS public.lotes_filtros(text, text, text, text, text, int, int, text, boolean);

CREATE OR REPLACE FUNCTION public.lotes_filtros(
  p_id_propriedade text,
  p_pesquisa text DEFAULT '',
  p_status text DEFAULT '',
  p_data_criacao_de text DEFAULT '',
  p_data_criacao_ate text DEFAULT '',
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0,
  p_order_by text DEFAULT 'id',
  p_order_ascending boolean DEFAULT false
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
  WITH params AS (
    SELECT
      CASE
        WHEN lower(coalesce(p_order_by, 'id')) IN (
          'nome',
          'qtd_rebanhos_no_lote',
          'numero_animais',
          'animais',
          'status',
          'id'
        ) THEN lower(coalesce(p_order_by, 'id'))
        ELSE 'id'
      END AS order_by,
      coalesce(p_order_ascending, false) AS sort_ascending
  ),
  lote_filtrado AS (
    SELECT l.*
    FROM public.lotes l
    WHERE l.deletado = 'NAO'
      AND l.id_propriedade IS NOT NULL
      AND l.id_propriedade = p_id_propriedade
      AND (p_pesquisa = '' OR l.nome ILIKE '%' || p_pesquisa || '%')
      AND (p_status = '' OR l.ativo = p_status)
      AND (p_data_criacao_de = '' OR l.created_at::date >= TO_DATE(p_data_criacao_de, 'YYYY-MM-DD'))
      AND (p_data_criacao_ate = '' OR l.created_at::date <= TO_DATE(p_data_criacao_ate, 'YYYY-MM-DD'))
  ),
  match_lote_id AS (
    SELECT lf.id AS lote_pk, r.id AS reb_id
    FROM lote_filtrado lf
    JOIN public.rebanho r ON r."loteID" = lf.id_lote
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
      AND lf.id_lote IS NOT NULL AND btrim(lf.id_lote) <> ''
      AND lower(btrim(lf.id_lote)) <> 'null'
  ),
  match_lote_nome AS (
    SELECT lf.id AS lote_pk, r.id AS reb_id
    FROM lote_filtrado lf
    JOIN public.rebanho r ON r."loteNome" = lf.nome
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
      AND (
        r."loteID" IS NULL
        OR btrim(r."loteID") = ''
        OR lower(btrim(r."loteID")) = 'null'
      )
      AND lf.nome IS NOT NULL AND btrim(lf.nome) <> ''
      AND lower(btrim(lf.nome)) <> 'null'
  ),
  match_lote_id_nome AS (
    SELECT lf.id AS lote_pk, r.id AS reb_id
    FROM lote_filtrado lf
    JOIN public.rebanho r ON r."loteID" = lf.nome
    WHERE r.deletado = 'NAO'
      AND r."idPropriedade" = p_id_propriedade
      AND lf.nome IS NOT NULL AND btrim(lf.nome) <> ''
      AND lower(btrim(lf.nome)) <> 'null'
  ),
  contagem AS (
    SELECT lote_pk, COUNT(DISTINCT reb_id)::bigint AS qtd
    FROM (
      SELECT lote_pk, reb_id FROM match_lote_id
      UNION ALL
      SELECT lote_pk, reb_id FROM match_lote_nome
      UNION ALL
      SELECT lote_pk, reb_id FROM match_lote_id_nome
    ) m
    GROUP BY lote_pk
  ),
  lotes_com_contagem AS (
    SELECT
      lf.id,
      lf.created_at,
      lf.id_propriedade,
      lf.id_animais,
      lf.nome,
      lf.anotacoes,
      lf.ativo,
      lf.data_entrada_piquete,
      lf.data_saida_piquete,
      lf.motivo,
      lf.data_motivo,
      lf.id_lote,
      lf.deletado,
      lf.updated_at,
      NULL::numeric AS "valorVenda",
      COALESCE(c.qtd, 0)::bigint AS qtd_rebanhos_no_lote,
      CASE
        WHEN lower(btrim(coalesce(lf.ativo, ''))) = 'ativo'
          AND lf.data_saida_piquete IS NULL
          AND lf.data_motivo IS NULL
          AND NULLIF(btrim(coalesce(lf.motivo, '')), '') IS NULL
        THEN 0
        ELSE 1
      END AS status_sort
    FROM lote_filtrado lf
    LEFT JOIN contagem c ON c.lote_pk = lf.id
  ),
  lotes_ordenados AS (
    SELECT lc.*
    FROM lotes_com_contagem lc
    CROSS JOIN params p
    ORDER BY
      CASE WHEN p.order_by = 'nome' AND p.sort_ascending THEN lower(coalesce(lc.nome, '')) END ASC NULLS LAST,
      CASE WHEN p.order_by = 'nome' AND NOT p.sort_ascending THEN lower(coalesce(lc.nome, '')) END DESC NULLS LAST,
      CASE WHEN p.order_by IN ('qtd_rebanhos_no_lote', 'numero_animais', 'animais') AND p.sort_ascending THEN lc.qtd_rebanhos_no_lote END ASC NULLS LAST,
      CASE WHEN p.order_by IN ('qtd_rebanhos_no_lote', 'numero_animais', 'animais') AND NOT p.sort_ascending THEN lc.qtd_rebanhos_no_lote END DESC NULLS LAST,
      CASE WHEN p.order_by = 'status' AND p.sort_ascending THEN lc.status_sort END ASC NULLS LAST,
      CASE WHEN p.order_by = 'status' AND NOT p.sort_ascending THEN lc.status_sort END DESC NULLS LAST,
      CASE WHEN p.order_by = 'id' AND p.sort_ascending THEN lc.id END ASC NULLS LAST,
      CASE WHEN p.order_by = 'id' AND NOT p.sort_ascending THEN lc.id END DESC NULLS LAST,
      lower(coalesce(lc.nome, '')) ASC,
      lc.id DESC
    LIMIT p_limite
    OFFSET p_offset
  )
  SELECT
    lo.id,
    lo.created_at,
    lo.id_propriedade,
    lo.id_animais,
    lo.nome,
    lo.anotacoes,
    lo.ativo,
    lo.data_entrada_piquete,
    lo.data_saida_piquete,
    lo.motivo,
    lo.data_motivo,
    lo.id_lote,
    lo.deletado,
    lo.updated_at,
    lo."valorVenda",
    lo.qtd_rebanhos_no_lote
  FROM lotes_ordenados lo;
$function$;
