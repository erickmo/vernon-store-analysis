import '../../domain/entities/visit_entity.dart';

/// Model data kunjungan yang memetakan JSON dari API ke VisitEntity.
class VisitModel extends VisitEntity {
  const VisitModel({
    required super.id,
    required super.visitorId,
    required super.cameraId,
    required super.entryAt,
    super.exitAt,
    required super.dwellSeconds,
  });

  /// Membuat VisitModel dari JSON response API.
  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id'] as int,
      visitorId: json['visitor_id'] as int,
      cameraId: json['camera_id'] as int,
      entryAt: DateTime.parse(json['entry_at'] as String),
      exitAt: json['exit_at'] != null
          ? DateTime.parse(json['exit_at'] as String)
          : null,
      dwellSeconds: json['dwell_seconds'] as int,
    );
  }

  /// Mengonversi model ke Map JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'visitor_id': visitorId,
    'camera_id': cameraId,
    'entry_at': entryAt.toIso8601String(),
    'exit_at': exitAt?.toIso8601String(),
    'dwell_seconds': dwellSeconds,
  };

  /// Mengonversi model ke VisitEntity.
  VisitEntity toEntity() => VisitEntity(
    id: id,
    visitorId: visitorId,
    cameraId: cameraId,
    entryAt: entryAt,
    exitAt: exitAt,
    dwellSeconds: dwellSeconds,
  );
}
