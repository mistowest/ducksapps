/// Modelo de resposta de token baseado na análise do app.
class TokenResponse {
  final String accessToken;
  final String? refreshToken;

  const TokenResponse({
    required this.accessToken,
    this.refreshToken,
  });

  /// Cria uma resposta de token a partir de um JSON (geralmente da resposta da API)
  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['access_token'] ?? json['token'] ?? '',
        refreshToken: json['refresh_token'],
      );

  /// Converte o objeto para um JSON (para envio ou armazenamento)
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenResponse &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode;

  @override
  String toString() {
    return 'TokenResponse{accessToken: $accessToken, refreshToken: $refreshToken}';
  }
}