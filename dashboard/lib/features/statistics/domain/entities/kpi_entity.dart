import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan ringkasan periode (start–end).
class PeriodEntity extends Equatable {
  final DateTime start;
  final DateTime end;

  const PeriodEntity({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

/// Entity untuk data konversi pengunjung ke kasir.
class ConversionEntity extends Equatable {
  final int totalVisitors;
  final int cashierVisitors;
  final double conversionRate;

  const ConversionEntity({
    required this.totalVisitors,
    required this.cashierVisitors,
    required this.conversionRate,
  });

  @override
  List<Object?> get props => [totalVisitors, cashierVisitors, conversionRate];
}

/// Entity untuk data bounce (pengunjung yang segera keluar).
class BounceEntity extends Equatable {
  final int totalVisitors;
  final int bounced;
  final double bounceRate;

  const BounceEntity({
    required this.totalVisitors,
    required this.bounced,
    required this.bounceRate,
  });

  @override
  List<Object?> get props => [totalVisitors, bounced, bounceRate];
}

/// Entity untuk data return visitor (pengunjung baru vs. balik).
class ReturnVisitorsEntity extends Equatable {
  final int total;
  final int newVisitors;
  final int returning;
  final double returnRate;

  const ReturnVisitorsEntity({
    required this.total,
    required this.newVisitors,
    required this.returning,
    required this.returnRate,
  });

  @override
  List<Object?> get props => [total, newVisitors, returning, returnRate];
}

/// Entity untuk ringkasan perubahan mood selama kunjungan.
class MoodShiftSummaryEntity extends Equatable {
  final double improved;
  final double worsened;
  final double same;

  const MoodShiftSummaryEntity({
    required this.improved,
    required this.worsened,
    required this.same,
  });

  @override
  List<Object?> get props => [improved, worsened, same];
}

/// Entity utama yang berisi semua KPI untuk suatu toko.
class KpiEntity extends Equatable {
  /// ID toko yang menjadi sumber data KPI.
  final int storeId;

  /// Periode data KPI.
  final PeriodEntity period;

  /// Total pengunjung dalam periode.
  final int totalVisitors;

  /// Persentase conversion rate.
  final double conversionRate;

  /// Persentase bounce rate.
  final double bounceRate;

  /// Persentase return visitor rate.
  final double returnVisitorRate;

  /// Skor kepuasan rata-rata (0–10).
  final double satisfactionScore;

  /// Data detail konversi.
  final ConversionEntity conversion;

  /// Data detail bounce.
  final BounceEntity bounce;

  /// Data detail return visitor.
  final ReturnVisitorsEntity returnVisitors;

  /// Ringkasan perubahan mood.
  final MoodShiftSummaryEntity moodShiftSummary;

  const KpiEntity({
    required this.storeId,
    required this.period,
    required this.totalVisitors,
    required this.conversionRate,
    required this.bounceRate,
    required this.returnVisitorRate,
    required this.satisfactionScore,
    required this.conversion,
    required this.bounce,
    required this.returnVisitors,
    required this.moodShiftSummary,
  });

  @override
  List<Object?> get props => [
    storeId,
    period,
    totalVisitors,
    conversionRate,
    bounceRate,
    returnVisitorRate,
    satisfactionScore,
    conversion,
    bounce,
    returnVisitors,
    moodShiftSummary,
  ];
}
