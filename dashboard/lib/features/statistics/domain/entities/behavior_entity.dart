import 'package:equatable/equatable.dart';

import 'kpi_entity.dart';

/// Entity yang merepresentasikan satu pola alur zona pengunjung.
class ZoneFlowEntity extends Equatable {
  /// Deskripsi pola alur (misal: "entry → floor → cashier → exit").
  final String pattern;

  /// Jumlah pengunjung yang mengikuti pola ini.
  final int count;

  /// Persentase pengunjung yang mengikuti pola ini.
  final double percentage;

  const ZoneFlowEntity({
    required this.pattern,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [pattern, count, percentage];
}

/// Entity untuk data mood shift pengunjung.
class MoodShiftEntity extends Equatable {
  /// Persentase pengunjung yang mood-nya membaik.
  final double improvedRate;

  /// Persentase pengunjung yang mood-nya memburuk.
  final double worsenedRate;

  /// Skor kepuasan rata-rata (0–10).
  final double satisfactionScore;

  const MoodShiftEntity({
    required this.improvedRate,
    required this.worsenedRate,
    required this.satisfactionScore,
  });

  @override
  List<Object?> get props => [improvedRate, worsenedRate, satisfactionScore];
}

/// Entity untuk data heatmap zona.
class ZoneHeatmapEntity extends Equatable {
  /// Nama zona.
  final String zone;

  /// Jumlah kunjungan ke zona ini.
  final int visitCount;

  /// Persentase traffic yang melewati zona ini.
  final double trafficShare;

  const ZoneHeatmapEntity({
    required this.zone,
    required this.visitCount,
    required this.trafficShare,
  });

  @override
  List<Object?> get props => [zone, visitCount, trafficShare];
}

/// Entity untuk data jam sibuk.
class PeakHourEntity extends Equatable {
  /// Jam dalam format 0–23.
  final int hour;

  /// Rata-rata jumlah pengunjung pada jam ini.
  final double avgVisitors;

  /// Label tampilan jam (misal: "14:00").
  final String label;

  const PeakHourEntity({
    required this.hour,
    required this.avgVisitors,
    required this.label,
  });

  @override
  List<Object?> get props => [hour, avgVisitors, label];
}

/// Entity utama yang berisi data customer behavior suatu toko.
class BehaviorEntity extends Equatable {
  /// ID toko yang menjadi sumber data behavior.
  final int storeId;

  /// Periode data behavior.
  final PeriodEntity period;

  /// Daftar pola alur zona yang paling umum.
  final List<ZoneFlowEntity> zoneFlow;

  /// Data perubahan mood selama kunjungan.
  final MoodShiftEntity moodShift;

  /// Data heatmap tiap zona.
  final List<ZoneHeatmapEntity> zoneHeatmap;

  /// Data distribusi pengunjung per jam.
  final List<PeakHourEntity> peakHours;

  const BehaviorEntity({
    required this.storeId,
    required this.period,
    required this.zoneFlow,
    required this.moodShift,
    required this.zoneHeatmap,
    required this.peakHours,
  });

  @override
  List<Object?> get props => [
    storeId,
    period,
    zoneFlow,
    moodShift,
    zoneHeatmap,
    peakHours,
  ];
}
