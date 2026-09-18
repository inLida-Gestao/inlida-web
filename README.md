# inLidaWeb

A new Flutter project.

## Deploy (Vercel)

Este projeto é Flutter Web (SPA). Na Vercel, configure:

- **Framework Preset**: `Other`
- **Build Command**: `bash scripts/vercel_build.sh`
- **Output Directory**: `build/web`

O `vercel.json` já inclui rewrite para `index.html` (necessário para rotas do Flutter não virarem 404/NOT_FOUND em refresh/deep link).

O build de produção usa **WebAssembly + Skwasm** quando o navegador é compatível e mantém o fallback JavaScript + CanvasKit gerado pelo Flutter.

Os headers COOP/COEP para Skwasm multithread não estão habilitados nesta primeira etapa. Assim, o Wasm roda inicialmente em single-thread sem impor isolamento cross-origin às integrações externas.

Opcional:

- Defina `FLUTTER_VERSION` nas Environment Variables da Vercel para sobrescrever a versão padrão validada pelo projeto.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

Build local:

```bash
flutter build web --wasm --release --pwa-strategy=none --base-href /
```

O resultado deve conter `main.dart.wasm`, `main.dart.mjs` e `main.dart.js`.
