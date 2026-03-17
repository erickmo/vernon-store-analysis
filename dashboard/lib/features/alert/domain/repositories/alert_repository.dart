import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/alert_entity.dart';

/// Abstract repository untuk shoplifting alert.
abstract class AlertRepository {
  /// Mendapatkan daftar alert untuk toko tertentu.
  Future<Either<Failure, List<AlertEntity>>> getAlertList(int storeId);

  /// Menyelesaikan alert dengan catatan.
  Future<Either<Failure, void>> resolveAlert(int alertId, String note);
}
