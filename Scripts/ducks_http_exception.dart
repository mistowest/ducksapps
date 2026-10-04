/// Custom exceptions for the Ducks HTTP client.
/// Based on the specifications in Doc/tasks/002.md

class DucksHttpException implements Exception {
  final String message;
  
  DucksHttpException(this.message);
  
  @override
  String toString() => 'DucksHttpException: $message';
}

class UnauthorizedException extends DucksHttpException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message);
}

class ForbiddenException extends DucksHttpException {
  ForbiddenException([String message = 'Forbidden']) : super(message);
}

class NotFoundException extends DucksHttpException {
  NotFoundException([String message = 'Not Found']) : super(message);
}

class BadRequestException extends DucksHttpException {
  BadRequestException([String message = 'Bad Request']) : super(message);
}

class InternalServerErrorException extends DucksHttpException {
  InternalServerErrorException([String message = 'Internal Server Error']) : super(message);
}