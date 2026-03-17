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

/// Stat per gender (count + percentage).
class GenderStat extends Equatable {
  final int count;
  final double percentage;

  const GenderStat({required this.count, required this.percentage});

  @override
  List<Object?> get props => [count, percentage];
}

/// Distribusi gender.
class GenderDistribution extends Equatable {
  final GenderStat male;
  final GenderStat female;

  const GenderDistribution({required this.male, required this.female});

  @override
  List<Object?> get props => [male, female];
}

/// Stat per kelompok usia.
class AgeStat extends Equatable {
  final int count;
  final double percentage;

  const AgeStat({required this.count, required this.percentage});

  @override
  List<Object?> get props => [count, percentage];
}

/// Distribusi kelompok usia.
class AgeGroups extends Equatable {
  final AgeStat under18;
  final AgeStat age1825;
  final AgeStat age2635;
  final AgeStat age3650;
  final AgeStat over50;

  const AgeGroups({
    required this.under18,
    required this.age1825,
    required this.age2635,
    required this.age3650,
    required this.over50,
  });

  @override
  List<Object?> get props => [under18, age1825, age2635, age3650, over50];
}

/// Snapshot mood di satu zona (persentase per ekspresi).
class MoodSnapshot extends Equatable {
  final double happy;
  final double neutral;
  final double sad;
  final double angry;
  final double surprised;

  const MoodSnapshot({
    required this.happy,
    required this.neutral,
    required this.sad,
    required this.angry,
    required this.surprised,
  });

  @override
  List<Object?> get props => [happy, neutral, sad, angry, surprised];
}

/// Mood di semua zona (entry, exit, cashier, floor).
class MoodData extends Equatable {
  final MoodSnapshot entry;
  final MoodSnapshot exit;
  final MoodSnapshot cashier;
  final MoodSnapshot floor;

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
  final double avgDwellMinutes;
  final double medianDwellMinutes;
  final int maxDwellSeconds;

  const DwellTimeData({
    required this.avgDwellMinutes,
    required this.medianDwellMinutes,
    required this.maxDwellSeconds,
  });

  @override
  List<Object?> get props =>
      [avgDwellMinutes, medianDwellMinutes, maxDwellSeconds];
}

/// Distribusi dwell time dalam bucket menit.
class DwellDistribution extends Equatable {
  final int under5min;
  final int min515;
  final int min1530;
  final int min3060;
  final int over60min;

  const DwellDistribution({
    required this.under5min,
    required this.min515,
    required this.min1530,
    required this.min3060,
    required this.over60min,
  });

  @override
  List<Object?> get props =>
      [under5min, min515, min1530, min3060, over60min];
}

/// Traffic per jam.
class HourlyTrafficPoint extends Equatable {
  final int hour;
  final int count;

  const HourlyTrafficPoint({required this.hour, required this.count});

  @override
  List<Object?> get props => [hour, count];
}

/// Entitas utama dashboard analitik.
class AnalyticsDashboardEntity extends Equatable {
  final int storeId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final AnalyticsSummary summary;
  final GenderDistribution gender;
  final AgeGroups ageGroups;
  final MoodData mood;
  final DwellTimeData dwellTime;
  final DwellDistribution dwellDistribution;
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
