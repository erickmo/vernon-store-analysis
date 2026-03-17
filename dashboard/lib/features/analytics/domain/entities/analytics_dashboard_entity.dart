import 'package:equatable/equatable.dart';

/// Ringkasan utama periode analitik.
class AnalyticsSummary extends Equatable {
  final int totalVisitors;
  final double avgDwellMinutes;
  final double maxDwellMinutes;

  const AnalyticsSummary({
    required this.totalVisitors,
    required this.avgDwellMinutes,
    required this.maxDwellMinutes,
  });

  @override
  List<Object?> get props => [totalVisitors, avgDwellMinutes, maxDwellMinutes];
}

/// Satu item gender (misal: male 75, 50%).
class GenderItem extends Equatable {
  final String gender;
  final int count;
  final double percentage;

  const GenderItem({
    required this.gender,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [gender, count, percentage];
}

/// Satu item kelompok usia.
class AgeGroupItem extends Equatable {
  final String ageGroup;
  final int count;
  final double percentage;
  final double? avgAge;

  const AgeGroupItem({
    required this.ageGroup,
    required this.count,
    required this.percentage,
    this.avgAge,
  });

  @override
  List<Object?> get props => [ageGroup, count, percentage, avgAge];
}

/// Satu item mood di suatu zona (misal: happy 52, 34.7%).
class MoodItem extends Equatable {
  final String mood;
  final int count;
  final double percentage;
  final double avgConfidence;

  const MoodItem({
    required this.mood,
    required this.count,
    required this.percentage,
    required this.avgConfidence,
  });

  @override
  List<Object?> get props => [mood, count, percentage, avgConfidence];
}

/// Mood di semua zona (entry, exit, cashier, floor).
class MoodData extends Equatable {
  final List<MoodItem> entry;
  final List<MoodItem> exit;
  final List<MoodItem> cashier;
  final List<MoodItem> floor;

  const MoodData({
    required this.entry,
    required this.exit,
    required this.cashier,
    required this.floor,
  });

  @override
  List<Object?> get props => [entry, exit, cashier, floor];
}

/// Data dwell time agregat.
class DwellTimeData extends Equatable {
  final int totalVisits;
  final double avgDwellSeconds;
  final int minDwellSeconds;
  final int maxDwellSeconds;
  final double avgDwellMinutes;

  const DwellTimeData({
    required this.totalVisits,
    required this.avgDwellSeconds,
    required this.minDwellSeconds,
    required this.maxDwellSeconds,
    required this.avgDwellMinutes,
  });

  @override
  List<Object?> get props => [
        totalVisits,
        avgDwellSeconds,
        minDwellSeconds,
        maxDwellSeconds,
        avgDwellMinutes,
      ];
}

/// Satu bucket distribusi dwell time.
class DwellBucket extends Equatable {
  final String bucket;
  final int count;
  final double percentage;

  const DwellBucket({
    required this.bucket,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [bucket, count, percentage];
}

/// Traffic per jam.
class HourlyTrafficPoint extends Equatable {
  final String hour;
  final int visitorCount;

  const HourlyTrafficPoint({required this.hour, required this.visitorCount});

  @override
  List<Object?> get props => [hour, visitorCount];
}

/// Entitas utama dashboard analitik.
class AnalyticsDashboardEntity extends Equatable {
  final int storeId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final AnalyticsSummary summary;
  final List<GenderItem> gender;
  final List<AgeGroupItem> ageGroups;
  final MoodData mood;
  final DwellTimeData dwellTime;
  final List<DwellBucket> dwellDistribution;
  final List<HourlyTrafficPoint> hourlyTraffic;

  const AnalyticsDashboardEntity({
    required this.storeId,
    required this.periodStart,
    required this.periodEnd,
    required this.summary,
    required this.gender,
    required this.ageGroups,
    required this.mood,
    required this.dwellTime,
    required this.dwellDistribution,
    required this.hourlyTraffic,
  });

  @override
  List<Object?> get props => [
        storeId,
        periodStart,
        periodEnd,
        summary,
        gender,
        ageGroups,
        mood,
        dwellTime,
        dwellDistribution,
        hourlyTraffic,
      ];
}
