import 'package:equatable/equatable.dart';

import '../../domain/entities/visitor_entity.dart';

/// Base sealed class untuk state visitor list.
sealed class VisitorState extends Equatable {
  const VisitorState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum data dimuat.
final class VisitorInitial extends VisitorState {
  const VisitorInitial();
}

/// State saat sedang memuat data visitor.
final class VisitorLoading extends VisitorState {
  const VisitorLoading();
}

/// State saat data visitor berhasil dimuat.
final class VisitorLoaded extends VisitorState {
  /// Daftar visitor yang berhasil diambil.
  final List<VisitorEntity> visitors;

  const VisitorLoaded({required this.visitors});

  @override
  List<Object?> get props => [visitors];
}

/// State saat terjadi error saat memuat data visitor.
final class VisitorError extends VisitorState {
  /// Pesan error yang terjadi.
  final String message;

  const VisitorError({required this.message});

  @override
  List<Object?> get props => [message];
}
