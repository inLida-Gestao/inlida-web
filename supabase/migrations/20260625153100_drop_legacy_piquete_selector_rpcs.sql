-- Remove legacy selector overloads so PostgREST can resolve the paginated RPCs
-- with filter parameters unambiguously.

DROP FUNCTION IF EXISTS public.buscar_animais_disponiveis_piquete(text, text);
DROP FUNCTION IF EXISTS public.buscar_lotes_disponiveis_piquete(text, text);
