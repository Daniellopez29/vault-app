import 'package:equatable/equatable.dart';
import '../../profile/domain/entities.dart';

/// Estadísticas de la colección de un usuario.
///
/// Se derivan de los activos ya cargados: no requieren una llamada extra al
/// backend. El cálculo vive aquí (dominio) y no en la UI, para que la vista
/// solo muestre y no calcule.
class CollectionStats extends Equatable {
  final int totalAssets;
  final double totalValue;
  final int forSaleCount;
  final int publishedCount;
  final int verifiedCount;
  final int servicesCount;
  final int restorationsCount;
  final Map<AssetCategory, int> byCategory;

  const CollectionStats({
    required this.totalAssets,
    required this.totalValue,
    required this.forSaleCount,
    required this.publishedCount,
    required this.verifiedCount,
    required this.servicesCount,
    required this.restorationsCount,
    required this.byCategory,
  });

  /// Colección vacía, para el estado inicial.
  static const empty = CollectionStats(
    totalAssets: 0,
    totalValue: 0,
    forSaleCount: 0,
    publishedCount: 0,
    verifiedCount: 0,
    servicesCount: 0,
    restorationsCount: 0,
    byCategory: {},
  );

  /// Calcula las estadísticas a partir de la lista de activos del usuario.
  factory CollectionStats.fromAssets(List<AssetEntity> assets) {
    if (assets.isEmpty) return empty;

    final byCategory = <AssetCategory, int>{};
    var totalValue = 0.0;
    var forSale = 0;
    var published = 0;
    var verified = 0;
    var services = 0;
    var restorations = 0;

    for (final asset in assets) {
      byCategory[asset.category] = (byCategory[asset.category] ?? 0) + 1;
      totalValue += asset.originalPrice;
      if (asset.isForSale) forSale++;
      if (asset.isPublished) published++;
      if (asset.isVerified) verified++;
      services += asset.servicesCount;
      restorations += asset.restorationsCount;
    }

    return CollectionStats(
      totalAssets: assets.length,
      totalValue: totalValue,
      forSaleCount: forSale,
      publishedCount: published,
      verifiedCount: verified,
      servicesCount: services,
      restorationsCount: restorations,
      byCategory: byCategory,
    );
  }

  /// Valor promedio por activo, útil para el resumen.
  double get averageValue => totalAssets == 0 ? 0 : totalValue / totalAssets;

  /// La categoría con más activos, o null si la colección está vacía.
  AssetCategory? get topCategory {
    if (byCategory.isEmpty) return null;
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  @override
  List<Object?> get props => [
        totalAssets,
        totalValue,
        forSaleCount,
        publishedCount,
        verifiedCount,
        servicesCount,
        restorationsCount,
        byCategory,
      ];
}
