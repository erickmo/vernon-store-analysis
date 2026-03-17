import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

/// Usecase untuk mendapatkan daftar shoplifting alert.
class GetAlertListUseCase {
  final AlertRepository repository;

  const GetAlertListUseCase(this.repository);

  /// Mendapatkan daftar alert untuk [storeId].
  Future<Either<Failure, List<AlertEntity>>> call(int storeId) {
    return repository.getAlertList(storeId);
  }
}
