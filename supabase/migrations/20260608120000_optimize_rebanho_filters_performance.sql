-- Otimiza buscas e filtros da tela de Rebanho.

CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;
SET search_path TO public, extensions;

CREATE INDEX IF NOT EXISTS idx_rebanho_active_property_created_at
  ON public.rebanho ("idPropriedade", created_at DESC)
  WHERE deletado = 'NAO';

CREATE INDEX IF NOT EXISTS idx_rebanho_active_property_filters
  ON public.rebanho ("idPropriedade", status, sexo, categoria, "dataNascimento", created_at DESC)
  WHERE deletado = 'NAO';

CREATE INDEX IF NOT EXISTS idx_rebanho_active_property_loteid
  ON public.rebanho ("idPropriedade", "loteID")
  WHERE deletado = 'NAO'
    AND "loteID" IS NOT NULL
    AND btrim("loteID") <> '';

CREATE INDEX IF NOT EXISTS idx_rebanho_numeroanimal_trgm_active
  ON public.rebanho USING gin ("numeroAnimal" gin_trgm_ops)
  WHERE deletado = 'NAO'
    AND "numeroAnimal" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_rebanho_nome_trgm_active
  ON public.rebanho USING gin (nome gin_trgm_ops)
  WHERE deletado = 'NAO'
    AND nome IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_rebanho_chip_trgm_active
  ON public.rebanho USING gin (chip gin_trgm_ops)
  WHERE deletado = 'NAO'
    AND chip IS NOT NULL;

CREATE OR REPLACE FUNCTION public.rebanho_propriedade_filtros(
  p_id_propriedade text,
  p_sexo text,
  p_status text,
  p_data_nascimento_de text,
  p_data_nascimento_ate text,
  p_lote_nome text,
  p_categoria text,
  p_raca text,
  p_origem text,
  p_pesquisa text,
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0
)
RETURNS SETOF public.rebanho
LANGUAGE plpgsql
STABLE
SET search_path TO 'public'
AS $$
DECLARE
  v_pesquisa text := NULLIF(btrim(COALESCE(p_pesquisa, '')), '');
  v_sexo text := NULLIF(btrim(COALESCE(p_sexo, '')), '');
  v_status text := NULLIF(btrim(COALESCE(p_status, '')), '');
  v_categoria text := NULLIF(btrim(COALESCE(p_categoria, '')), '');
  v_raca text := NULLIF(btrim(COALESCE(p_raca, '')), '');
  v_origem text := NULLIF(btrim(COALESCE(p_origem, '')), '');
  v_data_nascimento_de date := CASE
    WHEN COALESCE(btrim(p_data_nascimento_de), '') = '' THEN NULL
    ELSE p_data_nascimento_de::date
  END;
  v_data_nascimento_ate date := CASE
    WHEN COALESCE(btrim(p_data_nascimento_ate), '') = '' THEN NULL
    ELSE p_data_nascimento_ate::date
  END;
  v_lote_tokens text[] := ARRAY[]::text[];
BEGIN
  SELECT COALESCE(array_remove(array_agg(btrim(token)), ''), ARRAY[]::text[])
    INTO v_lote_tokens
  FROM unnest(string_to_array(COALESCE(p_lote_nome, ''), ',')) AS tokens(token);

  RETURN QUERY
  SELECT r.*
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r.deletado = 'NAO'
    AND (
      v_pesquisa IS NULL
      OR r."numeroAnimal" ILIKE '%' || v_pesquisa || '%'
      OR r.nome ILIKE '%' || v_pesquisa || '%'
      OR r.chip ILIKE '%' || v_pesquisa || '%'
    )
    AND (v_sexo IS NULL OR r.sexo = v_sexo)
    AND (v_status IS NULL OR r.status = v_status)
    AND (v_data_nascimento_de IS NULL OR r."dataNascimento" >= v_data_nascimento_de)
    AND (v_data_nascimento_ate IS NULL OR r."dataNascimento" <= v_data_nascimento_ate)
    AND (
      cardinality(v_lote_tokens) = 0
      OR (
        'SEM_LOTE' = ANY(v_lote_tokens)
        AND COALESCE(r."loteNome", '') = ''
        AND COALESCE(r."loteID", '') = ''
      )
      OR r."loteID" = ANY(v_lote_tokens)
      OR r."loteNome" = ANY(v_lote_tokens)
    )
    AND (v_categoria IS NULL OR r.categoria = v_categoria)
    AND (v_raca IS NULL OR r.raca = v_raca)
    AND (v_origem IS NULL OR r.origem = v_origem)
  ORDER BY r.created_at DESC
  LIMIT COALESCE(p_limite, 1000)
  OFFSET COALESCE(p_offset, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION public.rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text,integer,integer)
  TO anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public.contar_rebanho_propriedade_filtros(
  p_id_propriedade text,
  p_sexo text,
  p_status text,
  p_data_nascimento_de text,
  p_data_nascimento_ate text,
  p_lote_id text,
  p_categoria text,
  p_raca text,
  p_origem text,
  p_pesquisa text
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  total integer;
  v_pesquisa text := NULLIF(btrim(COALESCE(p_pesquisa, '')), '');
  v_sexo text := NULLIF(btrim(COALESCE(p_sexo, '')), '');
  v_status text := NULLIF(btrim(COALESCE(p_status, '')), '');
  v_categoria text := NULLIF(btrim(COALESCE(p_categoria, '')), '');
  v_raca text := NULLIF(btrim(COALESCE(p_raca, '')), '');
  v_origem text := NULLIF(btrim(COALESCE(p_origem, '')), '');
  v_data_nascimento_de date := CASE
    WHEN COALESCE(btrim(p_data_nascimento_de), '') = '' THEN NULL
    ELSE p_data_nascimento_de::date
  END;
  v_data_nascimento_ate date := CASE
    WHEN COALESCE(btrim(p_data_nascimento_ate), '') = '' THEN NULL
    ELSE p_data_nascimento_ate::date
  END;
  v_lote_tokens text[] := ARRAY[]::text[];
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN 0;
  END IF;

  SELECT COALESCE(array_remove(array_agg(btrim(token)), ''), ARRAY[]::text[])
    INTO v_lote_tokens
  FROM unnest(string_to_array(COALESCE(p_lote_id, ''), ',')) AS tokens(token);

  SELECT COUNT(*)::integer
    INTO total
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r.deletado = 'NAO'
    AND (
      v_pesquisa IS NULL
      OR r."numeroAnimal" ILIKE '%' || v_pesquisa || '%'
      OR r.nome ILIKE '%' || v_pesquisa || '%'
      OR r.chip ILIKE '%' || v_pesquisa || '%'
    )
    AND (v_sexo IS NULL OR r.sexo = v_sexo)
    AND (v_status IS NULL OR r.status = v_status)
    AND (v_data_nascimento_de IS NULL OR r."dataNascimento" >= v_data_nascimento_de)
    AND (v_data_nascimento_ate IS NULL OR r."dataNascimento" <= v_data_nascimento_ate)
    AND (
      cardinality(v_lote_tokens) = 0
      OR (
        'SEM_LOTE' = ANY(v_lote_tokens)
        AND COALESCE(r."loteNome", '') = ''
        AND COALESCE(r."loteID", '') = ''
      )
      OR r."loteID" = ANY(v_lote_tokens)
      OR r."loteNome" = ANY(v_lote_tokens)
    )
    AND (v_categoria IS NULL OR r.categoria = v_categoria)
    AND (v_raca IS NULL OR r.raca = v_raca)
    AND (v_origem IS NULL OR r.origem = v_origem);

  RETURN COALESCE(total, 0);
END;
$$;

REVOKE ALL ON FUNCTION public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text)
  TO authenticated, service_role;
