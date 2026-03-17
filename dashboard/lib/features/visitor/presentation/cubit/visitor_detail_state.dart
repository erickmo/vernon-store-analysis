import 'package:equatable/equatable.dart';

import '../../domain/entities/mood_log_entity.dart';
import '../../domain/entities/visit_entity.dart';
import '../../domain/entities/visitor_entity.dart';

/// Base sealed class untuk state visitor detail.
sealed class VisitorDetailState extends Equatable {
  const VisitorDetailState();

  @override
  List<Object?> get props => [];
}

/// State awal sebelum data detail dimuat.
final class VisitorDetailInitial extends VisitorDetailState {
  const VisitorDetailInitial();
}

/// State saat sedang memuat detail visitor.
final class VisitorDetailLoading extends VisitorDetailState {
  const VisitorDetailLoading();
}

/// State saat detail visitor berhasil dimuat.
final class VisitorDetailLoaded extends VisitorDetailState {
  /// Data visitor yang berhasil diambil.
  final VisitorEntity visitor;

  /// Riwayat kunjungan visitor.
  final List<VisitEntity> visits;

  /// ID kunjungan yang sedang dipilih untuk ditampilkan mood timelinenya.
  final int? selectedVisitId;

  /// Daftar mood log dari kunjungan yang dipilih. Null jika belum dimuat.
  final List<MoodLogEntity>? moodTimeline;

  /// True saat mood timeline sedang dimuat.
  final bool isMoodTimelineLoading;

  /// Pesan error khusus untuk mood timeline. Null jika tidak ada error.
  final String? moodTimelineError;

  const VisitorDetailLoaded({
    required this.visitor,
    required this.visits,
    this.selectedVisitId,
    this.moodTimeline,
    this.isMoodTimelineLoading = false,
    this.moodTimelineError,
  });

  VisitorDetailLoaded copyWith({
    VisitorEntity? visitor,
    List<VisitEntity>? visits,
    int? selectedVisitId,
    List<MoodLogEntity>? moodTimeline,
    bool? isMoodTimelineLoading,
    String? moodTimelineError,
  }) {
    return VisitorDetailLoaded(
      visitor: visitor ?? this.visitor,
      visits: visits ?? this.visits,
      selectedVisitId: selectedVisitId ?? this.selectedVisitId,
      moodTimeline: moodTimeline ?? this.moodTimeline,
      isMoodTimelineLoading:
          isMoodTimelineLoading ?? this.isMoodTimelineLoading,
      moodTimelineError: moodTimelineError ?? this.moodTimelineError,
    );
  }

  @override
  List<Object?> get props => [
    visitor,
    visits,
    selectedVisitId,
    moodTimeline,
    isMoodTimelineLoading,
    moodTimelineError,
  ];
}

/// State saat terjadi error saat memuat detail visitor.
final class VisitorDetailError extends VisitorDetailState {
  /// Pesan error yang terjadi.
  final String message;

  const VisitorDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
