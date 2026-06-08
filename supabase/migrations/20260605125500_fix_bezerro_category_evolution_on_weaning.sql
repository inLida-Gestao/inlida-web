-- Corrige a evolução automática de Bezerro/Bezerra quando a data de desmama é preenchida.
-- Antes, o job diário só atualizava animais com status "Na propriedade", deixando
-- desmamas já informadas em outros status sem evolução de categoria.

CREATE OR REPLACE FUNCTION public.evoluir_categoria_bezerro_row()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.deletado IS DISTINCT FROM 'SIM' THEN
    IF NEW.categoria = 'Bezerro'
       AND (
         NEW."dataDesmama" IS NOT NULL
         OR (
           NEW."dataNascimento" IS NOT NULL
           AND NEW."dataNascimento"::date <= (CURRENT_DATE - INTERVAL '12 months')::date
           AND COALESCE(NEW.status, '') ILIKE 'Na propriedade'
         )
       ) THEN
      NEW.categoria := 'Garrote';
    ELSIF NEW.categoria = 'Bezerra'
       AND (
         NEW."dataDesmama" IS NOT NULL
         OR (
           NEW."dataNascimento" IS NOT NULL
           AND NEW."dataNascimento"::date <= (CURRENT_DATE - INTERVAL '12 months')::date
           AND COALESCE(NEW.status, '') ILIKE 'Na propriedade'
         )
       ) THEN
      NEW.categoria := 'Novilha';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_evoluir_categoria_bezerros ON public.rebanho;

CREATE TRIGGER trigger_evoluir_categoria_bezerros
BEFORE INSERT OR UPDATE OF categoria, "dataDesmama", "dataNascimento", status, deletado
ON public.rebanho
FOR EACH ROW
EXECUTE FUNCTION public.evoluir_categoria_bezerro_row();

CREATE OR REPLACE FUNCTION public.atualiza_categorias_bezerros()
RETURNS TABLE(updated_garrote integer, updated_novilha integer)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE public.rebanho r
  SET categoria = 'Garrote'
  WHERE
    r.deletado IS DISTINCT FROM 'SIM'
    AND r.categoria = 'Bezerro'
    AND (
      r."dataDesmama" IS NOT NULL
      OR (
        r."dataDesmama" IS NULL
        AND COALESCE(r.status, '') ILIKE 'Na propriedade'
        AND r."dataNascimento" IS NOT NULL
        AND r."dataNascimento"::date <= (CURRENT_DATE - INTERVAL '12 months')::date
      )
    );

  GET DIAGNOSTICS updated_garrote = ROW_COUNT;

  UPDATE public.rebanho r
  SET categoria = 'Novilha'
  WHERE
    r.deletado IS DISTINCT FROM 'SIM'
    AND r.categoria = 'Bezerra'
    AND (
      r."dataDesmama" IS NOT NULL
      OR (
        r."dataDesmama" IS NULL
        AND COALESCE(r.status, '') ILIKE 'Na propriedade'
        AND r."dataNascimento" IS NOT NULL
        AND r."dataNascimento"::date <= (CURRENT_DATE - INTERVAL '12 months')::date
      )
    );

  GET DIAGNOSTICS updated_novilha = ROW_COUNT;

  RETURN NEXT;
END;
$$;

CREATE OR REPLACE FUNCTION public.atualiza_categorias_bezerros_teste(
  p_id_propriedade text
)
RETURNS TABLE(updated_garrote integer, updated_novilha integer)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE public.rebanho r
  SET categoria = 'Garrote'
  WHERE
    r.deletado IS DISTINCT FROM 'SIM'
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
    AND r.categoria = 'Bezerro'
    AND (
      r."dataDesmama" IS NOT NULL
      OR (
        r."dataDesmama" IS NULL
        AND COALESCE(r.status, '') ILIKE 'Na propriedade'
        AND r."dataNascimento" IS NOT NULL
        AND r."dataNascimento"::date <= (CURRENT_DATE - INTERVAL '12 months')::date
      )
    );

  GET DIAGNOSTICS updated_garrote = ROW_COUNT;

  UPDATE public.rebanho r
  SET categoria = 'Novilha'
  WHERE
    r.deletado IS DISTINCT FROM 'SIM'
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
    AND r.categoria = 'Bezerra'
    AND (
      r."dataDesmama" IS NOT NULL
      OR (
        r."dataDesmama" IS NULL
        AND COALESCE(r.status, '') ILIKE 'Na propriedade'
        AND r."dataNascimento" IS NOT NULL
        AND r."dataNascimento"::date <= (CURRENT_DATE - INTERVAL '12 months')::date
      )
    );

  GET DIAGNOSTICS updated_novilha = ROW_COUNT;

  RETURN NEXT;
END;
$$;

SELECT * FROM public.atualiza_categorias_bezerros();
