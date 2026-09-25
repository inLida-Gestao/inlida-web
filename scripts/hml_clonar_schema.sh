#!/usr/bin/env bash
#
# Recria em homologacao o schema `public` de producao.
#
# Uso:
#   PROD_DB_URL=postgres://... ./scripts/hml_clonar_schema.sh dump
#   HML_DB_URL=postgres://...  ./scripts/hml_clonar_schema.sh restore
#
# Por que nao `supabase db push` com as migrations do repo: o projeto de
# producao nasceu em maio/2025, mas o versionamento de schema so comecou em
# maio/2026. Nenhuma das migrations cria `rebanho`, `reproducao`,
# `propriedades` ou `historico_pesagens` -- todas assumem que essas tabelas
# ja existem. Rodar as 173 num banco vazio falha na primeira. O dump do
# schema e a unica forma de reproduzir producao fielmente.
#
# O dump traz tabelas, views, funcoes, triggers, policies de RLS e indices
# de `public`, mais o historico em `supabase_migrations` -- assim um
# `supabase db push` futuro sabe de onde continuar.
set -euo pipefail

DESTINO="${DESTINO:-.hml_seed}"
ARQUIVO="${DESTINO}/schema.sql"
PROD_REF="eqrtgsqnxxnfjjzlxpuj"

# Presentes em producao e ausentes num projeto Supabase novo.
# As demais (pgcrypto, uuid-ossp, pgjwt, pg_stat_statements) ja vem de fabrica.
EXTENSOES=(postgis pg_trgm moddatetime pg_cron)

dump() {
  : "${PROD_DB_URL:?defina PROD_DB_URL com a connection string de producao}"
  mkdir -p "$DESTINO"

  # --no-owner e --no-privileges: os roles de producao nao existem no destino,
  # e o Supabase gerencia os seus proprios (anon, authenticated, service_role).
  # Os schemas auth/storage/realtime ficam de fora de proposito: o projeto novo
  # ja os tem, e sobrescreve-los quebra a autenticacao.
  pg_dump "$PROD_DB_URL" \
    --schema-only \
    --no-owner \
    --no-privileges \
    --schema=public \
    --schema=supabase_migrations \
    --file="$ARQUIVO"

  echo "Schema salvo em ${ARQUIVO} ($(wc -l < "$ARQUIVO" | tr -d ' ') linhas)"
}

restore() {
  : "${HML_DB_URL:?defina HML_DB_URL com a connection string de homologacao}"

  if [[ "$HML_DB_URL" == *"$PROD_REF"* ]]; then
    echo "HML_DB_URL aponta para o projeto de producao (${PROD_REF}). Abortando." >&2
    exit 1
  fi

  if [[ ! -f "$ARQUIVO" ]]; then
    echo "Falta ${ARQUIVO} -- rode o dump primeiro." >&2
    exit 1
  fi

  echo "Habilitando extensoes..."
  for extensao in "${EXTENSOES[@]}"; do
    psql "$HML_DB_URL" --quiet --no-psqlrc \
      -c "create extension if not exists \"${extensao}\" with schema extensions;" \
      || echo "  aviso: nao foi possivel habilitar ${extensao}; habilite pelo painel." >&2
    printf '  %s\n' "$extensao"
  done

  echo "Restaurando schema..."
  # Sem ON_ERROR_STOP: o dump repete objetos que o Supabase ja criou
  # (o schema `public`, por exemplo), e esses erros sao esperados.
  psql "$HML_DB_URL" --no-psqlrc --quiet -f "$ARQUIVO"

  echo
  echo "Schema restaurado. Confira a contagem de tabelas:"
  psql "$HML_DB_URL" --no-psqlrc -c \
    "select count(*) as tabelas_public from pg_tables where schemaname='public';"

  echo "Producao tem 70 tabelas e 3 views em public."
  echo
  echo "Faltam ainda, fora deste script:"
  echo "  1. as 18 edge functions  -> npx supabase functions deploy --project-ref <ref-hml>"
  echo "  2. os dados da propriedade -> ./scripts/hml_seed_propriedade.sh"
  echo "  3. os usuarios de login    -> crie em auth.users pelo painel do projeto"
}

case "${1:-}" in
  dump)    dump ;;
  restore) restore ;;
  *)
    echo "uso: $0 {dump|restore}" >&2
    exit 1
    ;;
esac
