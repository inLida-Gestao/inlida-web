-- Mantem rebanho.dataUltimaPesagem alinhada a maior data ativa do historico.
-- pesoAtual continua seguindo somente pesagens do tipo Atual ou tipo vazio.

CREATE OR REPLACE FUNCTION public.sincronizar_data_ultima_pesagem_rebanho_por_historico(
  p_id_rebanho text DEFAULT ''
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_id_rebanho text := NULLIF(btrim(COALESCE(p_id_rebanho, '')), '');
  v_pesagem_id integer;
  v_data_pesagem public.historico_pesagens."dataPesagem"%TYPE;
  v_updated integer := 0;
BEGIN
  IF v_id_rebanho IS NULL THEN
    RETURN jsonb_build_object(
      'idRebanho', NULL,
      'updated', 0,
      'reason', 'idRebanho vazio'
    );
  END IF;

  SELECT hp.id, hp."dataPesagem"
  INTO v_pesagem_id, v_data_pesagem
  FROM public.historico_pesagens hp
  WHERE hp."idRebanho" = v_id_rebanho
    AND COALESCE(hp.deletado, 'NAO') <> 'SIM'
    AND hp."dataPesagem" IS NOT NULL
  ORDER BY hp."dataPesagem" DESC, hp.id DESC
  LIMIT 1;

  UPDATE public.rebanho r
  SET
    "dataUltimaPesagem" = v_data_pesagem,
    updated_at = now()
  WHERE r."idRebanho" = v_id_rebanho
    AND COALESCE(r.deletado, 'NAO') <> 'SIM'
    AND r."dataUltimaPesagem" IS DISTINCT FROM v_data_pesagem;

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  RETURN jsonb_build_object(
    'idRebanho', v_id_rebanho,
    'updated', v_updated,
    'pesagem_id', v_pesagem_id,
    'dataPesagem', v_data_pesagem
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.trg_sincronizar_peso_atual_rebanho_por_pesagem()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_old_atual boolean;
  v_new_atual boolean;
BEGIN
  IF TG_OP = 'INSERT' THEN
    PERFORM public.sincronizar_data_ultima_pesagem_rebanho_por_historico(
      NEW."idRebanho"
    );

    v_new_atual := lower(btrim(COALESCE(NEW.tipo, ''))) IN ('', 'atual');
    IF v_new_atual THEN
      PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(
        NEW."idRebanho"
      );
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    v_old_atual := lower(btrim(COALESCE(OLD.tipo, ''))) IN ('', 'atual');
    v_new_atual := lower(btrim(COALESCE(NEW.tipo, ''))) IN ('', 'atual');

    IF NULLIF(btrim(COALESCE(OLD."idRebanho", '')), '') IS NOT NULL
       AND OLD."idRebanho" IS DISTINCT FROM NEW."idRebanho" THEN
      PERFORM public.sincronizar_data_ultima_pesagem_rebanho_por_historico(
        OLD."idRebanho"
      );
      IF v_old_atual THEN
        PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(
          OLD."idRebanho"
        );
      END IF;
    END IF;

    PERFORM public.sincronizar_data_ultima_pesagem_rebanho_por_historico(
      NEW."idRebanho"
    );
    IF v_old_atual OR v_new_atual THEN
      PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(
        NEW."idRebanho"
      );
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'DELETE' THEN
    PERFORM public.sincronizar_data_ultima_pesagem_rebanho_por_historico(
      OLD."idRebanho"
    );

    v_old_atual := lower(btrim(COALESCE(OLD.tipo, ''))) IN ('', 'atual');
    IF v_old_atual THEN
      PERFORM public.sincronizar_peso_atual_rebanho_por_pesagem(
        OLD."idRebanho"
      );
    END IF;
    RETURN OLD;
  END IF;

  RETURN NULL;
END;
$function$;

WITH latest_pesagem AS (
  SELECT DISTINCT ON (hp."idRebanho")
    hp."idRebanho",
    hp."dataPesagem"
  FROM public.historico_pesagens hp
  WHERE NULLIF(btrim(COALESCE(hp."idRebanho", '')), '') IS NOT NULL
    AND COALESCE(hp.deletado, 'NAO') <> 'SIM'
    AND hp."dataPesagem" IS NOT NULL
  ORDER BY hp."idRebanho", hp."dataPesagem" DESC, hp.id DESC
)
UPDATE public.rebanho r
SET
  "dataUltimaPesagem" = latest_pesagem."dataPesagem",
  updated_at = now()
FROM latest_pesagem
WHERE r."idRebanho" = latest_pesagem."idRebanho"
  AND COALESCE(r.deletado, 'NAO') <> 'SIM'
  AND r."dataUltimaPesagem" IS DISTINCT FROM latest_pesagem."dataPesagem";

GRANT EXECUTE
ON FUNCTION public.sincronizar_data_ultima_pesagem_rebanho_por_historico(text)
TO anon, authenticated;

NOTIFY pgrst, 'reload schema';