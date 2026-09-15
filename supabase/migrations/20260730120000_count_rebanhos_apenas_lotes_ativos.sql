-- O card "Animais nos lotes" (FFAppState().qtdAnimaisEmLotesAtivos) contava todo
-- animal com "loteID" preenchido, mesmo quando o lote estava inativo. Por isso a
-- contagem nao diminuia ao inativar um lote sem venda (motivo <> 'Lote vendido'),
-- ja que nesse caso os animais permanecem com status 'Na propriedade'.
--
-- Passa a considerar apenas lotes ativos, replicando a mesma regra de isLoteAtivo()
-- usada em lib/actions/actions.dart para o card "Lotes ativos":
--   ativo = 'Ativo' (case-insensitive) e sem informacao de saida
--   (data_saida_piquete, motivo ou data_motivo preenchidos).

CREATE OR REPLACE FUNCTION public.count_rebanhos_com_lote(p_id_propriedade text)
RETURNS bigint
LANGUAGE sql
STABLE
SET search_path = public
AS $function$
  SELECT COUNT(*)
  FROM public.rebanho r
  JOIN public.lotes l
    ON l.id_propriedade = r."idPropriedade"
   AND l.id_lote = r."loteID"
   AND COALESCE(l.deletado, 'NAO') = 'NAO'
  WHERE r."idPropriedade" = p_id_propriedade
    AND r."loteID" IS NOT NULL
    AND btrim(r."loteID") <> ''
    AND lower(btrim(r."loteID")) <> 'null'
    AND r.deletado = 'NAO'
    AND r.status = 'Na propriedade'
    AND lower(btrim(COALESCE(l.ativo, ''))) = 'ativo'
    AND l.data_saida_piquete IS NULL
    AND l.data_motivo IS NULL
    AND btrim(COALESCE(l.motivo, '')) = '';
$function$;

NOTIFY pgrst, 'reload schema';
