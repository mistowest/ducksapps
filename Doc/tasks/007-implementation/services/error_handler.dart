/// Centralized error handling for HTTP responses based on analysis in Doc/analysis/02-rede.md, 03-auth.md, and 04-usuarios.md.
import 'dart:io';

import '../exceptions/auth_exceptions.dart';
import '../exceptions/service_exceptions.dart';

class ErrorHandler {
  /// Handles HTTP responses and throws appropriate exceptions based on status code.
  ///
  /// [statusCode] HTTP status code from the response
  /// [message] Optional message from the response body or reason phrase
  ///
  /// Returns nothing but throws an appropriate exception
  static void handleHttpResponse(int statusCode, String? message) {
    switch (statusCode) {
      case 400:
        throw BadRequestException(message ?? 'Bad request');
      case 401:
        throw UnauthorizedException(message ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(message ?? 'Forbidden');
      case 404:
        throw NotFoundException(message ?? 'Not found');
      case 429:
        throw RateLimitException(message ?? 'Rate limit exceeded');
      case >= 500:
        throw ServerException(message ?? 'Server error');
      default:
        throw Exception('HTTP error $statusCode: $message');
    }
  }

  /// Handles a DucksHttpException and rethrows it as a more specific exception if possible.
  ///
  /// [exception] The DucksHttpException to handle
  ///
  /// Returns nothing but may throw a more specific exception
  static void handleDucksHttpException(DucksHttpException exception) {
    // Re-throw as more specific exception based on status code
    handleHttpResponse(exception.statusCode, exception.message);
  }
}