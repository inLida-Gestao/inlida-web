-- PAINT — correções de exportação (calls PAINT 03/06 + manuais oficiais).
-- Aditivo e idempotente: apenas ADD COLUMN IF NOT EXISTS / DROP NOT NULL.
-- Nenhum DROP de coluna ou tabela.

-- 1) Série do registro da raça para animais PO (manual §7.1; call PAINT: na
--    Cachoeira a série vem do registro = "JLK", não da série da fazenda).
alter table public.paint_fazenda_config
  add column if not exists serie_raca_po varchar(4);

comment on column public.paint_fazenda_config.serie_raca_po is
  'Série usada na montagem do A12 de animais PO (registro da raça, ex.: JLK). '
  'Quando vazio, animais PO usam serie_fazenda.';

-- 2) Tipo de registro/livro PAINT no cadastro do animal (manual §11.4):
--    PO, CL, POI, CEIP, LA, LA1. Obrigatório informar para animais PO.
alter table public.rebanho
  add column if not exists tipo_registro varchar(4);

comment on column public.rebanho.tipo_registro is
  'Tipo de registro/livro PAINT (PO, CL, POI, CEIP, LA, LA1). '
  'Exportado em ANIMAL.ani_tipo. Obrigatório para animais Puros de Origem.';

-- 3) Coordenadas da localidade para avaliação genética (call Juliana: ambiente
--    dos embriões/animais). O layout LOCALIDADE não tem campos dedicados, então
--    a exportação grava lat/long formatados em lde_obs.
alter table public.paint_localidade
  add column if not exists latitude numeric(10,7),
  add column if not exists longitude numeric(10,7);

-- 4) Descrição da safra é opcional (manual §8.5 + call PAINT: recomendada, não
--    obrigatória).
alter table public.paint_safra
  alter column descricao drop not null;

-- 5) Relatório de pré-validação da exportação (erros/avisos por arquivo).
--    Não bloqueia a exportação (PAINT recebe todos os dados); serve de checklist
--    para a equipe revisar antes de enviar ao Gencis.
alter table public.paint_export_job
  add column if not exists validacao jsonb;
