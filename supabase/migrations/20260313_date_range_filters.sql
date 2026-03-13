-- =============================================================================
-- Migration: Converter filtros de data unica para intervalo (De/Ate)
-- Modulos: Rebanho, Reproducao, Sanidade, Lotes
-- =============================================================================
-- Cada parametro de data unica (p_data_xxx) e substituido por dois parametros:
--   p_data_xxx_de (inicio do intervalo) e p_data_xxx_ate (fim do intervalo).
-- Quando vazio (''), a clausula e ignorada, permitindo filtrar so por "De",
-- so por "Ate", ou ambos.
-- =============================================================================

-- =============================================
-- 1. REBANHO: rebanho_propriedade_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.rebanho_propriedade_filtros(text, text, text, text, text, text, text, text, text, int, int);

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
AS $function$
  SELECT *
  FROM public.rebanho
  WHERE "idPropriedade" = p_id_propriedade
    AND (p_pesquisa = '' OR "numeroAnimal" ILIKE '%' || p_pesquisa || '%' OR nome ILIKE '%' || p_pesquisa || '%' OR chip ILIKE '%' || p_pesquisa || '%')
    AND (p_sexo = '' OR sexo = p_sexo)
    AND (p_status = '' OR status = p_status)
    AND (p_data_nascimento_de = '' OR "dataNascimento" >= to_date(p_data_nascimento_de, 'YYYY-MM-DD'))
    AND (p_data_nascimento_ate = '' OR "dataNascimento" <= to_date(p_data_nascimento_ate, 'YYYY-MM-DD'))
    AND (p_lote_nome = '' OR "loteNome" ILIKE '%' || p_lote_nome || '%')
    AND (p_categoria = '' OR categoria ILIKE '%' || p_categoria || '%')
    AND (p_raca = '' OR raca ILIKE '%' || p_raca || '%')
    AND (p_origem = '' OR origem ILIKE '%' || p_origem || '%')
    AND deletado = 'NAO'
    ORDER BY created_at DESC
    LIMIT p_limite
    OFFSET p_offset;
$function$;

-- =============================================
-- 2. REBANHO: contar_rebanho_propriedade_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.contar_rebanho_propriedade_filtros(text, text, text, text, text, text, text, text, text);

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
AS $function$
  SELECT COUNT(*)::INTEGER
  FROM public.rebanho
  WHERE "idPropriedade" = p_id_propriedade
    AND (p_pesquisa = '' OR "numeroAnimal" ILIKE '%' || p_pesquisa || '%' OR nome ILIKE '%' || p_pesquisa || '%' OR chip ILIKE '%' || p_pesquisa || '%')
    AND (p_sexo = '' OR sexo = p_sexo)
    AND (p_status = '' OR status = p_status)
    AND (p_data_nascimento_de = '' OR "dataNascimento" >= to_date(p_data_nascimento_de, 'YYYY-MM-DD'))
    AND (p_data_nascimento_ate = '' OR "dataNascimento" <= to_date(p_data_nascimento_ate, 'YYYY-MM-DD'))
    AND (p_lote_ID = '' OR "loteID" ILIKE '%' || p_lote_ID || '%')
    AND (p_categoria = '' OR categoria ILIKE '%' || p_categoria || '%')
    AND (p_raca = '' OR raca ILIKE '%' || p_raca || '%')
    AND (p_origem = '' OR origem ILIKE '%' || p_origem || '%')
    AND deletado = 'NAO';
$function$;

-- =============================================
-- 3. REPRODUCAO: reproducao_filtros
-- =============================================

-- Drop both overloads (one without diagnostico, one with)
DROP FUNCTION IF EXISTS public.reproducao_filtros(text, text, text, text, text, text, text, text, text, int, int, text, text);
DROP FUNCTION IF EXISTS public.reproducao_filtros(text, text, text, text, text, text, text, text, text, text, text, text, text, int, int, text, text);

CREATE OR REPLACE FUNCTION public.reproducao_filtros(
  p_id_propriedade text DEFAULT '',
  p_data_reproducao_de text DEFAULT '',
  p_data_reproducao_ate text DEFAULT '',
  p_data_previsao_parto_de text DEFAULT '',
  p_data_previsao_parto_ate text DEFAULT '',
  p_data_diagnostico_de text DEFAULT '',
  p_data_diagnostico_ate text DEFAULT '',
  p_tipo_reproducao text DEFAULT '',
  p_lote_nome text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_matriz text DEFAULT '',
  p_reprodutor text DEFAULT '',
  p_limite integer DEFAULT 20,
  p_offset integer DEFAULT 0,
  p_sort_column text DEFAULT 'data_inseminacao',
  p_sort_direction text DEFAULT 'desc'
)
RETURNS SETOF view_reproducao_detalhada
LANGUAGE plpgsql
STABLE
AS $function$
BEGIN
  RETURN QUERY
  SELECT v.*
  FROM view_reproducao_detalhada v
  WHERE
    (p_id_propriedade = '' OR v.id_propriedade = p_id_propriedade)
    AND (v.deletado IS NULL OR v.deletado <> 'SIM')
    -- Data reproducao (intervalo)
    AND (p_data_reproducao_de = '' OR COALESCE(v.data_inseminacao, v.data_inicial)::date >= p_data_reproducao_de::date)
    AND (p_data_reproducao_ate = '' OR COALESCE(v.data_inseminacao, v.data_inicial)::date <= p_data_reproducao_ate::date)
    -- Previsao de parto (intervalo)
    AND (p_data_previsao_parto_de = '' OR (v.previsao_parto IS NOT NULL AND v.previsao_parto::date >= p_data_previsao_parto_de::date))
    AND (p_data_previsao_parto_ate = '' OR (v.previsao_parto IS NOT NULL AND v.previsao_parto::date <= p_data_previsao_parto_ate::date))
    -- Diagnostico (intervalo) - usa data_status
    AND (p_data_diagnostico_de = '' OR (v.data_status IS NOT NULL AND v.data_status::date >= p_data_diagnostico_de::date))
    AND (p_data_diagnostico_ate = '' OR (v.data_status IS NOT NULL AND v.data_status::date <= p_data_diagnostico_ate::date))
    AND (p_tipo_reproducao = '' OR v.categoria = p_tipo_reproducao)
    AND (p_lote_nome = '' OR v."loteNome" = p_lote_nome)
    AND (p_inseminador = '' OR v.inseminador = p_inseminador)
    AND (p_matriz = '' OR v.id_rebanho_matriz = p_matriz)
    AND (p_reprodutor = '' OR v.id_rebanho_reprodutor = p_reprodutor)
    AND (p_pesquisa = '' OR (v."nomeMatriz" IS NOT NULL AND v."nomeMatriz" ILIKE '%' || p_pesquisa || '%')
      OR (v."numMatriz" IS NOT NULL AND v."numMatriz" ILIKE '%' || p_pesquisa || '%')
      OR (v."nomeReprodutor" IS NOT NULL AND v."nomeReprodutor" ILIKE '%' || p_pesquisa || '%')
      OR (v."numReprodutor" IS NOT NULL AND v."numReprodutor" ILIKE '%' || p_pesquisa || '%'))
  ORDER BY
    CASE p_sort_column
      WHEN 'tipo_reproducao' THEN v.tipo_reproducao
      WHEN 'status' THEN v.status_reproducao
      WHEN 'matriz' THEN COALESCE(v."nomeMatriz", '')
      ELSE (COALESCE(v.data_inseminacao, v.data_inicial)::text)
    END
  DESC NULLS LAST
  LIMIT NULLIF(p_limite, 0)
  OFFSET p_offset;
END;
$function$;

-- =============================================
-- 4. REPRODUCAO: contar_reproducao_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.contar_reproducao_filtros(text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.contar_reproducao_filtros(
  p_id_propriedade text DEFAULT '',
  p_data_reproducao_de text DEFAULT '',
  p_data_reproducao_ate text DEFAULT '',
  p_data_previsao_parto_de text DEFAULT '',
  p_data_previsao_parto_ate text DEFAULT '',
  p_data_diagnostico_de text DEFAULT '',
  p_data_diagnostico_ate text DEFAULT '',
  p_tipo_reproducao text DEFAULT '',
  p_lote_nome text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_pesquisa text DEFAULT '',
  p_matriz text DEFAULT '',
  p_reprodutor text DEFAULT ''
)
RETURNS bigint
LANGUAGE plpgsql
STABLE
AS $function$
DECLARE
  total bigint;
BEGIN
  SELECT COUNT(*) INTO total
  FROM view_reproducao_detalhada v
  WHERE
    (p_id_propriedade = '' OR v.id_propriedade = p_id_propriedade)
    AND (v.deletado IS NULL OR v.deletado <> 'SIM')
    AND (p_data_reproducao_de = '' OR COALESCE(v.data_inseminacao, v.data_inicial)::date >= p_data_reproducao_de::date)
    AND (p_data_reproducao_ate = '' OR COALESCE(v.data_inseminacao, v.data_inicial)::date <= p_data_reproducao_ate::date)
    AND (p_data_previsao_parto_de = '' OR (v.previsao_parto IS NOT NULL AND v.previsao_parto::date >= p_data_previsao_parto_de::date))
    AND (p_data_previsao_parto_ate = '' OR (v.previsao_parto IS NOT NULL AND v.previsao_parto::date <= p_data_previsao_parto_ate::date))
    AND (p_data_diagnostico_de = '' OR (v.data_status IS NOT NULL AND v.data_status::date >= p_data_diagnostico_de::date))
    AND (p_data_diagnostico_ate = '' OR (v.data_status IS NOT NULL AND v.data_status::date <= p_data_diagnostico_ate::date))
    AND (p_tipo_reproducao = '' OR v.categoria = p_tipo_reproducao)
    AND (p_lote_nome = '' OR v."loteNome" = p_lote_nome)
    AND (p_inseminador = '' OR v.inseminador = p_inseminador)
    AND (p_matriz = '' OR v.id_rebanho_matriz = p_matriz)
    AND (p_reprodutor = '' OR v.id_rebanho_reprodutor = p_reprodutor)
    AND (p_pesquisa = '' OR (v."nomeMatriz" IS NOT NULL AND v."nomeMatriz" ILIKE '%' || p_pesquisa || '%')
      OR (v."numMatriz" IS NOT NULL AND v."numMatriz" ILIKE '%' || p_pesquisa || '%')
      OR (v."nomeReprodutor" IS NOT NULL AND v."nomeReprodutor" ILIKE '%' || p_pesquisa || '%')
      OR (v."numReprodutor" IS NOT NULL AND v."numReprodutor" ILIKE '%' || p_pesquisa || '%'));
  RETURN total;
END;
$function$;

-- =============================================
-- 5. SANIDADE: sanidade_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.sanidade_filtros(text, text, text, text, text, text, text, text, text, text, text, text, text, int, int);

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
  p_offset integer DEFAULT 0
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
    ORDER BY id DESC
    LIMIT p_limite
    OFFSET p_offset;
$function$;

-- =============================================
-- 6. SANIDADE: count_sanidade_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.count_sanidade_filtros(text, text, text, text, text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.count_sanidade_filtros(
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
  p_vacinacao text
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
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
$function$;

-- =============================================
-- 7. SANIDADE: count_sanidade_vacinacao
-- =============================================

DROP FUNCTION IF EXISTS public.count_sanidade_vacinacao(text, text, text, text, text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.count_sanidade_vacinacao(
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
  p_vacinacao text
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
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
    AND vacinacao <> 'null'
    AND vacinacao <> '[]'
    AND deletado = 'NAO'
$function$;

-- =============================================
-- 8. SANIDADE: count_sanidade_antiparasitario
-- =============================================

DROP FUNCTION IF EXISTS public.count_sanidade_antiparasitario(text, text, text, text, text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.count_sanidade_antiparasitario(
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
  p_vacinacao text
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
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
    AND antiparasitario <> 'null'
    AND antiparasitario <> '[]'
    AND deletado = 'NAO'
$function$;

-- =============================================
-- 9. SANIDADE: count_sanidade_tratamento
-- =============================================

DROP FUNCTION IF EXISTS public.count_sanidade_tratamento(text, text, text, text, text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.count_sanidade_tratamento(
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
  p_vacinacao text
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
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
    AND tratamento <> 'null'
    AND tratamento <> '[]'
    AND deletado = 'NAO'
$function$;

-- =============================================
-- 10. SANIDADE: count_sanidade_protocolo_reprodutivo
-- =============================================

DROP FUNCTION IF EXISTS public.count_sanidade_protocolo_reprodutivo(text, text, text, text, text, text, text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.count_sanidade_protocolo_reprodutivo(
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
  p_vacinacao text
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
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
    AND protocolo_reprodutivo <> 'null'
    AND protocolo_reprodutivo <> '[]'
    AND deletado = 'NAO'
$function$;

-- =============================================
-- 11. LOTES: lotes_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.lotes_filtros(text, text, text, int, int);

CREATE OR REPLACE FUNCTION public.lotes_filtros(
  p_id_propriedade text,
  p_pesquisa text DEFAULT '',
  p_status text DEFAULT '',
  p_data_criacao_de text DEFAULT '',
  p_data_criacao_ate text DEFAULT '',
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0
)
RETURNS TABLE(
  id bigint,
  created_at timestamp with time zone,
  id_propriedade text,
  id_animais text,
  nome text,
  anotacoes text,
  ativo text,
  data_entrada_piquete date,
  data_saida_piquete date,
  motivo text,
  data_motivo date,
  id_lote text,
  deletado text,
  updated_at timestamp without time zone,
  "valorVenda" numeric,
  qtd_rebanhos_no_lote bigint
)
LANGUAGE sql
AS $function$
  SELECT
    l.id,
    l.created_at,
    l.id_propriedade,
    l.id_animais,
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
      r."loteNome" AS nome_lote,
      r."idPropriedade" AS id_propriedade_ref,
      COUNT(*)::bigint AS qtd_rebanhos_no_lote
    FROM public.rebanho r
    WHERE r.deletado = 'NAO'
      AND r."loteNome" IS NOT NULL
      AND btrim(r."loteNome") <> ''
      AND lower(btrim(r."loteNome")) <> 'null'
    GROUP BY r."loteNome", r."idPropriedade"
  ) rc
    ON rc.nome_lote = l.nome
   AND rc.id_propriedade_ref = l.id_propriedade
  WHERE l.deletado = 'NAO'
    AND l.id_propriedade = p_id_propriedade
    AND (p_pesquisa = '' OR l.nome ILIKE '%' || p_pesquisa || '%')
    AND (p_status = '' OR l.ativo = p_status)
    AND (p_data_criacao_de = '' OR l.created_at::date >= TO_DATE(p_data_criacao_de, 'YYYY-MM-DD'))
    AND (p_data_criacao_ate = '' OR l.created_at::date <= TO_DATE(p_data_criacao_ate, 'YYYY-MM-DD'))
  ORDER BY l.id DESC
  LIMIT p_limite
  OFFSET p_offset;
$function$;

-- =============================================
-- 12. LOTES: count_lotes_filtros
-- =============================================

DROP FUNCTION IF EXISTS public.count_lotes_filtros(text, text, text);

CREATE OR REPLACE FUNCTION public.count_lotes_filtros(
  p_id_propriedade text,
  p_pesquisa text,
  p_status text,
  p_data_criacao_de text DEFAULT '',
  p_data_criacao_ate text DEFAULT ''
)
RETURNS integer
LANGUAGE sql
AS $function$
  SELECT COUNT(*)::INTEGER
  FROM public.lotes
  WHERE id_propriedade = p_id_propriedade
    AND (p_pesquisa = '' OR nome ILIKE '%' || p_pesquisa || '%')
    AND (p_status = '' OR ativo = p_status)
    AND (p_data_criacao_de = '' OR created_at::date >= TO_DATE(p_data_criacao_de, 'YYYY-MM-DD'))
    AND (p_data_criacao_ate = '' OR created_at::date <= TO_DATE(p_data_criacao_ate, 'YYYY-MM-DD'))
    AND deletado = 'NAO'
$function$;
