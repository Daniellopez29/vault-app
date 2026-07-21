import 'package:equatable/equatable.dart';

/// Tipo de suscripción. Cada tipo tiene su propio propósito y su propio
/// anuncio en la app:
/// - product: destacar tus productos en venta para que aparezcan primero.
/// - business: publicitar tu negocio para llegar a más clientes.
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

/// Un plan de suscripción concreto que el usuario puede contratar.
class SubscriptionPlan extends Equatable {
  final String id;
  final SubscriptionType type;
  final String name;
  final double price;
  final int durationDays;
  final List<String> benefits;

  const SubscriptionPlan({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.benefits,
  });

  @override
  List<Object?> get props => [id, type, name, price, durationDays, benefits];
}
