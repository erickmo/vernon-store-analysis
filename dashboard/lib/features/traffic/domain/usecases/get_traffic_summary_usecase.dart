import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/traffic_entity.dart';
import '../repositories/traffic_repository.dart';

/// Use case untuk mengambil ringkasan traffic.
class GetTrafficSummaryUseCase {
  final TrafficRepository _repository;

  const GetTrafficSummaryUseCase(this._repository);

  /// Eksekusi use case dengan parameter [storeId].
  Future<Either<Failure, TrafficSummaryEntity>> call(int storeId) {
    return _repository.getTrafficSummary(storeId);
  }
}
