import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/mood_log_entity.dart';
import '../entities/visit_entity.dart';
import '../entities/visitor_entity.dart';

/// Contract untuk VisitorRepository.
abstract class VisitorRepository {
  /// Mengambil daftar visitor berdasarkan store ID.
  Future<Either<Failure, List<VisitorEntity>>> getVisitorList(int storeId);

  /// Mengambil detail visitor beserta riwayat kunjungannya.
  Future<Either<Failure, ({VisitorEntity visitor, List<VisitEntity> visits})>>
  getVisitorDetail(int visitorId);

  /// Mengambil mood timeline untuk satu sesi kunjungan.
  Future<Either<Failure, List<MoodLogEntity>>> getMoodTimeline(
    int visitorId,
    int visitId,
  );
}
