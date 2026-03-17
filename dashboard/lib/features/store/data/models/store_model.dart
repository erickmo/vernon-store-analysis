import '../../domain/entities/store_entity.dart';

/// Model data untuk toko dari API.
///
/// Extends [StoreEntity] dan menambahkan kemampuan serialisasi JSON.
class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.location,
    required super.timezone,
    super.description,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Buat [StoreModel] dari map JSON response API.
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      timezone: json['timezone'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Konversi [StoreModel] ke map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'timezone': timezone,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
