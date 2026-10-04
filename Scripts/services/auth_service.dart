/// Service for handling authentication-related operations.
/// Uses the DucksHttpClient from task 002 for HTTP communication.
import 'dart:convert';
import 'dart:io';

import '../ducks_http_client.dart';
import '../ducks_http_exception.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  final DucksHttpClient _httpClient;
  String? _authToken;

  AuthService({String? baseUrl})
      : _httpClient = DucksHttpClient(baseUrl ?? 'https://api.duckapps.com.br');

  /// Logs in with email and password.
  /// 
  /// [email] User's email address
  /// [password] User's password
  /// Returns a Future that completes with the authentication token (JWT)
  Future<String> login(String email, String password) async {
    try {
      final response = await _httpClient.post(
        '/auth/login', // Assuming this is the login endpoint - to be verified from analysis
        body: {
          'email': email,
          'password': password,
        },
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Parse the response to extract the token
      // This would depend on the actual API response format
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);
      
      // Assuming the token is returned in a standard format
      final token = jsonResponse['token'] ?? jsonResponse['accessToken'];
      if (token == null) {
        throw Exception('No token found in login response');
      }
      
      _authToken = token;
      return token;
    } on DucksHttpException {
      rethrow;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logs out the current user by clearing the authentication token.
  Future<void> logout() async {
    _authToken = null;
    // Optionally, we could call a logout endpoint to invalidate the token server-side
    try {
      await _httpClient.post(
        '/auth/logout',
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );
    } catch (_) {
      // Ignore logout errors - we still want to clear the token locally
    }
  }

  /// Refreshes the authentication token using a refresh token.
  /// 
  /// [refreshToken] The refresh token to use for obtaining a new access token
  /// Returns a Future that completes with the new authentication token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _httpClient.post(
        '/auth/refresh-token', // Assuming this is the refresh endpoint
        body: {
          'refresh_token': refreshToken,
        },
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);
      
      final newToken = jsonResponse['token'] ?? jsonResponse['accessToken'];
      if (newToken == null) {
        throw Exception('No token found in refresh response');
      }
      
      _authToken = newToken;
      return newToken;
    } on DucksHttpException {
      rethrow;
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  /// Checks if the user is currently authenticated (has a valid token).
  /// 
  /// Returns a Future that completes with true if authenticated, false otherwise
  Future<bool> isAuthenticated() async {
    // In a real implementation, we might want to validate the token
    // For now, we just check if we have a token stored
    return _authToken != null && _authToken!.isNotEmpty;
  }

  /// Gets the current authentication token.
  /// 
  /// Returns the current token or null if not authenticated
  String? getAuthToken() => _authToken;

  /// Sets the authentication token directly (useful for token restoration).
  /// 
  /// [token] The authentication token to set
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clears the authentication token.
  void clearAuthToken() {
    _authToken = null;
  }

  /// Makes an authenticated GET request.
  /// 
  /// [endpoint] The API endpoint to call
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> getAuthenticated(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    return _httpClient.get(
      endpoint,
      headers: {...?headers, 'Authorization': 'Bearer $_authToken'},
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
    return _httpClient.post(
      endpoint,
      body: body,
      headers: {...?headers, 'Authorization': 'Bearer $_authToken'},
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
    return _httpClient.put(
      endpoint,
      body: body,
      headers: {...?headers, 'Authorization': 'Bearer $_authToken'},
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
    return _httpClient.delete(
      endpoint,
      headers: {...?headers, 'Authorization': 'Bearer $_authToken'},
    );
  }

  @override
  Future<void> dispose() async {
    _httpClient.dispose(); // dispose() do DucksHttpClient é void
    await super.dispose();
  }
}