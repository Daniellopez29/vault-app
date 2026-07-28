import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';
import 'repositories.dart';

class GetActiveAdsUseCase {
  final AdRepository repository;
  const GetActiveAdsUseCase(this.repository);

  Future<Either<Failure, List<AdEntity>>> call(String section) =>
      repository.getActiveAds(section);
}

class CreateAdParams {
  final String title;
  final String description;
  final String imageUrl;
  final String targetSection;
  final String targetId;

  const CreateAdParams({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetSection,
    required this.targetId,
  });
}

class CreateAdUseCase {
  final AdRepository repository;
  const CreateAdUseCase(this.repository);

  Future<Either<Failure, AdEntity>> call(CreateAdParams params) => repository.createAd(
        title: params.title,
        description: params.description,
        imageUrl: params.imageUrl,
        targetSection: params.targetSection,
        targetId: params.targetId,
      );
}

class DeleteAdUseCase {
  final AdRepository repository;
  const DeleteAdUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.deleteAd(id);
}
