import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/token_entity.dart';
import '../entities/user_entity.dart';

/// Kontrak repository untuk operasi autentikasi.
abstract class AuthRepository {
  /// Login dengan email dan password.
  ///
  /// Mengembalikan [TokenEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, TokenEntity>> login({
    required String email,
    required String password,
  });

  /// Logout dan hapus semua token tersimpan.
  ///
  /// Mengembalikan [Unit] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, Unit>> logout();

  /// Ambil data profil pengguna yang sedang login.
  ///
  /// Mengembalikan [UserEntity] jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, UserEntity>> getMe();

  /// Perbarui access token menggunakan refresh token.
  ///
  /// Mengembalikan [TokenEntity] baru jika berhasil, atau [Failure] jika gagal.
  Future<Either<Failure, TokenEntity>> refreshToken({
    required String refreshToken,
  });
}
