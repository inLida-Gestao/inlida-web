-- Permite que a RPC seja chamada pela edge com anon e leia reproducao/rebanho
-- (evita 500 por RLS quando o JWT de sessão não chega à função).
-- Ainda filtra por id_propriedade_param; revise políticas se necessário.

ALTER FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text)
  TO anon, authenticated, service_role;
