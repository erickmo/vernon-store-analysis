import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stream_status_entity.dart';

/// Abstract repository untuk stream control.
abstract class StreamRepository {
  /// Mendapatkan status stream semua kamera.
  Future<Either<Failure, StreamStatusEntity>> getStreamStatus();

  /// Memulai stream kamera tertentu.
  Future<Either<Failure, void>> startCamera(int cameraId);

  /// Menghentikan stream kamera tertentu.
  Future<Either<Failure, void>> stopCamera(int cameraId);

  /// Memulai semua stream kamera.
  Future<Either<Failure, void>> startAllStreams();

  /// Menghentikan semua stream kamera.
  Future<Either<Failure, void>> stopAllStreams();

  /// Stream WebSocket events real-time.
  Stream<WsEvent> get wsEvents;

  /// Sambungkan ke WebSocket.
  Future<void> connectWebSocket();

  /// Putuskan koneksi WebSocket.
  Future<void> disconnectWebSocket();
}
