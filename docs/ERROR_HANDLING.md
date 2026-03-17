# Error Handling & Troubleshooting Guide

**Date:** 2026-03-17
**Status:** Complete
**Version:** 1.0.0

---

## Error Response Format

Semua error dari API mengikuti format yang konsisten:

```json
{
  "success": false,
  "error": "ExceptionClassName",
  "message": "Human-readable error message",
  "detail": "Additional technical details or validation errors",
  "status_code": 400,
  "timestamp": "2026-03-17T10:00:00Z"
}
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | Always `false` for errors |
| error | string | Exception class name (see list below) |
| message | string | User-friendly error message |
| detail | string/object | Technical details or validation errors |
| status_code | integer | HTTP status code |
| timestamp | string | ISO 8601 timestamp when error occurred |

---

## HTTP Status Codes

### Client Errors (4xx)

#### 400 Bad Request
**Meaning:** Request malformed or invalid parameters
**Possible Causes:**
- Missing required fields
- Invalid JSON syntax
- Incorrect field types
- Invalid enum values

**Example:**
```json
{
  "success": false,
  "error": "BadRequestException",
  "message": "Invalid request format",
  "detail": "Field 'confidence' must be between 0.0 and 1.0",
  "status_code": 400
}
```

**Fix:**
- Check request body syntax
- Validate all required fields are provided
- Ensure field types match specification

---

#### 401 Unauthorized
**Meaning:** Authentication failed or token missing/invalid
**Possible Causes:**
- Missing Authorization header
- Token expired
- Token signature invalid
- Invalid credentials

**Example (Missing Token):**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Missing authorization header",
  "detail": "Authorization header tidak ditemukan",
  "status_code": 401
}
```

**Example (Expired Token):**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Token has expired",
  "detail": "Token expired pada 2026-03-17T11:00:00Z",
  "status_code": 401
}
```

**Fix:**
- Add Authorization header: `Authorization: Bearer <token>`
- Get new token via `/api/v1/auth/login`
- Implement token refresh logic (auto-refresh if <5 min left)

---

#### 403 Forbidden
**Meaning:** Authenticated but insufficient permissions
**Possible Causes:**
- User role doesn't allow action
- User can't access other store's data
- Feature not available for user role

**Example:**
```json
{
  "success": false,
  "error": "ForbiddenException",
  "message": "You don't have permission to access store 2",
  "detail": "Manager role hanya dapat akses store yang di-assign",
  "status_code": 403
}
```

**Fix:**
- Check user role and permissions
- Request admin to grant access if needed
- Ensure accessing correct store_id for logged-in user

---

#### 404 Not Found
**Meaning:** Resource doesn't exist
**Possible Causes:**
- Wrong ID provided
- Resource was deleted
- Store/camera doesn't exist

**Example:**
```json
{
  "success": false,
  "error": "NotFoundException",
  "message": "Alert with ID 999 not found",
  "detail": "Alert ID 999 tidak ada di database",
  "status_code": 404
}
```

**Fix:**
- Verify resource ID is correct
- Check resource hasn't been deleted
- List resources to find correct ID

---

#### 422 Unprocessable Entity
**Meaning:** Validation error (Pydantic validation)
**Possible Causes:**
- Invalid field type
- Field value out of range
- Invalid enum value
- Missing required nested field

**Example (Type Error):**
```json
{
  "success": false,
  "error": "ValidationException",
  "message": "Validation error",
  "detail": {
    "field": "confidence",
    "type": "float_parsing",
    "message": "Input should be a valid number"
  },
  "status_code": 422
}
```

**Example (Range Error):**
```json
{
  "success": false,
  "error": "ValidationException",
  "message": "Validation error",
  "detail": {
    "field": "limit",
    "constraint": "le=200",
    "message": "ensure this value is less than or equal to 200"
  },
  "status_code": 422
}
```

**Fix:**
- Check error detail for field and constraint
- Validate types: int, float, string, boolean, array, object
- Check ranges: min/max values
- Check enums: only allowed values

---

#### 429 Too Many Requests
**Meaning:** Rate limit exceeded
**Possible Causes:**
- Too many login attempts (10/hour limit)
- Too many API requests (1000/hour limit)
- WebSocket reconnection spam

**Example:**
```json
{
  "success": false,
  "error": "RateLimitException",
  "message": "Too many requests",
  "detail": "Anda sudah mencapai batas 10 login attempts per jam",
  "status_code": 429,
  "headers": {
    "X-RateLimit-Limit": "10",
    "X-RateLimit-Remaining": "0",
    "X-RateLimit-Reset": "1679055600"
  }
}
```

**Fix:**
- Wait before retrying (check `X-RateLimit-Reset` header)
- Implement exponential backoff (wait 1s, 2s, 4s, etc.)
- Don't spam login/reconnect attempts

---

### Server Errors (5xx)

#### 500 Internal Server Error
**Meaning:** Unhandled exception on server
**Possible Causes:**
- Bug in backend code
- Database connection error
- Unexpected data format
- Missing environment variable

**Example:**
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

**Fix:**
- Check server logs for actual error
- Report to backend team with timestamp
- Retry after server is fixed
- Implement client-side retry logic with delay

---

#### 503 Service Unavailable
**Meaning:** Server temporarily unavailable
**Possible Causes:**
- Database down
- Stream manager crashed
- Server restarting
- High load

**Example:**
```json
{
  "success": false,
  "error": "ServiceUnavailableException",
  "message": "Service temporarily unavailable",
  "detail": "Database connection failed",
  "status_code": 503,
  "retry_after_seconds": 30
}
```

**Fix:**
- Wait and retry (check `Retry-After` header)
- Implement circuit breaker pattern
- Show "offline" message to user
- Queue requests and retry when service recovers

---

## Custom Exception Classes

Backend defines these custom exceptions:

### NotFoundException
Raised when resource doesn't exist.

**Status:** 404
**Message:** "Alert/Store/Camera/User not found"
**When to expect:**
- Accessing deleted resource
- Wrong resource ID
- Resource in different store

**Client handling:**
```javascript
if (error.error === "NotFoundException") {
  // Redirect to list view
  // Show "Resource not found" message
}
```

---

### ValidationException
Raised when input validation fails.

**Status:** 422
**Message:** "Validation error" with field details
**When to expect:**
- Invalid field type
- Value out of range
- Invalid enum value
- Required field missing

**Client handling:**
```javascript
if (error.error === "ValidationException") {
  // Extract field and constraint from detail
  // Show field-level error message
  // Highlight invalid field
}
```

---

### UnauthorizedException
Raised when authentication fails.

**Status:** 401
**Message:** "Invalid credentials" or "Token expired"
**When to expect:**
- Wrong password
- Missing token
- Expired token
- Invalid signature

**Client handling:**
```javascript
if (error.status_code === 401) {
  // Redirect to login
  // Clear stored token
  // Force re-authentication
}
```

---

### ForbiddenException
Raised when user lacks permission.

**Status:** 403
**Message:** "You don't have permission to..."
**When to expect:**
- User role insufficient
- Can't access other user's data
- Can't access other store's data

**Client handling:**
```javascript
if (error.error === "ForbiddenException") {
  // Show "Access denied" message
  // Hide menu items user can't access
  // Request admin to grant access
}
```

---

### RateLimitException
Raised when rate limit exceeded.

**Status:** 429
**Message:** "Too many requests"
**When to expect:**
- Too many login attempts
- Too many API calls
- WebSocket reconnection spam

**Client handling:**
```javascript
if (error.status_code === 429) {
  const resetTime = parseInt(error.headers['X-RateLimit-Reset']);
  const waitSeconds = resetTime - Math.floor(Date.now() / 1000);
  // Show countdown: "Try again in X seconds"
  // Implement exponential backoff
}
```

---

## API Error Handling Best Practices

### 1. Authentication Errors

```javascript
// Check if error is 401/Unauthorized
if (response.status === 401) {
  // 1. Clear stored credentials
  localStorage.removeItem('access_token');

  // 2. Redirect to login
  window.location.href = '/login';

  // 3. Show message
  toast.error('Session expired. Please login again.');

  // Don't retry (new token needed)
  return;
}
```

### 2. Validation Errors (422)

```javascript
if (error.status_code === 422) {
  const { field, message, constraint } = error.detail;

  // Show field-level error
  setFormErrors({
    [field]: `${message} (${constraint})`
  });

  // Highlight invalid input
  document.querySelector(`[name="${field}"]`)?.classList.add('error');
}
```

### 3. Server Errors (5xx)

```javascript
if (response.status >= 500) {
  // 1. Don't retry immediately (server is broken)
  // 2. Show error message with timestamp
  toast.error('Server error. Our team is investigating.');

  // 3. Implement exponential backoff retry
  const retryWithBackoff = async (url, options, attempt = 0) => {
    try {
      return await fetch(url, options);
    } catch (err) {
      if (attempt < 3) {
        const delay = 1000 * Math.pow(2, attempt); // 1s, 2s, 4s
        await new Promise(r => setTimeout(r, delay));
        return retryWithBackoff(url, options, attempt + 1);
      }
      throw err;
    }
  };
}
```

### 4. Rate Limiting (429)

```javascript
if (response.status === 429) {
  const resetTime = parseInt(response.headers.get('X-RateLimit-Reset'));
  const waitMs = (resetTime * 1000) - Date.now();

  // Show countdown
  toast.warning(`Rate limited. Try again in ${Math.ceil(waitMs / 1000)}s`);

  // Queue request and retry
  setTimeout(() => {
    fetch(url, options);
  }, waitMs);
}
```

### 5. Network Errors

```javascript
try {
  const response = await fetch(url, options);
} catch (error) {
  if (error.name === 'TypeError') {
    // Network error (CORS, offline, etc.)
    toast.error('Network error. Check your connection.');
  }

  // Implement retry
  setTimeout(() => retry(), 2000);
}
```

---

## WebSocket Error Handling

### Connection Errors

```javascript
const ws = new WebSocket("wss://api.vernon.local/ws/stream");

ws.onerror = (error) => {
  console.error("WebSocket error:", error);
  // Attempt to reconnect
  setTimeout(() => {
    reconnect();
  }, 3000);
};

ws.onclose = (event) => {
  if (!event.wasClean) {
    // Connection closed unexpectedly
    console.error("Unexpected close, code:", event.code, "reason:", event.reason);
    // Implement reconnection logic
  }
};
```

### Message Validation

```javascript
ws.onmessage = (event) => {
  try {
    const message = JSON.parse(event.data);

    // Validate required fields
    if (!message.type) {
      console.error("Invalid message: missing type");
      return;
    }

    // Handle by type
    switch (message.type) {
      case "detection_update":
        if (!message.detections || !Array.isArray(message.detections)) {
          throw new Error("Invalid detections format");
        }
        updateDetections(message.detections);
        break;

      case "shoplifting_alert":
        if (!message.alert_id || message.confidence === undefined) {
          throw new Error("Invalid alert format");
        }
        showAlert(message);
        break;
    }
  } catch (error) {
    console.error("Error processing message:", error);
    // Don't crash, just log and continue
  }
};
```

---

## Debugging Tips

### 1. Check Browser Network Tab
- Open DevTools → Network tab
- Filter by "Fetch/XHR"
- Click request to see:
  - Request headers (Authorization, Content-Type)
  - Request body
  - Response status & headers
  - Response body (error detail)

### 2. Check Server Logs
```bash
# View API logs
docker logs vernon-api

# Watch live logs
docker logs -f vernon-api

# Look for errors around timestamp
grep "2026-03-17T10:00" logs/api.log
```

### 3. Verify Configuration
```javascript
// Check environment variables
console.log("API URL:", process.env.REACT_APP_API_URL);
console.log("WS URL:", process.env.REACT_APP_WS_URL);

// Check stored token
console.log("Token:", localStorage.getItem('access_token'));

// Check user role
console.log("User:", localStorage.getItem('user'));
```

### 4. Test with Postman
- Import collection: `vernon-store-analytics.postman_collection.json`
- Test endpoint manually
- Check response status and body
- Verify headers sent

### 5. Enable Debug Logging
```javascript
// In development, enable verbose logging
if (process.env.NODE_ENV === 'development') {
  // Log all API requests
  axios.interceptors.request.use(config => {
    console.log("→ API Request:", config.method.toUpperCase(), config.url);
    return config;
  });

  // Log all responses
  axios.interceptors.response.use(
    response => {
      console.log("← API Response:", response.status, response.data);
      return response;
    },
    error => {
      console.error("← API Error:", error.response?.status, error.response?.data);
      return Promise.reject(error);
    }
  );
}
```

---

## Common Issues & Solutions

### Issue: 401 Unauthorized on every request
**Symptoms:** All API calls return 401, token appears to be present
**Cause:** Token expired or invalid signature
**Solution:**
- Clear localStorage and login again
- Check token expiration time
- Check Authorization header format: `Bearer <token>`

### Issue: 403 Forbidden accessing store data
**Symptoms:** Can't see other stores' data
**Cause:** User role/permissions or wrong store_id
**Solution:**
- Check user role (admin can see all stores)
- Verify store_id is correct
- Ask admin to grant access

### Issue: 422 Validation error on valid data
**Symptoms:** Valid-looking data rejected with 422
**Cause:** Type mismatch, constraint violation, or API version
**Solution:**
- Check error detail field for specific constraint
- Verify data types: "abc" not abc
- Check min/max values, enum values
- Check API examples in API_EXAMPLES.md

### Issue: WebSocket keeps disconnecting
**Symptoms:** Real-time updates stop, need to refresh
**Cause:** Network issue, server timeout, or rate limiting
**Solution:**
- Check network stability (DevTools → Network tab)
- Implement auto-reconnect with exponential backoff
- Check rate limiting headers
- Reduce message frequency if rate limited

### Issue: Network error (CORS)
**Symptoms:** "Cross-Origin Request Blocked" in console
**Cause:** Frontend URL not in CORS whitelist
**Solution:**
- Check backend CORS_ORIGINS setting
- Frontend and backend must be on allowed domain
- In development: add localhost:3000 to CORS whitelist

---

## Error Response Examples by Endpoint

### POST /api/v1/auth/login

**400 Bad Request:**
```json
{
  "success": false,
  "error": "BadRequestException",
  "message": "Missing required fields",
  "detail": "Field 'email' is required",
  "status_code": 400
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Invalid email or password",
  "status_code": 401
}
```

---

### GET /api/v1/stores/{store_id}/alerts

**401 Unauthorized:**
```json
{
  "success": false,
  "error": "UnauthorizedException",
  "message": "Missing authorization header",
  "status_code": 401
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "error": "ForbiddenException",
  "message": "You don't have permission to access store 2",
  "status_code": 403
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": "NotFoundException",
  "message": "Store with ID 999 not found",
  "status_code": 404
}
```

---

### PUT /api/v1/alerts/{alert_id}/resolve

**422 Unprocessable Entity:**
```json
{
  "success": false,
  "error": "ValidationException",
  "message": "Validation error",
  "detail": {
    "field": "note",
    "message": "Input should be a valid string"
  },
  "status_code": 422
}
```

**400 Bad Request (Already Resolved):**
```json
{
  "success": false,
  "error": "ValidationException",
  "message": "Alert sudah di-resolve pada 2026-03-17T10:20:00Z",
  "status_code": 400
}
```

---

**Last Updated:** 2026-03-17
**Version:** 1.0.0
