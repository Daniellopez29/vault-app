import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

class GetUserAssetsUseCase implements UseCase<List<AssetEntity>, NoParams> {
  final ProfileRepository repository;
  GetUserAssetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AssetEntity>>> call(NoParams params) {
    return repository.getUserAssets();
  }
}

class DeleteAssetUseCase {
  final ProfileRepository repository;
  DeleteAssetUseCase(this.repository);

  Future<Either<Failure, void>> call(String assetId) {
    return repository.deleteAsset(assetId);
  }
}