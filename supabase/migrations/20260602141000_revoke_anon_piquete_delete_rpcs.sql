-- Keep destructive piquete RPCs available only to authenticated sessions.

REVOKE ALL ON FUNCTION public.excluir_limite_propriedade(text, text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.excluir_retiro(text, text) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.excluir_limite_propriedade(text, text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.excluir_retiro(text, text) TO authenticated, service_role;
