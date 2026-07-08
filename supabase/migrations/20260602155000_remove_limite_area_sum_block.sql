-- Remove the remaining area-sum block when saving/reimporting the property limit.

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
  v_nome text;
BEGIN
  SELECT r.nome
  INTO v_nome
  FROM public.retiros r
  WHERE r.id_propriedade = p_id_propriedade
    AND r.deleted_at IS NULL
    AND COALESCE(r.status, 'ativo') = 'ativo'
    AND NOT extensions.ST_Intersects(r.geom, p_limite_geom)
  LIMIT 1;

  IF v_nome IS NOT NULL THEN
    RAISE EXCEPTION 'O retiro "%" precisa intersectar o limite da propriedade', v_nome;
  END IF;

  SELECT p.nome
  INTO v_nome
  FROM public.piquete p
  WHERE p.id_propriedade = p_id_propriedade
    AND p.retiro_id IS NULL
    AND p.geom IS NOT NULL
    AND p.deleted_at IS NULL
    AND COALESCE(p.status, 'ativo') = 'ativo'
    AND NOT extensions.ST_Intersects(p.geom, p_limite_geom)
  LIMIT 1;

  IF v_nome IS NOT NULL THEN
    RAISE EXCEPTION 'O piquete "%" precisa intersectar o limite da propriedade', v_nome;
  END IF;
END;
$$;
