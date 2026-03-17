import 'package:equatable/equatable.dart';

import '../../domain/entities/behaviour_alert_entity.dart';
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

  /// List behaviour alerts untuk CCTV ini.
  final List<BehaviourAlertEntity> alerts;

  /// Alert yang sedang aktif/ditampilkan, null jika tidak ada.
  final BehaviourAlertEntity? activeAlert;

  /// Apakah alert overlay sedang ditampilkan.
  final bool showAlertOverlay;

  const StreamingState({
    this.cctv,
    this.streamStatus = StreamStatus.initial,
    this.errorMessage,
    this.isPlaying = false,
    this.isFullscreen = false,
    this.volume = 1.0,
    this.showControls = false,
    this.alerts = const [],
    this.activeAlert,
    this.showAlertOverlay = false,
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
    List<BehaviourAlertEntity>? alerts,
    BehaviourAlertEntity? activeAlert,
    bool? showAlertOverlay,
  }) {
    return StreamingState(
      cctv: cctv ?? this.cctv,
      streamStatus: streamStatus ?? this.streamStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      volume: volume ?? this.volume,
      showControls: showControls ?? this.showControls,
      alerts: alerts ?? this.alerts,
      activeAlert: activeAlert ?? this.activeAlert,
      showAlertOverlay: showAlertOverlay ?? this.showAlertOverlay,
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
    alerts,
    activeAlert,
    showAlertOverlay,
  ];
}
