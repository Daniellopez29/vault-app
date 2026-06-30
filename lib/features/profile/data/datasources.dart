import '../../../core/error.dart';
import 'models.dart';

abstract class ProfileRemoteDataSource {
  Future<List<AssetModel>> getUserAssets();
  Future<void> deleteAsset(String assetId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  // TODO: reemplazar por llamadas reales a la API cuando el backend esté listo.
  // Por ahora no hay artículos: el usuario aún no ha registrado ningún activo.

  final List<AssetModel> _assets = [];

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
}