import '../domain/entities.dart';
import 'models.dart';

/// Fuente de datos de planes. Hoy devuelve datos mock; mañana será una
/// llamada a la API. Aislado aquí para que el cambio a backend real toque
/// SOLO este archivo.
abstract class SubscriptionDataSource {
  Future<List<SubscriptionPlanModel>> getPlans(SubscriptionType type);
}

class SubscriptionMockDataSource implements SubscriptionDataSource {
  @override
  Future<List<SubscriptionPlanModel>> getPlans(SubscriptionType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = type == SubscriptionType.product
        ? _productPlans
        : _businessPlans;
    return all.map(SubscriptionPlanModel.fromMap).toList();
  }

  /// Planes para destacar productos.
  static const List<Map<String, dynamic>> _productPlans = [
    {
      'id': 'prod_monthly',
      'type': 'product',
      'name': 'Mensual',
      'price': 99.0,
      'durationDays': 30,
      'benefits': [
        'Tus productos aparecen primero',
        'Insignia de destacado',
        'Soporte prioritario',
      ],
    },
    {
      'id': 'prod_quarterly',
      'type': 'product',
      'name': 'Trimestral',
      'price': 249.0,
      'durationDays': 90,
      'benefits': [
        'Todo lo del plan mensual',
        'Ahorro del 16%',
        'Estadísticas de visibilidad',
      ],
    },
    {
      'id': 'prod_yearly',
      'type': 'product',
      'name': 'Anual',
      'price': 899.0,
      'durationDays': 365,
      'benefits': [
        'Todo lo del plan trimestral',
        'Ahorro del 24%',
        'Máxima prioridad todo el año',
      ],
    },
  ];

  /// Planes para publicitar el negocio.
  static const List<Map<String, dynamic>> _businessPlans = [
    {
      'id': 'biz_monthly',
      'type': 'business',
      'name': 'Mensual',
      'price': 149.0,
      'durationDays': 30,
      'benefits': [
        'Tu negocio en la vitrina destacada',
        'Perfil verificado',
        'Alcance ampliado',
      ],
    },
    {
      'id': 'biz_quarterly',
      'type': 'business',
      'name': 'Trimestral',
      'price': 399.0,
      'durationDays': 90,
      'benefits': [
        'Todo lo del plan mensual',
        'Ahorro del 11%',
        'Reporte mensual de clientes',
      ],
    },
    {
      'id': 'biz_yearly',
      'type': 'business',
      'name': 'Anual',
      'price': 1399.0,
      'durationDays': 365,
      'benefits': [
        'Todo lo del plan trimestral',
        'Ahorro del 22%',
        'Publicidad destacada todo el año',
      ],
    },
  ];
}
