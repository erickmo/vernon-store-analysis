import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

/// Parameter untuk use case get store by id.
class GetStoreByIdParams extends Equatable {
  /// ID toko yang akan diambil.
  final int storeId;

  const GetStoreByIdParams({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

/// Use case untuk mengambil detail satu toko berdasarkan ID.
class GetStoreByIdUseCase {
  final StoreRepository _repository;

  const GetStoreByIdUseCase(this._repository);

  /// Eksekusi pengambilan detail toko.
  ///
  /// Mengembalikan [StoreEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, StoreEntity>> call(GetStoreByIdParams params) {
    return _repository.getStoreById(params.storeId);
  }
}
