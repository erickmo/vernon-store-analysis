import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cctv_entity.dart';
import '../../domain/repositories/cctv_repository.dart';
import '../datasources/cctv_local_datasource.dart';
import '../datasources/cctv_remote_datasource.dart';

/// Concrete implementation dari [CCTVRepository].
///
/// Menggunakan remote datasource sebagai sumber utama.
/// Jika remote gagal, fallback ke local datasource.
class CCTVRepositoryImpl implements CCTVRepository {
  final CCTVRemoteDataSource remoteDataSource;
  final CCTVLocalDataSource localDataSource;

  const CCTVRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<CCTVEntity>>> getCCTVList(int storeId) async {
    try {
      final models = await remoteDataSource.getCCTVList(storeId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      try {
        final models = await localDataSource.getCCTVList();
        return Right(models.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure('Gagal memuat daftar kamera: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, CCTVEntity>> getCCTVById(
    int storeId,
    int cameraId,
  ) async {
    try {
      final model = await remoteDataSource.getCCTVById(storeId, cameraId);
      return Right(model.toEntity());
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      try {
        final model = await localDataSource.getCCTVById(cameraId);
        if (model == null) {
          return Left(
            NotFoundFailure('Kamera dengan ID $cameraId tidak ditemukan'),
          );
        }
        return Right(model.toEntity());
      } catch (e) {
        return Left(CacheFailure('Gagal memuat kamera: ${e.toString()}'));
      }
    }
  }
}
