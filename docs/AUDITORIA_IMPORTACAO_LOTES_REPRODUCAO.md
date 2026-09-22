# Estender a auditoria de importação a Lotes e Reprodução

**Situação:** a auditoria e o popup de pré-confirmação estão em produção para **Rebanho** e **Pesagem** desde 21/09/2026. Lotes e Reprodução ficaram de fora por decisão de escopo — a ideia é validar o comportamento com as duas primeiras antes de estender.

Este documento registra o que falta, na ordem certa, e por quê. Escrito em 21/09/2026.

---

## O que já está pronto e serve às quatro entidades

A camada em `lib/importacao/` nasceu genérica por entidade. O que **não** precisa ser refeito:

| Já existe | Onde |
|---|---|
| Modelo de diagnóstico, catálogo de códigos, builder com truncamento | `import_diagnostico_model.dart` |
| Helpers de texto, data e número | `import_texto_utils.dart`, `import_data_analise.dart` |
| Tradução de erro do Postgres e rótulos de coluna | `import_erro_amigavel.dart` |
| Probe de cabeçalho e assinatura de entidade | `import_arquivo_probe.dart` |
| Popup de pré-confirmação, com paginação e export CSV | `pp_pre_confirmacao_importacao_widget.dart` |
| Trilha de auditoria (3 tabelas + repositório) | `import_auditoria_repository.dart` |
| Tela de histórico | `lib/pages/pg_auditoria_importacao/` |

**O banco já aceita as duas entidades.** O CHECK da migration `20260921180000` é `entidade in ('rebanho','lotes','reproducao','pesagem')` — nenhuma migration nova é necessária para a auditoria em si.

---

## Pré-requisito: os dois parsers precisam de conserto antes

Esta é a parte que diferencia o trabalho. **Nenhum diagnóstico salva um parser que lê as colunas erradas** — por isso os consertos abaixo vêm primeiro, não depois.

### Lotes — o elo mais frágil do pipeline

`lib/custom_code/actions/parse_csv_to_json_lotes.dart` **não tem mapeamento por cabeçalho nem suporte a XLSX** (verificado: zero ocorrências de `templateMap` e de `package:excel`). Ele mapeia por **posição**, na ordem do banco:

```
id, created_at, id_propriedade, nome, anotacoes, ativo,
data_entrada_piquete, data_saida_piquete, motivo, data_motivo,
id_lote, deletado, updated_at, valorVenda
```

Consequência: a planilha do produtor, que começa em "Nome", tem o nome do lote lido como `id` — e `id` é descartado na gravação. O lote entra com o nome errado, sem erro nenhum. A primeira linha é sempre descartada como se fosse cabeçalho, mesmo quando não é.

**O que fazer:** copiar a estrutura de `parse_csv_to_json_rebanho2.dart` — `_buildHeaderToDbMapping`, detecção de XLSX/XLS/binário, e as constantes de colunas de data e numéricas. Depois disso o fallback posicional vira `ARQ_SEM_HEADER_FALLBACK_POSICIONAL` como nas outras entidades.

### Reprodução — parser melhor, gravação pior

`parse_csv_to_json_reproducao.dart` **já tem** mapeamento por cabeçalho e, corretamente, **aborta** quando não reconhece o cabeçalho em vez de cair no posicional (é a única entidade que já faz isso certo). Falta apenas suporte a XLSX.

O problema está na gravação, e é o mais sério do repositório inteiro.

---

## O problema central da Reprodução: reimportar duplica

`batch_insert_supabase_reproducao.dart:359-361` gera um `id_reproducao` **novo** quando a planilha não traz um — que é o caso normal da planilha do produtor. Como o upsert é por `id_reproducao`, **nada deduplica contra o banco**: reimportar a mesma planilha cria tudo de novo.

Não é hipótese. Está documentado em `LIMPEZA_duplicados_reproducao.sql` na raiz do repo:

> as duplicatas se concentram em LOTES de importação (ex.: 161 linhas às 22h de 24/03/2026; 115 às 14h de 03/03/2026) — é a mesma planilha importada mais de uma vez, não clique repetido do usuário.
>
> ESCOPO: 155 grupos / 217 registros a remover, em 20 propriedades.

Isso contamina taxa de prenhez e de concepção.

**Lotes tem o mesmo defeito** (`batch_insert_supabase_lotes.dart:65`): sem `id_lote` na planilha, gera um novo, e reimportar duplica todos os lotes. Não há unique em `(id_propriedade, nome)`, então ficam dois lotes de mesmo nome — e aí a resolução de `loteNome → id_lote` na importação de rebanho fica ambígua (o diagnóstico de rebanho já avisa isso: `REB_LOTE_AMBIGUO`).

### A chave de deduplicação da Reprodução já está definida

`LIMPEZA_duplicados_reproducao.sql:34-41` usa, e justifica, esta chave:

```
(id_propriedade, id_rebanho_matriz, tipo_reproducao,
 coalesce(data_inseminacao, data_inicial), id_rebanho_reprodutor)
```

com a regra de negócio: *uma vaca não é coberta duas vezes pelo mesmo touro no mesmo dia*. Use exatamente essa chave no diagnóstico — ela já foi validada contra dados reais.

**Proteção obrigatória:** o mesmo script exclui deliberadamente os grupos cuja matriz é `SN`/`S/N`/vazia, porque *cada fazenda tem UMA vaca cadastrada como "SN" e todas as vacas sem número foram amarradas nela* — ali as linhas repetidas são **vacas diferentes**, não duplicatas. O código `REB_MATRIZ_SN_GENERICA` já existe e trata disso; replique em Reprodução antes de qualquer dedupe automático.

---

## Passo a passo

### 1. Consertar o parser de Lotes
`parse_csv_to_json_lotes.dart` ganha `_buildHeaderToDbMapping` e XLSX, espelhando o de rebanho.
**Teste:** planilha com cabeçalho em PT e planilha XLSX entram corretas; planilha sem cabeçalho é sinalizada.

### 2. XLSX no parser de Reprodução
Menor: o mapeamento por cabeçalho já existe.

### 3. Estender os enums e o catálogo
- `ImportEntidade` em `import_diagnostico_model.dart` ganha `lotes` e `reproducao`.
  ⚠️ O teste `import_auditoria_payload_test.dart` trava os nomes dos enums contra os CHECK da migration — ele vai falhar de propósito e deve ser atualizado junto.
- Novos códigos `LOT_*` e `REP_*` no catálogo, com título em português em `tituloDoCodigo`.
- `cabecalhosPorEntidade`, `cabecalhosExclusivosPorEntidade` e `colunasObrigatoriasPorEntidade` em `import_arquivo_probe.dart` ganham as duas entidades. **Isso também melhora as existentes:** com as quatro assinaturas cadastradas, o "planilha da entidade errada" passa a distinguir os quatro casos.

### 4. `diagnostico_lotes.dart` e `diagnostico_reproducao.dart`
Mesmo formato dos existentes: uma função local (só arquivo) e uma de consistência (com o banco).

**Lotes — regras mínimas:**
- nome ausente; nome duplicado no arquivo (normalizado)
- nome que já existe no banco → hoje **duplicaria**; precisa de aviso explícito
- `ativo` fora de `Ativo`/`Inativo`
- `data_saida_piquete < data_entrada_piquete`
- `valorVenda`: o parser atual só faz `replaceAll(',', '.')`, então `"1.250,00"` vira `null` em silêncio
- `id_propriedade` divergente do selecionado → bloqueia (mesmo risco de transferência entre fazendas do rebanho)

**Reprodução — regras mínimas:**
- sem matriz identificada; sem data de evento (`data_inseminacao` **ou** `data_inicial`)
- matriz `SN`/vazia (ver proteção acima)
- `tipo_reproducao` e `status_reproducao` fora do domínio
- duplicata no arquivo e **contra o banco**, pela chave da seção anterior
- `data_parto` antes da cobertura; `data_final < data_inicial`
- previsão de parto incoerente (o batch calcula `data_inseminacao + 295 dias` quando vem vazia)
- matriz resolvida que está cadastrada como Macho
- sêmen preenchido em Monta Natural → o pipeline descarta em silêncio, e um trigger no banco reforça

### 5. Ligar os call-sites
Os dois blocos restantes em `sub_menu_painel_importar_widget.dart` seguem o modelo de `_importarRebanho()`: ler → diagnosticar → popup → gravar → auditar. Os `AlertDialog` e `_exportFailedRowsCsv*` desses dois blocos são removidos, como já foi feito nos outros.

### 6. Dedupe de escrita (decisão à parte)
O popup **avisa** a duplicata, mas quem decide é o usuário. Fazer a gravação deduplicar sozinha é mudança de comportamento em arquivos de 386 e 849 linhas, e interage com o script de limpeza existente. Recomendação: entregar 1–5 primeiro, deixar o diagnóstico medir quantas importações trazem duplicata, e só então decidir.

Se for feito, considere um **unique index parcial** em `reproducao` com a chave validada — é a proteção que o `historico_pesagens` já tem e que impede o problema na origem, não no cliente.

---

## Riscos

1. **Tornar o fallback posicional de Lotes bloqueante é breaking change.** Alguém pode estar importando um export do banco sem cabeçalho e funcionando por sorte. Mesma mitigação usada no rebanho: bloquear só quando os cabeçalhos não forem reconhecidos como export do banco, e medir antes de endurecer.
2. **Dedupe automático em Reprodução pode apagar dado real** se ignorar a proteção "SN". Leia `LIMPEZA_duplicados_reproducao.sql` inteiro antes.
3. **O teste de enums vai quebrar** ao estender `ImportEntidade` — é de propósito, para forçar a revisão do CHECK da migration.

---

## Referências

- Plano original e decisões: histórico desta implementação, commits `bdd8a4b`..`76421ae`
- Incidente de duplicidade: `LIMPEZA_duplicados_reproducao.sql`, `DUPLICADOS_REPRODUCAO_resumo.csv`, `DUPLICADOS_REPRODUCAO_detalhado.csv` (raiz do repo)
- Migrations da auditoria: `supabase/migrations/20260921180000_auditoria_importacao_planilhas.sql` e `20260921190000_auditoria_importacao_autor_snapshot.sql`
