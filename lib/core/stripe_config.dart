/// Llave publicable de Stripe (la que puede vivir en el cliente sin riesgo;
/// la llave secreta solo la usa `payment/`, nunca esta app).
///
/// TODO: reemplazar con la llave real de producción antes de lanzar --
/// Stripe Dashboard → Developers → API keys → Publishable key (empieza con
/// "pk_"). Mientras tanto, `flutter_stripe` rechaza cualquier llamada con un
/// error claro ("Invalid API Key") en vez de fallar en silencio.
abstract class StripeConfig {
  static const publishableKey = 'pk_test_REEMPLAZAR_CON_TU_LLAVE_PUBLICABLE';
}
