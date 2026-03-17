import 'package:equatable/equatable.dart';

import '../../domain/entities/stream_status_entity.dart';

/// State untuk [StreamStatusCubit].
sealed class StreamStatusState extends Equatable {
  const StreamStatusState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada action.
final class StreamStatusInitial extends StreamStatusState {
  const StreamStatusInitial();
}

/// State saat memuat status stream.
final class StreamStatusLoading extends StreamStatusState {
  const StreamStatusLoading();
}

/// State saat status stream berhasil dimuat.
final class StreamStatusLoaded extends StreamStatusState {
  final StreamStatusEntity status;
  final bool isWsConnected;

  const StreamStatusLoaded({
    required this.status,
    this.isWsConnected = false,
  });

  StreamStatusLoaded copyWith({
    StreamStatusEntity? status,
    bool? isWsConnected,
  }) {
    return StreamStatusLoaded(
      status: status ?? this.status,
      isWsConnected: isWsConnected ?? this.isWsConnected,
    );
  }

  @override
  List<Object?> get props => [status, isWsConnected];
}

/// State saat terjadi error.
final class StreamStatusError extends StreamStatusState {
  final String message;

  const StreamStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State saat sedang mengontrol stream (start/stop).
final class StreamControlling extends StreamStatusState {
  const StreamControlling();
}

/// State saat WebSocket menerima event detection baru.
final class StreamWsDetectionReceived extends StreamStatusState {
  final StreamStatusEntity status;
  final WsDetectionEvent event;

  const StreamWsDetectionReceived({
    required this.status,
    required this.event,
  });

  @override
  List<Object?> get props => [status, event];
}

/// State saat WebSocket menerima shoplifting alert.
final class StreamWsAlertReceived extends StreamStatusState {
  final StreamStatusEntity status;
  final WsShopliftingAlertEvent event;

  const StreamWsAlertReceived({
    required this.status,
    required this.event,
  });

  @override
  List<Object?> get props => [status, event];
}
