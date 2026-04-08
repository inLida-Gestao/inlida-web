-- Mantém propriedades."usersID" alinhado a users_propriedades em todo INSERT/UPDATE/DELETE.
-- Evita que o convidado deixe de ver a propriedade quando só a tabela de vínculo é alterada.

CREATE OR REPLACE FUNCTION public.merge_user_into_propriedade_users_id(
  p_id_propriedade text,
  p_user_id text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cur text;
  merged text[];
  new_json text;
BEGIN
  IF p_id_propriedade IS NULL OR p_user_id IS NULL OR btrim(p_user_id) = '' THEN
    RETURN;
  END IF;

  SELECT p."usersID" INTO cur
  FROM propriedades p
  WHERE p."idPropriedade" = p_id_propriedade
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  SELECT COALESCE(array_agg(DISTINCT u), ARRAY[]::text[])
  INTO merged
  FROM unnest(
    CASE
      WHEN cur IS NOT NULL AND btrim(cur) <> '' AND left(btrim(cur), 1) = '[' THEN
        ARRAY(SELECT json_array_elements_text(cur::json)::text) || ARRAY[p_user_id]
      ELSE ARRAY[p_user_id]
    END
  ) AS u
  WHERE u IS NOT NULL AND btrim(u) <> '';

  IF merged IS NULL OR cardinality(merged) = 0 THEN
    new_json := '[]';
  ELSE
    new_json := to_json(merged)::text;
  END IF;

  UPDATE propriedades
  SET "usersID" = new_json
  WHERE "idPropriedade" = p_id_propriedade;
END;
$$;

CREATE OR REPLACE FUNCTION public.remove_user_from_propriedade_users_id(
  p_id_propriedade text,
  p_user_id text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  cur text;
  merged text[];
  new_json text;
BEGIN
  IF p_id_propriedade IS NULL OR p_user_id IS NULL OR btrim(p_user_id) = '' THEN
    RETURN;
  END IF;

  SELECT p."usersID" INTO cur
  FROM propriedades p
  WHERE p."idPropriedade" = p_id_propriedade
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  IF cur IS NULL OR btrim(cur) = '' OR left(btrim(cur), 1) <> '[' THEN
    RETURN;
  END IF;

  SELECT COALESCE(array_agg(t), ARRAY[]::text[])
  INTO merged
  FROM json_array_elements_text(cur::json) AS t
  WHERE t IS DISTINCT FROM p_user_id
    AND t IS NOT NULL
    AND btrim(t) <> '';

  IF merged IS NULL OR cardinality(merged) = 0 THEN
    new_json := '[]';
  ELSE
    new_json := to_json(merged)::text;
  END IF;

  UPDATE propriedades
  SET "usersID" = new_json
  WHERE "idPropriedade" = p_id_propriedade;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_users_propriedades_sync_users_id()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  active_old boolean;
  active_new boolean;
BEGIN
  active_old := TG_OP IN ('UPDATE', 'DELETE') AND COALESCE(OLD.deletado, 'NAO') = 'NAO';
  active_new := TG_OP IN ('INSERT', 'UPDATE') AND COALESCE(NEW.deletado, 'NAO') = 'NAO';

  IF TG_OP = 'INSERT' THEN
    IF active_new AND NEW.user_id IS NOT NULL AND btrim(NEW.user_id::text) <> '' THEN
      PERFORM public.merge_user_into_propriedade_users_id(NEW."idPropriedade", NEW.user_id::text);
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'DELETE' THEN
    IF active_old AND OLD.user_id IS NOT NULL AND btrim(OLD.user_id::text) <> '' THEN
      PERFORM public.remove_user_from_propriedade_users_id(OLD."idPropriedade", OLD.user_id::text);
    END IF;
    RETURN OLD;
  END IF;

  IF OLD."idPropriedade" IS DISTINCT FROM NEW."idPropriedade"
     OR OLD.user_id IS DISTINCT FROM NEW.user_id THEN
    IF active_old AND OLD.user_id IS NOT NULL AND btrim(OLD.user_id::text) <> '' THEN
      PERFORM public.remove_user_from_propriedade_users_id(OLD."idPropriedade", OLD.user_id::text);
    END IF;
    IF active_new AND NEW.user_id IS NOT NULL AND btrim(NEW.user_id::text) <> '' THEN
      PERFORM public.merge_user_into_propriedade_users_id(NEW."idPropriedade", NEW.user_id::text);
    END IF;
    RETURN NEW;
  END IF;

  IF active_old AND NOT active_new AND OLD.user_id IS NOT NULL AND btrim(OLD.user_id::text) <> '' THEN
    PERFORM public.remove_user_from_propriedade_users_id(OLD."idPropriedade", OLD.user_id::text);
  ELSIF (NOT active_old) AND active_new AND NEW.user_id IS NOT NULL AND btrim(NEW.user_id::text) <> '' THEN
    PERFORM public.merge_user_into_propriedade_users_id(NEW."idPropriedade", NEW.user_id::text);
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS users_propriedades_sync_users_id ON public.users_propriedades;

CREATE TRIGGER users_propriedades_sync_users_id
AFTER INSERT OR UPDATE OR DELETE ON public.users_propriedades
FOR EACH ROW
EXECUTE FUNCTION public.trg_users_propriedades_sync_users_id();
