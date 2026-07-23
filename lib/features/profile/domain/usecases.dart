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

  Future<Either<Failure, void>> call(AssetEntity asset) =>
      repository.addAsset(asset);
}

class DeleteAssetUseCase {
  final ProfileRepository repository;
  const DeleteAssetUseCase(this.repository);

  Future<Either<Failure, void>> call(String assetId) =>
      repository.deleteAsset(assetId);
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
        type: params.type,
        description: params.description,
        location: params.location,
      );
}

class RegisterBusinessParams {
  final String name;
  final String type;
  final String description;
  final String location;

  const RegisterBusinessParams({
    required this.name,
    required this.type,
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
