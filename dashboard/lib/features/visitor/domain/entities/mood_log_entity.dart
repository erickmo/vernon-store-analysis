import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan satu titik data mood dalam timeline.
class MoodLogEntity extends Equatable {
  /// ID unik mood log.
  final int id;

  /// ID kunjungan yang terkait.
  final int visitId;

  /// Waktu mood terdeteksi.
  final DateTime timestamp;

  /// Label mood (misal: happy, neutral, sad, angry).
  final String mood;

  /// Tingkat keyakinan deteksi antara 0.0 sampai 1.0.
  final double confidence;

  const MoodLogEntity({
    required this.id,
    required this.visitId,
    required this.timestamp,
    required this.mood,
    required this.confidence,
  });

  @override
  List<Object?> get props => [id, visitId, timestamp, mood, confidence];
}
