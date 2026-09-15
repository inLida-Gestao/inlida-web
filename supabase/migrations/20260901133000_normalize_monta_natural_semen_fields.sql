-- Monta Natural não utiliza campos de inseminação ou de partida de sêmen.
-- Corrige dados históricos e mantém essa regra em qualquer gravação futura.

UPDATE public.reproducao
SET data_inseminacao = NULL,
    data_partida_semen = NULL,
    partida_semen = NULL,
    updated_at = COALESCE(updated_at, now())
WHERE lower(btrim(COALESCE(tipo_reproducao, ''))) = 'monta natural'
  AND (
    data_inseminacao IS NOT NULL
    OR data_partida_semen IS NOT NULL
    OR partida_semen IS NOT NULL
  );

CREATE OR REPLACE FUNCTION public.limpar_campos_semen_monta_natural()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF lower(btrim(COALESCE(NEW.tipo_reproducao, ''))) = 'monta natural' THEN
    NEW.data_inseminacao := NULL;
    NEW.data_partida_semen := NULL;
    NEW.partida_semen := NULL;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_limpar_campos_semen_monta_natural
ON public.reproducao;

CREATE TRIGGER trg_limpar_campos_semen_monta_natural
BEFORE INSERT OR UPDATE OF tipo_reproducao, data_inseminacao,
data_partida_semen, partida_semen
ON public.reproducao
FOR EACH ROW
EXECUTE FUNCTION public.limpar_campos_semen_monta_natural();

-- Verificação: o resultado esperado é zero.
DO $$
DECLARE
  registros_invalidos integer;
BEGIN
  SELECT count(*)
  INTO registros_invalidos
  FROM public.reproducao
  WHERE lower(btrim(COALESCE(tipo_reproducao, ''))) = 'monta natural'
    AND (
      data_inseminacao IS NOT NULL
      OR data_partida_semen IS NOT NULL
      OR partida_semen IS NOT NULL
    );

  IF registros_invalidos <> 0 THEN
    RAISE EXCEPTION
      'Registros inválidos de Monta Natural encontrados: %',
      registros_invalidos;
  END IF;
END;
$$;
