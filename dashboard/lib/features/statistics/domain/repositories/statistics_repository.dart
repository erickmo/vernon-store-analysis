import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/behavior_entity.dart';
import '../entities/kpi_entity.dart';

/// Contract untuk StatisticsRepository.
abstract class StatisticsRepository {
  /// Mengambil data KPI untuk suatu toko.
  Future<Either<Failure, KpiEntity>> getKpi(int storeId);

  /// Mengambil data customer behavior untuk suatu toko.
  Future<Either<Failure, BehaviorEntity>> getBehavior(int storeId);
}
