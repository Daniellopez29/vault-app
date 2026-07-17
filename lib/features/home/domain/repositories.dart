import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PostEntity>>> getFeedPosts();

  /// [currentlyLiked] decide si se llama a dar-like o quitar-like -- el
  /// backend expone POST/DELETE separados, no un solo "toggle".
  Future<Either<Failure, void>> toggleLike(String postId, bool currentlyLiked);

  /// No hay tabla de "guardados" en el backend; queda como estado local
  /// de la sesión (no persiste entre reinicios de la app).
  Future<Either<Failure, void>> toggleSave(String postId);

  /// Crea un post con texto y, opcionalmente, una o más fotos. El texto es
  /// obligatorio para el backend aunque haya fotos (CreatePostRequest lo
  /// exige); las fotos se suben en llamadas separadas después de crear el
  /// post. Puede devolver [ModerationFailure] si el contenido es tóxico o
  /// el servicio de moderación no responde.
  Future<Either<Failure, void>> createPost({
    required String content,
    required List<PostImageUpload> images,
  });
}

/// Una imagen elegida por el usuario, todavía sin subir.
class PostImageUpload {
  final List<int> bytes;
  final String filename;

  const PostImageUpload({required this.bytes, required this.filename});
}