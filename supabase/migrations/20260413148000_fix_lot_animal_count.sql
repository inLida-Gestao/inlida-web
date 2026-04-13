-- Bug #16: Corrigir contagem de animais nos lotes.
--
-- Causa raiz: pg_edit_lote_widget.dart salvava loteID = novoLoteNome (nome do lote)
-- em vez de loteID = id_lote (ID real). Isso fazia com que a contagem por loteID
-- não encontrasse os animais.
--
-- Correções:
-- 1. Frontend: loteID agora recebe o id_lote correto ao salvar
-- 2. _loadAnimaisDoLoteParaEdicao: agora usa lógica inclusiva (OR) como pg_view_lote
-- 3. lotes_filtros: adicionado match loteID = nome do lote (compatibilidade com dados legados)
-- 4. Data fix: animais com loteID = nome do lote foram corrigidos para usar o id_lote real

-- Atualização da função lotes_filtros para também encontrar animais cujo loteID
-- contém o nome do lote (dados legados do bug).
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
  created_at timestamptz,
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
  updated_at timestamp,
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
            -- Match by loteID = id_lote (normal case)
            (
              NULLIF(btrim(r."loteID"), '') IS NOT NULL
              AND lower(btrim(r."loteID")) <> 'null'
              AND l.id_lote IS NOT NULL
              AND NULLIF(btrim(l.id_lote), '') IS NOT NULL
              AND lower(btrim(l.id_lote)) <> 'null'
              AND r."loteID" = l.id_lote
            )
            -- Match by loteNome = nome
            OR (
              NULLIF(btrim(r."loteNome"), '') IS NOT NULL
              AND lower(btrim(r."loteNome")) <> 'null'
              AND l.nome IS NOT NULL
              AND NULLIF(btrim(l.nome), '') IS NOT NULL
              AND lower(btrim(l.nome)) <> 'null'
              AND r."loteNome" = l.nome
            )
            -- Match by loteID = nome (bug legado: loteID recebia o nome do lote)
            OR (
              NULLIF(btrim(r."loteID"), '') IS NOT NULL
              AND lower(btrim(r."loteID")) <> 'null'
              AND l.nome IS NOT NULL
              AND NULLIF(btrim(l.nome), '') IS NOT NULL
              AND lower(btrim(l.nome)) <> 'null'
              AND r."loteID" = l.nome
            )
            -- Match by id_animais JSON array
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

-- Data fix: corrigir animais onde loteID contém o nome do lote em vez do id_lote
UPDATE public.rebanho r
SET "loteID" = l.id_lote,
    updated_at = NOW()
FROM public.lotes l
WHERE r.deletado = 'NAO'
  AND r."loteID" IS NOT NULL
  AND r."loteID" != ''
  AND r."loteID" != 'null'
  AND NOT EXISTS (
    SELECT 1 FROM public.lotes l2
    WHERE l2.id_lote = r."loteID"
      AND l2.deletado = 'NAO'
  )
  AND l.nome = r."loteID"
  AND l.id_propriedade = r."idPropriedade"
  AND l.deletado = 'NAO';
