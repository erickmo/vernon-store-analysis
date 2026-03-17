import '../../domain/entities/stream_status_entity.dart';

/// Model untuk status per-kamera.
class CameraStreamStatusModel extends CameraStreamStatusEntity {
  const CameraStreamStatusModel({
    required super.cameraId,
    required super.storeId,
    required super.zone,
    required super.isRunning,
    required super.personsInFrame,
    required super.totalDetections,
    super.lastFrameAt,
  });

  factory CameraStreamStatusModel.fromJson(Map<String, dynamic> json) {
    return CameraStreamStatusModel(
      cameraId: json['camera_id'] as int,
      storeId: json['store_id'] as int,
      zone: json['zone'] as String,
      isRunning: json['is_running'] as bool,
      personsInFrame: json['persons_in_frame'] as int,
      totalDetections: json['total_detections'] as int,
      lastFrameAt: json['last_frame_at'] != null
          ? DateTime.parse(json['last_frame_at'] as String)
          : null,
    );
  }

  CameraStreamStatusEntity toEntity() => CameraStreamStatusEntity(
    cameraId: cameraId,
    storeId: storeId,
    zone: zone,
    isRunning: isRunning,
    personsInFrame: personsInFrame,
    totalDetections: totalDetections,
    lastFrameAt: lastFrameAt,
  );
}

/// Model untuk keseluruhan status stream.
class StreamStatusModel extends StreamStatusEntity {
  const StreamStatusModel({
    required super.activeCameras,
    required super.registeredCameras,
    required super.cameras,
  });

  factory StreamStatusModel.fromJson(Map<String, dynamic> json) {
    final cameraList = (json['cameras'] as List<dynamic>)
        .map(
          (item) =>
              CameraStreamStatusModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return StreamStatusModel(
      activeCameras: json['active_cameras'] as int,
      registeredCameras: json['registered_cameras'] as int,
      cameras: cameraList,
    );
  }

  StreamStatusEntity toEntity() => StreamStatusEntity(
    activeCameras: activeCameras,
    registeredCameras: registeredCameras,
    cameras: cameras,
  );
}

/// Model untuk WebSocket detection event.
class WsDetectionEventModel extends WsDetectionEvent {
  const WsDetectionEventModel({
    required super.cameraId,
    required super.persons,
    required super.timestamp,
  });

  factory WsDetectionEventModel.fromJson(Map<String, dynamic> json) {
    return WsDetectionEventModel(
      cameraId: json['camera_id'] as int,
      persons: json['persons'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Model untuk WebSocket shoplifting alert event.
class WsShopliftingAlertEventModel extends WsShopliftingAlertEvent {
  const WsShopliftingAlertEventModel({
    required super.cameraId,
    required super.confidence,
    required super.personUid,
  });

  factory WsShopliftingAlertEventModel.fromJson(Map<String, dynamic> json) {
    return WsShopliftingAlertEventModel(
      cameraId: json['camera_id'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      personUid: json['person_uid'] as String,
    );
  }
}
