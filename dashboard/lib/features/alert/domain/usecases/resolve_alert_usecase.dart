import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/alert_repository.dart';

/// Usecase untuk menyelesaikan shoplifting alert.
class ResolveAlertUseCase {
  final AlertRepository repository;

  const ResolveAlertUseCase(this.repository);

  /// Menyelesaikan alert [alertId] dengan [note].
  Future<Either<Failure, void>> call(int alertId, String note) {
    return repository.resolveAlert(alertId, note);
  }
}
