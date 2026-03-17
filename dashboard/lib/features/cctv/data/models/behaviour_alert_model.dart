import '../../domain/entities/behaviour_alert_entity.dart';

/// Model untuk BehaviourAlert yang extends BehaviourAlertEntity.
class BehaviourAlertModel extends BehaviourAlertEntity {
  const BehaviourAlertModel({
    required super.id,
    required super.cctvId,
    required super.cctvName,
    required super.type,
    required super.confidence,
    required super.description,
    required super.timestamp,
    super.imageUrl,
  });

  /// Create BehaviourAlertModel from JSON.
  factory BehaviourAlertModel.fromJson(Map<String, dynamic> json) {
    return BehaviourAlertModel(
      id: json['id'] as String,
      cctvId: json['cctvId'] as String,
      cctvName: json['cctvName'] as String,
      type: BehaviourType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => BehaviourType.other,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Convert BehaviourAlertModel to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'cctvId': cctvId,
    'cctvName': cctvName,
    'type': type.toString().split('.').last,
    'confidence': confidence,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
  };

  /// Convert to entity.
  BehaviourAlertEntity toEntity() => BehaviourAlertEntity(
    id: id,
    cctvId: cctvId,
    cctvName: cctvName,
    type: type,
    confidence: confidence,
    description: description,
    timestamp: timestamp,
    imageUrl: imageUrl,
  );
}
