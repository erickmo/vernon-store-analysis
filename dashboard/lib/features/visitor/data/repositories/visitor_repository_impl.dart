import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/mood_log_entity.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/entities/visitor_entity.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_remote_datasource.dart';

/// Implementasi konkret VisitorRepository.
class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDataSource remoteDataSource;

  const VisitorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<VisitorEntity>>> getVisitorList(
    int storeId,
  ) async {
    try {
      final models = await remoteDataSource.getVisitorList(storeId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({VisitorEntity visitor, List<VisitEntity> visits})>>
  getVisitorDetail(int visitorId) async {
    try {
      final result = await remoteDataSource.getVisitorDetail(visitorId);
      return Right((
        visitor: result.visitor.toEntity(),
        visits: result.visits.map((v) => v.toEntity()).toList(),
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MoodLogEntity>>> getMoodTimeline(
    int visitorId,
    int visitId,
  ) async {
    try {
      final models = await remoteDataSource.getMoodTimeline(
        visitorId,
        visitId,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
