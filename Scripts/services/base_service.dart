/// Base service class that all services extend.
/// Provides common functionality and error handling patterns.
abstract class BaseService {
  /// Constructor for BaseService.
  BaseService();

  /// Common error handling method that can be overridden by subclasses.
  /// 
  /// [error] The error to handle
  /// Returns a Future that completes with the handled result or throws
  Future<T> handleError<T>(dynamic error) async {
    // Re-throw the error by default - subclasses can override for specific handling
    throw error;
  }

  /// Dispose of resources used by the service.
  /// Subclasses should override this method to clean up resources.
  Future<void> dispose() async {
    // Base implementation does nothing
  }
}