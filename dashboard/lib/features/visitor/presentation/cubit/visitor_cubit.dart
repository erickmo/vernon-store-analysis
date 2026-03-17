import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_visitor_list_usecase.dart';
import 'visitor_state.dart';

/// Cubit untuk mengelola state daftar visitor.
class VisitorCubit extends Cubit<VisitorState> {
  final GetVisitorListUseCase getVisitorListUseCase;

  VisitorCubit({required this.getVisitorListUseCase})
      : super(const VisitorInitial());

  /// Memuat daftar visitor dari repository berdasarkan store ID.
  Future<void> loadVisitors(int storeId) async {
    emit(const VisitorLoading());

    final result = await getVisitorListUseCase(
      GetVisitorListParams(storeId: storeId),
    );

    result.fold(
      (failure) => emit(VisitorError(message: failure.message)),
      (visitors) => emit(VisitorLoaded(visitors: visitors)),
    );
  }
}
