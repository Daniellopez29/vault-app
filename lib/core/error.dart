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