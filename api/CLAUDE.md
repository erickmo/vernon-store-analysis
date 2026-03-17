# Vernon Store Analytics — Python API

## Project Overview
Backend engine yang terhubung dengan CCTV untuk store analytics. Mencakup analisa traffic pengunjung (siapa, mood, ID person), mood tracking sepanjang kunjungan, dan deteksi shoplifting dengan notifikasi otomatis.

## Stack
- Python 3.11 + FastAPI
- Database: PostgreSQL 17 + SQLAlchemy async
- Migration: Alembic
- Auth: JWT | Logger: structlog

## Architecture
src/vernon_store_analytics/api|services|repositories|models|core/

## PRD & Requirements
- PRD Utama: `docs/requirements/prd-vernon-store-analytics.md`

## Active Sprint
- [ ] Initial setup & core infrastructure
- [ ] CCTV stream integration & person detection
- [ ] Traffic analytics (visitor count, dwell time, heatmap)
- [ ] Person identification & mood detection
- [ ] Shoplifting detection & notification system

## Coding Rules
- SEMUA code ditulis oleh AI — tidak ada manual coding
- Ikuti `python-coding-standard` skill
- WAJIB type hints di semua fungsi
- WAJIB docstring di semua class dan fungsi public
- DILARANG raw SQL string interpolation
- DILARANG hardcode credential — dari Settings env
- DILARANG print() — gunakan structlog
- Exception dari core/exceptions.py
- DILARANG DB query dari router

## Commands
```bash
make dev          # uvicorn dengan --reload
make test         # pytest
make test-cov     # pytest + coverage report
make lint         # ruff check
make format       # black + ruff fix
make typecheck    # mypy
make migrate      # alembic upgrade head
```

## Forbidden
- JANGAN push langsung ke main/master
- JANGAN hardcode secret key atau DB URL
- JANGAN expose detail error ke client
