import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/traffic_entity.dart';

/// Kontrak repository untuk fitur traffic.
abstract class TrafficRepository {
  /// Mengambil ringkasan traffic untuk [storeId].
  Future<Either<Failure, TrafficSummaryEntity>> getTrafficSummary(int storeId);

  /// Mengambil data traffic realtime untuk [storeId].
  Future<Either<Failure, RealtimeTrafficEntity>> getRealtimeTraffic(int storeId);
}
