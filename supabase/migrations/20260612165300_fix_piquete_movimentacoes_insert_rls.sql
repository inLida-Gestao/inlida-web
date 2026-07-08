-- Allow authenticated users to create piquete/retiro history rows only for
-- properties they can access.

ALTER TABLE public.piquete_movimentacoes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS piquete_movimentacoes_authenticated_insert ON public.piquete_movimentacoes;
CREATE POLICY piquete_movimentacoes_authenticated_insert
ON public.piquete_movimentacoes
FOR INSERT
TO authenticated
WITH CHECK (public.usuario_tem_acesso_propriedade(id_propriedade));

GRANT INSERT ON public.piquete_movimentacoes TO authenticated;
