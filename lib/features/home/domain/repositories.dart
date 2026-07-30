import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PostEntity>>> getFeedPosts();

  Future<Either<Failure, void>> toggleLike(String postId, bool currentlyLiked);

  Future<Either<Failure, void>> toggleSave(String postId, bool currentlySaved);

  Future<Either<Failure, void>> createPost({
    required String content,
    required List<PostImageUpload> images,
  });

  Future<Either<Failure, void>> deletePost(String postId);
}

class PostImageUpload {
  final List<int> bytes;
  final String filename;
  const PostImageUpload({required this.bytes, required this.filename});
}
