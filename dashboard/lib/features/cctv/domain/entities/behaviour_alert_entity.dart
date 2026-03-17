import 'package:equatable/equatable.dart';

/// Enum untuk tipe behaviour yang terdeteksi.
enum BehaviourType {
  loitering,
  fighting,
  running,
  crowding,
  other,
}

/// Entity untuk alert behaviour detection dari CCTV.
class BehaviourAlertEntity extends Equatable {
  /// ID unik dari alert.
  final String id;

  /// ID CCTV yang mendeteksi behaviour.
  final String cctvId;

  /// Nama CCTV untuk display.
  final String cctvName;

  /// Tipe behaviour yang terdeteksi.
  final BehaviourType type;

  /// Confidence level (0.0 - 1.0) dari deteksi.
  final double confidence;

  /// Deskripsi detail dari behaviour alert.
  final String description;

  /// Waktu terdeteksi behaviour.
  final DateTime timestamp;

  /// URL gambar/snapshot dari alert (optional).
  final String? imageUrl;

  const BehaviourAlertEntity({
    required this.id,
    required this.cctvId,
    required this.cctvName,
    required this.type,
    required this.confidence,
    required this.description,
    required this.timestamp,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    cctvId,
    cctvName,
    type,
    confidence,
    description,
    timestamp,
    imageUrl,
  ];
}
