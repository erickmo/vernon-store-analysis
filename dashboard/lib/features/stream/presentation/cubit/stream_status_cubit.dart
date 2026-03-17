import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/stream_status_entity.dart';
import '../../domain/repositories/stream_repository.dart';
import '../../domain/usecases/control_stream_usecase.dart';
import '../../domain/usecases/get_stream_status_usecase.dart';
import 'stream_status_state.dart';

/// Cubit untuk mengelola state stream control dan WebSocket real-time.
class StreamStatusCubit extends Cubit<StreamStatusState> {
  final GetStreamStatusUseCase getStreamStatusUseCase;
  final ControlStreamUseCase controlStreamUseCase;
  final StreamRepository streamRepository;

  StreamSubscription<WsEvent>? _wsSub;
  StreamStatusEntity? _lastStatus;

  StreamStatusCubit({
    required this.getStreamStatusUseCase,
    required this.controlStreamUseCase,
    required this.streamRepository,
  }) : super(const StreamStatusInitial());

  /// Memuat status stream dari API.
  Future<void> loadStatus() async {
    emit(const StreamStatusLoading());

    final result = await getStreamStatusUseCase();

    result.fold(
      (failure) => emit(StreamStatusError(failure.message)),
      (status) {
        _lastStatus = status;
        emit(StreamStatusLoaded(status: status));
      },
    );
  }

  /// Sambungkan ke WebSocket dan mulai listen events.
  Future<void> connectWebSocket() async {
    await streamRepository.connectWebSocket();

    _wsSub?.cancel();
    _wsSub = streamRepository.wsEvents.listen(_handleWsEvent);

    if (_lastStatus != null) {
      emit(StreamStatusLoaded(status: _lastStatus!, isWsConnected: true));
    }
  }

  /// Putuskan koneksi WebSocket.
  Future<void> disconnectWebSocket() async {
    await _wsSub?.cancel();
    _wsSub = null;
    await streamRepository.disconnectWebSocket();

    if (_lastStatus != null) {
      emit(StreamStatusLoaded(status: _lastStatus!, isWsConnected: false));
    }
  }

  /// Mulai stream kamera tertentu.
  Future<void> startCamera(int cameraId) async {
    emit(const StreamControlling());

    final result = await controlStreamUseCase(
      StreamControlAction.startCamera,
      cameraId: cameraId,
    );

    await result.fold(
      (failure) async => emit(StreamStatusError(failure.message)),
      (_) async => loadStatus(),
    );
  }

  /// Hentikan stream kamera tertentu.
  Future<void> stopCamera(int cameraId) async {
    emit(const StreamControlling());

    final result = await controlStreamUseCase(
      StreamControlAction.stopCamera,
      cameraId: cameraId,
    );

    await result.fold(
      (failure) async => emit(StreamStatusError(failure.message)),
      (_) async => loadStatus(),
    );
  }

  /// Mulai semua stream.
  Future<void> startAllStreams() async {
    emit(const StreamControlling());

    final result = await controlStreamUseCase(StreamControlAction.startAll);

    await result.fold(
      (failure) async => emit(StreamStatusError(failure.message)),
      (_) async => loadStatus(),
    );
  }

  /// Hentikan semua stream.
  Future<void> stopAllStreams() async {
    emit(const StreamControlling());

    final result = await controlStreamUseCase(StreamControlAction.stopAll);

    await result.fold(
      (failure) async => emit(StreamStatusError(failure.message)),
      (_) async => loadStatus(),
    );
  }

  void _handleWsEvent(WsEvent event) {
    if (_lastStatus == null) return;

    switch (event) {
      case WsDetection(:final data):
        emit(
          StreamWsDetectionReceived(status: _lastStatus!, event: data),
        );
      case WsShopliftingAlert(:final data):
        emit(
          StreamWsAlertReceived(status: _lastStatus!, event: data),
        );
      case WsUnknownEvent():
        break;
    }
  }

  @override
  Future<void> close() async {
    await _wsSub?.cancel();
    await streamRepository.disconnectWebSocket();
    return super.close();
  }
}
