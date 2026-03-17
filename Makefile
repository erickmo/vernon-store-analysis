# Vernon Store Analytics — Monorepo
# Usage: make <target>
#        make api.<target>     → jalankan target di api/
#        make dash.<target>    → jalankan target di dashboard/

.PHONY: help dev dev-api dev-dash install install-api install-dash \
        test test-api test-dash lint lint-api lint-dash \
        build build-web build-android build-ios clean

# ─── Default ────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "Vernon Store Analytics — Monorepo Commands"
	@echo ""
	@echo "  make dev             Jalankan API + Dashboard (parallel)"
	@echo "  make dev-api         Jalankan API saja"
	@echo "  make dev-dash        Jalankan Flutter dashboard (web)"
	@echo ""
	@echo "  make install         Install semua dependencies"
	@echo "  make install-api     Install Python dependencies"
	@echo "  make install-dash    flutter pub get"
	@echo ""
	@echo "  make test            Jalankan semua test"
	@echo "  make test-api        Jalankan Python test"
	@echo "  make test-dash       Jalankan Flutter test"
	@echo ""
	@echo "  make lint            Lint semua project"
	@echo "  make build-web       Build Flutter untuk Web/PWA"
	@echo "  make build-android   Build Flutter APK"
	@echo "  make build-ios       Build Flutter IPA"
	@echo "  make clean           Bersihkan build artifacts"
	@echo ""

# ─── Dev ────────────────────────────────────────────────────────────────────
dev:
	@echo "Starting API + Dashboard..."
	$(MAKE) dev-api & $(MAKE) dev-dash

dev-api:
	$(MAKE) -C api dev

dev-dash:
	cd dashboard && flutter run -d chrome

# ─── Install ────────────────────────────────────────────────────────────────
install: install-api install-dash

install-api:
	$(MAKE) -C api install

install-dash:
	cd dashboard && flutter pub get

# ─── Test ───────────────────────────────────────────────────────────────────
test: test-api test-dash

test-api:
	$(MAKE) -C api test

test-dash:
	cd dashboard && flutter test

# ─── Lint ───────────────────────────────────────────────────────────────────
lint: lint-api lint-dash

lint-api:
	$(MAKE) -C api lint

lint-dash:
	cd dashboard && flutter analyze

# ─── Build ──────────────────────────────────────────────────────────────────
build-web:
	cd dashboard && flutter build web --release --pwa-strategy=offline-first

build-android:
	cd dashboard && flutter build apk --release

build-ios:
	cd dashboard && flutter build ipa --release

# ─── API pass-through (make api.migrate, make api.seed, dll) ───────────────
api.%:
	$(MAKE) -C api $*

# ─── Dashboard pass-through (make dash.pub-upgrade, dll) ───────────────────
dash.%:
	cd dashboard && flutter $*

# ─── Clean ──────────────────────────────────────────────────────────────────
clean:
	$(MAKE) -C api clean
	cd dashboard && flutter clean
