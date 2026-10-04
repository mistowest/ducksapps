/// Exceções específicas para operações de autenticação
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException(String message) : super(message);
}

class NotAuthenticatedException extends AuthException {
  const NotAuthenticatedException(String message) : super(message);
}

class TokenExpiredException extends AuthException {
  const TokenExpiredException(String message) : super(message);
}