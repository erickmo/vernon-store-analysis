import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

/// Use case untuk mengambil daftar semua toko.
class GetStoreListUseCase {
  final StoreRepository _repository;

  const GetStoreListUseCase(this._repository);

  /// Eksekusi pengambilan daftar toko.
  ///
  /// Mengembalikan list [StoreEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, List<StoreEntity>>> call() {
    return _repository.getStoreList();
  }
}
