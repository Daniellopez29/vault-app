import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import '../../home/domain/entities.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<PostEntity>>> getSavedPosts();
  Future<Either<Failure, void>> removeSavedPost(String postId);
}