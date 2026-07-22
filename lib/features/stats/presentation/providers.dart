import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/providers.dart';
import '../domain/entities.dart';

/// Estadísticas de la colección del usuario.
///
/// Se derivan reactivamente de los activos ya cargados en el perfil: cuando
/// el usuario agrega, borra o pone algo en venta, las estadísticas se
/// recalculan solas. No hay estado propio ni llamadas extra al backend.
final collectionStatsProvider = Provider<CollectionStats>((ref) {
  final assets = ref.watch(profileAssetsControllerProvider).assets;
  return CollectionStats.fromAssets(assets);
});
