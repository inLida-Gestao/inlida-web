-- A previsão de parto só é válida enquanto o diagnóstico estiver aberto
-- (Não diagnosticado) ou confirmar Prenhez.

UPDATE public.reproducao
SET previsao_parto = NULL
WHERE previsao_parto IS NOT NULL
  AND lower(btrim(COALESCE(status_reproducao, ''))) NOT IN (
    'não diagnosticado',
    'prenhez'
  );

CREATE OR REPLACE FUNCTION public.limpar_previsao_parto_por_status()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  IF lower(btrim(COALESCE(NEW.status_reproducao, ''))) NOT IN (
    'não diagnosticado',
    'prenhez'
  ) THEN
    NEW.previsao_parto := NULL;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_limpar_previsao_parto_por_status
ON public.reproducao;

CREATE TRIGGER trg_limpar_previsao_parto_por_status
BEFORE INSERT OR UPDATE OF status_reproducao, previsao_parto
ON public.reproducao
FOR EACH ROW
EXECUTE FUNCTION public.limpar_previsao_parto_por_status();
