import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan pengguna yang sudah login.
class UserEntity extends Equatable {
  /// ID unik pengguna.
  final int id;

  /// Alamat email pengguna.
  final String email;

  /// Nama lengkap pengguna.
  final String fullName;

  /// Role pengguna di sistem.
  final String role;

  /// Status aktif akun pengguna.
  final bool isActive;

  /// Waktu pembuatan akun dalam ISO 8601.
  final String createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, isActive, createdAt];
}
