CREATE OR REPLACE FUNCTION public.buscar_usuario_por_email(p_email text)
RETURNS TABLE(
  "userID" text,
  nome text,
  email text,
  foto text,
  telefone text,
  excluido boolean,
  permissao text,
  funcao text
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    u."userID"::text,
    u.nome,
    u.email,
    u.foto,
    u.telefone,
    COALESCE(u.excluido, false) AS excluido,
    u.permissao,
    u.funcao
  FROM public.users u
  WHERE public.usuario_tem_plano_pago()
    AND p_email IS NOT NULL
    AND btrim(p_email) <> ''
    AND lower(btrim(u.email)) = lower(btrim(p_email))
    AND COALESCE(u.excluido, false) = false
  LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.buscar_usuario_por_email(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.buscar_usuario_por_email(text) TO authenticated;

CREATE OR REPLACE FUNCTION public.adicionar_usuario_propriedade_por_email(
  p_id_propriedade text,
  p_email text
)
RETURNS TABLE(
  status text,
  message text,
  "userID" text,
  nome text,
  email text,
  foto text,
  permissao text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user public.users%ROWTYPE;
BEGIN
  IF p_id_propriedade IS NULL OR btrim(p_id_propriedade) = '' THEN
    RETURN QUERY SELECT
      'id_propriedade_invalido'::text,
      'Propriedade inválida.'::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text;
    RETURN;
  END IF;

  IF p_email IS NULL OR btrim(p_email) = '' THEN
    RETURN QUERY SELECT
      'email_invalido'::text,
      'Informe um e-mail válido.'::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text;
    RETURN;
  END IF;

  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN QUERY SELECT
      'sem_acesso'::text,
      'Você não tem permissão para alterar esta propriedade.'::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text;
    RETURN;
  END IF;

  SELECT u.*
  INTO v_user
  FROM public.users u
  WHERE lower(btrim(u.email)) = lower(btrim(p_email))
    AND COALESCE(u.excluido, false) = false
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN QUERY SELECT
      'nao_encontrado'::text,
      'Usuário não encontrado ou e-mail digitado incorreto.'::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text;
    RETURN;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.users_propriedades up
    WHERE up."idPropriedade" = p_id_propriedade
      AND up.user_id = v_user."userID"::text
      AND COALESCE(up.deletado, 'NAO') = 'NAO'
  ) THEN
    RETURN QUERY SELECT
      'ja_adicionado'::text,
      'Este usuário já foi adicionado nesta propriedade.'::text,
      v_user."userID"::text,
      v_user.nome,
      v_user.email,
      v_user.foto,
      v_user.permissao;
    RETURN;
  END IF;

  INSERT INTO public.users_propriedades (
    user_id,
    nome,
    email,
    foto,
    permissao,
    "idPropriedade",
    deletado
  )
  VALUES (
    v_user."userID"::text,
    v_user.nome,
    v_user.email,
    v_user.foto,
    v_user.permissao,
    p_id_propriedade,
    'NAO'
  );

  RETURN QUERY SELECT
    'adicionado'::text,
    'Usuário adicionado na propriedade.'::text,
    v_user."userID"::text,
    v_user.nome,
    v_user.email,
    v_user.foto,
    v_user.permissao;
END;
$$;

REVOKE ALL ON FUNCTION public.adicionar_usuario_propriedade_por_email(text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.adicionar_usuario_propriedade_por_email(text, text) TO authenticated;
