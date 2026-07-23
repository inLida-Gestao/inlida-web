-- Torna a composicao de um lote autoritativa e atomica.
-- A assinatura permanece compativel com os clientes existentes.

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
  v_lote_anterior public.lotes%ROWTYPE;
  v_id_animais jsonb := '[]'::jsonb;
  v_ids text[] := ARRAY[]::text[];
  v_ids_json text := '[]';
  v_ids_validos integer := 0;
  v_animais_vinculados integer := 0;
  v_animais_removidos integer := 0;
  v_animais_solicitados integer := 0;
  v_ids_restantes jsonb := '[]'::jsonb;
  v_ativo text := CASE
    WHEN lower(btrim(COALESCE(p_ativo, 'Ativo'))) IN ('ativo', 'true', '1', 'sim') THEN 'Ativo'
    ELSE 'Inativo'
  END;
  v_motivo text := NULLIF(btrim(COALESCE(p_motivo, '')), '');
  v_lote_vendido boolean;
BEGIN
  IF btrim(COALESCE(p_id_propriedade, '')) = ''
     OR btrim(COALESCE(p_id_lote, '')) = '' THEN
    RAISE EXCEPTION 'Dados obrigatorios ausentes para salvar lote';
  END IF;

  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  IF NULLIF(btrim(COALESCE(p_id_animais, '')), '') IS NOT NULL THEN
    BEGIN
      v_id_animais := p_id_animais::jsonb;
    EXCEPTION WHEN others THEN
      RAISE EXCEPTION 'Lista de animais invalida';
    END;
  END IF;

  IF jsonb_typeof(v_id_animais) <> 'array' THEN
    RAISE EXCEPTION 'Lista de animais deve ser um array JSON';
  END IF;

  SELECT COALESCE(
    array_agg(DISTINCT btrim(item.value) ORDER BY btrim(item.value))
      FILTER (
        WHERE btrim(item.value) <> ''
          AND lower(btrim(item.value)) <> 'null'
      ),
    ARRAY[]::text[]
  )
  INTO v_ids
  FROM jsonb_array_elements_text(v_id_animais) AS item(value);

  v_animais_solicitados := cardinality(v_ids);
  v_ids_json := to_jsonb(v_ids)::text;

  SELECT l.*
  INTO v_lote
  FROM public.lotes l
  WHERE l.id_propriedade = p_id_propriedade
    AND l.id_lote = p_id_lote
    AND COALESCE(l.deletado, 'NAO') = 'NAO'
  LIMIT 1;

  IF v_lote.id IS NULL THEN
    RAISE EXCEPTION 'Lote nao encontrado';
  END IF;

  IF v_animais_solicitados > 0 THEN
    SELECT count(DISTINCT r."idRebanho")
    INTO v_ids_validos
    FROM public.rebanho r
    WHERE r."idPropriedade" = p_id_propriedade
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND r."idRebanho" = ANY(v_ids);

    IF v_ids_validos <> v_animais_solicitados THEN
      RAISE EXCEPTION 'Um ou mais animais nao pertencem a propriedade';
    END IF;
  END IF;

  v_lote_vendido := v_ativo = 'Inativo' AND v_motivo = 'Lote vendido';

  -- Desvincula primeiro os animais transferidos, para que o trigger dos lotes
  -- anteriores nao os devolva ao lote antigo.
  UPDATE public.rebanho r
  SET
    "loteID" = NULL,
    "loteNome" = NULL,
    status = 'Na propriedade',
    "dataVenda" = NULL,
    "valorVenda" = NULL,
    updated_at = now()
  WHERE r."idPropriedade" = p_id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND r."idRebanho" = ANY(v_ids);

  -- Remove os IDs transferidos dos lotes anteriores, inclusive do campo
  -- legado lotes.id_animais.
  FOR v_lote_anterior IN
    SELECT l.*
    FROM public.lotes l
    WHERE l.id_propriedade = p_id_propriedade
      AND COALESCE(l.deletado, 'NAO') = 'NAO'
      AND l.id_lote <> p_id_lote
      AND NULLIF(btrim(COALESCE(l.id_animais, '')), '') IS NOT NULL
  LOOP
    BEGIN
      IF jsonb_typeof(v_lote_anterior.id_animais::jsonb) <> 'array' THEN
        CONTINUE;
      END IF;

      SELECT COALESCE(
        jsonb_agg(item.value ORDER BY item.ord),
        '[]'::jsonb
      )
      INTO v_ids_restantes
      FROM jsonb_array_elements_text(v_lote_anterior.id_animais::jsonb)
        WITH ORDINALITY AS item(value, ord)
      WHERE btrim(item.value) <> ALL(v_ids);
    EXCEPTION WHEN others THEN
      CONTINUE;
    END;

    IF v_ids_restantes::text IS DISTINCT FROM btrim(v_lote_anterior.id_animais) THEN
      UPDATE public.lotes
      SET
        id_animais = v_ids_restantes::text,
        updated_at = now()
      WHERE id = v_lote_anterior.id;
    END IF;
  END LOOP;

  -- Atualiza a composicao e os dados do lote de destino. O trigger existente
  -- sincroniza os animais selecionados antes da limpeza final abaixo.
  UPDATE public.lotes
  SET
    id_animais = v_ids_json,
    nome = COALESCE(NULLIF(p_nome, ''), nome),
    anotacoes = COALESCE(p_anotacoes, anotacoes),
    ativo = v_ativo,
    motivo = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE v_motivo END,
    data_motivo = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_data_motivo END,
    "valorVenda" = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_valor_venda END,
    updated_at = now()
  WHERE id = v_lote.id
  RETURNING * INTO v_lote;

  -- A composicao enviada pelo usuario e a fonte da verdade: animais
  -- removidos da tela nao podem continuar vinculados ao destino.
  UPDATE public.rebanho r
  SET
    "loteID" = NULL,
    "loteNome" = NULL,
    status = 'Na propriedade',
    "dataVenda" = NULL,
    "valorVenda" = NULL,
    updated_at = now()
  WHERE r."idPropriedade" = p_id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND r."loteID" = v_lote.id_lote
    AND (v_animais_solicitados = 0 OR NOT (r."idRebanho" = ANY(v_ids)));

  GET DIAGNOSTICS v_animais_removidos = ROW_COUNT;

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
    AND r."idRebanho" = ANY(v_ids);

  GET DIAGNOSTICS v_animais_vinculados = ROW_COUNT;

  IF v_animais_vinculados <> v_animais_solicitados THEN
    RAISE EXCEPTION 'Quantidade de animais vinculados diferente da solicitada';
  END IF;

  RETURN jsonb_build_object(
    'id_lote', v_lote.id_lote,
    'ativo', v_lote.ativo,
    'motivo', v_lote.motivo,
    'animais_solicitados', v_animais_solicitados,
    'animais_vinculados', v_animais_vinculados,
    'animais_removidos', v_animais_removidos
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