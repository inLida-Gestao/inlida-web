BEGIN;

UPDATE public.rebanho
SET
  "loteID" = NULL,
  "loteNome" = NULL
WHERE NULLIF(btrim(COALESCE("loteID", '')), '') IS NULL
   OR lower(btrim(COALESCE("loteID", ''))) = 'null';

UPDATE public.rebanho r
SET "loteNome" = l.nome
FROM public.lotes l
WHERE l.id_propriedade = r."idPropriedade"
  AND l.id_lote = r."loteID"
  AND COALESCE(l.deletado, 'NAO') = 'NAO'
  AND r."loteNome" IS DISTINCT FROM l.nome;

DROP FUNCTION IF EXISTS public.lotes_com_qtd_rebanhos_por_propriedade(text);
DROP FUNCTION IF EXISTS public.salvar_lote_status_e_sincronizar_animais(text, text, text, text, text, text, timestamptz, numeric, text);
DROP VIEW IF EXISTS public.view_lotes_com_qtd_rebanhos;

ALTER TABLE public.lotes
  DROP COLUMN id_animais RESTRICT;

CREATE VIEW public.view_lotes_com_qtd_rebanhos AS
SELECT
  l.id,
  l.created_at,
  l.id_propriedade,
  l.nome,
  l.anotacoes,
  l.ativo,
  l.data_entrada_piquete,
  l.data_saida_piquete,
  l.motivo,
  l.data_motivo,
  l.id_lote,
  l.deletado,
  l.updated_at,
  l."valorVenda",
  COALESCE(rc.qtd_rebanhos_no_lote, 0)::bigint AS qtd_rebanhos_no_lote
FROM public.lotes l
LEFT JOIN (
  SELECT
    r."idPropriedade" AS id_propriedade_ref,
    r."loteID" AS id_lote_ref,
    COUNT(*)::bigint AS qtd_rebanhos_no_lote
  FROM public.rebanho r
  WHERE r.deletado = 'NAO'
    AND NULLIF(btrim(COALESCE(r."loteID", '')), '') IS NOT NULL
    AND lower(btrim(r."loteID")) <> 'null'
  GROUP BY r."idPropriedade", r."loteID"
) rc
  ON rc.id_propriedade_ref = l.id_propriedade
 AND rc.id_lote_ref = l.id_lote
WHERE l.deletado = 'NAO';

CREATE OR REPLACE FUNCTION public.lotes_com_qtd_rebanhos_por_propriedade(
  p_id_propriedade text
)
RETURNS TABLE (
  id bigint,
  created_at timestamptz,
  id_propriedade text,
  nome text,
  anotacoes text,
  ativo text,
  data_entrada_piquete date,
  data_saida_piquete date,
  motivo text,
  data_motivo date,
  id_lote text,
  deletado text,
  updated_at timestamp,
  "valorVenda" numeric,
  qtd_rebanhos_no_lote bigint
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    l.id,
    l.created_at,
    l.id_propriedade,
    l.nome,
    l.anotacoes,
    l.ativo,
    l.data_entrada_piquete,
    l.data_saida_piquete,
    l.motivo,
    l.data_motivo,
    l.id_lote,
    l.deletado,
    l.updated_at,
    l."valorVenda",
    COALESCE(rc.qtd_rebanhos_no_lote, 0)::bigint
  FROM public.lotes l
  LEFT JOIN (
    SELECT
      r."idPropriedade" AS id_propriedade_ref,
      r."loteID" AS id_lote_ref,
      COUNT(*)::bigint AS qtd_rebanhos_no_lote
    FROM public.rebanho r
    WHERE r.deletado = 'NAO'
      AND NULLIF(btrim(COALESCE(r."loteID", '')), '') IS NOT NULL
      AND lower(btrim(r."loteID")) <> 'null'
    GROUP BY r."idPropriedade", r."loteID"
  ) rc
    ON rc.id_propriedade_ref = l.id_propriedade
   AND rc.id_lote_ref = l.id_lote
  WHERE l.deletado = 'NAO'
    AND l.id_propriedade = p_id_propriedade
  ORDER BY l.id DESC;
$$;

ALTER TABLE public.rebanho
  DROP CONSTRAINT IF EXISTS rebanho_lote_id_not_null_text_check;
ALTER TABLE public.rebanho
  ADD CONSTRAINT rebanho_lote_id_not_null_text_check
  CHECK ("loteID" IS NULL OR (btrim("loteID") <> '' AND lower(btrim("loteID")) <> 'null'));

ALTER TABLE public.rebanho
  DROP CONSTRAINT IF EXISTS rebanho_lote_id_fkey;
ALTER TABLE public.rebanho
  ADD CONSTRAINT rebanho_lote_id_fkey
  FOREIGN KEY ("loteID") REFERENCES public.lotes (id_lote)
  ON UPDATE RESTRICT
  ON DELETE RESTRICT;

GRANT SELECT ON public.view_lotes_com_qtd_rebanhos TO authenticated;
GRANT EXECUTE ON FUNCTION public.lotes_com_qtd_rebanhos_por_propriedade(text) TO authenticated;

NOTIFY pgrst, 'reload schema';
COMMIT;
