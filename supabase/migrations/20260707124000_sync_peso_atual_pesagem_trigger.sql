-- Mantem rebanho.pesoAtual sincronizado com a ultima pesagem ativa do tipo Atual.
-- Regra: maior dataPesagem; em empate, maior id.

CREATE OR REPLACE FUNCTION public.sincronizar_peso_atual_rebanho_por_pesagem(
  p_id_rebanho text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id_rebanho text := NULLIF(btrim(COALESCE(p_id_rebanho, '')), '');
  v_pesagem_id integer;
  v_data_pesagem public.historico_pesagens."dataPesagem"%TYPE;
  v_peso public.historico_pesagens.peso%TYPE;
  v_updated integer := 0;
BEGIN
  IF v_id_rebanho IS NULL THEN
    RETURN jsonb_build_object(
      'idRebanho', NULL,
      'updated', 0,
      'reason', 'idRebanho vazio'
    );
  END IF;

  SELECT hp.id, hp."dataPesagem", hp.peso
  INTO v_pesagem_id, v_data_pesagem, v_peso
  FROM public.historico_pesagens hp
  WHERE hp."idRebanho" = v_id_rebanho
    AND COALESCE(hp.deletado, 'NAO') <> 'SIM'
    AND lower(btrim(COALESCE(hp.tipo, ''))) = 'atual'
    AND hp."dataPesagem" IS NOT NULL
  ORDER BY hp."dataPesagem" DESC, hp.id DESC
  LIMIT 1;

  UPDATE public.rebanho r
  SET
    "pesoAtual" = v_peso,
    updated_at = now()
  WHERE r."idRebanho" = v_id_rebanho
    AND COALESCE(r.deletado, 'NAO') <> 'SIM'
    AND (
      auth.uid() IS NULL
      OR public.usuario_tem_acesso_propriedade(r."idPropriedade")
    )
    AND r."pesoAtual" IS DISTINCT FROM v_peso;

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  RETURN jsonb_build_object(
    'idRebanho', v_id_rebanho,
    'updated', v_updated,
    'pesagem_id', v_pesagem_id,
    'dataPesagem', v_data_pesagem,
    'pesoAtual', v_peso
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.sincronizar_peso_atual_rebanho_por_pesagem(text)
TO authenticated;

CREATE OR REPLACE FUNCTION public.trg_sincronizar_peso_atual_rebanho_por_pesagem()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_old_atual boolean;
  v_new_atual boolean;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_new_atual := lower(btrim(COALESCE(NEW.tipo, ''))) = 'atual';
    IF v_new_atual THEN
      PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(NEW."idRebanho");
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    v_old_atual := lower(btrim(COALESCE(OLD.tipo, ''))) = 'atual';
    v_new_atual := lower(btrim(COALESCE(NEW.tipo, ''))) = 'atual';

    IF v_old_atual OR v_new_atual THEN
      IF NULLIF(btrim(COALESCE(OLD."idRebanho", '')), '') IS NOT NULL
         AND OLD."idRebanho" IS DISTINCT FROM NEW."idRebanho" THEN
        PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(OLD."idRebanho");
      END IF;

      PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(NEW."idRebanho");
    END IF;

    RETURN NEW;
  END IF;

  IF TG_OP = 'DELETE' THEN
    v_old_atual := lower(btrim(COALESCE(OLD.tipo, ''))) = 'atual';
    IF v_old_atual THEN
      PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(OLD."idRebanho");
    END IF;
    RETURN OLD;
  END IF;

  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_sincronizar_peso_atual_rebanho_por_pesagem
ON public.historico_pesagens;

CREATE TRIGGER trg_sincronizar_peso_atual_rebanho_por_pesagem
AFTER INSERT OR UPDATE OF "idRebanho", "dataPesagem", tipo, peso, deletado
OR DELETE
ON public.historico_pesagens
FOR EACH ROW
EXECUTE FUNCTION public.trg_sincronizar_peso_atual_rebanho_por_pesagem();

WITH ultima_atual AS (
  SELECT DISTINCT ON (hp."idRebanho")
    hp."idRebanho",
    hp.peso
  FROM public.historico_pesagens hp
  WHERE COALESCE(hp.deletado, 'NAO') <> 'SIM'
    AND lower(btrim(COALESCE(hp.tipo, ''))) = 'atual'
    AND hp."dataPesagem" IS NOT NULL
  ORDER BY hp."idRebanho", hp."dataPesagem" DESC, hp.id DESC
)
UPDATE public.rebanho r
SET
  "pesoAtual" = u.peso,
  updated_at = now()
FROM ultima_atual u
WHERE r."idRebanho" = u."idRebanho"
  AND COALESCE(r.deletado, 'NAO') <> 'SIM'
  AND r."pesoAtual" IS DISTINCT FROM u.peso;

NOTIFY pgrst, 'reload schema';
