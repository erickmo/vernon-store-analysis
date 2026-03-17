/// Exception yang dilempar oleh datasource layer.
class ServerException implements Exception {
  /// Pesan error dari server.
  final String message;

  /// HTTP status code jika tersedia.
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Exception untuk koneksi bermasalah.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}

/// Exception untuk data lokal bermasalah.
class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception untuk unauthorized / token expired.
class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: Token expired or invalid';
}

/// Exception untuk resource tidak ditemukan.
class NotFoundException implements Exception {
  final String message;

  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}
