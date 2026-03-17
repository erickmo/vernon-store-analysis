import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

/// Kontrak datasource remote untuk operasi autentikasi.
abstract class AuthRemoteDataSource {
  /// Login dengan email dan password menggunakan form URLEncoded.
  ///
  /// Melempar exception jika request gagal.
  Future<TokenModel> login({
    required String email,
    required String password,
  });

  /// Ambil profil pengguna yang sedang login.
  ///
  /// Melempar exception jika request gagal.
  Future<UserModel> getMe();

  /// Perbarui access token menggunakan refresh token.
  ///
  /// Melempar exception jika request gagal.
  Future<TokenModel> refreshToken({required String refreshToken});
}

/// Implementasi [AuthRemoteDataSource] yang berkomunikasi dengan REST API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AppHttpClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: FormData.fromMap({
        'username': email,
        'password': password,
      }),
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return TokenModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.me);
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<TokenModel> refreshToken({required String refreshToken}) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    return TokenModel.fromJson(response.data!);
  }
}
