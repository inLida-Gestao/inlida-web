-- Migração: Corrigir função calculate_mortality_rate
-- Data: 2025-01-27
-- Descrição: Adiciona filtro por categoria bezerro(a) e considera animais comprados

CREATE OR REPLACE FUNCTION public.calculate_mortality_rate(
    property_id text DEFAULT NULL::text, 
    start_year integer DEFAULT ((EXTRACT(year FROM CURRENT_DATE))::integer - 5), 
    start_month integer DEFAULT 1, 
    end_year integer DEFAULT (EXTRACT(year FROM CURRENT_DATE))::integer, 
    end_month integer DEFAULT 12
)
RETURNS TABLE(taxa_mortalidade numeric)
LANGUAGE plpgsql
AS $function$
DECLARE
    start_date date;
    end_date date;
    total_pre_desmama bigint;
    deaths_pre_desmama bigint;
BEGIN
    -- Define o período: primeiro ao último dia do mês
    start_date := make_date(start_year, start_month, 1);
    end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - 1;

    -- Denominador: bezerros nascidos ou comprados no período
    -- Conforme especificação: "Total de bezerros nascidos/comprados no período"
    SELECT COUNT(*) INTO total_pre_desmama
    FROM public.rebanho r
    WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      -- Filtro por categoria bezerro(a) - ADICIONADO
      AND (
          LOWER(r."categoria") LIKE '%bezerro%'
          OR LOWER(r."categoria") LIKE '%bezerra%'
      )
      -- Animais nascidos ou comprados no período - CORRIGIDO
      AND (
          -- Nascidos no período
          (r."dataNascimento" >= start_date AND r."dataNascimento" <= end_date)
          OR
          -- Comprados no período
          (
              r."origem" = 'Compra' 
              AND r."movimentacao_entrada" IS NOT NULL
              AND r."movimentacao_entrada" >= start_date 
              AND r."movimentacao_entrada" <= end_date
          )
      );

    -- Numerador: mortes de bezerros no período que ocorreram antes da desmama
    -- Conforme especificação: "Mortes dos animais com categoria bezerro(a) no período"
    SELECT COUNT(*) INTO deaths_pre_desmama
    FROM public.rebanho r
    WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND r.data_morte IS NOT NULL
      AND r.data_morte BETWEEN start_date AND end_date
      AND r.data_morte >= r."dataNascimento"
      -- Morte antes da desmama - CONFORME ESPECIFICAÇÃO
      AND (r."dataDesmama" IS NULL OR r.data_morte <= r."dataDesmama")
      -- Filtro por categoria bezerro(a) - ADICIONADO
      AND (
          LOWER(r."categoria") LIKE '%bezerro%'
          OR LOWER(r."categoria") LIKE '%bezerra%'
      );

    -- Calcula a taxa: (mortes / total) * 100
    -- Arredondado para 2 casas decimais conforme especificação
    RETURN QUERY
    SELECT
      CASE
        WHEN total_pre_desmama = 0 THEN 0
        ELSE ROUND((deaths_pre_desmama::numeric / total_pre_desmama::numeric) * 100, 2)
      END AS taxa_mortalidade;
END
$function$;

-- Comentário da função atualizada
COMMENT ON FUNCTION public.calculate_mortality_rate IS 
'Calcula a Taxa de Mortalidade Pré-Desmama (%) conforme especificação:
- Considera apenas animais com categoria bezerro(a)
- Inclui animais nascidos ou comprados no período
- Conta apenas mortes que ocorreram antes da desmama e dentro do período
- Fórmula: (Mortes de bezerros no período ÷ Total de bezerros nascidos/comprados no período) × 100';
