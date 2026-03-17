import 'package:equatable/equatable.dart';

/// Entity yang merepresentasikan satu toko Vernon Store.
class StoreEntity extends Equatable {
  /// ID unik toko.
  final int id;

  /// Nama toko.
  final String name;

  /// Lokasi / alamat toko.
  final String location;

  /// Timezone toko, contoh: "Asia/Jakarta".
  final String timezone;

  /// Deskripsi opsional toko.
  final String? description;

  /// Status aktif toko.
  final bool isActive;

  /// Waktu pembuatan data toko dalam ISO 8601.
  final String createdAt;

  /// Waktu terakhir update data toko dalam ISO 8601.
  final String updatedAt;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.timezone,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        timezone,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}
