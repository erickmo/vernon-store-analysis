import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';

/// Concrete implementation dari [AlertRepository].
class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource remoteDataSource;

  const AlertRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AlertEntity>>> getAlertList(int storeId) async {
    try {
      final models = await remoteDataSource.getAlertList(storeId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat daftar alert: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveAlert(int alertId, String note) async {
    try {
      await remoteDataSource.resolveAlert(alertId, note);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Gagal menyelesaikan alert: ${e.toString()}'));
    }
  }
}
