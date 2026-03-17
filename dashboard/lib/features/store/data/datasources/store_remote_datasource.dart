import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/store_model.dart';

/// Kontrak datasource remote untuk operasi toko.
abstract class StoreRemoteDataSource {
  /// Ambil daftar semua toko dari API.
  ///
  /// Melempar exception jika request gagal.
  Future<List<StoreModel>> getStoreList();

  /// Ambil detail satu toko berdasarkan [storeId] dari API.
  ///
  /// Melempar exception jika request gagal.
  Future<StoreModel> getStoreById(int storeId);
}

/// Implementasi [StoreRemoteDataSource] yang berkomunikasi dengan REST API.
class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final AppHttpClient _client;

  const StoreRemoteDataSourceImpl(this._client);

  @override
  Future<List<StoreModel>> getStoreList() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.stores);
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((item) => StoreModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StoreModel> getStoreById(int storeId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.storeById(storeId),
    );
    return StoreModel.fromJson(response.data!);
  }
}
