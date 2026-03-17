import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/stream_repository.dart';

/// Enum aksi kontrol stream.
enum StreamControlAction {
  startCamera,
  stopCamera,
  startAll,
  stopAll,
}

/// Usecase untuk mengontrol stream kamera (start/stop).
class ControlStreamUseCase {
  final StreamRepository repository;

  const ControlStreamUseCase(this.repository);

  /// Jalankan aksi kontrol stream.
  ///
  /// [cameraId] wajib diisi jika [action] adalah [StreamControlAction.startCamera]
  /// atau [StreamControlAction.stopCamera].
  Future<Either<Failure, void>> call(
    StreamControlAction action, {
    int? cameraId,
  }) {
    switch (action) {
      case StreamControlAction.startCamera:
        assert(cameraId != null, 'cameraId wajib untuk startCamera');
        return repository.startCamera(cameraId!);
      case StreamControlAction.stopCamera:
        assert(cameraId != null, 'cameraId wajib untuk stopCamera');
        return repository.stopCamera(cameraId!);
      case StreamControlAction.startAll:
        return repository.startAllStreams();
      case StreamControlAction.stopAll:
        return repository.stopAllStreams();
    }
  }
}
