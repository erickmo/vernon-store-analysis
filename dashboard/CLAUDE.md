# Vernon Store Analytics — Flutter Dashboard

## Project Overview
Dashboard analitik untuk Vernon Store yang terhubung ke backend FastAPI.
Menampilkan live CCTV feed, traffic analytics, mood detection, dan notifikasi shoplifting.

## Stack
- Flutter 3.x + Dart
- State management: BLoC / Cubit
- Architecture: Clean Architecture (features/domain/data/presentation)
- Platforms: **Web PWA**, **Android**, **iOS**
- Package: `com.vernon.store_analytics_dashboard`

## Architecture
```
lib/
└── features/
    └── <feature>/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── cubit/ (atau bloc/)
            ├── pages/
            └── widgets/
```

## Active Features
- [x] CCTV streaming (cctv_stream_page)
- [ ] Traffic analytics dashboard
- [ ] Mood tracking visualization
- [ ] Shoplifting alert & notification
- [ ] Auth (login/logout)

## Coding Rules
- SEMUA code ditulis oleh AI — tidak ada manual coding
- Ikuti `flutter-coding-standard` skill
- WAJIB gunakan BLoC/Cubit untuk state management
- WAJIB Clean Architecture — dilarang akses data langsung dari widget
- DILARANG hardcode API URL — dari environment config
- DILARANG `print()` — gunakan logger
- Semua network call via repository pattern

## Commands (dari folder dashboard/)
```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Jalankan di web
flutter run              # Jalankan di device/emulator
flutter test             # Jalankan test
flutter analyze          # Lint/analyze
flutter build web --release --pwa-strategy=offline-first
flutter build apk --release
flutter build ipa --release
```

## Commands (dari root monorepo)
```bash
make dev-dash            # flutter run -d chrome
make test-dash           # flutter test
make lint-dash           # flutter analyze
make build-web           # build PWA
make build-android       # build APK
make build-ios           # build IPA
make dash.pub-upgrade    # flutter pub upgrade
```

## Forbidden
- JANGAN akses API URL hardcoded
- JANGAN taruh business logic di widget/page
- JANGAN push langsung ke main/master
