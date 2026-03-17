import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/analytics_dashboard_model.dart';

/// Kontrak datasource remote untuk fitur analitik.
abstract class AnalyticsRemoteDataSource {
  /// Mengambil data dashboard analitik dari server untuk [storeId].
  ///
  /// Melempar [ServerException], [NetworkException], [UnauthorizedException],
  /// atau [NotFoundException] jika terjadi kesalahan.
  Future<AnalyticsDashboardModel> getDashboard(int storeId);
}

/// Implementasi [AnalyticsRemoteDataSource] menggunakan [AppHttpClient].
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final AppHttpClient _httpClient;

  const AnalyticsRemoteDataSourceImpl(this._httpClient);

  @override
  Future<AnalyticsDashboardModel> getDashboard(int storeId) async {
    final response = await _httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsDashboard(storeId),
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Respons server kosong');
    }

    return AnalyticsDashboardModel.fromJson(data);
  }
}
