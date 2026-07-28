import '../../../core/api_client.dart';
import '../../../core/error.dart';
import '../domain/entities.dart';
import 'models.dart';

abstract class ProfileRemoteDataSource {
  Future<List<AssetModel>> getUserAssets();
  Future<void> addAsset(AssetModel asset, {List<AssetImageUpload> images = const []});
  Future<void> updateAsset(AssetModel asset);
  Future<AssetModel> editAsset(AssetModel asset);
  Future<void> deleteAsset(String assetId);
  Future<AssetModel> uploadAssetPhoto(String assetId, {required List<int> bytes, required String filename});
  Future<AssetModel> deleteAssetPhoto(String assetId, String photoId);
  Future<RestorerProfileModel?> getRestorerProfile(String userId);
  Future<void> saveRestorerProfile(RestorerProfileModel profile);
  Future<List<RestorerProfileModel>> getAllRestorerProfiles();
  Future<void> registerBusiness({
    required String name,
    required List<String> types,
    required String description,
    required String location,
  });

  /// Historial completo de certificaciones de un activo (REGISTERED,
  /// MAINTAINED, RESTORED, TRANSFERRED), no solo la última -- endpoint
  /// público, no requiere sesión.
  Future<List<BlockchainCertificateModel>> getCertificateHistory(String assetId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<List<AssetModel>> getUserAssets() async {
    try {
      // GET /assets/mine filtra por el usuario del JWT en el backend -- el
      // filtro anterior (GET /assets sin auth + filtrar por user_id en el
      // cliente) caía a "sin filtro" si currentUserId() llegaba a leer null
      // en el momento del fetch, mezclando los artículos de todas las
      // cuentas del dispositivo.
      final body = await _client.get('/assets/mine');
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => AssetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar tus artículos: $e');
    }
  }

  @override
  Future<void> addAsset(AssetModel asset, {List<AssetImageUpload> images = const []}) async {
    try {
      // Mismo patrón que crear un post con fotos (ver
      // HomeRemoteDataSourceImpl.createPost): primero se crea el recurso
      // para tener su id real, luego se sube cada foto contra ese id.
      final body = await _client.post('/assets', body: asset.toApiJson());
      final assetId = (body as Map<String, dynamic>)['id'] as String;

      for (final image in images) {
        await _client.postMultipart(
          '/assets/$assetId/photos',
          bytes: image.bytes,
          filename: image.filename,
          fieldName: 'image',
        );
      }
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

  /// A diferencia de updateAsset, no publica nada en el Feed -- es solo
  /// para editar los datos del activo (nombre, marca, condición, etc.),
  /// así que usarlo no debe crear un post duplicado cada vez que se guarda
  /// un cambio en un activo que ya estaba publicado.
  @override
  Future<AssetModel> editAsset(AssetModel asset) async {
    try {
      final body = await _client.put('/assets/${asset.id}', body: asset.toApiJson());
      return AssetModel.fromJson(body as Map<String, dynamic>);
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

  @override
  Future<AssetModel> uploadAssetPhoto(
    String assetId, {
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final body = await _client.postMultipart(
        '/assets/$assetId/photos',
        bytes: bytes,
        filename: filename,
        fieldName: 'image',
      );
      return AssetModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al subir la foto: $e');
    }
  }

  @override
  Future<AssetModel> deleteAssetPhoto(String assetId, String photoId) async {
    try {
      final body = await _client.delete('/assets/$assetId/photos/$photoId');
      return AssetModel.fromJson(body as Map<String, dynamic>);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al eliminar la foto: $e');
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
    required List<String> types,
    required String description,
    required String location,
  }) async {
    try {
      await _client.post('/businesses', body: {
        'name': name,
        'types': types,
        'description': description,
        'location': location,
      });
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al registrar el negocio: $e');
    }
  }

  @override
  Future<List<BlockchainCertificateModel>> getCertificateHistory(String assetId) async {
    try {
      final body = await _client.get(
        '/blockchain-certificates',
        query: {'asset_id': assetId},
        auth: false,
      );
      final list = body as List<dynamic>? ?? const [];
      return list
          .map((e) => BlockchainCertificateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al cargar el historial de certificación: $e');
    }
  }
}
