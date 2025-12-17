# inLidaWeb

A new Flutter project.

## Deploy (Vercel)

Este projeto é Flutter Web (SPA). Na Vercel, configure:

- **Framework Preset**: `Other`
- **Build Command**: `bash scripts/vercel_build.sh`
- **Output Directory**: `build/web`

O `vercel.json` já inclui rewrite para `index.html` (necessário para rotas do Flutter não virarem 404/NOT_FOUND em refresh/deep link).

Opcional:

- Defina `FLUTTER_VERSION` (ex.: `3.24.5`) nas Environment Variables da Vercel.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.
