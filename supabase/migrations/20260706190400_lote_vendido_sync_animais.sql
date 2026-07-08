-- Sincroniza em lote o status dos animais ao vender/reativar um lote.
-- Evita falhas parciais do frontend em lotes grandes.

CREATE OR REPLACE FUNCTION public.salvar_lote_status_e_sincronizar_animais(
  p_id_propriedade text DEFAULT '',
  p_id_lote text DEFAULT '',
  p_nome text DEFAULT NULL,
  p_anotacoes text DEFAULT NULL,
  p_ativo text DEFAULT 'Ativo',
  p_motivo text DEFAULT NULL,
  p_data_motivo timestamp with time zone DEFAULT NULL,
  p_valor_venda numeric DEFAULT NULL,
  p_id_animais text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_lote public.lotes%ROWTYPE;
  v_id_animais jsonb := CASE
    WHEN NULLIF(btrim(COALESCE(p_id_animais, '')), '') IS NULL THEN '[]'::jsonb
    ELSE p_id_animais::jsonb
  END;
  v_ativo text := CASE
    WHEN lower(btrim(COALESCE(p_ativo, 'Ativo'))) IN ('ativo', 'true', '1', 'sim') THEN 'Ativo'
    ELSE 'Inativo'
  END;
  v_motivo text := NULLIF(btrim(COALESCE(p_motivo, '')), '');
  v_lote_vendido boolean;
  v_animais_atualizados integer := 0;
BEGIN
  IF btrim(COALESCE(p_id_propriedade, '')) = ''
     OR btrim(COALESCE(p_id_lote, '')) = '' THEN
    RAISE EXCEPTION 'Dados obrigatorios ausentes para salvar lote';
  END IF;

  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT *
  INTO v_lote
  FROM public.lotes l
  WHERE l.id_propriedade = p_id_propriedade
    AND l.id_lote = p_id_lote
    AND COALESCE(l.deletado, 'NAO') = 'NAO'
  LIMIT 1;

  IF v_lote.id IS NULL THEN
    RAISE EXCEPTION 'Lote nao encontrado';
  END IF;

  v_lote_vendido := v_ativo = 'Inativo' AND v_motivo = 'Lote vendido';

  UPDATE public.lotes
  SET
    id_animais = p_id_animais,
    nome = COALESCE(NULLIF(p_nome, ''), nome),
    anotacoes = COALESCE(p_anotacoes, anotacoes),
    ativo = v_ativo,
    motivo = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE v_motivo END,
    data_motivo = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_data_motivo END,
    "valorVenda" = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_valor_venda END,
    updated_at = now()
  WHERE id = v_lote.id
  RETURNING *
  INTO v_lote;

  UPDATE public.rebanho r
  SET
    "loteID" = v_lote.id_lote,
    "loteNome" = COALESCE(NULLIF(v_lote.nome, ''), r."loteNome"),
    status = CASE WHEN v_lote_vendido THEN 'Vendido' ELSE 'Na propriedade' END,
    "dataVenda" = CASE WHEN v_lote_vendido THEN p_data_motivo ELSE NULL END,
    "valorVenda" = CASE WHEN v_lote_vendido THEN p_valor_venda ELSE NULL END,
    updated_at = now()
  WHERE r."idPropriedade" = p_id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND (
      r."loteID" = v_lote.id_lote
      OR r."idRebanho" IN (
        SELECT jsonb_array_elements_text(v_id_animais)
      )
    );

  GET DIAGNOSTICS v_animais_atualizados = ROW_COUNT;

  RETURN jsonb_build_object(
    'id_lote', v_lote.id_lote,
    'ativo', v_lote.ativo,
    'motivo', v_lote.motivo,
    'animais_atualizados', v_animais_atualizados
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.salvar_lote_status_e_sincronizar_animais(
  text,
  text,
  text,
  text,
  text,
  text,
  timestamp with time zone,
  numeric,
  text
) TO authenticated;

NOTIFY pgrst, 'reload schema';
