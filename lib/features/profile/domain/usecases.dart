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

class DeleteAssetUseCase {
  final ProfileRepository repository;
  const DeleteAssetUseCase(this.repository);

  Future<Either<Failure, void>> call(String assetId) =>
      repository.deleteAsset(assetId);
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