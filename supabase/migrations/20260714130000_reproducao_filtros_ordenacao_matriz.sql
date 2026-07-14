-- Reprodução: corrige ordenação da coluna "Matriz" (WEB - BUG - P.BAIXA).
--
-- A ordenação por Matriz usava COALESCE(v."nomeMatriz", '') — o NOME do animal,
-- que é vazio para animais "S/N" (sem nome), a maioria do rebanho. Com a chave
-- toda vazia, asc e desc produziam a mesma ordem (desempate por created_at/id),
-- então a coluna parecia "travada": o 1º clique movia o sort, mas inverter (2º
-- clique) não reordenava nada.
--
-- A célula da coluna exibe `numMatriz • nomeMatriz` (ex.: "A4986 • S/N"), ou seja
-- o identificador visível é o NÚMERO (numMatriz), sempre preenchido. A ordenação
-- passa a priorizar numMatriz, com fallback para o nome.
--
-- IMPORTANTE: esta definição parte da função VIVA em produção (ORDER BY já ciente
-- da direção via p_sort_direction), que divergia das migrações versionadas no
-- repo (que tinham DESC fixo). Recria a função alinhando repo e produção e
-- aplicando apenas a mudança da chave de Matriz.

CREATE OR REPLACE FUNCTION public.reproducao_filtros(
  p_id_propriedade text DEFAULT ''::text,
  p_data_reproducao_de text DEFAULT ''::text,
  p_data_reproducao_ate text DEFAULT ''::text,
  p_data_previsao_parto_de text DEFAULT ''::text,
  p_data_previsao_parto_ate text DEFAULT ''::text,
  p_data_diagnostico_de text DEFAULT ''::text,
  p_data_diagnostico_ate text DEFAULT ''::text,
  p_tipo_reproducao text DEFAULT ''::text,
  p_lote_nome text DEFAULT ''::text,
  p_inseminador text DEFAULT ''::text,
  p_pesquisa text DEFAULT ''::text,
  p_matriz text DEFAULT ''::text,
  p_reprodutor text DEFAULT ''::text,
  p_status_reproducao text DEFAULT ''::text,
  p_categoria text DEFAULT ''::text,
  p_limite integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_sort_column text DEFAULT ''::text,
  p_sort_direction text DEFAULT 'desc'::text
)
RETURNS SETOF view_reproducao_detalhada
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  sort_column text := lower(coalesce(nullif(trim(p_sort_column), ''), 'created_at'));
  sort_direction text := lower(coalesce(nullif(trim(p_sort_direction), ''), 'desc'));
BEGIN
  RETURN QUERY
  SELECT v.*
  FROM public.view_reproducao_detalhada v
  LEFT JOIN public.rebanho matriz ON matriz."idRebanho" = v.id_rebanho_matriz
  WHERE
    p_id_propriedade <> ''
    AND v.id_propriedade = p_id_propriedade
    AND (v.deletado IS NULL OR v.deletado <> 'SIM')
    AND (v.ressinc IS NULL OR v.ressinc <> 'SIM')
    AND (p_data_reproducao_de = '' OR COALESCE(v.data_inseminacao, v.data_inicial)::date >= p_data_reproducao_de::date)
    AND (p_data_reproducao_ate = '' OR COALESCE(v.data_inseminacao, v.data_inicial)::date <= p_data_reproducao_ate::date)
    AND (p_data_previsao_parto_de = '' OR (v.previsao_parto IS NOT NULL AND v.previsao_parto::date >= p_data_previsao_parto_de::date))
    AND (p_data_previsao_parto_ate = '' OR (v.previsao_parto IS NOT NULL AND v.previsao_parto::date <= p_data_previsao_parto_ate::date))
    AND (p_data_diagnostico_de = '' OR (v.data_status IS NOT NULL AND v.data_status::date >= p_data_diagnostico_de::date))
    AND (p_data_diagnostico_ate = '' OR (v.data_status IS NOT NULL AND v.data_status::date <= p_data_diagnostico_ate::date))
    AND (p_tipo_reproducao = '' OR lower(trim(v.tipo_reproducao)) = lower(trim(p_tipo_reproducao)))
    AND (p_lote_nome = '' OR v."loteNome" = p_lote_nome)
    AND (p_inseminador = '' OR v.inseminador = p_inseminador)
    AND (p_matriz = '' OR v.id_rebanho_matriz = p_matriz)
    AND (p_reprodutor = '' OR v.id_rebanho_reprodutor = p_reprodutor)
    AND (
      p_categoria = ''
      OR lower(coalesce(nullif(trim(v.categoria), ''), nullif(trim(matriz.categoria), ''), '')) = lower(trim(p_categoria))
    )
    AND (
      nullif(trim(p_status_reproducao), '') IS NULL
      OR lower(trim(coalesce(v.status_reproducao, ''))) = ANY (
        ARRAY(
          SELECT lower(trim(value))
          FROM unnest(string_to_array(p_status_reproducao, ',')) AS status(value)
          WHERE trim(value) <> ''
        )
      )
    )
    AND (p_pesquisa = '' OR (v."nomeMatriz" IS NOT NULL AND v."nomeMatriz" ILIKE '%' || p_pesquisa || '%')
      OR (v."numMatriz" IS NOT NULL AND v."numMatriz" ILIKE '%' || p_pesquisa || '%')
      OR (v."nomeReprodutor" IS NOT NULL AND v."nomeReprodutor" ILIKE '%' || p_pesquisa || '%')
      OR (v."numReprodutor" IS NOT NULL AND v."numReprodutor" ILIKE '%' || p_pesquisa || '%'))
  ORDER BY
    CASE WHEN sort_direction = 'asc' AND sort_column = 'created_at' THEN v.created_at END ASC NULLS LAST,
    CASE WHEN sort_direction <> 'asc' AND sort_column = 'created_at' THEN v.created_at END DESC NULLS LAST,
    CASE WHEN sort_direction = 'asc' AND sort_column = 'data' THEN COALESCE(v.data_inseminacao, v.data_inicial) END ASC NULLS LAST,
    CASE WHEN sort_direction <> 'asc' AND sort_column = 'data' THEN COALESCE(v.data_inseminacao, v.data_inicial) END DESC NULLS LAST,
    CASE WHEN sort_direction = 'asc' AND sort_column = 'tipo_reproducao' THEN v.tipo_reproducao END ASC NULLS LAST,
    CASE WHEN sort_direction <> 'asc' AND sort_column = 'tipo_reproducao' THEN v.tipo_reproducao END DESC NULLS LAST,
    CASE WHEN sort_direction = 'asc' AND sort_column = 'status' THEN v.status_reproducao END ASC NULLS LAST,
    CASE WHEN sort_direction <> 'asc' AND sort_column = 'status' THEN v.status_reproducao END DESC NULLS LAST,
    CASE WHEN sort_direction = 'asc' AND sort_column = 'matriz' THEN COALESCE(NULLIF(v."numMatriz", ''), v."nomeMatriz", '') END ASC NULLS LAST,
    CASE WHEN sort_direction <> 'asc' AND sort_column = 'matriz' THEN COALESCE(NULLIF(v."numMatriz", ''), v."nomeMatriz", '') END DESC NULLS LAST,
    v.created_at DESC NULLS LAST,
    v.id DESC
  LIMIT NULLIF(p_limite, 0)
  OFFSET p_offset;
END;
$function$;
