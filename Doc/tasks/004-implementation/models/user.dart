/// Modelo de usuário baseado na análise do app.
/// Campos inferidos a partir da estrutura de resposta esperada.
class User {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final DateTime? createdAt;
  final bool? isActive;

  const User({
    this.id,
    this.email,
    this.name,
    this.role,
    this.createdAt,
    this.isActive,
  });

  /// Cria um usuário vazio para estados não autenticados
  factory User.empty() => const User(
        id: null,
        email: null,
        name: null,
        role: 'anon',
        createdAt: null,
        isActive: false,
      );

  /// Cria um usuário a partir de um JSON (geralmente da resposta da API)
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String?,
        email: json['email'] as String?,
        name: json['name'] as String?,
        role: json['role'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        isActive: json['is_active'] as bool?,
      );

  /// Tenta extrair informações do usuário de um token JWT
  /// Nota: Esta é uma implementação simplificada - em produção seria necessário
  /// decodificar o token properly
  factory User.fromToken(String token) {
    try {
      // Dividir o token JWT em partes
      final parts = token.split('.');
      if (parts.length != 3) return User.empty();

      // Decodificar o payload (parte do meio)
      final payload = _decodeBase64Url(parts[1]);
      final payloadJson = jsonDecode(payload) as Map<String, dynamic>;

      return User(
        id: payloadJson['sub'] as String?,
        email: payloadJson['email'] as String?,
        name: payloadJson['name'] as String?,
        role: payloadJson['role'] as String?,
        createdAt: payloadJson['iat'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (payloadJson['iat'] as num) * 1000,
              )
            : null,
      );
    } catch (_) {
      return User.empty();
    }
  }

  /// Decodifica uma string base64url (usada em JWT)
  static String _decodeBase64Url(String input) {
    // Adicionar padding se necessário
    final output = input
        .replaceAll('-', '+')
        .replaceAll('_', '/');

    final remainder = output.length % 4;
    if (remainder > 0) {
      return output + '=' * (4 - remainder);
    } else {
      return output;
    }

    // Note: This is a simplified version - in production would need proper base64url decoding
    // For now, returning a placeholder
    return '{}'; // Placeholder - actual implementation would decode properly
  }

  /// Converte o usuário para um JSON (para armazenamento)
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'created_at': createdAt?.toIso8601String(),
        'is_active': isActive,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          role == other.role &&
          createdAt == other.createdAt &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      role.hashCode ^
      createdAt.hashCode ^
      isActive.hashCode;

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name, role: $role, '
        'createdAt: $createdAt, isActive: $isActive}';
  }
}