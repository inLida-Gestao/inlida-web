-- Alinha status com dataVenda: cadastro de "lote vendido" (fluxo antigo) gravava
-- dataVenda sem atualizar status, enquanto Painel > Vendas conta por dataVenda.
UPDATE public.rebanho r
SET status = 'Vendido'
WHERE r.deletado = 'NAO'
  AND r."dataVenda" IS NOT NULL
  AND (
    r.status IS NULL
    OR lower(btrim(r.status)) = lower('Na propriedade')
  );
