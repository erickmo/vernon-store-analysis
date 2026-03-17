import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cctv_entity.dart';
import '../repositories/cctv_repository.dart';

/// Usecase untuk mendapatkan daftar CCTV.
class GetCCTVListUseCase {
  final CCTVRepository repository;

  const GetCCTVListUseCase(this.repository);

  /// Mendapatkan daftar CCTV.
  Future<Either<Failure, List<CCTVEntity>>> call() {
    return repository.getCCTVList();
  }
}
