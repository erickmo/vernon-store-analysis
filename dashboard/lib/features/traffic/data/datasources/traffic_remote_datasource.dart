import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/traffic_model.dart';

/// Kontrak datasource remote untuk fitur traffic.
abstract class TrafficRemoteDataSource {
  /// Mengambil ringkasan traffic untuk [storeId].
  ///
  /// Melempar [ServerException], [NetworkException], [UnauthorizedException],
  /// atau [NotFoundException] jika terjadi kesalahan.
  Future<TrafficSummaryModel> getTrafficSummary(int storeId);

  /// Mengambil data traffic realtime untuk [storeId].
  ///
  /// Melempar [ServerException], [NetworkException], [UnauthorizedException],
  /// atau [NotFoundException] jika terjadi kesalahan.
  Future<RealtimeTrafficModel> getRealtimeTraffic(int storeId);
}

/// Implementasi [TrafficRemoteDataSource] menggunakan [AppHttpClient].
class TrafficRemoteDataSourceImpl implements TrafficRemoteDataSource {
  final AppHttpClient _httpClient;

  const TrafficRemoteDataSourceImpl(this._httpClient);

  @override
  Future<TrafficSummaryModel> getTrafficSummary(int storeId) async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.traffic(storeId),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Respons server kosong');
    }

    return TrafficSummaryModel.fromJson(data);
  }

  @override
  Future<RealtimeTrafficModel> getRealtimeTraffic(int storeId) async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.realtimeTraffic(storeId),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Respons server kosong');
    }

    return RealtimeTrafficModel.fromJson(data);
  }
}
