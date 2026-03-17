import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/stream_status_entity.dart';
import '../repositories/stream_repository.dart';

/// Usecase untuk mendapatkan status stream semua kamera.
class GetStreamStatusUseCase {
  final StreamRepository repository;

  const GetStreamStatusUseCase(this.repository);

  Future<Either<Failure, StreamStatusEntity>> call() {
    return repository.getStreamStatus();
  }
}
