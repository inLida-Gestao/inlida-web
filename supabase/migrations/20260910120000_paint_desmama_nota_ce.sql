-- PAINT — perímetro escrotal na avaliação de desmama.
--
-- `dsm_nota_ce` é N(8,2) na posição 103 do DESMAMA.TXT e sempre saiu em branco,
-- porque a coluna não existia na tabela, nem na planilha de desmama, nem na
-- importação. A cliente estranhou justamente isso: a coluna aparece no arquivo
-- e nunca tem valor.
--
-- Mesma coluna que o sobreano já tem (numeric(4,2), medida em centímetros).
-- Fica nula por padrão: quem não medir o CE na desmama deixa em branco e o
-- campo continua saindo vazio no TXT, como hoje.
alter table public.paint_avaliacao_desmama
  add column if not exists nota_ce numeric(4,2);

comment on column public.paint_avaliacao_desmama.nota_ce is
  'Perímetro escrotal em centímetros (não é nota de 1 a 5). Exportado em '
  'DESMAMA.dsm_nota_ce.';
