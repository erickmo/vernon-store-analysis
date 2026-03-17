import 'package:equatable/equatable.dart';

/// Entity untuk shoplifting alert.
class AlertEntity extends Equatable {
  /// ID unik dari alert.
  final int id;

  /// ID kunjungan yang terkait.
  final int visitId;

  /// ID kamera yang mendeteksi.
  final int cameraId;

  /// Confidence level deteksi (0.0 - 1.0).
  final double confidence;

  /// Waktu terdeteksi.
  final DateTime timestamp;

  /// Path snapshot gambar (optional).
  final String? snapshotPath;

  /// Apakah sudah dikirim notifikasi.
  final bool notified;

  /// Apakah sudah diselesaikan.
  final bool resolved;

  /// Waktu diselesaikan (null jika belum).
  final DateTime? resolvedAt;

  /// Catatan penyelesaian (null jika belum).
  final String? resolvedNote;

  /// Timestamp kapan alert dibuat.
  final DateTime createdAt;

  const AlertEntity({
    required this.id,
    required this.visitId,
    required this.cameraId,
    required this.confidence,
    required this.timestamp,
    this.snapshotPath,
    required this.notified,
    required this.resolved,
    this.resolvedAt,
    this.resolvedNote,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    visitId,
    cameraId,
    confidence,
    timestamp,
    snapshotPath,
    notified,
    resolved,
    resolvedAt,
    resolvedNote,
    createdAt,
  ];
}
