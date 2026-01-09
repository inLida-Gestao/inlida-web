# Propriedades para Teste dos Gráficos de Diagnósticos Reprodutivos

## Resumo da Investigação

Após análise do banco de dados, foram identificadas propriedades com dados suficientes para testar os gráficos de diagnósticos reprodutivos.

### ⚠️ Observação Importante

**Categoria dos Animais:**
- O banco de dados **não possui registros** com categoria `'Primípara'` ou `'Multípara'`
- Todos os registros de reprodução têm categoria `'Novilha'` ou `NULL`
- O gráfico "Diagnósticos Reprodutivos por Categoria" funcionará, mas mostrará apenas a categoria "Novilha"
- Isso não impede o teste dos gráficos, mas limita a visualização da distribuição por categoria

---

## 1. Diagnóstico Reprodutivos por Categoria

### Propriedades Recomendadas para Teste

#### 🥇 **Fazenda Cachoeira 2**
- **ID Propriedade:** `5rruupz1q6oiu33upggo`
- **Total de Diagnósticos:** 8.290 registros
- **Categorias:** 3 distintas (mas apenas Novilhas têm dados)
- **Novilhas:** 197 registros
- **Período de Dados:** 2014-12-25 a 2025-10-29
- **Dados com Data de Inseminação:** 8.290 (100%)
- **Dados com Data de Status:** 8.288 (99.98%)
- **Dados dentro da faixa de períodos (16-50 dias):** 4.587 registros
- **Status:** ✅ **EXCELENTE para teste** - Maior volume de dados

#### 🥈 **Fazenda Cordilheira**
- **ID Propriedade:** `kjte6tz4u6c9ywf3t237`
- **Total de Diagnósticos:** 4.559 registros
- **Categorias:** 3 distintas (mas apenas Novilhas têm dados)
- **Novilhas:** 983 registros
- **Período de Dados:** 2024-04-30 a 2026-04-29
- **Dados com Data de Inseminação:** 4.559 (100%)
- **Dados com Data de Status:** 4.554 (99.89%)
- **Dados dentro da faixa de períodos (16-50 dias):** 3.571 registros
- **Distribuição de Períodos:**
  - Período 19-21: 1 registro
  - Período 25-27: 1 registro
- **Status:** ✅ **MUITO BOM para teste** - Dados recentes e bem distribuídos

#### 🥉 **Fazenda (sem nome)**
- **ID Propriedade:** `ysmkt4wtdpayny6a2r8o`
- **Total de Diagnósticos:** 3.367 registros
- **Categorias:** 3 distintas (mas apenas Novilhas têm dados)
- **Novilhas:** 284 registros
- **Período de Dados:** 2024-04-30 a 2025-12-25
- **Dados com Data de Inseminação:** 3.367 (100%)
- **Dados com Data de Status:** 3.365 (99.94%)
- **Dados dentro da faixa de períodos (16-50 dias):** 2.959 registros
- **Distribuição de Períodos:**
  - Período 19-21: 1 registro
  - Período 25-27: 2 registros
- **Status:** ✅ **BOM para teste** - Volume significativo de dados

#### **Fazenda Brasileira**
- **ID Propriedade:** `34kro0sh872pacbnlt8e`
- **Total de Diagnósticos:** 106 registros
- **Categorias:** 3 distintas (mas apenas Novilhas têm dados)
- **Novilhas:** 27 registros
- **Período de Dados:** 2024-01-13 a 2025-11-19
- **Dados com Data de Inseminação:** 105 (99.06%)
- **Dados com Data de Status:** 106 (100%)
- **Dados dentro da faixa de períodos (16-50 dias):** 46 registros
- **Distribuição de Períodos:**
  - Período 19-21: 1 registro
- **Status:** ✅ **ADEQUADO para teste** - Volume menor, mas dados válidos

### Como Testar o Gráfico "Diagnóstico Reprodutivos por Categoria"

1. **Selecionar a Propriedade:**
   - Recomendado: **Fazenda Cachoeira 2** (`5rruupz1q6oiu33upggo`)
   - Alternativa: **Fazenda Cordilheira** (`kjte6tz4u6c9ywf3t237`)

2. **Selecionar Período:**
   - **Período Inicial:** Janeiro/2024 (ou primeiro mês com dados)
   - **Período Final:** Outubro/2025 (ou último mês com dados)
   - **Exemplo:** De Janeiro/2024 a Outubro/2025

3. **Resultado Esperado:**
   - O gráfico mostrará colunas empilhadas por período (16-18, 19-21, 22-24, etc.)
   - Como só há dados de "Novilha", apenas essa categoria aparecerá
   - O gráfico ainda funcionará corretamente, mostrando a distribuição temporal

---

## 2. Diagnóstico Realizado no Período

### Propriedades Recomendadas para Teste

#### 🥇 **Fazenda Cordilheira**
- **ID Propriedade:** `kjte6tz4u6c9ywf3t237`
- **Melhor Período para Teste:** Novembro/2025
  - **Total de Diagnósticos:** 593 registros
  - **Prenhas de IA:** 301 (50.76%)
  - **Prenhas de Touro:** 0 (0%)
  - **Vazias:** 292 (49.24%)
- **Outros Períodos com Dados:**
  - Outubro/2025: 600 diagnósticos (214 IA, 0 Touro, 386 Vazias)
  - Dezembro/2025: 5 diagnósticos (2 IA, 0 Touro, 3 Vazias)
- **Status:** ✅ **EXCELENTE para teste** - Maior volume em um único mês

#### 🥈 **Fazenda Cachoeira 2**
- **ID Propriedade:** `5rruupz1q6oiu33upggo`
- **Melhor Período para Teste:** Setembro/2025
  - **Total de Diagnósticos:** 71 registros
  - **Prenhas de IA:** 47 (66.20%)
  - **Prenhas de Touro:** 0 (0%)
  - **Vazias:** 24 (33.80%)
- **Outros Períodos com Dados:**
  - Julho/2025: 129 diagnósticos (99 IA, 0 Touro, 30 Vazias)
  - Junho/2025: 6 diagnósticos (6 IA, 0 Touro, 0 Vazias)
- **Status:** ✅ **MUITO BOM para teste** - Dados bem distribuídos

#### 🥉 **Fazenda Matão**
- **ID Propriedade:** `b1pzo7uzshs1253lv8q6`
- **Melhor Período para Teste:** Outubro/2025
  - **Total de Diagnósticos:** 22 registros
  - **Prenhas de IA:** 21 (95.45%)
  - **Prenhas de Touro:** 0 (0%)
  - **Vazias:** 1 (4.55%)
- **Outros Períodos com Dados:**
  - Setembro/2025: 54 diagnósticos (54 IA, 0 Touro, 0 Vazias)
  - Agosto/2025: 60 diagnósticos (60 IA, 0 Touro, 0 Vazias)
- **Status:** ✅ **BOM para teste** - Dados consistentes

#### **Fazenda Santo Antônio**
- **ID Propriedade:** `hlbcyqx2vom7i79qurr6`
- **Melhor Período para Teste:** Julho/2025
  - **Total de Diagnósticos:** 179 registros
  - **Prenhas de IA:** 91 (50.84%)
  - **Prenhas de Touro:** 0 (0%)
  - **Vazias:** 88 (49.16%)
- **Outros Períodos com Dados:**
  - Outubro/2025: 40 diagnósticos (39 IA, 0 Touro, 1 Vazia)
- **Status:** ✅ **ADEQUADO para teste** - Volume bom em julho

#### **Fazenda Selecta**
- **ID Propriedade:** `qlv63f0bh3tvw2rc29j7`
- **Melhor Período para Teste:** Janeiro/2026
  - **Total de Diagnósticos:** 37 registros
  - **Prenhas de IA:** 24 (64.86%)
  - **Prenhas de Touro:** 0 (0%)
  - **Vazias:** 13 (35.14%)
- **Status:** ✅ **ADEQUADO para teste** - Dados recentes

#### **Fazenda Taioba** (com Prenhas de Touro)
- **ID Propriedade:** `f43f3ykbi9i3hl1wu1u0`
- **Melhor Período para Teste:** Novembro/2025
  - **Total de Diagnósticos:** 14 registros
  - **Prenhas de IA:** 0 (0%)
  - **Prenhas de Touro:** 12 (85.71%) ⭐ **Única com dados de Touro**
  - **Vazias:** 2 (14.29%)
- **Outros Períodos com Dados:**
  - Outubro/2025: 6 diagnósticos (0 IA, 6 Touro, 0 Vazias)
- **Status:** ✅ **EXCELENTE para teste** - Única propriedade com dados de "Prenhas de Touro"

#### **Fazenda Vera Cruz / Fazenda Vera Cruz 2** (com Prenhas de Touro)
- **ID Propriedade:** `iwbb3m7f9gwxhggnzt2t` ou `1xqd00z9l4538m81hfgh`
- **Melhor Período para Teste:** Outubro/2025
  - **Total de Diagnósticos:** 14 registros
  - **Prenhas de IA:** 0 (0%)
  - **Prenhas de Touro:** 14 (100%) ⭐ **Apenas Touro**
  - **Vazias:** 0 (0%)
- **Status:** ✅ **BOM para teste** - Mostra apenas "Prenhas de Touro"

### Como Testar o Gráfico "Diagnóstico Realizado no Período"

#### Teste 1: Propriedade com Maior Volume (Recomendado)
1. **Propriedade:** Fazenda Cordilheira (`kjte6tz4u6c9ywf3t237`)
2. **Período:** Novembro/2025
3. **Resultado Esperado:**
   - Prenhas de IA: 301 (50.76%)
   - Prenhas de Touro: 0 (0%)
   - Vazias: 292 (49.24%)
   - Total: 593 (100%)

#### Teste 2: Propriedade com Prenhas de Touro (Importante)
1. **Propriedade:** Fazenda Taioba (`f43f3ykbi9i3hl1wu1u0`)
2. **Período:** Novembro/2025
3. **Resultado Esperado:**
   - Prenhas de IA: 0 (0%)
   - Prenhas de Touro: 12 (85.71%)
   - Vazias: 2 (14.29%)
   - Total: 14 (100%)

#### Teste 3: Propriedade com Mix de Dados
1. **Propriedade:** Fazenda Cachoeira 2 (`5rruupz1q6oiu33upggo`)
2. **Período:** Setembro/2025
3. **Resultado Esperado:**
   - Prenhas de IA: 47 (66.20%)
   - Prenhas de Touro: 0 (0%)
   - Vazias: 24 (33.80%)
   - Total: 71 (100%)

---

## Resumo das Propriedades para Teste

| Propriedade | ID | Gráfico 1 (Categoria) | Gráfico 2 (Período) | Observações |
|------------|-----|------------------------|---------------------|-------------|
| **Fazenda Cachoeira 2** | `5rruupz1q6oiu33upggo` | ✅ Excelente (8.290 registros) | ✅ Muito Bom | Maior volume de dados |
| **Fazenda Cordilheira** | `kjte6tz4u6c9ywf3t237` | ✅ Muito Bom (4.559 registros) | ✅ Excelente (593 em Nov/2025) | Melhor para gráfico 2 |
| **Fazenda (sem nome)** | `ysmkt4wtdpayny6a2r8o` | ✅ Bom (3.367 registros) | ⚠️ Não testado | Volume significativo |
| **Fazenda Matão** | `b1pzo7uzshs1253lv8q6` | ✅ Adequado (485 registros) | ✅ Bom | Dados consistentes |
| **Fazenda Santo Antônio** | `hlbcyqx2vom7i79qurr6` | ✅ Adequado (221 registros) | ✅ Adequado (179 em Jul/2025) | Volume bom |
| **Fazenda Taioba** | `f43f3ykbi9i3hl1wu1u0` | ⚠️ Limitado (23 registros) | ✅ Excelente (com Touro) | **Única com Touro** |
| **Fazenda Vera Cruz** | `iwbb3m7f9gwxhggnzt2t` | ✅ Adequado (598 registros) | ✅ Bom (apenas Touro) | Apenas Touro |
| **Fazenda Brasileira** | `34kro0sh872pacbnlt8e` | ✅ Adequado (106 registros) | ⚠️ Não testado | Volume menor |

---

## Recomendações Finais

### Para Teste Completo dos Dois Gráficos:

1. **Teste Principal:**
   - **Propriedade:** Fazenda Cordilheira (`kjte6tz4u6c9ywf3t237`)
   - **Gráfico 1 (Categoria):** Período de Janeiro/2024 a Dezembro/2025
   - **Gráfico 2 (Período):** Novembro/2025

2. **Teste com Dados de Touro:**
   - **Propriedade:** Fazenda Taioba (`f43f3ykbi9i3hl1wu1u0`)
   - **Gráfico 2 (Período):** Novembro/2025 (para ver "Prenhas de Touro")

3. **Teste com Maior Volume:**
   - **Propriedade:** Fazenda Cachoeira 2 (`5rruupz1q6oiu33upggo`)
   - **Gráfico 1 (Categoria):** Período de Janeiro/2024 a Outubro/2025
   - **Gráfico 2 (Período):** Setembro/2025

---

**Documento gerado em:** 2025-01-27  
**Versão:** 1.0  
**Sistema:** inLida - Gestão de Rebanho
