import 'package:equatable/equatable.dart';

/// Enum untuk status CCTV.
enum CCTVStatus {
  online,
  offline,
  alert,
}

/// Entity untuk CCTV yang menampilkan video streaming.
class CCTVEntity extends Equatable {
  /// ID unik dari CCTV.
  final String id;

  /// Nama CCTV.
  final String name;

  /// Lokasi fisik CCTV.
  final String location;

  /// URL stream RTSP atau HTTP untuk video.
  final String streamUrl;

  /// Status saat ini dari CCTV (online, offline, alert).
  final CCTVStatus status;

  /// Resolusi video dalam pixel (e.g., 1080.0 untuk 1080p).
  final double resolution;

  /// Framerate video dalam fps.
  final int fps;

  /// Bitrate video (e.g., "5000 kbps").
  final String bitrate;

  /// Timestamp kapan CCTV terakhir di-update.
  final DateTime lastUpdated;

  const CCTVEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.streamUrl,
    required this.status,
    required this.resolution,
    required this.fps,
    required this.bitrate,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    streamUrl,
    status,
    resolution,
    fps,
    bitrate,
    lastUpdated,
  ];
}
