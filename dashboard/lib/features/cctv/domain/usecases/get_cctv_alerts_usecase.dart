import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/behaviour_alert_entity.dart';
import '../repositories/cctv_repository.dart';

/// Usecase untuk mendapatkan alerts berdasarkan CCTV.
class GetCCTVAlertsUseCase {
  final CCTVRepository repository;

  const GetCCTVAlertsUseCase(this.repository);

  /// Mendapatkan alerts untuk CCTV tertentu.
  Future<Either<Failure, List<BehaviourAlertEntity>>> call(String cctvId) {
    return repository.getAlertsByCCTV(cctvId);
  }
}
