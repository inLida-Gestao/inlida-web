-- Propaga alteracoes de numero, nome, raca e data de nascimento de um animal
-- para os registros denormalizados que guardam a "foto" dos pais:
--
--   1) rebanho (crias):  numeroMatriz / nomeMatriz / dataNascMatriz / racaMatriz
--                        numeroReprodutor / nomeReprodutor / dataNascReprodutor / racaReprodutor
--   2) reproducao:       numMatriz / nomeMatriz / nascimentoMatriz / racaMatriz
--                        numReprodutor / nomeReprodutor / nascimentoReprodutor / racaReprodutor
--
-- A tabela rebanho e a fonte da verdade. Inclui backfill dos registros ja divergentes.

-- ---------------------------------------------------------------------------
-- Indices de apoio (as buscas do trigger sao por id do pai/mae)
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_rebanho_rebanho_id_matriz
  ON public.rebanho ("rebanhoIdMatriz")
  WHERE "rebanhoIdMatriz" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_rebanho_rebanho_id_reprodutor
  ON public.rebanho ("rebanhoIdReprodutor")
  WHERE "rebanhoIdReprodutor" IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reproducao_id_rebanho_matriz
  ON public.reproducao (id_rebanho_matriz)
  WHERE id_rebanho_matriz IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reproducao_id_rebanho_reprodutor
  ON public.reproducao (id_rebanho_reprodutor)
  WHERE id_rebanho_reprodutor IS NOT NULL;

-- ---------------------------------------------------------------------------
-- Funcao do trigger
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.sincronizar_dados_pais_rebanho()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id_rebanho text := NULLIF(btrim(COALESCE(NEW."idRebanho", '')), '');
BEGIN
  -- Sem identificador nao ha como localizar as crias / reproducoes.
  IF v_id_rebanho IS NULL OR lower(v_id_rebanho) = 'null' THEN
    RETURN NEW;
  END IF;

  -- Nada mudou nos campos de interesse: evita escrita desnecessaria.
  IF NEW."numeroAnimal"   IS NOT DISTINCT FROM OLD."numeroAnimal"
     AND NEW.nome         IS NOT DISTINCT FROM OLD.nome
     AND NEW.raca         IS NOT DISTINCT FROM OLD.raca
     AND NEW."dataNascimento" IS NOT DISTINCT FROM OLD."dataNascimento" THEN
    RETURN NEW;
  END IF;

  -- 1) Crias que apontam para este animal como MATRIZ
  UPDATE public.rebanho c
  SET "numeroMatriz"   = NEW."numeroAnimal",
      "nomeMatriz"     = NEW.nome,
      "dataNascMatriz" = NEW."dataNascimento",
      "racaMatriz"     = NEW.raca
  WHERE c."rebanhoIdMatriz" = v_id_rebanho
    AND (
      c."numeroMatriz"   IS DISTINCT FROM NEW."numeroAnimal"
      OR c."nomeMatriz"  IS DISTINCT FROM NEW.nome
      OR c."dataNascMatriz" IS DISTINCT FROM NEW."dataNascimento"
      OR c."racaMatriz"  IS DISTINCT FROM NEW.raca
    );

  -- 2) Crias que apontam para este animal como REPRODUTOR
  UPDATE public.rebanho c
  SET "numeroReprodutor"   = NEW."numeroAnimal",
      "nomeReprodutor"     = NEW.nome,
      "dataNascReprodutor" = NEW."dataNascimento",
      "racaReprodutor"     = NEW.raca
  WHERE c."rebanhoIdReprodutor" = v_id_rebanho
    AND (
      c."numeroReprodutor"   IS DISTINCT FROM NEW."numeroAnimal"
      OR c."nomeReprodutor"  IS DISTINCT FROM NEW.nome
      OR c."dataNascReprodutor" IS DISTINCT FROM NEW."dataNascimento"
      OR c."racaReprodutor"  IS DISTINCT FROM NEW.raca
    );

  -- 3) Reproducoes em que este animal e a MATRIZ
  UPDATE public.reproducao rp
  SET "numMatriz"        = NEW."numeroAnimal",
      "nomeMatriz"       = NEW.nome,
      "nascimentoMatriz" = NEW."dataNascimento",
      "racaMatriz"       = NEW.raca
  WHERE rp.id_rebanho_matriz = v_id_rebanho
    AND (
      rp."numMatriz"      IS DISTINCT FROM NEW."numeroAnimal"
      OR rp."nomeMatriz"  IS DISTINCT FROM NEW.nome
      OR rp."nascimentoMatriz" IS DISTINCT FROM NEW."dataNascimento"
      OR rp."racaMatriz"  IS DISTINCT FROM NEW.raca
    );

  -- 4) Reproducoes em que este animal e o REPRODUTOR
  UPDATE public.reproducao rp
  SET "numReprodutor"        = NEW."numeroAnimal",
      "nomeReprodutor"       = NEW.nome,
      "nascimentoReprodutor" = NEW."dataNascimento",
      "racaReprodutor"       = NEW.raca
  WHERE rp.id_rebanho_reprodutor = v_id_rebanho
    AND (
      rp."numReprodutor"      IS DISTINCT FROM NEW."numeroAnimal"
      OR rp."nomeReprodutor"  IS DISTINCT FROM NEW.nome
      OR rp."nascimentoReprodutor" IS DISTINCT FROM NEW."dataNascimento"
      OR rp."racaReprodutor"  IS DISTINCT FROM NEW.raca
    );

  RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.sincronizar_dados_pais_rebanho() FROM PUBLIC, anon;

-- O trigger dispara apenas quando as colunas de origem sao alteradas.
-- As colunas gravadas pela funcao sao outras, portanto nao ha recursao.
DROP TRIGGER IF EXISTS trg_sincronizar_dados_pais_rebanho ON public.rebanho;

CREATE TRIGGER trg_sincronizar_dados_pais_rebanho
AFTER UPDATE OF "numeroAnimal", nome, raca, "dataNascimento"
ON public.rebanho
FOR EACH ROW
EXECUTE FUNCTION public.sincronizar_dados_pais_rebanho();

-- ---------------------------------------------------------------------------
-- Backfill dos registros ja divergentes
-- ---------------------------------------------------------------------------

-- Crias x matriz
UPDATE public.rebanho c
SET "numeroMatriz"   = r."numeroAnimal",
    "nomeMatriz"     = r.nome,
    "dataNascMatriz" = r."dataNascimento",
    "racaMatriz"     = r.raca
FROM public.rebanho r
WHERE r."idRebanho" = c."rebanhoIdMatriz"
  AND (
    c."numeroMatriz"   IS DISTINCT FROM r."numeroAnimal"
    OR c."nomeMatriz"  IS DISTINCT FROM r.nome
    OR c."dataNascMatriz" IS DISTINCT FROM r."dataNascimento"
    OR c."racaMatriz"  IS DISTINCT FROM r.raca
  );

-- Crias x reprodutor
UPDATE public.rebanho c
SET "numeroReprodutor"   = r."numeroAnimal",
    "nomeReprodutor"     = r.nome,
    "dataNascReprodutor" = r."dataNascimento",
    "racaReprodutor"     = r.raca
FROM public.rebanho r
WHERE r."idRebanho" = c."rebanhoIdReprodutor"
  AND (
    c."numeroReprodutor"   IS DISTINCT FROM r."numeroAnimal"
    OR c."nomeReprodutor"  IS DISTINCT FROM r.nome
    OR c."dataNascReprodutor" IS DISTINCT FROM r."dataNascimento"
    OR c."racaReprodutor"  IS DISTINCT FROM r.raca
  );

-- Reproducao x matriz
UPDATE public.reproducao rp
SET "numMatriz"        = r."numeroAnimal",
    "nomeMatriz"       = r.nome,
    "nascimentoMatriz" = r."dataNascimento",
    "racaMatriz"       = r.raca
FROM public.rebanho r
WHERE r."idRebanho" = rp.id_rebanho_matriz
  AND (
    rp."numMatriz"      IS DISTINCT FROM r."numeroAnimal"
    OR rp."nomeMatriz"  IS DISTINCT FROM r.nome
    OR rp."nascimentoMatriz" IS DISTINCT FROM r."dataNascimento"
    OR rp."racaMatriz"  IS DISTINCT FROM r.raca
  );

-- Reproducao x reprodutor
UPDATE public.reproducao rp
SET "numReprodutor"        = r."numeroAnimal",
    "nomeReprodutor"       = r.nome,
    "nascimentoReprodutor" = r."dataNascimento",
    "racaReprodutor"       = r.raca
FROM public.rebanho r
WHERE r."idRebanho" = rp.id_rebanho_reprodutor
  AND (
    rp."numReprodutor"      IS DISTINCT FROM r."numeroAnimal"
    OR rp."nomeReprodutor"  IS DISTINCT FROM r.nome
    OR rp."nascimentoReprodutor" IS DISTINCT FROM r."dataNascimento"
    OR rp."racaReprodutor"  IS DISTINCT FROM r.raca
  );
