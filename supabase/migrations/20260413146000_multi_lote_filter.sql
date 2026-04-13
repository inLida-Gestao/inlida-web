-- Melhoria #12: Filtrar por múltiplos lotes.
-- p_lote_nome agora aceita valores separados por vírgula.
-- Ex: "Lote A,Lote B" ou "SEM_LOTE,Lote A"

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
      OR (
        -- SEM_LOTE: animais sem lote
        'SEM_LOTE' = ANY(string_to_array(p_lote_nome, ','))
        AND (r."loteNome" IS NULL OR r."loteNome" = '')
        AND (r."loteID" IS NULL OR r."loteID" = '')
      )
      OR (
        -- Lotes específicos por nome
        r."loteNome" = ANY(string_to_array(p_lote_nome, ','))
      )
      OR (
        -- Lotes específicos por ID (lookup pelo nome)
        r."loteID" IN (
          SELECT l.id_lote FROM public.lotes l
          WHERE l.id_propriedade = p_id_propriedade
            AND l.nome = ANY(string_to_array(p_lote_nome, ','))
            AND (l.deletado IS NULL OR l.deletado != 'SIM')
        )
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

-- Count function also needs multi-lote support
DROP FUNCTION IF EXISTS public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text);

CREATE OR REPLACE FUNCTION public.contar_rebanho_propriedade_filtros(
  p_id_propriedade text,
  p_sexo text,
  p_status text,
  p_data_nascimento_de text,
  p_data_nascimento_ate text,
  p_lote_id text,
  p_categoria text,
  p_raca text,
  p_origem text,
  p_pesquisa text
)
RETURNS integer
LANGUAGE sql
STABLE
AS $function$
  SELECT COUNT(*)::integer
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND (p_pesquisa = '' OR r."numeroAnimal" ILIKE '%' || p_pesquisa || '%' OR r.nome ILIKE '%' || p_pesquisa || '%' OR r.chip ILIKE '%' || p_pesquisa || '%')
    AND (p_sexo = '' OR r.sexo = p_sexo)
    AND (p_status = '' OR r.status = p_status)
    AND (p_data_nascimento_de = '' OR r."dataNascimento" >= to_date(p_data_nascimento_de, 'YYYY-MM-DD'))
    AND (p_data_nascimento_ate = '' OR r."dataNascimento" <= to_date(p_data_nascimento_ate, 'YYYY-MM-DD'))
    AND (
      p_lote_id = ''
      OR (
        'SEM_LOTE' = ANY(string_to_array(p_lote_id, ','))
        AND (r."loteNome" IS NULL OR r."loteNome" = '')
        AND (r."loteID" IS NULL OR r."loteID" = '')
      )
      OR (
        r."loteID" = ANY(string_to_array(p_lote_id, ','))
      )
    )
    AND (p_categoria = '' OR r.categoria ILIKE '%' || p_categoria || '%')
    AND (p_raca = '' OR r.raca ILIKE '%' || p_raca || '%')
    AND (p_origem = '' OR r.origem ILIKE '%' || p_origem || '%')
    AND r.deletado = 'NAO';
$function$;
