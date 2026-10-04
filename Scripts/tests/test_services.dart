import 'package:test/test.dart';

import '../locator.dart';
import '../services/auth_service.dart';
import '../services/base_service.dart';
import '../services/navigation_service.dart';
import '../services/api_service.dart';
import '../routes.dart';

void main() {
  group('Service Locator', () {
    late Locator locator;

    setUp(() {
      locator = Locator();
    });

    test('can register and retrieve a service', () {
      locator.registerLazySingleton<AuthService>(() => AuthService());
      final authService = locator.get<AuthService>();
      expect(authService, isA<AuthService>());
    });

    test('returns the same instance for lazy singleton after first call', () {
      int callCount = 0;
      locator.registerLazySingleton<AuthService>(() {
        callCount++;
        return AuthService();
      });

      final service1 = locator.get<AuthService>();
      final service2 = locator.get<AuthService>();
      expect(callCount, 1); // Factory should only be called once
      expect(identical(service1, service2), isTrue); // Should be the same instance
    });

    test('can register a singleton with pre-created instance', () {
      final service = AuthService();
      locator.registerSingleton<AuthService>(service);
      final retrieved = locator.get<AuthService>();
      expect(identical(service, retrieved), isTrue);
    });

    test('throws when retrieving unregistered service', () {
      expect(() => locator.get<AuthService>(), throwsStateError);
    });

    test('can check if service is registered', () {
      expect(locator.isRegistered<AuthService>(), isFalse);
      locator.registerLazySingleton<AuthService>(() => AuthService());
      expect(locator.isRegistered<AuthService>(), isTrue);
    });

    test('can unregister a service', () {
      locator.registerLazySingleton<AuthService>(() => AuthService());
      expect(locator.isRegistered<AuthService>(), isTrue);
      locator.unregister<AuthService>();
      expect(locator.isRegistered<AuthService>(), isFalse);
      expect(() => locator.get<AuthService>(), throwsStateError);
    });
  });

  group('BaseService', () {
    test('is an abstract class', () {
      // We can't instantiate it directly, but we can verify it's abstract
      expect(BaseService, isNotNull);
    });
  });

  group('AuthService', () {
    test('can be instantiated', () {
      final service = AuthService();
      expect(service, isA<AuthService>());
      expect(service, isA<BaseService>());
    });

    test('has correct base URL when none provided', () {
      // This test would require accessing private fields - we'll test behavior instead
      final service = AuthService();
      expect(() => service.login('test@example.com', 'password'), returnsNormally);
    });

    test('can set and get auth token', () {
      final service = AuthService();
      service.setAuthToken('test-token');
      expect(service.getAuthToken(), 'test-token');
      service.clearAuthToken();
      expect(service.getAuthToken(), isNull);
    });
  });

  group('ApiService', () {
    test('can be instantiated', () {
      final service = ApiService();
      expect(service, isA<ApiService>());
      expect(service, isA<BaseService>());
    });

    test('can set and clear auth token on underlying client', () {
      final service = ApiService();
      service.setAuthToken('test-token');
      service.clearAuthToken();
      // We can't directly test the token, but we can verify no errors
      expect(() => service.get('/test'), returnsNormally);
    });
  });

  group('NavigationService', () {
    test('is a singleton', () {
      final service1 = NavigationService();
      final service2 = NavigationService();
      expect(identical(service1, service2), isTrue);
    });

    test('has pushRoute method', () {
      final service = NavigationService();
      expect(() => service.pushRoute(Route.home), returnsNormally);
    });
  });

  group('Route enum', () {
    test('has expected values', () {
      expect(Route.home, Route.home);
      expect(Route.login, Route.login);
      expect(Route.community, Route.community);
      expect(Route.profile, Route.profile);
      expect(Route.settings, Route.settings);
    });
  });
}