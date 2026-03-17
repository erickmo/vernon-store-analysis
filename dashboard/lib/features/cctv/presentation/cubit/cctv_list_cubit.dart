import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_cctv_list_usecase.dart';
import 'cctv_list_state.dart';

/// Cubit untuk mengelola state CCTV list.
class CCTVListCubit extends Cubit<CCTVListState> {
  final GetCCTVListUseCase getCCTVListUseCase;

  CCTVListCubit({required this.getCCTVListUseCase})
      : super(const CCTVListInitial());

  /// Memuat daftar kamera dari repository untuk [storeId].
  Future<void> loadCCTVList(int storeId) async {
    emit(const CCTVListLoading());

    final result = await getCCTVListUseCase(storeId);

    result.fold(
      (failure) => emit(CCTVListError(message: failure.message)),
      (cctvs) => emit(CCTVListLoaded(cctvs: cctvs)),
    );
  }
}
