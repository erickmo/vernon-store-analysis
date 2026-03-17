# PRD: Vernon Store Analytics

**Versi:** 1.0.0
**Tanggal:** 2026-03-16
**Status:** Draft
**Stack:** Python / FastAPI / PostgreSQL 17
**Author:** AI-Generated
**Reviewer:** -

---

## 1. Overview

### 1.1 Latar Belakang
Retail store membutuhkan insight real-time tentang perilaku pengunjung untuk meningkatkan operasional dan keamanan. Saat ini tidak ada sistem terpadu yang bisa menganalisa traffic, mengenali pengunjung, mendeteksi mood, dan memperingatkan potensi shoplifting dari satu platform.

### 1.2 Tujuan
- Menyediakan backend engine yang terhubung dengan CCTV store untuk analytics real-time
- Menganalisa traffic pengunjung secara lengkap (siapa, kapan, berapa lama, mood)
- Mendeteksi dan memberi notifikasi otomatis jika ditemukan kemungkinan shoplifting melebihi threshold

### 1.3 Scope
**In Scope:**
- REST API untuk store analytics
- Integrasi CCTV stream (RTSP/HTTP)
- Person detection & identification (unique visitor ID)
- Mood detection & tracking sepanjang kunjungan
- Traffic analytics (visitor count, dwell time, entry/exit)
- Shoplifting detection dengan configurable threshold
- Notification system (webhook, email)
- Autentikasi JWT

**Out of Scope:**
- Frontend / dashboard UI
- Hardware CCTV setup
- Training ML model (menggunakan pre-trained models)
- Payment / POS integration

---

## 2. Domain Model (Rencana Awal)

| Entity | Deskripsi | Fields Utama |
|---|---|---|
| Store | Informasi store | id, name, location, timezone |
| Camera | CCTV yang terdaftar | id, store_id, name, stream_url, location_zone |
| Visitor | Unique person yang terdeteksi | id, store_id, person_embedding, first_seen_at |
| Visit | Satu kunjungan visitor ke store | id, visitor_id, camera_id, entry_at, exit_at, dwell_seconds |
| MoodLog | Log mood visitor per waktu | id, visit_id, timestamp, mood, confidence |
| ShopliftingAlert | Alert potensi shoplifting | id, visit_id, camera_id, confidence, timestamp, notified, resolved |
| TrafficSnapshot | Agregasi traffic per interval | id, store_id, timestamp, visitor_count, avg_dwell |

---

## 3. API Endpoints (Rencana Awal)

| Method | Path | Deskripsi | Auth |
|---|---|---|---|
| POST | /api/v1/auth/login | Login | No |
| **Store** | | | |
| GET | /api/v1/stores | List stores | Yes |
| POST | /api/v1/stores | Register store | Yes |
| **Camera** | | | |
| GET | /api/v1/stores/{store_id}/cameras | List cameras | Yes |
| POST | /api/v1/stores/{store_id}/cameras | Register camera | Yes |
| **Traffic** | | | |
| GET | /api/v1/stores/{store_id}/traffic | Traffic summary | Yes |
| GET | /api/v1/stores/{store_id}/traffic/realtime | Real-time visitor count | Yes |
| GET | /api/v1/stores/{store_id}/traffic/heatmap | Traffic heatmap data | Yes |
| **Visitors** | | | |
| GET | /api/v1/stores/{store_id}/visitors | List detected visitors | Yes |
| GET | /api/v1/visitors/{visitor_id} | Visitor detail + visit history | Yes |
| GET | /api/v1/visitors/{visitor_id}/mood-timeline | Mood timeline per visit | Yes |
| **Shoplifting** | | | |
| GET | /api/v1/stores/{store_id}/alerts | List shoplifting alerts | Yes |
| PUT | /api/v1/alerts/{alert_id}/resolve | Resolve alert | Yes |
| **Settings** | | | |
| GET | /api/v1/stores/{store_id}/settings | Get store detection settings | Yes |
| PUT | /api/v1/stores/{store_id}/settings | Update threshold & config | Yes |

---

## 4. Non-Functional Requirements

| Kategori | Target |
|---|---|
| Response time (p95) | < 200ms |
| Test coverage | >= 80% |
| Auth | JWT 15 menit access token |
| Shoplifting alert latency | < 5 detik dari deteksi ke notifikasi |
| CCTV frame processing | configurable interval (default 5s) |

---

## 5. Environment Variables

| Variable | Wajib | Keterangan |
|---|---|---|
| DATABASE_URL | Ya | PostgreSQL 17 connection string |
| SECRET_KEY | Ya | JWT signing key (min 32 char) |
| CCTV_STREAM_URLS | Tidak | Default CCTV streams |
| SHOPLIFTING_THRESHOLD | Tidak | Default 0.75 (0.0 - 1.0) |
| NOTIFICATION_WEBHOOK_URL | Tidak | Webhook untuk alert |
| NOTIFICATION_EMAIL_TO | Tidak | Email untuk alert |

---

## 6. Out of Scope
- Frontend dashboard (akan di-repo terpisah)
- ML model training pipeline
- Multi-tenant architecture (v2)
- Video recording / playback

---

## 7. Open Questions
- [ ] ML model apa yang akan digunakan untuk person detection? (YOLO, MediaPipe, dll)
- [ ] ML model untuk mood detection? (FER, DeepFace, dll)
- [ ] Apakah perlu face recognition atau cukup person re-identification?
- [ ] Format notifikasi shoplifting — webhook saja atau perlu push notification?
- [ ] Retention policy untuk data visitor dan mood log?

---
*Di-generate saat project init. Update sesuai perkembangan project.*
