-- Lote counts in piquete screens must include every non-deleted animal in the lote,
-- even when the animal status is not "Na propriedade" (for example, "Vendido").

CREATE OR REPLACE FUNCTION public.buscar_lotes_disponiveis_piquete(
  p_id_propriedade text DEFAULT '',
  p_piquete_id text DEFAULT '',
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
  v_piquete_db_id integer;
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

  IF NULLIF(btrim(COALESCE(p_piquete_id, '')), '') IS NOT NULL THEN
    SELECT p.id
    INTO v_piquete_db_id
    FROM public.piquete p
    WHERE p.id_propriedade = p_id_propriedade
      AND (p.id::text = p_piquete_id OR p.id_piquete = p_piquete_id)
    LIMIT 1;
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
        lower(btrim(COALESCE(NULLIF(l.ativo, ''), 'Ativo'))) = lower('Ativo')
        OR EXISTS (
          SELECT 1
          FROM public.piquete_lotes pl_atual
          WHERE pl_atual.id_propriedade = p_id_propriedade
            AND pl_atual.id_lote = l.id_lote
            AND pl_atual.status = 'ativo'
            AND v_piquete_db_id IS NOT NULL
            AND pl_atual.piquete_id = v_piquete_db_id
        )
      )
      AND (
        v_query = ''
        OR lower(COALESCE(l.nome, '')) LIKE '%' || v_query || '%'
        OR lower(COALESCE(l.id_lote, '')) LIKE '%' || v_query || '%'
      )
      AND (v_status = '' OR lower(btrim(COALESCE(NULLIF(l.ativo, ''), 'Ativo'))) = v_status)
      AND (v_data_criacao_de IS NULL OR l.created_at::date >= v_data_criacao_de)
      AND (v_data_criacao_ate IS NULL OR l.created_at::date <= v_data_criacao_ate)
      AND NOT EXISTS (
        SELECT 1
        FROM public.piquete_lotes pl
        WHERE pl.id_propriedade = p_id_propriedade
          AND pl.id_lote = l.id_lote
          AND pl.status = 'ativo'
          AND (v_piquete_db_id IS NULL OR pl.piquete_id <> v_piquete_db_id)
      )
    ORDER BY COALESCE(l.nome, ''), l.id_lote
    LIMIT v_limite
    OFFSET v_offset
  ) s;

  RETURN v_result;
END;
$$;

CREATE OR REPLACE FUNCTION public.buscar_lotes_piquete_por_ids(
  p_id_propriedade text DEFAULT '',
  p_lotes_ids text[] DEFAULT ARRAY[]::text[]
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
  v_ids text[] := COALESCE(p_lotes_ids, ARRAY[]::text[]);
  v_result jsonb;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RAISE EXCEPTION 'Usuario sem acesso a propriedade';
  END IF;

  IF cardinality(v_ids) = 0 THEN
    RETURN '[]'::jsonb;
  END IF;

  SELECT COALESCE(jsonb_agg(item ORDER BY sort_index, nome, id), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT
      array_position(v_ids, l.id_lote) AS sort_index,
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
      AND l.id_lote = ANY(v_ids)
      AND COALESCE(l.deletado, 'NAO') = 'NAO'
  ) s;

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION public.buscar_lotes_disponiveis_piquete(text, text, text, integer, integer, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_lotes_piquete_por_ids(text, text[]) TO authenticated;
