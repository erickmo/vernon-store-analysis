import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/stream_status_entity.dart';
import '../../domain/repositories/stream_repository.dart';
import '../datasources/stream_remote_datasource.dart';

/// Concrete implementation dari [StreamRepository].
class StreamRepositoryImpl implements StreamRepository {
  final StreamRemoteDataSource remoteDataSource;

  const StreamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StreamStatusEntity>> getStreamStatus() async {
    try {
      final model = await remoteDataSource.getStreamStatus();
      return Right(model.toEntity());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat status stream: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> startCamera(int cameraId) async {
    try {
      await remoteDataSource.startCamera(cameraId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Gagal memulai stream: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> stopCamera(int cameraId) async {
    try {
      await remoteDataSource.stopCamera(cameraId);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Gagal menghentikan stream: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> startAllStreams() async {
    try {
      await remoteDataSource.startAllStreams();
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure('Gagal memulai semua stream: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> stopAllStreams() async {
    try {
      await remoteDataSource.stopAllStreams();
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure('Gagal menghentikan semua stream: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<WsEvent> get wsEvents => remoteDataSource.wsEvents;

  @override
  Future<void> connectWebSocket() => remoteDataSource.connectWebSocket();

  @override
  Future<void> disconnectWebSocket() => remoteDataSource.disconnectWebSocket();
}
