-- PostgREST pode resolver a RPC com datas como (text, date, date, ...), versão antiga
-- sem SECURITY DEFINER → 500 por RLS para sessões autenticadas.
-- Mantém apenas calcular_taxa_prenhez(text, text, text, text, text, text).

DROP FUNCTION IF EXISTS public.calcular_taxa_prenhez(text, date, date, text, text, text);
