import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cctv_entity.dart';
import '../repositories/cctv_repository.dart';

/// Usecase untuk mendapatkan daftar kamera berdasarkan store.
class GetCCTVListUseCase {
  final CCTVRepository repository;

  const GetCCTVListUseCase(this.repository);

  /// Mendapatkan daftar kamera milik [storeId].
  Future<Either<Failure, List<CCTVEntity>>> call(int storeId) {
    return repository.getCCTVList(storeId);
  }
}
