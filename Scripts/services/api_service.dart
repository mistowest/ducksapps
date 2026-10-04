import 'dart:io';

import '../ducks_http_client.dart';
import 'base_service.dart';

class ApiService extends BaseService {
  final DucksHttpClient _httpClient;

  ApiService({String? baseUrl})
      : _httpClient = DucksHttpClient(baseUrl ?? 'https://api.duckapps.com.br');

  /// Makes a GET request to the specified endpoint.
  /// 
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [headers] Optional additional headers
  /// [authenticated] Whether to include authentication headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> get(
      String endpoint, {
        Map<String, String>? headers,
        bool authenticated = false,
      }) async {
    if (authenticated) {
      // For authenticated requests, we would need to get the token from somewhere
      // In a real implementation, this would come from AuthService or a token manager
      // For now, we'll just add the header if we had a token - this would need to be implemented
      final authHeaders = {...?headers};
      // This is a placeholder - in reality, we'd need to get the token from AuthService
      // For demonstration purposes, we'll leave it as is and note that proper auth
      // integration would be needed
      return _httpClient.get(endpoint, headers: authHeaders);
    } else {
      return _httpClient.get(endpoint, headers: headers);
    }
  }

  /// Makes a POST request to the specified endpoint.
  /// 
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [body] Optional request body (will be JSON-encoded if Map/List)
  /// [headers] Optional additional headers
  /// [authenticated] Whether to include authentication headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> post(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
        bool authenticated = false,
      }) async {
    if (authenticated) {
      final authHeaders = {...?headers};
      // Placeholder for auth header - would need integration with AuthService
      return _httpClient.post(endpoint, body: body, headers: authHeaders);
    } else {
      return _httpClient.post(endpoint, body: body, headers: headers);
    }
  }

  /// Makes a PUT request to the specified endpoint.
  /// 
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [body] Optional request body (will be JSON-encoded if Map/List)
  /// [headers] Optional additional headers
  /// [authenticated] Whether to include authentication headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> put(
      String endpoint, {
        dynamic body,
        Map<String, String>? headers,
        bool authenticated = false,
      }) async {
    if (authenticated) {
      final authHeaders = {...?headers};
      // Placeholder for auth header - would need integration with AuthService
      return _httpClient.put(endpoint, body: body, headers: authHeaders);
    } else {
      return _httpClient.put(endpoint, body: body, headers: headers);
    }
  }

  /// Makes a DELETE request to the specified endpoint.
  /// 
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [headers] Optional additional headers
  /// [authenticated] Whether to include authentication headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> delete(
      String endpoint, {
        Map<String, String>? headers,
        bool authenticated = false,
      }) async {
    if (authenticated) {
      final authHeaders = {...?headers};
      // Placeholder for auth header - would need integration with AuthService
      return _httpClient.delete(endpoint, headers: authHeaders);
    } else {
      return _httpClient.delete(endpoint, headers: headers);
    }
  }

  /// Sets the authentication token on the underlying HTTP client.
  /// This method allows the ApiService to use an authenticated client.
  /// 
  /// [token] The authentication token to set
  void setAuthToken(String token) {
    _httpClient.setAuthToken(token);
  }

  /// Clears the authentication token on the underlying HTTP client.
  void clearAuthToken() {
    _httpClient.clearAuthToken();
  }

  @override
  Future<void> dispose() async {
    _httpClient.dispose(); // dispose() do DucksHttpClient é void
    await super.dispose();
  }
}