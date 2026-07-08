-- Close residual PUBLIC execute grants on dashboard SECURITY DEFINER RPCs.

REVOKE ALL ON FUNCTION public.calcular_taxa_prenhez(text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calcular_taxa_natalidade(text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calcular_taxa_prenhez2(text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calculate_media_primeira_cria(text,date,date) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez(text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calcular_taxa_natalidade(text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez2(text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_media_primeira_cria(text,date,date) TO authenticated, service_role;
