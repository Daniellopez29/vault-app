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

class GetMyAdsUseCase {
  final AdRepository repository;
  const GetMyAdsUseCase(this.repository);

  Future<Either<Failure, List<AdEntity>>> call() => repository.getMyAds();
}

class UpdateAdParams {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String targetSection;
  final String targetId;

  const UpdateAdParams({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetSection,
    required this.targetId,
  });
}

class UpdateAdUseCase {
  final AdRepository repository;
  const UpdateAdUseCase(this.repository);

  Future<Either<Failure, AdEntity>> call(UpdateAdParams params) => repository.updateAd(
        params.id,
        title: params.title,
        description: params.description,
        imageUrl: params.imageUrl,
        targetSection: params.targetSection,
        targetId: params.targetId,
      );
}

class RegisterAdImpressionUseCase {
  final AdRepository repository;
  const RegisterAdImpressionUseCase(this.repository);

  Future<void> call(String id) => repository.registerImpression(id);
}

class RegisterAdClickUseCase {
  final AdRepository repository;
  const RegisterAdClickUseCase(this.repository);

  Future<void> call(String id) => repository.registerClick(id);
}
