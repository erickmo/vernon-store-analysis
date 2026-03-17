import '../../domain/entities/alert_entity.dart';

/// Model untuk shoplifting alert yang extends [AlertEntity].
class AlertModel extends AlertEntity {
  const AlertModel({
    required super.id,
    required super.visitId,
    required super.cameraId,
    required super.confidence,
    required super.timestamp,
    super.snapshotPath,
    required super.notified,
    required super.resolved,
    super.resolvedAt,
    super.resolvedNote,
    required super.createdAt,
  });

  /// Create [AlertModel] dari JSON API response.
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as int,
      visitId: json['visit_id'] as int,
      cameraId: json['camera_id'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      snapshotPath: json['snapshot_path'] as String?,
      notified: json['notified'] as bool,
      resolved: json['resolved'] as bool,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedNote: json['resolved_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert ke JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'visit_id': visitId,
    'camera_id': cameraId,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
    'snapshot_path': snapshotPath,
    'notified': notified,
    'resolved': resolved,
    'resolved_at': resolvedAt?.toIso8601String(),
    'resolved_note': resolvedNote,
    'created_at': createdAt.toIso8601String(),
  };

  /// Convert ke entity.
  AlertEntity toEntity() => AlertEntity(
    id: id,
    visitId: visitId,
    cameraId: cameraId,
    confidence: confidence,
    timestamp: timestamp,
    snapshotPath: snapshotPath,
    notified: notified,
    resolved: resolved,
    resolvedAt: resolvedAt,
    resolvedNote: resolvedNote,
    createdAt: createdAt,
  );
}
