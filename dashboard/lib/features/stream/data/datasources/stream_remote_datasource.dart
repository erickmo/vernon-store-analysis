import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../../../../core/utils/websocket_client.dart';
import '../../domain/entities/stream_status_entity.dart';
import '../models/stream_status_model.dart';

/// Abstract datasource untuk stream control dan WebSocket.
abstract class StreamRemoteDataSource {
  /// Fetch status stream dari API.
  Future<StreamStatusModel> getStreamStatus();

  /// Start stream kamera tertentu.
  Future<void> startCamera(int cameraId);

  /// Stop stream kamera tertentu.
  Future<void> stopCamera(int cameraId);

  /// Start semua stream.
  Future<void> startAllStreams();

  /// Stop semua stream.
  Future<void> stopAllStreams();

  /// Stream WebSocket events yang sudah di-parse.
  Stream<WsEvent> get wsEvents;

  /// Sambungkan ke WebSocket.
  Future<void> connectWebSocket();

  /// Putuskan koneksi WebSocket.
  Future<void> disconnectWebSocket();
}

/// Implementasi [StreamRemoteDataSource] menggunakan [AppHttpClient] dan [WebSocketClient].
class StreamRemoteDataSourceImpl implements StreamRemoteDataSource {
  final AppHttpClient httpClient;
  final WebSocketClient webSocketClient;

  const StreamRemoteDataSourceImpl({
    required this.httpClient,
    required this.webSocketClient,
  });

  @override
  Future<StreamStatusModel> getStreamStatus() async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.streamStatus,
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat status stream',
      );
    }

    return StreamStatusModel.fromJson(body);
  }

  @override
  Future<void> startCamera(int cameraId) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiEndpoints.startCamera(cameraId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memulai stream kamera',
      );
    }
  }

  @override
  Future<void> stopCamera(int cameraId) async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiEndpoints.stopCamera(cameraId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal menghentikan stream kamera',
      );
    }
  }

  @override
  Future<void> startAllStreams() async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiEndpoints.startAllStreams,
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memulai semua stream',
      );
    }
  }

  @override
  Future<void> stopAllStreams() async {
    final response = await httpClient.post<Map<String, dynamic>>(
      ApiEndpoints.stopAllStreams,
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal menghentikan semua stream',
      );
    }
  }

  @override
  Stream<WsEvent> get wsEvents {
    return webSocketClient.messages.map(_parseWsEvent);
  }

  @override
  Future<void> connectWebSocket() => webSocketClient.connect();

  @override
  Future<void> disconnectWebSocket() => webSocketClient.disconnect();

  WsEvent _parseWsEvent(Map<String, dynamic> raw) {
    final type = raw['type'] as String?;
    switch (type) {
      case 'detection':
        return WsDetection(WsDetectionEventModel.fromJson(raw));
      case 'shoplifting_alert':
        return WsShopliftingAlert(WsShopliftingAlertEventModel.fromJson(raw));
      default:
        return WsUnknownEvent(raw);
    }
  }
}
