import 'package:equatable/equatable.dart';

import '../../domain/entities/traffic_entity.dart';

/// Sealed class manual untuk state traffic cubit.
sealed class TrafficState extends Equatable {
  const TrafficState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada aksi.
final class TrafficInitial extends TrafficState {
  const TrafficInitial();
}

/// State ketika data sedang dimuat (summary dan/atau realtime).
final class TrafficLoading extends TrafficState {
  const TrafficLoading();
}

/// State ketika data berhasil dimuat.
final class TrafficLoaded extends TrafficState {
  final TrafficSummaryEntity summary;
  final RealtimeTrafficEntity? realtime;

  const TrafficLoaded({required this.summary, this.realtime});

  /// Salin state dengan realtime terbaru.
  TrafficLoaded copyWithRealtime(RealtimeTrafficEntity realtime) {
    return TrafficLoaded(summary: summary, realtime: realtime);
  }

  @override
  List<Object?> get props => [summary, realtime];
}

/// State ketika terjadi kesalahan.
final class TrafficError extends TrafficState {
  final String message;

  const TrafficError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State saat hanya realtime yang diperbarui (refresh ringan).
final class TrafficRealtimeRefreshing extends TrafficState {
  final TrafficSummaryEntity summary;
  final RealtimeTrafficEntity? previousRealtime;

  const TrafficRealtimeRefreshing({
    required this.summary,
    this.previousRealtime,
  });

  @override
  List<Object?> get props => [summary, previousRealtime];
}
