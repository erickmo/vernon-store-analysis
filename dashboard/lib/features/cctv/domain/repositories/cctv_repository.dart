import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/behaviour_alert_entity.dart';
import '../entities/cctv_entity.dart';

/// Abstract repository untuk CCTV.
abstract class CCTVRepository {
  /// Mendapatkan daftar semua CCTV.
  Future<Either<Failure, List<CCTVEntity>>> getCCTVList();

  /// Mendapatkan CCTV berdasarkan ID.
  Future<Either<Failure, CCTVEntity>> getCCTVById(String id);

  /// Mendapatkan alerts untuk CCTV tertentu.
  Future<Either<Failure, List<BehaviourAlertEntity>>> getAlertsByCCTV(
    String cctvId,
  );
}
