-- Show the sum of linked piquete areas when a retiro has no area of its own.

CREATE OR REPLACE FUNCTION public.retiro_to_json(p_retiro public.retiros)
RETURNS jsonb
LANGUAGE sql
STABLE
SET search_path = public, extensions
AS $$
  SELECT jsonb_build_object(
    'id', p_retiro.id::text,
    'id_retiro', p_retiro.id_retiro,
    'id_propriedade', p_retiro.id_propriedade,
    'nome', p_retiro.nome,
    'area_informada_ha', p_retiro.area_informada_ha,
    'area_calculada_ha', p_retiro.area_calculada_ha,
    'area_ha', COALESCE(
      p_retiro.area_calculada_ha,
      NULLIF(p_retiro.area_informada_ha, 0),
      (
        SELECT COALESCE(SUM(COALESCE(p.area_calculada_ha, p.area, 0)), 0)
        FROM public.piquete p
        WHERE p.retiro_id = p_retiro.id
          AND p.deleted_at IS NULL
          AND COALESCE(p.status, 'ativo') = 'ativo'
      ),
      0
    ),
    'anotacoes', COALESCE(p_retiro.anotacoes, ''),
    'geojson', public.piquete_geojson_json(p_retiro.geom),
    'centro', public.piquete_center_json(p_retiro.geom),
    'bounds', COALESCE(p_retiro.bounds, public.piquete_bounds_json(p_retiro.geom)),
    'status', p_retiro.status,
    'created_at', p_retiro.created_at
  );
$$;
