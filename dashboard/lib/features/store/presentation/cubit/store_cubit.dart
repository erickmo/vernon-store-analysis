import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_store_by_id_usecase.dart';
import '../../domain/usecases/get_store_list_usecase.dart';
import 'store_state.dart';

/// Cubit yang mengelola state daftar dan detail toko.
///
/// Alur normal: [StoreInitial] → [StoreLoading] → [StoreLoaded] / [StoreError].
class StoreCubit extends Cubit<StoreState> {
  final GetStoreListUseCase _getStoreListUseCase;
  final GetStoreByIdUseCase _getStoreByIdUseCase;

  StoreCubit({
    required GetStoreListUseCase getStoreListUseCase,
    required GetStoreByIdUseCase getStoreByIdUseCase,
  })  : _getStoreListUseCase = getStoreListUseCase,
        _getStoreByIdUseCase = getStoreByIdUseCase,
        super(const StoreInitial());

  /// Mengambil daftar semua toko dari API.
  ///
  /// Emit [StoreLoading] saat proses, [StoreLoaded] jika berhasil,
  /// atau [StoreError] jika gagal.
  Future<void> loadStores() async {
    emit(const StoreLoading());

    final result = await _getStoreListUseCase();

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (stores) => emit(StoreLoaded(stores)),
    );
  }

  /// Mengambil detail toko berdasarkan [storeId].
  ///
  /// Emit [StoreLoading] saat proses, [StoreLoaded] (list 1 item) jika berhasil,
  /// atau [StoreError] jika gagal.
  Future<void> loadStoreById(int storeId) async {
    emit(const StoreLoading());

    final result = await _getStoreByIdUseCase(
      GetStoreByIdParams(storeId: storeId),
    );

    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (store) => emit(StoreLoaded([store])),
    );
  }
}
