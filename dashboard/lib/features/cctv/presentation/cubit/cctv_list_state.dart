import 'package:equatable/equatable.dart';

import '../../domain/entities/cctv_entity.dart';

/// Base class untuk CCTVListState.
abstract class CCTVListState extends Equatable {
  const CCTVListState();

  @override
  List<Object?> get props => [];
}

/// Initial state untuk CCTV list.
class CCTVListInitial extends CCTVListState {
  const CCTVListInitial();
}

/// Loading state saat memuat data CCTV.
class CCTVListLoading extends CCTVListState {
  const CCTVListLoading();
}

/// Loaded state dengan data CCTV.
class CCTVListLoaded extends CCTVListState {
  /// List dari CCTV entities yang berhasil dimuat.
  final List<CCTVEntity> cctvs;

  const CCTVListLoaded({required this.cctvs});

  @override
  List<Object?> get props => [cctvs];
}

/// Error state saat terjadi kesalahan memuat CCTV.
class CCTVListError extends CCTVListState {
  /// Pesan error yang terjadi.
  final String message;

  const CCTVListError({required this.message});

  @override
  List<Object?> get props => [message];
}
