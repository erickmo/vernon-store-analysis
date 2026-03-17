import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/analytics_dashboard_entity.dart';
import '../repositories/analytics_repository.dart';

/// Use case untuk mengambil data dashboard analitik.
class GetAnalyticsDashboardUseCase {
  final AnalyticsRepository _repository;

  const GetAnalyticsDashboardUseCase(this._repository);

  /// Eksekusi use case dengan parameter [storeId].
  Future<Either<Failure, AnalyticsDashboardEntity>> call(int storeId) {
    return _repository.getDashboard(storeId);
  }
}
