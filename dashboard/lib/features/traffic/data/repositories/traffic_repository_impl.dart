import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/traffic_entity.dart';
import '../../domain/repositories/traffic_repository.dart';
import '../datasources/traffic_remote_datasource.dart';

/// Implementasi [TrafficRepository].
class TrafficRepositoryImpl implements TrafficRepository {
  final TrafficRemoteDataSource _remoteDataSource;

  const TrafficRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, TrafficSummaryEntity>> getTrafficSummary(
      int storeId) async {
    try {
      final model = await _remoteDataSource.getTrafficSummary(storeId);
      return Right(model);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, RealtimeTrafficEntity>> getRealtimeTraffic(
      int storeId) async {
    try {
      final model = await _remoteDataSource.getRealtimeTraffic(storeId);
      return Right(model);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
