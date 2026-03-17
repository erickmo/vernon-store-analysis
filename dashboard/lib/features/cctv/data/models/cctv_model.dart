import '../../domain/entities/cctv_entity.dart';

/// Model untuk CCTV yang extends CCTVEntity.
class CCTVModel extends CCTVEntity {
  const CCTVModel({
    required super.id,
    required super.name,
    required super.location,
    required super.streamUrl,
    required super.status,
    required super.resolution,
    required super.fps,
    required super.bitrate,
    required super.lastUpdated,
  });

  /// Create CCTVModel from JSON.
  factory CCTVModel.fromJson(Map<String, dynamic> json) {
    return CCTVModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      streamUrl: json['streamUrl'] as String,
      status: CCTVStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => CCTVStatus.offline,
      ),
      resolution: (json['resolution'] as num).toDouble(),
      fps: json['fps'] as int,
      bitrate: json['bitrate'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Convert CCTVModel to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'streamUrl': streamUrl,
    'status': status.toString().split('.').last,
    'resolution': resolution,
    'fps': fps,
    'bitrate': bitrate,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  /// Convert to entity.
  CCTVEntity toEntity() => CCTVEntity(
    id: id,
    name: name,
    location: location,
    streamUrl: streamUrl,
    status: status,
    resolution: resolution,
    fps: fps,
    bitrate: bitrate,
    lastUpdated: lastUpdated,
  );
}
