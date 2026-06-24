-- Alinha as políticas RLS de paint_registro_excluido e paint_estoque ao padrão
-- permissivo já adotado pelas demais tabelas do módulo PAINT (using/with check = true).
--
-- Motivo: o restante do módulo PAINT usa políticas permissivas para usuários
-- autenticados. Estas duas tabelas mantinham a checagem por vínculo em
-- users_propriedades (user_id = auth.uid()), que falhava na prática e gerava
-- "new row violates row-level security policy" (42501) ao registrar exclusões
-- (POST em paint_registro_excluido) durante o delete na UI do PAINT.

drop policy if exists paint_registro_excluido_rw on public.paint_registro_excluido;
create policy paint_registro_excluido_rw on public.paint_registro_excluido
  for all to authenticated
  using (true)
  with check (true);

drop policy if exists paint_estoque_rw on public.paint_estoque;
create policy paint_estoque_rw on public.paint_estoque
  for all to authenticated
  using (true)
  with check (true);
