-- Guarda QUEM importou, por nome, direto na linha de auditoria.
--
-- Por que snapshot e nao join com public.users: a policy users_select_own
-- permite ao usuario ler apenas o proprio registro (auth.uid() = "userID"),
-- entao um join mostraria so um UUID para quem quisesse saber qual pessoa da
-- equipe fez a importacao -- que e justamente a pergunta que a auditoria
-- precisa responder. A fonte usada e users_propriedades, que quem tem acesso
-- a propriedade consegue ler.
--
-- Snapshot tambem e o comportamento correto de uma trilha de auditoria: o
-- nome preservado e o que valia no momento da importacao, e sobrevive a
-- renomeacao ou exclusao do usuario (a FK usuario_id ja e ON DELETE SET NULL).
alter table public.import_auditoria
  add column if not exists usuario_nome  text,
  add column if not exists usuario_email text;

comment on column public.import_auditoria.usuario_nome is
  'Nome de quem importou, como estava no momento da importacao (users_propriedades.nome).';
comment on column public.import_auditoria.usuario_email is
  'E-mail de quem importou, no momento da importacao.';
