-- SECURITY DEFINER dashboard RPCs must only run with an authenticated user JWT.

REVOKE ALL ON FUNCTION public.contar_rebanho_ativo(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.contar_rebanho_fora(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.contar_rebanho_prop(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.obter_rebanho_ativo_por_propriedade(text,integer,integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_rebanho_available_years(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_rebanho_stats_by_categoria(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_rebanho_stats_by_gender_monthly(text,integer,integer,integer,integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calculate_mortality_rate(text,integer,integer,integer,integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calculate_weaning_percentage(text,integer,integer,integer,integer) FROM PUBLIC, anon;

REVOKE ALL ON FUNCTION public.calcular_taxa_prenhez(text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calcular_taxa_natalidade(text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calcular_taxa_prenhez2(text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calculate_media_primeira_cria(text,date,date) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.contar_rebanho_ativo(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_fora(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_prop(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.obter_rebanho_ativo_por_propriedade(text,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_rebanho_available_years(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_rebanho_stats_by_categoria(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_rebanho_stats_by_gender_monthly(text,integer,integer,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_mortality_rate(text,integer,integer,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_weaning_percentage(text,integer,integer,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez(text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calcular_taxa_natalidade(text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez2(text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_media_primeira_cria(text,date,date) TO authenticated, service_role;
