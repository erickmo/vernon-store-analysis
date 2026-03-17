import 'package:equatable/equatable.dart';

import '../constants/app_strings.dart';

/// Base class untuk semua Failure.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure dari server (HTTP error).
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure karena tidak ada koneksi internet.
class NetworkFailure extends Failure {
  const NetworkFailure() : super(AppStrings.noInternetError);
}

/// Failure dari local cache.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure karena unauthorized (token expired / invalid).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super(AppStrings.unauthorizedError);
}

/// Failure karena resource tidak ditemukan.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
