import 'models.dart';

/// Datos de prueba temporales mientras el backend no está disponible.
/// Reemplazar por llamadas HTTP reales en [HomeRemoteDataSourceImpl].
abstract class HomeFeedFixtures {
  static List<PostModel> get mockPosts => [
    const PostModel(
      id: '1',
      authorName: 'Sr.Sneakers',
      authorAvatarUrl: '',
      imageUrl: 'assets/images/mock/sneaker1.jpg',
      title: 'Tenis ColorFull A9',
      description:
      'Acabo de registrar esta joya en la app. ¿Qué dicen, se queda '
          'para la colección personal a largo plazo o la movemos pronto en el mercado?',
      timeAgo: '3 días atrás',
      likesCount: 187,
      commentsCount: 155,
    ),
    const PostModel(
      id: '2',
      authorName: 'Sr.Sneakers',
      authorAvatarUrl: '',
      imageUrl: 'assets/images/mock/sneaker2.jpg',
      title: 'Tenis ColorFull A9',
      description:
      'Acabo de registrar esta joya en la app. ¿Qué dicen, se queda '
          'para la colección personal a largo plazo o la movemos pronto en el mercado?',
      timeAgo: '3 días atrás',
      likesCount: 187,
      commentsCount: 155,
    ),
    const PostModel(
      id: '3',
      authorName: 'Sr.Rolex',
      authorAvatarUrl: '',
      imageUrl: 'assets/images/mock/reloj1.jpg',
      title: 'Reloj Rolex Gemini',
      description:
      'Acabo de registrar esta joya en la app. ¿Qué dicen, se queda '
          'para la colección personal a largo plazo o la movemos pronto en el mercado?',
      timeAgo: '3 días atrás',
      likesCount: 187,
      commentsCount: 155,
    ),
  ];
}