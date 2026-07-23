import '../../../core/api_client.dart';
import '../../../core/error.dart';
import 'models.dart';

abstract class ProfileRemoteDataSource {
  Future<List<AssetModel>> getUserAssets();
  Future<void> addAsset(AssetModel asset);
  Future<void> updateAsset(AssetModel asset);
  Future<void> deleteAsset(String assetId);
  Future<RestorerProfileModel?> getRestorerProfile(String userId);
  Future<void> saveRestorerProfile(RestorerProfileModel profile);
  Future<List<RestorerProfileModel>> getAllRestorerProfiles();
  Future<void> registerBusiness({
    required String name,
    required String type,
    required String description,
    required String location,
  });
}

/// [currentUserId] filtra GET /assets (que devuelve los de todos los
/// usuarios) a solo los del dueño de la sesión -- el backend no tiene un
/// endpoint "mis activos" todavía.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _client;
  final String? Function() _currentUserId;

  ProfileRemoteDataSourceImpl(this._client, {required this._currentUserId});

  @override
  Future<List<AssetModel>> getUserAssets() async {
    try {
      final body = await _client.get('/assets', auth: false);
      final list = body as List<dynamic>? ?? const [];
      final userId = _currentUserId();
      return list
          .map((e) => e as Map<String, dynamic>)
          .where((json) => userId == null || json['user_id'] == userId)
          .map(AssetModel.fromJson)
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus artículos: $e');
    }
  }

  @override
  Future<void> addAsset(AssetModel asset) async {
    try {
      await _client.post('/assets', body: asset.toApiJson());
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al registrar el activo: $e');
    }
  }

  @override
  Future<void> updateAsset(AssetModel asset) async {
    try {
      await _client.put('/assets/${asset.id}', body: asset.toApiJson());

      // "Publicar en el Feed" no es un campo de assets -- se traduce a un
      // post real con asset_id, para que aparezca en el feed de todos.
      if (asset.isPublished) {
        await _client.post('/posts', body: {
          'content': asset.publishCaption ?? '¡Mira mi ${asset.name}!',
          'asset_id': asset.id,
        });
      }
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al actualizar el activo: $e');
    }
  }

  @override
  Future<void> deleteAsset(String assetId) async {
    try {
      await _client.delete('/assets/$assetId');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar el activo: $e');
    }
  }

  /// GET /restorerprofiles/{userId} devuelve 404 ("el perfil no existe")
  /// cuando el usuario aún no tiene uno -- se traduce a `null`, que es lo
  /// que la UI ya espera (`RestorerProfileStatus.empty`).
  @override
  Future<RestorerProfileModel?> getRestorerProfile(String userId) async {
    try {
      final body = await _client.get('/restorerprofiles/$userId', auth: false);
      return RestorerProfileModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      return null;
    } catch (e) {
      throw ServerFailure('Error al cargar tu perfil de restaurador: $e');
    }
  }

  @override
  Future<void> saveRestorerProfile(RestorerProfileModel profile) async {
    try {
      await _client.put('/restorerprofiles/${profile.userId}', body: {
        'bio': profile.bio,
        'specialties': profile.specialties,
        'services': profile.services
            .map((s) => {
                  'title': s.title,
                  'description': s.description,
                  'price': s.price,
                })
            .toList(),
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al guardar tu perfil de restaurador: $e');
    }
  }

  @override
  Future<List<RestorerProfileModel>> getAllRestorerProfiles() async {
    try {
      final body = await _client.get('/restorerprofiles', auth: false);
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => RestorerProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar el directorio de especialistas: $e');
    }
  }

  @override
  Future<void> registerBusiness({
    required String name,
    required String type,
    required String description,
    required String location,
  }) async {
    try {
      await _client.post('/businesses', body: {
        'name': name,
        'type': type,
        'description': description,
        'location': location,
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al registrar el negocio: $e');
    }
  }
}
