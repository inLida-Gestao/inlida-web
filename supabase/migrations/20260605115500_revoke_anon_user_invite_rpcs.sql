REVOKE EXECUTE ON FUNCTION public.buscar_usuario_por_email(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.adicionar_usuario_propriedade_por_email(text, text) FROM anon;

REVOKE EXECUTE ON FUNCTION public.buscar_usuario_por_email(text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.adicionar_usuario_propriedade_por_email(text, text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.buscar_usuario_por_email(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.adicionar_usuario_propriedade_por_email(text, text) TO authenticated;
