import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<MarketplaceItemEntity>>> getItems();
  Future<Either<Failure, List<PromoBannerEntity>>> getPromoBanners();
}