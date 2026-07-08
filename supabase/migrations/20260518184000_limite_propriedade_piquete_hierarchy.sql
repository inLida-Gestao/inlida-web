-- =============================================================================
-- Limite da propriedade + hierarquia Limite > Retiro > Piquete
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

CREATE TABLE IF NOT EXISTS public.limites_propriedade (
  id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  id_limite text NOT NULL UNIQUE DEFAULT ('lim_' || replace(extensions.gen_random_uuid()::text, '-', '')),
  id_propriedade text NOT NULL,
  nome text NOT NULL DEFAULT 'Limite da propriedade',
  area_informada_ha numeric,
  area_calculada_ha numeric,
  anotacoes text,
  geom extensions.geometry(Polygon, 4326) NOT NULL,
  centro extensions.geometry(Point, 4326),
  bounds jsonb,
  status text NOT NULL DEFAULT 'ativo',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz,
  deleted_at timestamptz,
  CONSTRAINT limites_propriedade_status_check CHECK (status IN ('ativo', 'excluido')),
  CONSTRAINT limites_propriedade_area_informada_check CHECK (area_informada_ha IS NULL OR area_informada_ha > 0),
  CONSTRAINT limites_propriedade_area_calculada_check CHECK (area_calculada_ha IS NULL OR area_calculada_ha > 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS limites_propriedade_unico_ativo_idx
  ON public.limites_propriedade (id_propriedade)
  WHERE deleted_at IS NULL AND status = 'ativo';

CREATE INDEX IF NOT EXISTS limites_propriedade_id_propriedade_idx
  ON public.limites_propriedade (id_propriedade)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS limites_propriedade_geom_gix
  ON public.limites_propriedade
  USING gist (geom);

CREATE OR REPLACE FUNCTION public.limite_propriedade_area_usada_ha(
  p_id_propriedade text,
  p_retiro_id uuid DEFAULT NULL,
  p_retiro_geom extensions.geometry DEFAULT NULL,
  p_piquete_id integer DEFAULT NULL,
  p_piquete_retiro_id uuid DEFAULT NULL,
  p_piquete_geom extensions.geometry DEFAULT NULL
)
RETURNS numeric
LANGUAGE plpgsql
STABLE
SET search_path = public, extensions
AS $$
DECLARE
  v_area numeric := 0;
BEGIN
  SELECT COALESCE(sum(public.piquete_area_ha(r.geom)), 0)
  INTO v_area
  FROM public.retiros r
  WHERE r.id_propriedade = p_id_propriedade
    AND r.deleted_at IS NULL
    AND COALESCE(r.status, 'ativo') = 'ativo'
    AND (p_retiro_id IS NULL OR r.id <> p_retiro_id);

  IF p_retiro_geom IS NOT NULL THEN
    v_area := v_area + public.piquete_area_ha(p_retiro_geom);
  END IF;

  SELECT v_area + COALESCE(sum(public.piquete_area_ha(p.geom)), 0)
  INTO v_area
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND p.retiro_id IS NULL
    AND p.geom IS NOT NULL
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND (p_piquete_id IS NULL OR p.id <> p_piquete_id);

  IF p_piquete_geom IS NOT NULL AND p_piquete_retiro_id IS NULL THEN
    v_area := v_area + public.piquete_area_ha(p_piquete_geom);
  END IF;

  RETURN round(COALESCE(v_area, 0), 4);
END;
$$;

CREATE OR REPLACE FUNCTION public.limite_propriedade_to_json(
  p_limite public.limites_propriedade
)
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, extensions
AS $$
  SELECT jsonb_build_object(
    'id', p_limite.id::text,
    'id_limite', p_limite.id_limite,
    'id_propriedade', p_limite.id_propriedade,
    'nome', p_limite.nome,
    'area_ha', COALESCE(p_limite.area_informada_ha, p_limite.area_calculada_ha, 0),
    'area_calculada_ha', COALESCE(p_limite.area_calculada_ha, 0),
    'area_usada_ha', public.limite_propriedade_area_usada_ha(p_limite.id_propriedade),
    'area_disponivel_ha', GREATEST(
      COALESCE(p_limite.area_informada_ha, p_limite.area_calculada_ha, 0)
        - public.limite_propriedade_area_usada_ha(p_limite.id_propriedade),
      0
    ),
    'anotacoes', COALESCE(p_limite.anotacoes, ''),
    'geojson', public.piquete_geojson_json(p_limite.geom),
    'status', COALESCE(p_limite.status, 'ativo'),
    'created_at', p_limite.created_at
  );
$$;

CREATE OR REPLACE FUNCTION public.buscar_limite_propriedade(
  p_id_propriedade text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
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
  ORDER BY l.created_at DESC
  LIMIT 1;

  IF v_limite.id IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN public.limite_propriedade_to_json(v_limite);
END;
$$;

CREATE OR REPLACE FUNCTION public.validar_limite_propriedade_existente(
  p_id_propriedade text,
  p_limite_id uuid,
  p_limite_geom extensions.geometry
)
RETURNS void
LANGUAGE plpgsql
STABLE
SET search_path = public, extensions
AS $$
DECLARE
  v_limite_area numeric;
  v_area_usada numeric;
  v_nome text;
BEGIN
  v_limite_area := public.piquete_area_ha(p_limite_geom);
  v_area_usada := public.limite_propriedade_area_usada_ha(p_id_propriedade);

  IF v_area_usada > v_limite_area THEN
    RAISE EXCEPTION 'A soma das areas de retiros e piquetes sem retiro (%.2f ha) ultrapassa o limite da propriedade (%.2f ha)',
      v_area_usada, v_limite_area;
  END IF;

  SELECT r.nome
  INTO v_nome
  FROM public.retiros r
  WHERE r.id_propriedade = p_id_propriedade
    AND r.deleted_at IS NULL
    AND COALESCE(r.status, 'ativo') = 'ativo'
    AND NOT extensions.ST_CoveredBy(r.geom, p_limite_geom)
  LIMIT 1;

  IF v_nome IS NOT NULL THEN
    RAISE EXCEPTION 'O retiro "%" precisa estar dentro do limite da propriedade', v_nome;
  END IF;

  SELECT p.nome
  INTO v_nome
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND p.retiro_id IS NULL
    AND p.geom IS NOT NULL
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND NOT extensions.ST_CoveredBy(p.geom, p_limite_geom)
  LIMIT 1;

  IF v_nome IS NOT NULL THEN
    RAISE EXCEPTION 'O piquete "%" precisa estar dentro do limite da propriedade', v_nome;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.salvar_limite_propriedade(
  p_limite_id text DEFAULT '',
  p_id_propriedade text DEFAULT '',
  p_nome text DEFAULT 'Limite da propriedade',
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
  v_limite_id uuid;
  v_limite public.limites_propriedade;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  v_geom := public.piquete_geojson_to_polygon(p_geojson);

  IF NULLIF(btrim(COALESCE(p_limite_id, '')), '') IS NOT NULL THEN
    SELECT l.id
    INTO v_limite_id
    FROM public.limites_propriedade l
    WHERE l.id_propriedade = p_id_propriedade
      AND l.deleted_at IS NULL
      AND (l.id::text = p_limite_id OR l.id_limite = p_limite_id)
    LIMIT 1;
  END IF;

  IF v_limite_id IS NULL THEN
    SELECT l.id
    INTO v_limite_id
    FROM public.limites_propriedade l
    WHERE l.id_propriedade = p_id_propriedade
      AND l.deleted_at IS NULL
      AND COALESCE(l.status, 'ativo') = 'ativo'
    LIMIT 1;
  END IF;

  PERFORM public.validar_limite_propriedade_existente(p_id_propriedade, v_limite_id, v_geom);

  IF v_limite_id IS NULL THEN
    INSERT INTO public.limites_propriedade (
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
      COALESCE(NULLIF(btrim(p_nome), ''), 'Limite da propriedade'),
      p_area_informada_ha,
      public.piquete_area_ha(v_geom),
      NULLIF(btrim(COALESCE(p_anotacoes, '')), ''),
      v_geom,
      extensions.ST_PointOnSurface(v_geom),
      public.piquete_bounds_json(v_geom),
      'ativo',
      now()
    )
    RETURNING id INTO v_limite_id;
  ELSE
    UPDATE public.limites_propriedade
    SET nome = COALESCE(NULLIF(btrim(p_nome), ''), 'Limite da propriedade'),
        area_informada_ha = p_area_informada_ha,
        area_calculada_ha = public.piquete_area_ha(v_geom),
        anotacoes = NULLIF(btrim(COALESCE(p_anotacoes, '')), ''),
        geom = v_geom,
        centro = extensions.ST_PointOnSurface(v_geom),
        bounds = public.piquete_bounds_json(v_geom),
        status = 'ativo',
        updated_at = now()
    WHERE public.limites_propriedade.id = v_limite_id;
  END IF;

  SELECT *
  INTO v_limite
  FROM public.limites_propriedade l
  WHERE l.id = v_limite_id;

  RETURN public.limite_propriedade_to_json(v_limite);
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

  IF NOT extensions.ST_CoveredBy(NEW.geom, v_limite.geom) THEN
    RAISE EXCEPTION 'A area do retiro precisa estar dentro do limite da propriedade';
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

  v_area_limite := COALESCE(v_limite.area_informada_ha, v_limite.area_calculada_ha, public.piquete_area_ha(v_limite.geom));
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

DROP TRIGGER IF EXISTS validar_retiro_no_limite_before_write ON public.retiros;
CREATE TRIGGER validar_retiro_no_limite_before_write
  BEFORE INSERT OR UPDATE ON public.retiros
  FOR EACH ROW
  EXECUTE FUNCTION public.validar_retiro_no_limite_trigger();

CREATE OR REPLACE FUNCTION public.validar_piquete_no_limite_trigger()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public, extensions
AS $$
DECLARE
  v_limite public.limites_propriedade;
  v_retiro public.retiros;
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
    RAISE EXCEPTION 'Cadastre o limite da propriedade antes de criar ou editar piquetes';
  END IF;

  IF NOT extensions.ST_CoveredBy(NEW.geom, v_limite.geom) THEN
    RAISE EXCEPTION 'A area do piquete precisa estar dentro do limite da propriedade';
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

  v_area_limite := COALESCE(v_limite.area_informada_ha, v_limite.area_calculada_ha, public.piquete_area_ha(v_limite.geom));
  v_area_usada := public.limite_propriedade_area_usada_ha(
    NEW.id_propriedade,
    NULL,
    NULL,
    NEW.id,
    NEW.retiro_id,
    NEW.geom
  );

  IF v_area_usada > v_area_limite THEN
    RAISE EXCEPTION 'A soma das areas de retiros e piquetes sem retiro (%.2f ha) ultrapassa o limite da propriedade (%.2f ha)',
      v_area_usada, v_area_limite;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS validar_piquete_no_limite_before_write ON public.piquete;
CREATE TRIGGER validar_piquete_no_limite_before_write
  BEFORE INSERT OR UPDATE ON public.piquete
  FOR EACH ROW
  EXECUTE FUNCTION public.validar_piquete_no_limite_trigger();

GRANT EXECUTE ON FUNCTION public.buscar_limite_propriedade(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.salvar_limite_propriedade(text, text, text, numeric, text, jsonb) TO authenticated;
