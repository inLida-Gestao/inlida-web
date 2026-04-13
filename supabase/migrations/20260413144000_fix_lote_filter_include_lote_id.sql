-- Bugs #9, #13, #16: Corrigir filtro e contagem de animais por lote.
-- A função rebanho_propriedade_filtros só verificava loteNome.
-- Agora verifica loteNome OU loteID (via tabela lotes pelo nome).
-- Isso corrige animais que têm loteID mas não loteNome.

CREATE OR REPLACE FUNCTION public.rebanho_propriedade_filtros(
  p_id_propriedade text,
  p_sexo text,
  p_status text,
  p_data_nascimento_de text,
  p_data_nascimento_ate text,
  p_lote_nome text,
  p_categoria text,
  p_raca text,
  p_origem text,
  p_pesquisa text,
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0
)
RETURNS SETOF rebanho
LANGUAGE sql
STABLE
AS $function$
  SELECT r.*
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND (p_pesquisa = '' OR r."numeroAnimal" ILIKE '%' || p_pesquisa || '%' OR r.nome ILIKE '%' || p_pesquisa || '%' OR r.chip ILIKE '%' || p_pesquisa || '%')
    AND (p_sexo = '' OR r.sexo = p_sexo)
    AND (p_status = '' OR r.status = p_status)
    AND (p_data_nascimento_de = '' OR r."dataNascimento" >= to_date(p_data_nascimento_de, 'YYYY-MM-DD'))
    AND (p_data_nascimento_ate = '' OR r."dataNascimento" <= to_date(p_data_nascimento_ate, 'YYYY-MM-DD'))
    AND (
      p_lote_nome = ''
      OR r."loteNome" ILIKE '%' || p_lote_nome || '%'
      OR r."loteID" IN (
        SELECT l.id_lote FROM public.lotes l
        WHERE l.id_propriedade = p_id_propriedade
          AND l.nome ILIKE '%' || p_lote_nome || '%'
          AND (l.deletado IS NULL OR l.deletado != 'SIM')
      )
    )
    AND (p_categoria = '' OR r.categoria ILIKE '%' || p_categoria || '%')
    AND (p_raca = '' OR r.raca ILIKE '%' || p_raca || '%')
    AND (p_origem = '' OR r.origem ILIKE '%' || p_origem || '%')
    AND r.deletado = 'NAO'
    ORDER BY r.created_at DESC
    LIMIT p_limite
    OFFSET p_offset;
$function$;
