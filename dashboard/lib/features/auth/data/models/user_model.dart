import '../../domain/entities/user_entity.dart';

/// Model data untuk pengguna dari API.
///
/// Extends [UserEntity] dan menambahkan kemampuan serialisasi JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.isActive,
    required super.createdAt,
  });

  /// Buat [UserModel] dari map JSON response API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  /// Konversi [UserModel] ke map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}
