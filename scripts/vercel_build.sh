#!/usr/bin/env bash
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"

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

  export PATH="$FLUTTER_BIN:$PATH"
fi

flutter --version
flutter config --no-analytics

flutter pub get
flutter build web --release

echo "Built Flutter web into build/web"
