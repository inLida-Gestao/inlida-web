-- Saving the property limit must not be blocked by existing retiros or piquetes.
-- The limit itself represents the property area and can be increased or reduced freely.

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
BEGIN
  RETURN;
END;
$$;
