-- 1) Reverte a contagem para o comportamento original: animais com lote vinculado
--    e status 'Na propriedade' sao contabilizados mesmo que o lote esteja inativo
--    (lote inativo sem venda continua com animais na propriedade).
--
-- 2) Corrige a causa real do aumento "misterioso" da contagem ao inativar um lote.
--    O trigger e a funcao de salvamento sobrescreviam o status de TODOS os animais
--    do lote com 'Na propriedade' sempre que o lote nao estivesse vendido -- inclusive
--    ao apenas renomear ou salvar um lote ativo. Isso "ressuscitava" animais
--    'Vendido' e 'Morto', inflando a contagem e apagando dataVenda/valorVenda.
--
--    Agora o status do animal so e alterado nas transicoes de venda do lote:
--      - lote passa a vendido      -> animais viram 'Vendido' (exceto os 'Morto')
--      - lote deixa de ser vendido -> apenas os 'Vendido' voltam a 'Na propriedade'
--    Em qualquer outro caso o status individual do animal e preservado.

CREATE OR REPLACE FUNCTION public.count_rebanhos_com_lote(p_id_propriedade text)
RETURNS bigint
LANGUAGE sql
STABLE
SET search_path = public
AS $function$
  SELECT COUNT(*)
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r."loteID" IS NOT NULL
    AND btrim(r."loteID") <> ''
    AND lower(btrim(r."loteID")) <> 'null'
    AND r.deletado = 'NAO'
    AND r.status = 'Na propriedade';
$function$;

CREATE OR REPLACE FUNCTION public.sincronizar_animais_por_status_lote()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_vendido boolean;
  v_era_vendido boolean;
BEGIN
  -- salvar_lote_com_composicao ja sincroniza os animais da composicao final.
  IF COALESCE(current_setting('app.lote_sync_skip', true), 'off') = 'on' THEN
    RETURN NEW;
  END IF;

  IF COALESCE(NEW.deletado, 'NAO') <> 'NAO'
     OR btrim(COALESCE(NEW.id_propriedade, '')) = ''
     OR btrim(COALESCE(NEW.id_lote, '')) = '' THEN
    RETURN NEW;
  END IF;

  v_vendido := NEW.ativo = 'Inativo' AND NEW.motivo = 'Lote vendido';
  v_era_vendido := TG_OP = 'UPDATE'
                   AND OLD.ativo = 'Inativo'
                   AND OLD.motivo = 'Lote vendido';

  UPDATE public.rebanho r
  SET
    "loteNome" = NEW.nome,
    updated_at = now()
  WHERE r."idPropriedade" = NEW.id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND r."loteID" = NEW.id_lote
    AND r."loteNome" IS DISTINCT FROM NEW.nome;

  IF v_vendido AND NOT v_era_vendido THEN
    UPDATE public.rebanho r
    SET
      status = 'Vendido',
      "dataVenda" = NEW.data_motivo,
      "valorVenda" = NEW."valorVenda",
      updated_at = now()
    WHERE r."idPropriedade" = NEW.id_propriedade
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND r."loteID" = NEW.id_lote
      AND COALESCE(r.status, '') <> 'Morto';
  ELSIF v_vendido AND v_era_vendido THEN
    UPDATE public.rebanho r
    SET
      "dataVenda" = NEW.data_motivo,
      "valorVenda" = NEW."valorVenda",
      updated_at = now()
    WHERE r."idPropriedade" = NEW.id_propriedade
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND r."loteID" = NEW.id_lote
      AND r.status = 'Vendido'
      AND (r."dataVenda" IS DISTINCT FROM NEW.data_motivo
           OR r."valorVenda" IS DISTINCT FROM NEW."valorVenda");
  ELSIF v_era_vendido THEN
    UPDATE public.rebanho r
    SET
      status = 'Na propriedade',
      "dataVenda" = NULL,
      "valorVenda" = NULL,
      updated_at = now()
    WHERE r."idPropriedade" = NEW.id_propriedade
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND r."loteID" = NEW.id_lote
      AND r.status = 'Vendido';
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.salvar_lote_com_composicao(
  p_id_propriedade text DEFAULT '',
  p_id_lote text DEFAULT '',
  p_nome text DEFAULT NULL,
  p_anotacoes text DEFAULT NULL,
  p_ativo text DEFAULT 'Ativo',
  p_motivo text DEFAULT NULL,
  p_data_motivo timestamptz DEFAULT NULL,
  p_valor_venda numeric DEFAULT NULL,
  p_animais_ids text DEFAULT '[]',
  p_composicao_esperada text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_lote public.lotes%ROWTYPE;
  v_animais_json jsonb := '[]'::jsonb;
  v_esperada_json jsonb := '[]'::jsonb;
  v_ids text[] := ARRAY[]::text[];
  v_ids_esperados text[] := ARRAY[]::text[];
  v_ids_atuais text[] := ARRAY[]::text[];
  v_ativo text := CASE
    WHEN lower(btrim(COALESCE(p_ativo, 'Ativo'))) IN ('ativo', 'true', '1', 'sim') THEN 'Ativo'
    ELSE 'Inativo'
  END;
  v_motivo text := NULLIF(btrim(COALESCE(p_motivo, '')), '');
  v_vendido boolean;
  v_era_vendido boolean := false;
  v_existia boolean := false;
  v_validos integer;
  v_atualizados integer;
  v_removidos integer;
BEGIN
  IF NULLIF(btrim(COALESCE(p_id_propriedade, '')), '') IS NULL
     OR NULLIF(btrim(COALESCE(p_id_lote, '')), '') IS NULL THEN
    RAISE EXCEPTION 'Dados obrigatorios ausentes para salvar lote';
  END IF;

  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  BEGIN
    v_animais_json := COALESCE(NULLIF(btrim(COALESCE(p_animais_ids, '')), '')::jsonb, '[]'::jsonb);
    v_esperada_json := COALESCE(NULLIF(btrim(COALESCE(p_composicao_esperada, '')), '')::jsonb, '[]'::jsonb);
  EXCEPTION WHEN others THEN
    RAISE EXCEPTION 'Composicao de animais invalida';
  END;

  IF jsonb_typeof(v_animais_json) <> 'array'
     OR jsonb_typeof(v_esperada_json) <> 'array' THEN
    RAISE EXCEPTION 'Composicao de animais deve ser um array JSON';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT btrim(value) ORDER BY btrim(value)) FILTER (
    WHERE btrim(value) <> '' AND lower(btrim(value)) <> 'null'
  ), ARRAY[]::text[])
  INTO v_ids
  FROM jsonb_array_elements_text(v_animais_json) AS item(value);

  SELECT COALESCE(array_agg(DISTINCT btrim(value) ORDER BY btrim(value)) FILTER (
    WHERE btrim(value) <> '' AND lower(btrim(value)) <> 'null'
  ), ARRAY[]::text[])
  INTO v_ids_esperados
  FROM jsonb_array_elements_text(v_esperada_json) AS item(value);

  SELECT l.*
  INTO v_lote
  FROM public.lotes l
  WHERE l.id_propriedade = p_id_propriedade
    AND l.id_lote = btrim(p_id_lote)
    AND COALESCE(l.deletado, 'NAO') = 'NAO'
  FOR UPDATE;

  IF FOUND THEN
    v_existia := true;
    v_era_vendido := v_lote.ativo = 'Inativo' AND v_lote.motivo = 'Lote vendido';

    IF p_composicao_esperada IS NOT NULL THEN
      SELECT COALESCE(array_agg(r."idRebanho" ORDER BY r."idRebanho"), ARRAY[]::text[])
      INTO v_ids_atuais
      FROM public.rebanho r
      WHERE r."idPropriedade" = p_id_propriedade
        AND r."loteID" = v_lote.id_lote
        AND COALESCE(r.deletado, 'NAO') = 'NAO';

      IF v_ids_atuais <> v_ids_esperados THEN
        RAISE EXCEPTION 'Lote alterado por outro usuario; recarregue a composicao';
      END IF;
    END IF;
  ELSE
    INSERT INTO public.lotes (
      id_propriedade,
      nome,
      anotacoes,
      ativo,
      id_lote,
      deletado,
      motivo,
      data_motivo,
      "valorVenda"
    ) VALUES (
      p_id_propriedade,
      NULLIF(btrim(COALESCE(p_nome, '')), ''),
      p_anotacoes,
      v_ativo,
      btrim(p_id_lote),
      'NAO',
      CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE v_motivo END,
      CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_data_motivo END,
      CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_valor_venda END
    )
    RETURNING * INTO v_lote;
  END IF;

  PERFORM 1
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND (r."loteID" = v_lote.id_lote OR r."idRebanho" = ANY(v_ids))
  FOR UPDATE;

  IF cardinality(v_ids) > 0 THEN
    SELECT count(DISTINCT r."idRebanho")
    INTO v_validos
    FROM public.rebanho r
    WHERE r."idPropriedade" = p_id_propriedade
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND r."idRebanho" = ANY(v_ids);

    IF v_validos <> cardinality(v_ids) THEN
      RAISE EXCEPTION 'Um ou mais animais nao pertencem a propriedade';
    END IF;
  END IF;

  v_vendido := v_ativo = 'Inativo' AND v_motivo = 'Lote vendido';

  PERFORM set_config('app.lote_sync_skip', 'on', true);

  UPDATE public.lotes
  SET
    nome = COALESCE(NULLIF(btrim(COALESCE(p_nome, '')), ''), nome),
    anotacoes = COALESCE(p_anotacoes, anotacoes),
    ativo = v_ativo,
    motivo = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE v_motivo END,
    data_motivo = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_data_motivo END,
    "valorVenda" = CASE WHEN v_ativo = 'Ativo' THEN NULL ELSE p_valor_venda END,
    updated_at = now()
  WHERE id = v_lote.id
  RETURNING * INTO v_lote;

  -- Animais retirados do lote: apenas desvincula. O status individual e preservado,
  -- exceto quando a venda do lote precisa ser desfeita para o animal retirado.
  UPDATE public.rebanho r
  SET
    "loteID" = NULL,
    "loteNome" = NULL,
    status = CASE
      WHEN v_era_vendido AND r.status = 'Vendido' THEN 'Na propriedade'
      ELSE r.status
    END,
    "dataVenda" = CASE
      WHEN v_era_vendido AND r.status = 'Vendido' THEN NULL
      ELSE r."dataVenda"
    END,
    "valorVenda" = CASE
      WHEN v_era_vendido AND r.status = 'Vendido' THEN NULL
      ELSE r."valorVenda"
    END,
    updated_at = now()
  WHERE r."idPropriedade" = p_id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND r."loteID" = v_lote.id_lote
    AND NOT (r."idRebanho" = ANY(v_ids));
  GET DIAGNOSTICS v_removidos = ROW_COUNT;

  -- Composicao final: vincula ao lote sem sobrescrever o status individual.
  UPDATE public.rebanho r
  SET
    "loteID" = v_lote.id_lote,
    "loteNome" = v_lote.nome,
    status = CASE
      WHEN v_vendido AND COALESCE(r.status, '') <> 'Morto' THEN 'Vendido'
      WHEN NOT v_vendido AND v_era_vendido AND r.status = 'Vendido' THEN 'Na propriedade'
      ELSE r.status
    END,
    "dataVenda" = CASE
      WHEN v_vendido AND COALESCE(r.status, '') <> 'Morto' THEN v_lote.data_motivo
      WHEN NOT v_vendido AND v_era_vendido AND r.status = 'Vendido' THEN NULL
      ELSE r."dataVenda"
    END,
    "valorVenda" = CASE
      WHEN v_vendido AND COALESCE(r.status, '') <> 'Morto' THEN v_lote."valorVenda"
      WHEN NOT v_vendido AND v_era_vendido AND r.status = 'Vendido' THEN NULL
      ELSE r."valorVenda"
    END,
    "dataEntradaLote" = CASE
      WHEN r."loteID" IS DISTINCT FROM v_lote.id_lote THEN CURRENT_DATE
      ELSE r."dataEntradaLote"
    END,
    updated_at = now()
  WHERE r."idPropriedade" = p_id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND r."idRebanho" = ANY(v_ids);
  GET DIAGNOSTICS v_atualizados = ROW_COUNT;

  PERFORM set_config('app.lote_sync_skip', 'off', true);

  IF v_atualizados <> cardinality(v_ids) THEN
    RAISE EXCEPTION 'Quantidade de animais vinculados diferente da solicitada';
  END IF;

  RETURN jsonb_build_object(
    'id_lote', v_lote.id_lote,
    'animais_solicitados', cardinality(v_ids),
    'animais_vinculados', v_atualizados,
    'animais_removidos', v_removidos,
    'criado', NOT v_existia
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.salvar_lote_com_composicao(text, text, text, text, text, text, timestamptz, numeric, text, text) TO authenticated;

NOTIFY pgrst, 'reload schema';
