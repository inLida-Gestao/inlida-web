-- Corrige chamadas de triggers que resolvem piquete.id como bigint/text em
-- bancos onde a tabela public.piquete ja existia antes do modulo de retiros.

CREATE OR REPLACE FUNCTION public.piquete_registrar_movimentacao(
  p_id_propriedade text,
  p_retiro_id uuid,
  p_piquete_id integer,
  p_tipo text,
  p_entidade_tipo text DEFAULT NULL,
  p_entidade_id text DEFAULT NULL,
  p_descricao text DEFAULT '',
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  IF p_id_propriedade IS NULL
     OR btrim(p_id_propriedade) = ''
     OR p_tipo IS NULL
     OR btrim(p_tipo) = '' THEN
    RAISE EXCEPTION 'Dados invalidos para registrar historico do piquete';
  END IF;

  INSERT INTO public.piquete_movimentacoes (
    id_propriedade,
    retiro_id,
    piquete_id,
    tipo,
    entidade_tipo,
    entidade_id,
    descricao,
    metadata
  )
  VALUES (
    p_id_propriedade,
    p_retiro_id,
    p_piquete_id,
    p_tipo,
    p_entidade_tipo,
    p_entidade_id,
    NULLIF(btrim(COALESCE(p_descricao, '')), ''),
    COALESCE(p_metadata, '{}'::jsonb)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_registrar_movimentacao(
  p_id_propriedade text,
  p_retiro_id uuid,
  p_piquete_id bigint,
  p_tipo text,
  p_entidade_tipo text,
  p_entidade_id text,
  p_descricao text,
  p_metadata jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  PERFORM public.piquete_registrar_movimentacao(
    p_id_propriedade,
    p_retiro_id,
    p_piquete_id::integer,
    p_tipo,
    p_entidade_tipo,
    p_entidade_id,
    p_descricao,
    p_metadata
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_registrar_movimentacao(
  p_id_propriedade text,
  p_retiro_id text,
  p_piquete_id integer,
  p_tipo text,
  p_entidade_tipo text,
  p_entidade_id text,
  p_descricao text,
  p_metadata jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  PERFORM public.piquete_registrar_movimentacao(
    p_id_propriedade,
    NULLIF(btrim(COALESCE(p_retiro_id, '')), '')::uuid,
    p_piquete_id,
    p_tipo,
    p_entidade_tipo,
    p_entidade_id,
    p_descricao,
    p_metadata
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.piquete_registrar_movimentacao(
  p_id_propriedade text,
  p_retiro_id text,
  p_piquete_id bigint,
  p_tipo text,
  p_entidade_tipo text,
  p_entidade_id text,
  p_descricao text,
  p_metadata jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
BEGIN
  PERFORM public.piquete_registrar_movimentacao(
    p_id_propriedade,
    NULLIF(btrim(COALESCE(p_retiro_id, '')), '')::uuid,
    p_piquete_id::integer,
    p_tipo,
    p_entidade_tipo,
    p_entidade_id,
    p_descricao,
    p_metadata
  );
END;
$$;

REVOKE ALL ON FUNCTION public.piquete_registrar_movimentacao(text, uuid, integer, text, text, text, text, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.piquete_registrar_movimentacao(text, uuid, bigint, text, text, text, text, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.piquete_registrar_movimentacao(text, text, integer, text, text, text, text, jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.piquete_registrar_movimentacao(text, text, bigint, text, text, text, text, jsonb) FROM PUBLIC;
