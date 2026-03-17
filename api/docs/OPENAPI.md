# OpenAPI / Swagger Documentation

**Date:** 2026-03-17
**Status:** Complete
**Auto-Generated at:** `/api/openapi.json`
**UI Endpoints:**
- Swagger UI: `/api/docs`
- ReDoc: `/api/redoc`

---

## Overview

Aplikasi Vernon Store Analytics menggunakan **FastAPI** dengan auto-generated OpenAPI 3.0.1 specification. Semua endpoint:
- ✅ Fully documented dengan descriptions
- ✅ Type-checked dengan Pydantic models
- ✅ Authenticated dengan JWT Bearer token (kecuali `/health` dan `/api/docs`)
- ✅ Organized in 9 logical tags (Authentication, Stores, Cameras, Alerts, Stream, Visitors, Traffic, Analytics, Statistics)

---

## API Base URL

```
http://localhost:8000/api/v1
```

### Health Check (No Auth Required)
```
GET /health
```

---

## Authentication

### Login Flow

**1. Get Access Token**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "admin@vernon.local",
  "password": "secure_password"
}

Response 200:
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

**2. Use Token in Headers**
```http
GET /api/v1/stores/1/alerts
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### Token Details
- **Type:** JWT (JSON Web Token)
- **Algorithm:** HS256
- **Expiration:** 1 hour (3600 seconds)
- **Header:** `Authorization: Bearer <token>`
- **Refresh:** Automatic via middleware if <5 min remaining

### Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer <token>

Response 200:
{
  "success": true,
  "message": "Logout successful"
}
```

---

## API Tags Organization

### 1. **Authentication** (3 endpoints)
- POST `/auth/login` — User login
- POST `/auth/logout` — User logout
- POST `/auth/refresh` — Refresh JWT token

### 2. **Stores** (4 endpoints)
- GET `/stores` — List all stores
- GET `/stores/{store_id}` — Get store details
- POST `/stores` — Create new store (Admin only)
- PUT `/stores/{store_id}` — Update store configuration

### 3. **Cameras** (5 endpoints)
- GET `/stores/{store_id}/cameras` — List store cameras
- GET `/cameras/{camera_id}` — Get camera details
- POST `/stores/{store_id}/cameras` — Add camera to store
- PUT `/cameras/{camera_id}` — Update camera config
- DELETE `/cameras/{camera_id}` — Remove camera

### 4. **Alerts** (4 endpoints)
- GET `/stores/{store_id}/alerts` — List alerts with filters
- GET `/alerts/{alert_id}` — Get alert detail
- PUT `/alerts/{alert_id}/resolve` — Resolve alert with note
- DELETE `/alerts/{alert_id}` — Delete alert record

### 5. **Stream** (3 endpoints)
- WebSocket `/ws/stream` — Real-time detection updates
- GET `/stream/stats` — Stream manager statistics
- POST `/stream/cameras/{camera_id}/start` — Start camera stream
- POST `/stream/cameras/{camera_id}/stop` — Stop camera stream

### 6. **Visitors** (3 endpoints)
- GET `/stores/{store_id}/visitors` — List tracked visitors
- GET `/visitors/{person_uid}` — Get visitor profile
- GET `/visitors/{person_uid}/history` — Get visit history

### 7. **Traffic** (3 endpoints)
- GET `/stores/{store_id}/traffic` — Traffic metrics (count, heatmap)
- GET `/stores/{store_id}/traffic/hourly` — Hourly traffic chart
- GET `/stores/{store_id}/traffic/zones` — Zone-wise traffic breakdown

### 8. **Analytics** (4 endpoints)
- GET `/analytics/shoplifting` — Shoplifting statistics & trends
- GET `/analytics/behavior` — Behavior pattern analysis
- GET `/analytics/export` — Export analytics to CSV/PDF
- POST `/analytics/reports/generate` — Generate custom report

### 9. **Statistics** (2 endpoints)
- GET `/statistics/dashboard` — Dashboard overview metrics
- GET `/statistics/summary` — Weekly/monthly summary

---

## Common Response Format

### Success Response (200, 201)
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Alert #1",
    "...": "..."
  },
  "message": "Operation successful"
}
```

### List Response (200) with Pagination
```json
{
  "success": true,
  "data": [
    { "id": 1, "...": "..." },
    { "id": 2, "...": "..." }
  ],
  "pagination": {
    "total": 42,
    "limit": 10,
    "offset": 0,
    "pages": 5,
    "current_page": 1
  }
}
```

### Error Response (4xx, 5xx)
```json
{
  "success": false,
  "error": "NotFoundException",
  "message": "Alert with ID 999 not found",
  "detail": "Alert ID tidak ada di database",
  "status_code": 404,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

## Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| **200** | OK | GET success, data found |
| **201** | Created | POST success, resource created |
| **204** | No Content | DELETE success |
| **400** | Bad Request | Invalid request format |
| **401** | Unauthorized | Missing/invalid token |
| **403** | Forbidden | Insufficient permissions |
| **404** | Not Found | Resource doesn't exist |
| **422** | Unprocessable Entity | Validation failed (Pydantic) |
| **429** | Too Many Requests | Rate limit exceeded |
| **500** | Internal Error | Server error (no detail to client) |
| **503** | Service Unavailable | Database/stream unavailable |

---

## Rate Limiting

**Limits (per user, per hour):**
- `/auth/login` — 10 attempts
- `/api/v1/*` — 1000 requests
- `/ws/stream` — Unlimited (WebSocket)

**Response Headers:**
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1679055600
```

---

## Pagination

### Query Parameters
- `limit` — Results per page (default: 50, max: 200)
- `offset` — Skip first N results (default: 0)

### Example
```http
GET /api/v1/stores/1/alerts?limit=10&offset=20

Response includes:
{
  "pagination": {
    "total": 500,
    "limit": 10,
    "offset": 20,
    "pages": 50,
    "current_page": 3
  }
}
```

---

## Filtering & Search

### Alert Filtering
```http
GET /api/v1/stores/1/alerts?
    resolved=false
    &confidence_min=0.75
    &confidence_max=1.0
    &camera_id=1
    &date_from=2026-03-01
    &date_to=2026-03-17
    &limit=50
```

### Visitor Search
```http
GET /api/v1/stores/1/visitors?
    person_uid=person_abc123
    &zone=floor
    &mood=nervous
    &date_from=2026-03-17
```

---

## Request/Response Examples

### 1. POST /api/v1/auth/login

**Request:**
```json
{
  "email": "manager@vernon.local",
  "password": "password123"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "email": "manager@vernon.local",
      "name": "Store Manager",
      "role": "manager",
      "store_id": 1
    }
  }
}
```

**Response 401:**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Invalid email or password",
  "status_code": 401
}
```

---

### 2. GET /api/v1/stores/{store_id}/alerts

**Request:**
```http
GET /api/v1/stores/1/alerts?resolved=false&limit=10
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "visit_id": 100,
      "camera_id": 1,
      "person_uid": "person_abc123",
      "confidence": 0.87,
      "timestamp": "2026-03-17T10:15:00Z",
      "status": "unresolved",
      "reasons": [
        "Dwell 15 menit tanpa kasir",
        "Mood nervous 60%"
      ],
      "resolved_at": null,
      "resolved_by": null,
      "resolved_note": null
    },
    {
      "id": 2,
      "visit_id": 101,
      "camera_id": 2,
      "person_uid": "person_xyz789",
      "confidence": 0.92,
      "timestamp": "2026-03-17T09:45:00Z",
      "status": "resolved",
      "reasons": [
        "Zone changes 4 kali",
        "Exit tanpa kasir"
      ],
      "resolved_at": "2026-03-17T10:00:00Z",
      "resolved_by": "admin",
      "resolved_note": "False alarm, customer just browsing"
    }
  ],
  "pagination": {
    "total": 23,
    "limit": 10,
    "offset": 0,
    "pages": 3,
    "current_page": 1
  }
}
```

---

### 3. PUT /api/v1/alerts/{alert_id}/resolve

**Request:**
```json
{
  "note": "Confirmed suspicious behavior, passed to security team"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "visit_id": 100,
    "status": "resolved",
    "resolved_at": "2026-03-17T10:30:00Z",
    "resolved_by": "manager_001",
    "resolved_note": "Confirmed suspicious behavior, passed to security team"
  },
  "message": "Alert resolved successfully"
}
```

**Response 404:**
```json
{
  "success": false,
  "error": "NotFoundException",
  "message": "Alert with ID 999 not found",
  "status_code": 404
}
```

---

### 4. WebSocket /ws/stream

**Connection:**
```javascript
const ws = new WebSocket("wss://api.vernon.local/ws/stream");
```

**Message: Detection Update**
```json
{
  "type": "detection_update",
  "camera_id": 1,
  "timestamp": "2026-03-17T10:00:00Z",
  "persons_count": 5,
  "detections": [
    {
      "person_uid": "person_abc123",
      "mood": "neutral",
      "mood_confidence": 0.92,
      "age_estimate": 35,
      "gender": "male",
      "zone": "floor",
      "dwell_time_seconds": 120
    }
  ]
}
```

**Message: Shoplifting Alert**
```json
{
  "type": "shoplifting_alert",
  "alert_id": 1,
  "camera_id": 1,
  "timestamp": "2026-03-17T10:05:00Z",
  "person_uid": "person_abc123",
  "visit_id": 100,
  "confidence": 0.87,
  "reasons": [
    "Dwell 15 menit tanpa kasir",
    "Mood nervous 60%"
  ]
}
```

---

### 5. GET /api/v1/analytics/shoplifting

**Request:**
```http
GET /api/v1/analytics/shoplifting?
    period=week
    &store_id=1
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "period": "week",
    "store_id": 1,
    "summary": {
      "total_alerts": 23,
      "resolved": 21,
      "unresolved": 2,
      "resolution_rate": 91.3,
      "avg_confidence": 0.81,
      "avg_resolution_time_hours": 2.5
    },
    "by_day": [
      {
        "date": "2026-03-11",
        "count": 2,
        "avg_confidence": 0.75
      },
      {
        "date": "2026-03-12",
        "count": 5,
        "avg_confidence": 0.84
      }
    ],
    "by_hour": [
      {
        "hour": 9,
        "count": 3,
        "avg_confidence": 0.79
      },
      {
        "hour": 10,
        "count": 8,
        "avg_confidence": 0.87
      }
    ],
    "top_reasons": [
      {
        "reason": "Dwell tanpa kasir",
        "count": 18,
        "percentage": 78.3
      },
      {
        "reason": "Zone changes",
        "count": 12,
        "percentage": 52.2
      }
    ],
    "by_camera": [
      {
        "camera_id": 1,
        "name": "Floor Zone",
        "count": 15,
        "avg_confidence": 0.83
      },
      {
        "camera_id": 2,
        "name": "Shelves Zone",
        "count": 8,
        "avg_confidence": 0.78
      }
    ]
  }
}
```

---

## Endpoint Documentation Template

Semua endpoint harus memiliki dokumentasi lengkap dalam kode:

```python
@router.get(
    "/alerts",
    tags=["Alerts"],
    summary="List shoplifting alerts",
    description="Daftar alerts shoplifting dengan filter dan paginasi",
    response_model=AlertListResponse,
    status_code=200,
)
async def list_alerts(
    store_id: int = Query(..., description="Store ID untuk filter alerts"),
    resolved: bool | None = Query(None, description="Filter by status (true/false/null)"),
    limit: int = Query(50, ge=1, le=200, description="Jumlah alerts per page"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    current_user: User = Depends(get_current_user),
) -> AlertListResponse:
    """
    **List Alerts dengan Filter**

    - **store_id**: ID toko untuk filter (required)
    - **resolved**: true/false untuk filter status, null untuk semua
    - **limit**: Max 200 results per request
    - **offset**: Pagination offset

    **Response:**
    - data: Array of alerts
    - pagination: Pagination metadata

    **Status Codes:**
    - 200: Success
    - 401: Unauthorized
    - 404: Store not found
    - 422: Invalid parameters
    """
```

---

## Auto-Generated Schema

OpenAPI schema otomatis di-generate dari Pydantic models.

**Example Alert Model:**
```python
class AlertResponse(BaseModel):
    id: int = Field(..., description="Alert ID")
    visit_id: int = Field(..., description="Foreign key to visits")
    camera_id: int = Field(..., description="Foreign key to cameras")
    person_uid: str = Field(..., description="Unique person identifier")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence 0.0-1.0")
    timestamp: datetime = Field(..., description="When alert was triggered")
    status: AlertStatus = Field(..., description="unresolved, resolved, dismissed")
    reasons: list[str] = Field(..., description="List of detected reasons")
    resolved_at: datetime | None = Field(None, description="When resolved")
    resolved_by: str | None = Field(None, description="Username who resolved")
    resolved_note: str | None = Field(None, description="Staff notes")

    model_config = ConfigDict(from_attributes=True)
```

---

## CORS Configuration

**Allowed Origins:**
- Development: `http://localhost:3000`, `http://localhost:5173`
- Production: Configured via `CORS_ORIGINS` env var

**Allowed Methods:** GET, POST, PUT, DELETE, OPTIONS
**Allowed Headers:** Content-Type, Authorization
**Credentials:** Enabled (cookies for JWT)

---

## Logging & Debugging

### Request Logging (Middleware)
Semua request/response di-log dengan structlog:
```
timestamp=2026-03-17T10:00:00Z method=GET path=/api/v1/alerts status=200 duration_ms=45 user_id=1
```

### Debug Mode (Development Only)
```python
# Enable in development:
# FASTAPI_DEBUG=1
```

---

## Security Headers

```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

---

## CORS & CSRF Protection

- CORS middleware enabled for frontend integration
- CSRF token required for state-changing operations (POST, PUT, DELETE)
- JWT tokens validated on every request (except public endpoints)

---

## Swagger UI Tips

**In `/api/docs`:**
1. Click "Authorize" button → enter token
2. All endpoints marked with lock icon require auth
3. Click endpoint → "Try it out" → enter parameters → "Execute"
4. Response shows status code, headers, body

---

## Further Reading

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [OpenAPI Specification](https://spec.openapis.org/)
- [JWT Authentication](https://fastapi.tiangolo.com/advanced/security/oauth2-jwt/)
- Project Backend: `/src/vernon_store_analytics/api/v1/`

---

**Last Updated:** 2026-03-17
**Version:** 1.0.0
