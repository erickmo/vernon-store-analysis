import 'package:equatable/equatable.dart';

/// Entity untuk status per-kamera dalam stream.
class CameraStreamStatusEntity extends Equatable {
  /// ID kamera.
  final int cameraId;

  /// ID toko.
  final int storeId;

  /// Zona lokasi kamera.
  final String zone;

  /// Apakah stream sedang berjalan.
  final bool isRunning;

  /// Jumlah orang dalam frame saat ini.
  final int personsInFrame;

  /// Total deteksi sejak stream dimulai.
  final int totalDetections;

  /// Waktu frame terakhir diterima.
  final DateTime? lastFrameAt;

  const CameraStreamStatusEntity({
    required this.cameraId,
    required this.storeId,
    required this.zone,
    required this.isRunning,
    required this.personsInFrame,
    required this.totalDetections,
    this.lastFrameAt,
  });

  @override
  List<Object?> get props => [
    cameraId,
    storeId,
    zone,
    isRunning,
    personsInFrame,
    totalDetections,
    lastFrameAt,
  ];
}

/// Entity untuk keseluruhan status stream.
class StreamStatusEntity extends Equatable {
  /// Jumlah kamera yang sedang aktif streaming.
  final int activeCameras;

  /// Jumlah kamera yang terdaftar.
  final int registeredCameras;

  /// Status detail per kamera.
  final List<CameraStreamStatusEntity> cameras;

  const StreamStatusEntity({
    required this.activeCameras,
    required this.registeredCameras,
    required this.cameras,
  });

  @override
  List<Object?> get props => [activeCameras, registeredCameras, cameras];
}

/// Entity untuk WebSocket event detection.
class WsDetectionEvent extends Equatable {
  final int cameraId;
  final int persons;
  final DateTime timestamp;

  const WsDetectionEvent({
    required this.cameraId,
    required this.persons,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [cameraId, persons, timestamp];
}

/// Entity untuk WebSocket event shoplifting alert.
class WsShopliftingAlertEvent extends Equatable {
  final int cameraId;
  final double confidence;
  final String personUid;

  const WsShopliftingAlertEvent({
    required this.cameraId,
    required this.confidence,
    required this.personUid,
  });

  @override
  List<Object?> get props => [cameraId, confidence, personUid];
}

/// Sealed class untuk semua WebSocket events.
sealed class WsEvent {
  const WsEvent();
}

final class WsDetection extends WsEvent {
  final WsDetectionEvent data;
  const WsDetection(this.data);
}

final class WsShopliftingAlert extends WsEvent {
  final WsShopliftingAlertEvent data;
  const WsShopliftingAlert(this.data);
}

final class WsUnknownEvent extends WsEvent {
  final Map<String, dynamic> raw;
  const WsUnknownEvent(this.raw);
}
