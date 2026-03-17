import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/visitor_entity.dart';
import '../repositories/visitor_repository.dart';

/// Params untuk GetVisitorListUseCase.
class GetVisitorListParams {
  /// ID toko yang akan diambil daftar visitornya.
  final int storeId;

  const GetVisitorListParams({required this.storeId});
}

/// Usecase untuk mendapatkan daftar visitor dari suatu toko.
class GetVisitorListUseCase {
  final VisitorRepository repository;

  const GetVisitorListUseCase(this.repository);

  Future<Either<Failure, List<VisitorEntity>>> call(
    GetVisitorListParams params,
  ) {
    return repository.getVisitorList(params.storeId);
  }
}
