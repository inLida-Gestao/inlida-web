-- =============================================================================
-- Backend Retiro/Piquete com PostGIS
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- -----------------------------------------------------------------------------
-- Tabelas
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.retiros (
  id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  id_retiro text NOT NULL UNIQUE DEFAULT ('ret_' || replace(extensions.gen_random_uuid()::text, '-', '')),
  id_propriedade text NOT NULL,
  nome text NOT NULL,
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
  CONSTRAINT retiros_status_check CHECK (status IN ('ativo', 'excluido')),
  CONSTRAINT retiros_area_informada_check CHECK (area_informada_ha IS NULL OR area_informada_ha > 0),
  CONSTRAINT retiros_area_calculada_check CHECK (area_calculada_ha IS NULL OR area_calculada_ha > 0)
);

ALTER TABLE public.piquete
  ADD COLUMN IF NOT EXISTS retiro_id uuid REFERENCES public.retiros(id),
  ADD COLUMN IF NOT EXISTS geom extensions.geometry(Polygon, 4326),
  ADD COLUMN IF NOT EXISTS area_calculada_ha numeric,
  ADD COLUMN IF NOT EXISTS centro extensions.geometry(Point, 4326),
  ADD COLUMN IF NOT EXISTS bounds jsonb,
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'ativo',
  ADD COLUMN IF NOT EXISTS updated_at timestamptz,
  ADD COLUMN IF NOT EXISTS deleted_at timestamptz;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'piquete_status_check'
      AND conrelid = 'public.piquete'::regclass
  ) THEN
    ALTER TABLE public.piquete
      ADD CONSTRAINT piquete_status_check CHECK (status IN ('ativo', 'excluido'));
  END IF;
END;
$$;

CREATE TABLE IF NOT EXISTS public.piquete_forrageiras (
  piquete_id integer NOT NULL REFERENCES public.piquete(id) ON DELETE CASCADE,
  forrageira_id integer NOT NULL REFERENCES public.forrageiras(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (piquete_id, forrageira_id)
);

CREATE TABLE IF NOT EXISTS public.piquete_animais (
  id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  piquete_id integer NOT NULL REFERENCES public.piquete(id) ON DELETE CASCADE,
  id_rebanho text NOT NULL,
  id_propriedade text NOT NULL,
  data_entrada timestamptz NOT NULL DEFAULT now(),
  data_saida timestamptz,
  status text NOT NULL DEFAULT 'ativo',
  origem text NOT NULL DEFAULT 'manual',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz,
  CONSTRAINT piquete_animais_status_check CHECK (status IN ('ativo', 'inativo'))
);

CREATE TABLE IF NOT EXISTS public.piquete_lotes (
  id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  piquete_id integer NOT NULL REFERENCES public.piquete(id) ON DELETE CASCADE,
  id_lote text NOT NULL,
  id_propriedade text NOT NULL,
  data_entrada timestamptz NOT NULL DEFAULT now(),
  data_saida timestamptz,
  status text NOT NULL DEFAULT 'ativo',
  origem text NOT NULL DEFAULT 'manual',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz,
  CONSTRAINT piquete_lotes_status_check CHECK (status IN ('ativo', 'inativo'))
);

CREATE TABLE IF NOT EXISTS public.piquete_movimentacoes (
  id uuid PRIMARY KEY DEFAULT extensions.gen_random_uuid(),
  id_propriedade text NOT NULL,
  retiro_id uuid REFERENCES public.retiros(id),
  piquete_id integer REFERENCES public.piquete(id),
  tipo text NOT NULL,
  entidade_tipo text,
  entidade_id text,
  descricao text,
  metadata jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS retiros_id_propriedade_idx
  ON public.retiros (id_propriedade)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS retiros_geom_gix
  ON public.retiros
  USING gist (geom);

CREATE INDEX IF NOT EXISTS piquete_retiro_id_idx
  ON public.piquete (retiro_id)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS piquete_geom_gix
  ON public.piquete
  USING gist (geom);

CREATE UNIQUE INDEX IF NOT EXISTS piquete_animais_ativo_unique_idx
  ON public.piquete_animais (id_propriedade, id_rebanho)
  WHERE status = 'ativo';

CREATE UNIQUE INDEX IF NOT EXISTS piquete_lotes_ativo_unique_idx
  ON public.piquete_lotes (id_propriedade, id_lote)
  WHERE status = 'ativo';

CREATE INDEX IF NOT EXISTS piquete_movimentacoes_piquete_idx
  ON public.piquete_movimentacoes (piquete_id, created_at DESC);

CREATE INDEX IF NOT EXISTS piquete_movimentacoes_retiro_idx
  ON public.piquete_movimentacoes (retiro_id, created_at DESC);

-- -----------------------------------------------------------------------------
-- Helpers de seguranca/geometria
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.usuario_tem_acesso_propriedade(p_id_propriedade text)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid text;
BEGIN
  v_uid := auth.uid()::text;

  IF v_uid IS NULL OR btrim(v_uid) = '' OR p_id_propriedade IS NULL OR btrim(p_id_propriedade) = '' THEN
    RETURN false;
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM public.users_propriedades up
    WHERE up."idPropriedade" = p_id_propriedade
      AND up.user_id = v_uid
      AND COALESCE(up.deletado, 'NAO') = 'NAO'
  )
  OR EXISTS (
    SELECT 1
    FROM public.propriedades p
    WHERE p."idPropriedade" = p_id_propriedade
      AND p."userID" = v_uid
      AND COALESCE(p.deletado, 'NAO') = 'NAO'
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_geojson_to_polygon(p_geojson jsonb)
RETURNS extensions.geometry
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public, extensions
AS $$
DECLARE
  v_json jsonb;
  v_geom extensions.geometry;
BEGIN
  IF p_geojson IS NULL THEN
    RAISE EXCEPTION 'GeoJSON da area e obrigatorio';
  END IF;

  v_json := CASE
    WHEN p_geojson->>'type' = 'Feature' THEN p_geojson->'geometry'
    ELSE p_geojson
  END;

  IF v_json IS NULL OR COALESCE(v_json->>'type', '') NOT IN ('Polygon', 'MultiPolygon') THEN
    RAISE EXCEPTION 'GeoJSON deve ser um Polygon';
  END IF;

  v_geom := extensions.ST_SetSRID(extensions.ST_GeomFromGeoJSON(v_json::text), 4326);
  v_geom := extensions.ST_Force2D(extensions.ST_MakeValid(v_geom));

  IF extensions.GeometryType(v_geom) = 'MULTIPOLYGON' THEN
    IF extensions.ST_NumGeometries(v_geom) <> 1 THEN
      RAISE EXCEPTION 'A area deve ter somente um poligono';
    END IF;
    v_geom := extensions.ST_GeometryN(v_geom, 1);
  END IF;

  IF extensions.GeometryType(v_geom) <> 'POLYGON' THEN
    RAISE EXCEPTION 'GeoJSON deve ser um Polygon valido';
  END IF;

  IF NOT extensions.ST_IsValid(v_geom) THEN
    RAISE EXCEPTION 'Poligono invalido';
  END IF;

  IF extensions.ST_NPoints(v_geom) < 4 THEN
    RAISE EXCEPTION 'A area precisa ter ao menos 3 pontos';
  END IF;

  IF extensions.ST_Area(v_geom::geography) <= 0 THEN
    RAISE EXCEPTION 'Area calculada precisa ser maior que zero';
  END IF;

  RETURN v_geom;
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_area_ha(p_geom extensions.geometry)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
STRICT
SET search_path = public, extensions
AS $$
  SELECT round((extensions.ST_Area(p_geom::geography) / 10000)::numeric, 4);
$$;

CREATE OR REPLACE FUNCTION public.piquete_bounds_json(p_geom extensions.geometry)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
STRICT
SET search_path = public, extensions
AS $$
  SELECT jsonb_build_object(
    'south', min(extensions.ST_Y(dp.geom)),
    'west', min(extensions.ST_X(dp.geom)),
    'north', max(extensions.ST_Y(dp.geom)),
    'east', max(extensions.ST_X(dp.geom))
  )
  FROM extensions.ST_DumpPoints(p_geom) AS dp;
$$;

CREATE OR REPLACE FUNCTION public.piquete_center_json(p_geom extensions.geometry)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
STRICT
SET search_path = public, extensions
AS $$
  SELECT jsonb_build_object(
    'latitude', extensions.ST_Y(extensions.ST_PointOnSurface(p_geom)),
    'longitude', extensions.ST_X(extensions.ST_PointOnSurface(p_geom))
  );
$$;

CREATE OR REPLACE FUNCTION public.piquete_geojson_json(p_geom extensions.geometry)
RETURNS jsonb
LANGUAGE sql
IMMUTABLE
STRICT
SET search_path = public, extensions
AS $$
  SELECT extensions.ST_AsGeoJSON(p_geom)::jsonb;
$$;

CREATE OR REPLACE FUNCTION public.retiro_to_json(p_retiro public.retiros)
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, extensions
AS $$
  SELECT jsonb_build_object(
    'id', p_retiro.id::text,
    'id_retiro', p_retiro.id_retiro,
    'id_propriedade', p_retiro.id_propriedade,
    'nome', p_retiro.nome,
    'area_informada_ha', p_retiro.area_informada_ha,
    'area_calculada_ha', p_retiro.area_calculada_ha,
    'area_ha', COALESCE(p_retiro.area_calculada_ha, p_retiro.area_informada_ha, 0),
    'anotacoes', COALESCE(p_retiro.anotacoes, ''),
    'geojson', public.piquete_geojson_json(p_retiro.geom),
    'centro', public.piquete_center_json(p_retiro.geom),
    'bounds', COALESCE(p_retiro.bounds, public.piquete_bounds_json(p_retiro.geom)),
    'status', p_retiro.status,
    'created_at', p_retiro.created_at
  );
$$;

CREATE OR REPLACE FUNCTION public.piquete_to_json(p_piquete public.piquete)
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, extensions
AS $$
  SELECT jsonb_build_object(
    'id', p_piquete.id::text,
    'id_piquete', COALESCE(p_piquete.id_piquete, p_piquete.id::text),
    'retiro_id', p_piquete.retiro_id::text,
    'id_propriedade', p_piquete.id_propriedade,
    'nome', COALESCE(p_piquete.nome, ''),
    'area_informada_ha', p_piquete.area,
    'area_calculada_ha', p_piquete.area_calculada_ha,
    'area_ha', COALESCE(p_piquete.area_calculada_ha, p_piquete.area, 0),
    'forrageiras', COALESCE(
      (
        SELECT jsonb_agg(f.nome ORDER BY f.nome)
        FROM public.piquete_forrageiras pf
        JOIN public.forrageiras f ON f.id = pf.forrageira_id
        WHERE pf.piquete_id = p_piquete.id
      ),
      to_jsonb(COALESCE(p_piquete.forrageria, ARRAY[]::text[]))
    ),
    'anotacoes', COALESCE(p_piquete.anotacoes, ''),
    'geojson', CASE
      WHEN p_piquete.geom IS NULL THEN NULL
      ELSE public.piquete_geojson_json(p_piquete.geom)
    END,
    'centro', CASE
      WHEN p_piquete.geom IS NULL THEN NULL
      ELSE public.piquete_center_json(p_piquete.geom)
    END,
    'bounds', p_piquete.bounds,
    'animais_ids', COALESCE(
      (
        SELECT jsonb_agg(pa.id_rebanho ORDER BY pa.id_rebanho)
        FROM public.piquete_animais pa
        WHERE pa.piquete_id = p_piquete.id
          AND pa.status = 'ativo'
      ),
      to_jsonb(COALESCE(p_piquete.id_rebanhos, ARRAY[]::text[]))
    ),
    'lotes_ids', COALESCE(
      (
        SELECT jsonb_agg(pl.id_lote ORDER BY pl.id_lote)
        FROM public.piquete_lotes pl
        WHERE pl.piquete_id = p_piquete.id
          AND pl.status = 'ativo'
      ),
      to_jsonb(COALESCE(p_piquete.id_lotes, ARRAY[]::text[]))
    ),
    'animais_count', (
      SELECT count(*)
      FROM public.piquete_animais pa
      WHERE pa.piquete_id = p_piquete.id
        AND pa.status = 'ativo'
    ),
    'lotes_count', (
      SELECT count(*)
      FROM public.piquete_lotes pl
      WHERE pl.piquete_id = p_piquete.id
        AND pl.status = 'ativo'
    ),
    'animais_lotes_count', (
      SELECT count(DISTINCT r."idRebanho")
      FROM public.piquete_lotes pl
      JOIN public.rebanho r
        ON r."idPropriedade" = pl.id_propriedade
       AND r."loteID" = pl.id_lote
      WHERE pl.piquete_id = p_piquete.id
        AND pl.status = 'ativo'
        AND COALESCE(r.deletado, 'NAO') = 'NAO'
    ),
    'status', COALESCE(p_piquete.status, 'ativo'),
    'created_at', p_piquete.created_at
  );
$$;

-- -----------------------------------------------------------------------------
-- RPCs de escrita
-- -----------------------------------------------------------------------------

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

  v_geom := public.piquete_geojson_to_polygon(p_geojson);

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
      extensions.ST_PointOnSurface(v_geom),
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
        centro = extensions.ST_PointOnSurface(v_geom),
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
  v_piquetes_ativos integer;
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

  SELECT count(*)
  INTO v_piquetes_ativos
  FROM public.piquete p
  WHERE p.retiro_id = v_retiro.id
    AND p.id_propriedade = p_id_propriedade
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo';

  IF v_piquetes_ativos > 0 THEN
    RAISE EXCEPTION 'Nao e possivel excluir um retiro com piquetes ativos';
  END IF;

  UPDATE public.retiros
  SET status = 'excluido',
      deleted_at = now(),
      updated_at = now()
  WHERE public.retiros.id = v_retiro.id;

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
    v_retiro.id,
    'removeu_retiro',
    'retiro',
    v_retiro.id::text,
    'Retiro excluido'
  );

  RETURN jsonb_build_object('ok', true, 'id', v_retiro.id::text);
END;
$$;

CREATE OR REPLACE FUNCTION public.salvar_piquete(
  p_piquete_id text DEFAULT '',
  p_retiro_id text DEFAULT '',
  p_id_propriedade text DEFAULT '',
  p_nome text DEFAULT '',
  p_area_informada_ha numeric DEFAULT NULL,
  p_forrageiras text[] DEFAULT ARRAY[]::text[],
  p_anotacoes text DEFAULT '',
  p_geojson jsonb DEFAULT NULL,
  p_animais_ids text[] DEFAULT ARRAY[]::text[],
  p_lotes_ids text[] DEFAULT ARRAY[]::text[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_retiro public.retiros;
  v_geom extensions.geometry;
  v_area numeric;
  v_piquete_db_id integer;
  v_piquete public.piquete;
  v_forrageiras text[];
  v_animais text[];
  v_lotes text[];
  v_conflito text;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  IF p_nome IS NULL OR btrim(p_nome) = '' THEN
    RAISE EXCEPTION 'Nome do piquete e obrigatorio';
  END IF;

  SELECT *
  INTO v_retiro
  FROM public.retiros r
  WHERE r.id_propriedade = p_id_propriedade
    AND r.deleted_at IS NULL
    AND r.status = 'ativo'
    AND (r.id::text = p_retiro_id OR r.id_retiro = p_retiro_id)
  LIMIT 1;

  IF v_retiro.id IS NULL THEN
    RAISE EXCEPTION 'Retiro nao encontrado';
  END IF;

  v_geom := public.piquete_geojson_to_polygon(p_geojson);
  v_area := public.piquete_area_ha(v_geom);

  IF NOT extensions.ST_CoveredBy(v_geom, v_retiro.geom) THEN
    RAISE EXCEPTION 'A area do piquete precisa estar dentro do retiro';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT valor ORDER BY valor), ARRAY[]::text[])
  INTO v_forrageiras
  FROM (
    SELECT btrim(item) AS valor
    FROM unnest(COALESCE(p_forrageiras, ARRAY[]::text[])) AS item
    WHERE btrim(item) <> ''
  ) t;

  IF cardinality(v_forrageiras) = 0 THEN
    RAISE EXCEPTION 'Informe ao menos uma forrageira';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT valor ORDER BY valor), ARRAY[]::text[])
  INTO v_animais
  FROM (
    SELECT btrim(item) AS valor
    FROM unnest(COALESCE(p_animais_ids, ARRAY[]::text[])) AS item
    WHERE btrim(item) <> ''
  ) t;

  SELECT COALESCE(array_agg(DISTINCT valor ORDER BY valor), ARRAY[]::text[])
  INTO v_lotes
  FROM (
    SELECT btrim(item) AS valor
    FROM unnest(COALESCE(p_lotes_ids, ARRAY[]::text[])) AS item
    WHERE btrim(item) <> ''
  ) t;

  IF NULLIF(btrim(COALESCE(p_piquete_id, '')), '') IS NOT NULL THEN
    SELECT p.id
    INTO v_piquete_db_id
    FROM public.piquete p
    WHERE p.id_propriedade = p_id_propriedade
      AND p.deleted_at IS NULL
      AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
    LIMIT 1;
  END IF;

  SELECT pa.id_rebanho
  INTO v_conflito
  FROM public.piquete_animais pa
  WHERE pa.id_propriedade = p_id_propriedade
    AND pa.status = 'ativo'
    AND pa.id_rebanho = ANY(v_animais)
    AND (v_piquete_db_id IS NULL OR pa.piquete_id <> v_piquete_db_id)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'Animal ja esta vinculado a outro piquete: %', v_conflito;
  END IF;

  SELECT pl.id_lote
  INTO v_conflito
  FROM public.piquete_lotes pl
  WHERE pl.id_propriedade = p_id_propriedade
    AND pl.status = 'ativo'
    AND pl.id_lote = ANY(v_lotes)
    AND (v_piquete_db_id IS NULL OR pl.piquete_id <> v_piquete_db_id)
  LIMIT 1;

  IF v_conflito IS NOT NULL THEN
    RAISE EXCEPTION 'Lote ja esta vinculado a outro piquete: %', v_conflito;
  END IF;

  IF v_piquete_db_id IS NULL THEN
    INSERT INTO public.piquete (
      nome,
      area,
      forrageria,
      anotacoes,
      incluir_piquete,
      id_rebanhos,
      id_lotes,
      id_piquete,
      id_propriedade,
      retiro_id,
      geom,
      area_calculada_ha,
      centro,
      bounds,
      status,
      updated_at
    )
    VALUES (
      btrim(p_nome),
      COALESCE(p_area_informada_ha, v_area),
      v_forrageiras,
      NULLIF(btrim(COALESCE(p_anotacoes, '')), ''),
      CASE
        WHEN cardinality(v_animais) > 0 AND cardinality(v_lotes) > 0 THEN 'Misto'
        WHEN cardinality(v_animais) > 0 THEN 'Animal'
        WHEN cardinality(v_lotes) > 0 THEN 'Lote'
        ELSE 'Vazio'
      END,
      v_animais,
      v_lotes,
      'piq_' || replace(extensions.gen_random_uuid()::text, '-', ''),
      p_id_propriedade,
      v_retiro.id,
      v_geom,
      v_area,
      extensions.ST_PointOnSurface(v_geom),
      public.piquete_bounds_json(v_geom),
      'ativo',
      now()
    )
    RETURNING id INTO v_piquete_db_id;

    INSERT INTO public.piquete_movimentacoes (
      id_propriedade,
      retiro_id,
      piquete_id,
      tipo,
      entidade_tipo,
      entidade_id,
      descricao
    )
    VALUES (
      p_id_propriedade,
      v_retiro.id,
      v_piquete_db_id,
      'criou_piquete',
      'piquete',
      v_piquete_db_id::text,
      'Piquete criado'
    );
  ELSE
    UPDATE public.piquete
    SET nome = btrim(p_nome),
        area = COALESCE(p_area_informada_ha, v_area),
        forrageria = v_forrageiras,
        anotacoes = NULLIF(btrim(COALESCE(p_anotacoes, '')), ''),
        incluir_piquete = CASE
          WHEN cardinality(v_animais) > 0 AND cardinality(v_lotes) > 0 THEN 'Misto'
          WHEN cardinality(v_animais) > 0 THEN 'Animal'
          WHEN cardinality(v_lotes) > 0 THEN 'Lote'
          ELSE 'Vazio'
        END,
        id_rebanhos = v_animais,
        id_lotes = v_lotes,
        retiro_id = v_retiro.id,
        geom = v_geom,
        area_calculada_ha = v_area,
        centro = extensions.ST_PointOnSurface(v_geom),
        bounds = public.piquete_bounds_json(v_geom),
        status = 'ativo',
        updated_at = now()
    WHERE public.piquete.id = v_piquete_db_id;

    INSERT INTO public.piquete_movimentacoes (
      id_propriedade,
      retiro_id,
      piquete_id,
      tipo,
      entidade_tipo,
      entidade_id,
      descricao
    )
    VALUES (
      p_id_propriedade,
      v_retiro.id,
      v_piquete_db_id,
      'atualizou_piquete',
      'piquete',
      v_piquete_db_id::text,
      'Piquete atualizado'
    );
  END IF;

  INSERT INTO public.forrageiras (nome)
  SELECT unnest(v_forrageiras)
  ON CONFLICT (nome) DO NOTHING;

  DELETE FROM public.piquete_forrageiras
  WHERE piquete_id = v_piquete_db_id;

  INSERT INTO public.piquete_forrageiras (piquete_id, forrageira_id)
  SELECT v_piquete_db_id, f.id
  FROM public.forrageiras f
  WHERE f.nome = ANY(v_forrageiras)
  ON CONFLICT DO NOTHING;

  UPDATE public.piquete_animais
  SET status = 'inativo',
      data_saida = now(),
      updated_at = now()
  WHERE piquete_id = v_piquete_db_id
    AND status = 'ativo'
    AND NOT (id_rebanho = ANY(v_animais));

  INSERT INTO public.piquete_animais (
    piquete_id,
    id_rebanho,
    id_propriedade,
    status,
    origem
  )
  SELECT v_piquete_db_id, item, p_id_propriedade, 'ativo', 'manual'
  FROM unnest(v_animais) AS item
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.piquete_animais pa
    WHERE pa.piquete_id = v_piquete_db_id
      AND pa.id_rebanho = item
      AND pa.status = 'ativo'
  );

  UPDATE public.piquete_lotes
  SET status = 'inativo',
      data_saida = now(),
      updated_at = now()
  WHERE piquete_id = v_piquete_db_id
    AND status = 'ativo'
    AND NOT (id_lote = ANY(v_lotes));

  INSERT INTO public.piquete_lotes (
    piquete_id,
    id_lote,
    id_propriedade,
    status,
    origem
  )
  SELECT v_piquete_db_id, item, p_id_propriedade, 'ativo', 'manual'
  FROM unnest(v_lotes) AS item
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.piquete_lotes pl
    WHERE pl.piquete_id = v_piquete_db_id
      AND pl.id_lote = item
      AND pl.status = 'ativo'
  );

  SELECT *
  INTO v_piquete
  FROM public.piquete p
  WHERE p.id = v_piquete_db_id;

  RETURN public.piquete_to_json(v_piquete);
END;
$$;

CREATE OR REPLACE FUNCTION public.excluir_piquete(
  p_piquete_id text DEFAULT '',
  p_id_propriedade text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_piquete public.piquete;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT *
  INTO v_piquete
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND p.deleted_at IS NULL
    AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
  LIMIT 1;

  IF v_piquete.id IS NULL THEN
    RAISE EXCEPTION 'Piquete nao encontrado';
  END IF;

  UPDATE public.piquete
  SET status = 'excluido',
      deleted_at = now(),
      updated_at = now()
  WHERE public.piquete.id = v_piquete.id;

  UPDATE public.piquete_animais
  SET status = 'inativo',
      data_saida = COALESCE(data_saida, now()),
      updated_at = now()
  WHERE piquete_id = v_piquete.id
    AND status = 'ativo';

  UPDATE public.piquete_lotes
  SET status = 'inativo',
      data_saida = COALESCE(data_saida, now()),
      updated_at = now()
  WHERE piquete_id = v_piquete.id
    AND status = 'ativo';

  INSERT INTO public.piquete_movimentacoes (
    id_propriedade,
    retiro_id,
    piquete_id,
    tipo,
    entidade_tipo,
    entidade_id,
    descricao
  )
  VALUES (
    p_id_propriedade,
    v_piquete.retiro_id,
    v_piquete.id,
    'removeu_piquete',
    'piquete',
    v_piquete.id::text,
    'Piquete excluido'
  );

  RETURN jsonb_build_object('ok', true, 'id', v_piquete.id::text);
END;
$$;

-- -----------------------------------------------------------------------------
-- RPCs de leitura
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.listar_retiros_com_resumo(
  p_id_propriedade text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_result jsonb;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT COALESCE(jsonb_agg(item ORDER BY item->>'nome'), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT public.retiro_to_json(r) || jsonb_build_object(
      'piquetes_count', (
        SELECT count(*)
        FROM public.piquete p
        WHERE p.retiro_id = r.id
          AND p.deleted_at IS NULL
          AND COALESCE(p.status, 'ativo') = 'ativo'
      ),
      'animais_count', (
        SELECT count(DISTINCT animal_id)
        FROM (
          SELECT pa.id_rebanho AS animal_id
          FROM public.piquete p
          JOIN public.piquete_animais pa ON pa.piquete_id = p.id AND pa.status = 'ativo'
          WHERE p.retiro_id = r.id
            AND p.deleted_at IS NULL
          UNION
          SELECT rb."idRebanho" AS animal_id
          FROM public.piquete p
          JOIN public.piquete_lotes pl ON pl.piquete_id = p.id AND pl.status = 'ativo'
          JOIN public.rebanho rb
            ON rb."idPropriedade" = pl.id_propriedade
           AND rb."loteID" = pl.id_lote
          WHERE p.retiro_id = r.id
            AND p.deleted_at IS NULL
            AND COALESCE(rb.deletado, 'NAO') = 'NAO'
        ) animais
      ),
      'lotes_count', (
        SELECT count(DISTINCT pl.id_lote)
        FROM public.piquete p
        JOIN public.piquete_lotes pl ON pl.piquete_id = p.id AND pl.status = 'ativo'
        WHERE p.retiro_id = r.id
          AND p.deleted_at IS NULL
      ),
      'forrageiras', COALESCE((
        SELECT jsonb_agg(DISTINCT f.nome)
        FROM public.piquete p
        JOIN public.piquete_forrageiras pf ON pf.piquete_id = p.id
        JOIN public.forrageiras f ON f.id = pf.forrageira_id
        WHERE p.retiro_id = r.id
          AND p.deleted_at IS NULL
      ), '[]'::jsonb)
    ) AS item
    FROM public.retiros r
    WHERE r.id_propriedade = p_id_propriedade
      AND r.deleted_at IS NULL
      AND r.status = 'ativo'
  ) s;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.listar_piquetes_por_retiro(
  p_retiro_id text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_forrageiras text[] DEFAULT ARRAY[]::text[],
  p_limite integer DEFAULT 50,
  p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_retiro public.retiros;
  v_result jsonb;
  v_query text;
BEGIN
  SELECT *
  INTO v_retiro
  FROM public.retiros r
  WHERE r.deleted_at IS NULL
    AND r.status = 'ativo'
    AND (r.id::text = p_retiro_id OR r.id_retiro = p_retiro_id)
  LIMIT 1;

  IF v_retiro.id IS NULL THEN
    RAISE EXCEPTION 'Retiro nao encontrado';
  END IF;

  IF NOT public.usuario_tem_acesso_propriedade(v_retiro.id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  v_query := lower(btrim(COALESCE(p_pesquisa, '')));

  SELECT COALESCE(jsonb_agg(public.piquete_to_json(filtered.p) ORDER BY (filtered.p).nome), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT p
    FROM public.piquete p
    WHERE p.retiro_id = v_retiro.id
      AND p.deleted_at IS NULL
      AND COALESCE(p.status, 'ativo') = 'ativo'
      AND (
        v_query = ''
        OR lower(COALESCE(p.nome, '')) LIKE '%' || v_query || '%'
        OR EXISTS (
          SELECT 1
          FROM public.piquete_forrageiras pf
          JOIN public.forrageiras f ON f.id = pf.forrageira_id
          WHERE pf.piquete_id = p.id
            AND lower(f.nome) LIKE '%' || v_query || '%'
        )
      )
      AND (
        cardinality(COALESCE(p_forrageiras, ARRAY[]::text[])) = 0
        OR EXISTS (
          SELECT 1
          FROM public.piquete_forrageiras pf
          JOIN public.forrageiras f ON f.id = pf.forrageira_id
          WHERE pf.piquete_id = p.id
            AND f.nome = ANY(p_forrageiras)
        )
      )
    ORDER BY p.nome
    LIMIT GREATEST(COALESCE(p_limite, 50), 1)
    OFFSET GREATEST(COALESCE(p_offset, 0), 0)
  ) filtered;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.buscar_piquete_detalhe(
  p_piquete_id text DEFAULT '',
  p_id_propriedade text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_piquete public.piquete;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT *
  INTO v_piquete
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
  LIMIT 1;

  IF v_piquete.id IS NULL THEN
    RAISE EXCEPTION 'Piquete nao encontrado';
  END IF;

  RETURN public.piquete_to_json(v_piquete);
END;
$$;

CREATE OR REPLACE FUNCTION public.buscar_animais_disponiveis_piquete(
  p_id_propriedade text DEFAULT '',
  p_piquete_id text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_piquete_db_id integer;
  v_result jsonb;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  IF NULLIF(btrim(COALESCE(p_piquete_id, '')), '') IS NOT NULL THEN
    SELECT p.id
    INTO v_piquete_db_id
    FROM public.piquete p
    WHERE p.id_propriedade = p_id_propriedade
      AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
    LIMIT 1;
  END IF;

  SELECT COALESCE(jsonb_agg(item ORDER BY item->>'numero'), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', r."idRebanho",
      'numero', COALESCE(r."numeroAnimal", ''),
      'nome', COALESCE(r.nome, ''),
      'sexo', COALESCE(r.sexo, ''),
      'categoria', COALESCE(r.categoria, ''),
      'raca', COALESCE(r.raca, ''),
      'data_nascimento', r."dataNascimento",
      'lote_nome', COALESCE(r."loteNome", ''),
      'lote_id', COALESCE(r."loteID", '')
    ) AS item
    FROM public.rebanho r
    WHERE r."idPropriedade" = p_id_propriedade
      AND r."idRebanho" IS NOT NULL
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND NOT EXISTS (
        SELECT 1
        FROM public.piquete_animais pa
        WHERE pa.id_propriedade = p_id_propriedade
          AND pa.id_rebanho = r."idRebanho"
          AND pa.status = 'ativo'
          AND (v_piquete_db_id IS NULL OR pa.piquete_id <> v_piquete_db_id)
      )
  ) s;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.buscar_lotes_disponiveis_piquete(
  p_id_propriedade text DEFAULT '',
  p_piquete_id text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_piquete_db_id integer;
  v_result jsonb;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  IF NULLIF(btrim(COALESCE(p_piquete_id, '')), '') IS NOT NULL THEN
    SELECT p.id
    INTO v_piquete_db_id
    FROM public.piquete p
    WHERE p.id_propriedade = p_id_propriedade
      AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
    LIMIT 1;
  END IF;

  SELECT COALESCE(jsonb_agg(item ORDER BY item->>'nome'), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT jsonb_build_object(
      'id', l.id_lote,
      'nome', COALESCE(l.nome, ''),
      'qtd_animais', (
        SELECT count(*)
        FROM public.rebanho r
        WHERE r."idPropriedade" = p_id_propriedade
          AND r."loteID" = l.id_lote
          AND COALESCE(r.deletado, 'NAO') = 'NAO'
      ),
      'status', COALESCE(NULLIF(l.ativo, ''), 'Ativo')
    ) AS item
    FROM public.lotes l
    WHERE l.id_propriedade = p_id_propriedade
      AND l.id_lote IS NOT NULL
      AND COALESCE(l.deletado, 'NAO') = 'NAO'
      AND NOT EXISTS (
        SELECT 1
        FROM public.piquete_lotes pl
        WHERE pl.id_propriedade = p_id_propriedade
          AND pl.id_lote = l.id_lote
          AND pl.status = 'ativo'
          AND (v_piquete_db_id IS NULL OR pl.piquete_id <> v_piquete_db_id)
      )
  ) s;

  RETURN v_result;
END;
$$;

-- -----------------------------------------------------------------------------
-- RLS e grants
-- -----------------------------------------------------------------------------

ALTER TABLE public.retiros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.piquete_forrageiras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.piquete_animais ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.piquete_lotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.piquete_movimentacoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS retiros_authenticated_select ON public.retiros;
CREATE POLICY retiros_authenticated_select
ON public.retiros
FOR SELECT
TO authenticated
USING (public.usuario_tem_acesso_propriedade(id_propriedade));

DROP POLICY IF EXISTS retiros_authenticated_insert ON public.retiros;
CREATE POLICY retiros_authenticated_insert
ON public.retiros
FOR INSERT
TO authenticated
WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));

DROP POLICY IF EXISTS retiros_authenticated_update ON public.retiros;
CREATE POLICY retiros_authenticated_update
ON public.retiros
FOR UPDATE
TO authenticated
USING (public.usuario_tem_acesso_propriedade(id_propriedade))
WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));

DROP POLICY IF EXISTS piquete_forrageiras_authenticated_all ON public.piquete_forrageiras;
CREATE POLICY piquete_forrageiras_authenticated_all
ON public.piquete_forrageiras
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM public.piquete p
    WHERE p.id = piquete_forrageiras.piquete_id
      AND public.usuario_tem_acesso_propriedade(p.id_propriedade)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.piquete p
    WHERE p.id = piquete_forrageiras.piquete_id
      AND public.usuario_tem_acesso_propriedade(p.id_propriedade)
  )
);

DROP POLICY IF EXISTS piquete_animais_authenticated_all ON public.piquete_animais;
CREATE POLICY piquete_animais_authenticated_all
ON public.piquete_animais
FOR ALL
TO authenticated
USING (public.usuario_tem_acesso_propriedade(id_propriedade))
WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));

DROP POLICY IF EXISTS piquete_lotes_authenticated_all ON public.piquete_lotes;
CREATE POLICY piquete_lotes_authenticated_all
ON public.piquete_lotes
FOR ALL
TO authenticated
USING (public.usuario_tem_acesso_propriedade(id_propriedade))
WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));

DROP POLICY IF EXISTS piquete_movimentacoes_authenticated_select ON public.piquete_movimentacoes;
CREATE POLICY piquete_movimentacoes_authenticated_select
ON public.piquete_movimentacoes
FOR SELECT
TO authenticated
USING (public.usuario_tem_acesso_propriedade(id_propriedade));

GRANT SELECT, INSERT, UPDATE, DELETE ON public.retiros TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.piquete_forrageiras TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.piquete_animais TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.piquete_lotes TO authenticated;
GRANT SELECT ON public.piquete_movimentacoes TO authenticated;

GRANT EXECUTE ON FUNCTION public.usuario_tem_acesso_propriedade(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.salvar_retiro(text, text, text, numeric, text, jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.excluir_retiro(text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.salvar_piquete(text, text, text, text, numeric, text[], text, jsonb, text[], text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.excluir_piquete(text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_retiros_com_resumo(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_piquetes_por_retiro(text, text, text[], integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_piquete_detalhe(text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_animais_disponiveis_piquete(text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_lotes_disponiveis_piquete(text, text) TO authenticated;
