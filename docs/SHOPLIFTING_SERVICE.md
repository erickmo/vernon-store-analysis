# Shoplifting Detection Service

## Overview

**ShopliftingService** adalah service layer yang mengelola deteksi potensi shoplifting dari video CCTV stream. Service ini mengintegrasikan behavior tracking, scoring, dan alert management dalam satu unit yang terstruktur dan testable.

## Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│ CCTV Video Stream (StreamManager)                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Frame Analysis & Person Tracking                             │
│ - FrameAnalyzer (DeepFace emotion/age/gender)              │
│ - PersonTracker (face embedding & re-identification)        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ ShopliftingDetector (Behavior Scoring)                       │
│ - Track behavior profile per person                         │
│ - Apply 6 scoring rules (dwell, mood, zone changes, etc)   │
│ - Return confidence score 0.0-1.0                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ ShopliftingService (Business Logic)                          │
│ - Coordinate detection & alert creation                     │
│ - Provide behavior insights                                 │
│ - Manage alert lifecycle (create, resolve)                  │
│ - Compute statistics                                         │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. ShopliftingService

**File:** `src/vernon_store_analytics/services/shoplifting_service.py`

**Tanggung jawab:**
- Mengelola behavior tracking dan scoring
- Membuat dan mengelola shoplifting alerts
- Menyediakan insights dan statistics

**Dependencies:**
- `AlertRepository` — untuk CRUD alerts di database
- `VisitRepository` — untuk validation visit data
- `ShopliftingDetector` — untuk behavior analysis dan scoring

### 2. ShopliftingDetector

**File:** `src/vernon_store_analytics/services/stream/shoplifting_detector.py` ✅ (already exists)

**Cara Kerja:**
1. `update_profile()` — collect behavior data setiap deteksi orang
2. `evaluate()` — score behavior berdasarkan 6 rules:
   - Long dwell without cashier (>10 min)
   - Nervous mood (fear/angry/disgust >30%)
   - Frequent zone changes (≥3 changes)
   - Lingering floor only (>70% dwell time)
   - Exit without cashier (>5 min visit)
   - Rapid entry-exit (grab & run <2 min)
3. Return `ShopliftingScore` dengan confidence dan reasons

### 3. StreamManager Integration

**File:** `src/vernon_store_analytics/services/stream/stream_manager.py` ✅ (already exists)

StreamManager sudah mengintegrasikan shoplifting detection:
- Setiap frame analysis → update detector profile
- Setiap X frame → evaluate score
- Jika score > threshold → create ShopliftingAlert
- Broadcast alert ke WebSocket clients

## API Endpoints

### List Alerts

```http
GET /api/v1/stores/{store_id}/alerts?resolved=false&limit=50&offset=0
Authorization: Bearer <token>
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "visit_id": 1,
      "camera_id": 1,
      "confidence": 0.85,
      "timestamp": "2026-03-17T10:00:00Z",
      "notified": false,
      "resolved": false,
      "resolved_at": null,
      "resolved_note": null
    }
  ],
  "total": 1
}
```

### Resolve Alert

```http
PUT /api/v1/alerts/{alert_id}/resolve
Authorization: Bearer <token>
Content-Type: application/json

{
  "resolved_note": "False alarm - staff checking"
}
```

## Usage Examples

### 1. Get Active Profiles

```python
from src.vernon_store_analytics.services.shoplifting_service import ShopliftingService

service = ShopliftingService(alert_repo, visit_repo)

# Jumlah visitor yang sedang ditrack
count = await service.get_active_profiles_count()
print(f"Active profiles: {count}")
```

### 2. Evaluate Person Behavior

```python
# Get behavior score untuk satu person
result = await service.evaluate_person_behavior(person_uid="person_123")

if result and result["is_alert"]:
    print(f"⚠️  ALERT: confidence {result['confidence']}")
    for reason in result["reasons"]:
        print(f"  - {reason}")
```

### 3. Get Behavior Profile

```python
# Detail behavior profile untuk debugging
profile = await service.get_person_behavior_profile("person_123")

print(f"Dwell time: {profile['total_dwell_seconds']}s")
print(f"Zones visited: {profile['zones_visited']}")
print(f"Visited cashier: {profile['visited_cashier']}")
print(f"Nervous ratio: {profile['nervous_ratio']:.1%}")
```

### 4. Get Suspicious Persons

```python
# All person dengan score mencurigakan di atas threshold
suspicious = await service.get_all_suspicious_persons(threshold=0.75)

for person in suspicious:
    print(f"Person {person['person_uid']}: {person['confidence']:.1%}")
    for reason in person['reasons']:
        print(f"  - {reason}")
```

### 5. Get Statistics

```python
# Alert statistics untuk store
stats = await service.get_alert_statistics(store_id=1)

print(f"Total alerts: {stats['total_alerts']}")
print(f"Unresolved: {stats['unresolved_count']}")
print(f"Avg confidence: {stats['average_confidence']:.1%}")
```

## Scoring Rules

| Rule | Trigger | Score | Description |
|------|---------|-------|-------------|
| **Long Dwell** | >10 min without cashier | ≤0.35 | Mencurigakan jika terlalu lama di floor |
| **Nervous Mood** | >30% mood nervous | ≤0.35 | Takut/marah/jijik konsisten |
| **Zone Changes** | ≥3 perpindahan | ≤0.25 | Mondar-mandir tidak wajar |
| **Floor Lingering** | >70% dwell di floor | ≤0.20 | Hanya di area tanpa interaksi zona lain |
| **Exit No Cashier** | Exit setelah >5 min | 0.20 | Pergi tanpa membeli |
| **Grab & Run** | <2 min + zone changes | ≤0.30 | Entry-exit sangat cepat |

**Threshold:** Score ≥ 0.75 (default) → Alert

## Configuration

Environment variables di `.env`:

```bash
# Shoplifting detection config
SHOPLIFTING_THRESHOLD=0.75
SHOPLIFTING_NOTIFICATION_COOLDOWN_SECONDS=300
CCTV_FRAME_INTERVAL=0.5  # seconds between frame analysis
```

## Testing

### Unit Tests

```bash
# Run all unit tests
pytest tests/unit/test_shoplifting_service.py -v -s

# Run specific test
pytest tests/unit/test_shoplifting_service.py::test_evaluate_person_behavior_alert -v -s
```

**Test Coverage:**
- ✅ Get behavior profile (tracked, not tracked)
- ✅ Evaluate behavior (alert, no-alert, not tracked)
- ✅ Get active profiles count
- ✅ Get all suspicious persons (with custom threshold)
- ✅ Create alert (success, invalid visit, invalid confidence)
- ✅ List unresolved alerts
- ✅ Get alert statistics
- ✅ Mark alert reviewed (success, not found, already resolved)

### Integration Tests

```bash
# Run all integration tests
pytest tests/integration/test_shoplifting_alert_api.py -v -s
```

**Coverage:**
- ✅ List alerts (success, filters, pagination, not found, unauthorized)
- ✅ Resolve alert (success, already resolved, not found)
- ✅ Error handling (invalid params, validation)

## Output Format

Test output mengikuti format perusahaan:

```
────────────────────────────────────────────────────────────
TEST     : test_evaluate_person_behavior_alert
Scenario : Person memiliki suspicious behavior score di atas threshold
Goal     : Service return score dict dengan is_alert=True dan reasons
Flow     : service.evaluate_person_behavior(uid) →
           detector.evaluate() → ShopliftingScore(is_alert=True) →
           to_dict() → return
Result   : Score alert berhasil dikembalikan dengan reasons
Status   : ✅ PASSED
```

## Future Enhancements

- [ ] Notification system (email/SMS saat alert terjadi)
- [ ] ML-based behavior anomaly detection
- [ ] Real-time alert escalation
- [ ] Multi-camera person tracking across zones
- [ ] Heatmap generation untuk behavioral patterns

## Related Files

- `src/vernon_store_analytics/services/stream/shoplifting_detector.py` — Behavior scoring
- `src/vernon_store_analytics/services/stream/stream_manager.py` — Stream integration
- `src/vernon_store_analytics/repositories/alert_repository.py` — Database layer
- `src/vernon_store_analytics/api/v1/alert_router.py` — API endpoints
- `tests/unit/test_shoplifting_service.py` — Unit tests
- `tests/integration/test_shoplifting_alert_api.py` — Integration tests
