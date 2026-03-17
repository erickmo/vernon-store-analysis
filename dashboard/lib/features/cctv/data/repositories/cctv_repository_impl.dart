import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/behaviour_alert_entity.dart';
import '../../domain/entities/cctv_entity.dart';
import '../../domain/repositories/cctv_repository.dart';
import '../datasources/cctv_local_datasource.dart';

/// Concrete implementation dari CCTVRepository.
class CCTVRepositoryImpl implements CCTVRepository {
  final CCTVLocalDataSource localDataSource;

  const CCTVRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CCTVEntity>>> getCCTVList() async {
    try {
      final models = await localDataSource.getCCTVList();
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Failed to load CCTV list: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CCTVEntity>> getCCTVById(String id) async {
    try {
      final model = await localDataSource.getCCTVById(id);
      if (model == null) {
        return Left(CacheFailure('CCTV dengan ID $id tidak ditemukan'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to load CCTV: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BehaviourAlertEntity>>> getAlertsByCCTV(
    String cctvId,
  ) async {
    try {
      final models = await localDataSource.getAlertsByCCTV(cctvId);
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(
        CacheFailure('Failed to load alerts for CCTV: ${e.toString()}'),
      );
    }
  }
}
