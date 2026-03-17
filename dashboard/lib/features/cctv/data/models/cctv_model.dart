import '../../domain/entities/cctv_entity.dart';

/// Model untuk CCTV yang extends CCTVEntity.
class CCTVModel extends CCTVEntity {
  const CCTVModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.streamUrl,
    required super.locationZone,
    super.description,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create CCTVModel from JSON (API response).
  factory CCTVModel.fromJson(Map<String, dynamic> json) {
    return CCTVModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      name: json['name'] as String,
      streamUrl: json['stream_url'] as String,
      locationZone: json['location_zone'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert CCTVModel to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'name': name,
    'stream_url': streamUrl,
    'location_zone': locationZone,
    'description': description,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Convert to entity.
  CCTVEntity toEntity() => CCTVEntity(
    id: id,
    storeId: storeId,
    name: name,
    streamUrl: streamUrl,
    locationZone: locationZone,
    description: description,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
