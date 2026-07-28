/// Llave publicable de Stripe (la que puede vivir en el cliente sin riesgo;
/// la llave secreta solo la usa `payment/`, nunca esta app).
///
/// Es la de modo test (`pk_test_`) -- antes de lanzar a producción hay que
/// cambiarla por la `pk_live_` del Stripe Dashboard.
abstract class StripeConfig {
  static const publishableKey =
      'pk_test_51TvBSUBe8INFqTaYcwXJBl52VRi3QEbaGpkjpaQNjc6j7S1gXyFcW1E7XO3RBVTO0DUHo0rJKbAYBK2Mid3PHvpg00GMm37oFy';
}
