# Vernon Store Analytics — TODO

> Status per 2026-03-17. Diperbarui setiap selesai sprint/sesi.

---

## 🔴 Prioritas Tinggi

### [WEB] Fix token persistence loop saat startup
- **File:** `dashboard/lib/core/utils/token_manager.dart`
- **Problem:** `flutter_secure_storage` gagal baca/tulis di HTTP (WebCrypto butuh HTTPS). App melakukan login 2x saat startup karena token tidak terbaca.
- **Fix:** Gunakan `SharedPreferences` sebagai fallback di web platform, atau deteksi platform dan bypass secure storage di localhost.
- **Dampak:** UX — loading spinner muncul 2x saat pertama buka.

### [GIT] Commit perubahan analytics model
- **Files yang belum di-commit:**
  - `dashboard/lib/features/analytics/data/models/analytics_dashboard_model.dart` (rewrite penuh)
  - `dashboard/lib/features/analytics/domain/entities/analytics_dashboard_entity.dart` (rewrite penuh)
  - `dashboard/lib/features/analytics/presentation/pages/analytics_dashboard_page.dart`
  - `dashboard/lib/features/analytics/presentation/widgets/gender_chart_card.dart`
  - `dashboard/lib/features/analytics/presentation/widgets/mood_chart_card.dart`

---

## 🟡 Coding Standard (Wajib)

### [TEST] Widget test untuk semua screen baru
Per `flutter-coding-standard`: wajib widget test untuk setiap screen.

| Screen | File | Status |
|--------|------|--------|
| LoginPage | `features/auth/presentation/pages/login_page.dart` | ❌ Belum |
| StoreListPage | `features/store/presentation/pages/store_list_page.dart` | ❌ Belum |
| AnalyticsDashboardPage | `features/analytics/presentation/pages/analytics_dashboard_page.dart` | ❌ Belum |
| AlertListPage | `features/alert/presentation/pages/alert_list_page.dart` | ❌ Belum |
| TrafficPage | `features/traffic/presentation/pages/traffic_page.dart` | ❌ Belum |
| VisitorListPage | `features/visitor/presentation/pages/visitor_list_page.dart` | ❌ Belum |
| StatisticsPage | `features/statistics/presentation/pages/statistics_page.dart` | ❌ Belum |
| StreamControlPage | `features/stream/presentation/pages/stream_control_page.dart` | ❌ Belum |

### [LINT] Perbaiki warning yang ada
- `withOpacity` deprecated → ganti ke `.withValues()` (banyak file)
- `unnecessary_string_interpolations` di beberapa file
- Unused import di `streaming_cubit.dart`

---

## 🔵 Review Per Page

| # | Page | File | UI | Data | Error State | Empty State | Test | Catatan |
|---|------|------|----|------|-------------|-------------|------|---------|
| 1 | LoginPage | `auth/pages/login_page.dart` | ⬜ | ⬜ | ⬜ | — | ⬜ | |
| 2 | StoreListPage | `store/pages/store_list_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| 3 | CCTVStreamPage | `cctv/pages/cctv_stream_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | WebSocket belum ditest |
| 4 | AnalyticsDashboardPage | `analytics/pages/analytics_dashboard_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Model baru, perlu verifikasi chart render |
| 5 | AlertListPage | `alert/pages/alert_list_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| 6 | TrafficPage | `traffic/pages/traffic_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| 7 | VisitorListPage | `visitor/pages/visitor_list_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Belum ada pagination |
| 8 | VisitorDetailPage | `visitor/pages/visitor_detail_page.dart` | ⬜ | ⬜ | ⬜ | — | ⬜ | |
| 9 | StatisticsPage | `statistics/pages/statistics_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |
| 10 | StreamControlPage | `stream/pages/stream_control_page.dart` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | |

> **Legenda:** ✅ OK · ⚠️ Perlu perbaikan · ❌ Broken · ⬜ Belum direview · — Tidak berlaku

---

## 🟠 Fitur / Kualitas

### [ENV] API URL dari environment variable
- **File:** `dashboard/lib/core/network/api_endpoints.dart`
- **Problem:** URL `http://localhost:8000` hardcode.
- **Fix:** Gunakan `--dart-define=API_BASE_URL=...` dan baca via `String.fromEnvironment`.
- **Contoh:**
  ```bash
  flutter run --dart-define=API_BASE_URL=http://localhost:8000
  flutter build web --dart-define=API_BASE_URL=https://api.vernonstore.id
  ```

### [WS] Test WebSocket streaming CCTV
- **File:** `dashboard/lib/core/utils/websocket_client.dart`
- **Problem:** Belum diverifikasi apakah koneksi WebSocket ke stream API berjalan di web browser.
- **Fix:** Test manual dengan store_id dan camera_id yang valid.

### [UI] Error state yang informatif
- Beberapa halaman menampilkan pesan error generik.
- Tambahkan kode error, link retry, dan saran tindakan.

### [UI] Empty state yang baik
- Halaman visitor list, alert list belum punya ilustrasi empty state.

### [UI] Pagination / infinite scroll
- API mendukung `limit` & `offset` tapi Flutter belum implement pagination.
- Berlaku untuk: VisitorList, AlertList.

---

## 🟢 Infrastruktur

### [PWA] Update web manifest
- **File:** `dashboard/web/manifest.json`
- **Todo:**
  - Ganti nama app dari default Flutter ke "Vernon Store Analytics"
  - Update ikon PWA (512x512, 192x192)
  - Set `theme_color` dan `background_color` sesuai `AppColors`

### [DOCKER] Docker Compose untuk dev & prod
- Buat `docker-compose.yml` di root:
  - Service `api`: Python FastAPI + PostgreSQL
  - Service `dashboard`: Flutter web (nginx)
  - Service `db`: PostgreSQL 17
  - Service `nginx`: reverse proxy (prod)

### [CI] GitHub Actions pipeline
- Lint API (ruff) + test (pytest)
- Lint Flutter (flutter analyze) + test (flutter test)
- Build Flutter web PWA
- Deploy ke staging on push ke `develop`

### [HTTPS] HTTPS untuk development web
- Aktifkan HTTPS di Flutter web dev agar `flutter_secure_storage` (WebCrypto) berfungsi normal tanpa retry loop.
- Gunakan `mkcert` untuk self-signed cert lokal.
- Jalankan dengan: `flutter run -d chrome --web-tls-cert-path=... --web-tls-key-path=...`

---

## ✅ Selesai

- [x] Setup monorepo (satu git repo untuk api + dashboard)
- [x] Root Makefile dengan semua perintah dev/build
- [x] Flutter Clean Architecture — semua fitur (auth, store, cctv, analytics, alert, traffic, visitor, statistics, stream)
- [x] Dependency injection (GetIt) untuk semua fitur
- [x] JWT auth — login, logout, refresh token
- [x] Preset credentials di LoginPage (`admin@vernon.com`)
- [x] Sinkronisasi model analytics dengan API response format (list-based)
- [x] API running di `localhost:8000`
- [x] Flutter web running di `localhost:3000`
- [x] `flutter analyze` — 0 errors
