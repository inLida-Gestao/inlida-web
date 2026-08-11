-- Filtro por data da ultima pesagem no modulo Rebanho.
--
-- Adiciona p_data_pesagem_de / p_data_pesagem_ate as RPCs de listagem e contagem
-- do rebanho, filtrando por rebanho."dataUltimaPesagem".
-- Os parametros tem DEFAULT '' para nao quebrar as chamadas existentes
-- (pg_lotes, sanidade, popup de rebanhos) que nao enviam os novos campos.

DROP FUNCTION IF EXISTS public.rebanho_propriedade_filtros(
  text,text,text,text,text,text,text,text,text,text,integer,integer);
DROP FUNCTION IF EXISTS public.rebanho_propriedade_filtros(
  text,text,text,text,text,text,text,text,text,text,integer,integer,text,boolean);

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
  p_offset integer DEFAULT 0,
  p_ordenar text DEFAULT '',
  p_asc boolean DEFAULT true,
  p_data_pesagem_de text DEFAULT '',
  p_data_pesagem_ate text DEFAULT ''
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
  v_ord text := lower(btrim(COALESCE(p_ordenar, '')));
  v_asc boolean := COALESCE(p_asc, true);
  v_data_nascimento_de date := CASE
    WHEN COALESCE(btrim(p_data_nascimento_de), '') = '' THEN NULL
    ELSE p_data_nascimento_de::date
  END;
  v_data_nascimento_ate date := CASE
    WHEN COALESCE(btrim(p_data_nascimento_ate), '') = '' THEN NULL
    ELSE p_data_nascimento_ate::date
  END;
  v_data_pesagem_de date := CASE
    WHEN COALESCE(btrim(p_data_pesagem_de), '') = '' THEN NULL
    ELSE p_data_pesagem_de::date
  END;
  v_data_pesagem_ate date := CASE
    WHEN COALESCE(btrim(p_data_pesagem_ate), '') = '' THEN NULL
    ELSE p_data_pesagem_ate::date
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
    AND (v_data_pesagem_de IS NULL
         OR (r."dataUltimaPesagem" IS NOT NULL
             AND r."dataUltimaPesagem"::date >= v_data_pesagem_de))
    AND (v_data_pesagem_ate IS NULL
         OR (r."dataUltimaPesagem" IS NOT NULL
             AND r."dataUltimaPesagem"::date <= v_data_pesagem_ate))
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
  ORDER BY
    -- Número (ordenação natural: 1º grupo de dígitos, depois texto)
    CASE WHEN v_ord = 'numero' AND v_asc
         THEN substring(r."numeroAnimal" from '[0-9]+')::numeric END ASC NULLS LAST,
    CASE WHEN v_ord = 'numero' AND v_asc
         THEN lower(btrim(COALESCE(r."numeroAnimal", ''))) END ASC NULLS LAST,
    CASE WHEN v_ord = 'numero' AND NOT v_asc
         THEN substring(r."numeroAnimal" from '[0-9]+')::numeric END DESC NULLS LAST,
    CASE WHEN v_ord = 'numero' AND NOT v_asc
         THEN lower(btrim(COALESCE(r."numeroAnimal", ''))) END DESC NULLS LAST,
    -- Nascimento (desempate pelo número, mesma direção)
    CASE WHEN v_ord = 'nascimento' AND v_asc
         THEN r."dataNascimento" END ASC NULLS LAST,
    CASE WHEN v_ord = 'nascimento' AND v_asc
         THEN substring(r."numeroAnimal" from '[0-9]+')::numeric END ASC NULLS LAST,
    CASE WHEN v_ord = 'nascimento' AND NOT v_asc
         THEN r."dataNascimento" END DESC NULLS LAST,
    CASE WHEN v_ord = 'nascimento' AND NOT v_asc
         THEN substring(r."numeroAnimal" from '[0-9]+')::numeric END DESC NULLS LAST,
    -- Padrão / desempate final estável
    r.created_at DESC
  LIMIT COALESCE(p_limite, 1000)
  OFFSET COALESCE(p_offset, 0);
END;
$$;

GRANT EXECUTE ON FUNCTION public.rebanho_propriedade_filtros(
  text,text,text,text,text,text,text,text,text,text,integer,integer,text,boolean,text,text)
  TO anon, authenticated, service_role;

DROP FUNCTION IF EXISTS public.contar_rebanho_propriedade_filtros(
  text,text,text,text,text,text,text,text,text,text);

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
  p_pesquisa text,
  p_data_pesagem_de text DEFAULT '',
  p_data_pesagem_ate text DEFAULT ''
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
  v_data_pesagem_de date := CASE
    WHEN COALESCE(btrim(p_data_pesagem_de), '') = '' THEN NULL
    ELSE p_data_pesagem_de::date
  END;
  v_data_pesagem_ate date := CASE
    WHEN COALESCE(btrim(p_data_pesagem_ate), '') = '' THEN NULL
    ELSE p_data_pesagem_ate::date
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
    AND (v_data_pesagem_de IS NULL
         OR (r."dataUltimaPesagem" IS NOT NULL
             AND r."dataUltimaPesagem"::date >= v_data_pesagem_de))
    AND (v_data_pesagem_ate IS NULL
         OR (r."dataUltimaPesagem" IS NOT NULL
             AND r."dataUltimaPesagem"::date <= v_data_pesagem_ate))
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

REVOKE ALL ON FUNCTION public.contar_rebanho_propriedade_filtros(
  text,text,text,text,text,text,text,text,text,text,text,text)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_propriedade_filtros(
  text,text,text,text,text,text,text,text,text,text,text,text)
  TO authenticated, service_role;

CREATE INDEX IF NOT EXISTS idx_rebanho_propriedade_data_ultima_pesagem
  ON public.rebanho ("idPropriedade", "dataUltimaPesagem")
  WHERE deletado = 'NAO';

NOTIFY pgrst, 'reload schema';
