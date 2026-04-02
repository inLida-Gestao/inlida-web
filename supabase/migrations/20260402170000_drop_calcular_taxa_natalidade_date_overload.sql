-- Evita ambiguidade na RPC: versão legada com (text, date, date) x nova com 6x text.
DROP FUNCTION IF EXISTS public.calcular_taxa_natalidade(text, date, date);
