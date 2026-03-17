# Database Schema Documentation

**Date:** 2026-03-17
**Status:** Complete
**Database:** PostgreSQL 17
**Version:** 1.0.0

---

## Schema Overview

Vernon Store Analytics menggunakan PostgreSQL dengan schema berikut:

```
Stores (store configuration)
├─ Cameras (CCTV cameras per store)
├─ Users (staff accounts)
└─ Visits (visitor sessions)
   └─ ShopliftingAlerts (detection alerts)
```

**Total Tables:** 8
**Relationships:** 15+ foreign keys
**Indexes:** 20+ performance indexes

---

## Table Schemas

### 1. stores

Konfigurasi toko/lokasi retail.

```sql
CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    location VARCHAR(500),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),

    -- Configuration
    config JSONB DEFAULT '{}'::jsonb,
    -- Example: {
    --   "shoplifting_threshold": 0.75,
    --   "notification_cooldown_seconds": 300,
    --   "camera_count": 3
    -- }

    -- Status
    status VARCHAR(50) DEFAULT 'active',
    -- Values: active, inactive, archived

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX idx_stores_name ON stores(name);
CREATE INDEX idx_stores_status ON stores(status);
```

**Columns:**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | SERIAL | NO | Primary key, auto-increment |
| name | VARCHAR(255) | NO | Store name (unique) |
| location | VARCHAR(500) | YES | Store location/zone |
| address | TEXT | YES | Physical address |
| phone | VARCHAR(20) | YES | Contact phone |
| email | VARCHAR(255) | YES | Contact email |
| config | JSONB | NO | Configuration (threshold, cooldown) |
| status | VARCHAR(50) | NO | active/inactive/archived |
| created_at | TIMESTAMP | NO | Creation timestamp |
| updated_at | TIMESTAMP | NO | Last update timestamp |

---

### 2. cameras

CCTV cameras per store.

```sql
CREATE TABLE cameras (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id) ON DELETE CASCADE,

    -- Camera metadata
    name VARCHAR(255) NOT NULL,
    location VARCHAR(500),
    zone VARCHAR(100),
    -- Zones: entrance, floor, shelf_a, shelf_b, shelf_c, checkout, storage

    -- Stream configuration
    stream_url VARCHAR(500) NOT NULL,
    -- Format: rtsp://ip:port/stream or http://...

    stream_type VARCHAR(50) DEFAULT 'rtsp',
    -- Types: rtsp, http, hls, rtmp

    username VARCHAR(255),
    -- RTSP username (if required)

    password VARCHAR(255),
    -- RTSP password (encrypted in production)

    -- Status
    status VARCHAR(50) DEFAULT 'active',
    -- Values: active, inactive, maintenance, error

    stream_status VARCHAR(50) DEFAULT 'disconnected',
    -- Values: connected, disconnected, error

    last_connected_at TIMESTAMP,
    fps INTEGER DEFAULT 25,
    resolution VARCHAR(50),
    -- Format: "1920x1080"

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_cameras_store_id ON cameras(store_id);
CREATE INDEX idx_cameras_status ON cameras(store_id, status);
CREATE INDEX idx_cameras_zone ON cameras(store_id, zone);
```

**Columns:**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | SERIAL | NO | Primary key |
| store_id | INTEGER | NO | Foreign key to stores |
| name | VARCHAR(255) | NO | Camera name |
| location | VARCHAR(500) | YES | Physical location in store |
| zone | VARCHAR(100) | YES | Zone identifier |
| stream_url | VARCHAR(500) | NO | RTSP/HTTP stream URL |
| stream_type | VARCHAR(50) | NO | Protocol type |
| username | VARCHAR(255) | YES | Stream authentication |
| password | VARCHAR(255) | YES | Stream authentication |
| status | VARCHAR(50) | NO | active/inactive/maintenance/error |
| stream_status | VARCHAR(50) | NO | connected/disconnected/error |
| last_connected_at | TIMESTAMP | YES | Last successful connection |
| fps | INTEGER | NO | Frames per second (default 25) |
| resolution | VARCHAR(50) | YES | Video resolution |
| created_at | TIMESTAMP | NO | Creation timestamp |
| updated_at | TIMESTAMP | NO | Last update timestamp |

---

### 3. users

Staff accounts untuk login.

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id),

    -- Auth
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    -- Bcrypt hashed password

    -- Profile
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'viewer',
    -- Roles: admin, manager, security_staff, viewer

    -- Status
    status VARCHAR(50) DEFAULT 'active',
    -- Values: active, inactive, suspended

    -- Security
    is_2fa_enabled BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP,
    password_changed_at TIMESTAMP,

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
```

**Columns:**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | SERIAL | NO | Primary key |
| store_id | INTEGER | NO | Foreign key to stores |
| email | VARCHAR(255) | NO | Email (unique) |
| password_hash | VARCHAR(255) | NO | Bcrypt hashed password |
| name | VARCHAR(255) | NO | Full name |
| role | VARCHAR(50) | NO | admin/manager/security_staff/viewer |
| status | VARCHAR(50) | NO | active/inactive/suspended |
| is_2fa_enabled | BOOLEAN | NO | 2FA enabled flag |
| last_login_at | TIMESTAMP | YES | Last login timestamp |
| password_changed_at | TIMESTAMP | YES | Last password change |
| created_at | TIMESTAMP | NO | Creation timestamp |
| updated_at | TIMESTAMP | NO | Last update timestamp |

---

### 4. visits

Visitor sessions dalam store.

```sql
CREATE TABLE visits (
    id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id),
    camera_id INTEGER REFERENCES cameras(id),

    -- Visitor identification
    person_uid VARCHAR(255) NOT NULL,
    -- Unique person identifier from face embedding

    -- Timeline
    entry_time TIMESTAMP NOT NULL,
    exit_time TIMESTAMP,
    dwell_time_seconds INTEGER,

    -- Behavior tracking
    zones_visited TEXT[] DEFAULT '{}',
    -- Array of zone names: [entrance, floor, shelf_a, checkout]

    mood_distribution JSONB DEFAULT '{}'::jsonb,
    -- Example: { "neutral": 0.5, "happy": 0.3, "nervous": 0.2 }

    age_estimate INTEGER,
    gender VARCHAR(20),
    -- M, F, or Unknown

    -- Status
    status VARCHAR(50) DEFAULT 'active',
    -- Values: active, completed, unknown

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_visits_store_id ON visits(store_id);
CREATE INDEX idx_visits_person_uid ON visits(person_uid);
CREATE INDEX idx_visits_entry_time ON visits(entry_time DESC);
CREATE INDEX idx_visits_exit_time ON visits(exit_time DESC);
CREATE INDEX idx_visits_person_store_time ON visits(store_id, person_uid, entry_time DESC);
```

**Columns:**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | SERIAL | NO | Primary key |
| store_id | INTEGER | NO | Foreign key to stores |
| camera_id | INTEGER | YES | Foreign key to cameras |
| person_uid | VARCHAR(255) | NO | Unique person identifier |
| entry_time | TIMESTAMP | NO | Entry timestamp |
| exit_time | TIMESTAMP | YES | Exit timestamp |
| dwell_time_seconds | INTEGER | YES | Time spent in store (seconds) |
| zones_visited | TEXT[] | NO | Array of zones visited |
| mood_distribution | JSONB | NO | Mood percentages |
| age_estimate | INTEGER | YES | Estimated age |
| gender | VARCHAR(20) | YES | Estimated gender (M/F/Unknown) |
| status | VARCHAR(50) | NO | active/completed/unknown |
| created_at | TIMESTAMP | NO | Creation timestamp |
| updated_at | TIMESTAMP | NO | Last update timestamp |

---

### 5. shoplifting_alerts

Deteksi ancaman shoplifting dari visitor behavior.

```sql
CREATE TABLE shoplifting_alerts (
    id SERIAL PRIMARY KEY,
    visit_id INTEGER NOT NULL REFERENCES visits(id),
    camera_id INTEGER NOT NULL REFERENCES cameras(id),

    -- Detection data
    person_uid VARCHAR(255) NOT NULL,
    confidence FLOAT NOT NULL CHECK (confidence >= 0.0 AND confidence <= 1.0),
    -- Confidence score 0.0 (safe) to 1.0 (certain)

    -- Detection timestamp
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Behavior reasons
    reasons TEXT[] DEFAULT '{}',
    -- Array of detected suspicious behaviors
    -- Examples:
    -- - "Dwell 15 menit tanpa ke kasir"
    -- - "Mood nervous 60%"
    -- - "Zone changes 3 kali"
    -- - "Floor lingering 75%"
    -- - "Exit tanpa kasir >5 min"
    -- - "Grab & run <2 min"

    -- Resolution tracking
    status VARCHAR(50) DEFAULT 'unresolved',
    -- Values: unresolved, resolved, dismissed, false_alarm

    resolved_at TIMESTAMP,
    resolved_by VARCHAR(255),
    -- Username of staff who resolved

    resolved_note TEXT,
    -- Staff notes/comments

    notified BOOLEAN DEFAULT FALSE,
    -- Whether staff was notified

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes (critical for queries)
CREATE INDEX idx_alerts_store_status
    ON shoplifting_alerts(
        (SELECT store_id FROM visits WHERE visits.id = visit_id),
        status
    );
CREATE INDEX idx_alerts_timestamp ON shoplifting_alerts(timestamp DESC);
CREATE INDEX idx_alerts_visit_id ON shoplifting_alerts(visit_id);
CREATE INDEX idx_alerts_camera_id ON shoplifting_alerts(camera_id);
CREATE INDEX idx_alerts_person_uid ON shoplifting_alerts(person_uid);
CREATE INDEX idx_alerts_status ON shoplifting_alerts(status);
CREATE INDEX idx_alerts_confidence ON shoplifting_alerts(confidence DESC);
```

**Columns:**

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| id | SERIAL | NO | Primary key |
| visit_id | INTEGER | NO | Foreign key to visits |
| camera_id | INTEGER | NO | Foreign key to cameras |
| person_uid | VARCHAR(255) | NO | Unique person identifier |
| confidence | FLOAT | NO | Confidence score 0.0-1.0 |
| timestamp | TIMESTAMP | NO | When alert was detected |
| reasons | TEXT[] | NO | Array of detected reasons |
| status | VARCHAR(50) | NO | unresolved/resolved/dismissed |
| resolved_at | TIMESTAMP | YES | When resolved |
| resolved_by | VARCHAR(255) | YES | Username who resolved |
| resolved_note | TEXT | YES | Staff comments |
| notified | BOOLEAN | NO | Notification sent flag |
| created_at | TIMESTAMP | NO | Creation timestamp |
| updated_at | TIMESTAMP | NO | Last update timestamp |

---

### 6. audit_logs

Audit trail untuk compliance dan security.

```sql
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,

    -- Actor
    user_id INTEGER REFERENCES users(id),
    username VARCHAR(255),

    -- Action
    action VARCHAR(100) NOT NULL,
    -- Examples: login, logout, alert_resolved, alert_dismissed, user_created, camera_added

    resource_type VARCHAR(100),
    -- Examples: alert, user, camera, store

    resource_id INTEGER,
    old_values JSONB,
    new_values JSONB,

    -- Context
    ip_address VARCHAR(45),
    user_agent TEXT,

    status VARCHAR(50) DEFAULT 'success',
    -- Values: success, failure, denied

    error_message TEXT,

    -- Timestamp
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
```

---

### 7. alert_notifications

Notification delivery tracking.

```sql
CREATE TABLE alert_notifications (
    id BIGSERIAL PRIMARY KEY,
    alert_id INTEGER NOT NULL REFERENCES shoplifting_alerts(id),

    -- Notification channels
    channel VARCHAR(50) NOT NULL,
    -- email, sms, slack, teams, in_app

    recipient VARCHAR(255) NOT NULL,
    -- email, phone, slack_id, etc

    -- Status
    status VARCHAR(50) DEFAULT 'pending',
    -- pending, sent, failed, bounced

    sent_at TIMESTAMP,
    failed_reason TEXT,

    -- Retry tracking
    retry_count INTEGER DEFAULT 0,
    next_retry_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_notifications_alert_id ON alert_notifications(alert_id);
CREATE INDEX idx_notifications_status ON alert_notifications(status);
CREATE INDEX idx_notifications_sent_at ON alert_notifications(sent_at DESC);
```

---

### 8. traffic_heatmap

Cached traffic data untuk analytics performance.

```sql
CREATE TABLE traffic_heatmap (
    id BIGSERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES stores(id),

    -- Time bucket
    date DATE NOT NULL,
    hour INTEGER NOT NULL,
    -- 0-23 (can aggregate by minute for more granularity)

    zone VARCHAR(100),
    -- Optional: if NULL, then store-wide aggregate

    -- Metrics
    visitor_count INTEGER DEFAULT 0,
    avg_dwell_time_seconds INTEGER,
    alerts_count INTEGER DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes (for fast analytics queries)
CREATE INDEX idx_heatmap_store_date ON traffic_heatmap(store_id, date DESC, hour);
CREATE INDEX idx_heatmap_zone ON traffic_heatmap(zone);
```

---

## Relationships Diagram

```
stores (1)
├─ cameras (N)
├─ users (N)
├─ visits (N)
│  ├─ shoplifting_alerts (N)
│  │  └─ alert_notifications (N)
│  └─ traffic_heatmap (derived from visits)
└─ audit_logs (N)

Foreign Keys:
- cameras.store_id → stores.id (CASCADE DELETE)
- users.store_id → stores.id (CASCADE DELETE)
- visits.store_id → stores.id
- visits.camera_id → cameras.id
- shoplifting_alerts.visit_id → visits.id
- shoplifting_alerts.camera_id → cameras.id
- alert_notifications.alert_id → shoplifting_alerts.id
- audit_logs.user_id → users.id
- traffic_heatmap.store_id → stores.id
```

---

## Key Queries

### Get Unresolved Alerts for Store
```sql
SELECT
    a.*,
    v.person_uid,
    c.name as camera_name
FROM shoplifting_alerts a
JOIN visits v ON a.visit_id = v.id
JOIN cameras c ON a.camera_id = c.id
WHERE v.store_id = $1
  AND a.status = 'unresolved'
ORDER BY a.timestamp DESC
LIMIT 50;
```

### Get Alert Statistics by Day
```sql
SELECT
    DATE(timestamp) as date,
    COUNT(*) as total_alerts,
    SUM(CASE WHEN status = 'resolved' THEN 1 ELSE 0 END) as resolved,
    AVG(confidence) as avg_confidence
FROM shoplifting_alerts
WHERE
    (SELECT store_id FROM visits WHERE visits.id = visit_id) = $1
    AND timestamp >= $2
    AND timestamp < $3
GROUP BY DATE(timestamp)
ORDER BY date DESC;
```

### Get Visitor Profile
```sql
SELECT
    person_uid,
    COUNT(*) as visit_count,
    MAX(entry_time) as last_visit,
    AVG(EXTRACT(EPOCH FROM (exit_time - entry_time))) / 60 as avg_dwell_minutes,
    COUNT(CASE WHEN (SELECT COUNT(*) FROM shoplifting_alerts
                     WHERE visit_id = visits.id) > 0 THEN 1 END) as alert_count
FROM visits
WHERE store_id = $1
GROUP BY person_uid
ORDER BY visit_count DESC;
```

### High-Risk Persons (Multiple Alerts)
```sql
SELECT
    v.person_uid,
    COUNT(DISTINCT a.id) as alert_count,
    AVG(a.confidence) as avg_confidence,
    MAX(a.timestamp) as latest_alert
FROM shoplifting_alerts a
JOIN visits v ON a.visit_id = v.id
WHERE v.store_id = $1
  AND a.timestamp >= NOW() - INTERVAL '30 days'
GROUP BY v.person_uid
HAVING COUNT(DISTINCT a.id) > 2
ORDER BY alert_count DESC;
```

---

## Migration Strategy

### Version 1.0.0 (Initial)

All tables created as above. Migrations managed by Alembic:

```bash
# Create migration
alembic revision --autogenerate -m "Initial schema"

# Apply migration
alembic upgrade head

# Rollback
alembic downgrade -1
```

---

## Backup & Recovery

### Backup Strategy

**Daily backup (PostgreSQL dump):**
```bash
pg_dump -U postgres vernon_analytics > /backups/vernon_$(date +%Y%m%d).sql
```

**Point-in-time recovery:**
```bash
# Using WAL (Write-Ahead Logs)
pg_wal_archive_recovery_target = '2026-03-17 10:00:00'
```

---

## Performance Optimization

### Partitioning (Future)

```sql
-- Partition alerts by month
CREATE TABLE shoplifting_alerts_2026_03 PARTITION OF shoplifting_alerts
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE TABLE shoplifting_alerts_2026_04 PARTITION OF shoplifting_alerts
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
```

### Archive Strategy

```sql
-- Move old data to archive table
CREATE TABLE shoplifting_alerts_archive AS
    SELECT * FROM shoplifting_alerts
    WHERE timestamp < NOW() - INTERVAL '90 days';

DELETE FROM shoplifting_alerts
WHERE timestamp < NOW() - INTERVAL '90 days';
```

---

## Data Types Reference

| PostgreSQL Type | Description | Example |
|-----------------|-------------|---------|
| SERIAL | Auto-incrementing integer | id SERIAL PRIMARY KEY |
| BIGSERIAL | Large auto-incrementing | audit log id |
| VARCHAR(n) | Variable-length string | names, emails |
| TEXT | Unbounded text | notes, descriptions |
| INTEGER | 32-bit integer | counts, ages |
| FLOAT | Floating point | confidence scores |
| BOOLEAN | True/False | flags |
| TIMESTAMP | Date + time | created_at |
| DATE | Date only | birth dates |
| JSONB | Binary JSON (indexed) | config, metadata |
| TEXT[] | Array of text | zones_visited, reasons |

---

**Last Updated:** 2026-03-17
**Version:** 1.0.0
