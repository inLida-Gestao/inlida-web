# Verificação do backend Supabase – Filtros de Reprodução

## Onde fica o backend

As chamadas do app usam **Supabase RPC** (PostgreSQL), não Edge Functions:

- **Base URL:** `https://eqrtgsqnxxnfjjzlxpuj.supabase.co/rest/v1/rpc`
- **Listagem:** `POST /rpc/reproducao_filtros`
- **Contagem:** `POST /rpc/contar_reproducao_filtros`

O corpo da requisição é JSON; as chaves são os **nomes dos parâmetros** da função no banco.  
O código das funções **não está neste repositório**; fica no projeto Supabase (Dashboard → Database → Functions ou migrations).

---

## Contrato enviado pelo app

### 1. `reproducao_filtros` (listagem paginada)

| Parâmetro (body JSON)   | Tipo   | Uso no app                          | Uso esperado no SQL                    |
|-------------------------|--------|-------------------------------------|----------------------------------------|
| `p_id_propriedade`      | string | ID da propriedade selecionada       | `WHERE id_propriedade = p_id_propriedade` |
| `p_data_reproducao`     | string | Data reprodução (yyyy-MM-dd ou '')  | Filtrar por data da inseminação/reprodução |
| `p_data_previsao_parto` | string | Previsão parto (yyyy-MM-dd ou '')   | Filtrar por `previsao_parto`           |
| `p_tipo_reproducao`     | string | Categoria (ex.: Bezerra, Novilha)   | Filtrar por `categoria` na view       |
| `p_lote_nome`          | string | Nome do lote                        | Filtrar por `loteNome`                 |
| `p_inseminador`         | string | Nome do inseminador                 | Filtrar por `inseminador`             |
| `p_matriz`              | string | ID rebanho da matriz (idAnimal)     | Filtrar por `id_rebanho_matriz`        |
| `p_reprodutor`          | string | ID rebanho do reprodutor            | Filtrar por `id_rebanho_reprodutor`    |
| `p_pesquisa`            | string | Texto livre                         | Busca em nome/número matriz/reprodutor |
| `p_limite`              | number | Tamanho da página                   | `LIMIT p_limite`                      |
| `p_offset`              | number | Offset paginação                    | `OFFSET p_offset`                     |
| `p_sort_column`         | string | Coluna ordenação (ex.: data)        | `ORDER BY`                            |
| `p_sort_direction`      | string | 'asc' ou 'desc'                     | Direção do `ORDER BY`                 |

Quando o app não aplica filtro, envia **string vazia** (`""`) para texto e datas; o backend deve **ignorar** o filtro nesses casos (não exigir valor).

### 2. `contar_reproducao_filtros` (total de registros)

Mesmos filtros da listagem, **sem** `p_limite`, `p_offset`, `p_sort_column`, `p_sort_direction`:

- `p_id_propriedade`, `p_data_reproducao`, `p_data_previsao_parto`, `p_tipo_reproducao`, `p_lote_nome`, `p_inseminador`, `p_matriz`, `p_reprodutor`, `p_pesquisa`

Retorno esperado: um número (total de linhas que batem com os filtros).

---

## View esperada

O app monta a lista a partir de uma estrutura que bate com a **view** `view_reproducao_detalhada` (ou com um `SELECT` que exponha as mesmas colunas). Principais colunas usadas no filtro e no resultado:

- `id_propriedade`, `id_rebanho_matriz`, `id_rebanho_reprodutor`
- `data_inseminacao`, `previsao_parto`, `data_inicial` / `data_final`
- `tipo_reproducao`, `categoria`, `loteNome`, `inseminador`
- `status_reproducao`, `id_reproducao`, `deletado`
- Colunas de matriz/reprodutor (nome, número, data nascimento, etc.) e `ressinc`, `parida`, `data_parto`

A função deve consultar essa view (ou a query equivalente) e aplicar os filtros em cima dela.

---

## O que conferir no Supabase

1. **Database → Functions**
   - Existem as funções `reproducao_filtros` e `contar_reproducao_filtros`?
   - Os **nomes e tipos** dos parâmetros batem exatamente com a tabela acima (incluindo o prefixo `p_`)?

2. **Lógica dos filtros**
   - `p_id_propriedade`: sempre aplicado quando enviado.
   - `p_data_reproducao`: quando não vazio, filtrar por data da reprodução (ex.: `data_inseminacao::date` ou `data_inicial`).
   - `p_data_previsao_parto`: quando não vazio, filtrar por `previsao_parto`.
   - `p_tipo_reproducao`: quando não vazio, filtrar por `categoria`.
   - `p_lote_nome`: quando não vazio, filtrar por `loteNome` (ex.: `= p_lote_nome` ou `ILIKE`).
   - `p_inseminador`: quando não vazio, filtrar por `inseminador`.
   - `p_matriz`: quando não vazio, filtrar por `id_rebanho_matriz = p_matriz`.
   - `p_reprodutor`: quando não vazio, filtrar por `id_rebanho_reprodutor = p_reprodutor`.
   - `p_pesquisa`: quando não vazio, usar `ILIKE` em nome/número da matriz e do reprodutor.

3. **Retorno**
   - `reproducao_filtros`: conjunto de linhas com as colunas da view (em snake_case), para bater com `ReproducaoDTStruct.fromMap` no app.
   - `contar_reproducao_filtros`: um único valor numérico (total).

Se alguma dessas funções não existir ou não aplicar um dos filtros acima, os filtros correspondentes “não vão funcionar” no app, mesmo com o front corrigido.

---

## Script SQL de referência

Foi gerado o arquivo `supabase/migrations/verificacao_reproducao_filtros.sql` com funções de exemplo que aplicam **todos** os filtros. Use como referência para:

- Criar as funções pela primeira vez, ou  
- Comparar/ajustar as funções já existentes no projeto.

Depois de alterar as funções no Supabase, rode os testes do app (filtros por data, previsão de parto, categoria, lote, inseminador, matriz e reprodutor) para validar.
