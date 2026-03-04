-- =============================================================================
-- Referência para as funções RPC de filtros de Reprodução (Supabase)
-- =============================================================================
-- O app chama: POST /rest/v1/rpc/reproducao_filtros e /rpc/contar_reproducao_filtros
-- com corpo JSON onde as chaves são os nomes dos parâmetros abaixo.
--
-- Ajuste o nome da view (view_reproducao_detalhada) se no seu banco for outro.
-- Se as colunas da view forem criadas em minúsculas (ex.: lotenome), use
-- v.lotenome em vez de v."loteNome"; idem para nomeMatriz, numMatriz, etc.
-- Garanta que a view expõe: id_propriedade, data_inseminacao, previsao_parto,
-- tipo_reproducao, categoria, loteNome, inseminador, id_rebanho_matriz,
-- id_rebanho_reprodutor, e demais colunas esperadas pelo app (ReproducaoDTStruct).
-- =============================================================================

-- 1) Função de listagem (com paginação e ordenação)
CREATE OR REPLACE FUNCTION public.reproducao_filtros(
  p_id_propriedade text DEFAULT '',
  p_data_reproducao text DEFAULT '',
  p_data_previsao_parto text DEFAULT '',
  p_tipo_reproducao text DEFAULT '',
  p_lote_nome text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_matriz text DEFAULT '',
  p_reprodutor text DEFAULT '',
  p_limite int DEFAULT 20,
  p_offset int DEFAULT 0,
  p_sort_column text DEFAULT 'data_inseminacao',
  p_sort_direction text DEFAULT 'desc'
)
RETURNS SETOF view_reproducao_detalhada
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT v.*
  FROM view_reproducao_detalhada v
  WHERE
    (p_id_propriedade = '' OR v.id_propriedade = p_id_propriedade)
    AND (v.deletado IS NULL OR v.deletado <> 'SIM')
    -- Data reprodução (data da inseminação)
    AND (p_data_reproducao = '' OR (v.data_inseminacao IS NOT NULL AND (v.data_inseminacao::date)::text = p_data_reproducao)
         OR (v.data_inicial IS NOT NULL AND (v.data_inicial::date)::text = p_data_reproducao))
    -- Previsão de parto
    AND (p_data_previsao_parto = '' OR (v.previsao_parto IS NOT NULL AND (v.previsao_parto::date)::text = p_data_previsao_parto))
    -- Categoria (campo "Categorias" do filtro no app)
    AND (p_tipo_reproducao = '' OR v.categoria = p_tipo_reproducao)
    -- Lote
    AND (p_lote_nome = '' OR v."loteNome" = p_lote_nome)
    -- Inseminador
    AND (p_inseminador = '' OR v.inseminador = p_inseminador)
    -- Matriz (id_rebanho da matriz)
    AND (p_matriz = '' OR v.id_rebanho_matriz = p_matriz)
    -- Reprodutor (id_rebanho do reprodutor)
    AND (p_reprodutor = '' OR v.id_rebanho_reprodutor = p_reprodutor)
    -- Pesquisa (nome ou número da matriz/reprodutor)
    AND (
      p_pesquisa = ''
      OR (
        (v."nomeMatriz" IS NOT NULL AND v."nomeMatriz" ILIKE '%' || p_pesquisa || '%')
        OR (v."numMatriz" IS NOT NULL AND v."numMatriz" ILIKE '%' || p_pesquisa || '%')
        OR (v."nomeReprodutor" IS NOT NULL AND v."nomeReprodutor" ILIKE '%' || p_pesquisa || '%')
        OR (v."numReprodutor" IS NOT NULL AND v."numReprodutor" ILIKE '%' || p_pesquisa || '%')
      )
    )
  ORDER BY
    CASE p_sort_column
      WHEN 'tipo_reproducao' THEN v.tipo_reproducao
      WHEN 'status' THEN v.status_reproducao
      WHEN 'matriz' THEN COALESCE(v."nomeMatriz", '')
      ELSE (COALESCE(v.data_inseminacao, v.data_inicial)::text)
    END
  DESC NULLS LAST
  LIMIT NULLIF(p_limite, 0)
  OFFSET p_offset;
END;
$$;

-- 2) Função de contagem (mesmos filtros, sem paginação/ordenação)
CREATE OR REPLACE FUNCTION public.contar_reproducao_filtros(
  p_id_propriedade text DEFAULT '',
  p_data_reproducao text DEFAULT '',
  p_data_previsao_parto text DEFAULT '',
  p_tipo_reproducao text DEFAULT '',
  p_lote_nome text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_matriz text DEFAULT '',
  p_reprodutor text DEFAULT ''
)
RETURNS bigint
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  total bigint;
BEGIN
  SELECT COUNT(*) INTO total
  FROM view_reproducao_detalhada v
  WHERE
    (p_id_propriedade = '' OR v.id_propriedade = p_id_propriedade)
    AND (v.deletado IS NULL OR v.deletado <> 'SIM')
    AND (p_data_reproducao = '' OR (v.data_inseminacao IS NOT NULL AND (v.data_inseminacao::date)::text = p_data_reproducao)
         OR (v.data_inicial IS NOT NULL AND (v.data_inicial::date)::text = p_data_reproducao))
    AND (p_data_previsao_parto = '' OR (v.previsao_parto IS NOT NULL AND (v.previsao_parto::date)::text = p_data_previsao_parto))
    AND (p_tipo_reproducao = '' OR v.categoria = p_tipo_reproducao)
    AND (p_lote_nome = '' OR v."loteNome" = p_lote_nome)
    AND (p_inseminador = '' OR v.inseminador = p_inseminador)
    AND (p_matriz = '' OR v.id_rebanho_matriz = p_matriz)
    AND (p_reprodutor = '' OR v.id_rebanho_reprodutor = p_reprodutor)
    AND (
      p_pesquisa = ''
      OR (
        (v."nomeMatriz" IS NOT NULL AND v."nomeMatriz" ILIKE '%' || p_pesquisa || '%')
        OR (v."numMatriz" IS NOT NULL AND v."numMatriz" ILIKE '%' || p_pesquisa || '%')
        OR (v."nomeReprodutor" IS NOT NULL AND v."nomeReprodutor" ILIKE '%' || p_pesquisa || '%')
        OR (v."numReprodutor" IS NOT NULL AND v."numReprodutor" ILIKE '%' || p_pesquisa || '%')
      )
    );
  RETURN total;
END;
$$;

-- Conceder execução ao role anon/authenticated (ajuste conforme suas políticas)
-- GRANT EXECUTE ON FUNCTION public.reproducao_filtros(...) TO anon;
-- GRANT EXECUTE ON FUNCTION public.contar_reproducao_filtros(...) TO anon;
