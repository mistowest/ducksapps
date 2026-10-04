/// Modelo de resposta de autenticação baseado na análise do app.
class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final User? user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  /// Cria uma resposta de auth a partir de um JSON (geralmente da resposta da API)
  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['access_token'] ?? json['token'] ?? '',
        refreshToken: json['refresh_token'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );

  /// Converte o objeto para um JSON (para envio ou armazenamento)
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user': user?.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponse &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          user == other.user;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode ^
      user.hashCode;

  @override
  String toString() {
    return 'AuthResponse{accessToken: $accessToken, refreshToken: $refreshToken, user: $user}';
  }
}