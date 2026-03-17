import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/token_entity.dart';
import '../repositories/auth_repository.dart';

/// Parameter untuk use case refresh token.
class RefreshTokenParams extends Equatable {
  /// Refresh token yang akan digunakan untuk mendapatkan access token baru.
  final String refreshToken;

  const RefreshTokenParams({required this.refreshToken});

  @override
  List<Object?> get props => [refreshToken];
}

/// Use case untuk memperbarui access token menggunakan refresh token.
class RefreshTokenUseCase {
  final AuthRepository _repository;

  const RefreshTokenUseCase(this._repository);

  /// Eksekusi refresh token.
  ///
  /// Mengembalikan [TokenEntity] baru jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, TokenEntity>> call(RefreshTokenParams params) {
    return _repository.refreshToken(refreshToken: params.refreshToken);
  }
}
