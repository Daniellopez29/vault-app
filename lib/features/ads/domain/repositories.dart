import 'package:dartz/dartz.dart';
import '../../../core/error.dart';
import 'entities.dart';

abstract class AdRepository {
  /// Anuncios activos de [section] ("marketplace"/"feed"), visibles para
  /// cualquier usuario (no solo el dueño).
  Future<Either<Failure, List<AdEntity>>> getActiveAds(String section);

  /// Todos los anuncios propios (activos e inactivos), para administrarlos.
  Future<Either<Failure, List<AdEntity>>> getMyAds();

  /// Crea un anuncio para el activo/negocio [targetId]. El backend exige
  /// una suscripción activa y respeta el `max_ads`/`target_sections` del
  /// plan -- ver ErrNoActiveSubscription/ErrMaxAdsReached/ErrSectionNotAllowed
  /// (llegan como el mensaje de un ServerFailure).
  Future<Either<Failure, AdEntity>> createAd({
    required String title,
    required String description,
    required String imageUrl,
    required String targetSection,
    required String targetId,
  });

  Future<Either<Failure, AdEntity>> updateAd(
    String id, {
    required String title,
    required String description,
    required String imageUrl,
    required String targetSection,
    required String targetId,
  });

  Future<Either<Failure, void>> deleteAd(String id);

  Future<void> registerImpression(String id);
  Future<void> registerClick(String id);
}
