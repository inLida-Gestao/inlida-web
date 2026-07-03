-- The movement modal must list every lote in the property and allow moving
-- lotes between piquetes/retiros from that modal.

CREATE OR REPLACE FUNCTION public.buscar_todos_lotes_piquete(
  p_id_propriedade text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_limite integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_status text DEFAULT '',
  p_data_criacao_de text DEFAULT '',
  p_data_criacao_ate text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_result jsonb;
  v_query text := lower(btrim(COALESCE(p_pesquisa, '')));
  v_limite integer := LEAST(GREATEST(COALESCE(p_limite, 50), 1), 200);
  v_offset integer := GREATEST(COALESCE(p_offset, 0), 0);
  v_status text := lower(btrim(COALESCE(p_status, '')));
  v_data_criacao_de date := CASE
    WHEN btrim(COALESCE(p_data_criacao_de, '')) = '' THEN NULL
    ELSE p_data_criacao_de::date
  END;
  v_data_criacao_ate date := CASE
    WHEN btrim(COALESCE(p_data_criacao_ate, '')) = '' THEN NULL
    ELSE p_data_criacao_ate::date
  END;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT COALESCE(jsonb_agg(item ORDER BY nome, id), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT
      COALESCE(l.nome, '') AS nome,
      l.id_lote AS id,
      jsonb_build_object(
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
      AND (
        v_query = ''
        OR lower(COALESCE(l.nome, '')) LIKE '%' || v_query || '%'
        OR lower(COALESCE(l.id_lote, '')) LIKE '%' || v_query || '%'
      )
      AND (v_status = '' OR lower(btrim(COALESCE(NULLIF(l.ativo, ''), 'Ativo'))) = v_status)
      AND (v_data_criacao_de IS NULL OR l.created_at::date >= v_data_criacao_de)
      AND (v_data_criacao_ate IS NULL OR l.created_at::date <= v_data_criacao_ate)
    ORDER BY COALESCE(l.nome, ''), l.id_lote
    LIMIT v_limite
    OFFSET v_offset
  ) s;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.mover_lotes_para_piquete(
  p_id_propriedade text DEFAULT '',
  p_piquete_id text DEFAULT '',
  p_lotes_ids text[] DEFAULT ARRAY[]::text[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_piquete_db_id integer;
  v_piquete public.piquete%ROWTYPE;
  v_lotes text[];
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  SELECT p.id
  INTO v_piquete_db_id
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND p.deleted_at IS NULL
    AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
  LIMIT 1;

  IF v_piquete_db_id IS NULL THEN
    RAISE EXCEPTION 'Piquete nao encontrado';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT valor ORDER BY valor), ARRAY[]::text[])
  INTO v_lotes
  FROM (
    SELECT btrim(item) AS valor
    FROM unnest(COALESCE(p_lotes_ids, ARRAY[]::text[])) AS item
    WHERE btrim(item) <> ''
  ) t;

  IF COALESCE(array_length(v_lotes, 1), 0) = 0 THEN
    SELECT *
    INTO v_piquete
    FROM public.piquete p
    WHERE p.id = v_piquete_db_id;
    RETURN public.piquete_to_json(v_piquete);
  END IF;

  UPDATE public.piquete_lotes
  SET status = 'inativo',
      data_saida = COALESCE(data_saida, now()),
      updated_at = now()
  WHERE id_propriedade = p_id_propriedade
    AND id_lote = ANY(v_lotes)
    AND status = 'ativo'
    AND piquete_id <> v_piquete_db_id;

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

GRANT EXECUTE ON FUNCTION public.buscar_todos_lotes_piquete(text, text, integer, integer, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mover_lotes_para_piquete(text, text, text[]) TO authenticated;
