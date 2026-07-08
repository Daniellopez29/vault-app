import 'models.dart';

/// Comentarios de prueba mientras el backend (con el NLP) no está disponible.
/// Reemplazar por llamadas reales en [CommentsRemoteDataSourceImpl].
abstract class CommentsFixtures {
  static List<CommentModel> get mock => const [
    CommentModel(
      id: 'c1',
      targetId: 'demo',
      authorName: 'Sr.Sneakers',
      authorAvatarUrl: '',
      text: '¡Qué joya! ¿La piensas vender o es para la colección?',
      timeAgo: '3 h',
      likesCount: 12,
    ),
    CommentModel(
      id: 'c2',
      targetId: 'demo',
      authorName: 'ColeccionMX',
      authorAvatarUrl: '',
      text: 'Tengo unas parecidas, la condición se ve impecable.',
      timeAgo: '2 h',
      likesCount: 5,
    ),
    CommentModel(
      id: 'c3',
      targetId: 'demo',
      authorName: 'Rolex_Fan',
      authorAvatarUrl: '',
      text: 'Excelente pieza, felicidades por la adquisición.',
      timeAgo: '1 h',
      likesCount: 3,
    ),
  ];
}