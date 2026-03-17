import '../../domain/entities/analytics_dashboard_entity.dart';

// ── Sub-models ────────────────────────────────────────────────────────────────

class GenderItemModel extends GenderItem {
  const GenderItemModel({
    required super.gender,
    required super.count,
    required super.percentage,
  });

  factory GenderItemModel.fromJson(Map<String, dynamic> json) {
    return GenderItemModel(
      gender: json['gender'] as String,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class AgeGroupItemModel extends AgeGroupItem {
  const AgeGroupItemModel({
    required super.ageGroup,
    required super.count,
    required super.percentage,
    super.avgAge,
  });

  factory AgeGroupItemModel.fromJson(Map<String, dynamic> json) {
    return AgeGroupItemModel(
      ageGroup: json['age_group'] as String,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      avgAge: json['avg_age'] != null
          ? (json['avg_age'] as num).toDouble()
          : null,
    );
  }
}

class MoodItemModel extends MoodItem {
  const MoodItemModel({
    required super.mood,
    required super.count,
    required super.percentage,
    required super.avgConfidence,
  });

  factory MoodItemModel.fromJson(Map<String, dynamic> json) {
    return MoodItemModel(
      mood: json['mood'] as String,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      avgConfidence: (json['avg_confidence'] as num).toDouble(),
    );
  }
}

class MoodDataModel extends MoodData {
  const MoodDataModel({
    required super.entry,
    required super.exit,
    required super.cashier,
    required super.floor,
  });

  factory MoodDataModel.fromJson(Map<String, dynamic> json) {
    List<MoodItem> parseZone(dynamic zone) {
      if (zone == null) return [];
      return (zone as List<dynamic>)
          .map((e) => MoodItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return MoodDataModel(
      entry: parseZone(json['entry']),
      exit: parseZone(json['exit']),
      cashier: parseZone(json['cashier']),
      floor: parseZone(json['floor']),
    );
  }
}

class DwellTimeDataModel extends DwellTimeData {
  const DwellTimeDataModel({
    required super.totalVisits,
    required super.avgDwellSeconds,
    required super.minDwellSeconds,
    required super.maxDwellSeconds,
    required super.avgDwellMinutes,
  });

  factory DwellTimeDataModel.fromJson(Map<String, dynamic> json) {
    return DwellTimeDataModel(
      totalVisits: (json['total_visits'] as num).toInt(),
      avgDwellSeconds: (json['avg_dwell_seconds'] as num).toDouble(),
      minDwellSeconds: (json['min_dwell_seconds'] as num).toInt(),
      maxDwellSeconds: (json['max_dwell_seconds'] as num).toInt(),
      avgDwellMinutes: (json['avg_dwell_minutes'] as num).toDouble(),
    );
  }
}

class DwellBucketModel extends DwellBucket {
  const DwellBucketModel({
    required super.bucket,
    required super.count,
    required super.percentage,
  });

  factory DwellBucketModel.fromJson(Map<String, dynamic> json) {
    return DwellBucketModel(
      bucket: json['bucket'] as String,
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class HourlyTrafficPointModel extends HourlyTrafficPoint {
  const HourlyTrafficPointModel({
    required super.hour,
    required super.visitorCount,
  });

  factory HourlyTrafficPointModel.fromJson(Map<String, dynamic> json) {
    return HourlyTrafficPointModel(
      hour: json['hour'] as String,
      visitorCount: (json['visitor_count'] as num).toInt(),
    );
  }
}

// ── Root model ────────────────────────────────────────────────────────────────

/// Model JSON untuk [AnalyticsDashboardEntity].
class AnalyticsDashboardModel extends AnalyticsDashboardEntity {
  const AnalyticsDashboardModel({
    required super.storeId,
    required super.periodStart,
    required super.periodEnd,
    required super.summary,
    required super.gender,
    required super.ageGroups,
    required super.mood,
    required super.dwellTime,
    required super.dwellDistribution,
    required super.hourlyTraffic,
  });

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>;
    final summaryJson = json['summary'] as Map<String, dynamic>;

    return AnalyticsDashboardModel(
      storeId: (json['store_id'] as num).toInt(),
      periodStart: DateTime.parse(period['start'] as String),
      periodEnd: DateTime.parse(period['end'] as String),
      summary: AnalyticsSummary(
        totalVisitors: (summaryJson['total_visitors'] as num).toInt(),
        avgDwellMinutes: (summaryJson['avg_dwell_minutes'] as num).toDouble(),
        maxDwellMinutes: (summaryJson['max_dwell_minutes'] as num).toDouble(),
      ),
      gender: (json['gender'] as List<dynamic>)
          .map((e) => GenderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      ageGroups: (json['age_groups'] as List<dynamic>)
          .map((e) => AgeGroupItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mood: MoodDataModel.fromJson(json['mood'] as Map<String, dynamic>),
      dwellTime: DwellTimeDataModel.fromJson(
          json['dwell_time'] as Map<String, dynamic>),
      dwellDistribution: (json['dwell_distribution'] as List<dynamic>)
          .map((e) => DwellBucketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourlyTraffic: (json['hourly_traffic'] as List<dynamic>)
          .map((e) =>
              HourlyTrafficPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
