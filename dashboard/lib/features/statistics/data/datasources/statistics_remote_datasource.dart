import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/behavior_model.dart';
import '../models/kpi_model.dart';

/// Abstract contract untuk statistics remote datasource.
abstract class StatisticsRemoteDataSource {
  /// Mengambil data KPI dari API berdasarkan store ID.
  Future<KpiModel> getKpi(int storeId);

  /// Mengambil data customer behavior dari API berdasarkan store ID.
  Future<BehaviorModel> getBehavior(int storeId);
}

/// Implementasi konkret StatisticsRemoteDataSource yang memanggil backend API.
class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final AppHttpClient httpClient;

  const StatisticsRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<KpiModel> getKpi(int storeId) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.statsKpi(storeId),
    );

    final body = response.data;
    if (body == null) {
      throw ServerException(
        'Respons KPI kosong dari server',
        statusCode: response.statusCode,
      );
    }

    return KpiModel.fromJson(body);
  }

  @override
  Future<BehaviorModel> getBehavior(int storeId) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.statsBehavior(storeId),
    );

    final body = response.data;
    if (body == null) {
      throw ServerException(
        'Respons behavior kosong dari server',
        statusCode: response.statusCode,
      );
    }

    return BehaviorModel.fromJson(body);
  }
}
