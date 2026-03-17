# Vernon Store Analytics — Monorepo

## Struktur Project
```
vernon-store-analysis/
├── api/          # Python FastAPI backend
└── dashboard/    # Flutter app (Web PWA + Android + iOS)
```

## Stack
| Layer     | Tech                                          |
|-----------|-----------------------------------------------|
| Backend   | Python 3.11, FastAPI, PostgreSQL 17, SQLAlchemy async, Alembic, JWT |
| Frontend  | Flutter 3.x, Clean Architecture, BLoC/Cubit   |
| Platforms | Web PWA, Android, iOS                         |

## Coding Rules (berlaku di seluruh monorepo)
- SEMUA code ditulis oleh AI — tidak ada manual coding
- Ikuti skill `python-coding-standard` untuk code di `api/`
- Ikuti skill `flutter-coding-standard` untuk code di `dashboard/`
- DILARANG hardcode credential — selalu dari env/Settings
- DILARANG `print()` di Python — gunakan `structlog`

## Commands (dari root)
```bash
make help            # Lihat semua perintah
make install         # Install semua dependencies
make dev             # Jalankan API + Dashboard parallel
make dev-api         # API saja (localhost:8000)
make dev-dash        # Flutter web (chrome)
make test            # Semua test
make lint            # Lint semua project
make build-web       # Build Flutter PWA
make build-android   # Build APK
make build-ios       # Build IPA
make api.<target>    # Pass-through ke Makefile api/ (contoh: make api.migrate)
make dash.<target>   # Pass-through ke flutter CLI (contoh: make dash.pub-upgrade)
```

## Per-project Detail
- API: lihat `api/CLAUDE.md`
- Dashboard: lihat `dashboard/CLAUDE.md`

## Forbidden
- JANGAN push langsung ke main/master
- JANGAN hardcode secret key, DB URL, atau API endpoint
- JANGAN expose detail error ke client
