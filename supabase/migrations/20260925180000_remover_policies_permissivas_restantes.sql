-- Remove as policies permissivas que sobraram da 20260601151934
-- (remover_policies_permissivas_public).
--
-- Treze tabelas ainda tinham uma policy `USING (true)` para o papel `public`.
-- Como o `anon` tem GRANT de SELECT em todas elas, qualquer portador da anon
-- key -- que vai embutida no bundle web -- lia rebanho, reproducao,
-- pesagens, sanidade, propriedades e o vinculo usuario-fazenda de TODOS os
-- clientes, sem login. Em `anuncios` e `patrocinios` a policy era `ALL`:
-- dava para gravar e apagar anonimamente. `pagamentos` e `assinaturas` tinham
-- SELECT, INSERT e UPDATE abertos, apesar do nome "Admins can ...".
--
-- Quem precisa de acesso continua tendo:
--   * As 8 tabelas de dados ja tem policies `*_pago_*` para `authenticated`,
--     por propriedade (usuario_tem_acesso_propriedade). So sai a aberta.
--   * `pagamentos` e `assinaturas` so sao escritas pelas edge functions de
--     cobranca (generate-asaas-payment, asaas-webhook), que usam a service
--     role e ignoram RLS. Nenhum dos dois apps le essas tabelas. Fica: o
--     proprio usuario ve as suas linhas; admin ve e altera tudo.
--   * `administradores` so e lida por is_user_admin e
--     excluir_usuario_completo, ambas SECURITY DEFINER. A leitura passa a
--     exigir login.
--   * `anuncios` e `patrocinios` sao so lidos pelos apps, depois do login
--     (home do mobile, sidebar do web). Leitura para `authenticated`,
--     escrita so para admin.
--
-- Idempotente: pode rodar de novo sem erro.

-- 1) Tabelas de dados: ja cobertas pelas policies *_pago_*.
drop policy if exists "public" on public.rebanho;
drop policy if exists "public" on public.reproducao;
drop policy if exists "public" on public.historico_pesagens;
drop policy if exists "public" on public.sanidade;
drop policy if exists "public" on public.lotes;
drop policy if exists "public" on public.ocorrencias;
drop policy if exists "public" on public.propriedades;
drop policy if exists "public" on public.users_propriedades;

-- 2) Cobranca: dono le as proprias linhas; admin le e altera.
drop policy if exists "Admins can view all pagamentos" on public.pagamentos;
drop policy if exists "Admins can insert pagamentos" on public.pagamentos;
drop policy if exists "Admins can update all pagamentos" on public.pagamentos;
drop policy if exists "pagamentos_select_dono_ou_admin" on public.pagamentos;
drop policy if exists "pagamentos_escrita_admin" on public.pagamentos;

create policy "pagamentos_select_dono_ou_admin" on public.pagamentos
  for select to authenticated
  using (user_id = auth.uid() or public.is_user_admin(auth.uid()));
create policy "pagamentos_escrita_admin" on public.pagamentos
  for all to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));

drop policy if exists "Admins can view all assinaturas" on public.assinaturas;
drop policy if exists "Admins can insert assinaturas" on public.assinaturas;
drop policy if exists "Admins can update all assinaturas" on public.assinaturas;
drop policy if exists "assinaturas_select_dono_ou_admin" on public.assinaturas;
drop policy if exists "assinaturas_escrita_admin" on public.assinaturas;

create policy "assinaturas_select_dono_ou_admin" on public.assinaturas
  for select to authenticated
  using (user_id = auth.uid() or public.is_user_admin(auth.uid()));
create policy "assinaturas_escrita_admin" on public.assinaturas
  for all to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));

-- 3) Administradores: leitura so com login. As policies de escrita
--    (is_user_admin) ficam como estao.
drop policy if exists "Permitir acesso público para leitura" on public.administradores;
drop policy if exists "administradores_select_autenticado" on public.administradores;

create policy "administradores_select_autenticado" on public.administradores
  for select to authenticated
  using (true);

-- 4) Anuncios e patrocinios: leitura com login, escrita so admin.
drop policy if exists "public" on public.anuncios;
drop policy if exists "anuncios_select_autenticado" on public.anuncios;
drop policy if exists "anuncios_escrita_admin" on public.anuncios;

create policy "anuncios_select_autenticado" on public.anuncios
  for select to authenticated
  using (true);
create policy "anuncios_escrita_admin" on public.anuncios
  for all to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));

drop policy if exists "public" on public.patrocinios;
drop policy if exists "patrocinios_select_autenticado" on public.patrocinios;
drop policy if exists "patrocinios_escrita_admin" on public.patrocinios;

create policy "patrocinios_select_autenticado" on public.patrocinios
  for select to authenticated
  using (true);
create policy "patrocinios_escrita_admin" on public.patrocinios
  for all to authenticated
  using (public.is_user_admin(auth.uid()))
  with check (public.is_user_admin(auth.uid()));
