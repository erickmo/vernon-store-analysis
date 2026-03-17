import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cctv_entity.dart';
import '../repositories/cctv_repository.dart';

/// Usecase untuk mendapatkan CCTV berdasarkan ID.
class GetCCTVByIdUseCase {
  final CCTVRepository repository;

  const GetCCTVByIdUseCase(this.repository);

  /// Mendapatkan CCTV berdasarkan ID.
  Future<Either<Failure, CCTVEntity>> call(String id) {
    return repository.getCCTVById(id);
  }
}
