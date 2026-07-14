-- Corrige exibicao/vinculo de lote na reproducao e ordenacao padrao da lista.

CREATE OR REPLACE VIEW public.view_reproducao_detalhada AS
SELECT r.id,
    r.created_at,
    r.updated_at,
    r.id_propriedade,
    r.tipo_reproducao,
    r.id_rebanho_matriz,
    r.score_corporal,
    r.id_rebanho_reprodutor,
    r.data_inseminacao,
    r.data_partida_semen,
    r.partida_semen,
    r.previsao_parto,
    r.id_lote,
    r.data_inicial,
    r.data_final,
    r.status_reproducao,
    r.inseminador,
    r.anotacoes,
    r.id_reproducao,
    r.deletado,
    r.categoria,
    r."numMatriz",
    r."nomeMatriz",
    r."nascimentoMatriz",
    r."numReprodutor",
    r."nomeReprodutor",
    r."nascimentoReprodutor",
    COALESCE(NULLIF(r."loteNome", ''), l.nome) AS "loteNome",
    r.data_status,
    matriz."numeroAnimal" AS matriz_numeroanimal,
    matriz.chip AS matriz_chip,
    matriz.nome AS matriz_nome,
    matriz."dataNascimento" AS matriz_datanascimento,
    reprodutor."numeroAnimal" AS reprodutor_numeroanimal,
    reprodutor.chip AS reprodutor_chip,
    reprodutor.nome AS reprodutor_nome,
    reprodutor."dataNascimento" AS reprodutor_datanascimento,
    r.ressinc,
    r.parida,
    r.data_parto
   FROM public.reproducao r
     LEFT JOIN public.rebanho matriz ON r.id_rebanho_matriz = matriz."idRebanho"
     LEFT JOIN public.rebanho reprodutor ON r.id_rebanho_reprodutor = reprodutor."idRebanho"
     LEFT JOIN public.lotes l ON l.id_lote = r.id_lote
        AND l.id_propriedade = r.id_propriedade
        AND (l.deletado IS NULL OR l.deletado <> 'SIM');

UPDATE public.reproducao r
SET "loteNome" = l.nome,
    updated_at = COALESCE(r.updated_at, now())
FROM public.lotes l
WHERE r.id_lote IS NOT NULL
  AND l.id_lote = r.id_lote
  AND l.id_propriedade = r.id_propriedade
  AND (l.deletado IS NULL OR l.deletado <> 'SIM')
  AND NULLIF(r."loteNome", '') IS NULL
  AND NULLIF(l.nome, '') IS NOT NULL;

UPDATE public.reproducao r
SET id_lote = matriz."loteID",
    "loteNome" = matriz."loteNome",
    updated_at = COALESCE(r.updated_at, now())
FROM public.rebanho matriz
WHERE r.id_rebanho_matriz = matriz."idRebanho"
  AND r.id_propriedade = matriz."idPropriedade"
  AND NULLIF(r.id_lote, '') IS NULL
  AND NULLIF(r."loteNome", '') IS NULL
  AND NULLIF(matriz."loteID", '') IS NOT NULL
  AND NULLIF(matriz."loteNome", '') IS NOT NULL
  AND (r.deletado IS NULL OR r.deletado <> 'SIM')
  AND (r.ressinc IS NULL OR r.ressinc <> 'SIM');

CREATE OR REPLACE FUNCTION public.reproducao_filtros(
  p_id_propriedade text DEFAULT '',
  p_data_reproducao_de text DEFAULT '',
  p_data_reproducao_ate text DEFAULT '',
  p_data_previsao_parto_de text DEFAULT '',
  p_data_previsao_parto_ate text DEFAULT '',
  p_data_diagnostico_de text DEFAULT '',
  p_data_diagnostico_ate text DEFAULT '',
  p_tipo_reproducao text DEFAULT '',
  p_lote_nome text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_matriz text DEFAULT '',
  p_reprodutor text DEFAULT '',
  p_status_reproducao text DEFAULT '',
  p_categoria text DEFAULT '',
  p_limite integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_sort_column text DEFAULT '',
  p_sort_direction text DEFAULT 'desc'
)
RETURNS SETOF public.view_reproducao_detalhada
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
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
    CASE WHEN sort_direction = 'asc' AND sort_column = 'matriz' THEN COALESCE(v."nomeMatriz", '') END ASC NULLS LAST,
    CASE WHEN sort_direction <> 'asc' AND sort_column = 'matriz' THEN COALESCE(v."nomeMatriz", '') END DESC NULLS LAST,
    v.created_at DESC NULLS LAST,
    v.id DESC
  LIMIT NULLIF(p_limite, 0)
  OFFSET p_offset;
END;
$$;

GRANT EXECUTE ON FUNCTION public.reproducao_filtros(
  text, text, text, text, text, text, text, text, text, text, text, text, text,
  text, text, integer, integer, text, text
) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';
