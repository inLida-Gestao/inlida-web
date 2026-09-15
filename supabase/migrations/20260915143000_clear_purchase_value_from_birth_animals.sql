CREATE OR REPLACE FUNCTION public.normalizar_valor_compra_por_origem()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'public'
AS $function$
BEGIN
  IF lower(btrim(COALESCE(NEW.origem, ''))) = 'nascimento' THEN
    NEW."valorCompra" := NULL;
  END IF;

  RETURN NEW;
END;
$function$;

DROP TRIGGER IF EXISTS trg_normalizar_valor_compra_por_origem
  ON public.rebanho;

CREATE TRIGGER trg_normalizar_valor_compra_por_origem
BEFORE INSERT OR UPDATE OF origem, "valorCompra"
ON public.rebanho
FOR EACH ROW
EXECUTE FUNCTION public.normalizar_valor_compra_por_origem();
