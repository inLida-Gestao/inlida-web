-- Garante que o sync de pesoAtual via trigger/RPC nao dependa do usuario logado.
-- A funcao e SECURITY DEFINER e deve sincronizar o rebanho pelo idRebanho validado,
-- inclusive quando importacoes sao feitas por usuarios com permissao operacional parcial.

CREATE OR REPLACE FUNCTION public.sincronizar_peso_atual_rebanho_por_pesagem(p_id_rebanho text DEFAULT ''::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
$function$;

GRANT EXECUTE ON FUNCTION public.sincronizar_peso_atual_rebanho_por_pesagem(text) TO anon, authenticated;

NOTIFY pgrst, 'reload schema';
