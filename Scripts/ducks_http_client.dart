import 'dart:convert';
import 'dart:io';

import 'ducks_http_exception.dart';

/// HTTP client for the Ducks app that replicates the exact network calls
/// of the official app, based on analysis in Doc/analysis/02-rede.md and Doc/tasks/002.md
class DucksHttpClient {
  final String _baseUrl;
  String? _authToken;
  bool _disposed = false;

  /// Creates a new DucksHttpClient with the specified base URL.
  ///
  /// [baseUrl] The base URL for all requests (e.g., 'https://api.duckapps.com.br')
  DucksHttpClient(String baseUrl)
      : _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''); // Remove trailing slash

  /// Sets the authentication token to be used in subsequent requests.
  ///
  /// [token] The Bearer token (typically a JWT) for authentication
  void setAuthToken(String token) {
    if (_disposed) {
      throw StateError('Client has been disposed');
    }
    _authToken = token;
  }

  /// Clears the authentication token, making subsequent requests unauthenticated.
  void clearAuthToken() {
    if (_disposed) {
      throw StateError('Client has been disposed');
    }
    _authToken = null;
  }

  /// Disposes of the client and releases any resources.
  void dispose() {
    _disposed = true;
  }

  /// Adds the standard headers required by the Ducks app.
  ///
  /// [additionalHeaders] Optional additional headers to include
  /// [authRequired] Whether Authorization header should be added (if token available)
  Map<String, String> _getHeaders({
    Map<String, String>? additionalHeaders,
    bool authRequired = true,
  }) {
    final headers = <String, String>{
      'X-Client-Info': 'postgrest-dart/2.7.1', // Mandatory header from analysis
    };

    // Add Authorization header if token is available and auth is required
    if (authRequired && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Makes a GET request to the specified endpoint.
  ///
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> get(
      String endpoint, {
      Map<String, String>? headers,
    }) async {
    if (_disposed) {
      throw StateError('Client has been disposed');
    }

    // Clean endpoint to avoid double slashes
    final cleanEndpoint = endpoint.replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$_baseUrl/$cleanEndpoint');
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(uri);
    
    // Add headers
    final requestHeaders = _getHeaders(additionalHeaders: headers);
    requestHeaders.forEach((key, value) => request.headers.set(key, value));
    
    return await _handleResponse(request);
  }

  /// Makes a POST request to the specified endpoint.
  ///
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [body] Optional request body (will be JSON-encoded if Map/List)
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> post(
      String endpoint, {
      dynamic body,
      Map<String, String>? headers,
    }) async {
    if (_disposed) {
      throw StateError('Client has been disposed');
    }

    // Clean endpoint to avoid double slashes
    final cleanEndpoint = endpoint.replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$_baseUrl/$cleanEndpoint');
    final httpClient = HttpClient();
    final request = await httpClient.postUrl(uri);
    
    // Add headers
    final requestHeaders = _getHeaders(additionalHeaders: headers);
    requestHeaders.forEach((key, value) => request.headers.set(key, value));
    
    // Set content type
    request.headers.contentType = ContentType.parse('application/json');
    
    // Write body if provided
    if (body != null) {
      final bodyBytes =
          body is String ? utf8.encode(body) : utf8.encode(jsonEncode(body));
      request.add(bodyBytes);
    }

    return await _handleResponse(request);
  }

  /// Makes a PUT request to the specified endpoint.
  ///
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [body] Optional request body (will be JSON-encoded if Map/List)
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> put(
      String endpoint, {
      dynamic body,
      Map<String, String>? headers,
    }) async {
    if (_disposed) {
      throw StateError('Client has been disposed');
    }

    // Clean endpoint to avoid double slashes
    final cleanEndpoint = endpoint.replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$_baseUrl/$cleanEndpoint');
    final httpClient = HttpClient();
    final request = await httpClient.putUrl(uri);
    
    // Add headers
    final requestHeaders = _getHeaders(additionalHeaders: headers);
    requestHeaders.forEach((key, value) => request.headers.set(key, value));
    
    // Set content type
    request.headers.contentType = ContentType.parse('application/json');
    
    // Write body if provided
    if (body != null) {
      final bodyBytes =
          body is String ? utf8.encode(body) : utf8.encode(jsonEncode(body));
      request.add(bodyBytes);
    }

    return await _handleResponse(request);
  }

  /// Makes a DELETE request to the specified endpoint.
  ///
  /// [endpoint] The API endpoint (will be appended to base URL)
  /// [headers] Optional additional headers
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> delete(
      String endpoint, {
      Map<String, String>? headers,
    }) async {
    if (_disposed) {
      throw StateError('Client has been disposed');
    }

    // Clean endpoint to avoid double slashes
    final cleanEndpoint = endpoint.replaceAll(RegExp(r'^/+'), '');
    final uri = Uri.parse('$_baseUrl/$cleanEndpoint');
    final httpClient = HttpClient();
    final request = await httpClient.deleteUrl(uri);
    
    // Add headers
    final requestHeaders = _getHeaders(additionalHeaders: headers);
    requestHeaders.forEach((key, value) => request.headers.set(key, value));
    
    return await _handleResponse(request);
  }

  /// Handles the HTTP response, checking for errors and throwing appropriate exceptions.
  ///
  /// [request] The HttpClientRequest to execute
  /// Returns a Future that completes with the HTTP response
  Future<HttpClientResponse> _handleResponse(
      HttpClientRequest request) async {
    final response = await request.close();

    // Handle rate limiting (429) with retry would go here per spec
    // For now, we'll handle it in the service layer as mentioned in "Fora de escopo"
    
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(
            'Bad request: ${response.reasonPhrase}');
      case 401:
        throw UnauthorizedException(
            'Unauthorized: ${response.reasonPhrase}');
      case 403:
        throw ForbiddenException(
            'Forbidden: ${response.reasonPhrase}');
      case 404:
        throw NotFoundException(
            'Not found: ${response.reasonPhrase}');
      case 500:
        throw InternalServerErrorException(
            'Internal server error: ${response.reasonPhrase}');
      case >= 500 && < 600:
        throw InternalServerErrorException(
            'Server error: ${response.statusCode} ${response.reasonPhrase}');
    }

    return response;
  }
}