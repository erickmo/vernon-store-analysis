import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../network/api_endpoints.dart';
import 'token_manager.dart';

/// Client untuk koneksi WebSocket ke real-time detection stream.
///
/// Gunakan [connect] untuk membuka koneksi dan [messages] untuk
/// menerima update deteksi secara real-time.
class WebSocketClient {
  final TokenManager _tokenManager;

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController.broadcast();

  bool _isConnected = false;

  WebSocketClient(this._tokenManager);

  /// Stream event real-time dari server.
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  /// True jika WebSocket sedang terhubung.
  bool get isConnected => _isConnected;

  /// Buka koneksi WebSocket.
  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _tokenManager.getAccessToken();
    final uri = Uri.parse(
      token != null
          ? '${ApiEndpoints.wsStream}?token=$token'
          : ApiEndpoints.wsStream,
    );

    _channel = WebSocketChannel.connect(uri);
    _isConnected = true;

    _channel!.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          _controller.add(decoded);
        } catch (_) {
          // Ignore malformed messages
        }
      },
      onDone: () => _isConnected = false,
      onError: (_) => _isConnected = false,
      cancelOnError: false,
    );
  }

  /// Tutup koneksi WebSocket.
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
  }

  /// Kirim pesan ke server.
  void send(Map<String, dynamic> message) {
    if (_isConnected) {
      _channel?.sink.add(jsonEncode(message));
    }
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}
