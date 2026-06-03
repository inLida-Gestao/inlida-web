CREATE OR REPLACE FUNCTION public.sync_auth_user_to_public_users()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_nome text := NULLIF(NEW.raw_user_meta_data ->> 'nome', '');
  v_telefone text := NULLIF(NEW.raw_user_meta_data ->> 'telefone', '');
  v_funcao text := NULLIF(NEW.raw_user_meta_data ->> 'funcao', '');
  v_acesso text := COALESCE(NULLIF(NEW.raw_user_meta_data ->> 'acesso', ''), 'Gratis');
  v_termos boolean := NULLIF(NEW.raw_user_meta_data ->> 'termos', '')::boolean;
BEGIN
  INSERT INTO public.users (
    "userID",
    email,
    nome,
    telefone,
    termos,
    funcao,
    acesso,
    excluido
  )
  SELECT
    NEW.id::text,
    lower(NEW.email),
    v_nome,
    v_telefone,
    v_termos,
    v_funcao,
    v_acesso,
    false
  WHERE NOT EXISTS (
    SELECT 1
    FROM public.users
    WHERE "userID" = NEW.id::text
  );

  UPDATE public.users
  SET
    email = COALESCE(lower(NEW.email), email),
    nome = COALESCE(v_nome, nome),
    telefone = COALESCE(v_telefone, telefone),
    termos = COALESCE(v_termos, termos),
    funcao = COALESCE(v_funcao, funcao),
    acesso = COALESCE(NULLIF(acesso, ''), v_acesso, 'Gratis'),
    excluido = COALESCE(excluido, false)
  WHERE "userID" = NEW.id::text;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_sync_public_users ON auth.users;

CREATE TRIGGER on_auth_user_created_sync_public_users
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.sync_auth_user_to_public_users();

INSERT INTO public.users (
  "userID",
  email,
  nome,
  telefone,
  termos,
  funcao,
  acesso,
  excluido
)
SELECT
  au.id::text,
  lower(au.email),
  NULLIF(au.raw_user_meta_data ->> 'nome', ''),
  NULLIF(au.raw_user_meta_data ->> 'telefone', ''),
  NULLIF(au.raw_user_meta_data ->> 'termos', '')::boolean,
  NULLIF(au.raw_user_meta_data ->> 'funcao', ''),
  COALESCE(NULLIF(au.raw_user_meta_data ->> 'acesso', ''), 'Gratis'),
  false
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1
  FROM public.users u
  WHERE u."userID" = au.id::text
);
