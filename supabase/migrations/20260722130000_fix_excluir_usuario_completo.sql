CREATE OR REPLACE FUNCTION public.excluir_usuario_completo(p_user_id text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Usuário não autenticado';
  END IF;

  BEGIN
    v_user_id := p_user_id::uuid;
  EXCEPTION
    WHEN invalid_text_representation THEN
      RAISE EXCEPTION 'Identificador de usuário inválido';
  END;

  IF v_user_id <> auth.uid() THEN
    RAISE EXCEPTION 'Permissão negada';
  END IF;

  DELETE FROM public.users_propriedades
  WHERE user_id = v_user_id::text;

  DELETE FROM public.administradores
  WHERE user_id = v_user_id;

  DELETE FROM public.users
  WHERE "userID" = v_user_id;

  DELETE FROM auth.users
  WHERE id = v_user_id;

  RETURN FOUND;
END;
$$;

REVOKE ALL ON FUNCTION public.excluir_usuario_completo(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.excluir_usuario_completo(text) FROM anon;
GRANT EXECUTE ON FUNCTION public.excluir_usuario_completo(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.excluir_usuario_completo(text) TO service_role;