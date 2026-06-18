# Auditoria de Tarefas — Módulo PAINT

Auditoria das tarefas/subtarefas solicitadas, cruzando cada item com o código
real do sistema e com o manual (`docs/MANUAL_PAINT_INLIDA.md`).

> Atualização: os itens de ação levantados na primeira auditoria foram tratados
> nesta rodada. Veja a seção "Itens que exigiam ação — situação após correção".

Fontes verificadas:
- Exportação (Edge Function): `supabase/functions/paint-export/lib/generators.ts`,
  `layouts.ts`, `paint_mappers.ts`, `fixed-width.ts`, `validate.ts`.
- App Flutter: `lib/pg_paint/pg_paint/pg_paint_widget.dart`,
  `lib/custom_code/actions/import_paint_avaliacao_excel.dart`,
  `export_paint_avaliacao_excel.dart`, `auto_preencher_paint.dart`.
- Banco: `supabase/migrations/20260615120000_paint_export_corrections.sql`.

## Legenda

- ✅ Implementado no sistema **e** coberto no manual.
- 🟡 Parcial / pendente de confirmação externa (PAINT/produto).
- ❌ Não funciona (bug) — precisa correção.

## Resumo do veredito (após correções)

- Total auditado: **40 subtarefas**.
- ✅ Plenamente contempladas (sistema + manual): **38**.
- 🟡 Pendentes de confirmação externa: **2** (interpretação dos extras de `RACA`;
  fluxo de UI para embrião).
- ❌ Com bug: **0**.

---

## 1. PAINT — Exportação geral e filtros (3)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Identificador único (A12 + nº + data nasc.) | ✅ A importação valida A12 × `numeroAnimal` × `Data_Nascimento`; exportação usa A12 como chave | ✅ Seção 9 |
| Filtro na exportação por data nasc. e avaliação | ✅ **Resolvido por design**: o ZIP exporta tudo (decisão PAINT); os filtros valem para "Importar tudo" e planilhas | ✅ Seções 7, 8, 13 e 19 |
| Filtro em Matrizes antes de "Com dados da fazenda" | ✅ Botão de filtro (nasc. + avaliação) por tipo, inclusive matrizes (`pg_paint_widget.dart` ~1999) | ✅ Seção 8 |

---

## 2. PAINT — Tabela ANIMAL (13)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Avaliação exportada após lançada | ✅ RAH refletido em `ANIMAL` (`rahByA12`) | ✅ Seções 10/15 |
| Exportação do nome do pai | ✅ `ani_pai` = **A12 do pai** (conforme o layout) | ✅ Seção 15 |
| Validar obrigatoriedade `tipo_animal` | ✅ Aviso na pré-validação: "Animal PO sem tipo de registro definido" (`validate.ts`) | ✅ Seções 6/14 |
| Preencher campo tipo do animal | ✅ `ani_tipo` = `mapTipoRegistro` | ✅ Seção 6 |
| `recno` dentro do limite | ✅ `ani_recno` tipo N(9), alinhado à direita | ✅ Seção 15 |
| Corrigir `animal_grupo` | ✅ `ani_grupo_manejo` via lote (`grupoManejoFromLote`) | ✅ Seção 15 |
| Validar obrigatoriedade raça | ✅ Erro em `validate.ts` (animal sem raça) | ✅ Seção 14 |
| Categoria anterior sem histórico | ✅ `mapCategoriaAnterior` (deriva por evento) | ✅ Seção 19 |
| Regra da série no A12 para PO | ✅ `resolveSerieA12` (JLK) | ✅ Seção 5 |
| Montagem do A12 do Touro | ✅ Touro é animal do rebanho; `a12FromRebanho` alimenta `ani_pai`/`cob_touro` | ✅ Seções 5/15 |
| Corrigir `animal_categoria` | ✅ `mapCategoriaPaint` | ✅ Seção 19 |
| `rac1/rac2` = grau sanguíneo | 🟡 Grau sanguíneo está em **COMPOSICAO_RACIAL** (`cpr_indice`); extras da `RACA` documentados e pendentes de confirmação com o PAINT | 🟡 Seção 15 (esclarecido) |
| Validar obrigatoriedade de brinco | ✅ Erro na pré-validação para **todos** os animais sem brinco numérico (`validate.ts`) | ✅ Seção 14 |

---

## 3. PAINT — Tabela COMPOSIÇÃO RACIAL (1)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Corrigir `recno` | ✅ `cpr_recno` N(9), sequencial | ✅ Seção 15 |

---

## 4. PAINT — Cadastros automáticos e regras especiais (2)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Embrião como sêmen (mãe e pai real) | 🟡 `cob_tipo = E`; doadora/pai em ANIMAL e receptora em cobertura/nascimento. **Sem fluxo de UI dedicado** (pendência de produto) | 🟡 Seção 19 (regra descrita) |
| Auto → TXT (inseminador, grupo, regime, avaliador) | ✅ `autoPreencherPaint` cria e geradores exportam | ✅ Seções 7/11 |

---

## 5. PAINT — Tabela NASCIMENTO (4)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Espaçamento de `nas_prev` | ✅ `nas_prevparto` tipo D(10) | ✅ Seção 15 |
| Peso ao nascimento | ✅ `nas_peso` = `pesoNascimento` | ✅ Seção 15 |
| A12 do pai | ✅ `nas_pai` = `paiA12` | ✅ Seção 15 |
| Data de nascimento | ✅ `nas_data_nasc` | ✅ Seção 15 |

---

## 6. PAINT — Tabela DESMAMA (3)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Incluir notas | ✅ `dsm_nota_c/p/m/u` (validado por e2e) | ✅ Seções 10/15 |
| Espaçamento `recno` | ✅ `dsm_recno` N(9) | ✅ Seção 15 |
| Regime alimentar e grupo de manejo | ✅ `dsm_regime_alimentar_animal` + `dsm_grupo_manejo` | ✅ Seções 10/15 |

---

## 7. PAINT — Regra de montagem e espaçamento do A12 (4)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| NASCIMENTO — espaçamento A12 (animal e cria) | ✅ `nas_animal`/`nas_animal_produto_id` + `formatA12` à esquerda | ✅ Seção 5 |
| COBERTURA — espaçamento A12 | ✅ `cob_animal_id`/`cob_touro` C(12) | ✅ Seção 5 |
| COMPOSIÇÃO — espaçamento A12 | ✅ `cpr_animal_id` C(12) | ✅ Seção 5 |
| Bug 1 — alinhamento do A12 | ✅ Campo Animal à esquerda + migration de realinhamento | ✅ Seção 5 |

---

## 8. PAINT — Tabela ANO_SOBREANO (5)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| `sbr_local` não obrigatório | ✅ Exportado quando presente, sem validação | ✅ Seção 15 |
| Notas que não subiam | ✅ `sbr_nota_c..nota_a` preenchidas (regressão corrigida) | ✅ Seções 10/15 |
| Incluir `sbr_avaliador` | ✅ `sbr_avaliador` | ✅ Seção 15 |
| Incluir `sbr_grupo` | ✅ `sbr_grupo_manejo` | ✅ Seção 15 |
| Espaçamento `recno` | ✅ `sbr_recno` N(9) | ✅ Seção 15 |

---

## 9. PAINT — Tabela DIAGNÓSTICO (1)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Incluir grupo de manejo | ✅ `dgn_grpmanejo_id` | ✅ Seção 15 |

---

## 10. PAINT — Tabela COBERTURA (4)

| Subtarefa | Sistema | Manual |
|-----------|---------|--------|
| Incluir `cob_grpm` | ✅ `cob_grpmanejo_id` (grupo da matriz via lote) | ✅ Seção 15 |
| Espaçamento `recno` | ✅ `cob_recno` N(9) | ✅ Seção 15 |
| Incluir `cob_inseminador` | ✅ **Corrigido**: `genCobertura` agora lê `reproducao.inseminador` e resolve o código via `paint_inseminador` (`loadInseminadorByNome`) | ✅ Seção 15 |
| Incluir A12 do touro | ✅ `cob_touro` = `touroA12` | ✅ Seção 15 |

---

## Itens que exigiam ação — situação após correção

1. ✅ **COBERTURA → `cob_inseminador` (corrigido).** `genCobertura` passou a
   incluir `inseminador` no `SELECT` e a resolver o código do inseminador a
   partir do nome via novo helper `loadInseminadorByNome` (mapeia
   `paint_inseminador.nome` → `codigo`). Antes o campo saía sempre vazio.
2. ✅ **Filtro na "exportação" (resolvido por design).** Confirmado que o ZIP não
   é filtrado por data (o PAINT recebe todos os dados); os filtros atuam apenas
   nas planilhas e na importação. Documentado na seção 13 do manual.
3. 🟡 **`RACA` `rac1/rac2` = grau sanguíneo (pendente PAINT).** Esclarecido no
   manual que o grau sanguíneo é exportado em `COMPOSICAO_RACIAL.cpr_indice`. A
   interpretação dos campos extras da `RACA` segue pendente de confirmação com o
   PAINT (mantidos como valores padrão).
4. ✅ **Validações de obrigatoriedade (tipo e brinco) — implementadas.**
   `validate.ts` agora gera erro para qualquer animal sem brinco numérico de 5
   dígitos e aviso para animal PO sem tipo de registro definido.
5. 🟡 **Embrião como sêmen (pendente de produto).** A regra está documentada
   (`cob_tipo = E`, doadora/pai em ANIMAL, receptora em cobertura/nascimento),
   mas ainda não há fluxo de UI dedicado para "cadastrar embrião como sêmen".

### Validação automatizada

- `node scripts/paint_e2e_check.ts` → 71 verificações, 0 falhas.
- `supabase/functions/paint-export/lib/generators.ts` e `validate.ts` sem erros
  de lint.
