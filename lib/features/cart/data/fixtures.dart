import '../domain/entities.dart';
import 'models.dart';

/// Datos de prueba temporales mientras el backend no está disponible.
/// El carrito arranca vacío; aquí solo viven los métodos de pago mock.
abstract class CartFixtures {
  static List<PaymentMethodModel> get mockPaymentMethods => const [
    PaymentMethodModel(
      id: 'pm1',
      type: PaymentType.visa,
      label: '****** 2334',
    ),
    PaymentMethodModel(
      id: 'pm2',
      type: PaymentType.maestro,
      label: '****** 3774',
    ),
    PaymentMethodModel(
      id: 'pm3',
      type: PaymentType.paypal,
      label: 'abc@gmail.com',
    ),
  ];
}