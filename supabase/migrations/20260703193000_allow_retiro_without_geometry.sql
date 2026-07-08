-- Allow creating/updating retiros without drawing a polygon.

ALTER TABLE public.retiros
  ALTER COLUMN geom DROP NOT NULL;

CREATE OR REPLACE FUNCTION public.salvar_retiro(
  p_retiro_id text DEFAULT '',
  p_id_propriedade text DEFAULT '',
  p_nome text DEFAULT '',
  p_area_informada_ha numeric DEFAULT NULL,
  p_anotacoes text DEFAULT '',
  p_geojson jsonb DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_geom extensions.geometry;
  v_retiro_id uuid;
  v_retiro public.retiros;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  IF p_nome IS NULL OR btrim(p_nome) = '' THEN
    RAISE EXCEPTION 'Nome do retiro e obrigatorio';
  END IF;

  v_geom := CASE
    WHEN p_geojson IS NULL THEN NULL
    ELSE public.piquete_geojson_to_polygon(p_geojson)
  END;

  IF NULLIF(btrim(COALESCE(p_retiro_id, '')), '') IS NOT NULL THEN
    SELECT r.id
    INTO v_retiro_id
    FROM public.retiros r
    WHERE r.id_propriedade = p_id_propriedade
      AND r.deleted_at IS NULL
      AND (r.id::text = p_retiro_id OR r.id_retiro = p_retiro_id)
    LIMIT 1;
  END IF;

  IF v_retiro_id IS NULL THEN
    INSERT INTO public.retiros (
      id_propriedade,
      nome,
      area_informada_ha,
      area_calculada_ha,
      anotacoes,
      geom,
      centro,
      bounds,
      status,
      updated_at
    )
    VALUES (
      p_id_propriedade,
      btrim(p_nome),
      p_area_informada_ha,
      public.piquete_area_ha(v_geom),
      NULLIF(btrim(COALESCE(p_anotacoes, '')), ''),
      v_geom,
      CASE WHEN v_geom IS NULL THEN NULL ELSE extensions.ST_PointOnSurface(v_geom) END,
      public.piquete_bounds_json(v_geom),
      'ativo',
      now()
    )
    RETURNING id INTO v_retiro_id;

    INSERT INTO public.piquete_movimentacoes (
      id_propriedade,
      retiro_id,
      tipo,
      entidade_tipo,
      entidade_id,
      descricao
    )
    VALUES (
      p_id_propriedade,
      v_retiro_id,
      'criou_retiro',
      'retiro',
      v_retiro_id::text,
      'Retiro criado'
    );
  ELSE
    UPDATE public.retiros
    SET nome = btrim(p_nome),
        area_informada_ha = p_area_informada_ha,
        area_calculada_ha = public.piquete_area_ha(v_geom),
        anotacoes = NULLIF(btrim(COALESCE(p_anotacoes, '')), ''),
        geom = v_geom,
        centro = CASE WHEN v_geom IS NULL THEN NULL ELSE extensions.ST_PointOnSurface(v_geom) END,
        bounds = public.piquete_bounds_json(v_geom),
        status = 'ativo',
        updated_at = now()
    WHERE public.retiros.id = v_retiro_id;

    INSERT INTO public.piquete_movimentacoes (
      id_propriedade,
      retiro_id,
      tipo,
      entidade_tipo,
      entidade_id,
      descricao
    )
    VALUES (
      p_id_propriedade,
      v_retiro_id,
      'atualizou_retiro',
      'retiro',
      v_retiro_id::text,
      'Retiro atualizado'
    );
  END IF;

  SELECT *
  INTO v_retiro
  FROM public.retiros r
  WHERE r.id = v_retiro_id;

  RETURN public.retiro_to_json(v_retiro);
END;
$$;

CREATE OR REPLACE FUNCTION public.validar_retiro_no_limite_trigger()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, extensions
AS $$
DECLARE
  v_limite public.limites_propriedade;
  v_area_limite numeric;
  v_area_usada numeric;
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
    RAISE EXCEPTION 'Cadastre o limite da propriedade antes de criar ou editar retiros';
  END IF;

  IF NOT extensions.ST_CoveredBy(NEW.geom, v_limite.geom) THEN
    RAISE EXCEPTION 'A area do retiro precisa estar dentro do limite da propriedade';
  END IF;

  SELECT r.nome
  INTO v_conflito
  FROM public.retiros r
  WHERE r.id_propriedade = NEW.id_propriedade
    AND r.id <> NEW.id
    AND r.geom IS NOT NULL
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

  v_area_limite := COALESCE(
    v_limite.area_informada_ha,
    v_limite.area_calculada_ha,
    public.piquete_area_ha(v_limite.geom)
  );
  v_area_usada := public.limite_propriedade_area_usada_ha(
    NEW.id_propriedade,
    NEW.id,
    NEW.geom,
    NULL,
    NULL,
    NULL
  );

  IF v_area_usada > v_area_limite THEN
    RAISE EXCEPTION 'A soma das areas de retiros e piquetes sem retiro (%.2f ha) ultrapassa o limite da propriedade (%.2f ha)',
      v_area_usada, v_area_limite;
  END IF;

  RETURN NEW;
END;
$$;
