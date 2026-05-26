-- Bloqueia o uso das tabelas operacionais para usuarios sem plano Pago.
-- Leitura tambem precisa ser protegida por RLS; trigger/Edge Function nao cobrem SELECT direto via PostgREST.

CREATE OR REPLACE FUNCTION public.usuario_tem_plano_pago()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.users u
    WHERE u."userID"::text = auth.uid()::text
      AND btrim(COALESCE(u.acesso::text, '')) = 'Pago'
      AND COALESCE(u.excluido, false) = false
  );
$$;

GRANT EXECUTE ON FUNCTION public.usuario_tem_plano_pago() TO authenticated;

CREATE OR REPLACE FUNCTION public.usuario_listado_em_json(
  p_lista text,
  p_user_id text
)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT CASE
    WHEN p_lista IS NULL
      OR btrim(p_lista) = ''
      OR left(btrim(p_lista), 1) <> '['
      OR p_user_id IS NULL
      OR btrim(p_user_id) = ''
    THEN false
    ELSE EXISTS (
      SELECT 1
      FROM json_array_elements_text(p_lista::json) AS item(user_id)
      WHERE item.user_id = p_user_id
    )
  END;
$$;

GRANT EXECUTE ON FUNCTION public.usuario_listado_em_json(text, text) TO authenticated;

CREATE OR REPLACE FUNCTION public.usuario_tem_acesso_propriedade(p_id_propriedade text)
RETURNS boolean
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid text;
BEGIN
  v_uid := auth.uid()::text;

  IF v_uid IS NULL
     OR btrim(v_uid) = ''
     OR p_id_propriedade IS NULL
     OR btrim(p_id_propriedade) = '' THEN
    RETURN false;
  END IF;

  IF NOT public.usuario_tem_plano_pago() THEN
    RETURN false;
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM public.users_propriedades up
    WHERE up."idPropriedade" = p_id_propriedade
      AND up.user_id = v_uid
      AND COALESCE(up.deletado, 'NAO') = 'NAO'
  )
  OR EXISTS (
    SELECT 1
    FROM public.propriedades p
    WHERE p."idPropriedade" = p_id_propriedade
      AND (
        p."userID" = v_uid
        OR public.usuario_listado_em_json(p."usersID", v_uid)
      )
      AND COALESCE(p.deletado, 'NAO') = 'NAO'
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.usuario_tem_acesso_propriedade(text) TO authenticated;

-- Tabelas operacionais com coluna idPropriedade.
ALTER TABLE IF EXISTS public.rebanho ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS rebanho_pago_select ON public.rebanho;
DROP POLICY IF EXISTS rebanho_pago_insert ON public.rebanho;
DROP POLICY IF EXISTS rebanho_pago_update ON public.rebanho;
DROP POLICY IF EXISTS rebanho_pago_delete ON public.rebanho;
CREATE POLICY rebanho_pago_select ON public.rebanho
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY rebanho_pago_insert ON public.rebanho
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY rebanho_pago_update ON public.rebanho
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"))
  WITH CHECK (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY rebanho_pago_delete ON public.rebanho
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"));

ALTER TABLE IF EXISTS public.propriedades ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS propriedades_pago_select ON public.propriedades;
DROP POLICY IF EXISTS propriedades_pago_insert ON public.propriedades;
DROP POLICY IF EXISTS propriedades_pago_update ON public.propriedades;
DROP POLICY IF EXISTS propriedades_pago_delete ON public.propriedades;
CREATE POLICY propriedades_pago_select ON public.propriedades
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY propriedades_pago_insert ON public.propriedades
  FOR INSERT TO authenticated
  WITH CHECK (
    public.usuario_tem_plano_pago()
    AND (
      "userID" = auth.uid()::text
      OR public.usuario_listado_em_json("usersID", auth.uid()::text)
    )
  );
CREATE POLICY propriedades_pago_update ON public.propriedades
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"))
  WITH CHECK (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY propriedades_pago_delete ON public.propriedades
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"));

ALTER TABLE IF EXISTS public.users_propriedades ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS users_propriedades_pago_select ON public.users_propriedades;
DROP POLICY IF EXISTS users_propriedades_pago_insert ON public.users_propriedades;
DROP POLICY IF EXISTS users_propriedades_pago_update ON public.users_propriedades;
DROP POLICY IF EXISTS users_propriedades_pago_delete ON public.users_propriedades;
CREATE POLICY users_propriedades_pago_select ON public.users_propriedades
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY users_propriedades_pago_insert ON public.users_propriedades
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY users_propriedades_pago_update ON public.users_propriedades
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"))
  WITH CHECK (public.usuario_tem_acesso_propriedade("idPropriedade"));
CREATE POLICY users_propriedades_pago_delete ON public.users_propriedades
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade("idPropriedade"));

-- Tabelas operacionais com coluna id_propriedade.
ALTER TABLE IF EXISTS public.lotes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS lotes_pago_select ON public.lotes;
DROP POLICY IF EXISTS lotes_pago_insert ON public.lotes;
DROP POLICY IF EXISTS lotes_pago_update ON public.lotes;
DROP POLICY IF EXISTS lotes_pago_delete ON public.lotes;
CREATE POLICY lotes_pago_select ON public.lotes
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY lotes_pago_insert ON public.lotes
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY lotes_pago_update ON public.lotes
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY lotes_pago_delete ON public.lotes
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

ALTER TABLE IF EXISTS public.historico_pesagens ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS historico_pesagens_pago_select ON public.historico_pesagens;
DROP POLICY IF EXISTS historico_pesagens_pago_insert ON public.historico_pesagens;
DROP POLICY IF EXISTS historico_pesagens_pago_update ON public.historico_pesagens;
DROP POLICY IF EXISTS historico_pesagens_pago_delete ON public.historico_pesagens;
CREATE POLICY historico_pesagens_pago_select ON public.historico_pesagens
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY historico_pesagens_pago_insert ON public.historico_pesagens
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY historico_pesagens_pago_update ON public.historico_pesagens
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY historico_pesagens_pago_delete ON public.historico_pesagens
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

ALTER TABLE IF EXISTS public.reproducao ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS reproducao_pago_select ON public.reproducao;
DROP POLICY IF EXISTS reproducao_pago_insert ON public.reproducao;
DROP POLICY IF EXISTS reproducao_pago_update ON public.reproducao;
DROP POLICY IF EXISTS reproducao_pago_delete ON public.reproducao;
CREATE POLICY reproducao_pago_select ON public.reproducao
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY reproducao_pago_insert ON public.reproducao
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY reproducao_pago_update ON public.reproducao
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY reproducao_pago_delete ON public.reproducao
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

ALTER TABLE IF EXISTS public.sanidade ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS sanidade_pago_select ON public.sanidade;
DROP POLICY IF EXISTS sanidade_pago_insert ON public.sanidade;
DROP POLICY IF EXISTS sanidade_pago_update ON public.sanidade;
DROP POLICY IF EXISTS sanidade_pago_delete ON public.sanidade;
CREATE POLICY sanidade_pago_select ON public.sanidade
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY sanidade_pago_insert ON public.sanidade
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY sanidade_pago_update ON public.sanidade
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY sanidade_pago_delete ON public.sanidade
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

ALTER TABLE IF EXISTS public.ocorrencias ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS ocorrencias_pago_select ON public.ocorrencias;
DROP POLICY IF EXISTS ocorrencias_pago_insert ON public.ocorrencias;
DROP POLICY IF EXISTS ocorrencias_pago_update ON public.ocorrencias;
DROP POLICY IF EXISTS ocorrencias_pago_delete ON public.ocorrencias;
CREATE POLICY ocorrencias_pago_select ON public.ocorrencias
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY ocorrencias_pago_insert ON public.ocorrencias
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY ocorrencias_pago_update ON public.ocorrencias
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY ocorrencias_pago_delete ON public.ocorrencias
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

ALTER TABLE IF EXISTS public.pastagem ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS pastagem_pago_select ON public.pastagem;
DROP POLICY IF EXISTS pastagem_pago_insert ON public.pastagem;
DROP POLICY IF EXISTS pastagem_pago_update ON public.pastagem;
DROP POLICY IF EXISTS pastagem_pago_delete ON public.pastagem;
CREATE POLICY pastagem_pago_select ON public.pastagem
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY pastagem_pago_insert ON public.pastagem
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY pastagem_pago_update ON public.pastagem
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY pastagem_pago_delete ON public.pastagem
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

ALTER TABLE IF EXISTS public.piquete ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS piquete_pago_select ON public.piquete;
DROP POLICY IF EXISTS piquete_pago_insert ON public.piquete;
DROP POLICY IF EXISTS piquete_pago_update ON public.piquete;
DROP POLICY IF EXISTS piquete_pago_delete ON public.piquete;
CREATE POLICY piquete_pago_select ON public.piquete
  FOR SELECT TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY piquete_pago_insert ON public.piquete
  FOR INSERT TO authenticated
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY piquete_pago_update ON public.piquete
  FOR UPDATE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade))
  WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));
CREATE POLICY piquete_pago_delete ON public.piquete
  FOR DELETE TO authenticated
  USING (public.usuario_tem_acesso_propriedade(id_propriedade));

-- Change trackers nao carregam dados de negocio, mas tambem nao devem habilitar uso do app sem plano.
DO $$
DECLARE
  v_table text;
BEGIN
  FOREACH v_table IN ARRAY ARRAY[
    'rebanho_change_tracker',
    'lotes_change_tracker',
    'historico_pesagens_change_tracker',
    'reproducao_change_tracker',
    'sanidade_change_tracker',
    'propriedades_change_tracker'
  ]
  LOOP
    IF to_regclass(format('public.%I', v_table)) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', v_table);
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', v_table || '_pago_all', v_table);
      EXECUTE format(
        'CREATE POLICY %I ON public.%I FOR ALL TO authenticated USING (public.usuario_tem_plano_pago()) WITH CHECK (public.usuario_tem_plano_pago())',
        v_table || '_pago_all',
        v_table
      );
    END IF;
  END LOOP;
END;
$$;

-- Views devem respeitar RLS das tabelas base no PostgreSQL 15+.
DO $$
DECLARE
  v_view text;
BEGIN
  FOREACH v_view IN ARRAY ARRAY[
    'view_lotes_com_qtd_rebanhos',
    'view_reproducao_detalhada',
    'view_rebanho_sanidade'
  ]
  LOOP
    IF to_regclass(format('public.%I', v_view)) IS NOT NULL THEN
      EXECUTE format('ALTER VIEW public.%I SET (security_invoker = true)', v_view);
    END IF;
  END LOOP;
END;
$$;

-- RPCs SECURITY DEFINER que recebem propriedade podem contornar RLS. Para relatorios/listagens,
-- usar SECURITY INVOKER faz as consultas internas respeitarem as policies acima.
DO $$
DECLARE
  r record;
BEGIN
  FOR r IN
    SELECT
      n.nspname,
      p.proname,
      pg_get_function_identity_arguments(p.oid) AS args
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prosecdef = true
      AND p.prorettype <> 'pg_catalog.trigger'::regtype
      AND p.proname NOT IN (
        'usuario_tem_plano_pago',
        'usuario_tem_acesso_propriedade',
        'usuario_listado_em_json',
        'merge_user_into_propriedade_users_id',
        'remove_user_from_propriedade_users_id'
      )
      AND EXISTS (
        SELECT 1
        FROM unnest(COALESCE(p.proargnames, ARRAY[]::text[])) AS arg_name
        WHERE arg_name ILIKE '%propriedade%'
      )
  LOOP
    EXECUTE format('ALTER FUNCTION %I.%I(%s) SECURITY INVOKER', r.nspname, r.proname, r.args);
  END LOOP;
END;
$$;
