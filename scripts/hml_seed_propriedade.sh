#!/usr/bin/env bash
#
# Copia uma propriedade inteira de producao para um ambiente de homologacao.
#
# Uso:
#   PROD_DB_URL=postgres://... ./scripts/hml_seed_propriedade.sh extract
#   HML_DB_URL=postgres://...  ./scripts/hml_seed_propriedade.sh load
#
# O `extract` so le a producao e grava CSVs em ./.hml_seed, para voce
# conferir antes de carregar. O `load` escreve no banco de homologacao.
#
# Por padrao os dados pessoais dos usuarios sao anonimizados. Use
# ANONIMIZAR=0 para copiar nome, email, telefone e CPF reais -- pense duas
# vezes: sao dados de clientes, e um segundo ambiente e uma segunda
# superficie de exposicao.
set -euo pipefail

ID_PROPRIEDADE="${ID_PROPRIEDADE:-kjte6tz4u6c9ywf3t237}"  # Fazenda Cordilheira
DESTINO="${DESTINO:-.hml_seed}"
ANONIMIZAR="${ANONIMIZAR:-1}"

# Ref do projeto de producao. Serve de trava: o `load` se recusa a rodar
# contra ele, porque um engano aqui sobrescreveria a base real.
PROD_REF="eqrtgsqnxxnfjjzlxpuj"

# Ordem importa: as tabelas sao carregadas nesta sequencia, das que so
# dependem da propriedade para as que dependem de rebanho e lotes.
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
)

# Tabelas com sequence own: apos carregar ids explicitos, o nextval continua
# em 1 e o proximo insert do app colidiria com a chave primaria.
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

# Coluna que liga cada tabela a propriedade. O schema mistura snake_case e
# camelCase por razoes historicas.
coluna_propriedade() {
  case "$1" in
    propriedades|users_propriedades) echo '"idPropriedade"' ;;
    rebanho)                          echo '"idPropriedade"' ;;
    *)                                echo 'id_propriedade' ;;
  esac
}

select_da_tabela() {
  local tabela="$1"
  local prop="$2"
  local coluna
  coluna="$(coluna_propriedade "$tabela")"

  case "$tabela" in
    users)
      # Os usuarios nao tem coluna de propriedade: chegam pelo vinculo.
      if [[ "$ANONIMIZAR" == "1" ]]; then
        cat <<SQL
select u."userID", u.created_at,
       'Usuario HML ' || row_number() over (order by u.created_at) as nome,
       'usuario' || row_number() over (order by u.created_at) || '@hml.inlida.com.br' as email,
       u.termos, null::text as foto, null::text as telefone, u.excluido,
       u.permissao, u.funcao, u.acesso, null::text as cpf_cnpj,
       u.valor_assinatura, u.ciclo_assinatura, u.piquete
  from users u
 where u."userID"::text in (
         select user_id from users_propriedades where "idPropriedade" = '${prop}'
       )
SQL
      else
        cat <<SQL
select * from users
 where "userID"::text in (
         select user_id from users_propriedades where "idPropriedade" = '${prop}'
       )
SQL
      fi
      ;;
    users_propriedades)
      if [[ "$ANONIMIZAR" == "1" ]]; then
        cat <<SQL
select id, created_at, user_id,
       'Usuario HML ' || row_number() over (order by id) as nome,
       'usuario' || row_number() over (order by id) || '@hml.inlida.com.br' as email,
       null::text as foto, permissao, "idPropriedade", deletado
  from users_propriedades
 where "idPropriedade" = '${prop}'
SQL
      else
        echo "select * from users_propriedades where \"idPropriedade\" = '${prop}'"
      fi
      ;;
    *)
      echo "select * from ${tabela} where ${coluna} = '${prop}'"
      ;;
  esac
}

# A lista de colunas precisa ser explicita na carga das tabelas
# anonimizadas, porque o SELECT delas nao e `select *`.
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

  echo "Extraindo propriedade ${ID_PROPRIEDADE} para ${DESTINO}/"
  for tabela in "${TABELAS[@]}"; do
    local consulta
    consulta="$(select_da_tabela "$tabela" "$ID_PROPRIEDADE")"
    psql "$PROD_DB_URL" --quiet --no-psqlrc \
      -c "\\copy (${consulta}) TO '${DESTINO}/${tabela}.csv' WITH (FORMAT csv)"
    printf '  %-28s %8s linhas\n' "$tabela" "$(wc -l < "${DESTINO}/${tabela}.csv" | tr -d ' ')"
  done

  if [[ "$ANONIMIZAR" == "1" ]]; then
    echo "Dados de usuarios anonimizados (ANONIMIZAR=0 para copiar os reais)."
  else
    echo "ATENCAO: dados pessoais reais dos usuarios foram copiados."
  fi
}

carregar() {
  : "${HML_DB_URL:?defina HML_DB_URL com a connection string de homologacao}"

  if [[ "$HML_DB_URL" == *"$PROD_REF"* ]]; then
    echo "HML_DB_URL aponta para o projeto de producao (${PROD_REF}). Abortando." >&2
    exit 1
  fi

  for tabela in "${TABELAS[@]}"; do
    if [[ ! -f "${DESTINO}/${tabela}.csv" ]]; then
      echo "Falta ${DESTINO}/${tabela}.csv -- rode o extract primeiro." >&2
      exit 1
    fi
  done

  echo "Carregando em ${DESTINO} -> homologacao"

  # Os triggers precisam sair do caminho. Em `rebanho` sao 13, e entre eles
  # ha os que resolvem o vinculo de pais, evoluem a categoria do bezerro e
  # registram movimentacao de lote -- com eles ativos a carga reescreveria os
  # dados e criaria movimentacoes que nao existiram.
  for tabela in "${TABELAS[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc \
      -c "ALTER TABLE public.${tabela} DISABLE TRIGGER USER;"
  done

  for tabela in "${TABELAS[@]}"; do
    local colunas
    colunas="$(colunas_da_tabela "$tabela")"
    psql "$HML_DB_URL" --quiet --no-psqlrc \
      -c "\\copy public.${tabela} ${colunas} FROM '${DESTINO}/${tabela}.csv' WITH (FORMAT csv)"
    printf '  %-28s carregada\n' "$tabela"
  done

  for tabela in "${TABELAS[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc \
      -c "ALTER TABLE public.${tabela} ENABLE TRIGGER USER;"
  done

  for tabela in "${TABELAS_COM_SEQUENCE[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc -c "
      select setval(
        pg_get_serial_sequence('public.${tabela}', 'id'),
        coalesce((select max(id) from public.${tabela}), 1)
      );" > /dev/null
    printf '  %-28s sequence ajustada\n' "$tabela"
  done

  echo "Carga concluida."
  echo "Os usuarios de login vivem em auth.users e NAO vieram nesta copia:"
  echo "crie-os no painel do projeto de homologacao e acerte users_propriedades.user_id."
}

case "${1:-}" in
  extract) extrair ;;
  load)    carregar ;;
  *)
    echo "uso: $0 {extract|load}" >&2
    exit 1
    ;;
esac
