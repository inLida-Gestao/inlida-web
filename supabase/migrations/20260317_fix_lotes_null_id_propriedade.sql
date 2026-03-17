-- Fix: Excluir lotes com id_propriedade NULL das funções lotes_filtros e count_lotes_filtros
-- Lotes sem propriedade associada não devem aparecer nos resultados

-- =============================================
-- 1. lotes_filtros - Adiciona filtro IS NOT NULL
-- =============================================

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
AS $function$
  SELECT
    l.id,
    l.created_at,
    l.id_propriedade,
    l.id_animais,
    l.nome,
    l.anotacoes,
    l.ativo,
    l.data_entrada_piquete,
    l.data_saida_piquete,
    l.motivo,
    l.data_motivo,
    l.id_lote,
    l.deletado,
    l.updated_at,
    l."valorVenda",
    COALESCE(rc.qtd_rebanhos_no_lote, 0)::bigint AS qtd_rebanhos_no_lote
  FROM public.lotes l
  LEFT JOIN (
    SELECT
      r."loteNome" AS nome_lote,
      r."idPropriedade" AS id_propriedade_ref,
      COUNT(*)::bigint AS qtd_rebanhos_no_lote
    FROM public.rebanho r
    WHERE r.deletado = 'NAO'
      AND r."loteNome" IS NOT NULL
      AND btrim(r."loteNome") <> ''
      AND lower(btrim(r."loteNome")) <> 'null'
    GROUP BY r."loteNome", r."idPropriedade"
  ) rc
    ON rc.nome_lote = l.nome
   AND rc.id_propriedade_ref = l.id_propriedade
  WHERE l.deletado = 'NAO'
    AND l.id_propriedade IS NOT NULL
    AND l.id_propriedade = p_id_propriedade
    AND (p_pesquisa = '' OR l.nome ILIKE '%' || p_pesquisa || '%')
    AND (p_status = '' OR l.ativo = p_status)
    AND (p_data_criacao_de = '' OR l.created_at::date >= TO_DATE(p_data_criacao_de, 'YYYY-MM-DD'))
    AND (p_data_criacao_ate = '' OR l.created_at::date <= TO_DATE(p_data_criacao_ate, 'YYYY-MM-DD'))
  ORDER BY l.id DESC
  LIMIT p_limite
  OFFSET p_offset;
$function$;

-- =============================================
-- 2. count_lotes_filtros - Adiciona filtro IS NOT NULL
-- =============================================

DROP FUNCTION IF EXISTS public.count_lotes_filtros(text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.count_lotes_filtros(
  p_id_propriedade text,
  p_pesquisa text,
  p_status text,
  p_data_criacao_de text DEFAULT '',
  p_data_criacao_ate text DEFAULT ''
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
  FROM public.lotes
  WHERE id_propriedade IS NOT NULL
    AND id_propriedade = p_id_propriedade
    AND (p_pesquisa = '' OR nome ILIKE '%' || p_pesquisa || '%')
    AND (p_status = '' OR ativo = p_status)
    AND (p_data_criacao_de = '' OR created_at::date >= TO_DATE(p_data_criacao_de, 'YYYY-MM-DD'))
    AND (p_data_criacao_ate = '' OR created_at::date <= TO_DATE(p_data_criacao_ate, 'YYYY-MM-DD'))
    AND deletado = 'NAO'
$function$;
