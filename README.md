# inLidaWeb

A new Flutter project.

## Deploy (Vercel)

Este projeto é Flutter Web (SPA). Na Vercel, configure:

- **Framework Preset**: `Other`
- **Build Command**: `bash scripts/vercel_build.sh`
- **Output Directory**: `build/web`

O `vercel.json` já inclui rewrite para `index.html` (necessário para rotas do Flutter não virarem 404/NOT_FOUND em refresh/deep link).

Este projeto está configurado para usar o **HTML renderer** em produção.

Opcional:

- Defina `FLUTTER_VERSION` (ex.: `3.24.5`) nas Environment Variables da Vercel.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

Build local (HTML renderer):

```bash
flutter build web --release --pwa-strategy=none --base-href / --web-renderer html
```
