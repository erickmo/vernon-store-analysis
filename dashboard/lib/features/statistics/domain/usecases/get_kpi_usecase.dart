import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/kpi_entity.dart';
import '../repositories/statistics_repository.dart';

/// Params untuk GetKpiUseCase.
class GetKpiParams {
  /// ID toko yang akan diambil data KPI-nya.
  final int storeId;

  const GetKpiParams({required this.storeId});
}

/// Usecase untuk mendapatkan data KPI suatu toko.
class GetKpiUseCase {
  final StatisticsRepository repository;

  const GetKpiUseCase(this.repository);

  Future<Either<Failure, KpiEntity>> call(GetKpiParams params) {
    return repository.getKpi(params.storeId);
  }
}
