import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../domain/usecases/get_cctv_by_id_usecase.dart';
import 'streaming_state.dart';

/// Cubit untuk mengelola state video streaming CCTV.
class StreamingCubit extends Cubit<StreamingState> {
  final GetCCTVByIdUseCase getCCTVByIdUseCase;

  VideoPlayerController? _videoController;
  Timer? _controlsHideTimer;

  StreamingCubit({
    required this.getCCTVByIdUseCase,
  }) : super(const StreamingState());

  /// Getter untuk VideoPlayerController.
  VideoPlayerController? get videoController => _videoController;

  /// Inisialisasi streaming untuk kamera tertentu.
  Future<void> initialize(int storeId, int cameraId) async {
    emit(state.copyWith(streamStatus: StreamStatus.loading));

    final cctvResult = await getCCTVByIdUseCase(storeId, cameraId);

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

    if (!cctv.isActive) {
      emit(state.copyWith(
        cctv: cctv,
        streamStatus: StreamStatus.noSignal,
      ));
      return;
    }

    await _initVideoPlayer(cctv.streamUrl);

    emit(state.copyWith(
      cctv: cctv,
      streamStatus: StreamStatus.streaming,
      isPlaying: true,
    ));
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
        errorMessage: 'Gagal inisialisasi video player: ${e.toString()}',
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

  /// Reset controls auto-hide timer.
  void _resetControlsAutoHide() {
    _controlsHideTimer?.cancel();
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
  }

  @override
  Future<void> close() {
    disposeStream();
    return super.close();
  }
}

// Keep debugPrint accessible for widgets that use it.
void debugPrint(String msg) {
  // ignore: avoid_print
  print('[StreamingCubit] $msg');
}
