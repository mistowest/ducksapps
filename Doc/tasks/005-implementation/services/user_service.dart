/// Service for handling user-related operations.
/// Uses the DucksHttpClient and AuthService for HTTP communication and auth management.
import 'dart:convert';

import '../ducks_http_client.dart';
import '../ducks_http_exception.dart';
import '../models/user.dart';
import '../exceptions/auth_exceptions.dart';
import 'auth_service.dart';
import 'base_service.dart';

class UserService extends BaseService {
  final DucksHttpClient _httpClient;
  final AuthService _authService;

  UserService({
    required DucksHttpClient httpClient,
    required AuthService authService,
  })  : _httpClient = httpClient,
        _authService = authService;

  /// Gets the data of the currently authenticated user.
  ///
  /// Returns a Future that completes with the user data
  Future<User> getMe() async {
    try {
      final response = await _httpClient.get(
        '/me',
        // Headers are handled by DucksHttpClient when authenticated
      );

      // Parse the response to extract user data
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      final user = User.fromJson(jsonResponse);
      return user;
    } on DucksHttpException catch (e) {
      if (e.statusCode == 401) {
        throw NotAuthenticatedException('User not authenticated or token expired');
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Logs out the current user by delegating to AuthService.
  Future<void> logout() async {
    await _authService.logout();
  }

  /// Refreshes the authentication token using the AuthService.
  ///
  /// Returns a Future that completes with the refreshed user data
  Future<User> refreshToken() async {
    try {
      final user = await _authService.refreshToken();
      return user;
    } on DucksHttpException catch (e) {
      if (e.statusCode == 401) {
        throw NotAuthenticatedException('Unable to refresh token: invalid or expired');
      }
      rethrow;
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  /// Checks if the user is currently authenticated by delegating to AuthService.
  ///
  /// Returns a Future that completes with true if authenticated, false otherwise
  Future<bool> isAuthenticated() async => _authService.isAuthenticated();

  /// Gets the current authentication token by delegating to AuthService.
  ///
  /// Returns the current token or null if not authenticated
  Future<String?> getAuthToken() async => _authService.getAuthToken();

  /// Gets the current user by delegating to AuthService.
  ///
  /// Returns the current user or null if not authenticated
  User? getCurrentUser() => _authService.getCurrentUser();

  @override
  Future<void> dispose() async {
    // Note: We don't dispose the AuthService here as it might be shared
    await super.dispose();
  }
}