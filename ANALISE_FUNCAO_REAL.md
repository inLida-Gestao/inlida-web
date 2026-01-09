# Análise da Função calculate_mortality_rate - Código Real

## Função Encontrada

A função `calculate_mortality_rate` foi encontrada no banco de dados Supabase através dos MCPs:
- `supabase-inlida-web` ✅
- `supabase-lidia-mcp` ✅

Ambos os servidores acessam o mesmo banco de dados e contêm a mesma função.

## Código SQL Atual

```sql
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
    start_date := make_date(start_year, start_month, 1);
    end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - 1;

    -- Denominador: animais "em pré-desmama" em algum momento do período
    SELECT COUNT(*) INTO total_pre_desmama
    FROM public.rebanho r
    WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND r."dataNascimento" <= end_date
      AND (r."dataDesmama" IS NULL OR r."dataDesmama" >= start_date);

    -- Numerador: mortes no período que ocorreram antes (ou no dia) da desmama
    SELECT COUNT(*) INTO deaths_pre_desmama
    FROM public.rebanho r
    WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND r.data_morte IS NOT NULL
      AND r.data_morte BETWEEN start_date AND end_date
      AND r.data_morte >= r."dataNascimento"
      AND (r."dataDesmama" IS NULL OR r.data_morte <= r."dataDesmama");

    RETURN QUERY
    SELECT
      CASE
        WHEN total_pre_desmama = 0 THEN 0
        ELSE ROUND((deaths_pre_desmama::numeric / total_pre_desmama::numeric) * 100, 2)
      END AS taxa_mortalidade;
END
$function$
```

## Comparação com a Especificação

### ✅ Pontos Corretos

1. **Definição do período**: ✅ CORRETO
   - Usa `make_date(start_year, start_month, 1)` para primeiro dia
   - Usa `(make_date(end_year, end_month, 1) + interval '1 month')::date - 1` para último dia
   - Considera corretamente meses com diferentes números de dias

2. **Filtros de animais válidos**: ✅ PARCIALMENTE CORRETO
   - ✅ Filtra por `property_id` (ou `idPropriedade`)
   - ✅ Filtra `deletado IS DISTINCT FROM 'SIM'` (equivalente a `deletado = 'NAO'`)
   - ✅ Filtra `dataNascimento IS NOT NULL`
   - ✅ Filtra `tipo = 'animal'`
   - ⚠️ **FALTA**: Não filtra por categoria "bezerro(a)"

3. **Identificação de animais pré-desmama**: ✅ CORRETO
   - ✅ Verifica se `dataDesmama IS NULL` (ainda pré-desmama)
   - ✅ Verifica se `dataDesmama >= start_date` (intersecção com período)
   - ✅ Verifica se `dataNascimento <= end_date` (intersecção com período)

4. **Contagem de mortes**: ✅ CORRETO
   - ✅ Filtra mortes com `data_morte BETWEEN start_date AND end_date`
   - ✅ Verifica se `data_morte >= dataNascimento` (proteção contra dados inválidos)
   - ✅ Verifica se `data_morte <= dataDesmama` ou `dataDesmama IS NULL`
   - ⚠️ **FALTA**: Não filtra por categoria "bezerro(a)"

5. **Cálculo da taxa**: ✅ CORRETO
   - ✅ Calcula: `(deaths_pre_desmama / total_pre_desmama) * 100`
   - ✅ Arredonda para 2 casas decimais: `ROUND(..., 2)`
   - ✅ Retorna 0% se não houver animais válidos

### ❌ Problemas Identificados

#### PROBLEMA CRÍTICO 1: Falta filtro por categoria "bezerro(a)"

**Especificação diz:**
> "Considera apenas animais com categoria bezerro(a) no momento da morte"
> "Total de bezerros nascidos/comprados no período"

**Código atual:**
- Não filtra por categoria
- Inclui TODOS os animais, não apenas bezerros

**Impacto:**
- O cálculo inclui animais de todas as categorias (vacas, touros, etc.)
- O resultado não reflete apenas a mortalidade de bezerros pré-desmama

#### PROBLEMA 2: Não considera animais comprados

**Especificação diz:**
> "Total de bezerros nascidos/comprados no período"

**Código atual:**
- Considera apenas animais com `dataNascimento` no período
- Não considera animais comprados (que teriam `origem = 'Compra'` e `movimentacao_entrada` no período)

**Impacto:**
- Animais comprados no período não são contados no denominador
- A taxa pode ficar inflada se houver animais comprados que morreram

#### PROBLEMA 3: Lógica do denominador pode estar incorreta

**Especificação diz:**
> "Total de animais nascidos ou comprados no período com categoria bezerro(a)"

**Código atual:**
- Conta animais que estavam "em pré-desmama em algum momento do período"
- Isso inclui animais nascidos antes do período que ainda estavam pré-desmama

**Impacto:**
- O denominador pode incluir animais que não nasceram no período
- A especificação parece indicar que deveria contar apenas os nascidos/comprados NO período

## Recomendações de Correção

### Correção Sugerida

```sql
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
    start_date := make_date(start_year, start_month, 1);
    end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - 1;

    -- Denominador: bezerros nascidos ou comprados no período
    SELECT COUNT(*) INTO total_pre_desmama
    FROM public.rebanho r
    WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND (
          LOWER(r."categoria") LIKE '%bezerro%'
          OR LOWER(r."categoria") LIKE '%bezerra%'
      )
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
    SELECT COUNT(*) INTO deaths_pre_desmama
    FROM public.rebanho r
    WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND r.data_morte IS NOT NULL
      AND r.data_morte BETWEEN start_date AND end_date
      AND r.data_morte >= r."dataNascimento"
      AND (r."dataDesmama" IS NULL OR r.data_morte <= r."dataDesmama")
      AND (
          LOWER(r."categoria") LIKE '%bezerro%'
          OR LOWER(r."categoria") LIKE '%bezerra%'
      );

    RETURN QUERY
    SELECT
      CASE
        WHEN total_pre_desmama = 0 THEN 0
        ELSE ROUND((deaths_pre_desmama::numeric / total_pre_desmama::numeric) * 100, 2)
      END AS taxa_mortalidade;
END
$function$
```

## Resumo das Discrepâncias

| Item | Especificação | Código Atual | Status |
|------|---------------|--------------|--------|
| Filtro por categoria bezerro | ✅ Obrigatório | ❌ Não implementado | **CRÍTICO** |
| Considera animais comprados | ✅ Obrigatório | ❌ Não implementado | **IMPORTANTE** |
| Período (primeiro/último dia) | ✅ Obrigatório | ✅ Implementado | ✅ OK |
| Filtro deletado = 'NAO' | ✅ Obrigatório | ✅ Implementado | ✅ OK |
| Filtro dataNascimento IS NOT NULL | ✅ Obrigatório | ✅ Implementado | ✅ OK |
| Mortes antes da desmama | ✅ Obrigatório | ✅ Implementado | ✅ OK |
| Arredondamento 2 casas | ✅ Obrigatório | ✅ Implementado | ✅ OK |
| Retorna 0% se sem dados | ✅ Obrigatório | ✅ Implementado | ✅ OK |

## Conclusão

A função atual **NÃO está implementando corretamente** a especificação fornecida. Os problemas principais são:

1. **CRÍTICO**: Não filtra por categoria "bezerro(a)", incluindo animais de todas as categorias
2. **IMPORTANTE**: Não considera animais comprados no período, apenas nascidos

É necessário corrigir a função para que ela calcule corretamente a Taxa de Mortalidade Pré-Desmama conforme especificado.
