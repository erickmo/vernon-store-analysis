import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/behaviour_alert_entity.dart';
import '../../domain/usecases/get_cctv_by_id_usecase.dart';
import '../../domain/usecases/get_cctv_alerts_usecase.dart';
import 'streaming_state.dart';

/// Cubit untuk mengelola state video streaming CCTV.
class StreamingCubit extends Cubit<StreamingState> {
  final GetCCTVByIdUseCase getCCTVByIdUseCase;
  final GetCCTVAlertsUseCase getCCTVAlertsUseCase;

  VideoPlayerController? _videoController;
  Timer? _controlsHideTimer;
  Timer? _alertHideTimer;
  Timer? _behaviourSimulationTimer;

  StreamingCubit({
    required this.getCCTVByIdUseCase,
    required this.getCCTVAlertsUseCase,
  }) : super(const StreamingState());

  /// Getter untuk VideoPlayerController.
  VideoPlayerController? get videoController => _videoController;

  /// Inisialisasi streaming untuk CCTV tertentu.
  Future<void> initialize(String cctvId) async {
    emit(state.copyWith(streamStatus: StreamStatus.loading));

    final cctvResult = await getCCTVByIdUseCase(cctvId);
    final alertsResult = await getCCTVAlertsUseCase(cctvId);

    // Handle CCTV result
    final cctv = cctvResult.fold(
      (failure) {
        emit(state.copyWith(
          streamStatus: StreamStatus.error,
          errorMessage: failure.message,
        ));
        return null;
      },
      (entity) => entity,
    );

    if (cctv == null) return;

    // Check if CCTV is offline
    if (cctv.status.toString().contains('offline')) {
      emit(state.copyWith(
        cctv: cctv,
        streamStatus: StreamStatus.noSignal,
      ));
      return;
    }

    // Initialize video player
    await _initVideoPlayer(cctv.streamUrl);

    // Handle alerts result
    final alerts = alertsResult.fold(
      (failure) => <BehaviourAlertEntity>[],
      (entities) => entities,
    );

    emit(state.copyWith(
      cctv: cctv,
      streamStatus: StreamStatus.streaming,
      isPlaying: true,
      alerts: alerts,
    ));

    // Start behaviour detection simulation
    _startBehaviourSimulation();
  }

  /// Inisialisasi VideoPlayerController dengan stream URL.
  Future<void> _initVideoPlayer(String streamUrl) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      await _videoController!.initialize();
      await _videoController!.play();
    } catch (e) {
      emit(state.copyWith(
        streamStatus: StreamStatus.error,
        errorMessage: 'Failed to initialize video player: ${e.toString()}',
      ));
    }
  }

  /// Toggle play/pause video.
  void togglePlayPause() {
    if (_videoController == null) return;

    if (state.isPlaying) {
      _videoController!.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      _videoController!.play();
      emit(state.copyWith(isPlaying: true));
    }

    _resetControlsAutoHide();
  }

  /// Toggle fullscreen mode.
  void toggleFullscreen() {
    emit(state.copyWith(isFullscreen: !state.isFullscreen));
    _resetControlsAutoHide();
  }

  /// Set volume level (0.0 - 1.0).
  void setVolume(double volume) {
    if (_videoController == null) return;

    final clampedVolume = volume.clamp(0.0, 1.0);
    _videoController!.setVolume(clampedVolume);
    emit(state.copyWith(volume: clampedVolume));
    _resetControlsAutoHide();
  }

  /// Handle tap on video player (show/hide controls).
  void tapOnPlayer() {
    emit(state.copyWith(showControls: !state.showControls));
    _resetControlsAutoHide();
  }

  /// Dismiss active alert.
  void dismissAlert() {
    _alertHideTimer?.cancel();
    emit(state.copyWith(
      activeAlert: null,
      showAlertOverlay: false,
    ));
  }

  /// Start behaviour detection simulation - random alerts setiap 10-15 detik.
  void _startBehaviourSimulation() {
    _behaviourSimulationTimer?.cancel();

    void scheduleNextAlert() {
      final delaySeconds = 10 + Random().nextInt(6); // 10-15 seconds
      _behaviourSimulationTimer = Timer(
        Duration(seconds: delaySeconds),
        () {
          if (!isClosed) {
            _triggerRandomAlert();
            scheduleNextAlert(); // Schedule next alert
          }
        },
      );
    }

    scheduleNextAlert();
  }

  /// Trigger random alert dari behaviour detection.
  void _triggerRandomAlert() {
    if (state.alerts.isEmpty || isClosed) return;

    final randomAlert = state.alerts[Random().nextInt(state.alerts.length)];

    emit(state.copyWith(
      activeAlert: randomAlert,
      showAlertOverlay: true,
    ));

    // Auto-hide alert setelah 5 detik
    _alertHideTimer?.cancel();
    _alertHideTimer = Timer(const Duration(seconds: 5), () {
      if (!isClosed) {
        dismissAlert();
      }
    });
  }

  /// Reset controls auto-hide timer.
  void _resetControlsAutoHide() {
    _controlsHideTimer?.cancel();
    _startControlsAutoHide();
  }

  /// Start controls auto-hide timer (3 detik idle).
  void _startControlsAutoHide() {
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed && state.showControls) {
        emit(state.copyWith(showControls: false));
      }
    });
  }

  /// Dispose stream dan cleanup resources.
  void disposeStream() {
    _videoController?.dispose();
    _videoController = null;
    _controlsHideTimer?.cancel();
    _alertHideTimer?.cancel();
    _behaviourSimulationTimer?.cancel();
  }

  @override
  Future<void> close() {
    disposeStream();
    return super.close();
  }
}
