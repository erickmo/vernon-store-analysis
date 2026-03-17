import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import 'api_endpoints.dart';
import 'token_interceptor.dart';

/// HTTP client wrapper menggunakan Dio.
///
/// Semua request otomatis menyertakan Authorization header via [TokenInterceptor].
class AppHttpClient {
  late final Dio _dio;

  AppHttpClient({TokenInterceptor? tokenInterceptor}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    if (tokenInterceptor != null) {
      _dio.interceptors.add(tokenInterceptor);
    }

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  Dio get dio => _dio;

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Convert DioException ke AppException yang lebih spesifik.
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ServerException('Koneksi timeout', statusCode: 408);
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response);
        if (statusCode == 401) return const UnauthorizedException();
        if (statusCode == 404) return NotFoundException(message);
        return ServerException(message, statusCode: statusCode);
      default:
        return ServerException(e.message ?? 'Unknown error');
    }
  }

  String _extractErrorMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map) {
        return (data['error'] ?? data['message'] ?? 'Server error').toString();
      }
    } catch (_) {}
    return 'Server error';
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print('[HTTP] $message');
}
