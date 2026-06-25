-- Recreate piquete selector RPCs with a single canonical signature.
-- This resolves PostgREST ambiguity when legacy overloads still exist.

DROP FUNCTION IF EXISTS public.buscar_animais_disponiveis_piquete(text, text);
DROP FUNCTION IF EXISTS public.buscar_animais_disponiveis_piquete(text, text, text, integer, integer);
DROP FUNCTION IF EXISTS public.buscar_lotes_disponiveis_piquete(text, text);
DROP FUNCTION IF EXISTS public.buscar_lotes_disponiveis_piquete(text, text, text, integer, integer);

CREATE OR REPLACE FUNCTION public.buscar_animais_disponiveis_piquete(
  p_id_propriedade text DEFAULT '',
  p_piquete_id text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_limite integer DEFAULT 50,
  p_offset integer DEFAULT 0,
  p_status text DEFAULT '',
  p_sexo text DEFAULT '',
  p_categoria text DEFAULT '',
  p_raca text DEFAULT '',
  p_origem text DEFAULT '',
  p_lote text DEFAULT '',
  p_data_nascimento_de text DEFAULT '',
  p_data_nascimento_ate text DEFAULT ''
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
  v_sexo text := lower(btrim(COALESCE(p_sexo, '')));
  v_categoria text := lower(btrim(COALESCE(p_categoria, '')));
  v_raca text := lower(btrim(COALESCE(p_raca, '')));
  v_origem text := lower(btrim(COALESCE(p_origem, '')));
  v_lote text := lower(btrim(COALESCE(p_lote, '')));
  v_data_nascimento_de date := CASE
    WHEN btrim(COALESCE(p_data_nascimento_de, '')) = '' THEN NULL
    ELSE p_data_nascimento_de::date
  END;
  v_data_nascimento_ate date := CASE
    WHEN btrim(COALESCE(p_data_nascimento_ate, '')) = '' THEN NULL
    ELSE p_data_nascimento_ate::date
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

  SELECT COALESCE(jsonb_agg(item ORDER BY numero, nome, id), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT
      COALESCE(r."numeroAnimal", '') AS numero,
      COALESCE(r.nome, '') AS nome,
      r."idRebanho" AS id,
      jsonb_build_object(
        'id', r."idRebanho",
        'numero', COALESCE(r."numeroAnimal", ''),
        'nome', COALESCE(r.nome, ''),
        'sexo', COALESCE(r.sexo, ''),
        'categoria', COALESCE(r.categoria, ''),
        'raca', COALESCE(r.raca, ''),
        'data_nascimento', r."dataNascimento",
        'lote_nome', COALESCE(r."loteNome", ''),
        'lote_id', COALESCE(r."loteID", ''),
        'status', COALESCE(r.status, '')
      ) AS item
    FROM public.rebanho r
    WHERE r."idPropriedade" = p_id_propriedade
      AND r."idRebanho" IS NOT NULL
      AND COALESCE(r.deletado, 'NAO') = 'NAO'
      AND (
        lower(btrim(COALESCE(r.status, ''))) = lower('Na propriedade')
        OR EXISTS (
          SELECT 1
          FROM public.piquete_animais pa_atual
          WHERE pa_atual.id_propriedade = p_id_propriedade
            AND pa_atual.id_rebanho = r."idRebanho"
            AND pa_atual.status = 'ativo'
            AND v_piquete_db_id IS NOT NULL
            AND pa_atual.piquete_id = v_piquete_db_id
        )
      )
      AND (
        v_query = ''
        OR lower(COALESCE(r."numeroAnimal", '')) LIKE '%' || v_query || '%'
        OR lower(COALESCE(r.nome, '')) LIKE '%' || v_query || '%'
        OR lower(COALESCE(r.categoria, '')) LIKE '%' || v_query || '%'
        OR lower(COALESCE(r."loteNome", '')) LIKE '%' || v_query || '%'
      )
      AND (v_status = '' OR lower(btrim(COALESCE(r.status, ''))) = v_status)
      AND (v_sexo = '' OR lower(btrim(COALESCE(r.sexo, ''))) = v_sexo)
      AND (v_categoria = '' OR lower(btrim(COALESCE(r.categoria, ''))) = v_categoria)
      AND (v_raca = '' OR lower(btrim(COALESCE(r.raca, ''))) = v_raca)
      AND (v_origem = '' OR lower(btrim(COALESCE(r.origem, ''))) = v_origem)
      AND (
        v_lote = ''
        OR lower(btrim(COALESCE(r."loteID", ''))) = v_lote
        OR lower(COALESCE(r."loteNome", '')) LIKE '%' || v_lote || '%'
      )
      AND (v_data_nascimento_de IS NULL OR r."dataNascimento"::date >= v_data_nascimento_de)
      AND (v_data_nascimento_ate IS NULL OR r."dataNascimento"::date <= v_data_nascimento_ate)
      AND NOT EXISTS (
        SELECT 1
        FROM public.piquete_animais pa
        WHERE pa.id_propriedade = p_id_propriedade
          AND pa.id_rebanho = r."idRebanho"
          AND pa.status = 'ativo'
          AND (v_piquete_db_id IS NULL OR pa.piquete_id <> v_piquete_db_id)
      )
    ORDER BY COALESCE(r."numeroAnimal", ''), COALESCE(r.nome, ''), r."idRebanho"
    LIMIT v_limite
    OFFSET v_offset
  ) s;

  RETURN v_result;
END;
$$;

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
            AND lower(btrim(COALESCE(r.status, ''))) = lower('Na propriedade')
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

GRANT EXECUTE ON FUNCTION public.buscar_animais_disponiveis_piquete(text, text, text, integer, integer, text, text, text, text, text, text, text, text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_lotes_disponiveis_piquete(text, text, text, integer, integer, text, text, text) TO authenticated;

NOTIFY pgrst, 'reload schema';
