abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Credenciales inválidas.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor. Intenta nuevamente.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}

/// El backend rechazó el contenido por tóxico/ofensivo (HTTP 422) o porque
/// el servicio de moderación no respondió (HTTP 503). La UI debe mostrar
/// [message] tal cual y conservar lo que el usuario escribió, sin borrarlo.
class ModerationFailure extends Failure {
  const ModerationFailure([super.message = 'Tu contenido es demasiado ofensivo para publicarse.']);
}