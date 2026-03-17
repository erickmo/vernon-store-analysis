import '../../domain/entities/behaviour_alert_entity.dart';
import '../../domain/entities/cctv_entity.dart';
import '../models/behaviour_alert_model.dart';
import '../models/cctv_model.dart';

/// Abstract datasource untuk CCTV local data.
abstract class CCTVLocalDataSource {
  /// Get semua CCTV dari local storage.
  Future<List<CCTVModel>> getCCTVList();

  /// Get CCTV berdasarkan ID.
  Future<CCTVModel?> getCCTVById(String id);

  /// Get alerts untuk CCTV tertentu.
  Future<List<BehaviourAlertModel>> getAlertsByCCTV(String cctvId);
}

/// Concrete implementation CCTVLocalDataSource dengan dummy data.
class CCTVLocalDataSourceImpl implements CCTVLocalDataSource {
  static const String _googleSampleVideo1 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4';
  static const String _googleSampleVideo2 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ElephantsDream.mp4';
  static const String _googleSampleVideo3 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerBlazes.mp4';
  static const String _googleSampleVideo4 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerEscapes.mp4';
  static const String _googleSampleVideo5 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerFun.mp4';
  static const String _googleSampleVideo6 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/VolleyballMatch.mp4';

  late final List<CCTVModel> _dummyCCTVs;
  late final Map<String, List<BehaviourAlertModel>> _dummyAlerts;

  CCTVLocalDataSourceImpl() {
    _initializeDummyData();
  }

  void _initializeDummyData() {
    final now = DateTime.now();

    _dummyCCTVs = [
      CCTVModel(
        id: 'cctv_001',
        name: 'Entrance Main',
        location: 'Main Entrance',
        streamUrl: _googleSampleVideo1,
        status: CCTVStatus.online,
        resolution: 1080.0,
        fps: 30,
        bitrate: '5000 kbps',
        lastUpdated: now,
      ),
      CCTVModel(
        id: 'cctv_002',
        name: 'Parking Lot A',
        location: 'Outdoor Parking',
        streamUrl: _googleSampleVideo2,
        status: CCTVStatus.online,
        resolution: 720.0,
        fps: 24,
        bitrate: '3000 kbps',
        lastUpdated: now,
      ),
      CCTVModel(
        id: 'cctv_003',
        name: 'Checkout Counter',
        location: 'Store Floor',
        streamUrl: _googleSampleVideo3,
        status: CCTVStatus.online,
        resolution: 1080.0,
        fps: 30,
        bitrate: '5000 kbps',
        lastUpdated: now,
      ),
      CCTVModel(
        id: 'cctv_004',
        name: 'Warehouse',
        location: 'Back Storage',
        streamUrl: _googleSampleVideo4,
        status: CCTVStatus.online,
        resolution: 720.0,
        fps: 24,
        bitrate: '3000 kbps',
        lastUpdated: now,
      ),
      CCTVModel(
        id: 'cctv_005',
        name: 'VIP Room',
        location: 'Building B',
        streamUrl: _googleSampleVideo5,
        status: CCTVStatus.offline,
        resolution: 1080.0,
        fps: 30,
        bitrate: '5000 kbps',
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      CCTVModel(
        id: 'cctv_006',
        name: 'Corridor 2F',
        location: 'Second Floor',
        streamUrl: _googleSampleVideo6,
        status: CCTVStatus.alert,
        resolution: 720.0,
        fps: 24,
        bitrate: '3000 kbps',
        lastUpdated: now.subtract(const Duration(minutes: 5)),
      ),
    ];

    _dummyAlerts = {
      'cctv_001': [
        BehaviourAlertModel(
          id: 'alert_001_001',
          cctvId: 'cctv_001',
          cctvName: 'Entrance Main',
          type: BehaviourType.loitering,
          confidence: 0.92,
          description: 'Person loitering at entrance for 3+ minutes',
          timestamp: now.subtract(const Duration(minutes: 15)),
          imageUrl: null,
        ),
      ],
      'cctv_002': [
        BehaviourAlertModel(
          id: 'alert_002_001',
          cctvId: 'cctv_002',
          cctvName: 'Parking Lot A',
          type: BehaviourType.fighting,
          confidence: 0.75,
          description: 'Potential altercation detected',
          timestamp: now.subtract(const Duration(hours: 1)),
          imageUrl: null,
        ),
        BehaviourAlertModel(
          id: 'alert_002_002',
          cctvId: 'cctv_002',
          cctvName: 'Parking Lot A',
          type: BehaviourType.running,
          confidence: 0.88,
          description: 'Person running across parking area',
          timestamp: now.subtract(const Duration(hours: 2)),
          imageUrl: null,
        ),
      ],
      'cctv_003': [
        BehaviourAlertModel(
          id: 'alert_003_001',
          cctvId: 'cctv_003',
          cctvName: 'Checkout Counter',
          type: BehaviourType.crowding,
          confidence: 0.68,
          description: 'Unusual crowd detected at counter',
          timestamp: now.subtract(const Duration(minutes: 45)),
          imageUrl: null,
        ),
      ],
      'cctv_004': [],
      'cctv_005': [],
      'cctv_006': [
        BehaviourAlertModel(
          id: 'alert_006_001',
          cctvId: 'cctv_006',
          cctvName: 'Corridor 2F',
          type: BehaviourType.loitering,
          confidence: 0.85,
          description: 'Loitering detected in restricted area',
          timestamp: now.subtract(const Duration(minutes: 5)),
          imageUrl: null,
        ),
      ],
    };
  }

  @override
  Future<List<CCTVModel>> getCCTVList() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyCCTVs;
  }

  @override
  Future<CCTVModel?> getCCTVById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _dummyCCTVs.firstWhere((cctv) => cctv.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<BehaviourAlertModel>> getAlertsByCCTV(String cctvId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyAlerts[cctvId] ?? [];
  }
}
