import '../../../core/error.dart';
import 'models.dart';

abstract class ProfileRemoteDataSource {
  Future<List<AssetModel>> getUserAssets();
  Future<void> deleteAsset(String assetId);
  Future<RestorerProfileModel?> getRestorerProfile(String userId);
  Future<void> saveRestorerProfile(RestorerProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final List<AssetModel> _assets = [];
  RestorerProfileModel? _restorerProfile;

  @override
  Future<List<AssetModel>> getUserAssets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return List.of(_assets);
    } catch (e) {
      throw ServerFailure('Error al cargar tus artículos: $e');
    }
  }

  @override
  Future<void> deleteAsset(String assetId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _assets.removeWhere((a) => a.id == assetId);
  }

  @override
  Future<RestorerProfileModel?> getRestorerProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _restorerProfile;
  }

  @override
  Future<void> saveRestorerProfile(RestorerProfileModel profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _restorerProfile = profile;
  }
}