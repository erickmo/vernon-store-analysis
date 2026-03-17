import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan data visitor.
class VisitorEntity extends Equatable {
  /// ID unik visitor.
  final int id;

  /// ID toko tempat visitor terdeteksi.
  final int storeId;

  /// UID unik person dari sistem pengenalan wajah.
  final String personUid;

  /// Label / kategori visitor (misal: VIP Customer).
  final String? label;

  /// Waktu pertama kali terdeteksi.
  final DateTime firstSeenAt;

  /// Waktu terakhir kali terdeteksi.
  final DateTime lastSeenAt;

  /// Total kunjungan yang telah tercatat.
  final int totalVisits;

  /// Waktu data dibuat di server.
  final DateTime createdAt;

  const VisitorEntity({
    required this.id,
    required this.storeId,
    required this.personUid,
    this.label,
    required this.firstSeenAt,
    required this.lastSeenAt,
    required this.totalVisits,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    storeId,
    personUid,
    label,
    firstSeenAt,
    lastSeenAt,
    totalVisits,
    createdAt,
  ];
}
