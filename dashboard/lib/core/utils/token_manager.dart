import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mengelola penyimpanan JWT token secara aman menggunakan secure storage.
///
/// Semua operasi di-wrap dengan try-catch agar aman di web
/// (WebCrypto API bisa gagal pada non-HTTPS context).
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  const TokenManager(this._storage);

  /// Simpan access token.
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (_) {}
  }

  /// Simpan refresh token.
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (_) {}
  }

  /// Simpan kedua token sekaligus.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Ambil access token. Null jika belum ada atau storage gagal.
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Ambil refresh token. Null jika belum ada atau storage gagal.
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Hapus semua token (logout).
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
    } catch (_) {}
  }

  /// True jika access token tersimpan.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
