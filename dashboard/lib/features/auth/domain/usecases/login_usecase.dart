import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/token_entity.dart';
import '../repositories/auth_repository.dart';

/// Parameter untuk use case login.
class LoginParams extends Equatable {
  /// Alamat email pengguna.
  final String email;

  /// Password pengguna.
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Use case untuk melakukan login dengan email dan password.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Eksekusi login.
  ///
  /// Mengembalikan [TokenEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, TokenEntity>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}
