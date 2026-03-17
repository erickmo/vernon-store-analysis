# Prompt: Shoplifting Detection Management Dashboard UI

## Executive Summary

Buatkan **Shoplifting Detection Management Dashboard** — aplikasi web untuk monitoring real-time dan management alerts shoplifting dari CCTV. Dashboard digunakan oleh **store managers** dan **security staff** untuk:
- 👁️ Monitor behavior mencurigakan dalam real-time
- ⚠️ Manage shoplifting alerts
- 📊 Lihat analytics dan trends
- 🎯 Respond cepat terhadap incidents

---

## 1. Platform & Technology Stack

### Frontend
- **Framework:** React 18+ (TypeScript)
- **State Management:** Redux Toolkit / TanStack Query
- **UI Component:** Shadcn/UI, Tailwind CSS
- **Charting:** Recharts (untuk analytics)
- **Real-time:** WebSocket (untuk live detection updates)
- **Build Tool:** Vite
- **Testing:** Vitest + React Testing Library

### Backend (Already Exists)
- **API Endpoints:**
  - `GET /api/v1/stores/{store_id}/alerts` — List alerts
  - `PUT /api/v1/alerts/{alert_id}/resolve` — Resolve alert
  - `GET /api/v1/stream/stats` — Stream statistics
  - `WebSocket /ws/stream` — Real-time detection updates
  - `GET /api/v1/analytics/shoplifting` — Statistics & trends

---

## 2. Dashboard Overview

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│ Header: Vernon Store Analytics | Store Selector | User Menu │
├─────────────────────────────────────────────────────────────┤
│ Sidebar │                                                    │
│         │ ┌────────────────────────────────────────────────┐ │
│ - Home  │ │ Key Metrics (Top Cards)                        │ │
│ - Alerts│ │ - Active Alerts: 3 | Avg Confidence: 82%      │ │
│ - Live  │ │ - Total This Week: 12 | Resolution Rate: 92%  │ │
│ - Stats │ │ - Persons Tracked: 45 | Stream Status: Online │ │
│ - Users │ └────────────────────────────────────────────────┘ │
│         │ ┌────────────────────────────────────────────────┐ │
│         │ │ Real-time Alerts & Live Camera Feed            │ │
│         │ │ (2-column layout)                              │ │
│         │ └────────────────────────────────────────────────┘ │
│         │ ┌────────────────────────────────────────────────┐ │
│         │ │ Analytics Charts (Trends, Heatmap)             │ │
│         │ └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Pages & Features

### A. Dashboard Home

**Path:** `/dashboard`

**Components:**
1. **Key Metrics Cards** (top section)
   - Active Alerts Count
   - Average Confidence Score
   - Total Alerts This Week
   - Alert Resolution Rate (%)
   - Active Persons Being Tracked
   - Stream Status (Online/Offline)

2. **Real-time Active Alerts Table**
   - Columns: Alert ID | Visit ID | Camera | Confidence | Time | Status | Actions
   - Color coding: Red (>0.85), Orange (0.75-0.85), Yellow (<0.75)
   - Sortable by: Confidence, Time, Camera
   - Filterable by: Status (unresolved/resolved)
   - Action buttons: View Detail | Resolve | Dismiss
   - Pagination: 10 alerts per page

3. **Live Camera Feed** (optional)
   - Grid view dari active cameras
   - Show latest detected persons
   - Real-time person count overlay

---

### B. Alerts Management Page

**Path:** `/alerts`

**Features:**
1. **Advanced Filter Panel**
   - Date range picker (Start - End)
   - Camera selector (multi-select)
   - Confidence range slider (0.0 - 1.0)
   - Status filter: All | Unresolved | Resolved
   - Search by Alert ID / Person UID

2. **Alerts Table**
   - Columns:
     - Alert ID (clickable → detail)
     - Visit ID
     - Camera
     - Confidence (with progress bar)
     - Detected At (timestamp)
     - Status (badge: Unresolved/Resolved)
     - Resolved By (user name)
     - Resolved At (timestamp)
     - Actions (Resolve, View Detail)
   - Sortable: All columns
   - Selectable: Bulk actions (multi-select resolve)
   - Exportable: CSV/PDF

3. **Alert Detail Modal**
   - Alert ID, Visit ID, Camera, Confidence
   - Detection timestamp
   - Person UID
   - Behavior reasons (list of detected suspicious behaviors)
   - Mood analysis (chart: mood distribution during visit)
   - Zone tracking (sequence of zones visited)
   - Dwell time breakdown per zone
   - Resolve form:
     - Textarea: resolved_note (staff comment)
     - Button: Mark as Resolved
   - Close button

---

### C. Live Monitoring Page

**Path:** `/live`

**Real-time Features:**
1. **WebSocket Connection Status**
   - Connected/Disconnected indicator
   - Last update timestamp
   - Auto-reconnect status

2. **Camera Grid View**
   - 2x2 or 3x3 grid layout (configurable)
   - Per camera card:
     - Camera name & location zone
     - Latest frame (if available)
     - Active persons count
     - FPS (frames per second)
     - Last frame timestamp
     - Click → expand full view

3. **Real-time Detection Feed**
   - Live stream of detected persons
   - Card per detection:
     - Face thumbnail (if available)
     - Person UID
     - Detected mood & confidence
     - Zone location
     - Timestamp
     - Current behavior score (%)
   - Auto-scroll list
   - Filter by camera

4. **Behavior Monitor**
   - List of persons currently being tracked
   - Per person:
     - Person UID
     - First detected time
     - Current mood
     - Zones visited (breadcrumb)
     - Dwell time
     - Suspicious score (%)
     - Alert status (if any)

---

### D. Analytics & Statistics Page

**Path:** `/analytics`

**Sections:**

1. **Overview Cards**
   - Total Alerts (this week/month/year)
   - Resolution Rate (%)
   - Average Confidence
   - Most Common Behaviors (top 3)

2. **Time Series Chart**
   - X-axis: Date/Hour
   - Y-axis: Alert count
   - Trend line
   - Toggleable: Daily/Hourly/Weekly view
   - Brush selector untuk zoom

3. **Confidence Distribution**
   - Histogram: Alert count by confidence bands
   - Bands: 0.0-0.25 | 0.25-0.50 | 0.50-0.75 | 0.75-0.90 | 0.90-1.0
   - Show median & mean line

4. **Top Behaviors**
   - Bar chart: Most common suspicious reasons
   - Example: "Dwell without cashier", "Nervous mood", "Zone changes", etc.

5. **Camera Performance**
   - Table: Camera | Detections | Avg Confidence | Active Profiles
   - Sortable, filterable

6. **Peak Hours Analysis**
   - Heatmap: Hour x Day of Week
   - Color intensity: Alert frequency
   - Show peak times for staffing

7. **Resolution Metrics**
   - Pie chart: Resolved vs Unresolved
   - List top resolvers (by count)
   - Average resolution time

---

### E. Settings & User Management Page

**Path:** `/settings`

**Sections:**

1. **Store Settings**
   - Store name & location
   - Threshold configuration (Shoplifting confidence threshold)
   - Notification cooldown (seconds between alerts same person)

2. **Camera Management**
   - Table: Camera ID | Name | Zone | Location | Stream URL | Status
   - Actions: Edit | Delete | Test Stream | View Live

3. **User Management**
   - Table: User ID | Name | Email | Role | Last Login | Status
   - Roles: Admin | Manager | Security Staff | Viewer
   - Actions: Edit | Deactivate | Reset Password | View Audit Log

4. **Notification Settings**
   - Email alerts on high-confidence detections
   - Slack/Teams integration (if available)
   - Custom alert thresholds per user role

5. **System Status**
   - Stream manager status
   - Database connection status
   - API health check
   - Last sync timestamp

---

## 4. Real-time Features (WebSocket)

### Connection URL
```
wss://api.vernon.local/ws/stream
```

### Message Types

**1. Detection Update**
```json
{
  "type": "detection_update",
  "camera_id": 1,
  "timestamp": "2026-03-17T10:00:00Z",
  "persons_count": 3,
  "detections": [
    {
      "person_uid": "person_123",
      "mood": "neutral",
      "mood_confidence": 0.92,
      "age_estimate": 35,
      "gender": "male",
      "zone": "floor"
    }
  ]
}
```

**2. Shoplifting Alert**
```json
{
  "type": "shoplifting_alert",
  "alert_id": 1,
  "camera_id": 1,
  "timestamp": "2026-03-17T10:05:00Z",
  "person_uid": "person_123",
  "visit_id": 1,
  "confidence": 0.85,
  "reasons": [
    "Dwell 15 menit tanpa ke kasir",
    "Mood nervous 50%"
  ]
}
```

### UI Behavior
- **On Detection Update:** Update persons list di Live page, update metrics
- **On Shoplifting Alert:**
  - Toast notification (top-right, 5 sec auto-close)
  - Add to alerts table instantly
  - Sound alert (configurable: on/off)
  - Badge counter di "Alerts" sidebar

---

## 5. UI/UX Requirements

### Color Scheme
- **Primary:** Blue (#0070F3)
- **Alert Levels:**
  - 🔴 Critical (>0.85): #EF4444
  - 🟠 Warning (0.75-0.85): #F97316
  - 🟡 Medium (0.60-0.75): #EAB308
  - 🟢 Normal (<0.60): #22C55E
- **Background:** Light (#FFFFFF) with dark (#0F172A) mode support
- **Text:** Dark text on light, light text on dark

### Typography
- **Headers (H1-H3):** Inter, Bold, Size 24-32
- **Body:** Inter, Regular, Size 14-16
- **Monospace (IDs):** JetBrains Mono, Size 12

### Icons
- Use: Lucide Icons (React library)
- Examples: AlertCircle, Camera, TrendingUp, Users, Settings, etc.

### Responsive Design
- **Desktop:** 1920x1080 (main breakpoint)
- **Laptop:** 1280x720
- **Tablet:** 768px
- **Mobile:** 375px (if needed, primary focus desktop)

### Accessibility
- WCAG 2.1 AA compliance
- Keyboard navigation support
- Screen reader friendly (ARIA labels)
- Color contrast ratio ≥4.5:1

---

## 6. Authentication & Authorization

### Auth Flow
- **Login page:** Email + Password
- **JWT token** stored in HTTP-only cookie
- **Token refresh:** Automatic, 1 hour expiry
- **Logout:** Clear session

### Role-Based Access
- **Admin:** Full access (all pages)
- **Manager:** Dashboard, Alerts, Analytics, Limited Settings
- **Security Staff:** Dashboard, Alerts, Live (read-only)
- **Viewer:** Dashboard, Analytics (read-only)

### Route Protection
```typescript
// Example protected route
<Route path="/alerts" component={AlertsPage} requiredRole="manager" />
```

---

## 7. Performance Requirements

- **Initial Load:** <3 seconds
- **Page Load:** <2 seconds
- **WebSocket Latency:** <500ms for updates
- **Real-time Chart Update:** <100ms
- **Bundle Size:** <500KB (gzipped)

### Optimization
- Code splitting by route
- Lazy load images & charts
- Virtual scrolling untuk long lists
- Memoization untuk expensive components
- Debounce WebSocket updates

---

## 8. Testing Requirements

### Unit Tests
- Component tests dengan React Testing Library
- Test coverage: >80%
- Test utilities & mocks

### Integration Tests
- WebSocket mock (MSW - Mock Service Worker)
- API integration tests
- Navigation tests

### E2E Tests (Optional)
- Playwright/Cypress
- Critical user flows:
  - Login → View Dashboard → Resolve Alert
  - Live monitoring → Real-time update
  - Filter alerts → Export

---

## 9. Project Structure

```
frontend/
├── public/
│   └── images/
├── src/
│   ├── components/
│   │   ├── layout/        (Header, Sidebar, Footer)
│   │   ├── alerts/        (AlertsTable, AlertDetail)
│   │   ├── dashboard/     (MetricsCards, RealTimeAlerts)
│   │   ├── live/          (CameraGrid, DetectionFeed)
│   │   ├── analytics/     (Charts, StatisticsCards)
│   │   ├── settings/      (SettingsForms)
│   │   └── common/        (Loading, Modal, Toast)
│   ├── pages/
│   │   ├── Dashboard.tsx
│   │   ├── Alerts.tsx
│   │   ├── Live.tsx
│   │   ├── Analytics.tsx
│   │   ├── Settings.tsx
│   │   └── Login.tsx
│   ├── hooks/
│   │   ├── useWebSocket.ts    (WebSocket management)
│   │   ├── useFetch.ts        (API data fetching)
│   │   ├── useAuth.ts         (Auth context)
│   │   └── useLocalStorage.ts
│   ├── services/
│   │   ├── api.ts             (Axios/Fetch wrapper)
│   │   ├── websocket.ts       (WebSocket client)
│   │   └── auth.ts            (Auth utilities)
│   ├── store/
│   │   ├── authSlice.ts
│   │   ├── alertsSlice.ts
│   │   ├── streamSlice.ts
│   │   └── store.ts           (Redux store config)
│   ├── types/
│   │   ├── alert.ts
│   │   ├── stream.ts
│   │   ├── user.ts
│   │   └── api.ts
│   ├── utils/
│   │   ├── formatters.ts      (Date, number formatting)
│   │   ├── validators.ts
│   │   └── constants.ts
│   ├── App.tsx
│   ├── App.css
│   └── main.tsx
├── tests/
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   └── mocks/
├── .env.example
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.ts
├── package.json
└── README.md
```

---

## 10. Key Implementation Details

### WebSocket Connection Management
```typescript
// Reconnect on disconnect
// Heartbeat check every 30s
// Queue messages if disconnected
// Auto-replay missed updates
```

### Real-time Alert Notification
```typescript
// Toast notification
// Sound alert (configurable)
// Badge counter increment
// Add to table (top of list)
```

### Data Refresh Strategy
```typescript
// Alerts: Auto-refresh every 5 seconds (+ WebSocket push)
// Analytics: Refresh every 60 seconds (user can manual refresh)
// Camera stats: Real-time via WebSocket
// User data: Fetch on page load
```

### Caching Strategy
- **React Query** dengan stale time 30s
- Local cache untuk non-critical data
- Invalidate on: Alert resolve, User action, Manual refresh

---

## 11. Deliverables Checklist

- [ ] React component library setup (Shadcn/UI + Tailwind)
- [ ] Redux store configuration (auth, alerts, stream)
- [ ] API client & error handling
- [ ] WebSocket client & reconnection logic
- [ ] Login page + auth flow
- [ ] Dashboard home page + key metrics
- [ ] Alerts management page + detail modal
- [ ] Live monitoring page + WebSocket integration
- [ ] Analytics page + charts
- [ ] Settings page (store, camera, users)
- [ ] Responsive design (desktop first, then tablet/mobile)
- [ ] Error handling & loading states
- [ ] Toast notifications & modal dialogs
- [ ] Unit tests (components, hooks, utils)
- [ ] Integration tests (with MSW mocks)
- [ ] Documentation (component storybook optional)
- [ ] Deployment configuration (build, env vars)

---

## 12. Future Enhancements

- [ ] Export alerts to PDF/CSV
- [ ] Multi-language support (EN, ID)
- [ ] Dark mode toggle (already in Tailwind)
- [ ] Custom dashboard widgets
- [ ] Scheduled reports via email
- [ ] Mobile app (React Native)
- [ ] Advanced analytics (ML-based anomaly detection)
- [ ] Incident timeline & correlation
- [ ] Video clip export (proof of incident)
- [ ] Integration dengan SIEM/Security platforms

---

## 13. Mockups / Wireframes Reference

**Suggested tool:** Figma (create before coding)

**Screens to design:**
1. Login page
2. Dashboard home
3. Alerts management
4. Alert detail modal
5. Live monitoring
6. Analytics page
7. Settings page
8. Mobile responsive (if needed)

---

## Start Building! 🚀

Gunakan prompt ini dengan:
- Flutter designer skill → `clone design ini`
- React frontend skill → `buat dashboard react ini`
- Next.js skill → `setup next.js dashboard`

**Questions?**
- Clarify data structure dari backend
- Confirm color scheme & branding
- Define WebSocket message format exactly
- Agree on analytics time periods
- Set performance benchmarks

**Success Criteria:**
✅ Real-time alerts displayed <500ms after detection
✅ All pages load <2 seconds
✅ WebSocket auto-reconnect works
✅ Role-based access enforced
✅ Mobile responsive (if required)
✅ >80% test coverage
