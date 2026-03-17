import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_analytics_dashboard_usecase.dart';
import 'analytics_state.dart';

/// Cubit untuk mengelola state dashboard analitik.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetAnalyticsDashboardUseCase _getDashboard;

  AnalyticsCubit(this._getDashboard) : super(const AnalyticsInitial());

  /// Memuat data dashboard analitik untuk [storeId].
  Future<void> loadDashboard(int storeId) async {
    emit(const AnalyticsLoading());

    final result = await _getDashboard(storeId);

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (dashboard) => emit(AnalyticsLoaded(dashboard)),
    );
  }
}
