import '../../domain/entities/mood_log_entity.dart';

/// Model data mood log yang memetakan JSON dari API ke MoodLogEntity.
class MoodLogModel extends MoodLogEntity {
  const MoodLogModel({
    required super.id,
    required super.visitId,
    required super.timestamp,
    required super.mood,
    required super.confidence,
  });

  /// Membuat MoodLogModel dari JSON response API.
  factory MoodLogModel.fromJson(Map<String, dynamic> json) {
    return MoodLogModel(
      id: json['id'] as int,
      visitId: json['visit_id'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mood: json['mood'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// Mengonversi model ke Map JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'visit_id': visitId,
    'timestamp': timestamp.toIso8601String(),
    'mood': mood,
    'confidence': confidence,
  };

  /// Mengonversi model ke MoodLogEntity.
  MoodLogEntity toEntity() => MoodLogEntity(
    id: id,
    visitId: visitId,
    timestamp: timestamp,
    mood: mood,
    confidence: confidence,
  );
}
