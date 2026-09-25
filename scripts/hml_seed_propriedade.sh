#!/usr/bin/env bash
#
# Copia uma ou mais propriedades de producao para o ambiente de homologacao.
#
# Uso:
#   PROD_DB_URL=postgres://... ./scripts/hml_seed_propriedade.sh extract
#   HML_DB_URL=postgres://...  ./scripts/hml_seed_propriedade.sh load
#
# O `extract` so le a producao e grava CSVs em ./.hml_seed, para conferencia.
# O `load` escreve no destino. Rode o hml_clonar_schema.sh antes: este script
# assume que o schema ja existe.
#
# Padrao: Fazenda Cordilheira (rebanho e reproducao em volume real, com 6,8k
# inseminacoes em aberto) e Fazenda Cachoeira (a unica propriedade com dados
# do modulo PAINT em toda a base).
#
# Dados pessoais dos usuarios sao anonimizados por padrao. ANONIMIZAR=0 copia
# nome, email, telefone e CPF reais -- pense duas vezes: sao dados de
# clientes, e um segundo ambiente e uma segunda superficie de exposicao.
set -euo pipefail

IDS_PROPRIEDADES="${IDS_PROPRIEDADES:-kjte6tz4u6c9ywf3t237 u7chcvxq1cxzss762oyi}"
DESTINO="${DESTINO:-.hml_seed}"
ANONIMIZAR="${ANONIMIZAR:-1}"
SENHA_PADRAO="${SENHA_PADRAO:-inlida-hml}"

# Ref do projeto de producao. Trava do `load`: um engano aqui sobrescreveria
# a base real.
PROD_REF="eqrtgsqnxxnfjjzlxpuj"

# Tabelas de apoio do PAINT: nao tem propriedade e sao pequenas, entao vem
# inteiras. Precisam existir antes de paint_composicao_racial e
# paint_biblioteca_touros, que tem FK para elas.
TABELAS_GLOBAIS=(
  paint_codigo_raca
  paint_tipo_registro
  paint_codigo_categoria
  paint_programa_melhoramento
  paint_tipo_cobertura
  paint_biblioteca_touros
)

# Ordem de carga: das que so dependem da propriedade para as que dependem de
# rebanho, lotes e dos cadastros do PAINT.
TABELAS=(
  propriedades
  users
  users_propriedades
  lotes
  retiros
  limites_propriedade
  piquete
  piquete_lotes
  rebanho
  reproducao
  historico_pesagens
  sanidade
  rebanho_lote_movimentacoes
  piquete_movimentacoes
  paint_fazenda_config
  paint_localidade
  paint_inseminador
  paint_regime_alimentar
  paint_safra
  paint_grupo_manejo
  paint_animal_a12
  paint_composicao_racial
  paint_diagnostico
  paint_avaliacao_desmama
  paint_avaliacao_rah
  paint_avaliacao_sobreano
  paint_cobertura_periodo
  paint_baixa
  paint_registro_excluido
)

# Fora de proposito:
#   paint_export_job, whatsapp_sessions, yethiva_* -- FK para auth.users e
#     nenhum valor em homologacao (historico de jobs e de sessoes de voz).
#   chat_sessions, import_auditoria -- idem, historico que nao vale replicar.
#   paint_avaliador, paint_estoque, paint_touro_multiplo, paint_safra_x_animal
#     -- vazias em producao.

# Tabelas com id serial. Carregamos ids explicitos, entao o nextval continua
# em 1 e o proximo insert do app colidiria na chave primaria. As do PAINT nao
# entram: usam uuid.
TABELAS_COM_SEQUENCE=(
  propriedades
  users_propriedades
  lotes
  piquete
  rebanho
  reproducao
  historico_pesagens
  sanidade
  rebanho_lote_movimentacoes
)

# O schema mistura snake_case e camelCase por razoes historicas.
coluna_propriedade() {
  case "$1" in
    propriedades|users_propriedades|rebanho) echo '"idPropriedade"' ;;
    *)                                       echo 'id_propriedade' ;;
  esac
}

# 'a b c' -> "'a','b','c'"
lista_sql() {
  local saida=""
  for id in $IDS_PROPRIEDADES; do
    [[ -n "$saida" ]] && saida+=","
    saida+="'${id}'"
  done
  echo "$saida"
}

select_da_tabela() {
  local tabela="$1"
  local props="$2"
  local coluna
  coluna="$(coluna_propriedade "$tabela")"

  case "$tabela" in
    users)
      # Os usuarios nao tem coluna de propriedade: chegam pelo vinculo.
      if [[ "$ANONIMIZAR" == "1" ]]; then
        cat <<SQL
select u."userID", u.created_at,
       'Usuario HML ' || dense_rank() over (order by u."userID"::text) as nome,
       'usuario' || dense_rank() over (order by u."userID"::text) || '@hml.inlida.com.br' as email,
       u.termos, null::text as foto, null::text as telefone, u.excluido,
       u.permissao, u.funcao, u.acesso, null::text as cpf_cnpj,
       u.valor_assinatura, u.ciclo_assinatura, u.piquete
  from users u
 where u."userID"::text in (
         select user_id from users_propriedades where "idPropriedade" in (${props})
       )
SQL
      else
        cat <<SQL
select * from users
 where "userID"::text in (
         select user_id from users_propriedades where "idPropriedade" in (${props})
       )
SQL
      fi
      ;;
    users_propriedades)
      if [[ "$ANONIMIZAR" == "1" ]]; then
        cat <<SQL
select id, created_at, user_id,
       'Usuario HML ' || dense_rank() over (order by user_id) as nome,
       'usuario' || dense_rank() over (order by user_id) || '@hml.inlida.com.br' as email,
       null::text as foto, permissao, "idPropriedade", deletado
  from users_propriedades
 where "idPropriedade" in (${props})
SQL
      else
        echo "select * from users_propriedades where \"idPropriedade\" in (${props})"
      fi
      ;;
    *)
      echo "select * from ${tabela} where ${coluna} in (${props})"
      ;;
  esac
}

# Par (id, email) de cada usuario, para criar as contas em auth.users.
# `public.users` tem FK para `auth.users`: sem essas contas a carga falha.
#
# A numeracao do email anonimo sai de `dense_rank` sobre o id em texto, a
# mesma expressao usada em `users` e `users_propriedades`. Ordenar por
# created_at aqui e por user_id la daria emails diferentes para o mesmo
# usuario, e o login nao bateria com o que a tela mostra.
select_auth_users() {
  local props="$1"
  if [[ "$ANONIMIZAR" == "1" ]]; then
    cat <<SQL
select u."userID",
       'usuario' || dense_rank() over (order by u."userID"::text) || '@hml.inlida.com.br'
  from users u
 where u."userID"::text in (
         select user_id from users_propriedades where "idPropriedade" in (${props})
       )
SQL
  else
    cat <<SQL
select u."userID", u.email
  from users u
 where u."userID"::text in (
         select user_id from users_propriedades where "idPropriedade" in (${props})
       )
   and u.email is not null
SQL
  fi
}

# A lista de colunas so e explicita nas tabelas anonimizadas, cujo SELECT
# nao e `select *`.
colunas_da_tabela() {
  case "$1" in
    users)
      echo '("userID", created_at, nome, email, termos, foto, telefone, excluido, permissao, funcao, acesso, cpf_cnpj, valor_assinatura, ciclo_assinatura, piquete)'
      ;;
    users_propriedades)
      echo '(id, created_at, user_id, nome, email, foto, permissao, "idPropriedade", deletado)'
      ;;
    *)
      echo ''
      ;;
  esac
}

extrair() {
  : "${PROD_DB_URL:?defina PROD_DB_URL com a connection string de producao}"
  mkdir -p "$DESTINO"
  local props
  props="$(lista_sql)"

  echo "Extraindo propriedades ${props} para ${DESTINO}/"

  echo "-- tabelas de apoio do PAINT (copiadas inteiras)"
  for tabela in "${TABELAS_GLOBAIS[@]}"; do
    psql "$PROD_DB_URL" --quiet --no-psqlrc \
      -c "\\copy (select * from ${tabela}) TO '${DESTINO}/${tabela}.csv' WITH (FORMAT csv)"
    printf '  %-30s %8s linhas\n' "$tabela" "$(wc -l < "${DESTINO}/${tabela}.csv" | tr -d ' ')"
  done

  echo "-- contas de autenticacao"
  psql "$PROD_DB_URL" --quiet --no-psqlrc \
    -c "\\copy ($(select_auth_users "$props")) TO '${DESTINO}/auth_users.csv' WITH (FORMAT csv)"
  printf '  %-30s %8s linhas\n' "auth_users" "$(wc -l < "${DESTINO}/auth_users.csv" | tr -d ' ')"

  echo "-- dados das propriedades"
  for tabela in "${TABELAS[@]}"; do
    psql "$PROD_DB_URL" --quiet --no-psqlrc \
      -c "\\copy ($(select_da_tabela "$tabela" "$props")) TO '${DESTINO}/${tabela}.csv' WITH (FORMAT csv)"
    printf '  %-30s %8s linhas\n' "$tabela" "$(wc -l < "${DESTINO}/${tabela}.csv" | tr -d ' ')"
  done

  if [[ "$ANONIMIZAR" == "1" ]]; then
    echo "Dados de usuarios anonimizados (ANONIMIZAR=0 para copiar os reais)."
  else
    echo "ATENCAO: dados pessoais reais dos usuarios foram copiados."
  fi
}

criar_contas_auth() {
  # `email` em auth.identities e GENERATED ALWAYS: nao pode ser inserida.
  psql "$HML_DB_URL" --no-psqlrc --quiet -v ON_ERROR_STOP=1 <<SQL
create temp table tmp_auth (id uuid, email text);
\copy tmp_auth from '${DESTINO}/auth_users.csv' with (format csv)

-- As quatro colunas de token precisam ser '' e nao NULL. O servico de auth
-- le essas colunas como string e, com NULL, todo login falha com
-- "Database error querying schema" -- as demais colunas de token ja tem ''
-- como default, estas nao.
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data,
  confirmation_token, recovery_token, email_change, email_change_token_new
)
select '00000000-0000-0000-0000-000000000000', t.id, 'authenticated', 'authenticated',
       t.email, extensions.crypt('${SENHA_PADRAO}', extensions.gen_salt('bf')),
       now(), now(), now(),
       '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb,
       '', '', '', ''
  from tmp_auth t
on conflict (id) do nothing;

insert into auth.identities (
  provider_id, user_id, identity_data, provider,
  created_at, updated_at, last_sign_in_at
)
select t.id::text, t.id,
       jsonb_build_object('sub', t.id::text, 'email', t.email, 'email_verified', true),
       'email', now(), now(), now()
  from tmp_auth t
on conflict do nothing;
SQL
}

carregar() {
  : "${HML_DB_URL:?defina HML_DB_URL com a connection string de homologacao}"

  if [[ "$HML_DB_URL" == *"$PROD_REF"* ]]; then
    echo "HML_DB_URL aponta para o projeto de producao (${PROD_REF}). Abortando." >&2
    exit 1
  fi

  local todas=("${TABELAS_GLOBAIS[@]}" "${TABELAS[@]}")
  for tabela in "${todas[@]}" ; do
    if [[ ! -f "${DESTINO}/${tabela}.csv" ]]; then
      echo "Falta ${DESTINO}/${tabela}.csv -- rode o extract primeiro." >&2
      exit 1
    fi
  done
  if [[ ! -f "${DESTINO}/auth_users.csv" ]]; then
    echo "Falta ${DESTINO}/auth_users.csv -- rode o extract primeiro." >&2
    exit 1
  fi

  echo "Criando contas em auth.users (senha: ${SENHA_PADRAO})..."
  criar_contas_auth

  # Os triggers precisam sair do caminho. Em `rebanho` sao 13, e entre eles
  # ha os que resolvem o vinculo de pais, evoluem a categoria do bezerro e
  # registram movimentacao de lote -- com eles ativos a carga reescreveria os
  # dados e criaria movimentacoes que nunca aconteceram.
  echo "Desativando triggers..."
  for tabela in "${todas[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc \
      -c "ALTER TABLE public.${tabela} DISABLE TRIGGER USER;"
  done

  echo "Carregando..."
  for tabela in "${todas[@]}"; do
    local colunas
    colunas="$(colunas_da_tabela "$tabela")"
    psql "$HML_DB_URL" --quiet --no-psqlrc -v ON_ERROR_STOP=1 \
      -c "\\copy public.${tabela} ${colunas} FROM '${DESTINO}/${tabela}.csv' WITH (FORMAT csv)"
    printf '  %-30s carregada\n' "$tabela"
  done

  echo "Reativando triggers..."
  for tabela in "${todas[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc \
      -c "ALTER TABLE public.${tabela} ENABLE TRIGGER USER;"
  done

  echo "Ajustando sequences..."
  for tabela in "${TABELAS_COM_SEQUENCE[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc -c "
      select setval(
        pg_get_serial_sequence('public.${tabela}', 'id'),
        coalesce((select max(id) from public.${tabela}), 1)
      );" > /dev/null
  done

  echo
  echo "Carga concluida. Entre com qualquer um dos emails de auth.users"
  echo "e a senha '${SENHA_PADRAO}'."
}

case "${1:-}" in
  extract) extrair ;;
  load)    carregar ;;
  *)
    echo "uso: $0 {extract|load}" >&2
    exit 1
    ;;
esac
