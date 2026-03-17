import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan token autentikasi JWT.
class TokenEntity extends Equatable {
  /// JWT access token.
  final String accessToken;

  /// JWT refresh token.
  final String refreshToken;

  /// Tipe token, contoh: "bearer".
  final String tokenType;

  /// Durasi kedaluwarsa access token dalam detik.
  final int expiresIn;

  const TokenEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType, expiresIn];
}
