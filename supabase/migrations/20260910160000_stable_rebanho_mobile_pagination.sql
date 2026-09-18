-- Evita registros repetidos ou ausentes ao paginar o pull incremental.
-- Muitos animais podem compartilhar exatamente o mesmo updated_at após uma
-- operação em lote. Sem um desempate único, LIMIT/OFFSET pode devolver o mesmo
-- animal em páginas diferentes e omitir outro.

CREATE INDEX IF NOT EXISTS idx_rebanho_mobile_sync_order
  ON public.rebanho ("idPropriedade", updated_at DESC, id ASC);

CREATE OR REPLACE FUNCTION public.rebanho_propriedade_mobile_inc(
  p_id_propriedade TEXT[],
  p_limite INT DEFAULT 999,
  p_offset INT DEFAULT 0,
  p_updated_after TIMESTAMPTZ DEFAULT '1970-01-01T00:00:00Z'
)
RETURNS SETOF public.rebanho
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT r.*
  FROM public.rebanho r
  WHERE r."idPropriedade" = ANY(p_id_propriedade)
    AND r.updated_at > p_updated_after
  ORDER BY r.updated_at DESC, r.id ASC
  LIMIT p_limite
  OFFSET p_offset;
$$;

GRANT EXECUTE ON FUNCTION public.rebanho_propriedade_mobile_inc(
  TEXT[], INT, INT, TIMESTAMPTZ
) TO anon, authenticated, service_role;
