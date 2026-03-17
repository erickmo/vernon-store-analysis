import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Base sealed class untuk state autentikasi.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada aksi autentikasi.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State ketika proses autentikasi sedang berlangsung.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State ketika login berhasil dan pengguna sudah terautentikasi.
class AuthLoaded extends AuthState {
  /// Data pengguna yang sedang login.
  final UserEntity user;

  const AuthLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// State ketika terjadi error pada proses autentikasi.
class AuthError extends AuthState {
  /// Pesan error yang akan ditampilkan.
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State ketika pengguna sudah logout.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
