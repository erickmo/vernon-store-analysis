import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan satu sesi kunjungan visitor ke toko.
class VisitEntity extends Equatable {
  /// ID unik kunjungan.
  final int id;

  /// ID visitor pemilik kunjungan ini.
  final int visitorId;

  /// ID kamera yang mendeteksi kunjungan.
  final int cameraId;

  /// Waktu masuk area yang terdeteksi.
  final DateTime entryAt;

  /// Waktu keluar area yang terdeteksi. Null jika masih di dalam.
  final DateTime? exitAt;

  /// Durasi kunjungan dalam detik.
  final int dwellSeconds;

  const VisitEntity({
    required this.id,
    required this.visitorId,
    required this.cameraId,
    required this.entryAt,
    this.exitAt,
    required this.dwellSeconds,
  });

  @override
  List<Object?> get props => [
    id,
    visitorId,
    cameraId,
    entryAt,
    exitAt,
    dwellSeconds,
  ];
}
