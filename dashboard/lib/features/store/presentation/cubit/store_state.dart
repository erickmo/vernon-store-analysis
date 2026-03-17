import 'package:equatable/equatable.dart';

import '../../domain/entities/store_entity.dart';

/// Base sealed class untuk state daftar toko.
abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum ada aksi pengambilan data toko.
class StoreInitial extends StoreState {
  const StoreInitial();
}

/// State ketika proses pengambilan data toko sedang berlangsung.
class StoreLoading extends StoreState {
  const StoreLoading();
}

/// State ketika daftar toko berhasil dimuat.
class StoreLoaded extends StoreState {
  /// Daftar toko yang berhasil diambil.
  final List<StoreEntity> stores;

  const StoreLoaded(this.stores);

  @override
  List<Object?> get props => [stores];
}

/// State ketika terjadi error saat mengambil data toko.
class StoreError extends StoreState {
  /// Pesan error yang akan ditampilkan.
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}
