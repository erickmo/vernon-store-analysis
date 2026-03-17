import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/http_client.dart';
import '../network/token_interceptor.dart';
import '../utils/token_manager.dart';
import '../utils/websocket_client.dart';

// Features
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/store/data/datasources/store_remote_datasource.dart';
import '../../features/store/data/repositories/store_repository_impl.dart';
import '../../features/store/domain/repositories/store_repository.dart';
import '../../features/store/domain/usecases/get_store_list_usecase.dart';
import '../../features/store/domain/usecases/get_store_by_id_usecase.dart';
import '../../features/store/presentation/cubit/store_cubit.dart';

import '../../features/cctv/data/datasources/cctv_local_datasource.dart';
import '../../features/cctv/data/datasources/cctv_remote_datasource.dart';
import '../../features/cctv/data/repositories/cctv_repository_impl.dart';
import '../../features/cctv/domain/repositories/cctv_repository.dart';
import '../../features/cctv/domain/usecases/get_cctv_list_usecase.dart';
import '../../features/cctv/domain/usecases/get_cctv_by_id_usecase.dart';
import '../../features/cctv/presentation/cubit/cctv_list_cubit.dart';
import '../../features/cctv/presentation/cubit/streaming_cubit.dart';

import '../../features/alert/data/datasources/alert_remote_datasource.dart';
import '../../features/alert/data/repositories/alert_repository_impl.dart';
import '../../features/alert/domain/repositories/alert_repository.dart';
import '../../features/alert/domain/usecases/get_alert_list_usecase.dart';
import '../../features/alert/domain/usecases/resolve_alert_usecase.dart';
import '../../features/alert/presentation/cubit/alert_cubit.dart';

import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/domain/usecases/get_analytics_dashboard_usecase.dart';
import '../../features/analytics/presentation/cubit/analytics_cubit.dart';

import '../../features/traffic/data/datasources/traffic_remote_datasource.dart';
import '../../features/traffic/data/repositories/traffic_repository_impl.dart';
import '../../features/traffic/domain/repositories/traffic_repository.dart';
import '../../features/traffic/domain/usecases/get_traffic_summary_usecase.dart';
import '../../features/traffic/domain/usecases/get_realtime_traffic_usecase.dart';
import '../../features/traffic/presentation/cubit/traffic_cubit.dart';

import '../../features/visitor/data/datasources/visitor_remote_datasource.dart';
import '../../features/visitor/data/repositories/visitor_repository_impl.dart';
import '../../features/visitor/domain/repositories/visitor_repository.dart';
import '../../features/visitor/domain/usecases/get_visitor_list_usecase.dart';
import '../../features/visitor/domain/usecases/get_visitor_detail_usecase.dart';
import '../../features/visitor/domain/usecases/get_mood_timeline_usecase.dart';
import '../../features/visitor/presentation/cubit/visitor_cubit.dart';
import '../../features/visitor/presentation/cubit/visitor_detail_cubit.dart';

import '../../features/statistics/data/datasources/statistics_remote_datasource.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
import '../../features/statistics/domain/usecases/get_kpi_usecase.dart';
import '../../features/statistics/domain/usecases/get_behavior_usecase.dart';
import '../../features/statistics/presentation/cubit/statistics_cubit.dart';

import '../../features/stream/data/datasources/stream_remote_datasource.dart';
import '../../features/stream/data/repositories/stream_repository_impl.dart';
import '../../features/stream/domain/repositories/stream_repository.dart';
import '../../features/stream/domain/usecases/get_stream_status_usecase.dart';
import '../../features/stream/domain/usecases/control_stream_usecase.dart';
import '../../features/stream/presentation/cubit/stream_status_cubit.dart';

final GetIt getIt = GetIt.instance;

/// Inisialisasi semua dependency injection.
///
/// Dipanggil sekali di [main()] sebelum [runApp()].
Future<void> setupDependencies() async {
  // ── Core ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<TokenManager>(
    () => TokenManager(getIt()),
  );

  getIt.registerLazySingleton<TokenInterceptor>(
    () => TokenInterceptor(getIt()),
  );

  getIt.registerLazySingleton<AppHttpClient>(
    () => AppHttpClient(tokenInterceptor: getIt()),
  );

  getIt.registerLazySingleton<WebSocketClient>(
    () => WebSocketClient(getIt()),
  );

  // ── Auth ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      tokenManager: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => RefreshTokenUseCase(getIt()));
  getIt.registerFactory(() => AuthCubit(
        loginUseCase: getIt(),
        logoutUseCase: getIt(),
        refreshTokenUseCase: getIt(),
        authRepository: getIt(),
      ));

  // ── Store ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<StoreRemoteDataSource>(
    () => StoreRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetStoreListUseCase(getIt()));
  getIt.registerLazySingleton(() => GetStoreByIdUseCase(getIt()));
  getIt.registerFactory(() => StoreCubit(
        getStoreListUseCase: getIt(),
        getStoreByIdUseCase: getIt(),
      ));

  // ── CCTV ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<CCTVLocalDataSource>(
    () => CCTVLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<CCTVRemoteDataSource>(
    () => CCTVRemoteDataSourceImpl(httpClient: getIt()),
  );
  getIt.registerLazySingleton<CCTVRepository>(
    () => CCTVRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton(() => GetCCTVListUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCCTVByIdUseCase(getIt()));
  getIt.registerFactory(
    () => CCTVListCubit(getCCTVListUseCase: getIt()),
  );
  getIt.registerFactory(
    () => StreamingCubit(getCCTVByIdUseCase: getIt()),
  );

  // ── Alert ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<AlertRemoteDataSource>(
    () => AlertRemoteDataSourceImpl(httpClient: getIt()),
  );
  getIt.registerLazySingleton<AlertRepository>(
    () => AlertRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetAlertListUseCase(getIt()));
  getIt.registerLazySingleton(() => ResolveAlertUseCase(getIt()));
  getIt.registerFactory(() => AlertCubit(
        getAlertListUseCase: getIt(),
        resolveAlertUseCase: getIt(),
      ));

  // ── Analytics ─────────────────────────────────────────────────
  getIt.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetAnalyticsDashboardUseCase(getIt()));
  getIt.registerFactory(() => AnalyticsCubit(getIt()));

  // ── Traffic ───────────────────────────────────────────────────
  getIt.registerLazySingleton<TrafficRemoteDataSource>(
    () => TrafficRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TrafficRepository>(
    () => TrafficRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetTrafficSummaryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetRealtimeTrafficUseCase(getIt()));
  getIt.registerFactory(() => TrafficCubit(
        getTrafficSummary: getIt(),
        getRealtimeTraffic: getIt(),
      ));

  // ── Visitor ───────────────────────────────────────────────────
  getIt.registerLazySingleton<VisitorRemoteDataSource>(
    () => VisitorRemoteDataSourceImpl(httpClient: getIt()),
  );
  getIt.registerLazySingleton<VisitorRepository>(
    () => VisitorRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetVisitorListUseCase(getIt()));
  getIt.registerLazySingleton(() => GetVisitorDetailUseCase(getIt()));
  getIt.registerLazySingleton(() => GetMoodTimelineUseCase(getIt()));
  getIt.registerFactory(() => VisitorCubit(getVisitorListUseCase: getIt()));
  getIt.registerFactory(() => VisitorDetailCubit(
        getVisitorDetailUseCase: getIt(),
        getMoodTimelineUseCase: getIt(),
      ));

  // ── Statistics ────────────────────────────────────────────────
  getIt.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(httpClient: getIt()),
  );
  getIt.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetKpiUseCase(getIt()));
  getIt.registerLazySingleton(() => GetBehaviorUseCase(getIt()));
  getIt.registerFactory(() => StatisticsCubit(
        getKpiUseCase: getIt(),
        getBehaviorUseCase: getIt(),
      ));

  // ── Stream ────────────────────────────────────────────────────
  getIt.registerLazySingleton<StreamRemoteDataSource>(
    () => StreamRemoteDataSourceImpl(
      httpClient: getIt(),
      webSocketClient: getIt(),
    ),
  );
  getIt.registerLazySingleton<StreamRepository>(
    () => StreamRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetStreamStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => ControlStreamUseCase(getIt()));
  getIt.registerFactory(() => StreamStatusCubit(
        getStreamStatusUseCase: getIt(),
        controlStreamUseCase: getIt(),
        streamRepository: getIt(),
      ));
}
