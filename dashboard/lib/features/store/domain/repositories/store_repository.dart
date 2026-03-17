import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store_entity.dart';

/// Kontrak repository untuk operasi toko.
abstract class StoreRepository {
  /// Ambil daftar semua toko.
  ///
  /// Mengembalikan list [StoreEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, List<StoreEntity>>> getStoreList();

  /// Ambil detail satu toko berdasarkan [storeId].
  ///
  /// Mengembalikan [StoreEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, StoreEntity>> getStoreById(int storeId);
}
