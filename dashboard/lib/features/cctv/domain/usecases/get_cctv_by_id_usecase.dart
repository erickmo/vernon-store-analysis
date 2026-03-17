import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cctv_entity.dart';
import '../repositories/cctv_repository.dart';

/// Usecase untuk mendapatkan kamera berdasarkan ID.
class GetCCTVByIdUseCase {
  final CCTVRepository repository;

  const GetCCTVByIdUseCase(this.repository);

  /// Mendapatkan kamera dengan [cameraId] di dalam [storeId].
  Future<Either<Failure, CCTVEntity>> call(int storeId, int cameraId) {
    return repository.getCCTVById(storeId, cameraId);
  }
}
