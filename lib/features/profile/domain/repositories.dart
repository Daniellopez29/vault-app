import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<AssetEntity>>> getUserAssets();
  Future<Either<Failure, void>> addAsset(AssetEntity asset);
  Future<Either<Failure, void>> updateAsset(AssetEntity asset);
  Future<Either<Failure, void>> deleteAsset(String assetId);
  Future<Either<Failure, RestorerProfileEntity?>> getRestorerProfile(String userId);
  Future<Either<Failure, void>> saveRestorerProfile(RestorerProfileEntity profile);

  /// Registra el negocio del usuario (tabla `businesses`: name/type/
  /// description/location). [type] debe ser 'restaurador' o 'servicio'.
  Future<Either<Failure, void>> registerBusiness({
    required String name,
    required String type,
    required String description,
    required String location,
  });
}