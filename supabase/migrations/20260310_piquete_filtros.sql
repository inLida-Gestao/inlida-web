-- =============================================================================
-- Migration: Módulo Piquete
-- Cria tabela forrageiras e funções RPC para filtros de piquete
-- =============================================================================

-- 1) Tabela de forrageiras (busca dinâmica)
CREATE TABLE IF NOT EXISTS public.forrageiras (
  id serial PRIMARY KEY,
  nome text NOT NULL UNIQUE
);

-- Inserir forrageiras iniciais
INSERT INTO public.forrageiras (nome) VALUES
  ('Andropogon gayanus'),
  ('Brachiaria brizantha'),
  ('Brachiaria decumbens'),
  ('Brachiaria humidicola'),
  ('Brachiaria ruziensis'),
  ('Capim Buffel'),
  ('Capim Coastcross'),
  ('Capim Elefante (Napier)'),
  ('Capim Tifton 85'),
  ('Cynodon (Bermuda)'),
  ('Estrela Africana'),
  ('Massai (Panicum maximum)'),
  ('Mombaça (Panicum maximum)'),
  ('Paiaguás (Urochloa brizantha)'),
  ('Pensacola'),
  ('Pioneiro (Brachiaria hybrid)'),
  ('Sorgo Forrageiro'),
  ('Tanzânia (Panicum maximum)'),
  ('Tobiatã (Panicum maximum)'),
  ('Toro (Brachiaria hybrid)'),
  ('Xaraés (Brachiaria brizantha)'),
  ('Outras')
ON CONFLICT (nome) DO NOTHING;

-- 2) Função de listagem de piquetes (com filtros e paginação)
-- SECURITY DEFINER: chamada com anon key pelo app; bypass de RLS com filtro por id_propriedade
CREATE OR REPLACE FUNCTION public.buscar_piquetes_filtros(
  p_id_propriedade text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_forrageira text DEFAULT '',
  p_area_min numeric DEFAULT 0,
  p_area_max numeric DEFAULT 9999,
  p_limite integer DEFAULT 20,
  p_offset integer DEFAULT 0
)
RETURNS SETOF public.piquete
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT p.*
  FROM public.piquete p
  WHERE
    (p_id_propriedade = '' OR p.id_propriedade = p_id_propriedade)
    AND (p_pesquisa = '' OR p.nome ILIKE '%' || p_pesquisa || '%')
    AND (p_forrageira = '' OR p_forrageira = ANY(p.forrageria))
    AND (p.area IS NULL OR p_area_min = 0 OR p.area >= p_area_min)
    AND (p.area IS NULL OR p_area_max = 9999 OR p.area <= p_area_max)
  ORDER BY p.nome ASC
  LIMIT NULLIF(p_limite, 0)
  OFFSET p_offset;
END;
$$;

-- 3) Função de contagem de piquetes (mesmos filtros)
-- SECURITY DEFINER: mesma razão da função acima
CREATE OR REPLACE FUNCTION public.contar_piquetes_filtros(
  p_id_propriedade text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_forrageira text DEFAULT '',
  p_area_min numeric DEFAULT 0,
  p_area_max numeric DEFAULT 9999
)
RETURNS bigint
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
  total bigint;
BEGIN
  SELECT COUNT(*) INTO total
  FROM public.piquete p
  WHERE
    (p_id_propriedade = '' OR p.id_propriedade = p_id_propriedade)
    AND (p_pesquisa = '' OR p.nome ILIKE '%' || p_pesquisa || '%')
    AND (p_forrageira = '' OR p_forrageira = ANY(p.forrageria))
    AND (p.area IS NULL OR p_area_min = 0 OR p.area >= p_area_min)
    AND (p.area IS NULL OR p_area_max = 9999 OR p.area <= p_area_max);
  RETURN total;
END;
$$;

-- 4) Permissões
GRANT SELECT ON public.forrageiras TO anon;
GRANT SELECT ON public.forrageiras TO authenticated;
GRANT EXECUTE ON FUNCTION public.buscar_piquetes_filtros TO anon;
GRANT EXECUTE ON FUNCTION public.buscar_piquetes_filtros TO authenticated;
GRANT EXECUTE ON FUNCTION public.contar_piquetes_filtros TO anon;
GRANT EXECUTE ON FUNCTION public.contar_piquetes_filtros TO authenticated;
