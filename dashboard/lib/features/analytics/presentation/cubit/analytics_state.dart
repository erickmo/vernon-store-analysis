import 'package:equatable/equatable.dart';

import '../../domain/entities/analytics_dashboard_entity.dart';

/// Sealed class manual untuk state analytics cubit.
sealed class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada aksi.
final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// State ketika data sedang dimuat.
final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

/// State ketika data berhasil dimuat.
final class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsDashboardEntity dashboard;

  const AnalyticsLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// State ketika terjadi kesalahan.
final class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
