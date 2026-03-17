import '../../domain/entities/analytics_dashboard_entity.dart';

// ── Sub-models ────────────────────────────────────────────────────────────────

class GenderStatModel extends GenderStat {
  const GenderStatModel({required super.count, required super.percentage});

  factory GenderStatModel.fromJson(Map<String, dynamic> json) {
    return GenderStatModel(
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class GenderDistributionModel extends GenderDistribution {
  const GenderDistributionModel({
    required GenderStatModel super.male,
    required GenderStatModel super.female,
  });

  factory GenderDistributionModel.fromJson(Map<String, dynamic> json) {
    return GenderDistributionModel(
      male: GenderStatModel.fromJson(
          json['male'] as Map<String, dynamic>),
      female: GenderStatModel.fromJson(
          json['female'] as Map<String, dynamic>),
    );
  }
}

class AgeStatModel extends AgeStat {
  const AgeStatModel({required super.count, required super.percentage});

  factory AgeStatModel.fromJson(Map<String, dynamic> json) {
    return AgeStatModel(
      count: (json['count'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class AgeGroupsModel extends AgeGroups {
  const AgeGroupsModel({
    required AgeStatModel super.under18,
    required AgeStatModel super.age1825,
    required AgeStatModel super.age2635,
    required AgeStatModel super.age3650,
    required AgeStatModel super.over50,
  });

  factory AgeGroupsModel.fromJson(Map<String, dynamic> json) {
    return AgeGroupsModel(
      under18: AgeStatModel.fromJson(
          json['under_18'] as Map<String, dynamic>),
      age1825: AgeStatModel.fromJson(
          json['18_25'] as Map<String, dynamic>),
      age2635: AgeStatModel.fromJson(
          json['26_35'] as Map<String, dynamic>),
      age3650: AgeStatModel.fromJson(
          json['36_50'] as Map<String, dynamic>),
      over50: AgeStatModel.fromJson(
          json['over_50'] as Map<String, dynamic>),
    );
  }
}

class MoodSnapshotModel extends MoodSnapshot {
  const MoodSnapshotModel({
    required super.happy,
    required super.neutral,
    required super.sad,
    required super.angry,
    required super.surprised,
  });

  factory MoodSnapshotModel.fromJson(Map<String, dynamic> json) {
    return MoodSnapshotModel(
      happy: (json['happy'] as num).toDouble(),
      neutral: (json['neutral'] as num).toDouble(),
      sad: (json['sad'] as num).toDouble(),
      angry: (json['angry'] as num).toDouble(),
      surprised: (json['surprised'] as num).toDouble(),
    );
  }
}

class MoodDataModel extends MoodData {
  const MoodDataModel({
    required MoodSnapshotModel super.entry,
    required MoodSnapshotModel super.exit,
    required MoodSnapshotModel super.cashier,
    required MoodSnapshotModel super.floor,
  });

  factory MoodDataModel.fromJson(Map<String, dynamic> json) {
    return MoodDataModel(
      entry: MoodSnapshotModel.fromJson(
          json['entry'] as Map<String, dynamic>),
      exit: MoodSnapshotModel.fromJson(
          json['exit'] as Map<String, dynamic>),
      cashier: MoodSnapshotModel.fromJson(
          json['cashier'] as Map<String, dynamic>),
      floor: MoodSnapshotModel.fromJson(
          json['floor'] as Map<String, dynamic>),
    );
  }
}

class DwellTimeDataModel extends DwellTimeData {
  const DwellTimeDataModel({
    required super.avgDwellMinutes,
    required super.medianDwellMinutes,
    required super.maxDwellSeconds,
  });

  factory DwellTimeDataModel.fromJson(Map<String, dynamic> json) {
    return DwellTimeDataModel(
      avgDwellMinutes: (json['avg_dwell_minutes'] as num).toDouble(),
      medianDwellMinutes: (json['median_dwell_minutes'] as num).toDouble(),
      maxDwellSeconds: (json['max_dwell_seconds'] as num).toInt(),
    );
  }
}

class DwellDistributionModel extends DwellDistribution {
  const DwellDistributionModel({
    required super.under5min,
    required super.min515,
    required super.min1530,
    required super.min3060,
    required super.over60min,
  });

  factory DwellDistributionModel.fromJson(Map<String, dynamic> json) {
    return DwellDistributionModel(
      under5min: (json['under_5min'] as num).toInt(),
      min515: (json['5_15min'] as num).toInt(),
      min1530: (json['15_30min'] as num).toInt(),
      min3060: (json['30_60min'] as num).toInt(),
      over60min: (json['over_60min'] as num).toInt(),
    );
  }
}

class HourlyTrafficPointModel extends HourlyTrafficPoint {
  const HourlyTrafficPointModel({required super.hour, required super.count});

  factory HourlyTrafficPointModel.fromJson(Map<String, dynamic> json) {
    return HourlyTrafficPointModel(
      hour: (json['hour'] as num).toInt(),
      count: (json['count'] as num).toInt(),
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
      gender: GenderDistributionModel.fromJson(
          json['gender'] as Map<String, dynamic>),
      ageGroups: AgeGroupsModel.fromJson(
          json['age_groups'] as Map<String, dynamic>),
      mood: MoodDataModel.fromJson(json['mood'] as Map<String, dynamic>),
      dwellTime: DwellTimeDataModel.fromJson(
          json['dwell_time'] as Map<String, dynamic>),
      dwellDistribution: DwellDistributionModel.fromJson(
          json['dwell_distribution'] as Map<String, dynamic>),
      hourlyTraffic: (json['hourly_traffic'] as List<dynamic>)
          .map((e) =>
              HourlyTrafficPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
