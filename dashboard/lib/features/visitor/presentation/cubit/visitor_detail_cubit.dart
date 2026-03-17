import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_mood_timeline_usecase.dart';
import '../../domain/usecases/get_visitor_detail_usecase.dart';
import 'visitor_detail_state.dart';

/// Cubit untuk mengelola state detail visitor dan mood timeline.
class VisitorDetailCubit extends Cubit<VisitorDetailState> {
  final GetVisitorDetailUseCase getVisitorDetailUseCase;
  final GetMoodTimelineUseCase getMoodTimelineUseCase;

  VisitorDetailCubit({
    required this.getVisitorDetailUseCase,
    required this.getMoodTimelineUseCase,
  }) : super(const VisitorDetailInitial());

  /// Memuat detail visitor beserta riwayat kunjungannya.
  Future<void> loadVisitorDetail(int visitorId) async {
    emit(const VisitorDetailLoading());

    final result = await getVisitorDetailUseCase(
      GetVisitorDetailParams(visitorId: visitorId),
    );

    result.fold(
      (failure) => emit(VisitorDetailError(message: failure.message)),
      (data) => emit(
        VisitorDetailLoaded(
          visitor: data.visitor,
          visits: data.visits,
        ),
      ),
    );
  }

  /// Memilih kunjungan dan memuat mood timeline untuk kunjungan tersebut.
  Future<void> selectVisitAndLoadMoodTimeline(int visitId) async {
    final current = state;
    if (current is! VisitorDetailLoaded) return;

    emit(
      current.copyWith(
        selectedVisitId: visitId,
        isMoodTimelineLoading: true,
        moodTimelineError: null,
      ),
    );

    final result = await getMoodTimelineUseCase(
      GetMoodTimelineParams(
        visitorId: current.visitor.id,
        visitId: visitId,
      ),
    );

    result.fold(
      (failure) {
        if (state is VisitorDetailLoaded) {
          emit(
            (state as VisitorDetailLoaded).copyWith(
              isMoodTimelineLoading: false,
              moodTimelineError: failure.message,
            ),
          );
        }
      },
      (moodLogs) {
        if (state is VisitorDetailLoaded) {
          emit(
            (state as VisitorDetailLoaded).copyWith(
              isMoodTimelineLoading: false,
              moodTimeline: moodLogs,
              moodTimelineError: null,
            ),
          );
        }
      },
    );
  }
}
