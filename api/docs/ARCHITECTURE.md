# Architecture Documentation

**Date:** 2026-03-17
**Status:** Complete
**Version:** 1.0.0

---

## System Overview

Vernon Store Analytics adalah **real-time CCTV-based shoplifting detection system** yang mengintegrasikan:
- Video stream processing dari multiple cameras
- Person detection & re-identification (face embedding)
- Behavior profiling & mood detection
- Shoplifting risk scoring (6 rules, 0.75 threshold)
- Alert management & resolution tracking
- Real-time WebSocket updates

---

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    CCTV Video Stream                         │
│              (RTSP/HTTP from IP cameras)                     │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────▼────────────┐
        │   Stream Manager        │ (services/stream/stream_manager.py)
        │   ─ Stream listener     │
        │   ─ Multi-camera mgmt   │
        │   ─ Lifecycle control   │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────────────┐
        │   Frame Analyzer                │ (services/stream/frame_analyzer.py)
        │   ─ Face detection (YOLO/etc)   │
        │   ─ Age, gender estimation      │
        │   ─ Face embedding extraction   │
        └────────────┬────────────────────┘
                     │
        ┌────────────▼────────────────────┐
        │   Person Tracker                │ (services/stream/person_tracker.py)
        │   ─ Face re-identification      │
        │   ─ Generate person_uid         │
        │   ─ Track person across frames  │
        └────────────┬────────────────────┘
                     │
        ┌────────────▼────────────────────┐
        │   Shoplifting Detector          │ (services/stream/shoplifting_detector.py)
        │   ─ Build behavior profile      │
        │   ─ Apply 6 scoring rules       │
        │   ─ Calculate confidence (0-1)  │
        └────────────┬────────────────────┘
                     │
        ┌────────────▼────────────────────────────┐
        │  Shoplifting Service (NEW) (services)   │
        │  ─ Coordinate detection results         │
        │  ─ Manage alert lifecycle               │
        │  ─ Provide analytics & insights         │
        └────────────┬────────────────────────────┘
                     │
        ┌────────────▼──────────────────────┐
        │  Repository Layer (data access)   │
        │  ─ AlertRepository                │
        │  ─ VisitRepository                │
        │  ─ CameraRepository               │
        │  ─ Custom queries & aggregations  │
        └────────────┬──────────────────────┘
                     │
        ┌────────────▼──────────────────────┐
        │  Database (PostgreSQL 17)         │
        │  ─ shoplifting_alerts             │
        │  ─ visits                         │
        │  ─ cameras                        │
        │  ─ stores                         │
        └──────────────────────────────────┘
                     │
        ┌────────────▼────────────────────────┐
        │  API Layer (FastAPI v1 routes)      │
        │  ─ REST endpoints                   │
        │  ─ WebSocket broadcast              │
        │  ─ JWT authentication               │
        │  ─ Request logging middleware       │
        └────────────┬────────────────────────┘
                     │
        ┌────────────▼────────────────────────┐
        │  Frontend (Separate React App)      │
        │  ─ Dashboard                        │
        │  ─ Alerts Management                │
        │  ─ Real-time Monitoring             │
        │  ─ Analytics & Reports              │
        └────────────────────────────────────┘
```

---

## Layered Architecture

### 1. **Presentation Layer (API)**
**Location:** `src/vernon_store_analytics/api/v1/`

Handles:
- HTTP REST endpoints
- WebSocket connections
- JWT authentication
- CORS headers
- Request/response validation

**Components:**
```
api/v1/
├── alert_router.py         (Alerts endpoints)
├── camera_router.py        (Camera management)
├── visitor_router.py       (Visitor tracking)
├── traffic_router.py       (Traffic analytics)
├── analytics_router.py     (Analytics data)
├── statistics_router.py    (Dashboard stats)
├── stream_router.py        (WebSocket + stream control)
├── auth_router.py          (Authentication)
└── middleware.py           (RequestLoggingMiddleware)
```

**Example Flow:**
```
Request → Router → validate JWT → Service call → Response
   ↓
WebSocket → broadcast message → Client receives in real-time
```

---

### 2. **Service Layer (Business Logic)**
**Location:** `src/vernon_store_analytics/services/`

Coordinates business operations:
- Behavior profiling (ShopliftingDetector)
- Alert lifecycle management
- Analytics computation
- Stream processing

**Components:**
```
services/
├── shoplifting_service.py      (Alert & behavior mgmt - NEW)
├── analytics_service.py        (Analytics computation)
├── auth_service.py             (JWT & password hashing)
├── stream/
│   ├── stream_manager.py       (Multi-camera orchestration)
│   ├── frame_analyzer.py       (Face detection & embedding)
│   ├── person_tracker.py       (Re-identification)
│   └── shoplifting_detector.py (Behavior scoring)
├── camera_service.py           (Camera CRUD + streaming)
└── traffic_service.py          (Footfall analytics)
```

**ShopliftingService Methods:**
```python
- get_person_behavior_profile(person_uid) → behavior data
- evaluate_person_behavior(person_uid) → confidence score
- create_alert_from_detection(visit_id, confidence) → alert
- list_unresolved_alerts(store_id) → alerts
- get_alert_statistics(store_id, period) → stats
- mark_alert_reviewed(alert_id, note) → resolved alert
```

---

### 3. **Repository Layer (Data Access)**
**Location:** `src/vernon_store_analytics/repositories/`

Abstracts database operations:
- CRUD operations
- Custom queries
- Transaction management

**Components:**
```
repositories/
├── alert_repository.py         (Alert CRUD)
├── visit_repository.py         (Visit tracking)
├── camera_repository.py        (Camera CRUD)
├── visitor_repository.py       (Visitor profiles)
├── traffic_repository.py       (Traffic analytics)
└── base_repository.py          (Base class with common operations)
```

---

### 4. **Models & Database**
**Location:** `src/vernon_store_analytics/models/`

**Database Schema:**
```
models/db/
├── store.py              (Store configuration)
├── camera.py             (CCTV camera metadata)
├── visit.py              (Visitor session)
├── shoplifting_alert.py  (Shoplifting detection alert)
├── visitor.py            (Visitor profile)
├── user.py               (User account)
└── audit_log.py          (Audit trail)

models/request/  (Pydantic request models)
├── alert_request.py
├── camera_request.py
└── ...

models/response/ (Pydantic response models)
├── alert_response.py
├── camera_response.py
└── ...
```

---

### 5. **Core Utilities**
**Location:** `src/vernon_store_analytics/core/`

Infrastructure & configuration:
```
core/
├── config.py           (Settings from env)
├── database.py         (SQLAlchemy async setup)
├── security.py         (JWT, password hashing)
├── logger.py           (Structlog configuration)
├── exceptions.py       (Custom exception classes)
├── constants.py        (Application constants)
└── enums.py            (Enum types)
```

---

## Data Flow

### A. Real-Time Detection Flow

```
1. CCTV Stream
   └─ RTSP URL: rtsp://192.168.1.100:554/stream1
   └─ Frames: 25 FPS

2. StreamManager.start_stream()
   └─ Opens video capture
   └─ Spawns frame processing tasks

3. Frame Processing Loop (per frame)
   a) FrameAnalyzer.analyze_frame(frame)
      └─ Detect faces → extract embeddings
      └─ Estimate: age, gender, mood
      └─ Result: Frame detection data

   b) PersonTracker.track_person(detections)
      └─ Match face embeddings with history
      └─ Generate person_uid (unique ID)
      └─ Update person tracking state
      └─ Result: Tracked persons list

   c) ShopliftingDetector.update_profile(person_uid, detection)
      └─ Add detection to behavior profile
      └─ Track: zones visited, mood, dwell time
      └─ Apply 6 scoring rules
      └─ Result: behavior_score (0.0-1.0)

4. Check Alert Threshold
   if behavior_score >= 0.75:
      └─ ShopliftingService.create_alert()
      └─ Save to database
      └─ Broadcast via WebSocket

5. Frontend Receives Alert
   └─ Toast notification
   └─ Add to alerts table
   └─ Sound alert (configurable)
```

---

### B. Alert Resolution Flow

```
1. User clicks "Resolve" in Dashboard
   └─ Frontend: PUT /api/v1/alerts/{alert_id}/resolve
   └─ Payload: { note: "False alarm, customer was browsing" }

2. API Endpoint (alert_router.py)
   └─ Validate JWT token
   └─ ShopliftingService.mark_alert_reviewed(alert_id, note)

3. ShopliftingService
   └─ Check alert exists & not already resolved
   └─ AlertRepository.update() → set status, resolved_at, note
   └─ Save to database

4. Response
   └─ 200 OK with updated alert data
   └─ Frontend updates UI
```

---

### C. Analytics Query Flow

```
1. User requests: GET /api/v1/analytics/shoplifting?period=week

2. API Endpoint (analytics_router.py)
   └─ Parse period (day/week/month/year)
   └─ AnalyticsService.get_shoplifting_analytics(store_id, period)

3. AnalyticsService
   └─ AlertRepository.get_alerts_by_period()
   └─ Aggregate by: day, hour, camera, behavior reason
   └─ Calculate: total, resolved, resolution_rate, avg_confidence
   └─ Compute: top behaviors, camera performance

4. Response
   └─ 200 OK with complete analytics object
   └─ Frontend renders charts & tables
```

---

## Database Schema (Simplified)

```sql
-- Stores
CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    config JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Cameras
CREATE TABLE cameras (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    name VARCHAR(255),
    location VARCHAR(255),
    zone VARCHAR(100),
    stream_url VARCHAR(500),
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Visits (visitor sessions)
CREATE TABLE visits (
    id SERIAL PRIMARY KEY,
    store_id INTEGER REFERENCES stores(id),
    person_uid VARCHAR(255),
    entry_time TIMESTAMP,
    exit_time TIMESTAMP,
    dwell_time_seconds INTEGER,
    zones_visited TEXT[],
    mood_distribution JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Shoplifting Alerts
CREATE TABLE shoplifting_alerts (
    id SERIAL PRIMARY KEY,
    visit_id INTEGER REFERENCES visits(id),
    camera_id INTEGER REFERENCES cameras(id),
    person_uid VARCHAR(255),
    confidence FLOAT CHECK (confidence >= 0.0 AND confidence <= 1.0),
    timestamp TIMESTAMP,
    status VARCHAR(50), -- unresolved, resolved, dismissed
    reasons TEXT[],
    resolved_at TIMESTAMP,
    resolved_by VARCHAR(255),
    resolved_note TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX idx_alerts_store_status ON shoplifting_alerts(store_id, status);
CREATE INDEX idx_alerts_timestamp ON shoplifting_alerts(timestamp DESC);
CREATE INDEX idx_visits_person_uid ON visits(person_uid);
CREATE INDEX idx_cameras_store_id ON cameras(store_id);
```

---

## Authentication & Authorization

### JWT Token Flow

```
1. User Login
   POST /api/v1/auth/login
   ├─ Email + Password
   ├─ Validate credentials
   └─ Return: JWT token (1 hour expiry)

2. Token Storage
   ├─ Frontend: HTTP-only cookie OR localStorage
   ├─ Auto-refresh if < 5 min remaining

3. Authenticated Request
   GET /api/v1/stores/1/alerts
   ├─ Header: Authorization: Bearer <token>
   ├─ Middleware: validate JWT signature
   ├─ Extract: user_id, store_id, role
   └─ Check: user has access to store_id

4. Authorization
   ├─ Role-based access (Admin, Manager, Security, Viewer)
   ├─ Store-based access (can only see own store)
   ├─ API returns 403 Forbidden if unauthorized
```

---

## WebSocket Real-Time Architecture

### Connection Flow

```
Client Browser
     │
     ├─ WebSocket /ws/stream
     │
Server (FastAPI)
     │
     ├─ Authenticate JWT token
     ├─ Add connection to active pool
     │
     └─ Listen to events:
        ├─ detection_update (from ShopliftingDetector)
        ├─ shoplifting_alert (from AlertRepository)
        └─ stream_status (from StreamManager)
```

### Message Broadcasting

```
Event Trigger
     │
     ├─ Detection complete (new behavior_score)
     │  └─ Broadcast to ALL connected clients
     │     └─ Message: { type: "detection_update", ... }
     │
     ├─ Alert created (confidence >= 0.75)
     │  └─ Broadcast to ALL connected clients
     │     └─ Message: { type: "shoplifting_alert", ... }
     │
     ├─ Alert resolved
     │  └─ Broadcast to ALL connected clients
     │     └─ Message: { type: "alert_resolved", ... }
```

---

## Scaling Considerations

### Horizontal Scaling

**Stateless API:**
- All API servers can handle any request
- No session affinity needed
- Load balance with Nginx/HAProxy

**Database Scaling:**
- PostgreSQL primary-replica setup
- Read replicas for analytics queries
- Connection pooling (pgBouncer)

**Stream Processing:**
- Stream manager runs on dedicated worker nodes
- One process per camera (or batched)
- Message queue (Redis/RabbitMQ) for scale

---

## Performance Optimization

### Caching Strategy

**Frontend (React Query):**
- Alerts: stale-time 30s, gc-time 5m
- Analytics: stale-time 60s, gc-time 10m
- Visitors: stale-time 120s, gc-time 15m

**Backend:**
- Database query caching (Redis)
- API response caching (HTTP headers)
- WebSocket debouncing (coalescence of updates)

### Database Optimization

**Indexes:**
```sql
-- Fast alert queries
CREATE INDEX idx_alerts_store_status ON shoplifting_alerts(store_id, status);
CREATE INDEX idx_alerts_timestamp ON shoplifting_alerts(timestamp DESC);

-- Fast visitor queries
CREATE INDEX idx_visits_person_uid ON visits(person_uid);
CREATE INDEX idx_visits_store_entry ON visits(store_id, entry_time DESC);
```

**Partitioning (future):**
- Partition `shoplifting_alerts` by month
- Partition `visits` by month or week
- Archive old data to cold storage

---

## Deployment Architecture

### Development Environment

```
localhost:8000
    ├─ FastAPI app
    ├─ PostgreSQL (Docker)
    ├─ Redis (Docker)
    ├─ Stream Manager (single camera)
    └─ Frontend (localhost:3000)
```

### Production Environment

```
Load Balancer (Nginx/HAProxy)
    ├─ API Server 1 (uvicorn)
    ├─ API Server 2 (uvicorn)
    └─ API Server N (uvicorn)
         │
    PostgreSQL Primary
         │
    ├─ Read Replica 1
    ├─ Read Replica 2
    └─ Backup
         │
    Redis Cache
         │
    Worker Nodes
    ├─ Stream Manager 1 (camera 1-4)
    ├─ Stream Manager 2 (camera 5-8)
    └─ Stream Manager N
         │
    Message Queue (RabbitMQ/Redis)
         │
    Frontend (React App)
```

---

## Security Architecture

### API Security

```
Request Flow:
1. TLS/HTTPS encryption (in-transit)
2. CORS middleware (cross-origin)
3. JWT authentication header
4. Role-based authorization
5. Input validation (Pydantic)
6. Rate limiting (per user)
7. Logging & audit trail
8. Response filtering (no sensitive data)
```

### Database Security

```
- Connection pooling (encrypted)
- SQL parameterization (prevent injection)
- Password hashing (bcrypt)
- Secrets management (environment variables)
- Read-only database users (for reports)
```

---

## Monitoring & Observability

### Logging

**Structured Logging (structlog):**
```python
logger.info("user_logged_in", user_id=1, store_id=1, ip="192.168.1.1")
logger.warning("alert_created", alert_id=1, confidence=0.87)
logger.error("stream_disconnected", camera_id=1, error="Connection timeout")
```

### Metrics

**Application Metrics:**
- Request latency (p50, p99)
- Error rate (4xx, 5xx)
- Alert detection rate
- WebSocket connections active
- Database query time

**Infrastructure Metrics:**
- CPU, memory, disk usage
- Network throughput
- Database connections
- Cache hit rate

---

## Related Documentation

- [OpenAPI Specification](./OPENAPI.md)
- [API Examples](./API_EXAMPLES.md)
- [Database Schema](./DATABASE_SCHEMA.md)
- [Error Handling](./ERROR_HANDLING.md)
- [Deployment Guide](./DEPLOYMENT.md)
- [Frontend Integration](./FRONTEND_INTEGRATION.md)

---

**Last Updated:** 2026-03-17
**Version:** 1.0.0
