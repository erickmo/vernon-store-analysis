import 'package:equatable/equatable.dart';

/// Satu snapshot traffic pada waktu tertentu.
class TrafficSnapshotEntity extends Equatable {
  final int id;
  final int storeId;
  final DateTime timestamp;
  final int visitorCount;
  final double avgDwellSeconds;
  final int peakCount;

  const TrafficSnapshotEntity({
    required this.id,
    required this.storeId,
    required this.timestamp,
    required this.visitorCount,
    required this.avgDwellSeconds,
    required this.peakCount,
  });

  @override
  List<Object?> get props =>
      [id, storeId, timestamp, visitorCount, avgDwellSeconds, peakCount];
}

/// Ringkasan traffic periode tertentu beserta daftar snapshot.
class TrafficSummaryEntity extends Equatable {
  final int storeId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalVisitors;
  final double avgDwellSeconds;
  final int peakVisitorCount;
  final List<TrafficSnapshotEntity> snapshots;

  const TrafficSummaryEntity({
    required this.storeId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalVisitors,
    required this.avgDwellSeconds,
    required this.peakVisitorCount,
    required this.snapshots,
  });

  @override
  List<Object?> get props => [
        storeId,
        periodStart,
        periodEnd,
        totalVisitors,
        avgDwellSeconds,
        peakVisitorCount,
        snapshots,
      ];
}

/// Data traffic realtime (jumlah pengunjung saat ini).
class RealtimeTrafficEntity extends Equatable {
  final int storeId;
  final int currentVisitorCount;
  final DateTime timestamp;

  const RealtimeTrafficEntity({
    required this.storeId,
    required this.currentVisitorCount,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [storeId, currentVisitorCount, timestamp];
}
