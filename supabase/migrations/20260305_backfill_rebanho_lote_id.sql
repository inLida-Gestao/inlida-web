-- =============================================================================
-- Migração: Preencher loteID no rebanho a partir do loteNome (dados já cadastrados)
-- Data: 2026-03-05
-- Motivo: Animais antigos têm loteNome preenchido (ex.: "PASTO 22") mas loteID
--         vazio; a tela do lote e a contagem dependem de loteID. Este script
--         preenche loteID buscando o id_lote do lote com mesmo nome e propriedade.
-- =============================================================================

-- Atualiza rebanho: define loteID quando loteNome está preenchido e loteID está vazio.
-- Considera apenas lotes ativos/não deletados e animais não deletados.
UPDATE public.rebanho r
SET "loteID" = (
  SELECT l.id_lote
  FROM public.lotes l
  WHERE l.id_propriedade = r."idPropriedade"
    AND trim(l.nome) = trim(r."loteNome")
    AND (l.deletado IS NULL OR l.deletado != 'SIM')
  LIMIT 1
)
WHERE r."loteNome" IS NOT NULL AND trim(r."loteNome") != ''
  AND (r."loteID" IS NULL OR trim(r."loteID") = '')
  AND (r.deletado IS NULL OR r.deletado != 'SIM');

-- Opcional: conferir quantos registros foram atualizados (rodar antes e depois).
-- SELECT count(*) FROM public.rebanho WHERE "loteNome" IS NOT NULL AND trim("loteNome") != '' AND ("loteID" IS NULL OR trim("loteID") = '');
