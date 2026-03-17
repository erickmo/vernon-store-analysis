import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/analytics_dashboard_entity.dart';

/// Kontrak repository untuk fitur analitik.
abstract class AnalyticsRepository {
  /// Mengambil data dashboard analitik untuk [storeId].
  ///
  /// Mengembalikan [AnalyticsDashboardEntity] jika berhasil,
  /// atau [Failure] jika terjadi kesalahan.
  Future<Either<Failure, AnalyticsDashboardEntity>> getDashboard(int storeId);
}
