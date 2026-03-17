import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_client.dart';
import '../models/mood_log_model.dart';
import '../models/visit_model.dart';
import '../models/visitor_model.dart';

/// Abstract contract untuk visitor remote datasource.
abstract class VisitorRemoteDataSource {
  /// Mengambil daftar visitor dari API berdasarkan store ID.
  Future<List<VisitorModel>> getVisitorList(int storeId);

  /// Mengambil detail visitor dan daftar kunjungannya dari API.
  Future<({VisitorModel visitor, List<VisitModel> visits})> getVisitorDetail(
    int visitorId,
  );

  /// Mengambil mood timeline dari API untuk satu sesi kunjungan.
  Future<List<MoodLogModel>> getMoodTimeline(int visitorId, int visitId);
}

/// Implementasi konkret VisitorRemoteDataSource yang memanggil backend API.
class VisitorRemoteDataSourceImpl implements VisitorRemoteDataSource {
  final AppHttpClient httpClient;

  const VisitorRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<VisitorModel>> getVisitorList(int storeId) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.visitors(storeId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat daftar visitor',
        statusCode: response.statusCode,
      );
    }

    final dataList = body['data'] as List<dynamic>;
    return dataList
        .map((item) => VisitorModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<({VisitorModel visitor, List<VisitModel> visits})> getVisitorDetail(
    int visitorId,
  ) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.visitorById(visitorId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat detail visitor',
        statusCode: response.statusCode,
      );
    }

    final visitor = VisitorModel.fromJson(
      body['data'] as Map<String, dynamic>,
    );

    final visitsList = (body['visits'] as List<dynamic>)
        .map((item) => VisitModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return (visitor: visitor, visits: visitsList);
  }

  @override
  Future<List<MoodLogModel>> getMoodTimeline(
    int visitorId,
    int visitId,
  ) async {
    final response = await httpClient.get<Map<String, dynamic>>(
      ApiEndpoints.moodTimeline(visitorId, visitId),
    );

    final body = response.data;
    if (body == null || body['success'] != true) {
      throw ServerException(
        body?['message']?.toString() ?? 'Gagal memuat mood timeline',
        statusCode: response.statusCode,
      );
    }

    final dataList = body['data'] as List<dynamic>;
    return dataList
        .map((item) => MoodLogModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
