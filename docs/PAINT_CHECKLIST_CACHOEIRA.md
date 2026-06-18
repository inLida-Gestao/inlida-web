# Checklist de homologação PAINT — Fazenda Cachoeira

Roteiro para gerar e validar a exportação PAINT da Cachoeira antes de enviar ao
Gencis. Baseado nas calls PAINT (03/06/2026), nos manuais oficiais e no plano
executável.

## 1. Configuração (tela PAINT → Configuração)

- [ ] Código de transmissão (6 dígitos) fornecido pelo PAINT
- [ ] Série fazenda (código PAINT da fazenda)
- [ ] Código fazenda (4 dígitos)
- [ ] **Série registro PO = `JLK`** (campo "Série registro PO") — usado no A12
      dos animais Puros de Origem
- [ ] Estratégia A12 e campo de origem do animal conforme acordado

## 2. Migrations / deploy

- [ ] Aplicar `supabase/migrations/20260615120000_paint_export_corrections.sql`
      (adiciona `serie_raca_po`, `rebanho.tipo_registro`, lat/long em
      `paint_localidade`, torna `paint_safra.descricao` opcional e cria
      `paint_export_job.validacao`)
- [ ] Deploy da Edge Function `paint-export` (geradores + `paint_mappers.ts` +
      `validate.ts`)

## 3. Realinhamento do A12 PO (executar após salvar `serie_raca_po`)

Como a série dos animais PO passa a vir do registro (`JLK`) e não da série da
fazenda, o A12 desses animais muda. Procedimento seguro:

1. [ ] Salvar a configuração com `serie_raca_po = JLK`.
2. [ ] Rodar **Importar tudo do sistema** (recalcula A12 e re-vincula avaliações
   por A12). O processo é idempotente.
3. [ ] Conferir, em uma amostra de 10 animais PO, se o A12 ficou
   `P` + `JLK ` + `<5 dígitos>` + `<ano 2 dígitos>`.

> Não há migração automática que reescreva A12 de PO, para evitar divergência
> com avaliações já lançadas. O realinhamento é feito pelo Importar tudo.

## 4. Pré-validação (automática)

Ao gerar a exportação, o job grava `paint_export_job.validacao` com erros e
avisos. **A exportação não é bloqueada** (o PAINT recebe todos os dados), mas
revise antes de enviar:

- [ ] Animais PO sem brinco numérico (5 dígitos)
- [ ] Animais sem raça
- [ ] Desmama sem peso / nota C-P-M-U / grupo de manejo
- [ ] Sobreano sem desmama prévia (manual §8.3)
- [ ] Monta/repasse sem data de início/fim de repasse
- [ ] Composição racial com soma de frações ≠ 1.0
- [ ] (Aviso) Vendidos/mortos sem registro de baixa

## 5. Conferência dos arquivos do ZIP

- [ ] ZIP contém todos os 22 arquivos + `PARAMETROS` + `*_DELETE` (mesmo vazios)
- [ ] `ESTOQUE.TXT` **vazio** (apenas o arquivo, sem linhas)
- [ ] Largura de linha por arquivo bate com `LAYOUTS`
      (`deno run scripts/paint-validate-sample.ts`)
- [ ] `recno` numérico alinhado à direita em todas as tabelas
- [ ] Conferir amostra de 5 linhas: ANIMAL, DESMAMA, COBERTURA, NASCIMENTO, BAIXA
- [ ] `ULTIMA_TRANSMISSAO` com as contagens corretas

## 6. Conferência de campos críticos (ANIMAL)

- [ ] `ani_tipo` = `PO` para Puros de Origem; `CL`/vazio para os demais
- [ ] `ani_brinco` = 5 dígitos, **sem** a sigla `JLK`
- [ ] `ani_raca` preenchida
- [ ] `ani_categoria` e `ani_categoria_ant` coerentes com os eventos
- [ ] `ani_pai` / `ani_mae` = A12 do pedigree
- [ ] `ani_racial` / `ani_frame` / `ani_aprumo` / `ani_pigmentacao` quando houver
      avaliação RAH da matriz

## 7. Envio e validação externa

- [ ] Enviar ZIP completo para Roberta/Juliana (Gencis)
- [ ] Enviar pacote de NASCIMENTO para validação técnica
- [ ] Registrar retorno do consistência do PAINT

## 8. Pendências a confirmar com o PAINT (e-mail Suporte)

- [ ] PARAMETROS vs PROGRAMAS — nomenclatura da coluna
- [ ] Significado do campo `par_chave`
- [ ] SAFRA_X_ANIMAL — associação prévia vs retroativa
- [ ] ULTIMA_TRANSMISSAO — entra no arquivo de avaliação genética?
- [ ] Alinhamento do campo Animal no A12 — esquerda (sample 000460) vs direita
      (manual §7.1)
- [ ] LOCALIDADE — lat/long em `lde_obs` é aceito ou há campo dedicado?
