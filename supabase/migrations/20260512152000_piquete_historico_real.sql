-- Historico real e granular para o modulo de piquetes.

CREATE OR REPLACE FUNCTION public.piquete_registrar_movimentacao(
  p_id_propriedade text,
  p_retiro_id uuid,
  p_piquete_id integer,
  p_tipo text,
  p_entidade_tipo text DEFAULT NULL,
  p_entidade_id text DEFAULT NULL,
  p_descricao text DEFAULT '',
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  IF p_id_propriedade IS NULL
     OR btrim(p_id_propriedade) = ''
     OR p_tipo IS NULL
     OR btrim(p_tipo) = '' THEN
    RAISE EXCEPTION 'Dados invalidos para registrar historico do piquete';
  END IF;

  INSERT INTO public.piquete_movimentacoes (
    id_propriedade,
    retiro_id,
    piquete_id,
    tipo,
    entidade_tipo,
    entidade_id,
    descricao,
    metadata
  )
  VALUES (
    p_id_propriedade,
    p_retiro_id,
    p_piquete_id,
    p_tipo,
    p_entidade_tipo,
    p_entidade_id,
    NULLIF(btrim(COALESCE(p_descricao, '')), ''),
    COALESCE(p_metadata, '{}'::jsonb)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_log_piquete_update()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_old_forrageiras text[];
  v_new_forrageiras text[];
  v_geom_changed boolean;
BEGIN
  IF TG_OP <> 'UPDATE' THEN
    RETURN NEW;
  END IF;

  IF COALESCE(OLD.nome, '') IS DISTINCT FROM COALESCE(NEW.nome, '') THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      NEW.retiro_id,
      NEW.id,
      'alterou_nome',
      'piquete',
      NEW.id::text,
      'Nome do piquete alterado',
      jsonb_build_object('anterior', OLD.nome, 'novo', NEW.nome)
    );
  END IF;

  IF COALESCE(OLD.area, 0) IS DISTINCT FROM COALESCE(NEW.area, 0)
     OR COALESCE(OLD.area_calculada_ha, 0) IS DISTINCT FROM COALESCE(NEW.area_calculada_ha, 0) THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      NEW.retiro_id,
      NEW.id,
      'alterou_area',
      'piquete',
      NEW.id::text,
      'Area do piquete alterada',
      jsonb_build_object(
        'area_anterior', OLD.area,
        'area_nova', NEW.area,
        'area_calculada_anterior', OLD.area_calculada_ha,
        'area_calculada_nova', NEW.area_calculada_ha
      )
    );
  END IF;

  v_old_forrageiras := COALESCE(OLD.forrageria, ARRAY[]::text[]);
  v_new_forrageiras := COALESCE(NEW.forrageria, ARRAY[]::text[]);
  IF v_old_forrageiras IS DISTINCT FROM v_new_forrageiras THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      NEW.retiro_id,
      NEW.id,
      'alterou_forrageiras',
      'piquete',
      NEW.id::text,
      'Forrageiras do piquete alteradas',
      jsonb_build_object('anterior', v_old_forrageiras, 'novo', v_new_forrageiras)
    );
  END IF;

  IF COALESCE(OLD.anotacoes, '') IS DISTINCT FROM COALESCE(NEW.anotacoes, '') THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      NEW.retiro_id,
      NEW.id,
      'alterou_anotacoes',
      'piquete',
      NEW.id::text,
      'Anotacoes do piquete alteradas',
      jsonb_build_object('anterior', OLD.anotacoes, 'novo', NEW.anotacoes)
    );
  END IF;

  v_geom_changed :=
    (OLD.geom IS NULL AND NEW.geom IS NOT NULL)
    OR (OLD.geom IS NOT NULL AND NEW.geom IS NULL)
    OR (
      OLD.geom IS NOT NULL
      AND NEW.geom IS NOT NULL
      AND NOT extensions.ST_Equals(OLD.geom, NEW.geom)
    );

  IF v_geom_changed THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      NEW.retiro_id,
      NEW.id,
      'alterou_demarcacao',
      'piquete',
      NEW.id::text,
      'Demarcacao do piquete alterada',
      jsonb_build_object(
        'area_calculada_anterior', OLD.area_calculada_ha,
        'area_calculada_nova', NEW.area_calculada_ha
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_log_animal_event()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_piquete public.piquete;
  v_piquete_id integer;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_piquete_id := NEW.piquete_id;
  ELSE
    v_piquete_id := OLD.piquete_id;
  END IF;

  SELECT *
  INTO v_piquete
  FROM public.piquete
  WHERE id = v_piquete_id
  LIMIT 1;

  IF TG_OP = 'INSERT' AND NEW.status = 'ativo' THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      v_piquete.retiro_id,
      NEW.piquete_id,
      'vinculou_animal',
      'animal',
      NEW.id_rebanho,
      'Animal vinculado ao piquete',
      jsonb_build_object('id_rebanho', NEW.id_rebanho)
    );
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND OLD.status = 'ativo'
     AND COALESCE(NEW.status, '') <> 'ativo' THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      v_piquete.retiro_id,
      NEW.piquete_id,
      'removeu_animal',
      'animal',
      NEW.id_rebanho,
      'Animal removido do piquete',
      jsonb_build_object(
        'id_rebanho', NEW.id_rebanho,
        'data_saida', NEW.data_saida
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_log_lote_event()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_piquete public.piquete;
  v_piquete_id integer;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_piquete_id := NEW.piquete_id;
  ELSE
    v_piquete_id := OLD.piquete_id;
  END IF;

  SELECT *
  INTO v_piquete
  FROM public.piquete
  WHERE id = v_piquete_id
  LIMIT 1;

  IF TG_OP = 'INSERT' AND NEW.status = 'ativo' THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      v_piquete.retiro_id,
      NEW.piquete_id,
      'vinculou_lote',
      'lote',
      NEW.id_lote,
      'Lote vinculado ao piquete',
      jsonb_build_object('id_lote', NEW.id_lote)
    );
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND OLD.status = 'ativo'
     AND COALESCE(NEW.status, '') <> 'ativo' THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      v_piquete.retiro_id,
      NEW.piquete_id,
      'removeu_lote',
      'lote',
      NEW.id_lote,
      'Lote removido do piquete',
      jsonb_build_object(
        'id_lote', NEW.id_lote,
        'data_saida', NEW.data_saida
      )
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS piquete_log_piquete_update_trigger ON public.piquete;
CREATE TRIGGER piquete_log_piquete_update_trigger
AFTER UPDATE ON public.piquete
FOR EACH ROW
EXECUTE FUNCTION public.piquete_log_piquete_update();

DROP TRIGGER IF EXISTS piquete_log_animal_event_trigger ON public.piquete_animais;
CREATE TRIGGER piquete_log_animal_event_trigger
AFTER INSERT OR UPDATE ON public.piquete_animais
FOR EACH ROW
EXECUTE FUNCTION public.piquete_log_animal_event();

DROP TRIGGER IF EXISTS piquete_log_lote_event_trigger ON public.piquete_lotes;
CREATE TRIGGER piquete_log_lote_event_trigger
AFTER INSERT OR UPDATE ON public.piquete_lotes
FOR EACH ROW
EXECUTE FUNCTION public.piquete_log_lote_event();

CREATE OR REPLACE FUNCTION public.buscar_piquete_historico(
  p_piquete_id text DEFAULT '',
  p_id_propriedade text DEFAULT '',
  p_limite integer DEFAULT 100,
  p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_piquete public.piquete;
  v_result jsonb;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT *
  INTO v_piquete
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
  LIMIT 1;

  IF v_piquete.id IS NULL THEN
    RAISE EXCEPTION 'Piquete nao encontrado';
  END IF;

  SELECT COALESCE(jsonb_agg(item ORDER BY (item->>'created_at') DESC), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', m.id::text,
      'tipo', m.tipo,
      'entidade_tipo', m.entidade_tipo,
      'entidade_id', m.entidade_id,
      'descricao', COALESCE(m.descricao, ''),
      'metadata', COALESCE(m.metadata, '{}'::jsonb),
      'created_at', m.created_at
    ) AS item
    FROM public.piquete_movimentacoes m
    WHERE m.id_propriedade = p_id_propriedade
      AND m.piquete_id = v_piquete.id
    ORDER BY m.created_at DESC
    LIMIT GREATEST(COALESCE(p_limite, 100), 1)
    OFFSET GREATEST(COALESCE(p_offset, 0), 0)
  ) s;

  RETURN v_result;
END;
$$;

REVOKE ALL ON FUNCTION public.piquete_registrar_movimentacao(text, uuid, integer, text, text, text, text, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.piquete_log_piquete_update() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.piquete_log_animal_event() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.piquete_log_lote_event() FROM PUBLIC;
REVOKE ALL ON FUNCTION public.buscar_piquete_historico(text, text, integer, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.buscar_piquete_historico(text, text, integer, integer) TO authenticated;
