/// Service-specific exceptions for handling various error conditions.
import 'package:meta/meta.dart';

@immutable
abstract class ServiceException implements Exception {
  final String message;

  const ServiceException(this.message);

  @override
  String toString() => '${runtimeType.toString()}: $message';
}

@immutable
class BadRequestException extends ServiceException {
  const BadRequestException(String message) : super(message);
}

@immutable
class UnauthorizedException extends ServiceException {
  const UnauthorizedException(String message) : super(message);
}

@immutable
class ForbiddenException extends ServiceException {
  const ForbiddenException(String message) : super(message);
}

@immutable
class NotFoundException extends ServiceException {
  const NotFoundException(String message) : super(message);
}

@immutable
class RateLimitException extends ServiceException {
  final int? retryAfter;

  const RateLimitException(String message, [this.retryAfter]) : super(message);

  @override
  String toString() {
    if (retryAfter != null) {
      return 'RateLimitException: $message (retry after $retryAfter seconds)';
    }
    return 'RateLimitException: $message';
  }
}

@immutable
class ServerException extends ServiceException {
  const ServerException(String message) : super(message);
}

@immutable
class NotAuthenticatedException extends ServiceException {
  const NotAuthenticatedException(String message) : super(message);
}