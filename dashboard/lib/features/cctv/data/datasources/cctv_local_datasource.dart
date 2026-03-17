import '../models/cctv_model.dart';

/// Abstract datasource untuk CCTV local data (fallback / cache).
abstract class CCTVLocalDataSource {
  /// Get semua CCTV dari local storage.
  Future<List<CCTVModel>> getCCTVList();

  /// Get CCTV berdasarkan ID.
  Future<CCTVModel?> getCCTVById(int id);
}

/// Concrete implementation CCTVLocalDataSource dengan dummy data.
class CCTVLocalDataSourceImpl implements CCTVLocalDataSource {
  static const String _sampleVideo1 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/BigBuckBunny.mp4';
  static const String _sampleVideo2 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ElephantsDream.mp4';
  static const String _sampleVideo3 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerBlazes.mp4';
  static const String _sampleVideo4 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerEscapes.mp4';
  static const String _sampleVideo5 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/ForBiggerFun.mp4';
  static const String _sampleVideo6 =
      'https://commondatastorage.googleapis.com/gtv-videos-library/sample/VolleyballMatch.mp4';

  late final List<CCTVModel> _dummyCCTVs;

  CCTVLocalDataSourceImpl() {
    _initializeDummyData();
  }

  void _initializeDummyData() {
    final now = DateTime.now();

    _dummyCCTVs = [
      CCTVModel(
        id: 1,
        storeId: 1,
        name: 'Entrance Main',
        streamUrl: _sampleVideo1,
        locationZone: 'entry',
        description: 'Kamera pintu masuk utama',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      CCTVModel(
        id: 2,
        storeId: 1,
        name: 'Parking Lot A',
        streamUrl: _sampleVideo2,
        locationZone: 'parking',
        description: 'Kamera area parkir outdoor',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      CCTVModel(
        id: 3,
        storeId: 1,
        name: 'Checkout Counter',
        streamUrl: _sampleVideo3,
        locationZone: 'cashier',
        description: 'Kamera area kasir',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      CCTVModel(
        id: 4,
        storeId: 1,
        name: 'Warehouse',
        streamUrl: _sampleVideo4,
        locationZone: 'warehouse',
        description: 'Kamera gudang belakang',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      CCTVModel(
        id: 5,
        storeId: 1,
        name: 'VIP Room',
        streamUrl: _sampleVideo5,
        locationZone: 'vip',
        description: 'Kamera ruang VIP',
        isActive: false,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      CCTVModel(
        id: 6,
        storeId: 1,
        name: 'Corridor 2F',
        streamUrl: _sampleVideo6,
        locationZone: 'corridor',
        description: 'Kamera koridor lantai 2',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<List<CCTVModel>> getCCTVList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyCCTVs;
  }

  @override
  Future<CCTVModel?> getCCTVById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _dummyCCTVs.firstWhere((cctv) => cctv.id == id);
    } catch (e) {
      return null;
    }
  }
}
