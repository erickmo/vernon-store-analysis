import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cctv_entity.dart';

/// Abstract repository untuk CCTV.
abstract class CCTVRepository {
  /// Mendapatkan daftar semua kamera dari API.
  Future<Either<Failure, List<CCTVEntity>>> getCCTVList(int storeId);

  /// Mendapatkan kamera berdasarkan ID.
  Future<Either<Failure, CCTVEntity>> getCCTVById(int storeId, int cameraId);
}
