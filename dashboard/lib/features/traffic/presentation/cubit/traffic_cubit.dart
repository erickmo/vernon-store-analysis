import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_realtime_traffic_usecase.dart';
import '../../domain/usecases/get_traffic_summary_usecase.dart';
import 'traffic_state.dart';

/// Cubit untuk mengelola state halaman traffic.
class TrafficCubit extends Cubit<TrafficState> {
  final GetTrafficSummaryUseCase _getTrafficSummary;
  final GetRealtimeTrafficUseCase _getRealtimeTraffic;

  TrafficCubit({
    required GetTrafficSummaryUseCase getTrafficSummary,
    required GetRealtimeTrafficUseCase getRealtimeTraffic,
  })  : _getTrafficSummary = getTrafficSummary,
        _getRealtimeTraffic = getRealtimeTraffic,
        super(const TrafficInitial());

  /// Memuat ringkasan traffic dan data realtime sekaligus.
  Future<void> loadTraffic(int storeId) async {
    emit(const TrafficLoading());

    final summaryResult = await _getTrafficSummary(storeId);

    summaryResult.fold(
      (failure) => emit(TrafficError(failure.message)),
      (summary) async {
        // Emit loaded dengan summary dulu, realtime menyusul.
        emit(TrafficLoaded(summary: summary));

        final realtimeResult = await _getRealtimeTraffic(storeId);
        realtimeResult.fold(
          (_) {
            // Realtime gagal tapi summary sudah ada — tetap tampil.
          },
          (realtime) => emit(TrafficLoaded(summary: summary, realtime: realtime)),
        );
      },
    );
  }

  /// Memperbarui hanya data realtime tanpa reload summary.
  Future<void> refreshRealtime(int storeId) async {
    final currentState = state;
    if (currentState is! TrafficLoaded) return;

    emit(TrafficRealtimeRefreshing(
      summary: currentState.summary,
      previousRealtime: currentState.realtime,
    ));

    final result = await _getRealtimeTraffic(storeId);
    result.fold(
      (failure) => emit(TrafficLoaded(
        summary: currentState.summary,
        realtime: currentState.realtime,
      )),
      (realtime) => emit(TrafficLoaded(
        summary: currentState.summary,
        realtime: realtime,
      )),
    );
  }
}
