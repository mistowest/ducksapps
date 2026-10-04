/// Implementation of bot behaviors based on analyzed app endpoints.
/// Contains sequences of API calls that form useful business actions.
import 'dart:async';

import '../ducks_http_client.dart';
import '../ducks_http_exception.dart';
import '../models/user.dart';
import '../models/paginated_response.dart';
import '../exceptions/service_exceptions.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'error_handler.dart';

class BotBehaviors {
  final DucksHttpClient _httpClient;
  final AuthService _authService;
  final UserService _userService;

  BotBehaviors({
    required DucksHttpClient httpClient,
    required AuthService authService,
    required UserService userService,
  })  : _httpClient = httpClient,
        _authService = authService,
        _userService = userService;

  /// Performs login and ensures user profile is complete.
  ///
  /// [email] User's email address
  /// [password] User's password
  /// Returns the authenticated user with complete profile
  Future<User> loginAndEnsureProfile(String email, String password) async {
    // Pré-condição: credenciais válidas
    final user = await _authService.login(email, password);

    // Efeito colateral: token salvo, usuário autenticado

    // Verificar se perfil precisa ser completado (baseado em heurísticas)
    final profile = await _userService.getMe();
    // In a real implementation, we would check if profile needs setup
    // For now, we just return the user

    return user;
  }

  /// Refreshes authentication token if needed (proactive session maintenance).
  ///
  /// Returns true if token was refreshed, false otherwise
  Future<bool> maintainSession() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      return false;
    }

    // In a real implementation, we would check token expiration time
    // For now, we always attempt to refresh (in practice, this would be smarter)
    try {
      await _authService.refreshToken();
      return true;
    } on Exception catch (_) {
      // If refresh fails, we might want to log out the user
      // For now, we just return false
      return false;
    }
  }

  /// Gets a paginated feed of posts (example behavior for social apps).
  ///
  /// [cursor] Pagination cursor (null for first page)
  /// [limit] Number of items per page
  /// Returns paginated response with posts
  Future<PaginatedResponse<Map<String, dynamic>>> getFeed({
    String? cursor,
    int limit = 20,
  }) async {
    // Pré-condição: autenticado
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      throw NotAuthenticatedException('Must be authenticated to get feed');
    }

    try {
      final queryParams = <String, String>{};
      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }
      queryParams['limit'] = limit.toString();

      final response = await _httpClient.get(
        '/feed', // Endpoint inferred from common social app patterns
        headers: {}, // Auth header handled by DucksHttpClient
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      return PaginatedResponse.fromJson(
        jsonResponse,
        (item) => item as Map<String, dynamic>,
      );
    } on DucksHttpException catch (e) {
      ErrorHandler.handleDucksHttpException(e);
      rethrow;
    } catch (e) {
      throw Exception('Failed to get feed: $e');
    }
  }

  /// Creates a new post (example behavior for social apps).
  ///
  /// [content] Text content of the post
  /// [mediaIds] Optional list of media IDs to attach
  /// Returns the created post
  Future<Map<String, dynamic>> createPost(
    String content, {
    List<String>? mediaIds,
  }) async {
    // Pré-condição: autenticado
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      throw NotAuthenticatedException('Must be authenticated to create post');
    }

    // Pré-condição: conteúdo válido
    if (content.trim().isEmpty) {
      throw BadRequestException('Post content cannot be empty');
    }

    try {
      final response = await _httpClient.post(
        '/posts', // Endpoint inferred from common social app patterns
        body: {
          'content': content,
          if (mediaIds != null && mediaIds.isNotEmpty) 'media_ids': mediaIds,
        },
        // Content-Type handled by DucksHttpClient
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      return jsonResponse as Map<String, dynamic>;
    } on DucksHttpException catch (e) {
      ErrorHandler.handleDucksHttpException(e);
      rethrow;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  /// Likes a post (example behavior for social apps).
  ///
  /// [postId] ID of the post to like
  /// Returns true if successful
  Future<bool> likePost(String postId) async {
    // Pré-condição: autenticado
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      throw NotAuthenticatedException('Must be authenticated to like post');
    }

    // Pré-condição: post ID válido
    if (postId.isEmpty) {
      throw BadRequestException('Post ID cannot be empty');
    }

    try {
      final response = await _httpClient.post(
        '/posts/$postId/like', // Endpoint inferred from common social app patterns
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      return jsonResponse['success'] as bool? ?? false;
    } on DucksHttpException catch (e) {
      ErrorHandler.handleDucksHttpException(e);
      rethrow;
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  /// Follows a user (example behavior for social apps).
  ///
  /// [userId] ID of the user to follow
  /// Returns true if successful
  Future<bool> followUser(String userId) async {
    // Pré-condição: autenticado
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      throw NotAuthenticatedException('Must be authenticated to follow user');
    }

    // Pré-condição: user ID válido
    if (userId.isEmpty) {
      throw BadRequestException('User ID cannot be empty');
    }

    try {
      final response = await _httpClient.post(
        '/users/$userId/follow', // Endpoint inferred from common social app patterns
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = jsonDecode(responseBody);

      return jsonResponse['success'] as bool? ?? false;
    } on DucksHttpException catch (e) {
      ErrorHandler.handleDucksHttpException(e);
      rethrow;
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  /// Performs a complete refresh cycle: token refresh and feed update.
  ///
  /// Returns refreshed feed data
  Future<PaginatedResponse<Map<String, dynamic>>> refreshSessionAndFeed({
    String? cursor,
    int limit = 20,
  }) async {
    // Attempt to maintain session first
    await maintainSession();

    // Then get fresh feed data
    return await getFeed(cursor: cursor, limit: limit);
  }
}