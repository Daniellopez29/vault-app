import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

class GetMarketplaceItemsUseCase
    implements UseCase<List<MarketplaceItemEntity>, NoParams> {
  final MarketplaceRepository repository;
  GetMarketplaceItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MarketplaceItemEntity>>> call(NoParams params) {
    return repository.getItems();
  }
}

class GetPromoBannersUseCase
    implements UseCase<List<PromoBannerEntity>, NoParams> {
  final MarketplaceRepository repository;
  GetPromoBannersUseCase(this.repository);

  @override
  Future<Either<Failure, List<PromoBannerEntity>>> call(NoParams params) {
    return repository.getPromoBanners();
  }
}