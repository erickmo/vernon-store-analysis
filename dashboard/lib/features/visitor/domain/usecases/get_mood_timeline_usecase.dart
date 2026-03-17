import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/mood_log_entity.dart';
import '../repositories/visitor_repository.dart';

/// Params untuk GetMoodTimelineUseCase.
class GetMoodTimelineParams {
  /// ID visitor pemilik kunjungan.
  final int visitorId;

  /// ID kunjungan yang akan diambil mood timelinenya.
  final int visitId;

  const GetMoodTimelineParams({
    required this.visitorId,
    required this.visitId,
  });
}

/// Usecase untuk mendapatkan mood timeline dari satu sesi kunjungan.
class GetMoodTimelineUseCase {
  final VisitorRepository repository;

  const GetMoodTimelineUseCase(this.repository);

  Future<Either<Failure, List<MoodLogEntity>>> call(
    GetMoodTimelineParams params,
  ) {
    return repository.getMoodTimeline(params.visitorId, params.visitId);
  }
}
