import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/cctv_model.dart';

/// Abstract datasource untuk CCTV remote data.
abstract class CCTVRemoteDataSource {
  /// Fetch daftar kamera dari API.
  Future<List<CCTVModel>> getCCTVList(int storeId);

  /// Fetch kamera berdasarkan ID dari API.
  Future<CCTVModel> getCCTVById(int storeId, int cameraId);
}

/// Implementasi [CCTVRemoteDataSource] menggunakan [AppHttpClient].
class CCTVRemoteDataSourceImpl implements CCTVRemoteDataSource {
  final AppHttpClient httpClient;

  const CCTVRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<CCTVModel>> getCCTVList(int storeId) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.cameras(storeId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat daftar kamera',
      );
    }

    final dataList = body['data'] as List<dynamic>;
    return dataList
        .map((item) => CCTVModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CCTVModel> getCCTVById(int storeId, int cameraId) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.cameraById(storeId, cameraId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat data kamera',
      );
    }

    final data = body['data'] as Map<String, dynamic>;
    return CCTVModel.fromJson(data);
  }
}
