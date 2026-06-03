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
  v_acesso_text text := NULLIF(NEW.raw_user_meta_data ->> 'acesso', '');
  v_termos_text text := lower(NULLIF(NEW.raw_user_meta_data ->> 'termos', ''));
  v_acesso public.tipo_acesso := 'Gratis'::public.tipo_acesso;
  v_termos boolean;
BEGIN
  IF v_acesso_text IN ('Gratis', 'Pago', 'Cancelado', 'Vencido') THEN
    v_acesso := v_acesso_text::public.tipo_acesso;
  END IF;

  IF v_termos_text IN ('true', 't', '1', 'yes', 'y', 'on') THEN
    v_termos := true;
  ELSIF v_termos_text IN ('false', 'f', '0', 'no', 'n', 'off') THEN
    v_termos := false;
  END IF;

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
    NEW.id,
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
    WHERE "userID" = NEW.id
  );

  UPDATE public.users
  SET
    email = COALESCE(lower(NEW.email), email),
    nome = COALESCE(v_nome, nome),
    telefone = COALESCE(v_telefone, telefone),
    termos = COALESCE(v_termos, termos),
    funcao = COALESCE(v_funcao, funcao),
    acesso = COALESCE(acesso, v_acesso, 'Gratis'::public.tipo_acesso),
    excluido = COALESCE(excluido, false)
  WHERE "userID" = NEW.id;

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
  au.id,
  lower(au.email),
  NULLIF(au.raw_user_meta_data ->> 'nome', ''),
  NULLIF(au.raw_user_meta_data ->> 'telefone', ''),
  CASE
    WHEN lower(NULLIF(au.raw_user_meta_data ->> 'termos', '')) IN ('true', 't', '1', 'yes', 'y', 'on') THEN true
    WHEN lower(NULLIF(au.raw_user_meta_data ->> 'termos', '')) IN ('false', 'f', '0', 'no', 'n', 'off') THEN false
    ELSE NULL
  END,
  NULLIF(au.raw_user_meta_data ->> 'funcao', ''),
  CASE
    WHEN NULLIF(au.raw_user_meta_data ->> 'acesso', '') IN ('Gratis', 'Pago', 'Cancelado', 'Vencido')
      THEN (au.raw_user_meta_data ->> 'acesso')::public.tipo_acesso
    ELSE 'Gratis'::public.tipo_acesso
  END,
  false
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1
  FROM public.users u
  WHERE u."userID" = au.id
);
