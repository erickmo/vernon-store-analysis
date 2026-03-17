import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_alert_list_usecase.dart';
import '../../domain/usecases/resolve_alert_usecase.dart';
import 'alert_state.dart';

/// Cubit untuk mengelola state daftar shoplifting alert.
class AlertCubit extends Cubit<AlertState> {
  final GetAlertListUseCase getAlertListUseCase;
  final ResolveAlertUseCase resolveAlertUseCase;

  AlertCubit({
    required this.getAlertListUseCase,
    required this.resolveAlertUseCase,
  }) : super(const AlertInitial());

  /// Memuat daftar alert untuk [storeId].
  Future<void> loadAlerts(int storeId) async {
    emit(const AlertLoading());

    final result = await getAlertListUseCase(storeId);

    result.fold(
      (failure) => emit(AlertError(failure.message)),
      (alerts) => emit(AlertLoaded(alerts)),
    );
  }

  /// Menyelesaikan alert [alertId] dengan [note] dan reload list.
  Future<void> resolveAlert(int storeId, int alertId, String note) async {
    emit(AlertResolving(alertId));

    final result = await resolveAlertUseCase(alertId, note);

    await result.fold(
      (failure) async => emit(AlertError(failure.message)),
      (_) async {
        emit(AlertResolved(alertId));
        await loadAlerts(storeId);
      },
    );
  }
}
