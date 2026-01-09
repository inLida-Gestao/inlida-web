# Documentação: Gráficos de Diagnósticos Reprodutivos

## Visão Geral

Este documento detalha o funcionamento e os cálculos dos gráficos de diagnósticos reprodutivos disponíveis no painel do sistema inLida. Os gráficos fornecem informações importantes sobre o desempenho reprodutivo do rebanho, permitindo acompanhar diagnósticos realizados e sua distribuição por categoria de animais.

---

## 1. Diagnósticos Reprodutivos por Categoria

### Descrição

Este gráfico apresenta a distribuição dos diagnósticos reprodutivos agrupados por:
- **Período após inseminação** (em dias)
- **Categoria do animal** (Novilha, Primípara, Multípara)

O gráfico utiliza colunas empilhadas, onde cada coluna representa um período e as cores indicam a quantidade de diagnósticos por categoria.

### Como o Sistema Calcula

#### 1.1. Período Analisado

O sistema considera diagnósticos realizados dentro de um período selecionado pelo usuário:
- **Data inicial**: Primeiro dia do mês inicial selecionado
- **Data final**: Último dia do mês final selecionado

**Exemplo:**
- Se o usuário selecionar de Janeiro/2024 a Março/2024:
  - Data inicial: 2024-01-01
  - Data final: 2024-03-31

#### 1.2. Seleção de Registros

O sistema considera apenas registros de reprodução que atendem aos seguintes critérios:

✅ **Filtros aplicados:**
- Animais da propriedade selecionada
- Registros não deletados (`deletado = 'NAO'`)
- Status de reprodução: `'Prenhez'` ou `'Vazio'`
- Data do diagnóstico ou data de inseminação dentro do período selecionado

#### 1.3. Cálculo do Período Após Inseminação

Para cada registro, o sistema calcula quantos dias se passaram entre a inseminação e o diagnóstico:

```
Dias após inseminação = Data do diagnóstico - Data de inseminação
```

**Regras:**
- Se houver `data_status` (data do diagnóstico), usa: `data_status - data_inseminacao`
- Se não houver `data_status`, mas houver `data_inseminacao`, usa: `Data atual - data_inseminacao`
- Se não houver nenhuma das duas datas, o registro é ignorado

#### 1.4. Agrupamento por Períodos

Os diagnósticos são agrupados em faixas de dias após a inseminação:

| Faixa de Dias | Label no Gráfico | Descrição |
|---------------|------------------|-----------|
| 16-18 dias | `16-18` | Diagnóstico muito precoce |
| 19-21 dias | `19-21` | Diagnóstico precoce |
| 22-24 dias | `22-24` | Diagnóstico no período ideal |
| 25-27 dias | `25-27` | Diagnóstico no período ideal |
| 28-30 dias | `28-30` | Diagnóstico no período ideal |
| 30-32 dias | `30-01` | Diagnóstico tardio |
| 33-35 dias | `01-03` | Diagnóstico muito tardio |
| 36-38 dias | `04-06` | Diagnóstico muito tardio |
| 39-41 dias | `06-08` | Diagnóstico muito tardio |
| 42-44 dias | `08-10` | Diagnóstico muito tardio |
| 45-47 dias | `11-13` | Diagnóstico muito tardio |
| 48-50 dias | `14-16` | Diagnóstico muito tardio |

#### 1.5. Agrupamento por Categoria

Para cada período, o sistema conta quantos diagnósticos foram realizados em cada categoria:

- **Novilha**: Animais com `categoria = 'Novilha'`
- **Primípara**: Animais com `categoria = 'Primípara'`
- **Multípara**: Animais com `categoria = 'Multípara'`

#### 1.6. Visualização

O gráfico exibe:
- **Eixo X**: Períodos (labels: 16-18, 19-21, 22-24, etc.)
- **Eixo Y**: Quantidade de diagnósticos (escala de 0 a 100)
- **Colunas empilhadas**: Cada coluna mostra a distribuição por categoria
  - Verde escuro: Novilha
  - Verde médio: Primípara
  - Verde claro: Multípara

### Exemplo de Cálculo

**Cenário:**
- Período selecionado: Janeiro/2024 a Março/2024
- Propriedade: "Fazenda ABC"

**Processo:**
1. Sistema busca todos os registros de reprodução da propriedade "Fazenda ABC" com status 'Prenhez' ou 'Vazio' e data entre 2024-01-01 e 2024-03-31
2. Para cada registro, calcula: `dias_apos_inseminacao = data_status - data_inseminacao`
3. Agrupa por faixa de dias (ex: 22-24 dias)
4. Conta quantos são de cada categoria (Novilha, Primípara, Multípara)
5. Exibe no gráfico

**Resultado:**
- Período 22-24: 5 Novilhas, 8 Primíparas, 12 Multíparas
- Período 25-27: 3 Novilhas, 10 Primíparas, 15 Multíparas
- E assim por diante...

---

## 2. Diagnósticos Realizados no Período

### Descrição

Este gráfico apresenta um resumo dos diagnósticos realizados em um mês específico, agrupados por situação reprodutiva. É exibido em formato de tabela com três colunas: Situação, Total e Porcentagem.

### Como o Sistema Calcula

#### 2.1. Período Analisado

O sistema considera diagnósticos realizados em um **mês específico**:
- **Mês**: Selecionado pelo usuário (1 a 12)
- **Ano**: Selecionado pelo usuário

**Exemplo:**
- Se o usuário selecionar Janeiro/2024:
  - Mês: 1
  - Ano: 2024
  - O sistema analisa todos os diagnósticos realizados em janeiro de 2024

#### 2.2. Seleção de Registros

O sistema considera apenas registros de reprodução que atendem aos seguintes critérios:

✅ **Filtros aplicados:**
- Animais da propriedade selecionada
- Registros não deletados (`deletado = 'NAO'`)
- Status de reprodução: `'Prenhez'` ou `'Vazio'`
- Mês e ano do diagnóstico correspondem ao período selecionado

**Data utilizada:**
- Se houver `data_status` (data do diagnóstico), usa essa data
- Se não houver `data_status`, usa `data_inseminacao` como referência

#### 2.3. Cálculo por Situação

O sistema agrupa os diagnósticos em três categorias:

##### 2.3.1. Prenhas de IA (Inseminação Artificial)

**Critérios:**
- `status_reproducao = 'Prenhez'`
- `tipo_reproducao = 'Inseminação'`
- Mês e ano do diagnóstico = período selecionado

**Cálculo:**
```
Total de Prenhas de IA = COUNT(*) WHERE status = 'Prenhez' AND tipo = 'Inseminação'
```

##### 2.3.2. Prenhas de Touro (Monta Natural)

**Critérios:**
- `status_reproducao = 'Prenhez'`
- `tipo_reproducao = 'Monta Natural'`
- Mês e ano do diagnóstico = período selecionado

**Cálculo:**
```
Total de Prenhas de Touro = COUNT(*) WHERE status = 'Prenhez' AND tipo = 'Monta Natural'
```

##### 2.3.3. Vazias

**Critérios:**
- `status_reproducao = 'Vazio'`
- Mês e ano do diagnóstico = período selecionado

**Cálculo:**
```
Total de Vazias = COUNT(*) WHERE status = 'Vazio'
```

#### 2.4. Cálculo do Total Geral

O total geral é a soma de todos os diagnósticos (Prenhes + Vazias) no período:

```
Total Geral = Prenhas de IA + Prenhas de Touro + Vazias
```

#### 2.5. Cálculo das Porcentagens

Para cada situação, o sistema calcula a porcentagem em relação ao total geral:

**Fórmula:**
```
Porcentagem = (Total da Situação ÷ Total Geral) × 100
```

**Exemplos:**
- Prenhas de IA: `(Prenhas de IA ÷ Total Geral) × 100`
- Prenhas de Touro: `(Prenhas de Touro ÷ Total Geral) × 100`
- Vazias: `(Vazias ÷ Total Geral) × 100`
- Total: `100%` (sempre)

**Arredondamento:** 2 casas decimais

#### 2.6. Visualização

A tabela exibe:

| Situação | Total | Porcentagem |
|----------|-------|-------------|
| Prenhas de IA | 45 | 52.94% |
| Prenhas de Touro | 20 | 23.53% |
| Vazias | 20 | 23.53% |
| **Total** | **85** | **100.00%** |

A linha "Total" é destacada visualmente (fundo cinza claro e texto em negrito).

### Exemplo de Cálculo

**Cenário:**
- Período: Janeiro/2024 (Mês: 1, Ano: 2024)
- Propriedade: "Fazenda ABC"

**Processo:**
1. Sistema busca todos os registros de reprodução da propriedade "Fazenda ABC" com:
   - `deletado = 'NAO'`
   - `status_reproducao IN ('Prenhez', 'Vazio')`
   - Mês e ano do diagnóstico = Janeiro/2024

2. Conta por situação:
   - Prenhas de IA: 45 registros
   - Prenhas de Touro: 20 registros
   - Vazias: 20 registros

3. Calcula total geral: 45 + 20 + 20 = 85

4. Calcula porcentagens:
   - Prenhas de IA: (45 ÷ 85) × 100 = 52.94%
   - Prenhas de Touro: (20 ÷ 85) × 100 = 23.53%
   - Vazias: (20 ÷ 85) × 100 = 23.53%
   - Total: 100.00%

**Resultado na tabela:**
| Situação | Total | Porcentagem |
|----------|-------|-------------|
| Prenhas de IA | 45 | 52.94% |
| Prenhas de Touro | 20 | 23.53% |
| Vazias | 20 | 23.53% |
| **Total** | **85** | **100.00%** |

---

## 3. Considerações Importantes

### 3.1. Dados Utilizados

- **Tabela principal**: `reproducao`
- **Campos principais**:
  - `id_propriedade`: Identifica a propriedade
  - `deletado`: Filtra registros ativos
  - `status_reproducao`: Status do diagnóstico ('Prenhez' ou 'Vazio')
  - `tipo_reproducao`: Tipo de reprodução ('Inseminação' ou 'Monta Natural')
  - `categoria`: Categoria do animal ('Novilha', 'Primípara', 'Multípara')
  - `data_inseminacao`: Data da inseminação
  - `data_status`: Data do diagnóstico

### 3.2. Tratamento de Dados Faltantes

- Se `data_status` não estiver preenchida, o sistema usa `data_inseminacao` como referência
- Registros sem `data_inseminacao` e sem `data_status` são ignorados
- Registros deletados (`deletado = 'SIM'`) são sempre ignorados

### 3.3. Performance

- Os cálculos são realizados no banco de dados (PostgreSQL) para garantir performance
- As funções SQL são otimizadas para processar grandes volumes de dados rapidamente

### 3.4. Atualização dos Dados

- Os gráficos são atualizados automaticamente quando:
  - O usuário altera o período selecionado
  - O usuário altera a propriedade selecionada
  - Os dados são recarregados na página

---

## 4. Interpretação dos Resultados

### 4.1. Diagnósticos Reprodutivos por Categoria

**O que observar:**
- **Distribuição temporal**: Verificar se os diagnósticos estão concentrados nos períodos ideais (22-30 dias)
- **Distribuição por categoria**: Comparar o desempenho entre Novilhas, Primíparas e Multíparas
- **Diagnósticos tardios**: Identificar se há muitos diagnósticos após 30 dias (pode indicar problemas no manejo)

**Indicadores de qualidade:**
- ✅ Maioria dos diagnósticos entre 22-30 dias
- ✅ Distribuição equilibrada entre categorias
- ⚠️ Muitos diagnósticos antes de 20 dias ou após 35 dias

### 4.2. Diagnósticos Realizados no Período

**O que observar:**
- **Taxa de prenhez**: Percentual de animais prenhes em relação ao total
- **Eficiência da IA vs. Monta Natural**: Comparar resultados entre os dois métodos
- **Taxa de vazias**: Percentual de animais vazios (pode indicar problemas reprodutivos)

**Indicadores de qualidade:**
- ✅ Taxa de prenhez acima de 50%
- ✅ Taxa de vazias abaixo de 30%
- ✅ Comparação equilibrada entre IA e Monta Natural

---

## 5. Suporte Técnico

Para dúvidas ou problemas relacionados aos gráficos de diagnósticos reprodutivos, entre em contato com o suporte técnico do inLida.

**Informações técnicas:**
- Função SQL: `get_diagnosticos_por_categoria` e `get_diagnosticos_periodo`
- Edge Functions: `reproducao-diagnosticos-categoria` e `reproducao-diagnosticos-periodo`
- Tabela de dados: `reproducao`

---

**Documento gerado em:** 2025-01-27  
**Versão:** 1.0  
**Sistema:** inLida - Gestão de Rebanho
