# Frontend Integration Guide

**Date:** 2026-03-17
**Status:** Complete
**Version:** 1.0.0

---

## Overview

Panduan lengkap untuk frontend React team mengintegrasikan dengan Vernon Store Analytics API.

**Backend:** FastAPI (Python) at `http://localhost:8000/api/v1`
**Frontend:** React 18 + TypeScript
**Auth:** JWT Bearer tokens
**Real-time:** WebSocket (`/ws/stream`)

---

## 1. Setup & Configuration

### Install Dependencies

```bash
npm install axios react-query zustand
# or
npm install @tanstack/react-query zustand
```

### Environment Variables

Create `.env.local`:

```bash
# API Configuration
REACT_APP_API_URL=http://localhost:8000
REACT_APP_WS_URL=ws://localhost:8000
REACT_APP_API_TIMEOUT=10000

# Feature flags
REACT_APP_ENABLE_2FA=true
REACT_APP_ENABLE_ANALYTICS=true
REACT_APP_ENABLE_DARK_MODE=true
```

### API Client Setup

**`src/services/api.ts`:**

```typescript
import axios, { AxiosInstance, InternalAxiosRequestConfig } from 'axios';

interface CustomConfig extends InternalAxiosRequestConfig {
  skipAuth?: boolean;
}

const api: AxiosInstance = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  timeout: parseInt(process.env.REACT_APP_API_TIMEOUT || '10000'),
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - add JWT token
api.interceptors.request.use((config: CustomConfig) => {
  if (!config.skipAuth) {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

// Response interceptor - handle 401, refresh token, etc.
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Handle 401 Unauthorized
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      // Try to refresh token
      try {
        const response = await api.post('/auth/refresh', {}, { skipAuth: true });
        const { access_token } = response.data.data;
        localStorage.setItem('access_token', access_token);

        // Retry original request with new token
        return api(originalRequest);
      } catch (refreshError) {
        // Refresh failed, redirect to login
        localStorage.removeItem('access_token');
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

---

## 2. Authentication Flow

### Login Implementation

**`src/pages/Login.tsx`:**

```typescript
import { useState } from 'react';
import api from '../services/api';

export function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await api.post('/auth/login', { email, password }, { skipAuth: true });

      if (response.data.success) {
        const { access_token, user } = response.data.data;

        // Store token
        localStorage.setItem('access_token', access_token);

        // Store user info for context
        localStorage.setItem('user', JSON.stringify(user));

        // Set store_id for Postman/requests
        if (user.store_id) {
          localStorage.setItem('store_id', user.store_id.toString());
        }

        // Redirect to dashboard
        window.location.href = '/dashboard';
      }
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleLogin}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
        required
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
        required
      />
      {error && <div style={{ color: 'red' }}>{error}</div>}
      <button type="submit" disabled={loading}>
        {loading ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

### Logout Implementation

```typescript
export function Logout() {
  const handleLogout = async () => {
    try {
      await api.post('/auth/logout');
    } finally {
      localStorage.removeItem('access_token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
  };

  return <button onClick={handleLogout}>Logout</button>;
}
```

---

## 3. Data Fetching with React Query

### Setup React Query

**`src/main.tsx`:**

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30 * 1000, // 30 seconds
      gcTime: 5 * 60 * 1000, // 5 minutes (formerly cacheTime)
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

ReactDOM.render(
  <QueryClientProvider client={queryClient}>
    <App />
  </QueryClientProvider>,
  document.getElementById('root')
);
```

### Custom Hooks

**`src/hooks/useAlerts.ts`:**

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../services/api';

interface Alert {
  id: number;
  visit_id: number;
  confidence: number;
  status: 'unresolved' | 'resolved';
  resolved_note?: string;
  timestamp: string;
  reasons: string[];
}

// List alerts
export function useAlerts(storeId: number, resolved?: boolean) {
  return useQuery({
    queryKey: ['alerts', storeId, resolved],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (resolved !== undefined) params.append('resolved', resolved.toString());
      params.append('limit', '50');

      const response = await api.get(`/stores/${storeId}/alerts?${params}`);
      return response.data.data;
    },
    staleTime: 30 * 1000,
  });
}

// Get single alert
export function useAlert(alertId: number) {
  return useQuery({
    queryKey: ['alert', alertId],
    queryFn: async () => {
      const response = await api.get(`/alerts/${alertId}`);
      return response.data.data;
    },
  });
}

// Resolve alert mutation
export function useResolveAlert(storeId: number) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ alertId, note }: { alertId: number; note: string }) => {
      const response = await api.put(`/alerts/${alertId}/resolve`, { note });
      return response.data.data;
    },
    onSuccess: () => {
      // Invalidate alerts query to refetch
      queryClient.invalidateQueries({ queryKey: ['alerts', storeId] });
    },
  });
}
```

**`src/hooks/useAnalytics.ts`:**

```typescript
import { useQuery } from '@tanstack/react-query';
import api from '../services/api';

export function useShopliftingAnalytics(storeId: number, period: 'day' | 'week' | 'month' | 'year') {
  return useQuery({
    queryKey: ['analytics', 'shoplifting', storeId, period],
    queryFn: async () => {
      const response = await api.get('/analytics/shoplifting', {
        params: { store_id: storeId, period },
      });
      return response.data.data;
    },
    staleTime: 60 * 1000, // 60 seconds for analytics
  });
}
```

---

## 4. WebSocket Integration

### WebSocket Hook

**`src/hooks/useWebSocket.ts`:**

```typescript
import { useEffect, useRef, useCallback } from 'react';

interface DetectionMessage {
  type: 'detection_update';
  camera_id: number;
  timestamp: string;
  persons_count: number;
  detections: Array<{
    person_uid: string;
    mood: string;
    zone: string;
    dwell_time_seconds: number;
  }>;
}

interface AlertMessage {
  type: 'shoplifting_alert';
  alert_id: number;
  confidence: number;
  person_uid: string;
  timestamp: string;
  reasons: string[];
}

type WebSocketMessage = DetectionMessage | AlertMessage;

export function useWebSocket(
  onDetection?: (msg: DetectionMessage) => void,
  onAlert?: (msg: AlertMessage) => void
) {
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();
  const reconnectAttempts = useRef(0);

  const connect = useCallback(() => {
    try {
      const wsUrl = process.env.REACT_APP_WS_URL || 'ws://localhost:8000';
      wsRef.current = new WebSocket(`${wsUrl}/ws/stream`);

      wsRef.current.onopen = () => {
        console.log('WebSocket connected');
        reconnectAttempts.current = 0;
      };

      wsRef.current.onmessage = (event) => {
        try {
          const message: WebSocketMessage = JSON.parse(event.data);

          if (message.type === 'detection_update') {
            onDetection?.(message);
          } else if (message.type === 'shoplifting_alert') {
            onAlert?.(message);
          }
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };

      wsRef.current.onerror = (error) => {
        console.error('WebSocket error:', error);
      };

      wsRef.current.onclose = () => {
        console.log('WebSocket disconnected, attempting reconnect...');
        // Exponential backoff
        const delay = Math.min(1000 * Math.pow(2, reconnectAttempts.current), 30000);
        reconnectAttempts.current++;

        reconnectTimeoutRef.current = setTimeout(connect, delay);
      };
    } catch (error) {
      console.error('Error connecting to WebSocket:', error);
    }
  }, [onDetection, onAlert]);

  useEffect(() => {
    connect();

    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
      }
    };
  }, [connect]);

  return {
    isConnected: wsRef.current?.readyState === WebSocket.OPEN,
  };
}
```

### Usage in Component

```typescript
import { useWebSocket } from '../hooks/useWebSocket';

export function LiveMonitoring() {
  const { isConnected } = useWebSocket(
    (detection) => {
      // Update detections on screen
      console.log('New detection:', detection);
    },
    (alert) => {
      // Show alert notification
      console.log('Alert triggered:', alert);
      toast.error(`Alert #${alert.alert_id} - ${alert.confidence}% confidence`);
    }
  );

  return (
    <div>
      <span>{isConnected ? '🟢 Connected' : '🔴 Disconnected'}</span>
    </div>
  );
}
```

---

## 5. Error Handling

### Global Error Handler

**`src/utils/errorHandler.ts`:**

```typescript
import { AxiosError } from 'axios';
import { toast } from 'react-hot-toast';

interface ApiError {
  success: false;
  error: string;
  message: string;
  detail?: string | object;
  status_code: number;
}

export function handleApiError(error: AxiosError<ApiError>) {
  const data = error.response?.data;

  if (!data) {
    toast.error('Network error. Check your connection.');
    return;
  }

  // Handle by error type
  switch (data.error) {
    case 'UnauthorizedException':
      // Handle logout
      localStorage.removeItem('access_token');
      window.location.href = '/login';
      toast.error('Session expired. Please login again.');
      break;

    case 'ForbiddenException':
      toast.error(data.message || 'Access denied');
      break;

    case 'NotFoundException':
      toast.error(data.message || 'Resource not found');
      break;

    case 'ValidationException':
      if (typeof data.detail === 'object') {
        const detail = data.detail as any;
        toast.error(`${detail.field}: ${detail.message}`);
      } else {
        toast.error(data.detail as string || data.message);
      }
      break;

    case 'RateLimitException':
      toast.error('Too many requests. Please try again later.');
      break;

    default:
      toast.error(data.message || 'An error occurred');
  }
}
```

### Interceptor Integration

```typescript
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.data) {
      handleApiError(error);
    }
    return Promise.reject(error);
  }
);
```

---

## 6. State Management (Zustand)

### Store Setup

**`src/store/authStore.ts`:**

```typescript
import { create } from 'zustand';

interface User {
  id: number;
  email: string;
  name: string;
  role: 'admin' | 'manager' | 'security_staff' | 'viewer';
  store_id: number;
}

interface AuthStore {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>((set) => ({
  user: JSON.parse(localStorage.getItem('user') || 'null'),
  token: localStorage.getItem('access_token'),
  isAuthenticated: !!localStorage.getItem('access_token'),

  setAuth: (user, token) => {
    localStorage.setItem('user', JSON.stringify(user));
    localStorage.setItem('access_token', token);
    set({ user, token, isAuthenticated: true });
  },

  logout: () => {
    localStorage.removeItem('user');
    localStorage.removeItem('access_token');
    set({ user: null, token: null, isAuthenticated: false });
  },
}));
```

### Usage in Component

```typescript
import { useAuthStore } from '../store/authStore';

export function Dashboard() {
  const { user, logout } = useAuthStore();

  return (
    <div>
      <h1>Welcome, {user?.name}</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

---

## 7. TypeScript Types

### Generate from OpenAPI

**Option A: Manual (Quick Start)**

```typescript
// src/types/api.ts

export interface Alert {
  id: number;
  visit_id: number;
  camera_id: number;
  person_uid: string;
  confidence: number;
  timestamp: string;
  status: 'unresolved' | 'resolved';
  reasons: string[];
  resolved_at?: string;
  resolved_by?: string;
  resolved_note?: string;
}

export interface AlertResponse {
  success: boolean;
  data: Alert[];
  pagination: {
    total: number;
    limit: number;
    offset: number;
    pages: number;
    current_page: number;
  };
}

export interface ShopliftingAnalytics {
  period: 'day' | 'week' | 'month' | 'year';
  summary: {
    total_alerts: number;
    resolved: number;
    avg_confidence: number;
    resolution_rate: number;
  };
  by_day: Array<{ date: string; count: number }>;
  by_hour: Array<{ hour: number; count: number }>;
  top_behaviors: Array<{ reason: string; count: number; percentage: number }>;
}

export interface Visitor {
  person_uid: string;
  visits_count: number;
  last_visit: string;
  avg_dwell_time_minutes: number;
  total_suspicious_alerts: number;
}

export interface Camera {
  id: number;
  store_id: number;
  name: string;
  location: string;
  zone: string;
  stream_url: string;
  status: 'active' | 'inactive';
  stream_status: 'connected' | 'disconnected';
  fps: number;
  active_persons: number;
}
```

**Option B: Auto-Generate from OpenAPI**

```bash
# Install openapi-typescript
npm install -D openapi-typescript

# Generate types from OpenAPI spec
npx openapi-typescript http://localhost:8000/api/openapi.json -o src/types/generated.ts

# Use in code
import { paths } from './types/generated';
type ListAlertsResponse = paths['/stores/{store_id}/alerts']['get']['responses']['200']['content']['application/json'];
```

---

## 8. Form Handling

### Form with Validation

**`src/components/ResolveAlertForm.tsx`:**

```typescript
import { useForm } from 'react-hook-form';
import { useResolveAlert } from '../hooks/useAlerts';

interface ResolveFormData {
  note: string;
}

export function ResolveAlertForm({ alertId, storeId, onSuccess }: Props) {
  const { register, handleSubmit, formState: { errors } } = useForm<ResolveFormData>();
  const { mutate: resolveAlert, isPending } = useResolveAlert(storeId);

  const onSubmit = (data: ResolveFormData) => {
    resolveAlert(
      { alertId, note: data.note },
      {
        onSuccess: () => {
          toast.success('Alert resolved');
          onSuccess?.();
        },
        onError: (error) => {
          // Error already handled by global interceptor
        },
      }
    );
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <textarea
        {...register('note', { required: 'Note is required', minLength: 10 })}
        placeholder="Enter resolution notes..."
      />
      {errors.note && <span style={{ color: 'red' }}>{errors.note.message}</span>}

      <button type="submit" disabled={isPending}>
        {isPending ? 'Resolving...' : 'Resolve Alert'}
      </button>
    </form>
  );
}
```

---

## 9. Testing API Integration

### Unit Test Example

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { useAlerts } from '../hooks/useAlerts';
import * as api from '../services/api';

jest.mock('../services/api');

describe('useAlerts', () => {
  it('should fetch alerts for store', async () => {
    const mockData = [
      { id: 1, confidence: 0.87, status: 'unresolved' },
    ];

    (api.get as jest.Mock).mockResolvedValue({
      data: { data: mockData },
    });

    const { result } = renderHook(() => useAlerts(1));

    await waitFor(() => {
      expect(result.current.data).toEqual(mockData);
    });
  });

  it('should handle API error', async () => {
    (api.get as jest.Mock).mockRejectedValue(
      new Error('API Error')
    );

    const { result } = renderHook(() => useAlerts(1));

    await waitFor(() => {
      expect(result.current.isError).toBe(true);
    });
  });
});
```

---

## 10. Performance Tips

### 1. Lazy Load Routes

```typescript
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Alerts = lazy(() => import('./pages/Alerts'));

export function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/alerts" element={<Alerts />} />
      </Routes>
    </Suspense>
  );
}
```

### 2. Memoization

```typescript
import { memo } from 'react';

// Only re-render if props change
const AlertsTable = memo(({ alerts }: Props) => {
  return <table>{/* render alerts */}</table>;
});
```

### 3. Virtual Scrolling (Long Lists)

```typescript
import { FixedSizeList } from 'react-window';

export function AlertsList({ alerts }) {
  return (
    <FixedSizeList
      height={600}
      itemCount={alerts.length}
      itemSize={60}
      width="100%"
    >
      {({ index, style }) => (
        <div style={style}>
          <AlertRow alert={alerts[index]} />
        </div>
      )}
    </FixedSizeList>
  );
}
```

### 4. Debounce Search

```typescript
import { useDeferredValue } from 'react';

export function SearchAlerts() {
  const [input, setInput] = useState('');
  const debouncedInput = useDeferredValue(input);

  const { data } = useQuery({
    queryKey: ['search', debouncedInput],
    queryFn: () => search(debouncedInput),
    enabled: debouncedInput.length > 2,
  });
}
```

---

## 11. Documentation Links

- **API Reference:** [OPENAPI.md](./OPENAPI.md)
- **API Examples:** [API_EXAMPLES.md](./API_EXAMPLES.md)
- **Architecture:** [ARCHITECTURE.md](./ARCHITECTURE.md)
- **Error Handling:** [ERROR_HANDLING.md](./ERROR_HANDLING.md)
- **Database Schema:** [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)
- **Postman Collection:** `vernon-store-analytics.postman_collection.json`

---

## 12. Common Questions

**Q: How do I get the JWT token?**
A: Call `POST /api/v1/auth/login` with email/password. Store the returned `access_token`.

**Q: How do I refresh the token?**
A: Token auto-refreshes via the response interceptor if < 5 min left. Or call `POST /api/v1/auth/refresh`.

**Q: How do I access other user's store data?**
A: Users can only access their own store. Admin can access all stores. Check user role in localStorage.

**Q: How do I handle WebSocket errors?**
A: Hook automatically reconnects with exponential backoff. Implement `onclose` handler for custom logic.

**Q: How do I implement role-based UI?**
A: Check `user.role` in your state and conditionally render elements.

```typescript
const { user } = useAuthStore();
const canResolveAlerts = ['admin', 'manager'].includes(user?.role);

return canResolveAlerts ? <ResolveButton /> : null;
```

---

**Last Updated:** 2026-03-17
**Version:** 1.0.0
