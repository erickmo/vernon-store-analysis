import 'package:equatable/equatable.dart';

import '../../domain/entities/behavior_entity.dart';
import '../../domain/entities/kpi_entity.dart';

/// Base sealed class untuk state statistics.
sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum data dimuat.
final class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

/// State saat sedang memuat data KPI.
final class StatisticsKpiLoading extends StatisticsState {
  const StatisticsKpiLoading();
}

/// State saat sedang memuat data behavior.
final class StatisticsBehaviorLoading extends StatisticsState {
  const StatisticsBehaviorLoading();
}

/// State saat sedang memuat KPI dan behavior secara bersamaan.
final class StatisticsAllLoading extends StatisticsState {
  const StatisticsAllLoading();
}

/// State saat data berhasil dimuat (KPI dan/atau behavior tersedia).
final class StatisticsLoaded extends StatisticsState {
  /// Data KPI. Null jika belum dimuat.
  final KpiEntity? kpi;

  /// Data behavior. Null jika belum dimuat.
  final BehaviorEntity? behavior;

  const StatisticsLoaded({this.kpi, this.behavior});

  StatisticsLoaded copyWith({
    KpiEntity? kpi,
    BehaviorEntity? behavior,
  }) {
    return StatisticsLoaded(
      kpi: kpi ?? this.kpi,
      behavior: behavior ?? this.behavior,
    );
  }

  @override
  List<Object?> get props => [kpi, behavior];
}

/// State saat terjadi error.
final class StatisticsError extends StatisticsState {
  /// Pesan error yang terjadi.
  final String message;

  const StatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}
