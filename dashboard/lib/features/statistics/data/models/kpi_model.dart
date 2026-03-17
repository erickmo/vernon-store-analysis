import '../../domain/entities/kpi_entity.dart';

/// Model untuk PeriodEntity.
class PeriodModel extends PeriodEntity {
  const PeriodModel({required super.start, required super.end});

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }

  PeriodEntity toEntity() => PeriodEntity(start: start, end: end);
}

/// Model untuk ConversionEntity.
class ConversionModel extends ConversionEntity {
  const ConversionModel({
    required super.totalVisitors,
    required super.cashierVisitors,
    required super.conversionRate,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) {
    return ConversionModel(
      totalVisitors: json['total_visitors'] as int,
      cashierVisitors: json['cashier_visitors'] as int,
      conversionRate: (json['conversion_rate'] as num).toDouble(),
    );
  }

  ConversionEntity toEntity() => ConversionEntity(
    totalVisitors: totalVisitors,
    cashierVisitors: cashierVisitors,
    conversionRate: conversionRate,
  );
}

/// Model untuk BounceEntity.
class BounceModel extends BounceEntity {
  const BounceModel({
    required super.totalVisitors,
    required super.bounced,
    required super.bounceRate,
  });

  factory BounceModel.fromJson(Map<String, dynamic> json) {
    return BounceModel(
      totalVisitors: json['total_visitors'] as int,
      bounced: json['bounced'] as int,
      bounceRate: (json['bounce_rate'] as num).toDouble(),
    );
  }

  BounceEntity toEntity() => BounceEntity(
    totalVisitors: totalVisitors,
    bounced: bounced,
    bounceRate: bounceRate,
  );
}

/// Model untuk ReturnVisitorsEntity.
class ReturnVisitorsModel extends ReturnVisitorsEntity {
  const ReturnVisitorsModel({
    required super.total,
    required super.newVisitors,
    required super.returning,
    required super.returnRate,
  });

  factory ReturnVisitorsModel.fromJson(Map<String, dynamic> json) {
    return ReturnVisitorsModel(
      total: json['total'] as int,
      newVisitors: json['new'] as int,
      returning: json['returning'] as int,
      returnRate: (json['return_rate'] as num).toDouble(),
    );
  }

  ReturnVisitorsEntity toEntity() => ReturnVisitorsEntity(
    total: total,
    newVisitors: newVisitors,
    returning: returning,
    returnRate: returnRate,
  );
}

/// Model untuk MoodShiftSummaryEntity.
class MoodShiftSummaryModel extends MoodShiftSummaryEntity {
  const MoodShiftSummaryModel({
    required super.improved,
    required super.worsened,
    required super.same,
  });

  factory MoodShiftSummaryModel.fromJson(Map<String, dynamic> json) {
    return MoodShiftSummaryModel(
      improved: (json['improved'] as num).toDouble(),
      worsened: (json['worsened'] as num).toDouble(),
      same: (json['same'] as num).toDouble(),
    );
  }

  MoodShiftSummaryEntity toEntity() => MoodShiftSummaryEntity(
    improved: improved,
    worsened: worsened,
    same: same,
  );
}

/// Model untuk KpiEntity yang memetakan JSON response API.
class KpiModel extends KpiEntity {
  const KpiModel({
    required super.storeId,
    required super.period,
    required super.totalVisitors,
    required super.conversionRate,
    required super.bounceRate,
    required super.returnVisitorRate,
    required super.satisfactionScore,
    required super.conversion,
    required super.bounce,
    required super.returnVisitors,
    required super.moodShiftSummary,
  });

  /// Membuat KpiModel dari JSON response API.
  factory KpiModel.fromJson(Map<String, dynamic> json) {
    final kpi = json['kpi'] as Map<String, dynamic>;

    return KpiModel(
      storeId: json['store_id'] as int,
      period: PeriodModel.fromJson(json['period'] as Map<String, dynamic>),
      totalVisitors: kpi['total_visitors'] as int,
      conversionRate: (kpi['conversion_rate'] as num).toDouble(),
      bounceRate: (kpi['bounce_rate'] as num).toDouble(),
      returnVisitorRate: (kpi['return_visitor_rate'] as num).toDouble(),
      satisfactionScore: (kpi['satisfaction_score'] as num).toDouble(),
      conversion: ConversionModel.fromJson(
        json['conversion'] as Map<String, dynamic>,
      ),
      bounce: BounceModel.fromJson(json['bounce'] as Map<String, dynamic>),
      returnVisitors: ReturnVisitorsModel.fromJson(
        json['return_visitors'] as Map<String, dynamic>,
      ),
      moodShiftSummary: MoodShiftSummaryModel.fromJson(
        json['mood_shift_summary'] as Map<String, dynamic>,
      ),
    );
  }

  /// Mengonversi model ke KpiEntity.
  KpiEntity toEntity() => KpiEntity(
    storeId: storeId,
    period: (period as PeriodModel).toEntity(),
    totalVisitors: totalVisitors,
    conversionRate: conversionRate,
    bounceRate: bounceRate,
    returnVisitorRate: returnVisitorRate,
    satisfactionScore: satisfactionScore,
    conversion: (conversion as ConversionModel).toEntity(),
    bounce: (bounce as BounceModel).toEntity(),
    returnVisitors: (returnVisitors as ReturnVisitorsModel).toEntity(),
    moodShiftSummary: (moodShiftSummary as MoodShiftSummaryModel).toEntity(),
  );
}
