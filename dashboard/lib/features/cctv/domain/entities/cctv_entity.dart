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
  final int id;

  /// ID toko tempat kamera dipasang.
  final int storeId;

  /// Nama CCTV.
  final String name;

  /// URL stream RTSP atau HTTP untuk video.
  final String streamUrl;

  /// Zona lokasi kamera (e.g., "entry", "cashier", "warehouse").
  final String locationZone;

  /// Deskripsi kamera.
  final String? description;

  /// Apakah kamera aktif.
  final bool isActive;

  /// Timestamp kapan CCTV dibuat.
  final DateTime createdAt;

  /// Timestamp kapan CCTV terakhir di-update.
  final DateTime updatedAt;

  const CCTVEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.streamUrl,
    required this.locationZone,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Status derived dari isActive.
  CCTVStatus get status => isActive ? CCTVStatus.online : CCTVStatus.offline;

  @override
  List<Object?> get props => [
    id,
    storeId,
    name,
    streamUrl,
    locationZone,
    description,
    isActive,
    createdAt,
    updatedAt,
  ];
}
