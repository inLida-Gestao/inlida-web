-- Permite criar e listar piquetes sem vinculo obrigatorio com retiro.

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
  v_retiro_id uuid;
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

  IF NULLIF(btrim(COALESCE(p_retiro_id, '')), '') IS NOT NULL THEN
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

    v_retiro_id := v_retiro.id;
  END IF;

  v_geom := public.piquete_geojson_to_polygon(p_geojson);
  v_area := public.piquete_area_ha(v_geom);

  IF v_retiro_id IS NOT NULL
     AND NOT extensions.ST_CoveredBy(v_geom, v_retiro.geom) THEN
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
      v_retiro_id,
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
      v_retiro_id,
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
        retiro_id = v_retiro_id,
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
      v_retiro_id,
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

CREATE OR REPLACE FUNCTION public.listar_piquetes_sem_retiro(
  p_id_propriedade text DEFAULT '',
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
  v_result jsonb;
  v_query text;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  v_query := lower(btrim(COALESCE(p_pesquisa, '')));

  SELECT COALESCE(jsonb_agg(public.piquete_to_json(filtered.p) ORDER BY (filtered.p).nome), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT p
    FROM public.piquete p
    WHERE p.id_propriedade = p_id_propriedade
      AND p.retiro_id IS NULL
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

GRANT EXECUTE ON FUNCTION public.salvar_piquete(text, text, text, text, numeric, text[], text, jsonb, text[], text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.listar_piquetes_sem_retiro(text, text, text[], integer, integer) TO authenticated;
