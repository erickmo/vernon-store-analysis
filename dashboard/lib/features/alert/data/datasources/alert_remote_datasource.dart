import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/alert_model.dart';

/// Abstract datasource untuk shoplifting alert.
abstract class AlertRemoteDataSource {
  /// Fetch daftar alert dari API.
  Future<List<AlertModel>> getAlertList(int storeId);

  /// Resolve alert via API.
  Future<void> resolveAlert(int alertId, String note);
}

/// Implementasi [AlertRemoteDataSource] menggunakan [AppHttpClient].
class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  final AppHttpClient httpClient;

  const AlertRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<AlertModel>> getAlertList(int storeId) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.alerts(storeId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat daftar alert',
      );
    }

    final dataList = body['data'] as List<dynamic>;
    return dataList
        .map((item) => AlertModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> resolveAlert(int alertId, String note) async {
    final response = await httpClient.put<Map<String, dynamic>>(
      ApiEndpoints.resolveAlert(alertId),
      data: {'note': note},
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal menyelesaikan alert',
      );
    }
  }
}
