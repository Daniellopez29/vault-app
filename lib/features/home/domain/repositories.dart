import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PostEntity>>> getFeedPosts();
  Future<Either<Failure, void>> toggleLike(String postId);
  Future<Either<Failure, void>> toggleSave(String postId);
}