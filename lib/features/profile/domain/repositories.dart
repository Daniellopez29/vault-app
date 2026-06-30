import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<AssetEntity>>> getUserAssets();
  Future<Either<Failure, void>> deleteAsset(String assetId);
}