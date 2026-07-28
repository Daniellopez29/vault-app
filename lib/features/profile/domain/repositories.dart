import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<AssetEntity>>> getUserAssets();
  Future<Either<Failure, void>> addAsset(AssetEntity asset, {List<AssetImageUpload> images = const []});
  Future<Either<Failure, void>> updateAsset(AssetEntity asset);
  Future<Either<Failure, AssetEntity>> editAsset(AssetEntity asset);
  Future<Either<Failure, void>> deleteAsset(String assetId);
  Future<Either<Failure, AssetEntity>> uploadAssetPhoto(
    String assetId, {
    required List<int> bytes,
    required String filename,
  });
  Future<Either<Failure, AssetEntity>> deleteAssetPhoto(String assetId, String photoId);
  Future<Either<Failure, RestorerProfileEntity?>> getRestorerProfile(String userId);
  Future<Either<Failure, void>> saveRestorerProfile(RestorerProfileEntity profile);

  /// Todos los perfiles de especialista con servicios publicados, para el
  /// directorio publico: quien ofrece que.
  Future<Either<Failure, List<RestorerProfileEntity>>> getAllRestorerProfiles();

  /// Registra el negocio del usuario (tabla `businesses`: name/type/
  /// description/location). [type] debe ser 'restaurador' o 'servicio'.
  Future<Either<Failure, void>> registerBusiness({
    required String name,
    required List<String> types,
    required String description,
    required String location,
  });

  Future<Either<Failure, List<BlockchainCertificateEntity>>> getCertificateHistory(
    String assetId,
  );
}
