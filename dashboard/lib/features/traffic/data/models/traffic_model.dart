import '../../domain/entities/traffic_entity.dart';

/// Model JSON untuk [TrafficSnapshotEntity].
class TrafficSnapshotModel extends TrafficSnapshotEntity {
  const TrafficSnapshotModel({
    required super.id,
    required super.storeId,
    required super.timestamp,
    required super.visitorCount,
    required super.avgDwellSeconds,
    required super.peakCount,
  });

  factory TrafficSnapshotModel.fromJson(Map<String, dynamic> json) {
    return TrafficSnapshotModel(
      id: (json['id'] as num).toInt(),
      storeId: (json['store_id'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      visitorCount: (json['visitor_count'] as num).toInt(),
      avgDwellSeconds: (json['avg_dwell_seconds'] as num).toDouble(),
      peakCount: (json['peak_count'] as num).toInt(),
    );
  }
}

/// Model JSON untuk [TrafficSummaryEntity].
class TrafficSummaryModel extends TrafficSummaryEntity {
  const TrafficSummaryModel({
    required super.storeId,
    required super.periodStart,
    required super.periodEnd,
    required super.totalVisitors,
    required super.avgDwellSeconds,
    required super.peakVisitorCount,
    required super.snapshots,
  });

  factory TrafficSummaryModel.fromJson(Map<String, dynamic> json) {
    final snapshotList = (json['snapshots'] as List<dynamic>? ?? [])
        .map((e) =>
            TrafficSnapshotModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TrafficSummaryModel(
      storeId: (json['store_id'] as num).toInt(),
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalVisitors: (json['total_visitors'] as num).toInt(),
      avgDwellSeconds: (json['avg_dwell_seconds'] as num).toDouble(),
      peakVisitorCount: (json['peak_visitor_count'] as num).toInt(),
      snapshots: snapshotList,
    );
  }
}

/// Model JSON untuk [RealtimeTrafficEntity].
class RealtimeTrafficModel extends RealtimeTrafficEntity {
  const RealtimeTrafficModel({
    required super.storeId,
    required super.currentVisitorCount,
    required super.timestamp,
  });

  factory RealtimeTrafficModel.fromJson(Map<String, dynamic> json) {
    return RealtimeTrafficModel(
      storeId: (json['store_id'] as num).toInt(),
      currentVisitorCount: (json['current_visitor_count'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
