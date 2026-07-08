-- Garante a sincronizacao dos animais sempre que o status de um lote mudar,
-- inclusive quando algum cliente antigo atualiza a tabela lotes diretamente.

CREATE OR REPLACE FUNCTION public.sincronizar_animais_por_status_lote()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id_animais jsonb := '[]'::jsonb;
  v_lote_vendido boolean;
BEGIN
  IF COALESCE(NEW.deletado, 'NAO') <> 'NAO'
     OR btrim(COALESCE(NEW.id_propriedade, '')) = ''
     OR btrim(COALESCE(NEW.id_lote, '')) = '' THEN
    RETURN NEW;
  END IF;

  IF NULLIF(btrim(COALESCE(NEW.id_animais, '')), '') IS NOT NULL THEN
    BEGIN
      v_id_animais := NEW.id_animais::jsonb;
    EXCEPTION WHEN others THEN
      v_id_animais := '[]'::jsonb;
    END;
  END IF;

  v_lote_vendido := NEW.ativo = 'Inativo' AND NEW.motivo = 'Lote vendido';

  UPDATE public.rebanho r
  SET
    "loteID" = NEW.id_lote,
    "loteNome" = COALESCE(NULLIF(NEW.nome, ''), r."loteNome"),
    status = CASE WHEN v_lote_vendido THEN 'Vendido' ELSE 'Na propriedade' END,
    "dataVenda" = CASE WHEN v_lote_vendido THEN NEW.data_motivo ELSE NULL END,
    "valorVenda" = CASE WHEN v_lote_vendido THEN NEW."valorVenda" ELSE NULL END,
    updated_at = now()
  WHERE r."idPropriedade" = NEW.id_propriedade
    AND COALESCE(r.deletado, 'NAO') = 'NAO'
    AND (
      r."loteID" = NEW.id_lote
      OR r."idRebanho" IN (
        SELECT jsonb_array_elements_text(
          CASE
            WHEN jsonb_typeof(v_id_animais) = 'array' THEN v_id_animais
            ELSE '[]'::jsonb
          END
        )
      )
    );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sincronizar_animais_por_status_lote ON public.lotes;

CREATE TRIGGER trg_sincronizar_animais_por_status_lote
AFTER INSERT OR UPDATE OF
  id_animais,
  nome,
  ativo,
  motivo,
  data_motivo,
  "valorVenda"
ON public.lotes
FOR EACH ROW
EXECUTE FUNCTION public.sincronizar_animais_por_status_lote();
