-- Adiciona filtro multi-select de diagnóstico/status reprodutivo.
-- O app envia p_status_reproducao como texto delimitado por vírgula.

DROP FUNCTION IF EXISTS public.reproducao_filtros(
  text, text, text, text, text, text, text, text, text, text, text, text, text,
  integer, integer, text, text
);

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
BEGIN
  RETURN QUERY
  SELECT v.*
  FROM public.view_reproducao_detalhada v
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

DROP FUNCTION IF EXISTS public.contar_reproducao_filtros(
  text, text, text, text, text, text, text, text, text, text, text, text, text
);

CREATE OR REPLACE FUNCTION public.contar_reproducao_filtros(
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
  p_status_reproducao text DEFAULT ''
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  total bigint;
BEGIN
  SELECT COUNT(*) INTO total
  FROM public.view_reproducao_detalhada v
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
      OR (v."numReprodutor" IS NOT NULL AND v."numReprodutor" ILIKE '%' || p_pesquisa || '%'));
  RETURN total;
END;
$$;

GRANT EXECUTE ON FUNCTION public.reproducao_filtros(
  text, text, text, text, text, text, text, text, text, text, text, text, text,
  text, integer, integer, text, text
) TO anon, authenticated;

GRANT EXECUTE ON FUNCTION public.contar_reproducao_filtros(
  text, text, text, text, text, text, text, text, text, text, text, text, text,
  text
) TO anon, authenticated;
