# Preencher loteID nos animais já cadastrados

## O que faz

Atualiza a tabela `rebanho` preenchendo o campo `loteID` nos animais que têm `loteNome` preenchido (ex.: "PASTO 22") mas `loteID` vazio. Assim, a listagem e a contagem de animais por lote passam a funcionar para todos os dados antigos.

## Como executar

### Opção 1 – Supabase Dashboard (recomendado)

1. Acesse o projeto no [Supabase Dashboard](https://supabase.com/dashboard).
2. Vá em **SQL Editor**.
3. Copie o conteúdo do arquivo `20260305_backfill_rebanho_lote_id.sql` e cole no editor.
4. (Opcional) Rode antes a query de conferência para ver quantos registros serão afetados:
   ```sql
   SELECT count(*) FROM public.rebanho
   WHERE "loteNome" IS NOT NULL AND trim("loteNome") != ''
     AND ("loteID" IS NULL OR trim("loteID") = '')
     AND (deletado IS NULL OR deletado != 'SIM');
   ```
5. Execute o script (Run).
6. (Opcional) Rode de novo a query do passo 4; o resultado deve ser 0.

### Opção 2 – CLI Supabase

Se usar Supabase CLI com migrações:

```bash
supabase db push
```

ou aplique só esta migração conforme a documentação do seu ambiente.

## Segurança

- Só altera animais não deletados.
- Só considera lotes não deletados.
- O vínculo é feito por **nome do lote** + **propriedade**; se houver dois lotes com o mesmo nome na mesma propriedade, será usado um deles (LIMIT 1).

## Depois de rodar

Novos cadastros/edições já preenchem `loteID` no app. Esta migração é **uma vez** para corrigir os registros antigos.
