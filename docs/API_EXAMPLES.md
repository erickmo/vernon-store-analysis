# API Examples — Request & Response Reference

**Date:** 2026-03-17
**Status:** Complete
**Last Updated:** 2026-03-17

---

## Authentication Examples

### 1. Login

**Endpoint:** `POST /api/v1/auth/login`

**Request:**
```http
POST /api/v1/auth/login HTTP/1.1
Host: api.vernon.local
Content-Type: application/json
Content-Length: 62

{
  "email": "manager@vernon.local",
  "password": "secure_password_123"
}
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtYW5hZ2VyQHZlcm5vbi5sb2NhbCIsImlhdCI6MTY3OTA1MDAwMCwiZXhwIjoxNjc5MDUzNjAwfQ.1234567890abcdef",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "email": "manager@vernon.local",
      "name": "Store Manager",
      "role": "manager",
      "store_id": 1
    }
  },
  "message": "Login successful"
}
```

**Response 401 Unauthorized:**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Invalid email or password",
  "status_code": 401,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

### 2. Logout

**Endpoint:** `POST /api/v1/auth/logout`

**Request:**
```http
POST /api/v1/auth/logout HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

## Alerts API Examples

### 3. List Alerts (with Filters)

**Endpoint:** `GET /api/v1/stores/{store_id}/alerts`

**Request (with filters):**
```http
GET /api/v1/stores/1/alerts?resolved=false&confidence_min=0.75&limit=10&offset=0 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "visit_id": 100,
      "camera_id": 1,
      "person_uid": "person_abc123def456",
      "confidence": 0.87,
      "timestamp": "2026-03-17T10:15:00Z",
      "status": "unresolved",
      "reasons": [
        "Dwell 15 menit tanpa ke kasir",
        "Mood nervous 60%",
        "Zone changes 3 kali"
      ],
      "resolved_at": null,
      "resolved_by": null,
      "resolved_note": null
    },
    {
      "id": 2,
      "visit_id": 101,
      "camera_id": 2,
      "person_uid": "person_xyz789pqr",
      "confidence": 0.92,
      "timestamp": "2026-03-17T09:45:00Z",
      "status": "unresolved",
      "reasons": [
        "Exit tanpa kasir >5 min after entry",
        "Floor lingering 75% of time"
      ],
      "resolved_at": null,
      "resolved_by": null,
      "resolved_note": null
    }
  ],
  "pagination": {
    "total": 23,
    "limit": 10,
    "offset": 0,
    "pages": 3,
    "current_page": 1
  },
  "message": "Alerts retrieved successfully"
}
```

**Request (no results):**
```http
GET /api/v1/stores/1/alerts?resolved=false&confidence_min=0.99&limit=10 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK (Empty):**
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "total": 0,
    "limit": 10,
    "offset": 0,
    "pages": 0,
    "current_page": 1
  },
  "message": "No alerts found"
}
```

---

### 4. Get Alert Detail

**Endpoint:** `GET /api/v1/alerts/{alert_id}`

**Request:**
```http
GET /api/v1/alerts/1 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "visit_id": 100,
    "camera_id": 1,
    "camera_name": "Floor Zone Camera",
    "person_uid": "person_abc123def456",
    "confidence": 0.87,
    "timestamp": "2026-03-17T10:15:00Z",
    "status": "unresolved",
    "reasons": [
      "Dwell 15 menit tanpa ke kasir",
      "Mood nervous 60%",
      "Zone changes 3 kali"
    ],
    "behavior_profile": {
      "dwell_time_seconds": 915,
      "zones_visited": ["floor", "shelf_a", "shelf_b"],
      "mood_distribution": {
        "neutral": 0.3,
        "nervous": 0.6,
        "happy": 0.1
      },
      "age_estimate": 38,
      "gender": "male"
    },
    "resolved_at": null,
    "resolved_by": null,
    "resolved_note": null
  },
  "message": "Alert details retrieved"
}
```

**Response 404 Not Found:**
```json
{
  "success": false,
  "error": "NotFoundException",
  "message": "Alert with ID 999 not found",
  "detail": "Alert tidak ada di database",
  "status_code": 404,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

### 5. Resolve Alert

**Endpoint:** `PUT /api/v1/alerts/{alert_id}/resolve`

**Request:**
```http
PUT /api/v1/alerts/1/resolve HTTP/1.1
Host: api.vernon.local
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Length: 95

{
  "note": "Customer was browsing shelves, nervous because first time di store ini. False alarm."
}
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "visit_id": 100,
    "status": "resolved",
    "resolved_at": "2026-03-17T10:30:00Z",
    "resolved_by": "manager_001",
    "resolved_note": "Customer was browsing shelves, nervous because first time di store ini. False alarm."
  },
  "message": "Alert resolved successfully"
}
```

**Response 400 Bad Request (Already Resolved):**
```json
{
  "success": false,
  "error": "ValidationException",
  "message": "Alert sudah di-resolve pada 2026-03-17T10:20:00Z oleh admin",
  "detail": "Cannot resolve an already resolved alert",
  "status_code": 400,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

## Visitors API Examples

### 6. List Visitors

**Endpoint:** `GET /api/v1/stores/{store_id}/visitors`

**Request:**
```http
GET /api/v1/stores/1/visitors?limit=20&offset=0 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": [
    {
      "person_uid": "person_abc123def456",
      "visits_count": 5,
      "last_visit": "2026-03-17T10:15:00Z",
      "avg_dwell_time_minutes": 12.3,
      "total_suspicious_alerts": 1,
      "profile": {
        "age_estimate": 38,
        "gender": "male",
        "typical_mood": "neutral",
        "favorite_zones": ["floor", "shelf_a"]
      }
    },
    {
      "person_uid": "person_xyz789pqr",
      "visits_count": 2,
      "last_visit": "2026-03-17T09:45:00Z",
      "avg_dwell_time_minutes": 8.5,
      "total_suspicious_alerts": 0,
      "profile": {
        "age_estimate": 25,
        "gender": "female",
        "typical_mood": "happy",
        "favorite_zones": ["entrance", "checkout"]
      }
    }
  ],
  "pagination": {
    "total": 156,
    "limit": 20,
    "offset": 0,
    "pages": 8,
    "current_page": 1
  }
}
```

---

### 7. Get Visitor Detail

**Endpoint:** `GET /api/v1/visitors/{person_uid}`

**Request:**
```http
GET /api/v1/visitors/person_abc123def456 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "person_uid": "person_abc123def456",
    "visits": [
      {
        "visit_id": 100,
        "date": "2026-03-17",
        "entry_time": "2026-03-17T10:00:00Z",
        "exit_time": "2026-03-17T10:30:00Z",
        "dwell_time_minutes": 30,
        "zones_visited": ["entrance", "floor", "shelf_a", "shelf_b", "checkout"],
        "mood_distribution": {
          "neutral": 0.5,
          "nervous": 0.3,
          "happy": 0.2
        },
        "alerts": [
          {
            "alert_id": 1,
            "confidence": 0.87,
            "reasons": ["Dwell 15 menit", "Mood nervous 60%"]
          }
        ]
      },
      {
        "visit_id": 95,
        "date": "2026-03-16",
        "entry_time": "2026-03-16T14:30:00Z",
        "exit_time": "2026-03-16T14:45:00Z",
        "dwell_time_minutes": 15,
        "zones_visited": ["entrance", "checkout"],
        "mood_distribution": {
          "neutral": 0.8,
          "happy": 0.2
        },
        "alerts": []
      }
    ],
    "profile_summary": {
      "total_visits": 5,
      "avg_dwell_time_minutes": 12.3,
      "favorite_zones": ["floor", "shelf_a"],
      "total_alerts": 1,
      "danger_score": 0.15
    }
  }
}
```

---

## Traffic API Examples

### 8. Get Traffic Metrics

**Endpoint:** `GET /api/v1/stores/{store_id}/traffic`

**Request:**
```http
GET /api/v1/stores/1/traffic?date=2026-03-17 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "date": "2026-03-17",
    "store_id": 1,
    "summary": {
      "total_visitors": 342,
      "avg_dwell_time_minutes": 11.2,
      "peak_hours": [10, 11, 17, 18],
      "alerts_today": 12,
      "alert_rate": 3.5
    },
    "by_hour": [
      {
        "hour": 9,
        "visitor_count": 15,
        "avg_dwell_minutes": 8.5,
        "alerts": 0
      },
      {
        "hour": 10,
        "visitor_count": 52,
        "avg_dwell_minutes": 12.3,
        "alerts": 3
      },
      {
        "hour": 11,
        "visitor_count": 48,
        "avg_dwell_minutes": 11.8,
        "alerts": 2
      }
    ],
    "by_zone": [
      {
        "zone": "entrance",
        "visitor_count": 342,
        "avg_dwell_minutes": 1.2
      },
      {
        "zone": "floor",
        "visitor_count": 298,
        "avg_dwell_minutes": 8.5
      },
      {
        "zone": "shelf_a",
        "visitor_count": 256,
        "avg_dwell_minutes": 6.3
      },
      {
        "zone": "checkout",
        "visitor_count": 198,
        "avg_dwell_minutes": 3.1
      }
    ]
  }
}
```

---

## Analytics API Examples

### 9. Get Shoplifting Analytics

**Endpoint:** `GET /api/v1/analytics/shoplifting`

**Request:**
```http
GET /api/v1/analytics/shoplifting?period=week&store_id=1 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "period": "week",
    "date_range": {
      "from": "2026-03-11",
      "to": "2026-03-17"
    },
    "summary": {
      "total_alerts": 45,
      "resolved": 42,
      "unresolved": 3,
      "resolution_rate": 93.3,
      "avg_confidence": 0.81,
      "avg_resolution_time_hours": 2.5,
      "total_visitors": 2341,
      "alert_rate_percentage": 1.92
    },
    "by_day": [
      {
        "date": "2026-03-11",
        "day_name": "Wednesday",
        "alerts": 4,
        "resolved": 4,
        "avg_confidence": 0.76,
        "visitors": 312
      },
      {
        "date": "2026-03-12",
        "day_name": "Thursday",
        "alerts": 8,
        "resolved": 8,
        "avg_confidence": 0.84,
        "visitors": 356
      },
      {
        "date": "2026-03-13",
        "day_name": "Friday",
        "alerts": 12,
        "resolved": 11,
        "avg_confidence": 0.86,
        "visitors": 421
      },
      {
        "date": "2026-03-14",
        "day_name": "Saturday",
        "alerts": 11,
        "resolved": 10,
        "avg_confidence": 0.83,
        "visitors": 412
      },
      {
        "date": "2026-03-15",
        "day_name": "Sunday",
        "alerts": 6,
        "resolved": 5,
        "avg_confidence": 0.79,
        "visitors": 289
      },
      {
        "date": "2026-03-16",
        "day_name": "Monday",
        "alerts": 2,
        "resolved": 2,
        "avg_confidence": 0.77,
        "visitors": 234
      },
      {
        "date": "2026-03-17",
        "day_name": "Tuesday",
        "alerts": 2,
        "resolved": 2,
        "avg_confidence": 0.82,
        "visitors": 317
      }
    ],
    "by_hour": [
      {
        "hour": 9,
        "alerts": 1,
        "avg_confidence": 0.78
      },
      {
        "hour": 10,
        "alerts": 8,
        "avg_confidence": 0.85
      },
      {
        "hour": 11,
        "alerts": 7,
        "avg_confidence": 0.83
      },
      {
        "hour": 14,
        "alerts": 12,
        "avg_confidence": 0.87
      },
      {
        "hour": 17,
        "alerts": 10,
        "avg_confidence": 0.80
      },
      {
        "hour": 18,
        "alerts": 5,
        "avg_confidence": 0.76
      }
    ],
    "top_behaviors": [
      {
        "reason": "Dwell tanpa kasir",
        "count": 38,
        "percentage": 84.4,
        "avg_confidence": 0.82
      },
      {
        "reason": "Zone changes berulang",
        "count": 28,
        "percentage": 62.2,
        "avg_confidence": 0.79
      },
      {
        "reason": "Mood nervous",
        "count": 18,
        "percentage": 40.0,
        "avg_confidence": 0.75
      },
      {
        "reason": "Floor lingering",
        "count": 15,
        "percentage": 33.3,
        "avg_confidence": 0.77
      },
      {
        "reason": "Exit tanpa kasir",
        "count": 12,
        "percentage": 26.7,
        "avg_confidence": 0.84
      }
    ],
    "by_camera": [
      {
        "camera_id": 1,
        "name": "Floor Zone",
        "alerts": 28,
        "avg_confidence": 0.82,
        "resolution_rate": 92.9
      },
      {
        "camera_id": 2,
        "name": "Shelves Zone",
        "alerts": 12,
        "avg_confidence": 0.79,
        "resolution_rate": 91.7
      },
      {
        "camera_id": 3,
        "name": "Checkout Zone",
        "alerts": 5,
        "avg_confidence": 0.80,
        "resolution_rate": 100.0
      }
    ]
  }
}
```

---

## Camera API Examples

### 10. List Cameras

**Endpoint:** `GET /api/v1/stores/{store_id}/cameras`

**Request:**
```http
GET /api/v1/stores/1/cameras HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Floor Zone Camera",
      "location": "Floor area, near shelves",
      "zone": "floor",
      "stream_url": "rtsp://192.168.1.100:554/stream1",
      "status": "active",
      "stream_status": "connected",
      "fps": 25,
      "resolution": "1920x1080",
      "active_persons": 3,
      "last_frame_timestamp": "2026-03-17T10:15:23Z"
    },
    {
      "id": 2,
      "name": "Shelves Zone Camera",
      "location": "Product shelves area",
      "zone": "shelf",
      "stream_url": "rtsp://192.168.1.100:554/stream2",
      "status": "active",
      "stream_status": "connected",
      "fps": 25,
      "resolution": "1920x1080",
      "active_persons": 2,
      "last_frame_timestamp": "2026-03-17T10:15:21Z"
    },
    {
      "id": 3,
      "name": "Checkout Zone Camera",
      "location": "Near payment counter",
      "zone": "checkout",
      "stream_url": "rtsp://192.168.1.100:554/stream3",
      "status": "inactive",
      "stream_status": "disconnected",
      "fps": 0,
      "resolution": "1920x1080",
      "active_persons": 0,
      "last_frame_timestamp": "2026-03-17T10:05:00Z"
    }
  ],
  "pagination": {
    "total": 3,
    "limit": 50,
    "offset": 0,
    "pages": 1,
    "current_page": 1
  }
}
```

---

### 11. Get Camera Detail

**Endpoint:** `GET /api/v1/cameras/{camera_id}`

**Request:**
```http
GET /api/v1/cameras/1 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "store_id": 1,
    "name": "Floor Zone Camera",
    "location": "Floor area, near shelves",
    "zone": "floor",
    "stream_url": "rtsp://192.168.1.100:554/stream1",
    "status": "active",
    "stream_status": "connected",
    "fps": 25,
    "resolution": "1920x1080",
    "active_persons": 3,
    "last_frame_timestamp": "2026-03-17T10:15:23Z",
    "statistics": {
      "total_detections_today": 156,
      "avg_persons_per_hour": 12.5,
      "total_alerts_today": 8,
      "uptime_percentage": 99.8,
      "last_restart": "2026-03-17T00:15:00Z"
    }
  }
}
```

---

## Stream/WebSocket Examples

### 12. WebSocket Connection

**Endpoint:** `WebSocket /ws/stream`

**Connect:**
```javascript
const ws = new WebSocket("wss://api.vernon.local/ws/stream");

ws.onopen = () => {
  console.log("Connected to stream");
};

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  // Handle different message types
  if (message.type === "detection_update") {
    // Update UI with detections
  } else if (message.type === "shoplifting_alert") {
    // Show alert notification
  }
};

ws.onerror = (error) => {
  console.error("WebSocket error:", error);
};

ws.onclose = () => {
  console.log("Connection closed, reconnecting...");
  // Auto-reconnect logic
};
```

**Message 1: Detection Update (periodic, ~1-2 per second)**
```json
{
  "type": "detection_update",
  "camera_id": 1,
  "timestamp": "2026-03-17T10:15:42.123Z",
  "persons_count": 3,
  "detections": [
    {
      "person_uid": "person_abc123def456",
      "mood": "neutral",
      "mood_confidence": 0.92,
      "age_estimate": 38,
      "gender": "male",
      "zone": "floor",
      "dwell_time_seconds": 120,
      "behavior_score": 0.42
    },
    {
      "person_uid": "person_xyz789pqr",
      "mood": "happy",
      "mood_confidence": 0.88,
      "age_estimate": 25,
      "gender": "female",
      "zone": "shelf_a",
      "dwell_time_seconds": 45,
      "behavior_score": 0.12
    }
  ]
}
```

**Message 2: Shoplifting Alert (when threshold exceeded)**
```json
{
  "type": "shoplifting_alert",
  "alert_id": 1,
  "camera_id": 1,
  "timestamp": "2026-03-17T10:15:00Z",
  "person_uid": "person_abc123def456",
  "visit_id": 100,
  "confidence": 0.87,
  "reasons": [
    "Dwell 15 menit tanpa ke kasir",
    "Mood nervous 60%",
    "Zone changes 3 kali"
  ],
  "action_required": true
}
```

**Message 3: Stream Status**
```json
{
  "type": "stream_status",
  "timestamp": "2026-03-17T10:15:00Z",
  "camera_id": 3,
  "status": "disconnected",
  "reason": "Network error",
  "last_seen": "2026-03-17T10:05:00Z"
}
```

---

## Statistics API Examples

### 13. Get Dashboard Statistics

**Endpoint:** `GET /api/v1/statistics/dashboard`

**Request:**
```http
GET /api/v1/statistics/dashboard?store_id=1 HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response 200 OK:**
```json
{
  "success": true,
  "data": {
    "active_alerts": 3,
    "total_alerts_this_week": 45,
    "resolution_rate": 93.3,
    "avg_confidence": 0.81,
    "active_persons_tracked": 12,
    "stream_status": "online",
    "cameras_active": 2,
    "cameras_total": 3,
    "visitors_today": 142,
    "peak_hour": 14,
    "suspicious_persons": 5
  }
}
```

---

## Error Response Examples

### 401 Unauthorized (Missing Token)

**Request:**
```http
GET /api/v1/stores/1/alerts HTTP/1.1
Host: api.vernon.local
```

**Response 401:**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Missing authorization header",
  "detail": "Authorization header tidak ditemukan",
  "status_code": 401,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

### 403 Forbidden (Insufficient Permissions)

**Request:**
```http
PUT /api/v1/stores/2/update HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs... (manager token, hanya untuk store 1)
Content-Type: application/json

{ "name": "Updated Store" }
```

**Response 403:**
```json
{
  "success": false,
  "error": "ForbiddenException",
  "message": "You don't have permission to access store 2",
  "detail": "Manager dapat hanya mengakses store yang di-assign",
  "status_code": 403,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

### 422 Unprocessable Entity (Validation Error)

**Request:**
```http
POST /api/v1/alerts/1/resolve HTTP/1.1
Host: api.vernon.local
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
Content-Type: application/json

{
  "note": 123
}
```

**Response 422:**
```json
{
  "success": false,
  "error": "ValidationException",
  "message": "Validation error",
  "detail": {
    "field": "note",
    "type": "string_type",
    "message": "Input should be a valid string"
  },
  "status_code": 422,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

### 429 Too Many Requests (Rate Limited)

**Response 429:**
```json
{
  "success": false,
  "error": "RateLimitException",
  "message": "Too many requests",
  "detail": "Anda sudah mencapai batas 10 login attempts per jam",
  "status_code": 429,
  "timestamp": "2026-03-17T10:00:00Z",
  "retry_after_seconds": 3600
}
```

---

### 500 Internal Server Error

**Response 500:**
```json
{
  "success": false,
  "error": "InternalServerException",
  "message": "Internal server error",
  "detail": "Terjadi kesalahan pada server. Silakan hubungi administrator.",
  "status_code": 500,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

---

## cURL Examples

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"manager@vernon.local","password":"password123"}'
```

### List Alerts
```bash
curl -X GET "http://localhost:8000/api/v1/stores/1/alerts?resolved=false&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Resolve Alert
```bash
curl -X PUT http://localhost:8000/api/v1/alerts/1/resolve \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"note":"False alarm, customer was browsing"}'
```

### Get Analytics
```bash
curl -X GET "http://localhost:8000/api/v1/analytics/shoplifting?period=week&store_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## JavaScript/Fetch Examples

### Login
```javascript
const response = await fetch("http://localhost:8000/api/v1/auth/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: "manager@vernon.local",
    password: "password123"
  })
});

const data = await response.json();
const token = data.data.access_token;
localStorage.setItem("access_token", token);
```

### List Alerts
```javascript
const token = localStorage.getItem("access_token");
const response = await fetch(
  "http://localhost:8000/api/v1/stores/1/alerts?resolved=false&limit=10",
  {
    method: "GET",
    headers: { "Authorization": `Bearer ${token}` }
  }
);

const { data, pagination } = await response.json();
console.log(data, pagination);
```

### WebSocket Connection
```javascript
const ws = new WebSocket("wss://api.vernon.local/ws/stream");

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);

  if (message.type === "shoplifting_alert") {
    console.log("🚨 Alert:", message.alert_id, message.confidence);
    showNotification(message);
  } else if (message.type === "detection_update") {
    updatePersonsList(message.detections);
  }
};
```

---

## Python Examples

### Login
```python
import requests

response = requests.post(
    "http://localhost:8000/api/v1/auth/login",
    json={
        "email": "manager@vernon.local",
        "password": "password123"
    }
)

data = response.json()
token = data["data"]["access_token"]
```

### List Alerts
```python
headers = {"Authorization": f"Bearer {token}"}
response = requests.get(
    "http://localhost:8000/api/v1/stores/1/alerts",
    params={"resolved": False, "limit": 10},
    headers=headers
)

alerts = response.json()["data"]
for alert in alerts:
    print(f"Alert {alert['id']}: {alert['confidence']}")
```

### WebSocket
```python
import websockets
import json
import asyncio

async def connect():
    async with websockets.connect("wss://api.vernon.local/ws/stream") as ws:
        async for message in ws:
            data = json.loads(message)
            if data["type"] == "shoplifting_alert":
                print(f"🚨 Alert: {data['alert_id']}")
            elif data["type"] == "detection_update":
                print(f"👤 Detections: {data['persons_count']}")

asyncio.run(connect())
```

---

**Last Updated:** 2026-03-17
**Version:** 1.0.0
