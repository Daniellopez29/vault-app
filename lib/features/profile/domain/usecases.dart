import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

class GetUserAssetsUseCase implements UseCase<List<AssetEntity>, NoParams> {
  final ProfileRepository repository;
  const GetUserAssetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AssetEntity>>> call(NoParams params) =>
      repository.getUserAssets();
}

class AddAssetUseCase {
  final ProfileRepository repository;
  const AddAssetUseCase(this.repository);

  Future<Either<Failure, void>> call(AssetEntity asset, {List<AssetImageUpload> images = const []}) =>
      repository.addAsset(asset, images: images);
}

class DeleteAssetUseCase {
  final ProfileRepository repository;
  const DeleteAssetUseCase(this.repository);

  Future<Either<Failure, void>> call(String assetId) =>
      repository.deleteAsset(assetId);
}

/// Edita los datos del activo (nombre, marca, categoría, etc.) -- no toca
/// su estado de venta/publicación, esos los maneja SetAssetForSaleUseCase/
/// SetAssetPublishedUseCase.
class EditAssetUseCase {
  final ProfileRepository repository;
  const EditAssetUseCase(this.repository);

  Future<Either<Failure, AssetEntity>> call(AssetEntity asset) =>
      repository.editAsset(asset);
}

class UploadAssetPhotoUseCase {
  final ProfileRepository repository;
  const UploadAssetPhotoUseCase(this.repository);

  Future<Either<Failure, AssetEntity>> call(
    String assetId, {
    required List<int> bytes,
    required String filename,
  }) =>
      repository.uploadAssetPhoto(assetId, bytes: bytes, filename: filename);
}

class DeleteAssetPhotoUseCase {
  final ProfileRepository repository;
  const DeleteAssetPhotoUseCase(this.repository);

  Future<Either<Failure, AssetEntity>> call(String assetId, String photoId) =>
      repository.deleteAssetPhoto(assetId, photoId);
}

/// Pone o quita un activo de venta. Al poner en venta guarda precio y
/// descripciÃ³n; al quitar, los limpia. La regla de negocio vive aquÃ­.
class SetAssetForSaleUseCase {
  final ProfileRepository repository;
  const SetAssetForSaleUseCase(this.repository);

  Future<Either<Failure, void>> call(SetForSaleParams params) {
    final updated = params.asset.copyWith(
      isForSale: params.forSale,
      salePrice: params.forSale ? params.price : null,
      saleDescription: params.forSale ? params.description : null,
    );
    return repository.updateAsset(updated);
  }
}

/// Publica o despublica un activo en el Feed. Al publicar guarda el caption;
/// al despublicar, lo limpia. La regla de negocio vive aquÃ­.
class SetAssetPublishedUseCase {
  final ProfileRepository repository;
  const SetAssetPublishedUseCase(this.repository);

  Future<Either<Failure, void>> call(SetPublishedParams params) {
    final updated = params.asset.copyWith(
      isPublished: params.published,
      publishCaption: params.published ? params.caption : null,
    );
    return repository.updateAsset(updated);
  }
}

class GetRestorerProfileUseCase {
  final ProfileRepository repository;
  const GetRestorerProfileUseCase(this.repository);

  Future<Either<Failure, RestorerProfileEntity?>> call(String userId) =>
      repository.getRestorerProfile(userId);
}

class SaveRestorerProfileUseCase {
  final ProfileRepository repository;
  const SaveRestorerProfileUseCase(this.repository);

  Future<Either<Failure, void>> call(RestorerProfileEntity profile) =>
      repository.saveRestorerProfile(profile);
}

/// Trae el directorio de especialistas con servicios publicados.
class GetAllRestorerProfilesUseCase {
  final ProfileRepository repository;
  const GetAllRestorerProfilesUseCase(this.repository);

  Future<Either<Failure, List<RestorerProfileEntity>>> call() =>
      repository.getAllRestorerProfiles();
}

class RegisterBusinessUseCase {
  final ProfileRepository repository;
  const RegisterBusinessUseCase(this.repository);

  Future<Either<Failure, void>> call(RegisterBusinessParams params) => repository.registerBusiness(
        name: params.name,
        types: params.types,
        description: params.description,
        location: params.location,
      );
}

class RegisterBusinessParams {
  final String name;
  final List<String> types;
  final String description;
  final String location;

  const RegisterBusinessParams({
    required this.name,
    required this.types,
    required this.description,
    required this.location,
  });
}

class SetForSaleParams {
  final AssetEntity asset;
  final bool forSale;
  final double? price;
  final String? description;

  const SetForSaleParams({
    required this.asset,
    required this.forSale,
    this.price,
    this.description,
  });
}

class SetPublishedParams {
  final AssetEntity asset;
  final bool published;
  final String? caption;

  const SetPublishedParams({
    required this.asset,
    required this.published,
    this.caption,
  });
}

class GetCertificateHistoryUseCase {
  final ProfileRepository repository;
  const GetCertificateHistoryUseCase(this.repository);

  Future<Either<Failure, List<BlockchainCertificateEntity>>> call(String assetId) =>
      repository.getCertificateHistory(assetId);
}
