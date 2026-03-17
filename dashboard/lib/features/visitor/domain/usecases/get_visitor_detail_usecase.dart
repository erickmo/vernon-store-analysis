import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/visit_entity.dart';
import '../entities/visitor_entity.dart';
import '../repositories/visitor_repository.dart';

/// Params untuk GetVisitorDetailUseCase.
class GetVisitorDetailParams {
  /// ID visitor yang akan diambil detailnya.
  final int visitorId;

  const GetVisitorDetailParams({required this.visitorId});
}

/// Usecase untuk mendapatkan detail visitor beserta riwayat kunjungannya.
class GetVisitorDetailUseCase {
  final VisitorRepository repository;

  const GetVisitorDetailUseCase(this.repository);

  Future<Either<Failure, ({VisitorEntity visitor, List<VisitEntity> visits})>>
  call(GetVisitorDetailParams params) {
    return repository.getVisitorDetail(params.visitorId);
  }
}
