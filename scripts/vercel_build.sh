#!/usr/bin/env bash
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
# Mantém compatibilidade com o `pubspec.yaml` atual (ex.: `collection: 1.19.1`).
FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.9}"

# Prefer usar Flutter já instalado (útil localmente no macOS).
# Em builds da Vercel normalmente não existe `flutter`, então baixamos o SDK.
if command -v flutter >/dev/null 2>&1; then
  echo "Using system Flutter: $(command -v flutter)"
else
  FLUTTER_ROOT="$PWD/.flutter"
  FLUTTER_BIN="$FLUTTER_ROOT/flutter/bin"

  if [[ ! -x "$FLUTTER_BIN/flutter" ]]; then
    echo "Downloading Flutter ${FLUTTER_VERSION} (${FLUTTER_CHANNEL})..."
    mkdir -p "$FLUTTER_ROOT"

    ARCHIVE="flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
    URL="https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/${ARCHIVE}"

    curl -fsSL "$URL" -o "$ARCHIVE"
    tar -xf "$ARCHIVE" -C "$FLUTTER_ROOT"
  fi

  # Em ambientes CI (ex.: Vercel) o Git pode recusar o repo do SDK (dubious ownership).
  # Isso quebra comandos internos do Flutter que consultam o Git.
  if command -v git >/dev/null 2>&1; then
    git config --global --add safe.directory "$FLUTTER_ROOT/flutter" || true
  fi

  export PATH="$FLUTTER_BIN:$PATH"
fi

flutter --version
flutter config --no-analytics

flutter pub get

# Sem --wasm de proposito. No build WebAssembly o pacote `archive` (usado pelo
# `excel` para montar o .xlsx) cai no stub e lanca
# "inflateBuffer requires html or io", entao nenhuma exportacao conclui.
# O `excel` 4.0.6 exige `archive ^3.6.1`, que nao tem implementacao para wasm.
# Reativar quando essas dependencias suportarem wasm.
BUILD_ARGS=(web --release --pwa-strategy=none --base-href /)
if [[ -n "${MAPBOX_ACCESS_TOKEN:-}" ]]; then
  BUILD_ARGS+=(--dart-define="MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}")
else
  echo "MAPBOX_ACCESS_TOKEN is not set; map will use fallback tile provider."
fi

# SUPABASE_URL e SUPABASE_ANON_KEY sao `String.fromEnvironment` em
# lib/backend/supabase/supabase_config.dart, ou seja, resolvidos em tempo de
# build. Sem repassar como --dart-define, definir a variavel no painel da
# Vercel nao surte efeito algum: o bundle sai com os defaults do arquivo, que
# apontam para producao. Foi assim que o ambiente de homologacao acabou
# gravando no banco de producao.
#
# As duas andam juntas: uma URL de um projeto com a anon key de outro so
# falha em runtime, e de forma dificil de diagnosticar. Por isso o build para
# aqui quando vem so uma das duas.
if { [[ -n "${SUPABASE_URL:-}" ]] && [[ -z "${SUPABASE_ANON_KEY:-}" ]]; } ||
   { [[ -z "${SUPABASE_URL:-}" ]] && [[ -n "${SUPABASE_ANON_KEY:-}" ]]; }; then
  echo "SUPABASE_URL and SUPABASE_ANON_KEY must be set together (or neither)." >&2
  exit 1
fi

if [[ -n "${SUPABASE_URL:-}" ]]; then
  BUILD_ARGS+=(--dart-define="SUPABASE_URL=${SUPABASE_URL}")
  BUILD_ARGS+=(--dart-define="SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}")
  echo "Using Supabase project from env: ${SUPABASE_URL}"
else
  echo "SUPABASE_URL is not set; using the default project from supabase_config.dart."
fi

flutter build "${BUILD_ARGS[@]}"

# Criar AssetManifest.json para compatibilidade com google_fonts
# O Flutter agora gera AssetManifest.bin.json, mas alguns pacotes ainda procuram AssetManifest.json
if [ -f "build/web/assets/AssetManifest.bin.json" ] && [ ! -f "build/web/assets/AssetManifest.json" ]; then
  cp build/web/assets/AssetManifest.bin.json build/web/assets/AssetManifest.json
  echo "Created AssetManifest.json for compatibility"
fi

for artifact in main.dart.js; do
  if [[ ! -f "build/web/$artifact" ]]; then
    echo "Missing required Flutter web artifact: build/web/$artifact" >&2
    exit 1
  fi
done

echo "Built Flutter web (JavaScript) into build/web"
