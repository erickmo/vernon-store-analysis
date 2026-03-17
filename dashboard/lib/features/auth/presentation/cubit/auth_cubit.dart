import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import 'auth_state.dart';

/// Cubit yang mengelola state autentikasi pengguna.
///
/// Alur normal: [AuthInitial] → [AuthLoading] → [AuthLoaded] / [AuthError].
/// Setelah logout: [AuthUnauthenticated].
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final AuthRepository _authRepository;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _refreshTokenUseCase = refreshTokenUseCase,
        _authRepository = authRepository,
        super(const AuthInitial());

  /// Melakukan login dengan email dan password, lalu mengambil data user.
  ///
  /// Emit [AuthLoading] saat proses, [AuthLoaded] jika berhasil,
  /// atau [AuthError] jika gagal.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final loginResult = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    await loginResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        final meResult = await _authRepository.getMe();
        meResult.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthLoaded(user)),
        );
      },
    );
  }

  /// Melakukan logout dan menghapus semua token.
  ///
  /// Emit [AuthLoading] saat proses, [AuthUnauthenticated] jika berhasil,
  /// atau [AuthError] jika gagal.
  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Memperbarui access token menggunakan refresh token.
  ///
  /// Tidak mengubah state jika berhasil; emit [AuthError] jika gagal.
  Future<void> refreshToken({required String refreshToken}) async {
    final result = await _refreshTokenUseCase(
      RefreshTokenParams(refreshToken: refreshToken),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {},
    );
  }

  /// Memeriksa sesi yang sedang aktif dan mengambil data user.
  ///
  /// Dipanggil saat app pertama kali dibuka untuk restore session.
  Future<void> checkSession() async {
    emit(const AuthLoading());

    final meResult = await _authRepository.getMe();

    meResult.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthLoaded(user)),
    );
  }
}
