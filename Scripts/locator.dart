/// Simple service locator for dependency injection.
/// Allows registering and retrieving services throughout the app.
import 'services/base_service.dart';

class Locator {
  /// Map to store registered services
  final Map<Type, dynamic> _services = {};

  /// Register a lazy singleton service.
  /// 
  /// [T] The type of service to register
  /// [factory] A factory function that creates the service when first requested
  void registerLazySingleton<T extends BaseService>(T Function() factory) {
    _services[T] = factory;
  }

  /// Register a singleton service with a pre-created instance.
  /// 
  /// [T] The type of service to register
  /// [instance] The pre-created instance of the service
  void registerSingleton<T extends BaseService>(T instance) {
    _services[T] = instance;
  }

  /// Retrieve a registered service.
  /// 
  /// [T] The type of service to retrieve
  /// Returns the registered service instance
  T get<T extends BaseService>() {
    final factory = _services[T];
    if (factory == null) {
      throw StateError('Service $T is not registered in the locator');
    }
    
    // If it's a factory function, call it to get the instance
    if (factory is T Function()) {
      final instance = factory();
      _services[T] = instance; // Cache the instance for future calls
      return instance;
    }
    
    // If it's already an instance, return it directly
    return factory as T;
  }

  /// Check if a service is registered.
  /// 
  /// [T] The type of service to check
  /// Returns true if the service is registered, false otherwise
  bool isRegistered<T extends BaseService>() {
    return _services.containsKey(T);
  }

  /// Remove a registered service.
  /// 
  /// [T] The type of service to remove
  void unregister<T extends BaseService>() {
    _services.remove(T);
  }

  /// Clear all registered services.
  void clear() {
    _services.clear();
  }
}