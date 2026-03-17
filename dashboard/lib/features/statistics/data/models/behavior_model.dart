import '../../domain/entities/behavior_entity.dart';
import 'kpi_model.dart';

/// Model untuk ZoneFlowEntity.
class ZoneFlowModel extends ZoneFlowEntity {
  const ZoneFlowModel({
    required super.pattern,
    required super.count,
    required super.percentage,
  });

  factory ZoneFlowModel.fromJson(Map<String, dynamic> json) {
    return ZoneFlowModel(
      pattern: json['pattern'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  ZoneFlowEntity toEntity() => ZoneFlowEntity(
    pattern: pattern,
    count: count,
    percentage: percentage,
  );
}

/// Model untuk MoodShiftEntity.
class MoodShiftModel extends MoodShiftEntity {
  const MoodShiftModel({
    required super.improvedRate,
    required super.worsenedRate,
    required super.satisfactionScore,
  });

  factory MoodShiftModel.fromJson(Map<String, dynamic> json) {
    return MoodShiftModel(
      improvedRate: (json['improved_rate'] as num).toDouble(),
      worsenedRate: (json['worsened_rate'] as num).toDouble(),
      satisfactionScore: (json['satisfaction_score'] as num).toDouble(),
    );
  }

  MoodShiftEntity toEntity() => MoodShiftEntity(
    improvedRate: improvedRate,
    worsenedRate: worsenedRate,
    satisfactionScore: satisfactionScore,
  );
}

/// Model untuk ZoneHeatmapEntity.
class ZoneHeatmapModel extends ZoneHeatmapEntity {
  const ZoneHeatmapModel({
    required super.zone,
    required super.visitCount,
    required super.trafficShare,
  });

  factory ZoneHeatmapModel.fromJson(Map<String, dynamic> json) {
    return ZoneHeatmapModel(
      zone: json['zone'] as String,
      visitCount: json['visit_count'] as int,
      trafficShare: (json['traffic_share'] as num).toDouble(),
    );
  }

  ZoneHeatmapEntity toEntity() => ZoneHeatmapEntity(
    zone: zone,
    visitCount: visitCount,
    trafficShare: trafficShare,
  );
}

/// Model untuk PeakHourEntity.
class PeakHourModel extends PeakHourEntity {
  const PeakHourModel({
    required super.hour,
    required super.avgVisitors,
    required super.label,
  });

  factory PeakHourModel.fromJson(Map<String, dynamic> json) {
    return PeakHourModel(
      hour: json['hour'] as int,
      avgVisitors: (json['avg_visitors'] as num).toDouble(),
      label: json['label'] as String,
    );
  }

  PeakHourEntity toEntity() => PeakHourEntity(
    hour: hour,
    avgVisitors: avgVisitors,
    label: label,
  );
}

/// Model untuk BehaviorEntity yang memetakan JSON response API.
class BehaviorModel extends BehaviorEntity {
  const BehaviorModel({
    required super.storeId,
    required super.period,
    required super.zoneFlow,
    required super.moodShift,
    required super.zoneHeatmap,
    required super.peakHours,
  });

  /// Membuat BehaviorModel dari JSON response API.
  factory BehaviorModel.fromJson(Map<String, dynamic> json) {
    final zoneFlowList = (json['zone_flow'] as List<dynamic>)
        .map((item) => ZoneFlowModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final zoneHeatmapList = (json['zone_heatmap'] as List<dynamic>)
        .map(
          (item) => ZoneHeatmapModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final peakHoursList = (json['peak_hours'] as List<dynamic>)
        .map((item) => PeakHourModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return BehaviorModel(
      storeId: json['store_id'] as int,
      period: PeriodModel.fromJson(json['period'] as Map<String, dynamic>),
      zoneFlow: zoneFlowList,
      moodShift: MoodShiftModel.fromJson(
        json['mood_shift'] as Map<String, dynamic>,
      ),
      zoneHeatmap: zoneHeatmapList,
      peakHours: peakHoursList,
    );
  }

  /// Mengonversi model ke BehaviorEntity.
  BehaviorEntity toEntity() => BehaviorEntity(
    storeId: storeId,
    period: (period as PeriodModel).toEntity(),
    zoneFlow: zoneFlow
        .map((z) => (z as ZoneFlowModel).toEntity())
        .toList(),
    moodShift: (moodShift as MoodShiftModel).toEntity(),
    zoneHeatmap: zoneHeatmap
        .map((z) => (z as ZoneHeatmapModel).toEntity())
        .toList(),
    peakHours: peakHours
        .map((p) => (p as PeakHourModel).toEntity())
        .toList(),
  );
}
