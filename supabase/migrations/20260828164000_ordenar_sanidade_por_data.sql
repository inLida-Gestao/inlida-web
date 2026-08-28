DROP FUNCTION IF EXISTS public.sanidade_filtros(
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  integer,
  integer
);

CREATE OR REPLACE FUNCTION public.sanidade_filtros(
  p_id_propriedade text,
  p_pesquisa text,
  p_data_sanidade_de text,
  p_data_sanidade_ate text,
  p_lote_id text,
  p_rebanho_id text,
  p_sexo text,
  p_data_nascimento_de text,
  p_data_nascimento_ate text,
  p_raca text,
  p_categoria text,
  p_tratamento text,
  p_protocolo text,
  p_antiparasitarios text,
  p_vacinacao text,
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0,
  p_ordem_data_asc boolean DEFAULT false
)
RETURNS SETOF view_rebanho_sanidade
LANGUAGE sql
AS $function$
  SELECT *
  FROM public.view_rebanho_sanidade
  WHERE id_propriedade = p_id_propriedade
    AND (p_pesquisa = '' OR nome ILIKE '%' || p_pesquisa || '%' OR "numeroAnimal" ILIKE '%' || p_pesquisa || '%' OR chip ILIKE '%' || p_pesquisa || '%')
    AND (p_data_sanidade_de = '' OR data_sanidade >= TO_DATE(p_data_sanidade_de, 'YYYY-MM-DD'))
    AND (p_data_sanidade_ate = '' OR data_sanidade <= TO_DATE(p_data_sanidade_ate, 'YYYY-MM-DD'))
    AND (p_rebanho_id = '' OR id_rebanho = p_rebanho_id)
    AND (p_lote_id = '' OR id_lote = p_lote_id)
    AND (p_sexo = '' OR sexo = p_sexo)
    AND (p_data_nascimento_de = '' OR "dataNascimento" >= TO_DATE(p_data_nascimento_de, 'YYYY-MM-DD'))
    AND (p_data_nascimento_ate = '' OR "dataNascimento" <= TO_DATE(p_data_nascimento_ate, 'YYYY-MM-DD'))
    AND (p_raca = '' OR raca = p_raca)
    AND (p_categoria = '' OR categoria = p_categoria)
    AND (p_tratamento = '' OR tratamento ILIKE '%' || p_tratamento || '%')
    AND (p_protocolo = '' OR protocolo_reprodutivo ILIKE '%' || p_protocolo || '%')
    AND (p_antiparasitarios = '' OR antiparasitario ILIKE '%' || p_antiparasitarios || '%')
    AND (p_vacinacao = '' OR vacinacao ILIKE '%' || p_vacinacao || '%')
    AND deletado = 'NAO'
  ORDER BY
    CASE
      WHEN p_ordem_data_asc
        THEN COALESCE(data_sanidade::timestamp, created_at::timestamp)
    END ASC NULLS LAST,
    CASE
      WHEN NOT p_ordem_data_asc
        THEN COALESCE(data_sanidade::timestamp, created_at::timestamp)
    END DESC NULLS LAST,
    CASE WHEN p_ordem_data_asc THEN id END ASC,
    CASE WHEN NOT p_ordem_data_asc THEN id END DESC
  LIMIT p_limite
  OFFSET p_offset;
$function$;
