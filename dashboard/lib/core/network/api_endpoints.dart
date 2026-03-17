/// Semua API endpoint constants.
abstract class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api/v1';

  // ── Auth ──────────────────────────────────────────────────────
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String me = '$apiPrefix/auth/me';

  // ── Stores ────────────────────────────────────────────────────
  static const String stores = '$apiPrefix/stores';
  static String storeById(int storeId) => '$apiPrefix/stores/$storeId';

  // ── Cameras ───────────────────────────────────────────────────
  static String cameras(int storeId) => '$apiPrefix/stores/$storeId/cameras';
  static String cameraById(int storeId, int cameraId) =>
      '$apiPrefix/stores/$storeId/cameras/$cameraId';

  // ── Visitors ──────────────────────────────────────────────────
  static String visitors(int storeId) => '$apiPrefix/stores/$storeId/visitors';
  static String visitorById(int visitorId) => '$apiPrefix/visitors/$visitorId';
  static String moodTimeline(int visitorId, int visitId) =>
      '$apiPrefix/visitors/$visitorId/visits/$visitId/mood-timeline';

  // ── Traffic ───────────────────────────────────────────────────
  static String traffic(int storeId) => '$apiPrefix/stores/$storeId/traffic';
  static String realtimeTraffic(int storeId) =>
      '$apiPrefix/stores/$storeId/traffic/realtime';

  // ── Alerts ────────────────────────────────────────────────────
  static String alerts(int storeId) => '$apiPrefix/stores/$storeId/alerts';
  static String resolveAlert(int alertId) =>
      '$apiPrefix/alerts/$alertId/resolve';

  // ── Analytics ─────────────────────────────────────────────────
  static String analyticsDashboard(int storeId) =>
      '$apiPrefix/stores/$storeId/analytics/dashboard';
  static String analyticsGender(int storeId) =>
      '$apiPrefix/stores/$storeId/analytics/gender';
  static String analyticsAge(int storeId) =>
      '$apiPrefix/stores/$storeId/analytics/age';
  static String analyticsMood(int storeId) =>
      '$apiPrefix/stores/$storeId/analytics/mood';
  static String analyticsDwellTime(int storeId) =>
      '$apiPrefix/stores/$storeId/analytics/dwell-time';
  static String analyticsVisitors(int storeId) =>
      '$apiPrefix/stores/$storeId/analytics/visitors';

  // ── Statistics ────────────────────────────────────────────────
  static String statsKpi(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/kpi';
  static String statsBehavior(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/behavior';
  static String statsConversion(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/conversion';
  static String statsBounce(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/bounce';
  static String statsReturnVisitors(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/return-visitors';
  static String statsJourney(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/journey';
  static String statsMoodShift(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/mood-shift';
  static String statsDemographics(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/demographics';
  static String statsHeatmap(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/heatmap';
  static String statsPeakHours(int storeId) =>
      '$apiPrefix/stores/$storeId/statistics/peak-hours';

  // ── Stream ────────────────────────────────────────────────────
  static const String streamStatus = '$apiPrefix/stream/status';
  static String startCamera(int cameraId) =>
      '$apiPrefix/stream/cameras/$cameraId/start';
  static String stopCamera(int cameraId) =>
      '$apiPrefix/stream/cameras/$cameraId/stop';
  static const String startAllStreams = '$apiPrefix/stream/start-all';
  static const String stopAllStreams = '$apiPrefix/stream/stop-all';
  static const String shopliftingScores = '$apiPrefix/stream/shoplifting/scores';
  static String shopliftingProfile(String personUid) =>
      '$apiPrefix/stream/shoplifting/profile/$personUid';

  // ── WebSocket ─────────────────────────────────────────────────
  static String get wsStream {
    final base = baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$base$apiPrefix/stream/ws';
  }
}
