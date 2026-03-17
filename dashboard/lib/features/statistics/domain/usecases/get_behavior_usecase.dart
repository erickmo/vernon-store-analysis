import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/behavior_entity.dart';
import '../repositories/statistics_repository.dart';

/// Params untuk GetBehaviorUseCase.
class GetBehaviorParams {
  /// ID toko yang akan diambil data behavior-nya.
  final int storeId;

  const GetBehaviorParams({required this.storeId});
}

/// Usecase untuk mendapatkan data customer behavior suatu toko.
class GetBehaviorUseCase {
  final StatisticsRepository repository;

  const GetBehaviorUseCase(this.repository);

  Future<Either<Failure, BehaviorEntity>> call(GetBehaviorParams params) {
    return repository.getBehavior(params.storeId);
  }
}
