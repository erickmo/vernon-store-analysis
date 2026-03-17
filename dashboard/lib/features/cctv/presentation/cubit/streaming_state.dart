import 'package:equatable/equatable.dart';

import '../../domain/entities/cctv_entity.dart';

/// Enum untuk status streaming video.
enum StreamStatus { initial, loading, streaming, error, noSignal }

/// State untuk video streaming.
class StreamingState extends Equatable {
  /// CCTV entity yang sedang di-stream, null saat initial/loading.
  final CCTVEntity? cctv;

  /// Status streaming video.
  final StreamStatus streamStatus;

  /// Pesan error jika terjadi kesalahan.
  final String? errorMessage;

  /// Apakah video sedang diputar.
  final bool isPlaying;

  /// Apakah video dalam mode fullscreen.
  final bool isFullscreen;

  /// Volume level (0.0 - 1.0).
  final double volume;

  /// Apakah controls overlay sedang ditampilkan.
  final bool showControls;

  const StreamingState({
    this.cctv,
    this.streamStatus = StreamStatus.initial,
    this.errorMessage,
    this.isPlaying = false,
    this.isFullscreen = false,
    this.volume = 1.0,
    this.showControls = false,
  });

  /// Create copy dari state dengan field yang bisa di-override.
  StreamingState copyWith({
    CCTVEntity? cctv,
    StreamStatus? streamStatus,
    String? errorMessage,
    bool? isPlaying,
    bool? isFullscreen,
    double? volume,
    bool? showControls,
  }) {
    return StreamingState(
      cctv: cctv ?? this.cctv,
      streamStatus: streamStatus ?? this.streamStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      volume: volume ?? this.volume,
      showControls: showControls ?? this.showControls,
    );
  }

  @override
  List<Object?> get props => [
    cctv,
    streamStatus,
    errorMessage,
    isPlaying,
    isFullscreen,
    volume,
    showControls,
  ];
}
