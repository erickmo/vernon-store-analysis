import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/behavior_entity.dart';
import '../../domain/entities/kpi_entity.dart';
import '../../domain/usecases/get_behavior_usecase.dart';
import '../../domain/usecases/get_kpi_usecase.dart';
import 'statistics_state.dart';

/// Cubit untuk mengelola state statistik toko (KPI dan customer behavior).
class StatisticsCubit extends Cubit<StatisticsState> {
  final GetKpiUseCase getKpiUseCase;
  final GetBehaviorUseCase getBehaviorUseCase;

  StatisticsCubit({
    required this.getKpiUseCase,
    required this.getBehaviorUseCase,
  }) : super(const StatisticsInitial());

  /// Memuat KPI dan behavior secara paralel.
  Future<void> loadAll(int storeId) async {
    emit(const StatisticsAllLoading());

    final kpiResult = await getKpiUseCase(GetKpiParams(storeId: storeId));
    final behaviorResult =
        await getBehaviorUseCase(GetBehaviorParams(storeId: storeId));

    String? errorMessage;

    final kpiOrNull = kpiResult.fold<KpiEntity?>(
      (failure) {
        errorMessage = failure.message;
        return null;
      },
      (kpi) => kpi,
    );

    final behaviorOrNull = behaviorResult.fold<BehaviorEntity?>(
      (failure) {
        errorMessage ??= failure.message;
        return null;
      },
      (behavior) => behavior,
    );

    if (kpiOrNull == null && behaviorOrNull == null) {
      emit(StatisticsError(message: errorMessage!));
    } else {
      emit(StatisticsLoaded(kpi: kpiOrNull, behavior: behaviorOrNull));
    }
  }

  /// Memuat hanya data KPI.
  Future<void> loadKpi(int storeId) async {
    final currentLoaded = state is StatisticsLoaded
        ? state as StatisticsLoaded
        : null;

    emit(const StatisticsKpiLoading());

    final result = await getKpiUseCase(GetKpiParams(storeId: storeId));

    result.fold(
      (failure) => emit(StatisticsError(message: failure.message)),
      (kpi) => emit(
        StatisticsLoaded(kpi: kpi, behavior: currentLoaded?.behavior),
      ),
    );
  }

  /// Memuat hanya data customer behavior.
  Future<void> loadBehavior(int storeId) async {
    final currentLoaded = state is StatisticsLoaded
        ? state as StatisticsLoaded
        : null;

    emit(const StatisticsBehaviorLoading());

    final result = await getBehaviorUseCase(
      GetBehaviorParams(storeId: storeId),
    );

    result.fold(
      (failure) => emit(StatisticsError(message: failure.message)),
      (behavior) => emit(
        StatisticsLoaded(kpi: currentLoaded?.kpi, behavior: behavior),
      ),
    );
  }
}
