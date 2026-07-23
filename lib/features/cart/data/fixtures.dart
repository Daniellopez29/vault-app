import '../domain/entities.dart';
import 'models.dart';

/// Datos de prueba temporales mientras el backend no está disponible.
/// El carrito arranca vacío; aquí solo viven los métodos de pago mock.
abstract class CartFixtures {
  static List<PaymentMethodModel> get mockPaymentMethods => const [
    PaymentMethodModel(
      id: 'pm_card',
      type: PaymentType.card,
      label: 'Tarjeta',
      description: 'Débito o crédito',
    ),
    PaymentMethodModel(
      id: 'pm_transfer',
      type: PaymentType.transfer,
      label: 'Transferencia',
      description: 'Te compartimos los datos bancarios',
    ),
    PaymentMethodModel(
      id: 'pm_cash',
      type: PaymentType.cash,
      label: 'Efectivo',
      description: 'Paga en establecimiento',
    ),
  ];
}
