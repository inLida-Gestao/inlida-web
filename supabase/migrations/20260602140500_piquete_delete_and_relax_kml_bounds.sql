-- Allow managing/deleting limite/retiro and accept KML polygons that
-- overflow the property boundary while preserving hierarchy/overlap checks.

CREATE OR REPLACE FUNCTION public.excluir_limite_propriedade(
  p_limite_id text DEFAULT '',
  p_id_propriedade text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_limite public.limites_propriedade;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT *
  INTO v_limite
  FROM public.limites_propriedade l
  WHERE l.id_propriedade = p_id_propriedade
    AND l.deleted_at IS NULL
    AND COALESCE(l.status, 'ativo') = 'ativo'
    AND (
      NULLIF(btrim(COALESCE(p_limite_id, '')), '') IS NULL
      OR l.id::text = p_limite_id
      OR l.id_limite = p_limite_id
    )
  ORDER BY l.created_at DESC
  LIMIT 1;

  IF v_limite.id IS NULL THEN
    RAISE EXCEPTION 'Limite da propriedade nao encontrado';
  END IF;

  UPDATE public.limites_propriedade
  SET status = 'excluido',
      deleted_at = now(),
      updated_at = now()
  WHERE public.limites_propriedade.id = v_limite.id;

  INSERT INTO public.piquete_movimentacoes (
    id_propriedade,
    tipo,
    entidade_tipo,
    entidade_id,
    descricao
  )
  VALUES (
    p_id_propriedade,
    'removeu_limite',
    'limite',
    v_limite.id::text,
    'Limite da propriedade excluido'
  );

  RETURN jsonb_build_object('ok', true, 'id', v_limite.id::text);
END;
$$;

CREATE OR REPLACE FUNCTION public.excluir_retiro(
  p_retiro_id text DEFAULT '',
  p_id_propriedade text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_retiro public.retiros;
  v_piquetes_movidos integer := 0;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT *
  INTO v_retiro
  FROM public.retiros r
  WHERE r.id_propriedade = p_id_propriedade
    AND r.deleted_at IS NULL
    AND (r.id::text = p_retiro_id OR r.id_retiro = p_retiro_id)
  LIMIT 1;

  IF v_retiro.id IS NULL THEN
    RAISE EXCEPTION 'Retiro nao encontrado';
  END IF;

  UPDATE public.retiros
  SET status = 'excluido',
      deleted_at = now(),
      updated_at = now()
  WHERE public.retiros.id = v_retiro.id;

  UPDATE public.piquete
  SET retiro_id = NULL,
      updated_at = now()
  WHERE id_propriedade = p_id_propriedade
    AND retiro_id = v_retiro.id
    AND deleted_at IS NULL
    AND COALESCE(status, 'ativo') = 'ativo';

  GET DIAGNOSTICS v_piquetes_movidos = ROW_COUNT;

  INSERT INTO public.piquete_movimentacoes (
    id_propriedade,
    retiro_id,
    tipo,
    entidade_tipo,
    entidade_id,
    descricao,
    metadata
  )
  VALUES (
    p_id_propriedade,
    v_retiro.id,
    'removeu_retiro',
    'retiro',
    v_retiro.id::text,
    'Retiro excluido',
    jsonb_build_object('piquetes_movidos_sem_retiro', v_piquetes_movidos)
  );

  RETURN jsonb_build_object(
    'ok', true,
    'id', v_retiro.id::text,
    'piquetes_movidos_sem_retiro', v_piquetes_movidos
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.validar_retiro_no_limite_trigger()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, extensions
AS $$
DECLARE
  v_limite public.limites_propriedade;
  v_conflito text;
BEGIN
  IF NEW.deleted_at IS NOT NULL OR COALESCE(NEW.status, 'ativo') <> 'ativo' THEN
    RETURN NEW;
  END IF;

  SELECT *
  INTO v_limite
  FROM public.limites_propriedade l
  WHERE l.id_propriedade = NEW.id_propriedade
    AND l.deleted_at IS NULL
    AND COALESCE(l.status, 'ativo') = 'ativo'
  ORDER BY l.created_at DESC
  LIMIT 1
  FOR UPDATE;

  IF v_limite.id IS NULL THEN
    RAISE EXCEPTION 'Cadastre o limite da propriedade antes de criar ou editar retiros';
  END IF;

  IF NOT extensions.ST_Intersects(NEW.geom, v_limite.geom) THEN
    RAISE EXCEPTION 'A area do retiro precisa intersectar o limite da propriedade';
  END IF;

  SELECT r.nome
  INTO v_conflito
  FROM public.retiros r
  WHERE r.id_propriedade = NEW.id_propriedade
    AND r.id <> NEW.id
    AND r.deleted_at IS NULL
    AND COALESCE(r.status, 'ativo') = 'ativo'
    AND extensions.ST_Intersects(r.geom, NEW.geom)
    AND NOT extensions.ST_Touches(r.geom, NEW.geom)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'A area do retiro sobrepoe o retiro "%"', v_conflito;
  END IF;

  SELECT p.nome
  INTO v_conflito
  FROM public.piquete p
  WHERE p.id_propriedade = NEW.id_propriedade
    AND p.retiro_id IS NULL
    AND p.geom IS NOT NULL
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND extensions.ST_Intersects(p.geom, NEW.geom)
    AND NOT extensions.ST_Touches(p.geom, NEW.geom)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'A area do retiro sobrepoe o piquete sem retiro "%"', v_conflito;
  END IF;

  SELECT p.nome
  INTO v_conflito
  FROM public.piquete p
  WHERE p.retiro_id = NEW.id
    AND p.id_propriedade = NEW.id_propriedade
    AND p.geom IS NOT NULL
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND NOT extensions.ST_CoveredBy(p.geom, NEW.geom)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'O piquete "%" precisa permanecer dentro do retiro', v_conflito;
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.validar_piquete_no_limite_trigger()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, extensions
AS $$
DECLARE
  v_limite public.limites_propriedade;
  v_retiro public.retiros;
  v_conflito text;
BEGIN
  IF NEW.geom IS NULL
     OR NEW.deleted_at IS NOT NULL
     OR COALESCE(NEW.status, 'ativo') <> 'ativo' THEN
    RETURN NEW;
  END IF;

  SELECT *
  INTO v_limite
  FROM public.limites_propriedade l
  WHERE l.id_propriedade = NEW.id_propriedade
    AND l.deleted_at IS NULL
    AND COALESCE(l.status, 'ativo') = 'ativo'
  ORDER BY l.created_at DESC
  LIMIT 1
  FOR UPDATE;

  IF v_limite.id IS NULL THEN
    RAISE EXCEPTION 'Cadastre o limite da propriedade antes de criar ou editar piquetes';
  END IF;

  IF NOT extensions.ST_Intersects(NEW.geom, v_limite.geom) THEN
    RAISE EXCEPTION 'A area do piquete precisa intersectar o limite da propriedade';
  END IF;

  IF NEW.retiro_id IS NOT NULL THEN
    SELECT *
    INTO v_retiro
    FROM public.retiros r
    WHERE r.id = NEW.retiro_id
      AND r.id_propriedade = NEW.id_propriedade
      AND r.deleted_at IS NULL
      AND COALESCE(r.status, 'ativo') = 'ativo'
    LIMIT 1;

    IF v_retiro.id IS NULL THEN
      RAISE EXCEPTION 'Retiro nao encontrado';
    END IF;

    IF NOT extensions.ST_CoveredBy(NEW.geom, v_retiro.geom) THEN
      RAISE EXCEPTION 'A area do piquete precisa estar dentro do retiro';
    END IF;

    RETURN NEW;
  END IF;

  SELECT r.nome
  INTO v_conflito
  FROM public.retiros r
  WHERE r.id_propriedade = NEW.id_propriedade
    AND r.deleted_at IS NULL
    AND COALESCE(r.status, 'ativo') = 'ativo'
    AND extensions.ST_Intersects(r.geom, NEW.geom)
    AND NOT extensions.ST_Touches(r.geom, NEW.geom)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'O piquete sem retiro sobrepoe o retiro "%"', v_conflito;
  END IF;

  SELECT p.nome
  INTO v_conflito
  FROM public.piquete p
  WHERE p.id_propriedade = NEW.id_propriedade
    AND p.id <> NEW.id
    AND p.retiro_id IS NULL
    AND p.geom IS NOT NULL
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND extensions.ST_Intersects(p.geom, NEW.geom)
    AND NOT extensions.ST_Touches(p.geom, NEW.geom)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'O piquete sem retiro sobrepoe o piquete "%"', v_conflito;
  END IF;

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.excluir_limite_propriedade(text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.excluir_retiro(text, text) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.excluir_limite_propriedade(text, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.excluir_retiro(text, text) TO authenticated, service_role;
