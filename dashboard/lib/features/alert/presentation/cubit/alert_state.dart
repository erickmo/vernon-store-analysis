import 'package:equatable/equatable.dart';

import '../../domain/entities/alert_entity.dart';

/// State untuk [AlertCubit].
sealed class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada action.
final class AlertInitial extends AlertState {
  const AlertInitial();
}

/// State saat memuat daftar alert.
final class AlertLoading extends AlertState {
  const AlertLoading();
}

/// State saat daftar alert berhasil dimuat.
final class AlertLoaded extends AlertState {
  final List<AlertEntity> alerts;

  const AlertLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

/// State saat terjadi error.
final class AlertError extends AlertState {
  final String message;

  const AlertError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State saat sedang memproses resolve alert.
final class AlertResolving extends AlertState {
  final int alertId;

  const AlertResolving(this.alertId);

  @override
  List<Object?> get props => [alertId];
}

/// State saat resolve alert berhasil.
final class AlertResolved extends AlertState {
  final int alertId;

  const AlertResolved(this.alertId);

  @override
  List<Object?> get props => [alertId];
}
