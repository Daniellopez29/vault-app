import 'package:equatable/equatable.dart';

/// Tipo de suscripción. Solo se usa para elegir el copy del anuncio y la
/// pantalla de origen (producto vs negocio) -- `payment/` vende los mismos
/// 3 planes fijos (básico/pro/premium) sin distinguir por este tipo, así
/// que [SubscriptionPlan] ya no lo lleva.
enum SubscriptionType { product, business }

/// Textos de los anuncios de suscripción. Viven en el dominio (no
/// hardcodeados en la UI ni en el marketplace) para tener una sola fuente
/// de verdad. Si cambia el copy, se cambia aquí.
abstract class SubscriptionCopy {
  static const productTitle = 'Haz que tus productos se vean primero';
  static const productSubtitle = 'Destácalos con una suscripción.';

  static const businessTitle = 'Publicita tu negocio';
  static const businessSubtitle = 'Llega a más clientes con una suscripción.';

  static String titleFor(SubscriptionType type) => switch (type) {
        SubscriptionType.product => productTitle,
        SubscriptionType.business => businessTitle,
      };

  static String subtitleFor(SubscriptionType type) => switch (type) {
        SubscriptionType.product => productSubtitle,
        SubscriptionType.business => businessSubtitle,
      };
}

/// Un plan de suscripción concreto que el usuario puede contratar. Refleja
/// los 3 planes fijos de `payment/` (básico/pro/premium): cuántos anuncios
/// permite, en qué secciones puede aparecer, y qué comisión de venta aplica.
class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final double price;
  final int maxAds;
  final List<String> targetSections;
  final double commissionRate;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.maxAds,
    required this.targetSections,
    required this.commissionRate,
  });

  /// Texto de beneficios derivado de los datos reales del plan (el backend
  /// no manda copy, solo los números/secciones).
  List<String> get benefits => [
        maxAds == 1 ? '1 anuncio activo' : 'Hasta $maxAds anuncios activos',
        targetSections.contains('feed')
            ? 'Aparece en marketplace y en el feed'
            : 'Aparece en marketplace',
        'Comisión de venta del ${(commissionRate * 100).toStringAsFixed(0)}%',
      ];

  @override
  List<Object?> get props => [id, name, price, maxAds, targetSections, commissionRate];
}

/// Estado de la suscripción activa del usuario (o su ausencia).
class SubscriptionStatus extends Equatable {
  final String id;
  final String planId;
  final String status;
  final DateTime currentPeriodEnd;

  const SubscriptionStatus({
    required this.id,
    required this.planId,
    required this.status,
    required this.currentPeriodEnd,
  });

  bool get isActive => status == 'active' || status == 'trialing';

  @override
  List<Object?> get props => [id, planId, status, currentPeriodEnd];
}
