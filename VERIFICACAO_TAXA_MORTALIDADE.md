# Verificação da Taxa de Mortalidade Pré-Desmama

## Resumo da Análise

✅ **FUNÇÃO ENCONTRADA**: A função `calculate_mortality_rate` foi localizada no banco de dados através do MCP `supabase-inlida-web`.

❌ **PROBLEMAS IDENTIFICADOS**: A função atual **NÃO está implementando corretamente** a especificação. Veja `ANALISE_FUNCAO_REAL.md` para detalhes completos.

### Problemas Críticos Encontrados:
1. **Falta filtro por categoria "bezerro(a)"** - A função inclui animais de todas as categorias
2. **Não considera animais comprados** - Apenas conta animais nascidos, não comprados no período

## Estrutura de Dados Identificada

### Tabela: `rebanho`

Campos relevantes identificados no código:
- `idPropriedade` (String) - ID da propriedade
- `dataNascimento` (DateTime?) - Data de nascimento do animal
- `dataDesmama` (DateTime?) - Data de desmama do animal
- `data_morte` (DateTime?) - Data de morte do animal (campo `dataMorte` no Dart)
- `categoria` (String?) - Categoria do animal (ex: "bezerro(a)")
- `deletado` (String?) - Flag de deletado (valor esperado: "NAO" para não deletado)
- `origem` (String?) - Origem do animal (nascimento/compra)

## Especificação Esperada

### Lógica de Cálculo

1. **Define o período**: Primeiro ao último dia do mês selecionado
2. **Seleciona animais válidos**:
   - Animais da propriedade escolhida (`idPropriedade`)
   - Animais não deletados (`deletado = 'NAO'`)
   - Animais com data de nascimento informada (`dataNascimento IS NOT NULL`)
3. **Identifica animais pré-desmama**:
   - Do nascimento até a data de desmama
   - Se não houver data de desmama, o animal é considerado ainda pré-desmama
4. **Conta as mortes**:
   - Apenas mortes que aconteceram antes da desmama
   - Dentro do período analisado
   - Animais com categoria "bezerro(a)"
5. **Fórmula**:
   ```
   (Mortes de bezerros no período ÷ Total de bezerros nascidos/comprados no período) × 100
   ```
   - Arredondado para duas casas decimais
   - Se não houver animais válidos, retorna 0%

## Parâmetros da Função

A função recebe os seguintes parâmetros:
- `property_id` (String) - ID da propriedade
- `start_year` (Integer) - Ano inicial
- `start_month` (Integer) - Mês inicial (1-12)
- `end_year` (Integer) - Ano final
- `end_month` (Integer) - Mês final (1-12)

## Script SQL de Referência

Abaixo está um script SQL que implementa a lógica esperada conforme a especificação:

```sql
CREATE OR REPLACE FUNCTION calculate_mortality_rate(
    property_id TEXT,
    start_year INTEGER,
    start_month INTEGER,
    end_year INTEGER,
    end_month INTEGER
)
RETURNS TABLE(taxa_mortalidade NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    data_inicio DATE;
    data_fim DATE;
    total_mortes INTEGER;
    total_animais INTEGER;
    taxa NUMERIC;
BEGIN
    -- 1. Define o período: primeiro ao último dia do mês
    data_inicio := DATE(start_year || '-' || LPAD(start_month::TEXT, 2, '0') || '-01');
    data_fim := (DATE(end_year || '-' || LPAD(end_month::TEXT, 2, '0') || '-01') + INTERVAL '1 month - 1 day')::DATE;
    
    -- 2. Conta mortes de bezerros pré-desmama no período
    SELECT COUNT(*)
    INTO total_mortes
    FROM rebanho
    WHERE "idPropriedade" = property_id
        AND "deletado" = 'NAO'
        AND "dataNascimento" IS NOT NULL
        AND "data_morte" IS NOT NULL
        AND "data_morte" >= data_inicio
        AND "data_morte" <= data_fim
        AND (
            "dataDesmama" IS NULL 
            OR "data_morte" < "dataDesmama"
        )
        AND (
            LOWER("categoria") LIKE '%bezerro%'
            OR LOWER("categoria") LIKE '%bezerra%'
        );
    
    -- 3. Conta total de bezerros nascidos/comprados no período
    SELECT COUNT(*)
    INTO total_animais
    FROM rebanho
    WHERE "idPropriedade" = property_id
        AND "deletado" = 'NAO'
        AND "dataNascimento" IS NOT NULL
        AND (
            ("dataNascimento" >= data_inicio AND "dataNascimento" <= data_fim)
            OR (
                "origem" = 'Compra' 
                AND "movimentacao_entrada" >= data_inicio 
                AND "movimentacao_entrada" <= data_fim
            )
        )
        AND (
            LOWER("categoria") LIKE '%bezerro%'
            OR LOWER("categoria") LIKE '%bezerra%'
        );
    
    -- 4. Calcula a taxa
    IF total_animais > 0 THEN
        taxa := ROUND((total_mortes::NUMERIC / total_animais::NUMERIC) * 100, 2);
    ELSE
        taxa := 0.00;
    END IF;
    
    RETURN QUERY SELECT taxa;
END;
$$;
```

## Pontos de Verificação

### ✅ Verificados no Código Flutter

1. **Estrutura da tabela**: Confirmada através do arquivo `rebanho.dart`
2. **Parâmetros da função**: Confirmados em `api_calls.dart` (linhas 1067-1111)
3. **Chamada da função**: Confirmada em `painel_widget.dart` (linhas 1947-2044)
4. **Exibição do resultado**: O resultado é extraído do campo `taxa_mortalidade` e exibido como percentual

### ⚠️ Requer Verificação no Supabase

1. **Código SQL da função**: Necessário acessar o Supabase Dashboard do projeto `eqrtgsqnxxnfjjzlxpuj`
2. **Lógica de cálculo**: Verificar se implementa corretamente:
   - Definição correta do período (primeiro ao último dia do mês)
   - Filtros de animais válidos
   - Identificação de animais pré-desmama
   - Contagem de mortes antes da desmama
   - Cálculo correto da taxa
   - Arredondamento para 2 casas decimais

## Próximos Passos

1. Acessar o Supabase Dashboard do projeto `eqrtgsqnxxnfjjzlxpuj`
2. Navegar para **Database** → **Functions** ou **SQL Editor**
3. Localizar a função `calculate_mortality_rate`
4. Comparar o código SQL com a especificação e o script de referência acima
5. Testar a função com dados reais e validar os resultados

## Notas Importantes

- A função está em uma RPC do Supabase, não em uma Edge Function
- O endpoint é: `https://eqrtgsqnxxnfjjzlxpuj.supabase.co/rest/v1/rpc/calculate_mortality_rate`
- O campo de data de morte no banco é `data_morte` (snake_case), mas no código Dart é acessado como `dataMorte` (camelCase)
- O campo `deletado` usa o valor `'NAO'` para indicar que não está deletado
