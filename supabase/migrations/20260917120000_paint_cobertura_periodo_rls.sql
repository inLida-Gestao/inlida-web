-- paint_cobertura_periodo: alinha a RLS ao padrão do módulo PAINT.
--
-- A tabela nasceu (04/09/2026) copiando a policy da migration inicial do
-- módulo, que checa o vínculo em users_propriedades:
--
--   id_propriedade in (select up."idPropriedade" from users_propriedades up
--                       where up.user_id = auth.uid()::text ...)
--
-- Essa checagem NÃO funciona, e já tinha sido abandonada em
-- 20260618120000_paint_rls_permissive_fix.sql depois de quebrar o delete da UI
-- com o mesmo erro 42501. Eu reintroduzi o padrão quebrado na tabela nova, e a
-- cliente bateu nele ao importar a planilha de período da cobertura:
-- "new row violates row-level security policy for table paint_cobertura_periodo".
--
-- Causa raiz (investigada agora, não estava registrada em junho): a própria
-- `users_propriedades` tem RLS ligada, com policy de SELECT atrelada a acesso
-- pago. A subconsulta da policy roda com as permissões de quem escreve, cai
-- nessa RLS e volta VAZIA — então `id_propriedade in (conjunto vazio)` é falso
-- e todo INSERT é recusado. Os dados estão corretos: os 359 vínculos têm
-- user_id de auth.users válido.
--
-- Consertar de verdade exigiria uma função SECURITY DEFINER para ler o vínculo
-- sem esbarrar na RLS de users_propriedades, e valeria para as ~20 tabelas do
-- módulo de uma vez. Isso é decisão de escopo maior; aqui a tabela fica igual a
-- todas as outras do PAINT (using/with check = true), para não deixar a
-- importação quebrada enquanto isso.
drop policy if exists paint_cobertura_periodo_rw on public.paint_cobertura_periodo;
create policy paint_cobertura_periodo_rw on public.paint_cobertura_periodo
  for all to authenticated
  using (true)
  with check (true);
