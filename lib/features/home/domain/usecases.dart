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

  Future<Either<Failure, void>> call(String postId, bool currentlyLiked) {
    return repository.toggleLike(postId, currentlyLiked);
  }
}

class ToggleSaveUseCase {
  final HomeRepository repository;
  ToggleSaveUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId, bool currentlySaved) {
    return repository.toggleSave(postId, currentlySaved);
  }
}

class CreatePostUseCase {
  final HomeRepository repository;
  CreatePostUseCase(this.repository);

  Future<Either<Failure, void>> call(CreatePostParams params) {
    return repository.createPost(content: params.content, images: params.images);
  }
}

class CreatePostParams {
  final String content;
  final List<PostImageUpload> images;

  const CreatePostParams({required this.content, required this.images});
}