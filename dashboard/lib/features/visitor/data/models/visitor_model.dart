import '../../domain/entities/visitor_entity.dart';

/// Model data visitor yang memetakan JSON dari API ke VisitorEntity.
class VisitorModel extends VisitorEntity {
  const VisitorModel({
    required super.id,
    required super.storeId,
    required super.personUid,
    super.label,
    required super.firstSeenAt,
    required super.lastSeenAt,
    required super.totalVisits,
    required super.createdAt,
  });

  /// Membuat VisitorModel dari JSON response API.
  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      personUid: json['person_uid'] as String,
      label: json['label'] as String?,
      firstSeenAt: DateTime.parse(json['first_seen_at'] as String),
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
      totalVisits: json['total_visits'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Mengonversi model ke Map JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'person_uid': personUid,
    'label': label,
    'first_seen_at': firstSeenAt.toIso8601String(),
    'last_seen_at': lastSeenAt.toIso8601String(),
    'total_visits': totalVisits,
    'created_at': createdAt.toIso8601String(),
  };

  /// Mengonversi model ke VisitorEntity.
  VisitorEntity toEntity() => VisitorEntity(
    id: id,
    storeId: storeId,
    personUid: personUid,
    label: label,
    firstSeenAt: firstSeenAt,
    lastSeenAt: lastSeenAt,
    totalVisits: totalVisits,
    createdAt: createdAt,
  );
}
