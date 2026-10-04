/// Service for handling authentication-related operations.
/// Uses the DucksHttpClient from task 002 for HTTP communication.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../ducks_http_client.dart';
import '../ducks_http_exception.dart';
import '../storage/secure_storage.dart';
import '../models/user.dart';
import '../exceptions/auth_exceptions.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  final DucksHttpClient _httpClient;
  final SecureStorage _storage;
  final _authController = StreamController<User?>.broadcast();

  String? _authToken;
  String? _refreshToken;
  User? _user;

  AuthService({
    String? baseUrl,
    SecureStorage? storage,
  })  : _httpClient = DucksHttpClient(baseUrl ?? 'https://api.duckapps.com.br'),
        _storage = storage ?? MockSecureStorage() {
    _loadAuthState();
  }

  /// Loads authentication state from storage on initialization
  Future<void> _loadAuthState() async {
    final token = await _storage.read('access_token');
    final refreshToken = await _storage.read('refresh_token');
    final userJson = await _storage.read('user_data');

    if (token != null && token.isNotEmpty) {
      _authToken = token;
      _httpClient.setAuthToken(token);
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken = refreshToken;
    }

    if (userJson != null && userJson.isNotEmpty) {
      try {
        _user = User.fromJson(jsonDecode(userJson));
      } catch (_) {
        _user = null;
      }
    }

    _authController.add(_user);
  }

  @override
  Future<void> dispose() async {
    await _authController.close();
    _httpClient.dispose();
    await super.dispose();
  }

  /// Logs in with email and password using the token endpoint.
  /// Based on analysis, the app uses a POST to /token with OAuth2-like parameters.
  ///
  /// [email] User's email address
  /// [password] User's password
  /// Returns a Future that completes with the authenticated user
  Future<User> login(String email, String password) async {
    try {
      final response = await _httpClient.post(
        '/token', // Token endpoint identified in analysis
        body: {
          'grant_type': 'password',
          'username': email,
          'password': password,
        },
        // Content-Type and X-Client-Info are handled by DucksHttpClient
      );

      // Parse the response to extract the token and user data
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      // Extract token from response - based on JWT found in analysis
      final token = jsonResponse['access_token'] ?? jsonResponse['token'];
      final refreshToken = jsonResponse['refresh_token'];
      if (token == null) {
        throw Exception('No token found in login response');
      }

      // Save tokens to secure storage
      await _storage.write('access_token', token);
      if (refreshToken != null) {
        await _storage.write('refresh_token', refreshToken);
      }

      // Save user data if present
      if (jsonResponse['user'] != null) {
        await _storage.write('user_data', jsonEncode(jsonResponse['user']));
        _user = User.fromJson(jsonResponse['user']);
      } else {
        // Try to create user from token claims if no user data provided
        _user = User.fromToken(token) ?? User.empty();
        await _storage.write('user_data', jsonEncode(_user!.toJson()));
      }

      // Set the token in the HTTP client for automatic header inclusion
      _httpClient.setAuthToken(token);
      _authToken = token;
      _refreshToken = refreshToken;

      // Notify listeners of auth state change
      _authController.add(_user);

      return _user;
    } on DucksHttpException catch (e) {
      if (e.statusCode == 401) {
        throw InvalidCredentialsException('Invalid email or password');
      }
      rethrow;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logs out the current user by clearing the authentication token.
  /// Note: The analysis didn't reveal a specific logout endpoint, so we clear locally.
  Future<void> logout() async {
    // Clear token from HTTP client
    _httpClient.clearAuthToken();
    await _storage.delete('access_token');
    await _storage.delete('refresh_token');
    await _storage.delete('user_data');
    _authToken = null;
    _refreshToken = null;
    _user = null;

    // Notify listeners of auth state change
    _authController.add(null);

    // Optionally call logout endpoint if discovered in future analysis
  }

  /// Refreshes the authentication token using a refresh token.
  /// Based on analysis of refresh_token strings in the app.
  ///
  /// Returns a Future that completes with the authenticated user
  Future<User> refreshToken() async {
    try {
      final refreshToken = await _storage.read('refresh_token');
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _httpClient.post(
        '/token', // Assuming token endpoint also handles refresh
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      final newToken = jsonResponse['access_token'] ?? jsonResponse['token'];
      final newRefreshToken = jsonResponse['refresh_token'];
      if (newToken == null) {
        throw Exception('No token found in refresh response');
      }

      // Save tokens to secure storage
      await _storage.write('access_token', newToken);
      if (newRefreshToken != null) {
        await _storage.write('refresh_token', newRefreshToken);
      }

      // Save user data if present
      if (jsonResponse['user'] != null) {
        await _storage.write('user_data', jsonEncode(jsonResponse['user']));
        _user = User.fromJson(jsonResponse['user']);
      }

      // Update token in HTTP client
      _httpClient.setAuthToken(newToken);
      _authToken = newToken;
      _refreshToken = newRefreshToken;

      // Notify listeners of auth state change
      _authController.add(_user);

      return _user!;
    } on DucksHttpException catch (e) {
      if (e.statusCode == 401) {
        throw InvalidCredentialsException('Refresh token expired or invalid');
      }
      rethrow;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Checks if the user is currently authenticated (has a valid token).
  ///
  /// Returns a Future that completes with true if authenticated, false otherwise
  Future<bool> isAuthenticated() async {
    // Check if HTTP client has a token set
    final token = await _storage.read('access_token');
    return token != null && token.isNotEmpty;
  }

  /// Gets the current authentication token.
  ///
  /// Returns the current token or null if not authenticated
  Future<String?> getAuthToken() async => await _storage.read('access_token');

  /// Gets the current user.
  ///
  /// Returns the current user or null if not authenticated
  User? getCurrentUser() => _user;

  /// Sets the authentication token directly (useful for token restoration).
  ///
  /// [token] The authentication token to set
  Future<void> setAuthToken(String token) async {
    await _storage.write('access_token', token);
    _httpClient.setAuthToken(token);
    _authToken = token;
    // TODO: Extract user from token if needed and update _user
    _authController.add(_user);
  }

  /// Clears the authentication token.
  Future<void> clearAuthToken() async {
    await _storage.delete('access_token');
    await _storage.delete('refresh_token');
    await _storage.delete('user_data');
    _httpClient.clearAuthToken();
    _authToken = null;
    _refreshToken = null;
    _user = null;
    _authController.add(null);
  }

  /// Stream to listen for authentication state changes.
  Stream<User?> get authStateChanges => _authController.stream;

  /// Makes an authenticated GET request.
  ///
  /// [endpoint] The API endpoint to call
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> getAuthenticated(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    // Ensure we have a token
    final token = await _storage.read('access_token');
    if (token == null || token.isEmpty) {
      throw NotAuthenticatedException('No authentication token available');
    }
    return _httpClient.get(
      endpoint,
      headers: headers,
    );
  }

  /// Makes an authenticated POST request.
  ///
  /// [endpoint] The API endpoint to call
  /// [body] Optional request body
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> postAuthenticated(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
      }) async {
    final token = await _storage.read('access_token');
    if (token == null || token.isEmpty) {
      throw NotAuthenticatedException('No authentication token available');
    }
    return _httpClient.post(
      endpoint,
      body: body,
      headers: headers,
    );
  }

  /// Makes an authenticated PUT request.
  ///
  /// [endpoint] The API endpoint to call
  /// [body] Optional request body
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> putAuthenticated(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
      }) async {
    final token = await _storage.read('access_token');
    if (token == null || token.isEmpty) {
      throw NotAuthenticatedException('No authentication token available');
    }
    return _httpClient.put(
      endpoint,
      body: body,
      headers: headers,
    );
  }

  /// Makes an authenticated DELETE request.
  ///
  /// [endpoint] The API endpoint to call
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> deleteAuthenticated(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    final token = await _storage.read('access_token');
    if (token == null || token.isEmpty) {
      throw NotAuthenticatedException('No authentication token available');
    }
    return _httpClient.delete(
      endpoint,
      headers: headers,
    );
  }
}

/// Mock secure storage for testing purposes.
class MockSecureStorage implements SecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) => Future.value(_data[key]);

  @override
  Future<void> write(String key, String value) =>
      Future.value(_data[key] = value);

  @override
  Future<void> delete(String key) =>
      Future.value(_data.remove(key));

  @override
  Future<void> clear() =>
      Future.value(_data.clear());
}