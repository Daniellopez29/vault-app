import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../../core/usecase.dart';
import 'entities.dart';
import 'repositories.dart';

class GetFeedPostsUseCase implements UseCase<List<PostEntity>, NoParams> {
  final HomeRepository repository;
  GetFeedPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) {
    return repository.getFeedPosts();
  }
}

class ToggleLikeUseCase {
  final HomeRepository repository;
  ToggleLikeUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) {
    return repository.toggleLike(postId);
  }
}

class ToggleSaveUseCase {
  final HomeRepository repository;
  ToggleSaveUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) {
    return repository.toggleSave(postId);
  }
}