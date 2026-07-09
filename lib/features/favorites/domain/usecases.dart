import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import '../../home/domain/entities.dart';
import 'repositories.dart';

class GetSavedPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final FavoritesRepository repository;
  const GetSavedPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) =>
      repository.getSavedPosts();
}

class RemoveSavedPostUseCase {
  final FavoritesRepository repository;
  const RemoveSavedPostUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) =>
      repository.removeSavedPost(postId);
}