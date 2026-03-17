import 'package:dio/dio.dart';

import '../utils/token_manager.dart';

/// Interceptor untuk menyisipkan JWT token ke setiap request.
///
/// Jika access token tersedia, otomatis ditambahkan sebagai
/// `Authorization: Bearer <token>` header.
class TokenInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  TokenInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 → token expired, bisa tambahkan refresh logic di sini jika diperlukan
    handler.next(err);
  }
}
