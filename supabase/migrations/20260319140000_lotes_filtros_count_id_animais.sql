-- Inclui na contagem animais referenciados em lotes.id_animais (mesma regra que pg_view_lote / edição).

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
    COALESCE(
      (
        SELECT COUNT(DISTINCT r.id)::bigint
        FROM public.rebanho r
        WHERE r.deletado = 'NAO'
          AND r."idPropriedade" = l.id_propriedade
          AND (
            (
              NULLIF(btrim(r."loteID"), '') IS NOT NULL
              AND lower(btrim(r."loteID")) <> 'null'
              AND l.id_lote IS NOT NULL
              AND NULLIF(btrim(l.id_lote), '') IS NOT NULL
              AND lower(btrim(l.id_lote)) <> 'null'
              AND r."loteID" = l.id_lote
            )
            OR (
              NULLIF(btrim(r."loteNome"), '') IS NOT NULL
              AND lower(btrim(r."loteNome")) <> 'null'
              AND l.nome IS NOT NULL
              AND NULLIF(btrim(l.nome), '') IS NOT NULL
              AND lower(btrim(l.nome)) <> 'null'
              AND r."loteNome" = l.nome
            )
            OR (
              r."idRebanho" IS NOT NULL
              AND NULLIF(btrim(r."idRebanho"), '') IS NOT NULL
              AND lower(btrim(r."idRebanho")) <> 'null'
              AND l.id_animais IS NOT NULL
              AND NULLIF(btrim(l.id_animais), '') IS NOT NULL
              AND lower(btrim(l.id_animais)) NOT IN ('null', '[]')
              AND left(btrim(l.id_animais), 1) = '['
              AND l.id_animais::jsonb @> jsonb_build_array(r."idRebanho")
            )
          )
      ),
      0
    )::bigint AS qtd_rebanhos_no_lote
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
  OFFSET p_offset;
$function$;
