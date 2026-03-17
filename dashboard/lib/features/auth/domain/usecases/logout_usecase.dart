import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case untuk melakukan logout dan menghapus semua token.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// Eksekusi logout.
  ///
  /// Mengembalikan [Unit] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, Unit>> call() {
    return _repository.logout();
  }
}
