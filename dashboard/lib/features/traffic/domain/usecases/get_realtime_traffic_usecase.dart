import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/traffic_entity.dart';
import '../repositories/traffic_repository.dart';

/// Use case untuk mengambil data traffic realtime.
class GetRealtimeTrafficUseCase {
  final TrafficRepository _repository;

  const GetRealtimeTrafficUseCase(this._repository);

  /// Eksekusi use case dengan parameter [storeId].
  Future<Either<Failure, RealtimeTrafficEntity>> call(int storeId) {
    return _repository.getRealtimeTraffic(storeId);
  }
}
